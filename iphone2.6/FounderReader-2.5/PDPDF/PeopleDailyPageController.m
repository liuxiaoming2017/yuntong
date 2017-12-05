//
//  PeopleDailyPageController.m
//  FounderReader-2.5
//
//  Created by ld on 14-3-5.
//
//

#import "PeopleDailyPageController.h"
#import "ColumnBarConfig.h"
#import "Column.h"
#import "PeopleDailyColumnListPageController.h"
#import "PeopleDailyPDFPageController.h"
#import "PeopleDailyColumnsPageController.h"
#import "NSString+Helper.h"
#import "ColumnBarPageController.h"
#import "MFSideMenu.h"
#import "NewsListConfig.h"
#import "UIView+Extention.h"
#import "FileLoader.h"
#import "PDFpaper.h"
#import "PDFPageDataModel.h"
#import <UMMobClick/MobClick.h>
#import "AppStartInfo.h"

@interface PeopleDailyPageController ()<PDFPagerChangeDelegate>
@property(nonatomic,retain) PDFColumnBar *columnBar;
@property(nonatomic,retain) NSString *currentPaperId;
@property(nonatomic,retain) NSString *currentPaperDate;

@end

@implementation PeopleDailyPageController
@synthesize columnBar;
@synthesize columnListController,pdfPageController;
@synthesize currentColumnIndex;
@synthesize currentPaperId,currentPaperDate;
@synthesize allPages, pagesWithArticle, paperArray;

- (id)initWithColumn:(Column *)column withIsMain:(int)isMain
{
    self = [super init];
    if (self) {
        self.column = column;
        self.isMain = isMain;
    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    if ((self.viewControllerType == FDViewControllerForDetailVC)) {
        [self.tabBarController.tabBar setHidden:YES];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.viewControllerType != FDViewControllerForDetailVC) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
}

-(void)goPDFBack{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)goColumns
{
    [MobClick event:@"epaper_use" attributes:@{@"epaper_use_click":NSLocalizedString(@"往期阅读", nil)}];
    PeopleDailyColumnsPageController *controller = [[PeopleDailyColumnsPageController alloc]init];
    controller.leftArray = self.paperArray;
    controller.isMain = self.isMain;
    if (self.parentColumn) {
        controller.parentColumn = self.parentColumn;
    }
    controller.pdfDelegate = self;
    controller.isPDF = YES;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)addColumnBar
{
    columnBar = [[PDFColumnBar alloc] initWithFrame:CGRectMake(0, 0, kSWidth, kNavBarHeight)];
    // 数字报在主栏目
    if (self.isMain){
        columnBar.frame = CGRectMake(0, -20, kSWidth, kNavBarHeight);
        UIImage *backImage = [UIImage imageNamed:@"icon_righthead_more"];
        UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        rightButton.frame = CGRectMake(kSWidth-backImage.size.width-5, kNavBarHeight-35, backImage.size.width, backImage.size.height);
        [rightButton setBackgroundImage:backImage forState:UIControlStateNormal];
        [rightButton addTarget:self action:@selector(goColumns) forControlEvents:UIControlEventTouchUpInside];
        [columnBar addSubview:rightButton];
    }
    else{
        columnBar.frame = CGRectMake(0, 0, kSWidth, kNavBarHeight);
    }
    self.columnBar.dataSource = self;
    self.columnBar.delegate = self;

    [self.view addSubview:self.columnBar];
    if (!self.isMain) {
        [self leftAndRightButton];
    }
    [self.columnBar selectTabAtIndex:0];
}


-(void)leftAndRightButton
{
    UIView *leftButton = [[UIView alloc] initWithFrame:CGRectMake(0,20,60,44)];
    UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake([NewsListConfig sharedListConfig].left_userIcon_width, 11, 22, 22)];
    imageview.image = [UIImage imageNamed:@"icon-head"];
    imageview.contentMode = UIViewContentModeScaleToFill;
    [leftButton addSubview:imageview];
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(left)];
    [leftButton addGestureRecognizer:recognizer];
 
    if (self.navStyle == 1) {
        imageview.image = [UIImage imageNamed:@"nav_bar_back"];
        recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goRightPageBackDisMisss)];
        [leftButton addGestureRecognizer:recognizer];
    }
    if (self.navStyle != 1 && [AppStartInfo sharedAppStartInfo].ucTabisShow) {
        
    }else{
        [columnBar addSubview:leftButton];
    }
   
    UIImage *backImage = [UIImage imageNamed:@"icon_righthead_more"];
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(kSWidth-backImage.size.width-5, kNavBarHeight-35, backImage.size.width, backImage.size.height);
    [rightButton setBackgroundImage:backImage forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(goColumns) forControlEvents:UIControlEventTouchUpInside];
    [columnBar addSubview:rightButton];
}

