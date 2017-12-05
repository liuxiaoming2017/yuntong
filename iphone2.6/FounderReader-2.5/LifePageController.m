//
//  NewsPageController.m
//  FounderReader-2.5
//
//  Created by chenfei on 4/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LifePageController.h"
#import "Column.h"
#import "Article.h"
#import "MiddleCell.h"
#import "MoreCell.h"
#import "NewsListConfig.h"
#import "NSString+Helper.h"
#import "TemplateDetailPageController.h"
#import "AppStartInfo.h"
#import "HeaderNewsWidget.h"
#import "ImageDetailPageController.h"
#import "UIDevice-Reachability.h"
#import <MediaPlayer/MediaPlayer.h>
#import "DataLib/DataLib.h"
#import "GroupImage_MiddleCell.h"
#import "SpecialNewsPageController.h"
#import "GroupImageConfig.h"
#import "CDRTranslucentSideBar.h"
#import "UIImage+Helper.h"
#import "PersonalCenterViewController.h"
#import "UIView+Extention.h"
#import "NJEventRequest.h"
#import "SeeRootViewController.h"
#import "TemplateNewDetailViewController.h"
#import "FounderIntegralRequest.h"
#import "ColumnRequest.h"
#import "ArticleRequest.h"
#import "ColumnBarConfig.h"
#import "NJWebPageController.h"
#import "NewsCellUtil.h"
#import "ColorStyleConfig.h"

@interface LifePageController () <HeaderNewsWidgetDelegate, CDRTranslucentSideBarDelegate>
{
    UIView *_columnLabel;
    UIView *_headWhiteLable;
}

@property (nonatomic, retain) NSMutableDictionary *saveIsRedDic;
@property (nonatomic, retain) NSArray *groupImageConfigs;
@property (nonatomic, retain) NSArray *subColumns;
@property (nonatomic, retain) NSMutableArray *lifeColumns;
@end

@implementation LifePageController
@synthesize groupImageConfigs,subColumns,saveIsRedDic;
- (id)initWithColumn:(Column *)column withIsMain:(int)isMain
{
    self = [super init];
    if (self) {
        self.parentColumn = column;
        self.isMain = isMain;
    }
    return self;
}

