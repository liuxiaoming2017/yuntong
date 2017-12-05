
//  ColumnBarPageController.m
//  FounderReader-2.5
//
//  Created by chenfei on 4/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import "ColumnBarPageController.h"
#import "Column.h"
#import "ColumnBarConfig.h"
#import "ArticleRequest.h"
#import "DataLib/DataLib.h"
#import "Article.h"
#import "NewsListConfig.h"
#import "CacheManager.h"
#import "NSString+Helper.h"
#import "FMArticlesListTableView.h"
#import "TemplateDetailPageController.h"
#import "DetailPageController.h"
#import "ImageDetailPageController.h"
#import "UIDevice-Reachability.h"
#import <MediaPlayer/MediaPlayer.h>
#import "MiddleCell.h"
#import "SpecialNewsPageController.h"
#import "ColumnRequest.h"
#import "UIView+Extention.h"
#import "AppStartInfo.h"
#import "AdPageController.h"
#import "PeopleDailyPageController.h"
#import "DishViewController.h"
#import "NJSquarePageController.h"
#import "LocalPageController.h"
#import "LifePageController.h"
#import "PoliticalPageController.h"
#import "ColumnBarConfig.h"
#import "XYAVPlayer.h"
#import <UMMobClick/MobClick.h>
#import "TinyMallViewController.h"

@interface ColumnBarPageController ()<UIGestureRecognizerDelegate>
@property (nonatomic, retain) NSMutableArray *array;
@property (nonatomic, retain) NSArray *adArticles;
@property (nonatomic, retain) NSURLRequest *request;
@property (nonatomic, retain) NSURL *url;
@property (nonatomic, retain) NSArray *arrayOnce;

@property (nonatomic, assign) CGPoint scrollViewStartPosPoint;
@property (nonatomic, assign) NSInteger scrollDirection;

// pull refresh
- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;

@end

@implementation ColumnBarPageController

@synthesize articles;
@synthesize adArticles;
@synthesize lastSelectedIndex;
@synthesize scrollViewbg;
@synthesize listTableView;
@synthesize arrayForHeadView;

- (id)init
{
    self = [super init];
    if (self) {
        self.lastSelectedIndex = -1;
        isScrollDrag = NO;
        isFirstLoadArticle = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gotoTableViewTop)];
    [self.navigationController.navigationBar addGestureRecognizer:tapGestureRecognizer];
    
    // 只是第一个一级新闻栏目能有headerLogo标志
    if (self.isFirstNewsVC) {
        self.listTableViewY = [ColumnBarConfig sharedColumnBarConfig].columnBarHeight+kStatusBarHeight;
        self.columnHeaderHeight = [ColumnBarConfig sharedColumnBarConfig].columnHeaderHeight;
    } else {
        self.listTableViewY = [ColumnBarConfig sharedColumnBarConfig].columnBtnHeight+kStatusBarHeight;
        self.columnHeaderHeight = 0;
    }
    
    // 当只有一个菜单时底部标签工具栏不显示
    NSInteger onlyOne = [[[NSUserDefaults standardUserDefaults] objectForKey:@"onlyOne"] integerValue];
    if (onlyOne == 2) self.isNotTabNewsVC = YES;

    
    scrollViewbg = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    scrollViewbg.bounces = YES;
    scrollViewbg.pagingEnabled = YES;
    scrollViewbg.delegate = self;
    scrollViewbg.userInteractionEnabled = YES;
    scrollViewbg.showsHorizontalScrollIndicator = NO;
    scrollViewbg.showsVerticalScrollIndicator = NO;
    
    [self.view addSubview:self.scrollViewbg];
    self.adViewControllers = [[NSMutableSet alloc] init];
    self.lifeControllers = [[NSMutableSet alloc] init];
    self.serverControllers = [[NSMutableSet alloc] init];
    self.politicalControllers = [[NSMutableSet alloc] init];
    recycledPages = [[NSMutableSet alloc] init];
    visiblePages = [[NSMutableSet alloc] init];
    [self listTVPages];
    [_refreshHeaderView refreshLastUpdatedDate];
    
    isRefresh = NO;
    
    columnBar = [[ColumnBar alloc] initWithFrame:CGRectMake(0, kStatusBarHeight+self.columnHeaderHeight, kSWidth, [ColumnBarConfig sharedColumnBarConfig].columnBtnHeight) withIsFirstNewsVC:self.isFirstNewsVC ViewControllerType:self.viewControllerType];
    
    [self loadColumns];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateForBUPOColumns) name:@"updateForBUPOColumns" object:nil];
    // 监听重复点击tabbar回到顶部
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotoTableViewTop) name:@"refreshNewsPageController" object:nil];
    
}

#pragma mark - load articles 加载文章数据

