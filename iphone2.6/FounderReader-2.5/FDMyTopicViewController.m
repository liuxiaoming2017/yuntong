//
//  FDMyTopicViewController.m
//  FounderReader-2.5
//
//  Created by Julian on 2017/5/3.
//
//

#import "FDMyTopicViewController.h"
#import "HttpRequest.h"
#import "FDRefreshHeader.h"
#import "FDRefreshFooter.h"
#import "FDMyTopicCell.h"
#import "FDTopicListCell.h"
#import "AESCrypt.h"
#import "AppConfig.h"
#import "FDMyTopic.h"
#import "NewsListConfig.h"
#import "FDMyAskSegmentButton.h"
#import "ColorStyleConfig.h"
#import "FDTopicContentDetailViewController.h"
#import "FDTopicPlusDetailViewController.h"
#import "FDMyTopicAuditViewController.h"
#import "UIView+Extention.h"

static NSString *FDMyTopicCellIdentifier = @"FDMyTopicCellIdentifier";
static NSString *FDTopicListCellIdentifier = @"FDTopicListCellIdentifier";
static CGFloat segmentViewHeight = 40;

@interface FDMyTopicViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UIView *segmentView;
@property (strong, nonatomic) UITableView *myTopicsTableView;
@property (assign, nonatomic) FDMyTopicType type;

@property (strong, nonatomic) NSMutableArray *myJionedArray;
@property (strong, nonatomic) NSMutableArray *myFollowedArray;

@property (assign, nonatomic) NSUInteger myTopicsPage;
@property (assign, nonatomic) NSUInteger myFollowedPage;

@property (strong, nonatomic) HttpRequest *myTopicsRequest;
@property (strong, nonatomic) HttpRequest *myFollowedRequest;

@property (strong, nonatomic) UIView *nothingView;
@property (assign, nonatomic) BOOL isFromMyTopicDetail;//是否来自我的话题详情栏目

@end

@implementation FDMyTopicViewController

- (instancetype)initWithIsFromMyTopicDetail:(BOOL)isFromMyTopicDetail
{
    if (self = [super init]) {
        _isFromMyTopicDetail = isFromMyTopicDetail;
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self setupUI];
    
    [Global showMessage:NSLocalizedString(@"正在加载...",nil) duration:60 onView:self.view];
    self.myTopicsPage = -1;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMyTopicInfoByDetail:) name:@"updateMyTopicInfoByDetail" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTopicArticleByDetail:) name:@"updateTopicArticleByDetail" object:nil];
}

- (void)setupUI {
    
    [self setupNav];
    
    if (!_isFromMyTopicDetail)
        [self.view addSubview:self.segmentView];
    else
        _type = FDMyJoinedTopicType;
    
    [self.view addSubview:self.myTopicsTableView];
    [self.myTopicsTableView registerClass:[FDMyTopicCell class] forCellReuseIdentifier:FDMyTopicCellIdentifier];
    [self.myTopicsTableView registerClass:[FDTopicListCell class] forCellReuseIdentifier:FDTopicListCellIdentifier];
    [self createRefreshHeader];
    [self createRefreshFooter];
}

#pragma mark - header & footer

- (void)createRefreshHeader {
    FDRefreshHeader *header = [FDRefreshHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshHeader)];
    self.myTopicsTableView.mj_header = header;
    [header beginRefreshing];
}

- (void)refreshHeader {
    if (_type == FDMyJoinedTopicType) {
        [self loadMyTopics:YES];
    } else {
        [self loadFollowedTopics:YES];
    }
}

- (void)createRefreshFooter {
    FDRefreshFooter *footer = [FDRefreshFooter footerWithRefreshingTarget:self refreshingAction:@selector(refreshFooter)];
    self.myTopicsTableView.mj_footer = footer;
    //没数据时自动隐藏，而不出现“全部加载完毕等”
    self.myTopicsTableView.mj_footer.automaticallyHidden = YES;
}

- (void)refreshFooter {
    if (_type == FDMyJoinedTopicType) {
        [self loadMyTopics:NO];
    } else {
        [self loadFollowedTopics:NO];
    }
}

#pragma mark - load