- (id)initWithColumn:(Column *)column viewControllerType:(FDViewControllerType)viewControllerType
{
    self = [super init];
    if (self) {
        self.parentColumn = column;
        self.isMain = 1;
        self.viewControllerType = viewControllerType;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 调整tabelview的位置
    [self initTableViewFrame];
    
    self.lifeColumns = [[NSMutableArray alloc] init];

     //已经读过的稿件
    saveIsRedDic = [[NSMutableDictionary alloc] initWithContentsOfFile:[cacheDirPath() stringByAppendingString:kSaveIsReadFileName]];
    if (!self.saveIsRedDic) {
        saveIsRedDic = [[NSMutableDictionary alloc] init];
    }
    self.listTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    leftController = [[PersonalCenterViewController alloc] init];
    self.leftController.view.frame = CGRectMake(0, 0, 240, self.view.bounds.size.height+kNavBarHeight);
    
    sideBar = [[CDRTranslucentSideBar alloc] init];
    self.sideBar.delegate = self;
    self.sideBar.sideBarWidth = self.view.bounds.size.width * 0.5;
    self.sideBar.view.frame = CGRectMake(0, 0,self.view.bounds.size.width * 0.5, self.view.bounds.size.height);
    [self.sideBar setContentViewInSideBar:self.leftController.view];
    self.leftController.sideBar = self.sideBar;
    
    // Add PanGesture to Show SideBar by PanGesture
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    
    panGestureRecognizer.delegate = self;
    if (![AppStartInfo sharedAppStartInfo].ucTabisShow && self.viewControllerType == FDViewControllerForTabbarVC) {
        [self.view addGestureRecognizer:panGestureRecognizer];
    }
    
    //增加首页搜索框
    _searchView = [[SearchToolBarView alloc] initWithFrame:CGRectMake(0, 0, kSWidth, 40)];
    _searchView.alpha = 0.0;
    if([AppConfig sharedAppConfig].isHomeAddSearch && self.isMain && [ColumnBarConfig sharedColumnBarConfig].columnHeaderScale < 1.4){
        [self.listTableView addSubview:_searchView];
    }
   
    [self loadLifeColumns];
    if (self.viewControllerType == FDViewControllerForDetailVC) {
        UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [leftButton setImage:[UIImage imageNamed:@"nav_bar_back"] forState:UIControlStateNormal];
        [leftButton sizeToFit];
        leftButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        leftButton.contentEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
        [leftButton addTarget:self action:@selector(goRightPageBack) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
        self.navigationItem.leftBarButtonItem = leftItem;
        self.navigationItem.rightBarButtonItem = nil;
        [self titleLableWithTitle:self.parentColumn.columnName];
        self.listTableView.frame = CGRectMake(0, 0, kSWidth, kSHeight-kNavBarHeight);
    }else{
       [self configWebViewToolBar];
    }
}
-(void)goRightPageBack{
    if (self.viewControllerType == FDViewControllerForDetailVC) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [super goRightPageBack];
    }
}
// 调整tabelview的位置
- (void)initTableViewFrame{
    
    scrollViewbg.contentSize = CGSizeMake(kSWidth *columns.count, kSHeight);
    NSInteger onlyOne = [[[NSUserDefaults standardUserDefaults] objectForKey:@"onlyOne"] integerValue];
    if(self.isMain){
        if (onlyOne == 2 && ![AppStartInfo sharedAppStartInfo].ucTabisShow)
        {
            self.listTableView.frame = CGRectMake(self.listTableView.frame.origin.x, [ColumnBarConfig sharedColumnBarConfig].columnBarHeight+kStatusBarHeight, kSWidth, kSHeight-[ColumnBarConfig sharedColumnBarConfig].columnBarHeight-kStatusBarHeight);
        }
        else
        {
         self.listTableView.frame = CGRectMake(self.listTableView.frame.origin.x, [ColumnBarConfig sharedColumnBarConfig].columnBarHeight+kStatusBarHeight, kSWidth, kSHeight-[ColumnBarConfig sharedColumnBarConfig].columnBarHeight-kTabBarHeight-kStatusBarHeight);
        }
    }
    else{
        self.listTableView.frame = CGRectMake(self.listTableView.frame.origin.x, kNavBarHeight, kSWidth, kSHeight-kNavBarHeight-kTabBarHeight);
    }
}

-(void)configWebViewToolBar
{
    UIView *toolBarView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kSWidth, kNavBarHeight)];
//    toolBarView.backgroundColor = [UIColor colorWithPatternImage:[Global navigationImage]];
    toolBarView.backgroundColor = [ColorStyleConfig sharedColorStyleConfig].nav_bar_color ;
    toolBarView.userInteractionEnabled = YES;
    [self.view addSubview:toolBarView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, kStatusBarHeight, kSWidth-80, kNavBarHeight-kStatusBarHeight)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    titleLabel.textAlignment = 1;
    titleLabel.textColor = [ColorStyleConfig sharedColorStyleConfig].navbar_titlecolor_didselect;
    titleLabel.text = self.parentColumn.columnName;
    titleLabel.tag = 222;
    [toolBarView addSubview:titleLabel];
    
    if (![AppStartInfo sharedAppStartInfo].ucTabisShow) {
        
        UIButton *preBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 31, 22, 22)];
        preBtn.tag = 111;
        [preBtn addTarget:self action:@selector(left) forControlEvents:UIControlEventTouchUpInside];
        [preBtn setBackgroundImage:[UIImage imageNamed:@"icon-head"] forState:UIControlStateNormal];
        [toolBarView addSubview:preBtn];
        if(self.isMain){
            toolBarView.hidden = YES;
    }
    }
}
#pragma mark - load columns

- (void)loadColumns
{
    
}