- (void)loadArticlesWithColumnId:(int)columnId lastFileId:(int)lastFileId rowNumber:(int)rowNumber
{
    columnBar.enabled = NO;
    _reloading = YES;
    ArticleRequest *request = [ArticleRequest articleRequestWithColumnId:columnId lastFileId:lastFileId count:[NewsListConfig sharedListConfig].count rowNumber:rowNumber];
    [request setCompletionBlock:^(NSArray *array) {
        CacheManager *manager = [CacheManager sharedCacheManager];
        hasMore = [manager hasMore:columnId rowNumber:rowNumber];
        self.articles = array;
        
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

- (void)loadArticlesFinished
{
    //加载音频文件到播放列表
    [[XYAVPlayer shareInstance] addPlayList:self.articles];
    _reloading = NO;
    _success = YES;
    isFirstLoadArticle = NO;
    [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:0.01];
    columnBar.enabled = YES;
    _searchView.alpha = 0.0;
    
}

- (void)loadArticlesFailed
{
    _reloading = NO;
    columnBar.hidden = NO;
    [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:0.01];
    columnBar.enabled = YES;
}

#pragma mark - load more articles

// 更多的时候也要加
- (void)loadMoreArticlesWithColumnId:(int)columnId lastFileId:(int)lastFileId rowNumber:(int)rowNumber
{
    _reloading = YES;
    
    ArticleRequest *request = [ArticleRequest articleRequestWithColumnId:columnId lastFileId:lastFileId count:[NewsListConfig sharedListConfig].count rowNumber:rowNumber];
    [request setCompletionBlock:^(NSArray *array) {
        CacheManager *manager = [CacheManager sharedCacheManager];
        hasMore = [manager hasMore:columnId rowNumber:rowNumber];
        NSMutableArray *tmpArray = [NSMutableArray arrayWithArray:self.articles];
        [tmpArray addObjectsFromArray:array];
        self.articles = tmpArray;
        
        [self loadMoreArticlesFinished];
        
    }];
    [request setFailedBlock:^(NSError *error) {
        XYLog(@"load articles failed: %@", error);
        [self loadMoreArticlesFailed];
        [Global showTipNoNetWork];
    }];
    [request startAsynchronous];
}

- (void)loadMoreHotArticlesWithColumnId:(int)siteID lastFileId:(int)lastFileId rowNumber:(int)rowNumber type:(int)type columnId:(int)columnId
{
    _reloading = YES;
    
    ArticleRequest *request = [ArticleRequest articleHotRequestWithColumnId:siteID lastFileId:lastFileId rowNumber:rowNumber type:type columnId:columnId];
    [request setCompletionBlock:^(NSArray *array) {
        CacheManager *manager = [CacheManager sharedCacheManager];
        hasMore = [manager hasMore:columnId rowNumber:rowNumber];
        NSMutableArray *tmpArray = [NSMutableArray arrayWithArray:self.articles];
        [tmpArray addObjectsFromArray:array];
        self.articles = tmpArray;
        [self loadMoreArticlesFinished];
        
    }];
    [request setFailedBlock:^(NSError *error) {
        XYLog(@"load articles failed: %@", error);
        [self loadMoreArticlesFailed];
        [Global showTipNoNetWork];
    }];
    [request startAsynchronous];
}

- (void)loadMoreArticlesFinished
{
    _reloading = NO;
    [self.listTableView reloadData];
    //加载音频文件到播放列表
    [[XYAVPlayer shareInstance] addPlayList:self.articles];
}

- (void)loadMoreArticlesFailed
{
    _reloading = NO;
}

#pragma mark -

- (int)currentColumnIndex
{
    return columnBar.selectedIndex;
}

/**
 *  添加顶部导航栏
 */
- (void)addColumnBar
{
    if (allcolumns.count == 1) {
        [[NSUserDefaults standardUserDefaults] setInteger:2 forKey:[NSString stringWithFormat:@"columnCount%@",self.parentColumn.columnName]];
    }
    else{
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:[NSString stringWithFormat:@"columnCount%@",self.parentColumn.columnName]];
    }
    
    columnBar.columnName = self.parentColumn.columnName;
    columnBar.dataSource = self;
    columnBar.delegate = self;
    [columnBar reloadData:self.parentColumn];
}

/**
 * 订阅新闻栏目
 *     原则：第一次默认显示发布库默认所有栏目和顺序，用户订阅后一直显示用户订阅的栏目和顺序，直到发布库栏目增删改，显示发布库新默认所有栏目和顺序
 */
#pragma mark - 点击右侧+号按钮
- (void)moreClick
{
    if (allcolumns.count <= 3) {
        return;
    }
    
    if (!columns.count) {
        return;
    }
    if (columnBar.selectedIndex >= columns.count) {
        columnBar.selectedIndex = 0;
    }
   
    Column *column = [columns objectAtIndex:columnBar.selectedIndex];
    UIView *moreView = [appDelegate().window viewWithTag:333];
    if (!moreView) {
        BUPOViewController *controller = [[BUPOViewController alloc] init];
        controller.currentName = column.columnName;
        [controller initWithColumns:self.allcolumns parentcolumnid:parentColumn.columnId];
        controller.delegate = self;
        controller.view.tag = 333;
        moreView = controller.view;
        moreView.frame = CGRectMake(0, 0, kSWidth, kSHeight);
    }
    
    moreView.alpha = 0;
    [UIView animateWithDuration:.5 animations:^{
        [appDelegate().window addSubview:moreView];
        moreView.alpha = 1;
        [appDelegate().window insertSubview:moreView belowSubview:columnBar];
        self.moreButton.layer.transform = CATransform3DMakeRotation(M_PI_2, 0.0f, 0.0f, 1.0f);
    }];
   
}

- (void)updateForBUPOColumns
{
    [self updateColumns];
    [columnBar reloadData:self.parentColumn];
}
/**
 *  加载栏目结束
 */
- (void)loadColumnsFinished
{
  
    [self initTableViewFrame];
    if ([self isMemberOfClass:NSClassFromString(@"NormalPageController")]) {
        [self columnBar:nil didSelectedTabAtIndex:0];
        return;
    }
    [self addColumnBar];
    [columnBar selectTabAtIndex:columnBar.selectedIndex];
    
    /* 个性化：首页是生活/服务时，加载不了对应的类 */
    if ([columns count]) {
        Column *firstColumn = (Column *)columns[0];
        if ([firstColumn.columnStyle isEqualToString:@"生活"]){
            [self listTVPages];
        }
        if ([firstColumn.columnStyle isEqualToString:@"服务"]){
            [self listTVPages];
        }
    }
    
    [visiblePages removeAllObjects];
    [recycledPages removeAllObjects];
}

- (void)loadColumnsFailed
{
    
}

#pragma mark -

-(void)isShowLeft:(BOOL)show
{
    
}

/**
 *  回到tableview顶部
 */
- (void)gotoTableViewTop
{
    
    [self.listTableView setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)stopRefresh
{
    [self.listTableView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
    [_refreshHeaderView setState:EGOOPullRefreshNormal];
    _reloading = NO;
}

#pragma mark - 点击栏目条二级栏目

- (void)columnBar:(ColumnBar *)sender didSelectedTabAtIndex:(int)index
{
    if(index != 0){ //点击非首页栏目，隐藏搜索框
        _searchView.alpha = 0.0;
        [self.listTableView sendSubviewToBack:_searchView];
    }
    if (index == self.lastSelectedIndex && _success == YES){
        //回到顶部
        [self.listTableView setContentOffset:CGPointMake(0, 0) animated:YES];
        return;
    }
    
    self.lastSelectedIndex = index;
    columnBar.selectedIndex = index;
    
    [self stopRefresh];
    
    _success = NO;
    
    if (self.columns.count == 0)
        return;
    
    Column *column = [columns objectAtIndex:index];
    
    [MobClick event:@"function_nav" attributes:@{@"home_custom_column_button_click":column.columnName}];
    [self titleLableWithTitle:column.columnName];
    NSArray *cacheArticles = [ArticleRequest getCacheArticlesWithColumnId:column.columnId rowNumber:0];
    self.articles = cacheArticles;
    CacheManager *manager = [CacheManager sharedCacheManager];
    hasMore = [manager hasMore:column.columnId rowNumber:0];
    [self.listTableView reloadData];
    
    [self loadHeaderWidget];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    column.lastupdatetime = [userDefaults objectForKey:[NSString stringWithFormat:@"%@%d",
                                                        kLastColumn_RefreshTime, column.columnId]];
    
    NSDate *currentdate = [NSDate date];
    NSTimeInterval subdate = [currentdate timeIntervalSinceDate:column.lastupdatetime];
    
    [scrollViewbg scrollRectToVisible:CGRectMake(kSWidth*index,0,kSWidth,kSHeight) animated:NO];
    
    if ((subdate > [ColumnBarConfig sharedColumnBarConfig].columnRefreshInterval)||
        (column.lastupdatetime == nil))
    {
        [self performSelector:@selector(refreshList) withObject:nil afterDelay:0.1];
        [column setLastupdatetime:[NSDate date]];
    }
    else
    {
        [self loadArticlesFinished];
    }
    //统计栏目点击事件
   // [FounderEventRequest columnclickDateAnaly:column.fullColumn];
}

- (void)refreshList
{
    Column *column = [columns objectAtIndex:columnBar.selectedIndex];
    if ([column.columnStyle isEqualToString:@"读报"] ||
        [column.columnStyle isEqualToString:@"外链"] ||
        [column.columnStyle isEqualToString:@"报料"] ||
        [column.columnStyle isEqualToString:@"服务"] ||
        [column.columnStyle isEqualToString:@"本地"] ||
        [column.columnStyle isEqualToString:@"生活"] ||
        [column.columnStyle isEqualToString:@"积分商城"])
    {
        return;
    }
    [self.listTableView setContentOffset:CGPointMake(0, -REFRESH_HEIGHT-kStatusBarHeight) animated:YES];
    [self performSelector:@selector(scrollViewDidEndDragging:willDecelerate:)
               withObject:self.listTableView
               afterDelay:1];
}

#pragma mark - column bar data source

- (int)numberOfTabsInColumnBar:(ColumnBar *)columnBar
{
    return (int)self.columns.count;
}

- (int)parentIdOfTabsInColumnBar
{
    return parentColumn.columnId;
}

- (Column*)ColumnOfTabsInColumnBar:(int)index
{
    Column *column = [columns objectAtIndex:index];
    return column;
}

- (void)UpdateTabsInColumnBar:(NSMutableArray*)msArray
{
    columns = msArray;
}

- (int)IdOfTabsInColumnBar:(int)index
{
    Column *column = [columns objectAtIndex:index];
    return column.columnId;
}

- (Column *)columnBar:(ColumnBar *)columnBar titleForTabAtIndex:(int)index
{
    Column *column = [columns objectAtIndex:index];
    
    return column;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollViewbg == scrollView) {
        if(scrollView.contentOffset.x < 0){
            scrollViewbg.scrollEnabled = NO;
        }
        else{
            
            scrollViewbg.scrollEnabled = YES;
            if ([columns count]) {
                // 因为scrollview上的vc不执行viewwilldisapear，故在此去除键盘
                for (UIViewController *vc in self.childViewControllers) {
                    if ([vc isKindOfClass:[DishViewController class]]) {
                        [vc.view endEditing:YES];
                        break;
                    }
                }
                [self listTVPages];
            }
            isScrollDrag = NO;
        }
    }
    else{
        
        CGFloat yy = scrollView.contentOffset.y;
        if(yy < 0 && yy > -20.0f && self.currentColumnIndex == 0 && isFirstLoadArticle == NO){
            if([AppConfig sharedAppConfig].isHomeAddSearch && self.isMain && [ColumnBarConfig sharedColumnBarConfig].columnHeaderScale < 1.4){
                [_searchView removeFromSuperview];
                [scrollView addSubview:_searchView];
                [scrollView bringSubviewToFront:_searchView];
            }
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.8];
            _searchView.alpha = 1.0;
            [UIView commitAnimations];
        }
        else if(yy > 0){
            
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.8];
            _searchView.alpha = 0.0;
            [UIView commitAnimations];
        }
    }
    
    //测试加 让ScrollView只向一个方向滑动
    if (self.scrollDirection == 0){//we need to determine direction
        if ( fabs(self.scrollViewStartPosPoint.x-scrollView.contentOffset.x)<
            fabs(self.scrollViewStartPosPoint.y-scrollView.contentOffset.y)){
            self.scrollDirection = 1;
        } else {
            self.scrollDirection = 2;
        }
    }
    if (self.scrollDirection == 1) {
        scrollView.contentOffset = CGPointMake(self.scrollViewStartPosPoint.x,scrollView.contentOffset.y);
    } else if (self.scrollDirection == 2){
        scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x,self.scrollViewStartPosPoint.y);
    }
    
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    [self testScrollView:scrollView];
}