- (void)loadMyTopics:(BOOL)isRefresh {
    [Global hideTip];
    if (isRefresh) {
        _myTopicsPage = 0;
    }
    NSString *requestString = [NSString stringWithFormat:@"%@/topicApi/getMyDiscussList?uid=%@&pageNum=%zd", [AppConfig sharedAppConfig].serverIf, [Global userId], _myTopicsPage];
    self.myTopicsRequest = [[HttpRequest alloc] initWithURL:[NSURL URLWithString:requestString]];
    [self.myTopicsRequest setValue:@"newaircloud.com" forHTTPHeaderField:@"Referer"];
    __weak __typeof (self)weakSelf = self;
    [self.myTopicsRequest setCompletionBlock:^(id data) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers  error:nil];
        NSMutableArray *listArray = [FDMyTopic mj_objectArrayWithKeyValuesArray:dict[@"list"]];
        if (listArray.count) {
            weakSelf.myTopicsPage++;
            [weakSelf.myTopicsTableView.mj_footer endRefreshing];
        } else {
            [weakSelf.myTopicsTableView.mj_footer endRefreshingWithNoMoreData];
        }
        
        if (isRefresh) {
            weakSelf.myJionedArray = nil;
        }
        [weakSelf.myJionedArray addObjectsFromArray:listArray.mutableCopy];
        
        [weakSelf.myTopicsTableView reloadData];
        [weakSelf.myTopicsTableView.mj_header endRefreshing];
        
    }];
    [self.myTopicsRequest setFailedBlock:^(NSError *error) {
        XYLog(@"load articles failed: %@", error);
        [weakSelf.myTopicsTableView.mj_header endRefreshing];
        [weakSelf.myTopicsTableView.mj_footer endRefreshing];
        [Global showTipNoNetWork];
    }];
    [self.myTopicsRequest startAsynchronous];
}

- (void)loadFollowedTopics:(BOOL)isRefresh {
    if (![Global userId].length) {
        return;
    }
    if (isRefresh) {
        _myFollowedPage = 0;
    }
    NSString *requestString = [NSString stringWithFormat:@"%@/topicApi/getMyFollowList?uid=%@&pageNum=%zd", [AppConfig sharedAppConfig].serverIf,[Global userId], _myFollowedPage];
    self.myFollowedRequest = [[HttpRequest alloc] initWithURL:[NSURL URLWithString:requestString]];
    [self.myFollowedRequest setValue:@"newaircloud.com" forHTTPHeaderField:@"Referer"];
    __weak __typeof (self)weakSelf = self;
    [self.myFollowedRequest setCompletionBlock:^(id data) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers  error:nil];
        NSArray *listArray = [Article articlesFromArray:dict[@"list"]];
        if (listArray.count) {
            weakSelf.myFollowedPage++;
        }
        if (isRefresh) {
            weakSelf.myFollowedArray = nil;
        }
        [weakSelf.myFollowedArray addObjectsFromArray:listArray.mutableCopy];
        [weakSelf.myTopicsTableView reloadData];
        
        if (!listArray.count) {
            [weakSelf.myTopicsTableView.mj_footer endRefreshingWithNoMoreData];
        } else {
            [weakSelf.myTopicsTableView.mj_footer endRefreshing];
        }
        
        [weakSelf.myTopicsTableView.mj_header endRefreshing];
    }];
    [self.myFollowedRequest setFailedBlock:^(NSError *error) {
        XYLog(@"load articles failed: %@", error);
        [Global showTipNoNetWork];
        [weakSelf.myTopicsTableView.mj_header endRefreshing];
        [weakSelf.myTopicsTableView.mj_footer endRefreshing];
    }];
    [self.myFollowedRequest startAsynchronous];
}

