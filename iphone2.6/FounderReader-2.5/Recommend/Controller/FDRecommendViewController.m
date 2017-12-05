//
//  FDRecommendViewController.m
//  FounderReader-2.5
//
//  Created by mac on 2017/7/24.
//
//

#import "FDRecommendViewController.h"
#import "PersonalCenterViewController.h"
#import "AppStartInfo.h"
#import "HttpRequest.h"
#import "FDRefreshHeader.h"
#import "FDRefreshFooter.h"
#import "Global.h"
#import "CacheManager.h"
#import "NewsCellUtil.h"
#import "MoreCell.h"
#import "NewsListConfig.h"
#import "ColumnBarConfig.h"
@interface FDRecommendViewController ()<CDRTranslucentSideBarDelegate,UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong) PersonalCenterViewController * leftController;
@property (nonatomic,strong) CDRTranslucentSideBar * sideBar;
@property (nonatomic,strong) UITableView * listTableView;
@property (nonatomic,strong) NSMutableArray * articles;
@property (nonatomic,strong) HttpRequest * request;
@property (nonatomic,strong) NSString * timesTamp;
@property (nonatomic,strong) NSMutableDictionary * saveIsRedDic;
@end

@implementation FDRecommendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpUI];
    [self setDataSource];
    // 监听重复点击tabbar回到顶部
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotoTableViewTop) name:@"refreshNewsPageController" object:nil];
}
-(void)setUpUI{
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self setupLeftView];
    [self titleLableWithTitle:self.parentColumn.columnName];
    [self leftAndRightButton];
    self.navigationItem.rightBarButtonItem = nil;
    
    
    
}
-(void)setDataSource{
    self.saveIsRedDic = [[NSMutableDictionary alloc] initWithContentsOfFile:[cacheDirPath() stringByAppendingString:kSaveIsReadFileName]];
    if (!self.saveIsRedDic) {
        self.saveIsRedDic = [[NSMutableDictionary alloc] init];
    }
    [self.view addSubview:self.listTableView];
    [self createRefreshHeader];
    [self createRefreshFooter];
}
- (void)createRefreshHeader {
    FDRefreshHeader *header = [FDRefreshHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshHeader)];
    self.listTableView.mj_header = header;
    [header beginRefreshing];
}

- (void)refreshHeader {
    [self loadNewData];
}
- (void)createRefreshFooter {
    FDRefreshFooter *footer = [FDRefreshFooter footerWithRefreshingTarget:self refreshingAction:@selector(refreshFooter)];
    self.listTableView.mj_footer = footer;
}

- (void)refreshFooter {
    [self loadMoreArticles];
}

