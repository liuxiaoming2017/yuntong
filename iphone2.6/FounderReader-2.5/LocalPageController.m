//
//  NewsPageController.m
//  FounderReader-2.5
//
//  Created by chenfei on 4/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LocalPageController.h"
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
#import "ColumnBarConfig.h"
#import "ArticleRequest.h"
#import "CityPageController.h"
#import "ColumnRequest.h"
#import "NewsCellUtil.h"
#import "ColorStyleConfig.h"

@interface LocalPageController () <HeaderNewsWidgetDelegate, CDRTranslucentSideBarDelegate>
{
    UIView *_columnLabel;
    UIView *_headWhiteLable;
}
@property (nonatomic, retain) NSMutableArray *array;
@property (nonatomic, retain) NSMutableDictionary *saveIsRedDic;
@property (nonatomic, retain) NSArray *groupImageConfigs;
@property (nonatomic, retain) NSArray *subColumns;
@property (nonatomic, retain) NSMutableArray *localColumns;
@end

@implementation LocalPageController
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    _array = [[NSMutableArray alloc] init];
    self.localColumns = [[NSMutableArray alloc] init];
    [self loadLocalColumns];
    
    _headWhiteLable = [[UIView alloc] initWithFrame:CGRectMake(0,0 ,[UIScreen mainScreen].bounds.size.width, 64)];
    _headWhiteLable.backgroundColor = [UIColor clearColor];
    _headWhiteLable.alpha = 1;
    [self.view addSubview:_headWhiteLable];
    
    //已经读过的稿件
    saveIsRedDic = [[NSMutableDictionary alloc] initWithContentsOfFile:[cacheDirPath() stringByAppendingString:kSaveIsReadFileName]];
    if (!self.saveIsRedDic) {
        saveIsRedDic = [[NSMutableDictionary alloc] init];
    }
    self.listTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    if (self.isMain) {
        
    }
    else
    {
        leftController = [[PersonalCenterViewController alloc] init];
        self.leftController.view.frame = CGRectMake(0, 0, 240, self.view.bounds.size.height+64);
        
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
    }
    if (self.viewControllerType == FDViewControllerForCloumnVC) {
        self.listTableView.frame = CGRectMake(0, 0, kSWidth, kSHeight-[ColumnBarConfig sharedColumnBarConfig].columnHeaderHeight - [ColumnBarConfig sharedColumnBarConfig].columnBarHeight -kTabBarHeight-kStatusBarHeight);
    }else{
       [self configWebViewToolBar];
    }
    [self loadArticlesWithColumnId:parentColumn.columnId lastFileId:0 rowNumber:0];
}

-(void)configWebViewToolBar
{
    UIView *toolBarView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kSWidth, 64)];
    toolBarView.backgroundColor=[UIColor colorWithPatternImage:[Global navigationImage]];
    toolBarView.userInteractionEnabled = YES;
    [self.view addSubview:toolBarView];
    
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 20, kSWidth-80, 44)];
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
    }
}
#pragma mark - load columns
- (void)loadColumns
{
    
}

- (void)loadLocalColumns
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
        self.localColumns = [[NSMutableArray alloc] initWithArray:arrayLast];
        [self.array addObject:parentColumn];
        [self.array addObjectsFromArray:self.localColumns];
    }];
    
    [request setFailedBlock:^(NSError *error) {
        XYLog(@"load Columns failed: %@", error);
        [self loadColumnsFailed];
        
    }];
    [request startSynchronous];
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
//        self.sideBar.isCurrentPanGestureTarget = YES;
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
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self.listTableView reloadData];
    [self.tabBarController.tabBar setHidden:NO];
    
    [self.navigationController.navigationBar setTranslucent:NO];
    self.edgesForExtendedLayout = UIRectEdgeTop;
    
    NSInteger onlyOne = [[[NSUserDefaults standardUserDefaults] objectForKey:@"onlyOne"] integerValue];
    if (onlyOne == 2 && ![AppStartInfo sharedAppStartInfo].ucTabisShow)
    {
        [self.tabBarController.tabBar setHidden:YES];
    }
    else
    {
        [self.tabBarController.tabBar setHidden:NO];
    }
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
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
    else if (indexPath.row == articles.count){
        cell = [tableView dequeueReusableCellWithIdentifier:@"MoreCell"];
        if (!cell){
            cell = [[MoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MoreCell"];
            cell.tag = 200;
            [cell configWithTitle:@"" summary:@"" date:@"" thumbnailUrl:@"" columnId:0];
        }
    }
    else{
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
        Column *column = [columns objectAtIndex:columnBar.selectedIndex];
        [NewsCellUtil clickNewsCell:currentAricle column:column in:self];
        
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
        
        Article *lastArticle = [self.articles lastObject];
        [self loadMoreArticlesWithColumnId:parentColumn.columnId
                                lastFileId:lastArticle.fileId
                                 rowNumber:(int)[self.articles count]+parentColumn.topArticleNum];
    }
}

- (void)sideBar:(CDRTranslucentSideBar *)sideBar1 willAppear:(BOOL)animated {
    [self.leftController updateUserInfo];
}

-(void)addHeaderView
{
    NSDictionary * configDic = [NSDictionary dictionaryWithContentsOfFile:pathForMainBundleResource(@"headerScroll_config.plist")];
    Column *column = [columns objectAtIndex:columnBar.selectedIndex];
    HeaderNewsWidget *headerView = [[HeaderNewsWidget alloc]initWithConfigDic:configDic IsHideColumnReadCount:[column.keyword[@"hideReadCount"] boolValue]];
    headerView.delegate = self;
    headerView.headerArticles = self.arrayForHeadView;
    headerView.column = column;
    [headerView loadData];

    self.listTableView.tableHeaderView = headerView;
    self.localView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"policeArrea1"]];
    self.localView.userInteractionEnabled = YES;
    self.localView.frame = CGRectMake(kSWidth-70, kSWidth*0.566-30, 60, 20);
    [self.listTableView addSubview:self.localView];
    [self.listTableView bringSubviewToFront:self.localView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pushMoreLocalCity)];
    [self.localView addGestureRecognizer:tap];
}

-(void)loadHeaderWidget
{
    //加载头条图片新闻
    Column *column = nil;
    if (self.localColumns.count > columnBar.selectedIndex) {
        column = [self.localColumns objectAtIndex:columnBar.selectedIndex];
    }
    if (column.topArticleNum == 0) {
        self.listTableView.tableHeaderView = nil;
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
        if(headerMutableArray.count < column.topArticleNum && article.advID == 0)
        {
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
- (void)pushMoreLocalCity
{

    CityPageController *controller = [[CityPageController alloc] init];
    controller.delegate = self;
    controller.columns = self.array;
    [self.navigationController pushViewController:controller animated:YES];

}

- (void)LocationPageController:(int)index
{
    Column *column = [self.array objectAtIndex:index];
    parentColumn = column;
    UILabel *lab = [self.view viewWithTag:222];
    lab.text = parentColumn.columnName;
    [self loadArticlesWithColumnId:parentColumn.columnId lastFileId:0 rowNumber:0];
}
@end
