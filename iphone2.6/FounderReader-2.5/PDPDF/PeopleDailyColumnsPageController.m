//
//  PeopleDailyColumnsPageController.m
//  FounderReader-2.5
//
//  Created by ld on 14-3-14.
//
//

#import "PeopleDailyColumnsPageController.h"
#import "Column.h"
#import "ArticleRequest.h"
#import "Article.h"
#import "PDFpaper.h"
#import "FileLoader.h"
#import "PDFpassWordView.h"
#import "YXLoginViewController.h"
#import "UIAlertView+Helper.h"
#import "UIDevice-Reachability.h"
#import "AppStartInfo.h"
#import "ColumnBarConfig.h"
#import "ColorStyleConfig.h"

#define PAPERTYPE 0

@interface PeopleDailyColumnsPageController ()<UITableViewDataSource,UITableViewDelegate,PDFpassWordViewDelegate,YXLoginViewControllerDelegate>
{
    NSUInteger LeftRow;
    NSUInteger rightRow;
}

@property(nonatomic,retain) UITableView *leftList;
@property(nonatomic,retain) UITableView *rightList;
@property(nonatomic,retain) NSArray *rightArray;
@end

@implementation PeopleDailyColumnsPageController
@synthesize leftList,rightList,rightArray;


- (void)viewDidLoad {

    [super viewDidLoad];
    UIView *viewTOP =  [[UIView alloc] init];
    viewTOP.frame = CGRectMake(0, 0, kSWidth, 64);
    viewTOP.backgroundColor = [UIColor colorWithPatternImage:[Global navigationImage]];
    [self.view addSubview:viewTOP];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(10, 31, 22, 22);
    [backButton setImage:[UIImage imageNamed:@"nav_bar_back"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(goBackPageBack) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
    UILabel *navTitle = [[UILabel alloc] initWithFrame:CGRectMake((kSWidth-140)/2, 20, 140, 44)];
    navTitle.text = NSLocalizedString(@"往期阅读",nil);
    navTitle.font = [UIFont systemFontOfSize:18];
    navTitle.textAlignment = NSTextAlignmentCenter;
    navTitle.backgroundColor = [UIColor clearColor];
    navTitle.textColor = [ColorStyleConfig sharedColorStyleConfig].navbar_titlecolor_selected;
    [self.view addSubview:navTitle];
    
    LeftRow = 0;
    rightRow = 1000;
    
    leftList = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.leftList.frame = CGRectMake(0, 64, kSWidth*(110/320.0), kSHeight - 64);
    self.leftList.backgroundColor = UIColorFromString(@"237,237,237");
    self.leftList.bounces = NO;
    self.leftList.delegate = self;
    self.leftList.dataSource = self;
    self.leftList.separatorStyle = 0;
    [self.view addSubview:self.leftList];

    rightList = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
    {
        self.rightList.frame = CGRectMake(kSWidth*(110/320.0), 64, kSWidth-self.leftList.frame.size.width, kSHeight - 64);
    }
    self.rightList.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.rightList.delegate = self;
    self.rightList.dataSource = self;
    self.rightList.bounces = NO;
    self.rightList.separatorStyle = 0;
    [self.view addSubview:self.rightList];
    
    [self loadLeftPapers];
    self.navigationItem.rightBarButtonItem = nil;
    
    UISwipeGestureRecognizer *rightRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(goBackPageBack)];
    rightRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:rightRecognizer];
    
    
}
-(void)goBackPageBack{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)goNavBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)backButton
{
    UIImage *leftImage = [UIImage imageNamed:@"pdfBack"];
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftButton.frame = CGRectMake(0, 0, leftImage.size.width, leftImage.size.height);
    [leftButton setBackgroundImage:leftImage forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(goPDFBack) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = left;
 
}
-(void)goPDFBack
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.tabBarController.tabBar setHidden:NO];
}

- (void)loadLeftPapers
{
    [self.leftList reloadData];
    
    NSInteger selectIndex = [[[NSUserDefaults standardUserDefaults] objectForKey:@"selectIndex"] integerValue];
    if(selectIndex >= self.leftArray.count){
        selectIndex = 0;
    }
    PDFpaper *paper = [self.leftArray objectAtIndex:selectIndex];
    [self loadRightEveryDayPaper:paper];
    //设置默认第一行样式
    if (self.leftArray.count) {
        
        [self.leftList selectRowAtIndexPath:[NSIndexPath indexPathForRow:selectIndex inSection:0] animated:NO scrollPosition:1];
        LeftRow = selectIndex;
        UITableViewCell *selectedCell = [self.leftList cellForRowAtIndexPath:[NSIndexPath indexPathForRow:selectIndex inSection:0]];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 2, 3, selectedCell.frame.size.height)];
        label.backgroundColor = [ColumnBarConfig sharedColumnBarConfig].column_all_color;
        label.tag = 110;
        [selectedCell addSubview:label];
        //        selectedCell.textLabel.textColor = [UIColor colorWithRed:245/255.0 green:67/255.0 blue:67/255.0 alpha:1];
    }
}