- (void)goRightPageBackDisMisss
{
    if (self.viewControllerType == FDViewControllerForDetailVC) {
        [self.navigationController popViewControllerAnimated:YES];
        self.navigationController.navigationBarHidden = NO;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSInteger onlyOne = [[[NSUserDefaults standardUserDefaults] objectForKey:@"onlyOne"] integerValue];
    //创建版面图视图
    if (self.isMain){
        if (onlyOne == 2 && ![AppStartInfo sharedAppStartInfo].ucTabisShow) {
          pdfPageController = [[PeopleDailyPDFPageController alloc] initWithFrame:CGRectMake(0, 10, kSWidth, kSHeight-kNavBarHeight-10-[ColumnBarConfig sharedColumnBarConfig].columnHeaderHeight) isMain:self.isMain];
        }else{
            pdfPageController = [[PeopleDailyPDFPageController alloc] initWithFrame:CGRectMake(0, 10, kSWidth, kSHeight-kTabBarHeight-kNavBarHeight-10-[ColumnBarConfig sharedColumnBarConfig].columnHeaderHeight) isMain:self.isMain];
        }
    }
    else{
        pdfPageController = [[PeopleDailyPDFPageController alloc] initWithFrame:CGRectMake(0, kStatusBarHeight, kSWidth, kSHeight-kTabBarHeight-kNavBarHeight) isMain:self.isMain];
    }
    [self addChildViewController:self.pdfPageController];
    [self.view addSubview:self.pdfPageController.view];
    //创建版面列表视图
    columnListController = [[PeopleDailyColumnListPageController alloc] initWithMain:self.isMain];
    if (self.isMain){
        if (onlyOne == 2 && ![AppStartInfo sharedAppStartInfo].ucTabisShow) {
            columnListController.view.frame = CGRectMake(0, kTabBarHeight - 5, kSWidth, kSHeight-kNavBarHeight-[ColumnBarConfig sharedColumnBarConfig].columnHeaderHeight);
        }else{
            columnListController.view.frame = CGRectMake(0, kTabBarHeight - 5, kSWidth, kSHeight-kTabBarHeight-kNavBarHeight-[ColumnBarConfig sharedColumnBarConfig].columnHeaderHeight);
        }
    }
    else{
        columnListController.view.frame = CGRectMake(0, kTabBarHeight - 5+kStatusBarHeight, kSWidth, self.view.frame.size.height-kTabBarHeight-kNavBarHeight-kStatusBarHeight);
    }
    [self addChildViewController:self.columnListController];
    [self.view addSubview:self.columnListController.view];
    

    self.pagesWithArticle = [[NSMutableArray alloc] init];
    self.allPages = [NSArray array];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self addColumnBar];
    [columnBar reloadData];
    self.view.userInteractionEnabled = YES;
    
    leftController = [[PersonalCenterViewController alloc] init];
    self.leftController.view.frame = CGRectMake(0, 0, 240, self.view.bounds.size.height+64);
    // 左侧个人中心
    sideBar = [[CDRTranslucentSideBar alloc] init];
    self.sideBar.sideBarWidth = self.view.bounds.size.width * 0.5;
    self.sideBar.view.frame = CGRectMake(0, 0,self.view.bounds.size.width * 0.5, self.view.bounds.size.height);
    [self.sideBar setContentViewInSideBar:self.leftController.view];
    self.leftController.sideBar = self.sideBar;
    
    [self loadPapers];
    
    UISwipeGestureRecognizer *leftRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(leftSwipe:)];
    leftRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:leftRecognizer];
    
    UISwipeGestureRecognizer *rightRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(rightSwipe:)];
    rightRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:rightRecognizer];
}

-(void)leftSwipe:(UISwipeGestureRecognizer *)recognizer{
   
    if(self.currentColumnIndex == 0){
        [self.columnBar selectTabAtIndex:1];
        [self.columnBar setSelectedIndex:1];
    }
    else if(self.currentColumnIndex == 1){
        [self goColumns];
    }
}

-(void)rightSwipe:(UISwipeGestureRecognizer *)recognizer{
    
    if(self.currentColumnIndex == 1){
        [self.columnBar selectTabAtIndex:0];
        [self.columnBar setSelectedIndex:0];
    }
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)recognizer {
    
    // if you have left and right sidebar, you can control the pan gesture by start point.
    CGPoint translatedPoint = [recognizer translationInView:self.view];
    if (translatedPoint.x > 0){
        if (recognizer.state == UIGestureRecognizerStateBegan) {
            self.sideBar.isCurrentPanGestureTarget = YES;
        }
        
        [self.sideBar handlePanGestureToShow:recognizer inView:self.view];
    }
}

- (void)sideBar:(CDRTranslucentSideBar *)sideBar1 willAppear:(BOOL)animated {
    [self.leftController updateUserInfo];
}