- (void)loadLifeColumns
{
    ColumnRequest *request = [ColumnRequest columnRequestWithParentColumnId:parentColumn.columnId];
    [request setCompletionBlock:^(NSArray *array) {
        
        NSMutableArray *muArray = [[NSMutableArray alloc] initWithArray:array];
        if (array.count != 0) {
            for (int i = 0; i < array.count; i++) {
                Column *column = [array objectAtIndex:i];
                if (column.showcolumn) {
                    [muArray removeObject:column];
                }
            }
        }
        NSArray *arrayLast = [[NSArray alloc] initWithArray:muArray];
        self.lifeColumns = [[NSMutableArray alloc] initWithArray:arrayLast];
         [self loadArticlesWithColumnId:parentColumn.columnId lastFileId:0 rowNumber:0];
    }];
    
    [request setFailedBlock:^(NSError *error) {
        XYLog(@"load Columns failed: %@", error);
        [self loadColumnsFailed];
        
    }];
    [request startAsynchronous];
}

#pragma mark - Gesture Handler
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if (self.scrollViewbg.contentOffset.x < 100) {
        return YES;
    }
    return NO;
}
- (void)handlePanGesture:(UIPanGestureRecognizer *)recognizer {
    
    //侧滑手势
    if (self.scrollViewbg.contentOffset.x>0)
        return;
    
    // if you have left and right sidebar, you can control the pan gesture by start point.
    CGPoint translatedPoint = [recognizer translationInView:self.view];
    if (translatedPoint.x > 0){
        if (recognizer.state == UIGestureRecognizerStateBegan) {
            
            CGPoint startPoint = [recognizer locationInView:self.view];
            if (startPoint.y<-self.listTableView.contentOffset.y + self.listTableView.tableHeaderView.frame.size.height+kSWidth*0.19375)
            {
                return;
            }
            
            if (startPoint.x < kSWidth/3.0)
            {
                self.sideBar.isCurrentPanGestureTarget = YES;
            }
        }

        [self.sideBar handlePanGestureToShow:recognizer inView:self.view];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.columnScrollView reloadData];
    if (self.viewControllerType != FDViewControllerForDetailVC) {

        [self.navigationController setNavigationBarHidden:YES animated:YES];
        [self.tabBarController.tabBar setHidden:NO];
        [self.navigationController.navigationBar setTranslucent:NO];
        self.edgesForExtendedLayout = UIRectEdgeTop;
        NSInteger onlyOne = [[[NSUserDefaults standardUserDefaults] objectForKey:@"onlyOne"] integerValue];
        if (onlyOne == 2)
        {
            [self.tabBarController.tabBar setHidden:YES];
        }
        else
        {
            [self.tabBarController.tabBar setHidden:NO];
        }
    }else{
        self.tabBarController.tabBar.hidden = YES;
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.viewControllerType != FDViewControllerForDetailVC) {
        [self.tabBarController.tabBar setHidden:NO];
    }
    NSInteger onlyOne = [[[NSUserDefaults standardUserDefaults] objectForKey:@"onlyOne"] integerValue];
    if (onlyOne == 2)
    {
        [self.tabBarController.tabBar setHidden:YES];
    }
    else
    {
        [self.tabBarController.tabBar setHidden:NO];
    }
}

- (void)loadArticlesWithColumnId:(int)columnId lastFileId:(int)lastFileId rowNumber:(int)rowNumber
{
    columnBar.enabled = NO;
    _reloading = YES;
    ArticleRequest *request = [ArticleRequest articleRequestWithColumnId:parentColumn.columnId lastFileId:lastFileId count:[NewsListConfig sharedListConfig].count rowNumber:rowNumber];
    [request setCompletionBlock:^(NSArray *array) {
        CacheManager *manager = [CacheManager sharedCacheManager];
        hasMore = [manager hasMore:columnId rowNumber:rowNumber];
        {
            self.articles = array;
        }
        [self loadHeaderWidget];
        [self loadArticlesFinished];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:[NSDate date] forKey:[NSString stringWithFormat:@"%@%d", kLastColumn_RefreshTime, columnId]];
    }];
    [request setFailedBlock:^(NSError *error) {
        XYLog(@"load articles failed: %@", error);
        self.articles = [NSArray array];
        hasMore = NO;
        [self loadArticlesFailed];
        [Global showTipNoNetWork];
    }];
    [request startAsynchronous];
}

