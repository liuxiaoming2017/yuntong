//
//  FDTopicListViewController.m
//  FounderReader-2.5
//
//  Created by Julian on 2017/4/25.
//
//

#import "FDTopicListViewController.h"
#import "PersonalCenterViewController.h"
#import "ColorStyleConfig.h"
#import "FDRefreshHeader.h"
#import "FDRefreshFooter.h"
#import "ArticleRequest.h"
#import "NewsListConfig.h"
#import "NSMutableAttributedString + Extension.h"
#import "MiddleCell.h"
#import "AESCrypt.h"
#import "YXLoginViewController.h"
#import "NewsCellUtil.h"
#import "FDTopicListCell.h"
#import "Article.h"
#import "UIButton+Block.h"
#import "AppStartInfo.h"
#import "FDTopicPlusDetailViewController.h"
#import "ColumnBarConfig.h"
static NSString *topicListCellIdentifier = @"topicListCellIdentifier";

@interface FDTopicListViewController () <CDRTranslucentSideBarDelegate, UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *articlesArray;

@property (strong, nonatomic) NSNumber *rowNumber;
@property (strong, nonatomic) NSNumber *lastId;

@property (strong, nonatomic) NSMutableDictionary *saveIsReadDic;

@property (assign, nonatomic) BOOL hasMore;

@property (strong, nonatomic) PersonalCenterViewController *leftController;
@property (strong, nonatomic) CDRTranslucentSideBar *sideBar;

@end

@implementation FDTopicListViewController

- (instancetype)initWithColumn:(Column *)column viewControllerType:(FDViewControllerType)viewControllerType
{
    if (self = [super init]) {
        parentColumn = column;
        self.viewControllerType = viewControllerType;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.viewControllerType == FDViewControllerForTabbarVC || self.viewControllerType == FDViewControllerForDetailVC) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }else if (self.viewControllerType == FDViewControllerForCloumnVC){
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
    if (self.viewControllerType == FDViewControllerForDetailVC) {
        [self rightPageNavTopButtons];
        self.tableView.frame = CGRectMake(0, 0, kSWidth, kSHeight);
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self setupLeftView];
    [self setupNavigationBar];
    
    [self setupTableView];
    //接受并处理登录登出的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLogin) name:@"USERDIDLOGIN" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLogout) name:@"USERDIDLOGOUT" object:nil];
    //页面刷新
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTopicArticleByDetail:) name:@"updateTopicArticleByDetail" object:nil];
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
- (void)rightPageNavTopButtons
{
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftButton setImage:[UIImage imageNamed:@"nav_bar_back"] forState:UIControlStateNormal];
    [leftButton sizeToFit];
    leftButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    leftButton.contentEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
    [leftButton addTarget:self action:@selector(goRightPageBack) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    self.navigationItem.rightBarButtonItem = nil;
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

- (void)setupTableView
{
    [self.view addSubview:self.tableView];
    [self createRefreshHeader];
    [self createRefreshFooter];
}

- (void)createRefreshHeader {
    FDRefreshHeader *header = [FDRefreshHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshHeader)];
    self.tableView.mj_header = header;
    [header beginRefreshing];
}

- (void)refreshHeader {
    [self loadData:YES];
}

- (void)createRefreshFooter {
    FDRefreshFooter *footer = [FDRefreshFooter footerWithRefreshingTarget:self refreshingAction:@selector(refreshFooter)];
    self.tableView.mj_footer = footer;
}

- (void)refreshFooter {
    [self loadData:NO];
}