- (void)goLeftPage:(id)sender{
    
    if(self.currentColumnIndex == 2)
        return;
    [self goPDFBack];
}

- (void)goRightPage:(id)sender{
    
    if(self.currentColumnIndex == 2)
        return;
    [self goColumns];
}

- (void)pushColumnListController
{
    [self.pdfPageController.view removeFromSuperview];
    [self.view addSubview:self.columnListController.view];
    [self.view bringSubviewToFront:self.columnBar];
}

- (void)pushPDFPageController
{
    [self.columnListController.view removeFromSuperview];
    [self.view addSubview:self.pdfPageController.view];
    [self.view bringSubviewToFront:self.columnBar];
}

#pragma mark - column bar delegate
- (void)columnBar:(PDFColumnBar *)columnBar didSelectedTabAtIndex:(int)index
{
    if (index) {
        self.currentColumnIndex = 1;
        [self pushColumnListController];
        
    } else {
        self.currentColumnIndex = 0;
        [self pushPDFPageController];
    }
    
    if (self.currentPaperId) {
        [self updatePaper:self.currentPaperId date:self.currentPaperDate];
    }
}

#pragma mark - column bar data source

- (int)numberOfTabsInColumnBar:(PDFColumnBar *)columnBar
{
    return 2;
}

- (Column *)columnBar:(PDFColumnBar *)columnBar titleForTabAtIndex:(int)index
{
    Column *column = [[Column alloc] init];
    switch (index) {
        case 1:
            column.columnName = NSLocalizedString(@"本期目录",nil);
            [MobClick event:@"epaper_use" attributes:@{@"epaper_use_click":column.columnName}];
            break;
        case 0:
            column.columnName =  NSLocalizedString(@"报纸版面",nil);
            [MobClick event:@"epaper_use" attributes:@{@"epaper_use_click":column.columnName}];
            break;
        default:
            column.columnName =  @"";
            break;
    }
    return column;
}


-(void)updatePaper:(NSString *)paperId date:(NSString *)date
{
    self.currentPaperDate = date;
    self.currentPaperId = paperId;
    [self loadPaperLayouts:paperId date:date];
}

- (void)loadPapers{
    
    NSString *urlString = [NSString stringWithFormat:@"%@/api/getPapers?sid=%@",[AppConfig sharedAppConfig].serverIf,[AppConfig sharedAppConfig].sid];
    
    FileLoader *request = [FileLoader fileLoaderWithUrl:urlString];
    [request setCompletionBlock:^(NSData *data) {
        NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers  error:nil];
        if (dataDic) {
            NSArray *Arry = [dataDic objectForKey:@"papers"];
            if (Arry.count) {
                self.paperArray = [PDFpaper papersFromArray:Arry];
                PDFpaper *paper = [self.paperArray firstObject];
                self.currentPaperId = paper.paperId;
                [self loadPaperLayouts:paper.paperId date:@""];
            }
        }
        
    }];
    [request setFailedBlock:^(NSError *error) {
        XYLog(@"load Columns failed: %@", error);
        
    }];
    [request startAsynchronous];
}


- (void)loadPaperLayouts:(NSString*)paperId date:(NSString *)date
{
    NSString *urlString = [NSString stringWithFormat:@"%@/api/getLayouts?sid=%@&cid=%@&date=%@",[AppConfig sharedAppConfig].serverIf,[AppConfig sharedAppConfig].sid,paperId,date];
    
    HttpRequest *request = [HttpRequest requestWithURL:[NSURL URLWithString:urlString]];
    [request setCompletionBlock:^(NSData *data) {
        NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers  error:nil];
        if (dataDic) {
            NSArray *Arry = [dataDic objectForKey:@"layouts"];
            //最顶上日期
            self.currentPaperDate = [NSString stringWithFormat:@"%@", Arry[0][@"date"]];
            if (Arry.count) {
                
                self.allPages = [PDFPageDataModel pagesFromArray:Arry];
                [self.pagesWithArticle removeAllObjects];
                for(int i = 0; i < self.allPages.count; i++){
                    PDFPageDataModel *page = [self.allPages objectAtIndex:i];
                    if(page.articlesList.count > 0){
                        [self.pagesWithArticle addObject:page];
                    }
                }
                [self loadPageFinished];
            }
        }
        
    }];
    [request setFailedBlock:^(NSError *error) {
        XYLog(@"load Columns failed: %@", error);
        
    }];
    [request startAsynchronous];
}

-(void)loadPageFinished{
    
    pdfPageController.allPages = self.allPages;
    pdfPageController.selectedDate = self.currentPaperDate;
    [pdfPageController reloadPage];
    columnListController.pagesWithArticle = self.pagesWithArticle;
    columnListController.selectedDate = self.currentPaperDate;
    
    [columnListController reloadPage];
}
@end