-(void)loadNewData{
    
        NSString * urlString = [NSString stringWithFormat:@"%@/api/getArticles?sid=%@&cid=%d&lastFileID=0&rowNumber=0&isRec=true&dev=%@&uid=%@",[AppConfig sharedAppConfig].serverIf,[AppConfig sharedAppConfig].sid,self.parentColumn.columnId,[[Global uuid] stringByReplacingOccurrencesOfString:@"-" withString:@""],[Global userId]];
        self.request = [[HttpRequest alloc]initWithURL:[NSURL URLWithString:urlString]];
        __weak typeof(self) weakSelf = self;
        [self.request setCompletionBlock:^(id data) {
            NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            [weakSelf dealDataWith:dict];
            [weakSelf.listTableView reloadData];
            [weakSelf.listTableView.mj_header endRefreshing];
        }];
        [self.request setFailedBlock:^(NSError *error) {
            [weakSelf.listTableView.mj_header endRefreshing];
            if (!weakSelf.articles.count) {
                [weakSelf loadMoreArticles];
            }
        }];
        [self.request startAsynchronous];
}
//MARK: deal DATA
-(void)dealDataWith:(NSDictionary *)dict{
    NSDictionary * bigDict = [dict objectForKey:@"bigList"];
    NSArray * bigArr = [bigDict objectForKey:@"list"];
    NSString * bigList = [NSString stringWithFormat:@"%@",bigArr];
    NSString * timetamp = [NSString stringWithFormat:@"%0.0f",[[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSince1970]];
    if (bigList.length) {
        NSData * data = [NSJSONSerialization dataWithJSONObject:bigArr options:NSJSONWritingPrettyPrinted error:nil];
        NSString * bigList = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        [[CacheManager sharedCacheManager] insertRecommendList:bigList columnId:self.parentColumn.columnId timestamp:timetamp];
    }
    
    NSArray * bigAdArr = [bigDict objectForKey:@"adv"];
    NSDictionary * colDict = [dict objectForKey:@"colList"];
    NSArray * colArr = [colDict objectForKey:@"list"];
    if (bigArr.count || colArr.count) {
        [self.articles removeAllObjects];
        self.timesTamp = timetamp;
        self.listTableView.mj_footer.state =  MJRefreshStateIdle;
    }
    NSArray * colAdArr = [colDict objectForKey:@"adv"];
    NSArray * bigArticals =[Article articlesFromArray:bigArr];
    NSArray * colAdArticles = [Article articlesFromArray:colAdArr];
    NSArray * bigAdArticles = [Article articlesFromArray:bigAdArr];
    NSArray * colArticals = [Article articlesFromArray:colArr];
    NSIndexSet * set = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, colArticals.count)];
    [self.articles insertObjects:colArticals atIndexes:set];
    [self.articles addObjectsFromArray:bigArticals];
    for (NSInteger index = 0; index < colAdArticles.count; index++) {
        Article * adArtical = colAdArticles[index];
        if (adArtical.type != 2) {
            continue;
        }
        if (self.articles.count >= adArtical.adOrder) {
            if (index > 0) {
                [self.articles insertObject:adArtical atIndex:adArtical.adOrder-1];
            }else{
               [self.articles insertObject:adArtical atIndex:adArtical.adOrder];
            }
        }
    }
    for (NSInteger index = 0; index < bigAdArticles.count; index++) {
        Article * adArtical = bigAdArticles[index];
        if (adArtical.type != 2) {
            continue;
        }
        if (self.articles.count >= adArtical.adOrder) {
            if (index > 0) {
                [self.articles insertObject:adArtical atIndex:adArtical.adOrder-1];
            }else{
                [self.articles insertObject:adArtical atIndex:adArtical.adOrder];
            }
        }
    }
    
}
-(void)loadMoreArticles{
    if (self.timesTamp == nil || [self.timesTamp isEqualToString:@""]) {
       self.timesTamp = [NSString stringWithFormat:@"%0.0f",[[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSince1970]];
    }
    NSDictionary * dict = [[CacheManager sharedCacheManager] getRecommendListWithTime:self.timesTamp];
    self.timesTamp = [dict objectForKey:@"timesTamp"];
    NSString * listStr = [dict objectForKey:@"list"];
    NSData * data = [listStr dataUsingEncoding:NSUTF8StringEncoding];
    
    if (!data.length) {
        [self.listTableView.mj_footer endRefreshingWithNoMoreData];
        return;
    }
    [self.listTableView.mj_footer endRefreshing];
    NSArray * colArr = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    NSArray * bigArticals = [Article articlesFromArray:colArr];
    [self.articles addObjectsFromArray:bigArticals];
    [self.listTableView reloadData];
}

//MARK: --UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//    return self.articles.count;
    if (self.articles.count>0) {
        return self.articles.count;
    }
    else{
        return 0;
    }
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TableViewCell *cell = nil;
    if (0 == self.articles.count) {
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"zeroCell"];
        if (!cell){
            cell = [[TableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"zeroCell"];
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

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == [self.articles count]){
        
        return  [NewsListConfig sharedListConfig].moreCellHeight;
    }
    
    Article *article = nil;
    if (self.articles.count > indexPath.row) {
        article = [self.articles objectAtIndex:indexPath.row];
    }
    
    return [NewsCellUtil getNewsCellHeight:article];
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == [self.articles count]) {
        return;
    }
    else{
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
#pragma mark - UI

- (void)setupLeftView {
    UIPanGestureRecognizer *panGestureRecognizer = nil;
    if (self.viewControllerType == FDViewControllerForTabbarVC) {
        _leftController = [[PersonalCenterViewController alloc] init];
        self.leftController.view.frame = CGRectMake(0, 0, 240, self.view.bounds.size.height+kNavBarHeight);
        
        self.sideBar = [[CDRTranslucentSideBar alloc] init];
        self.sideBar.sideBarWidth = self.view.bounds.size.width * 0.5;
        self.sideBar.view.frame = CGRectMake(0, 0,self.view.bounds.size.width * 0.5, self.view.bounds.size.height);
        [self.sideBar setContentViewInSideBar:self.leftController.view];
        self.sideBar.delegate = self;
        self.leftController.sideBar = self.sideBar;
        panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        if (![AppStartInfo sharedAppStartInfo].ucTabisShow && self.viewControllerType == FDViewControllerForTabbarVC) {
            [self.view addGestureRecognizer:panGestureRecognizer];
        }
    }
}
- (void)handlePanGesture:(UIPanGestureRecognizer *)recognizer {
    
    // if you have left and right sidebar, you can control the pan gesture by start point.
    CGPoint translatedPoint = [recognizer translationInView:self.view];
    if (translatedPoint.x > 0){
        if (recognizer.state == UIGestureRecognizerStateBegan) {
            CGPoint startPoint = [recognizer locationInView:self.view];
            if (startPoint.x < kSWidth/3.0)
            {
                self.sideBar.isCurrentPanGestureTarget = YES;
            }
        }
        
        [self.sideBar handlePanGestureToShow:recognizer inView:self.view];
    }
}
-(void)left{
    [self.sideBar show];
}
-(void)viewWillAppear:(BOOL)animated{
    if (self.viewControllerType == FDViewControllerForCloumnVC) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        [self.navigationController.navigationBar setTranslucent:YES];
        self.edgesForExtendedLayout = UIRectEdgeTop;
    }else{
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
    NSInteger onlyOne = [[[NSUserDefaults standardUserDefaults] objectForKey:@"onlyOne"] integerValue];
    if (onlyOne == 2 && ![AppStartInfo sharedAppStartInfo].ucTabisShow) {
        [self.tabBarController.tabBar setHidden:YES];
    }else{
        [self.tabBarController.tabBar setHidden:NO];
    }
    
}
//MARK: set & get
-(NSMutableArray *)articles{
    if (_articles == nil) {
        _articles = [[NSMutableArray alloc] init];
    }
    return _articles;
}
-(UITableView *)listTableView{
    if (_listTableView == nil) {
        
        _listTableView = [[UITableView alloc] init];
        _listTableView.delegate = self;
        _listTableView.dataSource = self;
        _listTableView.tableFooterView = [[UIView alloc] init];
        _listTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        switch (self.viewControllerType) {
            case FDViewControllerForTabbarVC:
            {
                _listTableView.frame = CGRectMake(0, 0, kSWidth, kSHeight-kNavBarHeight-kTabBarHeight);
            }
                break;
            case FDViewControllerForCloumnVC:
            {
                NSInteger onlyOne = [[[NSUserDefaults standardUserDefaults] objectForKey:@"onlyOne"] integerValue];
                if (onlyOne == 2 && ![AppStartInfo sharedAppStartInfo].ucTabisShow) {
                 _listTableView.frame = CGRectMake(0, 0, kSWidth, kSHeight-kNavBarHeight-[ColumnBarConfig sharedColumnBarConfig].columnHeaderHeight);
                }else{
                 _listTableView.frame = CGRectMake(0, 0, kSWidth, kSHeight-kNavBarHeight-kTabBarHeight-[ColumnBarConfig sharedColumnBarConfig].columnHeaderHeight);
                }
            }
            break;
            default:
                break;
        }
    }
    return _listTableView;
}
/**
 *  回到tableview顶部
 */
- (void)gotoTableViewTop
{
    
    [self.listTableView setContentOffset:CGPointMake(0, 0) animated:YES];
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