- (void)setupNavigationBar {
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 140, 43)];
    titleLabel.text = self.parentColumn.columnName;
    titleLabel.font = [UIFont systemFontOfSize:18];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [ColorStyleConfig sharedColorStyleConfig].navbar_titlecolor_selected;
    self.navigationItem.titleView = titleLabel;
    
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)loadData:(BOOL)isRefresh {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"duiba-load-WebView" object:nil];
    int rowNumber = 0;
    int lastId = 0;
    if (!isRefresh) {
        rowNumber = (int)self.articlesArray.count;
        Article *article = self.articlesArray.lastObject;
        lastId = article.topicID.intValue;
    }
    ArticleRequest *request = [ArticleRequest articleTopicListRequestWithColumnId:self.parentColumn.columnId LastId:lastId rowNumber:rowNumber];
    __weak __typeof (self)weakSelf = self;
    [request setCompletionBlock:^(NSArray *array) {
        if (isRefresh) {
            weakSelf.articlesArray = nil;
        }
        [weakSelf.articlesArray addObjectsFromArray:array.mutableCopy];
        
        [weakSelf.tableView reloadData];
        
        if (!array.count) {
            if (isRefresh) {
                [weakSelf.tableView.mj_footer endRefreshingWithNoMoreData];
            }
        } else {
            [weakSelf.tableView.mj_footer endRefreshing];
        }
        [weakSelf.tableView.mj_header endRefreshing];
        
    }];
    [request setFailedBlock:^(NSError *error) {
        XYLog(@"load articles failed: %@", error);
        [weakSelf.tableView.mj_header endRefreshing];
        [weakSelf.tableView.mj_footer endRefreshing];
        [Global showTipNoNetWork];
        
    }];
    [request startAsynchronous];
}

#pragma mark - tableView data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Article *topicArticle = self.articlesArray[indexPath.row];
    CGFloat cellHeight = 0;
    if (topicArticle.isBigPic)
        cellHeight = 8*2 + 7+ (kSWidth-15*2)*9/16.0f;
    else
        cellHeight = [NewsListConfig sharedListConfig].middleCellHeight + 7;
    
    if (indexPath.row == 0)
        return cellHeight + 7;
    else
        return cellHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.articlesArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Article *topicArticle = self.articlesArray[indexPath.row];
    NSString *key = [NSString stringWithFormat:@"%lld",topicArticle.topicID.longLongValue];
    topicArticle.isRead = [[self.saveIsReadDic valueForKey:key] boolValue];
    
    FDTopicListCell *cell = [tableView dequeueReusableCellWithIdentifier:topicListCellIdentifier];
    [cell setTopicArticle:topicArticle IsFirstRow:indexPath.row == 0];
    __weak __typeof (self)weakSelf = self;
    [cell.attentionBtn addAction:^(UIButton *btn) {
        [weakSelf attentionClickForIndexPath:indexPath];
    }];
    return cell;
}

#pragma mark - table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Article *article = self.articlesArray[indexPath.row];
    //点击事件
    
    //存储已读信息
    article.isRead = YES;
    NSString *key = [NSString stringWithFormat:@"%lld",article.topicID.longLongValue];
    [self.saveIsReadDic setObject:[NSNumber numberWithBool:YES] forKey:key];
    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    FDTopicPlusDetailViewController *vc = [[FDTopicPlusDetailViewController alloc] initWithTopicID:article.topicID viewControllerType:FDViewControllerForItemVC];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)attentionClickForIndexPath:(NSIndexPath *)indexPath {
    if ([Global userId].length) {
        //已登录
        Article *article = self.articlesArray[indexPath.row];
        NSString *urlString = [NSString stringWithFormat:@"%@/topicApi/topicFollow", [AppConfig sharedAppConfig].serverIf];
        NSURL *url = [NSURL URLWithString:urlString];
        HttpRequest *request = [HttpRequest requestWithURL:url];
        [request setHTTPMethod:@"POST"];
        NSString *sign = [AESCrypt encrypt:[NSString stringWithFormat:@"%@%@%@", [AppConfig sharedAppConfig].sid, [Global userId], article.topicID] password:key];
        NSString *informString = [NSString stringWithFormat:@"sid=%@&topicID=%ld&uid=%@&sign=%@&type=%d", [AppConfig sharedAppConfig].sid, article.topicID.integerValue, [Global userId], sign, !article.isFollow];
        informString = [informString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSData *informData = [informString dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPBody:informData];
        __weak __typeof (self)weakSelf = self;
        [request setCompletionBlock:^(id data) {
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers  error:nil];
            if ([[dic objectForKey:@"success"] boolValue]) {
                NSDictionary *topicConfigDict = [[NSUserDefaults standardUserDefaults] objectForKey:FDTopicConfigsNameKey];
                NSString *alertCancel = [NSString stringWithFormat:@"取消%@成功",[topicConfigDict objectForKey:FDTopicFollowWordKey]];
                NSString *alertSuccess = [NSString stringWithFormat:@"%@成功",[topicConfigDict objectForKey:FDTopicFollowWordKey]];
                NSString *alertStr = article.isFollow ? NSLocalizedString(alertCancel,nil) : NSLocalizedString(alertSuccess,nil);
                [Global showTip:alertStr];
                article.isFollow = !article.isFollow;
                article.interestCount = [dic objectForKey:@"interestCount"];
                if ([article.interestCount isKindOfClass:[NSNull class]]) article.interestCount = @0;
                [weakSelf.tableView reloadData];
            }
        }];
        [request setFailedBlock:^(NSError *error) {
            XYLog(@"load articles failed: %@", error);
            [Global showTip:NSLocalizedString(@"修改失败",nil)];
        }];
        [request startAsynchronous];
    } else {
        //未登陆
        YXLoginViewController *controller = [[YXLoginViewController alloc]init];
        [controller rightPageNavTopButtons];
        [self presentViewController:[Global controllerToNav:controller] animated:YES completion:NULL];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLogin) name:@"duiba-load-WebView" object:nil];
    }
}