#pragma mark - tableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (_type == FDMyJoinedTopicType) {
        return self.myJionedArray.count;
    } else {
        return self.myFollowedArray.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (self.type == FDMyJoinedTopicType && !self.myJionedArray.count && self.myTopicsPage == 0) {
        return kSHeight - kNavBarHeight - 30;
    }
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (self.type == FDMyJoinedTopicType && !self.myJionedArray.count && self.myTopicsPage == 0) {
        [_nothingView removeFromSuperview];
        return self.nothingView;
    }
    else if (self.type == FDMyFollowedTopicType && !self.myFollowedArray.count && self.myFollowedPage == 0){
        [_nothingView removeFromSuperview];
        return self.nothingView;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat cellHeight = 0;
    if (self.type == FDMyJoinedTopicType) {
        //我的参与
        FDMyTopic *myTopic = self.myJionedArray[indexPath.row];
        myTopic.isHeader = NO;// 必须有，因为详情回来被改变了为YES，因为是函数参数方式注入详情页，所以是同一个对象
        cellHeight = [myTopic cellHeight];
    } else {
        //我的关注
        Article *article = self.myFollowedArray[indexPath.row];
        if (article.isBigPic)
            cellHeight = 8*2 + 7+ (kSWidth-15*2)*9/16.0f;
        else
            cellHeight = [NewsListConfig sharedListConfig].middleCellHeight + 7;
    }
    
    if (indexPath.row == 0)
        return _isFromMyTopicDetail ? cellHeight : cellHeight + 7;
    else
        return cellHeight;
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.type == FDMyJoinedTopicType) {
        FDMyTopicCell *cell = [tableView dequeueReusableCellWithIdentifier:FDMyTopicCellIdentifier];
        FDMyTopic *myTopic = self.myJionedArray[indexPath.row];
        BOOL isFirstRow = _isFromMyTopicDetail ? NO : indexPath.row == 0;
        [cell layoutCell:myTopic IsHeader:NO IsFirstRow:isFirstRow];
        if (_isFromMyTopicDetail)
            cell.titleLabel.text = @"";
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    } else {
        Article *article = [self.myFollowedArray objectAtIndex:indexPath.row];
        FDTopicListCell *cell = [tableView dequeueReusableCellWithIdentifier:FDTopicListCellIdentifier];
        cell.isFromMyTopic = YES;
        [cell setTopicArticle:article IsFirstRow:indexPath.row == 0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.type == FDMyJoinedTopicType) {
        FDMyTopic *myTopic = self.myJionedArray[indexPath.row];
        if (myTopic.discussStatus.integerValue == 1) {
            FDTopicContentDetailViewController *contentDetailVC = [[FDTopicContentDetailViewController alloc] initWithDiscussID:myTopic.discussID IsFromTopicDetailColumn:_isFromMyTopicDetail];
            __weak __typeof (myTopic)weakMyTopic = myTopic;
            contentDetailVC.hasPraiseBlock = ^(NSNumber *praiseCount){
                FDMyTopicCell *cell = (FDMyTopicCell *)[tableView cellForRowAtIndexPath:indexPath];
                cell.praiseBtn.selected = YES;
                weakMyTopic.praiseCount = praiseCount;
//                [cell updatePraiseCount:[praiseCount stringValue]]; 刷新即可
                [tableView reloadData];
            };
            contentDetailVC.hasCommentBlock = ^(){
                [self loadMyTopics:YES];
            };
            [self.navigationController pushViewController:contentDetailVC animated:YES];
        } else {
            FDMyTopicAuditViewController *auditVC = [[FDMyTopicAuditViewController alloc] initWithMyTopic:myTopic];
            [self.navigationController pushViewController:auditVC animated:YES];
        }
    } else {
        Article *article = [self.myFollowedArray objectAtIndex:indexPath.row];
        FDTopicPlusDetailViewController *detailVC = [[FDTopicPlusDetailViewController alloc] initWithTopicID:article.topicID viewControllerType:FDViewControllerForItemVC];
        [self.navigationController pushViewController:detailVC animated:YES];
    }
}

- (UIView *)segmentView {
    if (!_segmentView) {
        
        NSDictionary *topicConfigDict = [[NSUserDefaults standardUserDefaults] objectForKey:FDTopicConfigsNameKey];
        
        _segmentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSWidth, segmentViewHeight)];
        FDMyAskSegmentButton *leftBtn = [[FDMyAskSegmentButton alloc] initWithFrame:CGRectMake(0, 0, kSWidth/2.f, segmentViewHeight)];
        leftBtn.selected = YES;
        [leftBtn setTitle:NSLocalizedString([topicConfigDict objectForKey:FDTopicMyJoinWordKey], nil) forState:UIControlStateNormal];
        leftBtn.tag = 10001;
        [_segmentView addSubview:leftBtn];
        [leftBtn addTarget:self action:@selector(segmentButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        FDMyAskSegmentButton *rightBtn = [[FDMyAskSegmentButton alloc] initWithFrame:CGRectMake(kSWidth/2.f, 0, kSWidth/2.f, segmentViewHeight)];
        [rightBtn setTitle:NSLocalizedString([topicConfigDict objectForKey:FDTopicMyFollowWordKey], nil) forState:UIControlStateNormal];
        rightBtn.tag = 10002;
        [rightBtn addTarget:self action:@selector(segmentButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_segmentView addSubview:rightBtn];
        
    }
    return _segmentView;
}



- (void)segmentButtonAction:(UIButton *)sender {
    if (sender.selected) {
        return;
    }
    if (sender.tag == 10001) {
        //我的参与
        UIButton *rightBtn = [self.segmentView viewWithTag:10002];
        sender.selected = YES;
        rightBtn.selected = NO;
        self.type = FDMyJoinedTopicType;
        [self.myFollowedRequest cancel];
    } else {
        //我的关注
        UIButton *rightBtn = [self.segmentView viewWithTag:10001];
        sender.selected = YES;
        rightBtn.selected = NO;
        self.type = FDMyFollowedTopicType;
        [self.myTopicsRequest cancel];
        if (![self.myFollowedArray count]) {
            [self.myTopicsTableView.mj_header beginRefreshing];
        }
    }
    [self.myTopicsTableView.mj_header endRefreshing];
    [self.myTopicsTableView reloadData];
}

#pragma mark -lazy

- (NSMutableArray *)myFollowedArray
{
    if (!_myFollowedArray) {
        _myFollowedArray = [NSMutableArray array];
    }
    return _myFollowedArray;
}

- (NSMutableArray *)myJionedArray {
    if (!_myJionedArray) {
        _myJionedArray = [NSMutableArray array];
    }
    return _myJionedArray;
}

- (UITableView *)myTopicsTableView {
    if (!_myTopicsTableView) {
        CGFloat segmentViewH = _isFromMyTopicDetail ? 0 : segmentViewHeight;
        _myTopicsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, segmentViewH, kSWidth, kSHeight - kNavBarHeight - segmentViewH) style:UITableViewStylePlain];
        _myTopicsTableView.delegate = self;
        _myTopicsTableView.dataSource = self;
        _myTopicsTableView.tableFooterView = [[UIView alloc] init];
        _myTopicsTableView.backgroundColor = [UIColor colorWithRed:237/255.f green:237/255.f blue:237/255.f alpha:1];
        _myTopicsTableView.backgroundColor = [UIColor whiteColor];
        _myTopicsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _myTopicsTableView;
}

- (void)setupNav {
    
    // 设置导航默认标题的颜色及字体大小
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [ColorStyleConfig sharedColorStyleConfig].navbar_titlecolor_didselect, NSFontAttributeName : [UIFont boldSystemFontOfSize:18]};
    UIButton *preBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    preBtn.tag = 111;
    [preBtn setImage:[UIImage imageNamed:@"nav_bar_back"] forState:UIControlStateNormal];
    [preBtn sizeToFit];
    preBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    preBtn.contentEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
    [preBtn addTarget:self action:@selector(goPrePage) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:preBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
}

- (UIView *)nothingView {
    if (!_nothingView) {
        _nothingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSWidth, kSHeight - kNavBarHeight - 30)];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"global_nothing"]];
        imageView.origin = CGPointMake((kSWidth-imageView.width)/2.0f, 120*kSHeight/768.0f);
        [_nothingView addSubview:imageView];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(imageView.frame) + 18, kSWidth, 14)];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = self.type == FDMyJoinedTopicType ? @"你还没参与任何话题哟~" : @"你还没关注任何话题哟~";
        label.font = [UIFont systemFontOfSize:14];
        label.textColor = colorWithHexString(@"999999");
        [_nothingView addSubview:label];
    }
    return _nothingView;
}

- (void)goPrePage {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)updateMyTopicInfoByDetail:(NSNotification *)noti
{
    [self loadMyTopics  :YES];
}

- (void)updateTopicArticleByDetail:(NSNotification *)noti {
    [self loadFollowedTopics:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