- (void)loadRightEveryDayPaper:(PDFpaper *)paper
{
    if (![UIDevice networkAvailable])
        return;

    NSString *urlString = [NSString stringWithFormat:@"%@/api/getPaperDates?sid=%@&cid=%@&type=%d",[AppConfig sharedAppConfig].serverIf,[AppConfig sharedAppConfig].sid,paper.paperId,PAPERTYPE];
 
    FileLoader *request = [FileLoader fileLoaderWithUrl:urlString];
    [request setCompletionBlock:^(NSData *data) {
        NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers  error:nil];
        if (dataDic) {
            self.rightArray = [dataDic objectForKey:@"dates"];
        }
        [self.rightList reloadData];
        
    }];
    [request setFailedBlock:^(NSError *error) {
        XYLog(@"load Columns failed: %@", error);
        
    }];
    [request startAsynchronous];
}



#pragma mark - table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == self.leftList)
        return self.leftArray.count;
    else
        return self.rightArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kSWidth*(40/320.0);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    if (tableView == self.leftList) {
        
        UITableViewCell *leftCell = [tableView dequeueReusableCellWithIdentifier:@"leftpdfcolumns"];
        if (!leftCell)
        {
            leftCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"leftpdfcolumns"];
            
            leftCell.backgroundColor = UIColorFromString(@"237,237,237");
            leftCell.textLabel.font=[UIFont fontWithName:[Global fontName] size:16];
            leftCell.textLabel.textAlignment = 1;
            UIImageView *selectedImageView = [[UIImageView alloc] initWithFrame:leftCell.contentView.bounds];
            
            selectedImageView.backgroundColor = [UIColor whiteColor];
            leftCell.selectedBackgroundView = selectedImageView;
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 3, selectedImageView.frame.size.height*kScale+4)];
            label.backgroundColor = [ColumnBarConfig sharedColumnBarConfig].column_all_color;
            [selectedImageView addSubview:label];
        }
        
        PDFpaper *paper = [self.leftArray objectAtIndex:indexPath.row];
        leftCell.textLabel.text = paper.paperName;
        return leftCell;
    }
    else
    {
        UITableViewCell *rightCell = [tableView dequeueReusableCellWithIdentifier:@"rightPdfcolumns"];
        UIView *line = nil;
        if (!rightCell)
        {
            rightCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"rightPdfcolumns"];
            [rightCell setSelectionStyle:UITableViewCellSelectionStyleNone];

            rightCell.textLabel.font=[UIFont fontWithName:[Global fontName] size:16];
            rightCell.textLabel.textAlignment = NSTextAlignmentLeft;
            rightCell.backgroundColor = [UIColor clearColor];

            line = [[UIView alloc]initWithFrame:CGRectMake(10, kSWidth*(40/320.0)-0.5, tableView.frame.size.width-20, 0.5)];
            line.backgroundColor = [UIColor colorWithRed:192/255.0 green:192/255.0 blue:192/255.0 alpha:1];
            [rightCell.contentView addSubview:line];
        }
        Class cal = NSClassFromString(@"UIButton");
        for (UIView *view in rightCell.contentView.subviews) {
            if ([view isKindOfClass:cal]) { 
                [view removeFromSuperview];
            }
        }
        _readBtn = [[UIButton alloc] init];
        [_readBtn setFrame:CGRectMake((250/480.0)*kSWidth, 13*kSHeight/667, 22, 22)];
        [rightCell.contentView addSubview:_readBtn];
        [_readBtn setBackgroundImage:[UIImage imageNamed:@"btn-read"] forState:UIControlStateNormal];
        NSDictionary *dic = [self.rightArray objectAtIndex:indexPath.row];
        rightCell.textLabel.text = [NSString stringWithFormat:@"    %@",[dic objectForKey:@"date"]];//7个空格
        _readBtn.tag = indexPath.row;
        _readBtn.userInteractionEnabled = NO;        
        return rightCell;
    }
}


- (void)readPDF:(int)row
{
    rightRow = row;
    [self showSelectedPaper];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.leftList) {
        
        if (self.leftArray.count > indexPath.row){
            PDFpaper* paper = [self.leftArray objectAtIndex:indexPath.row];
            [[NSUserDefaults standardUserDefaults] setInteger:indexPath.row forKey:@"selectIndex"];
            LeftRow = indexPath.row;
            UILabel *label = (UILabel *)[tableView viewWithTag:110];
            [label removeFromSuperview];
            [self loadRightEveryDayPaper:paper];
            [self.rightList reloadData];
        }
    }
    else{
        if (self.rightArray.count > indexPath.row){
            [self readPDF: (int)indexPath.row];
        }
    }
}

-(void)showPostPassWordView
{
    PDFpassWordView *psView = [[PDFpassWordView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    psView.pwTextField.delegate = self;
    [appDelegate().window addSubview:psView];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

-(void)showSelectedPaper
{
    PDFpaper* paper = [self.leftArray objectAtIndex:LeftRow];
    NSDictionary *dic = [self.rightArray objectAtIndex:rightRow];
    [self.pdfDelegate updatePaper:[NSString stringWithFormat:@"%d",[paper.paperId intValue]] date:[dic objectForKey:@"date"]];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)showLoginPage
{
    if (![UIDevice networkAvailable])
        return;
    
    YXLoginViewController *controller = [[YXLoginViewController alloc]init];
    controller.isNavBack = YES;
    [controller leftNavBackButton];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)loginFinished
{
   
}

-(void)postPDFpasswordFinished
{
    [self showSelectedPaper];
}
@end