- (void)didLogin {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"duiba-load-WebView" object:nil];
    [self loadData:YES];
}

#pragma mark - lazy

- (NSMutableDictionary *)saveIsReadDic {
    if (_saveIsReadDic == nil) {
        _saveIsReadDic = [NSMutableDictionary dictionary];
    }
    return _saveIsReadDic;
}

- (NSMutableArray *)articlesArray {
    if (_articlesArray == nil) {
        _articlesArray = [NSMutableArray array];
    }
    return _articlesArray;
}

- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kSWidth, kSHeight) style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor colorWithRed:237/255.f green:237/255.f blue:237/255.f alpha:1];
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        switch (self.viewControllerType) {
            case FDViewControllerForTabbarVC:
                _tableView.frame = CGRectMake(0, 0, kSWidth, kSHeight - kNavBarHeight - kTabBarHeight);
                //_tableView.contentInset = UIEdgeInsetsMake(kNavBarHeight, 0, 0, kTabBarHeight);
                break;
            case FDViewControllerForCloumnVC:
            {
                NSInteger onlyOne = [[[NSUserDefaults standardUserDefaults] objectForKey:@"onlyOne"] integerValue];
                if (onlyOne == 2 && ![AppStartInfo sharedAppStartInfo].ucTabisShow) {
                    _tableView.frame = CGRectMake(0, 0, kSWidth, kSHeight-kNavBarHeight-[ColumnBarConfig sharedColumnBarConfig].columnHeaderHeight);
                }else{
                    _tableView.frame = CGRectMake(0, 0, kSWidth, kSHeight-kNavBarHeight-kTabBarHeight-[ColumnBarConfig sharedColumnBarConfig].columnHeaderHeight);
                }
            }
                break;
            case FDViewControllerForDetailVC:
                _tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
                break;
            default:
                break;
        }
        _tableView.separatorInset = _tableView.contentInset;
        [_tableView registerClass:[FDTopicListCell class] forCellReuseIdentifier:topicListCellIdentifier];
    }
    return _tableView;
}
-(void)goRightPageBack{
    if (self.viewControllerType == FDViewControllerForDetailVC) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [super goRightPageBack];
    }
}
-(void)left
{
    [self.sideBar show];
    return;
}

- (void)userDidLogin {
    [self loadData:YES];
}

- (void)userDidLogout {
    for (Article *article in self.articlesArray) {
        article.isFollow = NO;
    }
    [self.tableView reloadData];
}

- (void)updateTopicArticleByDetail:(NSNotification *)noti {
    [self loadData:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
