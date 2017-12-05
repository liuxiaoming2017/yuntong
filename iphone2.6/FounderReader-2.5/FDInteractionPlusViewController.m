//
//  FDQuestionAndAnswerListViewController.m
//  FounderReader-2.5
//
//  Created by snitsky on 2016/12/6.
//
//

#import "FDInteractionPlusViewController.h"
#import "MiddleCell.h"
#import "ColumnBarConfig.h"
#import "ArticleRequest.h"
#import "CacheManager.h"
#import "MoreCell.h"
#import "NewsListConfig.h"
#import "NewsCellUtil.h"
#import "UIDevice-Reachability.h"
#import "UIButton+Block.h"
#import "CDRTranslucentSideBar.h"
#import "ColorStyleConfig.h"
#import "FDRefreshHeader.h"
#import "YXLoginViewController.h"
#import "HttpRequest.h"
#import "AESCrypt.h"
#import "FDRefreshFooter.h"
#import "PersonalCenterViewController.h"
#import "CDRTranslucentSideBar.h"
#import "NSMutableAttributedString + Extension.h"
#import "FDQuestionsAndAnwsersPlusDetailModel.h"
#import "FDAskBarCell.h"
#import "FDQuestionsAndAnwsersPlusDetailViewController.h"
#import "AppStartInfo.h"
static NSString *FDAskBarCellId = @"FDAskBarCellId";

@interface FDInteractionPlusViewController () <CDRTranslucentSideBarDelegate, UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *articlesArray;
@property (strong, nonatomic) NSMutableArray *askBarArticlesArray;

@property (strong, nonatomic) NSNumber *rowNumber;
@property (strong, nonatomic) NSNumber *lastId;

@property (strong, nonatomic) NSMutableDictionary *saveIsReadDic;

@property (assign, nonatomic) BOOL hasMore;


@property (strong, nonatomic) PersonalCenterViewController *leftController;
@property (strong, nonatomic) CDRTranslucentSideBar *sideBar;

@end

static NSString *interactionPlusCellIdentifier = @"interactionPlusCellIdentifier";

@implementation FDInteractionPlusViewController

