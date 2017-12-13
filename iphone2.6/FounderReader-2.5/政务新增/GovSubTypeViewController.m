//
//  GovSubTypeViewController.m
//  FounderReader-2.5
//
//  Created by 黄柳姣 on 2017/12/4.
//

#import "GovSubTypeViewController.h"
#import "ColorStyleConfig.h"
#import "ArticleRequest.h"
#import "Article.h"
#import "MiddleCell.h"
#import "NewsCellUtil.h"
#import "VideoCell.h"
#import "UserAccountDefine.h"

@interface GovSubTypeViewController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong)NSArray *dataArr;
@property(nonatomic,copy) NSString *titleStr;
@property(nonatomic,assign) BOOL isSelected;
@property(nonatomic,strong) UIButton *navRightBtn;
@property(nonatomic,strong) NSDictionary *columnDic;
@end

@implementation GovSubTypeViewController

- (id)initWithDataArr:(NSArray *)arr withDic:(NSDictionary *)dic withSelected:(BOOL)selected
{
    self = [super init];
    if(self){
        self.dataArr = arr;
        self.columnDic=dic;
        self.isSelected = selected;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNav];
    [self initUI];
    [self.tableView reloadData];
   // [self requestData];
}

- (void)requestData
{
    ArticleRequest *request = [ArticleRequest articleRequestWithColumnId:116 lastFileId:0 count:20 rowNumber:0];
    [request setCompletionBlock:^(NSArray *arr) {
        self.dataArr=arr;
        [self.tableView reloadData];
    }];
    [request setFailedBlock:^(NSError *error) {
        
    }];
    [request startAsynchronous];
}

- (void)initUI
{
    navTitleLabel.text=[self.columnDic objectForKey:@"columnName"];
    //表视图
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kSWidth, kSHeight-20-44) style:UITableViewStylePlain];
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
}

- (void)setupNav
{
    
    // 设置导航默认标题的颜色及字体大小
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [ColorStyleConfig sharedColorStyleConfig].navbar_titlecolor_didselect,
                                                                    NSFontAttributeName : [UIFont boldSystemFontOfSize:18]};
    
    UIButton *preBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    preBtn.tag = 111;
    [preBtn setImage:[UIImage imageNamed:@"nav_bar_back"] forState:UIControlStateNormal];
    [preBtn sizeToFit];
    preBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    preBtn.contentEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
    [preBtn addTarget:self action:@selector(goBack2) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:preBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    self.navRightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.navRightBtn setImage:[UIImage imageNamed:@"order"] forState:UIControlStateNormal];
    [self.navRightBtn setImage:[UIImage imageNamed:@"ordered"] forState:UIControlStateSelected];
    [self.navRightBtn addTarget:self action:@selector(rightAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navRightBtn.selected=self.isSelected;
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:self.navRightBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArr.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(cell==nil){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        
    }
    Article *article = nil;
    NSArray *articleArr = [Article articlesFromArray:self.dataArr];
    if(articleArr.count>indexPath.row){
        article = [articleArr objectAtIndex:indexPath.row];
        cell=[NewsCellUtil getNewsCell:article in:tableView];
        if([cell isKindOfClass:[VideoCell class]]){
            VideoCell *cell2 = (VideoCell *)cell;
            cell2.row=indexPath.row;
            cell2.delegate=self;
        }
    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *articleArr = [Article articlesFromArray:self.dataArr];
    Article *article = nil;
    if (articleArr.count > indexPath.row) {
        article = [articleArr objectAtIndex:indexPath.row];
    }
    return [NewsCellUtil getNewsCellHeight:article];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    Article *currentAricle = nil;
    if (self.dataArr.count > indexPath.row) {
        NSArray *articleArr = [Article articlesFromArray:self.dataArr];
        currentAricle = [articleArr objectAtIndex:indexPath.row];
    }
    Column *column = [columns objectAtIndex:columnBar.selectedIndex];
    
    [NewsCellUtil clickNewsCell:currentAricle column:column in:self];
    
    
    
}


//订阅按钮
- (void)rightAction:(UIButton *)button
{
    if(!button.selected){
        NSString *url = [NSString stringWithFormat:@"%@/api/%@", [AppConfig sharedAppConfig].serverIf,@"submitSubscribe"];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
        request.HTTPMethod = @"POST";
        request.HTTPBody = [[NSString stringWithFormat:@"cid=%d&uid=%d",[[self.columnDic objectForKey:@"columnID"]intValue],[[[NSUserDefaults standardUserDefaults] objectForKey:KuserAccountUserId] intValue]] dataUsingEncoding:NSUTF8StringEncoding];
        
        NSURLSession *session = [NSURLSession sharedSession];
        // 由于要先对request先行处理,我们通过request初始化task
        NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            if([[dic objectForKey:@"success"] integerValue] == 1){
                dispatch_async(dispatch_get_main_queue(), ^{
                    button.selected=!button.selected;
                    [Global showCustomMessage:@"您已成功定制此栏目"];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"submitSubscribe" object:self];
                });
                
            }
        }];
        [task resume];
        
    }else{
        NSString *url = [NSString stringWithFormat:@"%@/api/%@", [AppConfig sharedAppConfig].serverIf,@"cancelSubscribe"];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
        request.HTTPMethod = @"POST";
        request.HTTPBody = [[NSString stringWithFormat:@"cid=%d&uid=%d",[[self.columnDic objectForKey:@"columnID"]intValue],[[[NSUserDefaults standardUserDefaults] objectForKey:KuserAccountUserId] intValue]] dataUsingEncoding:NSUTF8StringEncoding];
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            if([[dic objectForKey:@"success"] integerValue] == 1){
                dispatch_async(dispatch_get_main_queue(), ^{
                    button.selected=!button.selected;
                    [Global showCustomMessage:@"您已成功取消定制此栏目"];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"cancelSubscribe" object:self];
                });
            }
        }];
        [task resume];
    }
}

- (void)goBack2
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
}





@end