/**
 *  加载数据结束
 */
- (void)loadArticlesFinished
{
    [super loadArticlesFinished];
    [self.listTableView reloadData];
}

/**
 *  加载更多数据失败
 */
- (void)loadMoreArticlesFailed
{
    [super loadMoreArticlesFailed];
    
    MoreCell *cell = (MoreCell *)[self.listTableView viewWithTag:200];
    if (cell)
        [cell hideIndicator];
}


#pragma mark - table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == [self.articles count]){
        
        return  [NewsListConfig sharedListConfig].moreCellHeight;
    }
    
    Article *article = nil;
    if (self.articles.count > indexPath.row) {
        article = [self.articles objectAtIndex:indexPath.row];
    }
    
    return [NewsCellUtil getNewsCellHeight:article];
}

#pragma mark - table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.articles.count>0) {
        if (hasMore) {
            return self.articles.count+1;
        }
        return self.articles.count;
    }

    else{
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TableViewCell *cell = nil;
    if (0 == articles.count) {
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"zeroCell"];
        if (!cell){
            cell = [[TableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"zeroCell"];
        }
    }
    else if (indexPath.row == articles.count)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"MoreCell"];
        if (!cell){
            cell = [[MoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MoreCell"];
            cell.tag = 200;
            [cell configWithTitle:@"" summary:@"" date:@"" thumbnailUrl:@"" columnId:0];
        }
    }
    else
    {
        Article *article = nil;
        if (self.articles.count >indexPath.row){
            article = [self.articles objectAtIndex:indexPath.row];
            article.isRead = [[self.saveIsRedDic valueForKey:[NSString stringWithFormat:@"%d",article.fileId]] boolValue];
        }
        else{
            cell = [tableView dequeueReusableCellWithIdentifier:@"zeroCell"];
            if (!cell)
                cell = [[TableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"zeroCell"] ;
            return cell;
        }
        BOOL isHideReadCount = [self.parentColumn.keyword[@"hideReadCount"] boolValue];
        article.isHideReadCount = isHideReadCount;
        cell.article = article;
        cell = [NewsCellUtil getNewsCell:article in:tableView];
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == [self.articles count]) {
        return;
    }
    else
    {
        Article *currentAricle = nil;
        if (self.articles.count > indexPath.row) {
            currentAricle = [self.articles objectAtIndex:indexPath.row];
        }

        [NewsCellUtil clickNewsCell:currentAricle column:self.parentColumn in:self];
        
        //存储已读信息
        currentAricle.isRead = YES;
        [self.saveIsRedDic setObject:[NSNumber numberWithBool:YES] forKey:[NSString stringWithFormat:@"%d",currentAricle.fileId]];
        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark - table view delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (cell.tag == 200) {
        if (![UIDevice networkAvailable]) {
            [Global showTipNoNetWork];
            return;
        }
        if ([cell respondsToSelector:@selector(showIndicator)]) {
            [(MoreCell *)cell showIndicator];
        }
        
        //Column *column = [columns objectAtIndex:columnBar.selectedIndex];
        Article *lastArticle = [self.articles lastObject];
        [self loadMoreArticlesWithColumnId:parentColumn.columnId
                                lastFileId:lastArticle.fileId
                                 rowNumber:(int)[self.articles count]+parentColumn.topArticleNum];
    }
}

- (void)sideBar:(CDRTranslucentSideBar *)sideBar1 willAppear:(BOOL)animated {
    [self.leftController updateUserInfo];
}


- (void)addHeaderView
{
    [self.columnScrollView removeFromSuperview];
    self.columnScrollView = [[ColumnScrollView alloc] initWithFrame:CGRectMake(0, 0, kSWidth, kSWidth*0.25) withPageCount:ceil((double)self.lifeColumns.count/4)];
    self.columnScrollView.backgroundColor = [UIColor whiteColor];
    self.columnScrollView.delegate = self;
    self.columnScrollView.columns = self.lifeColumns;
    [self.columnScrollView reloadData];
    
    if (self.parentColumn.topArticleNum == 0) {
//        UIView *headerView = [[UIView alloc] init];
//        headerView.frame = self.columnScrollView.frame;
        self.listTableView.tableHeaderView = self.columnScrollView;
        
    }else {
        NSDictionary * configDic = [NSDictionary dictionaryWithContentsOfFile:pathForMainBundleResource(@"headerScroll_config.plist")];
        
        self.headerView = [[HeaderNewsWidget alloc] initWithConfigDic:configDic withIsLife:1 IsHideColumnReadCount:[self.parentColumn.keyword[@"hideReadCount"] boolValue]];
        self.headerView.delegate = self;
        self.headerView.headerArticles = self.arrayForHeadView;
        self.headerView.column = self.parentColumn;
        [self.headerView loadData];
        self.columnScrollView.y = self.headerView.frame.size.height-self.columnScrollView.height;
        [self.headerView addSubview:self.columnScrollView];
        
        self.listTableView.tableHeaderView = self.headerView;
    }
//    self.columnScrollView = [[ColumnScrollView alloc] initWithFrame:CGRectMake(0, self.headerView.frame.size.height-0.25*kSWidth, kSWidth, kSWidth*0.25) withPageCount:ceil((double)self.lifeColumns.count/4)];
//    self.columnScrollView.backgroundColor = [UIColor whiteColor];
//    self.columnScrollView.delegate = self;
//    self.columnScrollView.columns = self.lifeColumns;
//    [self.columnScrollView reloadData];
//    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, kSWidth*0.76+kSWidth*0.25, kSWidth, 1)];
//    lbl.backgroundColor = UIColorFromString(@"221,221,221");
//    lbl.alpha = .3;
//    [self.headerView addSubview:lbl];
//    
//    [self.headerView addSubview:self.columnScrollView];
//    self.listTableView.tableHeaderView = self.headerView;

}

-(void)loadHeaderWidget
{
    //加载头条图片新闻
    Column *column = self.parentColumn;
    if (column.topArticleNum == 0) {
        self.listTableView.tableHeaderView = nil;
        [self addHeaderView];
        
        //无轮播头图的列表广告插入处理
        NSMutableArray *allMutArticles = [NSMutableArray arrayWithArray:self.articles];
        for (int i = 0; i < self.articles.count; i++)
        {
            Article *article = [self.articles objectAtIndex:i];
            if (article.advID != 0 && article.type == 2) {
                [allMutArticles removeObject:article];
            }
        }
        for (int i = 0; i < self.articles.count; i++)
        {
            Article *article = [self.articles objectAtIndex:i];
            if (article.advID != 0 && article.type == 2) {
                [allMutArticles insertObject:article atIndex:article.adOrder-1];
            }
        }
        self.articles = allMutArticles;
        return;
    }
    self.arrayForHeadView = [self headerArticleArray:column];
    
    UIView *headerView = self.listTableView.tableHeaderView;
    
    if (self.arrayForHeadView.count > 0) {
        if ([headerView isKindOfClass:[HeaderNewsWidget class]]) {
            ((HeaderNewsWidget *)headerView).column = [columns objectAtIndex:columnBar.selectedIndex];
            ((HeaderNewsWidget *)headerView).headerArticles = self.arrayForHeadView;
            [((HeaderNewsWidget *)headerView) loadData];
        }else
        {
            [self addHeaderView];
        }
    }
    else{
        self.listTableView.tableHeaderView = nil;
    }
}
-(NSArray *)headerArticleArray:(Column *)column
{
    NSMutableArray *headerMutableArray = [[NSMutableArray alloc] initWithCapacity:column.topArticleNum];
    NSMutableArray *allMutableArray = [[NSMutableArray alloc] initWithArray:self.articles];
    
    
    for (int i = 0; i < articles.count; i++) {
        Article *article = [articles objectAtIndex:i];
        // 去除无效广告稿件
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
        [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
        
        NSDate *dataStart = [formatter dateFromString:article.startTime];
        NSTimeInterval timeStart = [dataStart timeIntervalSince1970];
        
        NSDate *dataEnd = [formatter dateFromString:article.endTime];
        NSTimeInterval timeEnd = [dataEnd timeIntervalSince1970];
        
        NSTimeInterval timeNow = [[NSDate date] timeIntervalSince1970];
        if (!(timeStart < timeNow && timeNow < timeEnd) && article.advID != 0) {
            [allMutableArray removeObject:article];
        }
        
        // 正常获取轮播稿件
        if(headerMutableArray.count < column.topArticleNum && article.advID == 0){
            [headerMutableArray addObject:article];
            [allMutableArray removeObject:article];
        }
        else if(headerMutableArray.count >=column.topArticleNum){
            break;
        }
    }
    // 处理插入轮播广告事情
    NSArray *allTopArray = [NSArray arrayWithArray:allMutableArray];
    for (int i = 0; i < allTopArray.count; i++)
    {
        Article *article = [allTopArray objectAtIndex:i];
        if (article.advID != 0 && article.type == 1  && article.adOrder < column.topArticleNum + 1 && article.imgAdvUrl != nil && ![article.imgAdvUrl isEqualToString:@""]) {
            [headerMutableArray insertObject:article atIndex:article.adOrder-1];
            [allMutableArray removeObject:article];
        }
    }
    
    
    // 处理列表广告插入事情
    for (int i = 0; i < articles.count; i++)
    {
        Article *article = [articles objectAtIndex:i];
        if (article.advID != 0 && article.type == 2) {
            [allMutableArray removeObject:article];
        }
    }
    for (int i = 0; i < articles.count; i++)
    {
        Article *article = [articles objectAtIndex:i];
        if (article.advID != 0 && article.type == 2) {
            [allMutableArray insertObject:article atIndex:article.adOrder-1];
        }
    }
    
    self.articles = allMutableArray;
    return headerMutableArray;
}

-(void)reloadTableViewDataSource{
   [self loadArticlesWithColumnId:parentColumn.columnId lastFileId:0 rowNumber:0];
}

- (void)columnScrollView:(ColumnScrollView *)columnScrollView didSelectedButtonAtIndex:(int)index
{
    // 第三方链接
    Column *column = [self.lifeColumns objectAtIndex:index];
    NSString *strurl = column.linkUrl;
    if(![NSString isNilOrEmpty:strurl]){
        
        NJWebPageController * controller = [[NJWebPageController alloc] init];
        Column *one = [[Column alloc] init];
        one.linkUrl = strurl;
        one.columnName = column.columnName;
        controller.parentColumn = one;
        controller.isFromModal = YES;
        // 生活栏目H5的API(如<input type="file" class="ios_only" accept="image/*" capture="camera">)直接调用系统相册摄像imagePickerVC(依赖于NavVC)时，需要持有navgitionVC，否则调用不了imagePickerVC且H5页面所在Nav会崩掉。
        //controller.hidesBottomBarWhenPushed = YES;
        //[self.navigationController pushViewController:controller animated:YES];
                [self presentViewController:[Global controllerToNav:controller] animated:YES completion:nil];
        return;
    }
    // 其他
    else
    {
        column.className = @"NormalPageController";
    }
    
    ColumnBarPageController *pageController = [[NSClassFromString(column.className) alloc] init];
    pageController.parentColumn = column;
    pageController.isNotOneLevelNewsVC = YES;
    pageController.isFromLife = YES;
    pageController.viewControllerType = FDViewControllerForDetailVC;
    pageController.navigationController.navigationBar.hidden = NO;
    [self presentViewController:[Global controllerToNav:pageController] animated:YES completion:nil];
//    [self.navigationController pushViewController:pageController animated:YES];
    
}
@end