- (instancetype)initWithColumn:(Column *)column viewControllerType:(FDViewControllerType)viewControllerType {
    if (self = [super init]) {
        parentColumn = column;
        self.viewControllerType = viewControllerType;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self setupLeftView];
    [self setupNavigationBar];
    [self.view addSubview:self.tableView];
    [self createRefreshHeader];
    [self createRefreshFooter];
    //接受并处理登录登出的通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                            selector:@selector(userDidLogin)
                                                 name:@"USERDIDLOGIN"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userDidLogout)
                                                 name:@"USERDIDLOGOUT"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateQAAArticleWithNoti:)
                                                 name:@"updateQAAArticleWithNoti"
                                               object:nil];
    if (self.viewControllerType == FDViewControllerForDetailVC) {
        [self rightPageNavTopButtons];
    }
}
-(void)goRightPageBack{
    if (self.viewControllerType == FDViewControllerForDetailVC) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [super goRightPageBack];
    }
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.viewControllerType == FDViewControllerForTabbarVC) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }else if (self.viewControllerType == FDViewControllerForDetailVC) {
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    }else if (self.viewControllerType == FDViewControllerForCloumnVC){
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updateQAAArticleWithNoti:(NSNotification *)noti {
    FDQuestionsAndAnwsersPlusDetailModel *detailModel = noti.object;
    for (Article *model in self.articlesArray) {
        if (model.lastID.integerValue == detailModel.aid.integerValue) {
            model.interestCount = detailModel.interestCount;
            model.isFollow = detailModel.isFollow;
            [self.tableView reloadData];
            break;
        }
    }
}

-(void)left
{
    [self.sideBar show];
    return;
}

- (void)userDidLogout {
    for (Article *article in self.articlesArray) {
        article.isFollow = NO;
    }
    [self.tableView reloadData];
}

- (void)userDidLogin {
    [self loadData:YES];
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
    if (self.askBarArticlesArray.count) {
        [self loadAskBarData:NO];
    }else {
        [self loadData:NO];
    }
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
        lastId = article.lastID.intValue;
    }
    ArticleRequest *request = [ArticleRequest articleInteractionPlusRequestWithColumnId:self.parentColumn.columnId LastId:lastId rowNumber:rowNumber];
    __weak __typeof (self)weakSelf = self;
    [request setCompletionBlock:^(NSArray *array) {
        if (isRefresh) {
            weakSelf.articlesArray = nil;
            weakSelf.askBarArticlesArray = nil;
        }
        [weakSelf.articlesArray addObjectsFromArray:array.mutableCopy];
        
        [weakSelf.tableView reloadData];
        
        if (!array.count) {
            if (isRefresh) {
                [weakSelf.tableView.mj_footer endRefreshingWithNoMoreData];
            }else {
                // 加载有答
                [weakSelf loadAskBarData:YES];
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

- (void)loadAskBarData:(BOOL)isRefresh
{
    int rowNumber = 0;
    int lastId = 0;
    if (!isRefresh) {
        rowNumber = (int)self.askBarArticlesArray.count;
        Article *article = self.askBarArticlesArray.lastObject;
        lastId = article.fileId;
    }
    ArticleRequest *request = [ArticleRequest articleRequestWithColumnId:self.parentColumn.columnId lastFileId:lastId count:[NewsListConfig sharedListConfig].count rowNumber:rowNumber];
    __weak __typeof (self)weakSelf = self;
    [request setCompletionBlock:^(NSArray *array) {
        if (isRefresh) {
            weakSelf.askBarArticlesArray = nil;
        }
        
        [weakSelf.askBarArticlesArray addObjectsFromArray:array.mutableCopy];
        
        if (!array.count) {
            [weakSelf.tableView.mj_footer endRefreshingWithNoMoreData];
        } else {
            [weakSelf.tableView.mj_footer endRefreshing];
        }
        [weakSelf.tableView.mj_header endRefreshing];
        [weakSelf.tableView reloadData];
        
    }];
    [request setFailedBlock:^(NSError *error) {
        XYLog(@"load articles failed: %@", error);
        [weakSelf.tableView.mj_header endRefreshing];
        [weakSelf.tableView.mj_footer endRefreshing];
        [Global showTipNoNetWork];
        
    }];
    [request startAsynchronous];
}

- (void)loadFocusedInteractionList {
    if (![Global userId].length) {
        return;
    }
    NSString *requestString = [NSString stringWithFormat:@"%@/api/getAskBarPlusFollows?sid=%@&rowNumber=0&lastID=0&uid=%@", [AppConfig sharedAppConfig].serverIf, [AppConfig sharedAppConfig].sid, [Global userId]];
    HttpRequest *request = [[HttpRequest alloc] initWithURL:[NSURL URLWithString:requestString]];
    __weak __typeof (self)weakSelf = self;
    [request setCompletionBlock:^(id data) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers  error:nil];
        NSArray *listArray = dict[@"list"];
        for (NSDictionary *articleDict in listArray) {
            NSNumber *aid = articleDict[@"aid"];
            for (NSInteger i = 0; i < weakSelf.articlesArray.count; i++) {
                Article *article = weakSelf.articlesArray[i];
                if (aid.integerValue == article.lastID.integerValue) {
                    article.isFollow = YES;
                }
            }
        }
        [weakSelf.tableView reloadData];
    }];
    [request setFailedBlock:^(NSError *error) {
        
    }];
    [request startAsynchronous];
}

#pragma mark - tableView

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Article *article;
    if (indexPath.row < self.articlesArray.count) {
        article = self.articlesArray[indexPath.row];
    } else {
        article = self.askBarArticlesArray[indexPath.row - self.articlesArray.count];
    }
    CGFloat lineSpacing = kSWidth == 375 ||kSWidth == 414 ? 7 : 4;
    NSMutableAttributedString *string = [NSMutableAttributedString attributedStringWithString:article.title Font:[UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleCellTitleFontSize] lineSpacing:lineSpacing];
    CGFloat height = [string boundingHeightWithSize:CGSizeMake(kSWidth - 20, 0) font:[UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleCellTitleFontSize] lineSpacing:lineSpacing maxLines:2];
    if ([article.extproperty hasPrefix:@"questionsAndAnswers"]) {
        return 90 + height + kSWidth/3.f;
    }else {
        return 70 + height + kSWidth/3.f;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.articlesArray.count + self.askBarArticlesArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Article *article;
    if (indexPath.row < self.articlesArray.count) {
        article = self.articlesArray[indexPath.row];
    } else {
        article = self.askBarArticlesArray[indexPath.row - self.articlesArray.count];
    }
    NSString *key = [article.extproperty hasPrefix:@"questionsAndAnswers"] ? [NSString stringWithFormat:@"%lld",article.lastID.longLongValue] : [NSString stringWithFormat:@"%d",article.fileId];
    article.isRead = [[self.saveIsReadDic valueForKey:key] boolValue];
    if ([article.extproperty hasPrefix:@"questionsAndAnswers"]) {
        MiddleCell *cell = (MiddleCell *)[NewsCellUtil getNewsCell:article in:tableView];
        __weak __typeof (self)weakSelf = self;
        [cell.relationButton addAction:^(UIButton *btn) {
            [weakSelf relationButtonClickForIndexPath:indexPath];
        }];
        return cell;
    }else {
        FDAskBarCell *cell = [tableView dequeueReusableCellWithIdentifier:FDAskBarCellId];
        [cell updateCellWithArticle:article];
        return cell;
    }
}

- (void)relationButtonClickForIndexPath:(NSIndexPath *)indexPath {
    if ([Global userId].length) {
        //已登录
        Article *article;
        if (indexPath.row < self.articlesArray.count) {
            article = self.articlesArray[indexPath.row];
        } else {
            article = self.askBarArticlesArray[indexPath.row - self.articlesArray.count];
        }
        NSString *urlString = [NSString stringWithFormat:@"%@/api/submitAskBarPlusFollow", [AppConfig sharedAppConfig].serverIf];
        NSURL *url = [NSURL URLWithString:urlString];
        HttpRequest *request = [HttpRequest requestWithURL:url];
        [request setHTTPMethod:@"POST"];
        NSString *sign = [AESCrypt encrypt:[NSString stringWithFormat:@"%@%@%@", [AppConfig sharedAppConfig].sid, [Global userId], article.lastID] password:key];
        NSString *informString = [NSString stringWithFormat:@"sid=%@&aid=%zd&uid=%@&sign=%@&type=%d&authorID=%zd", [AppConfig sharedAppConfig].sid,article.lastID.integerValue, [Global userId],sign, !article.isFollow, article.authorID.integerValue];
        informString = [informString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSData *informData = [informString dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPBody:informData];
        __weak __typeof (self)weakSelf = self;
        [request setCompletionBlock:^(id data) {
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers  error:nil];
            if ([[dic objectForKey:@"success"] boolValue]) {
                article.isFollow = !article.isFollow;
                article.interestCount = [dic objectForKey:@"interestCount"];
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
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(didLogin)
         name:@"duiba-load-WebView"
         object:nil];
    }
}

- (void)didLogin {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"duiba-load-WebView" object:nil];
    [self loadData:YES];//[self loadFocusedInteractionList];
    
}

#pragma mark - table view data source

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Article *article;
    if (indexPath.row < self.articlesArray.count) {
        article = self.articlesArray[indexPath.row];
    } else {
        article = self.askBarArticlesArray[indexPath.row - self.articlesArray.count];
    }

//    [NewsCellUtil clickNewsCell:article column:self.parentColumn in:self];
    FDQuestionsAndAnwsersPlusDetailViewController * detialVC = [[FDQuestionsAndAnwsersPlusDetailViewController alloc]init];
    detialVC.article = article;
    detialVC.column = self.parentColumn;
    [self.navigationController pushViewController:detialVC animated:YES];
    
    //存储已读信息
    article.isRead = YES;
    NSString *key = [article.extproperty hasPrefix:@"questionsAndAnswers"] ? [NSString stringWithFormat:@"%lld",article.lastID.longLongValue] : [NSString stringWithFormat:@"%d",article.fileId];
    [self.saveIsReadDic setObject:[NSNumber numberWithBool:YES] forKey:key];
        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

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

- (NSMutableArray *)askBarArticlesArray {
    if (_askBarArticlesArray == nil) {
        _askBarArticlesArray = [NSMutableArray array];
    }
    return _askBarArticlesArray;
}

- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kSWidth, kSHeight) style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor colorWithRed:237/255.f green:237/255.f blue:237/255.f alpha:1];
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[FDAskBarCell class] forCellReuseIdentifier:FDAskBarCellId];
        switch (self.viewControllerType) {
            case FDViewControllerForTabbarVC:
                _tableView.frame = CGRectMake(0, 0, kSWidth, kSHeight - kNavBarHeight - kTabBarHeight);
                break;
            case FDViewControllerForCloumnVC:{
                NSInteger onlyOne = [[[NSUserDefaults standardUserDefaults] objectForKey:@"onlyOne"] integerValue];
                if (onlyOne == 2 && ![AppStartInfo sharedAppStartInfo].ucTabisShow) {
                    _tableView.frame = CGRectMake(0, 0, kSWidth, kSHeight-kNavBarHeight-[ColumnBarConfig sharedColumnBarConfig].columnHeaderHeight);
                }else{
                    _tableView.frame = CGRectMake(0, 0, kSWidth, kSHeight-kNavBarHeight-kTabBarHeight-[ColumnBarConfig sharedColumnBarConfig].columnHeaderHeight);
                }
            }
                break;
            case FDViewControllerForUserCenterVC:
                _tableView.contentInset = UIEdgeInsetsMake(kNavBarHeight, 0, 0, 0);
                break;
            case FDViewControllerForDetailVC:
                _tableView.frame = CGRectMake(0, 0, kSWidth, kSHeight - kNavBarHeight);
                break;
            default:
                break;
        }
        _tableView.separatorInset = _tableView.contentInset;
        [_tableView registerClass:[MiddleCell class] forCellReuseIdentifier:interactionPlusCellIdentifier];
    }
    return _tableView;
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