- (void)testScrollView:(UIScrollView *)scrollview
{
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    isScrollDrag = YES;
    
    //测试加
    self.scrollViewStartPosPoint = scrollView.contentOffset;
    self.scrollDirection = 0;
    
    return;
}



- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (0 == columnBar.selectedIndex) {
        [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    }else
    {
        if (scrollViewbg != scrollView) {
            
            [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
        }
    }
    if (!decelerate) {
        [self scrollViewDidEndDecelerating:scrollView];
    }
    //测试加
    else{
        self.scrollDirection = 0;
    }
}

#pragma mark - EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{
    //_searchView.alpha = 0.0;
    [self reloadTableViewDataSource];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
{
    return _reloading; // should return if data source model is reloading
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view
{
    return [NSDate date]; // should return date data source was last changed
}


#pragma mark - Data Source Loading / Reloading Methods
// 刷新加载稿件数据
- (void)reloadTableViewDataSource
{
    if (columns == nil || [columns count] == 0) {
        
        [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:0.01];
        return;
    }
    
    Column *column = [columns objectAtIndex:columnBar.selectedIndex];
    
    [self loadArticlesWithColumnId:column.columnId lastFileId:0 rowNumber:0];
    
}

- (void)doneLoadingTableViewData
{
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.listTableView];
    
}


-(void)initTableViewFrame
{
    scrollViewbg.contentSize = CGSizeMake(kSWidth *columns.count, kSHeight);
    self.listTableView.frame = CGRectMake(self.listTableView.frame.origin.x, self.listTableViewY, kSWidth, kSHeight-self.listTableViewY-kTabBarHeight);
    self.listTableView.height = (self.isNotOneLevelNewsVC||self.isNotTabNewsVC) ? self.listTableView.height+kTabBarHeight+kStatusBarHeight: self.listTableView.height+kStatusBarHeight;
}

//当滚动视图停止

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;{
    if (scrollView == scrollViewbg) {
        int currentPage = floor((scrollView.contentOffset.x - scrollView.frame.size.width / 2) /  scrollView.frame.size.width) + 1;
        XYLog(@"curtentpage==%d",currentPage);
        
        for (FMArticlesListTableView *page in visiblePages) {
            if (page.index == currentPage) {
                if ([page isKindOfClass:[FMArticlesListTableView class]]) {
                    self.listTableView = page;
                }
            }
        }
        [self.listTableView sendSubviewToBack:_searchView];
        [columnBar selectTabAtIndex:currentPage];
    }
}

#pragma mark-
#pragma mark-scrollView重用机制-

- (void)listTVPages
{
    // Calculate which pages are visible
    CGRect visibleBounds =scrollViewbg.bounds;
    int firstNeededPageIndex = floorf(CGRectGetMinX(visibleBounds) / CGRectGetWidth(visibleBounds));
    int lastNeededPageIndex  = floorf((CGRectGetMaxX(visibleBounds)-1) / CGRectGetWidth(visibleBounds));
    firstNeededPageIndex = MAX(firstNeededPageIndex, 0);
    lastNeededPageIndex  = (int)MIN(lastNeededPageIndex, columns.count - 1);

    // Recycle no-longer-visible pages
    for (FMArticlesListTableView *page in visiblePages) {
        if (page.index < firstNeededPageIndex || page.index > lastNeededPageIndex) {
            [recycledPages addObject:page];
            [page removeFromSuperview];
            XYLog(@"%zd--removeFromSuperview",page.index);
        }
    }
    [visiblePages minusSet:recycledPages];
    
    // add missing pages
    for (int index = firstNeededPageIndex; index <= lastNeededPageIndex; index++)
    {
        Column * c = self.columns[index];
        if ([c.columnStyle isEqualToString:@"服务分类"] || [c.columnStyle isEqualToString:@"问答+"] ||[c.columnStyle isEqualToString:@"话题+"]||[c.columnStyle isEqualToString:@"推荐"] || [c.columnStyle isEqualToString:@"话题详情"]) {
            [self configurePage:nil forIndex:index];
            continue;
        }
        /* 个性化：首页是生活/服务时，加载不了对应的类 */
        Column *firstColumn = nil;
        if ([columns count]) {
            firstColumn = (Column *)columns[0];
        }
       
        if (![self isDisplayingPageForIndex:index] || (firstColumn && [firstColumn.columnStyle isEqualToString:@"生活"]) || (firstColumn && [firstColumn.columnStyle isEqualToString:@"服务"]))
//      if (![self isDisplayingPageForIndex:index])
        {
            FMArticlesListTableView *page = [self dequeueRecycledPage];
            if (page == nil)
            {
                page = [[FMArticlesListTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
                page.delegate = self;
                page.dataSource = self;
            }
            
            //赋值给tableviewPage
            [self configurePage:page forIndex:index];
            
            if (_refreshHeaderView == nil)
            {
                _refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.scrollViewbg.bounds.size.height-20, self.view.bounds.size.width, self.scrollViewbg.bounds.size.height)];
                _refreshHeaderView.delegate = self;
                
            }
            if (_refreshHeaderView.superview) {
                [_refreshHeaderView removeFromSuperview];
            }
            [page addSubview:_refreshHeaderView];
            
            
            Column *col = [columns objectAtIndex:index];
            if ([col.columnStyle isEqualToString:@"读报"]
                || [col.columnStyle isEqualToString:@"外链"]
                || [col.columnStyle isEqualToString:@"报料"]
                || [col.columnStyle isEqualToString:@"服务"]
                || [col.columnStyle isEqualToString:@"本地"]
                || [col.columnStyle isEqualToString:@"生活"]
                || [col.columnStyle isEqualToString:@"政情"]
                || [col.columnStyle isEqualToString:@"积分商城"]) {
                page.bounces = NO;
                [visiblePages addObject:page];
            }
            else
            {
                page.bounces = YES;
                [scrollViewbg addSubview:page];
                [visiblePages addObject:page];
            }
        }
    }
}

- (FMArticlesListTableView *)dequeueRecycledPage
{
    //anyObject随机返回一个元素；复用池随机返回一个元素，并从复用池删掉它
    FMArticlesListTableView *page = [recycledPages anyObject];
    if (page)
    {
        [recycledPages removeObject:page];
    }
    return page;
}

- (BOOL)isDisplayingPageForIndex:(NSUInteger)index
{
    BOOL foundPage = NO;
    for (FMArticlesListTableView *page in visiblePages) {
        
        if (page.index == index) {
            foundPage = YES;
            break;
        }
    }
    return foundPage;
}
//MARK:=============configurePage
- (void)configurePage:(FMArticlesListTableView *)page forIndex:(NSUInteger)index
{
    page.index = index;
    self.listTableView = page;
    // 添加搜索框，之前再newspagecontroller的viewdidload添加，但网络不好情况下self.listTableView为nil
    [self addHomeSearchView];
    
    self.lastSelectedIndex = (int)index;
    if (isScrollDrag) {
        columnBar.selectedIndex = (int)index;
    }
    
    _success = NO;
    
    Column *column = [columns objectAtIndex:index];
    
    NSArray *cacheArticles = [ArticleRequest getCacheArticlesWithColumnId:column.columnId rowNumber:0];
    
    CGFloat pageHeight = (self.isNotOneLevelNewsVC||self.isNotTabNewsVC) ? kSHeight-self.listTableViewY+kStatusBarHeight : kSHeight-self.listTableViewY+kStatusBarHeight-kTabBarHeight;
    // 数字报栏目
    if ([column.columnStyle isEqualToString:@"读报"]) {
        cacheArticles = nil;
        self.listTableView.tableHeaderView = nil;
        if (_pdfViewControlle == nil)
        {
            _pdfViewControlle = [[PeopleDailyPageController alloc] initWithColumn:column withIsMain:1];
            _pdfViewControlle.view.frame = CGRectMake(kSWidth*index, self.listTableViewY, kSWidth, pageHeight);
            [scrollViewbg addSubview:_pdfViewControlle.view];
            [self addChildViewController:_pdfViewControlle];
        }
    }
    // 外链栏目
    else if ([column.columnStyle isEqualToString:@"外链"]) {
        BOOL isYouZan = [column.keyword[@"isYouZan"] boolValue];
        if (isYouZan && !self.mallVC) {
            self.mallVC = [[TinyMallViewController alloc] initWithColumn:column viewControllerType:FDViewControllerForCloumnVC];
            self.mallVC.mallTitle = column.columnName;
            self.mallVC.view.frame = CGRectMake(kSWidth*index, self.listTableViewY, kSWidth, pageHeight);
            [scrollViewbg addSubview:self.mallVC.view];
            [self addChildViewController:self.mallVC];
           
        }else{
            cacheArticles = nil;
            self.listTableView.tableHeaderView = nil;
            [self loadArticlesFinished];
            
            BOOL hasControllerCreated = NO;
            AdPageController *curViewController = nil;
            for(AdPageController *controller in self.adViewControllers){
                if(controller.adColumn.columnId == column.columnId){
                    hasControllerCreated = YES;
                    curViewController = controller;
                    break;
                }
            }
            if (!hasControllerCreated)
            {
                AdPageController *__viewController = [[AdPageController alloc] initWithColumn:column];
                __viewController.isMain = 1;
                __viewController.view.frame = CGRectMake(kSWidth*(index), self.listTableViewY, kSWidth, pageHeight);
                [scrollViewbg addSubview:__viewController.view];
                [self addChildViewController:__viewController];
                [self.adViewControllers addObject:__viewController];
            }
            else{
                [curViewController.view removeFromSuperview];
                curViewController.view.frame = CGRectMake(kSWidth*(index), self.listTableViewY, kSWidth, pageHeight);
                [scrollViewbg addSubview:curViewController.view];
            }
        }
       
    }
    // 积分商城栏目
    else if ([column.columnStyle isEqualToString:@"积分商城"]) {
        cacheArticles = nil;
        self.listTableView.tableHeaderView = nil;
        [self loadArticlesFinished];
        if (_creditWebController == nil) {
            _creditWebController = [[CreditMenuViewController alloc] init];
            _creditWebController.viewControllerType = FDViewControllerForCloumnVC;
            _creditWebController.view.frame = CGRectMake(kSWidth*(index), self.listTableViewY, kSWidth, pageHeight);
            [scrollViewbg addSubview:_creditWebController.view];
            [self addChildViewController:_creditWebController];
        }
    }
    // 报料栏目
    else if ([column.columnStyle isEqualToString:@"报料"]) {
        cacheArticles = nil;
        self.listTableView.tableHeaderView = nil;
        if(_dishViewController == nil){
            _dishViewController = [[DishViewController alloc] initWithColumn:column withIsMain:1];
            _dishViewController.view.frame = CGRectMake(kSWidth*index, self.listTableViewY, kSWidth, pageHeight);
            [scrollViewbg addSubview:_dishViewController.view];
            [self addChildViewController:_dishViewController];
            // 由于报料视图frame值会变化，因此需要记住偏移量
            [[NSUserDefaults standardUserDefaults] setFloat:kSWidth*index forKey:@"dishoffy"];
        }
    }
    // 服务栏目
    else if([column.columnStyle isEqualToString:@"服务"])
    {
        cacheArticles = nil;
        self.listTableView.tableHeaderView = nil;
        BOOL hasControllerCreated = NO;
        NJSquarePageController *curViewController = nil;
        for(NJSquarePageController *controller in self.serverControllers){
            if(controller.parentColumn.columnId == column.columnId){
                hasControllerCreated = YES;
                curViewController = controller;
                break;
            }
        }
        if (!hasControllerCreated)
        {
            NJSquarePageController *__viewController = [[NJSquarePageController alloc] initWithColumn:column withIsMain:1];
            __viewController.viewControllerType = FDViewControllerForCloumnVC;
            __viewController.view.frame = CGRectMake(kSWidth*(index), self.listTableViewY, kSWidth, pageHeight);
            [scrollViewbg addSubview:__viewController.view];
            [self addChildViewController:__viewController];
            [self.serverControllers addObject:__viewController];
        }
        else{
            [curViewController.view removeFromSuperview];
            curViewController.view.frame = CGRectMake(kSWidth*(index), self.listTableViewY, kSWidth, pageHeight);
            [scrollViewbg addSubview:curViewController.view];
        }
    }
    // 本地栏目
    else if([column.columnStyle isEqualToString:@"本地"])
    {
        cacheArticles = nil;
        self.listTableView.tableHeaderView = nil;
        if (_localController == nil)
        {
            _localController = [[LocalPageController alloc] initWithColumn:column withIsMain:1];
            _localController.viewControllerType = FDViewControllerForCloumnVC;
            _localController.view.frame = CGRectMake(kSWidth*index, self.listTableViewY, kSWidth, pageHeight);
            [scrollViewbg addSubview:_localController.view];
            [self addChildViewController:_localController];
        }
    }
    // 生活栏目
    else if([column.columnStyle isEqualToString:@"生活"])
    {
        cacheArticles = nil;
        self.listTableView.tableHeaderView = nil;
        BOOL hasControllerCreated = NO;
        LifePageController *curViewController = nil;
        for(LifePageController *controller in self.lifeControllers){
            if(controller.parentColumn.columnId == column.columnId){
                hasControllerCreated = YES;
                curViewController = controller;
                break;
            }
        }
        if (!hasControllerCreated)
        {
            LifePageController *__viewController = [[LifePageController alloc] initWithColumn:column withIsMain:1];
            __viewController.viewControllerType = FDViewControllerForCloumnVC;
            __viewController.view.frame = CGRectMake(kSWidth*(index), 0, kSWidth, pageHeight);
            [scrollViewbg addSubview:__viewController.view];
            __viewController.isMain = YES;
            [self addChildViewController:__viewController];
            [self.lifeControllers addObject:__viewController];
        }
        else{
            [curViewController.view removeFromSuperview];
            curViewController.view.frame = CGRectMake(kSWidth*(index), 0, kSWidth, pageHeight);
            [scrollViewbg addSubview:curViewController.view];
        }
    }
    //政情PoliticalPageController
    else if([column.columnStyle isEqualToString:@"政情"])
    {
        cacheArticles = nil;
        self.listTableView.tableHeaderView = nil;
        BOOL hasControllerCreated = NO;
        PoliticalPageController *curViewController = nil;
        for(PoliticalPageController *controller in self.politicalControllers){
            if(controller.parentColumn.columnId == column.columnId){
                hasControllerCreated = YES;
                curViewController = controller;
                break;
            }
        }
        if (!hasControllerCreated)
        {
            PoliticalPageController *__viewController = [[PoliticalPageController alloc] initWithColumn:column viewControllerType:FDViewControllerForCloumnVC];
            __viewController.isFromColumnBar = YES;//先走viewdidload才走这里，所以viewdidload里isFromColumnBar还是no
            __viewController.view.frame = CGRectMake(kSWidth*index, self.listTableViewY, kSWidth, pageHeight);
            [scrollViewbg addSubview:__viewController.view];
            
            [self addChildViewController:__viewController];
            [self.politicalControllers addObject:__viewController];
        }
        else{
            [curViewController.view removeFromSuperview];
            curViewController.view.frame = CGRectMake(kSWidth*index, self.listTableViewY, kSWidth, pageHeight);
            [scrollViewbg addSubview:curViewController.view];
        }
    } else if ([column.columnStyle isEqualToString:@"问答+"]) {
        cacheArticles = nil;
        self.listTableView.tableHeaderView = nil;
        if (_interactionPlusViewController == nil) {
            _interactionPlusViewController = [[FDInteractionPlusViewController alloc] initWithColumn:column viewControllerType:FDViewControllerForCloumnVC];
            [scrollViewbg addSubview:_interactionPlusViewController.view];
            _interactionPlusViewController.view.frame = CGRectMake(kSWidth*index, self.listTableViewY, kSWidth, pageHeight);
            [self addChildViewController:_interactionPlusViewController];
        }
    }else if ([column.columnStyle isEqualToString:@"话题+"]) {
        cacheArticles = nil;
        self.listTableView.tableHeaderView = nil;
        if (_topicListViewController == nil) {
            _topicListViewController = [[FDTopicListViewController alloc] initWithColumn:column viewControllerType:FDViewControllerForCloumnVC];
            [scrollViewbg addSubview:_topicListViewController.view];
            _topicListViewController.view.frame = CGRectMake(kSWidth*index, self.listTableViewY, kSWidth, pageHeight);
            [self addChildViewController:_topicListViewController];
        }
    }else if ([column.columnStyle isEqualToString:@"服务分类"]){
        cacheArticles = nil;
        self.listTableView.tableHeaderView = nil;
        if (self.serviceSort == nil) {
            self.serviceSort = [[FDServiceSortController alloc]init];
            self.serviceSort.viewControllerType = FDViewControllerForCloumnVC;
            self.serviceSort.parentColumn = column;
            self.serviceSort.view.frame = CGRectMake(kSWidth*index, self.listTableViewY, kSWidth, pageHeight);
            [scrollViewbg addSubview:self.serviceSort.view];
            [self addChildViewController:self.serviceSort];
        }

    }else if([column.columnStyle isEqualToString:@"推荐"]){
        if (self.recommendVC == nil) {
            self.recommendVC = [[FDRecommendViewController alloc]initWithColumn:column viewControllerType:FDViewControllerForCloumnVC];
            self.recommendVC.view.frame = CGRectMake(kSWidth * index, self.listTableViewY, kSWidth, pageHeight);
            [scrollViewbg addSubview:self.recommendVC.view];
            [self addChildViewController:self.recommendVC];
        }
    }else if ([column.columnStyle isEqualToString:@"话题详情"]) {
        cacheArticles = nil;
        self.listTableView.tableHeaderView = nil;
        NSNumber *topicID = column.keyword[@"topicDetailID"] ? column.keyword[@"topicDetailID"] : 0;
        if (_topicDetailViewController == nil) {
            _topicDetailViewController = [[FDTopicPlusDetailViewController alloc] initWithTopicID:topicID viewControllerType:FDViewControllerForCloumnVC];
            [scrollViewbg addSubview:_topicDetailViewController.view];
            _topicDetailViewController.view.frame = CGRectMake(kSWidth*index, self.listTableViewY, kSWidth, pageHeight);
            [self addChildViewController:_topicDetailViewController];
        }
    }
    
    CacheManager *manager = [CacheManager sharedCacheManager];
    hasMore = [manager hasMore:column.columnId rowNumber:0];
    self.articles = cacheArticles;
    [self loadHeaderWidget];
    if (self.viewControllerType == FDViewControllerForDetailVC && [self.parentColumn.columnStyle isEqualToString:@"新闻"] && self.parentColumn.hasSubColumn) {
        scrollViewbg.frame = CGRectMake(0, self.listTableViewY, kSWidth,kSHeight-self.listTableViewY);
        scrollViewbg.contentSize = CGSizeMake(kSWidth *columns.count, kSHeight-self.listTableViewY);
        page.frame = CGRectMake(scrollViewbg.frame.size.width*index, 0, kSWidth,kSHeight-self.listTableViewY);
        page.height = page.height+kStatusBarHeight;
    }else{
        page.frame = CGRectMake(scrollViewbg.frame.size.width*index, self.listTableViewY, kSWidth,kSHeight-self.listTableViewY-kNavBarHeight);
        page.height = (self.isNotOneLevelNewsVC||self.isNotTabNewsVC) ? page.height+kTabBarHeight+kStatusBarHeight : page.height+kStatusBarHeight;
    }
    [page reloadData];
}


- (void)refreshcolumnbar:(int) columnID{
    columnBar.selectedIndex = columnID;
    [self updateColumns];
    scrollViewbg.contentSize = CGSizeMake(kSWidth *columns.count, kSHeight);
    [columnBar reloadData:self.parentColumn];
    [columnBar selectTabAtIndex:columnBar.selectedIndex];
}

- (void)refreshcolumnbarNoMoreColumn:(int) columnID
{
    columnBar.selectedIndex = columnID;
    [self updateColumns];
    [columnBar reloadData:self.parentColumn];
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

}

-(NSArray *)headerArticleArray:(Column *)column
{
    NSMutableArray *headerMutableArray = [[NSMutableArray alloc] initWithCapacity:column.topArticleNum];
    NSMutableArray *allMutableArray = [[NSMutableArray alloc] initWithArray:self.articles];
    self.adCount = 0;
    
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
        
        // 得到列表广告的个数
        if (article.advID != 0 && article.type == 2) {
            self.adCount += 1;
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
        if (article.advID != 0 && article.type == 1) {
            if(article.adOrder > headerMutableArray.count)
                [headerMutableArray addObject:article];
            else
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

-(void)loadHeaderWidget
{
    //加载头条图片新闻
    Column *column = nil;
    if (columns.count > columnBar.selectedIndex) {
        column = [columns objectAtIndex:columnBar.selectedIndex];
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


#pragma mark - head news delegate

- (void)headerNewsWidget:(HeaderNewsWidget *)view didSelectAtIndex:(int)index
{
    HeaderNewsWidget *headerView = (HeaderNewsWidget *) self.listTableView.tableHeaderView;
    if ([headerView isKindOfClass:[HeaderNewsWidget class]]) {
        Article *article = [headerView.headerArticles objectAtIndex:index];
        
        [self showHeaderTopDetailArticle:article withColumn:parentColumn];
    }
    
}

#pragma mark - localPosition


-(void)positionCitySelected:(Column*)selectedColum
{
    selectedColum.columnStyle = @"地方";
    [self.columns replaceObjectAtIndex:columnBar.selectedIndex withObject:selectedColum];
    [[NSUserDefaults standardUserDefaults] setObject:selectedColum.columnName forKey:kpositionCityCustomerColumnName];
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d",selectedColum.columnId] forKey:kpositionCityCustomerColumnId];
    [[NSUserDefaults standardUserDefaults] setObject:selectedColum.iconUrl forKey:kpositionCityCustomerColumnImageUrl];
    
    [self loadArticlesWithColumnId:selectedColum.columnId lastFileId:0 rowNumber:0];
    
}

#pragma mark - webviewdelegate
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}


- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

-(void)goPrePage
{
    if ([(UIWebView*)self.view canGoBack])
    {
        [(UIWebView*)self.view  goBack];
    }
}

-(void)goNextPage
{
    if ([(UIWebView*)self.view  canGoForward])
    {
        [(UIWebView*)self.view  goForward];
    }
}
-(void)webViewDidFinishLoad:(UIWebView *)webView1
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    return nil;
}

- (void)addHomeSearchView
{
    
}

@end
