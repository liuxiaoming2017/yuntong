//
//  FDTopicPlusDetailViewController.m
//  FounderReader-2.5
//
//  Created by snitsky on 2017/5/4.
//
//

#import "FDTopicPlusDetailViewController.h"
#import "FDRefreshHeader.h"
#import "FDRefreshFooter.h"
#import "UIView+Extention.h"
#import "FDTopicPlusDetailHeader.h"
#import "FDTopicPlusDetailCell.h"
#import "FDTopicPlusDetaiHeaderlModel.h"
#import "HttpRequest.h"
#import "AppConfig.h"
#import "FDTopicDetailListModel.h"
#import "NSString+TimeStringHandler.h"
#import "UIButton+Block.h"
#import "YXLoginViewController.h"
#import "CommentViewControllerGuo.h"
#import "AESCrypt.h"
#import "UIDevice-Reachability.h"
#import "shareCustomView.h"
#import "ColumnBarConfig.h"
#import <AliyunOSSiOS/OSSService.h>
#import <AliyunOSSiOS/OSSCompat.h>
#import "FDTopicContentDetailViewController.h"
#import "PersonalCenterViewController.h"
#import "CDRTranslucentSideBar.h"
#import "AppStartInfo.h"
#import "FDMyTopicModifyViewController.h"

@interface FDTopicPlusDetailViewController () <UIGestureRecognizerDelegate, CDRTranslucentSideBarDelegate, UITableViewDelegate, UITableViewDataSource>
{
    NSString *_discussContent;
    NSMutableArray *_selectedPhotos;
    
    OSSClient * _client;
    NSDictionary *_dicInfo;
}

@property (strong, nonatomic) NSNumber *topicID;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) FDTopicPlusDetailHeader *headerView;
@property (strong, nonatomic) FDTopicPlusDetaiHeaderlModel *detailModel;

@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, assign) NSInteger pageNumer;
@property (nonatomic, strong) HttpRequest *detailRequest;
@property (nonatomic, strong) HttpRequest *detailListRequest;
@property (nonatomic, strong) CommentViewControllerGuo *commentController;

@property (strong, nonatomic) PersonalCenterViewController *leftController;
@property (strong, nonatomic) CDRTranslucentSideBar *sideBar;

@end

static NSString *FDTopicPlusDetailCellReuseIdentifier = @"FDTopicPlusDetailCellReuseIdentifier";

@implementation FDTopicPlusDetailViewController

- (instancetype)initWithTopicID:(NSNumber *)topicID viewControllerType:(FDViewControllerType)viewControllerType{
    if (self = [super init]) {
        _topicID = topicID;
        self.viewControllerType = viewControllerType;
        if (self.viewControllerType == FDViewControllerForTabbarVC || self.viewControllerType == FDViewControllerForCloumnVC)
            self.hidesBottomBarWhenPushed = NO;
    }
    return self;
}

- (void)dealloc {
    //tabbarItemController不能移除KVO
    if (self.viewControllerType == FDViewControllerForItemVC)
        [self.tableView removeObserver:self.headerView forKeyPath:@"contentOffset"];
//    //移除了所有的通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //用hidesBottomBarWhenPushed来控制
//    BOOL isAppearTab = (self.viewControllerType == FDViewControllerForTabbarVC || self.viewControllerType == FDViewControllerForCloumnVC);
//    [self.tabBarController.tabBar setHidden:!isAppearTab];
//    self.tabBarController.tabBar.hidden = NO;
//    
    BOOL isAppearNav = (self.viewControllerType == FDViewControllerForTabbarVC || self.viewControllerType == FDViewControllerForDetailVC || self.viewControllerType == FDViewControllerForUserCenterVC);
    [self.navigationController setNavigationBarHidden:!isAppearNav animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [Global showTipAlways:NSLocalizedString(@"正在加载...",nil)];

    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupTableV];
    
    [self loadOSSInfo];
    
    if (self.viewControllerType == FDViewControllerForTabbarVC || self.viewControllerType == FDViewControllerForCloumnVC) {
        [self titleLableWithTitle:self.parentColumn.columnName];
        [self setUpUI];
        [self setupJoinTopicDiscussBtn];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changeUserInfo)
                                                 name:KchangeUserInfoNotification
                                               object:nil];
    
}

- (void)setupJoinTopicDiscussBtn
{
    UIButton *joinDiscussBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    if (self.viewControllerType == FDViewControllerForCloumnVC ) {
        NSInteger onlyOne = [[[NSUserDefaults standardUserDefaults] objectForKey:@"onlyOne"] integerValue];
        if (onlyOne == 2 && ![AppStartInfo sharedAppStartInfo].ucTabisShow) {
           joinDiscussBtn.frame = CGRectMake(kSWidth - 83, kSHeight-[ColumnBarConfig sharedColumnBarConfig].columnHeaderHeight - 116, 90, 36);
        }else{
            joinDiscussBtn.frame = CGRectMake(kSWidth - 83, kSHeight-[ColumnBarConfig sharedColumnBarConfig].columnHeaderHeight - 170, 90, 36);
        }
        
    }else{
        joinDiscussBtn.frame = CGRectMake(kSWidth - 83, kSHeight - 170, 90, 36);
    }
    joinDiscussBtn.backgroundColor = [ColumnBarConfig sharedColumnBarConfig].column_all_color;
    [joinDiscussBtn setTitle:NSLocalizedString(@"我要参与",nil) forState:UIControlStateNormal];
    [joinDiscussBtn.titleLabel setFont:[UIFont systemFontOfSize:15.5]];
    joinDiscussBtn.alpha = 0.8;
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:joinDiscussBtn.bounds byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerTopLeft cornerRadii:CGSizeMake(18, 18)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = joinDiscussBtn.bounds;
    maskLayer.path = maskPath.CGPath;
    joinDiscussBtn.layer.mask = maskLayer;
    
    [joinDiscussBtn addTarget:self action:@selector(toJoinTopicDiscussClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:joinDiscussBtn];
}

- (void)toJoinTopicDiscussClick
{
    __weak __typeof (self)weakSelf = self;
    if(![NSString isNilOrEmpty:[Global userId]])
        [self joinTopicDiscuss];
    else
        [self toLoginWithBlock:^{
            [weakSelf joinTopicDiscuss];
        }];
}

- (void)joinTopicDiscuss
{
    __weak __typeof (self)weakSelf = self;
    FDMyTopicModifyViewController *modifyVC = [[FDMyTopicModifyViewController alloc] initWithMyTopic:nil DetailModel:self.detailModel];
    modifyVC.successAddDiscussBlock = ^(){
        [weakSelf loadDetailListData:YES];
        //若参与成功，默认关注此话题
        [weakSelf toFollowTopic:_headerView.followButton IsByDiscuss:YES];
    };
    modifyVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:modifyVC animated:YES];
}

- (void)setUpUI{
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self leftAndRightButton];
    self.navigationItem.rightBarButtonItem = nil;
    _leftController = [[PersonalCenterViewController alloc] init];
    self.leftController.view.frame = CGRectMake(0, 0, 240, self.view.bounds.size.height+kNavBarHeight);
    
    _sideBar = [[CDRTranslucentSideBar alloc] init];
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

-(void)left
{
    [self.sideBar show];
    return;
}

#pragma mark - 重写右滑出现评论手势方法 - 去掉右滑手势
-(void)showGreatComment
{
    XYLog(@"去掉右滑出现评论手势");
}

- (void)setupTableV
{
    [self.view addSubview:self.tableView];
    
    [self.tableView registerClass:[FDTopicPlusDetailCell class] forCellReuseIdentifier:FDTopicPlusDetailCellReuseIdentifier];
    [self createRefreshHeader];
    [self createRefreshFooter];
    
    //FDTopicPlusDetailHeaderView
    if (self.viewControllerType == FDViewControllerForItemVC) {
        [self.tableView addSubview:self.headerView];
        [self.view addSubview:self.headerView.navTitleLabel];
        
        [self.tableView addObserver:self.headerView
                         forKeyPath:@"contentOffset"
                            options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                            context:nil];
    }
}

- (void)createRefreshHeader {
    FDRefreshHeader *header = [FDRefreshHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshHeader)];
    self.tableView.mj_header = header;
    [header beginRefreshing];
}

- (void)refreshHeader {
    [self loadTopicDetailInfomation];
    [self loadDetailListData:YES];
}

- (void)createRefreshFooter {
    FDRefreshFooter *footer = [FDRefreshFooter footerWithRefreshingTarget:self refreshingAction:@selector(refreshFooter)];
    self.tableView.mj_footer = footer;
}

- (void)refreshFooter {
    [self loadDetailListData:NO];
}

- (void)setupFootV
{
    self.footview.commentBtn.hidden = YES;
    self.footview.commentLabel.hidden = YES;
    self.footview.greetBtn.hidden = YES;
    self.footview.greetLabel.hidden = YES;
    self.footview.collectBtn.hidden = YES;
    self.footview.shareBtn.x = kSWidth - 10 - self.footview.shareBtn.width;
    [self.view bringSubviewToFront:self.footview];
    //话题结束后，将其隐藏
    if (![self.detailModel.endTime isLaterThanNowWithDateFormat:TimeToSeconds]) {
        return;
    }
    
    UIImage *commentImage = [UIImage imageNamed:@"toolbar_comment_background_white"];
    UIButton *commentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat commentBtnX = CGRectGetMaxX(self.footview.backBtn.frame)+10;
    CGFloat commentBtnW = self.footview.shareBtn.x-10-commentBtnX;
    commentBtn.frame = CGRectMake(commentBtnX, (self.footview.height-30)/2.0f, commentBtnW, 30);
    [commentBtn setImage:commentImage forState:UIControlStateNormal];
    commentBtn.layer.masksToBounds = YES;
    commentBtn.layer.cornerRadius = commentBtn.height/2.0f;
    commentBtn.layer.borderWidth = 0.5f;
    commentBtn.layer.borderColor = colorWithHexString(@"b2b2b2").CGColor;
    __weak __typeof(self)weakSelf = self;
    [commentBtn addAction:^(UIButton *btn) {
        [weakSelf toWriteComment];
    }];
    [self.footview addSubview:commentBtn];
    
    UILabel *sayLabel = [[UILabel alloc] init];
    sayLabel.frame = CGRectMake(commentBtnX+15, (self.footview.height-20)/2.0f, commentBtn.width-30, 20);
    NSDictionary *topicConfigDict = [[NSUserDefaults standardUserDefaults] objectForKey:FDTopicConfigsNameKey];
    sayLabel.text = [topicConfigDict objectForKey:FDTopicDiscussWordKey];
    sayLabel.textColor = colorWithHexString(@"999999");
    sayLabel.font = [UIFont systemFontOfSize:13.5f];
    [self.footview  addSubview:sayLabel];
}

#pragma mark - 重写footerview的回调
- (void)goBothBack
{
    [self.detailRequest cancel];
    [self.detailListRequest cancel];
    [Global hideTip];
    if (self.navigationController.viewControllers.count > 1) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
}

- (void)shareClick
{
    if (![UIDevice networkAvailable]) {
        [Global showTipNoNetWork];
        return;
    }
    NSString *shareUrl = [NSString stringWithFormat:@"%@/topicColumn/%@/%ld",[AppConfig sharedAppConfig].serverIf, [AppConfig sharedAppConfig].sid, (long)self.topicID.integerValue];
    [shareCustomView shareWithContent:_detailModel.topicPlusDescription image:[NSString stringWithFormat:@"%@@!md169", _detailModel.imgUrl] title:_detailModel.title url:shareUrl type:0 completion:^(NSString *resultJson){
//        [FounderEventRequest founderEventShareAppinit:self.topicID.intValue];
//        //文章分享事件
//        [FounderEventRequest shareDateAnaly:self.topicID.intValue column:self.column.fullColumn];
    }];
}

#pragma mark - 写提问
- (void)toWriteComment
{
    __weak __typeof(self)weakSelf = self;
    if(![NSString isNilOrEmpty:[Global userId]])
        [self writeDiscuss];
    else
        [self toLoginWithBlock:^{
            [weakSelf writeDiscuss];
        }];
}

- (void)writeDiscuss
{
    _commentController = [[CommentViewControllerGuo alloc] init];
    [self.view addSubview:_commentController.view];
    [self.view bringSubviewToFront:_commentController.view];
    [self addChildViewController:_commentController];
    __weak __typeof(self)weakSelf = self;
    [_commentController setupCommentViewWith:NSLocalizedString(_detailModel.title,nil) SubTitle:nil IsTopic:YES HandleBlock:^(NSString *discussContent,NSMutableArray *photos) {
        _discussContent = discussContent;
        _selectedPhotos = [photos mutableCopy] ;
        [weakSelf addDiscuss:discussContent];
    }];
    _commentController.cancelHandleBlock = ^() {
        [weakSelf cancelDiscuss];
    };
    _commentController.successCommentBlock = ^() {
        
    };
}

- (void)cancelDiscuss
{
    [_selectedPhotos removeAllObjects];
}

#pragma mark - tableView Delegate && DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FDTopicDetailListModel *listModel = self.dataSource[indexPath.row];
    return listModel.cellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FDTopicPlusDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:FDTopicPlusDetailCellReuseIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    FDTopicDetailListModel *listModel = self.dataSource[indexPath.row];
    [cell layoutCell:listModel IsHeader:NO];
    __weak __typeof (self)weakSelf = self;
    [cell.praiseBtn addAction:^(UIButton *btn) {
        //已点赞不能取消，只处理未点赞
        if (!btn.selected) {
            if(![NSString isNilOrEmpty:[Global userId]])
                [weakSelf toPraiseAnswer:btn IndexPath:indexPath];
            else
                [weakSelf toLoginWithBlock:^{
                    [weakSelf toPraiseAnswer:btn IndexPath:indexPath];
                }];
        }
    }];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL isFromTopicDetailColumn = (self.viewControllerType == FDViewControllerForTabbarVC || self.viewControllerType == FDViewControllerForCloumnVC);
    FDTopicDetailListModel *itemModel = self.dataSource[indexPath.row];
    FDTopicContentDetailViewController *contentDetailVC = [[FDTopicContentDetailViewController alloc] initWithDiscussID:itemModel.discussID IsFromTopicDetailColumn:isFromTopicDetailColumn];
    contentDetailVC.detailModel = self.detailModel;
    __weak __typeof (itemModel)weakItemModel = itemModel;
    contentDetailVC.hasPraiseBlock = ^(NSNumber *praiseCount){
        FDTopicPlusDetailCell *cell = (FDTopicPlusDetailCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        cell.praiseBtn.selected = YES;
        weakItemModel.praiseCount = praiseCount;
//      [cell updatePraiseCount:[praiseCount stringValue]]; 刷新即可
        [tableView reloadData];
    };
    
    contentDetailVC.hasCommentBlock = ^(){
        [self loadDetailListData:YES];
    };
    contentDetailVC.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:contentDetailVC animated:YES];
}

#pragma mark - load data

- (void)loadTopicDetailInfomation {
    NSString *requestString = [NSString stringWithFormat:@"%@/topicApi/getTopicInfo?topicID=%lld&uid=%@", [AppConfig sharedAppConfig].serverIf, self.topicID.longLongValue, [Global userId]];
    self.detailRequest = [[HttpRequest alloc] initWithURL:[NSURL URLWithString:requestString]];
    __weak __typeof (self)weakSelf = self;
    [self.detailRequest setCompletionBlock:^(NSData *data) {
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers  error:nil];
        weakSelf.detailModel = [FDTopicPlusDetaiHeaderlModel mj_objectWithKeyValues:dict];
        if (self.viewControllerType == FDViewControllerForItemVC) {
            [weakSelf.headerView updateUIWithModel:weakSelf.detailModel];
            // 刷新话题首列表页信息
            [[NSNotificationCenter defaultCenter] postNotificationName:@"updateTopicArticleByDetail"
                                                                object:weakSelf.detailModel];
            [weakSelf setupFootV];
        }
    }];
    [self.detailRequest setFailedBlock:^(NSError *error) {
        [Global showTip:NSLocalizedString(@"加载失败，请检查网络",nil)];
    }];
    [self.detailRequest startAsynchronous];
}

- (void)loadDetailListData:(BOOL)isRefresh
{
    if (isRefresh) {
        _pageNumer = 0;
    }
    NSString *requestString = [NSString stringWithFormat:@"%@/topicApi/getDiscussList?topicID=%ld&pageNum=%ld", [AppConfig sharedAppConfig].serverIf, (long)_topicID.integerValue, (long)_pageNumer];
    self.detailListRequest = [[HttpRequest alloc] initWithURL:[NSURL URLWithString:requestString]];
    [self.detailListRequest setValue:@"newaircloud.com" forHTTPHeaderField:@"Referer"];
    __weak __typeof (self)weakSelf = self;
    [self.detailListRequest setCompletionBlock:^(id data) {
        NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers  error:nil];
        if ([[dataDict objectForKey:@"success"] boolValue]) {
            NSMutableArray *listArray = [FDTopicDetailListModel mj_objectArrayWithKeyValuesArray:dataDict[@"list"]];
            if (listArray.count) {
                weakSelf.pageNumer++;
                [weakSelf.tableView.mj_footer endRefreshing];
            } else {
//                [weakSelf.tableView.mj_footer endRefreshingWithNoMoreData];
                [weakSelf.tableView.mj_footer endRefreshing];
            }
            
            if (isRefresh) {
                weakSelf.dataSource = nil;
            }
            [weakSelf.dataSource addObjectsFromArray:listArray.mutableCopy];
            [Global hideTip];
            [weakSelf.tableView reloadData];
            [weakSelf.tableView.mj_header endRefreshing];
        }else {
            if ([[dataDict objectForKey:@"msg"] isEqualToString:@"没有相关信息"])
                //表示没有数据，不是错误
                [Global hideTip];
            else
                [Global showTip:NSLocalizedString(@"加载失败",nil)];
            [weakSelf.tableView.mj_header endRefreshing];
            [weakSelf.tableView.mj_footer endRefreshing];
        }
    }];
    [self.detailListRequest setFailedBlock:^(NSError *error) {
        XYLog(@"load articles failed: %@", error);
        [Global hideTip];
        [weakSelf.tableView.mj_header endRefreshing];
        [weakSelf.tableView.mj_footer endRefreshing];
        [Global showTipNoNetWork];
    }];
    [self.detailListRequest startAsynchronous];
}

#pragma mark - 网络

- (void)toLoginWithBlock:(void (^)(void))block
{
    YXLoginViewController *controller = [[YXLoginViewController alloc] init];
    [controller rightPageNavTopButtons];
    controller.loginSuccessBlock = ^(){
            if (block) block();
    };
    [self presentViewController:[Global controllerToNav:controller] animated:YES completion:nil];
}

- (void)addDiscuss:(NSString *)discussContent
{
    if ([_selectedPhotos count])
        [self sendPicsToAliyun];
    else
        [self sendDicuss:nil];
}

- (void)sendDicuss:(NSString *)attUrls
{
    // 若参与话题，默认关注此问答
    NSString *urlString = [NSString stringWithFormat:@"%@/topicApi/insertDiscuss", [AppConfig sharedAppConfig].serverIf];
    HttpRequest *addAskRequest = [HttpRequest requestWithURL:[NSURL URLWithString:urlString]];
    [addAskRequest setValue:@"newaircloud.com" forHTTPHeaderField:@"Referer"];
    [addAskRequest setHTTPMethod:@"POST"];
    // 评论页面中已被转义，加密时需要字符解码[askStr stringByRemovingPercentEncoding]
    NSString *sign = [AESCrypt encrypt:[NSString stringWithFormat:@"%@%@%@%@", [AppConfig sharedAppConfig].sid, [Global userId], self.topicID, [_discussContent stringByRemovingPercentEncoding]] password:key];
    
    NSString *bodyString = [NSString stringWithFormat:@"sid=%@&topicID=%ld&uid=%@&content=%@&publishStatus=%ld&sign=%@",[AppConfig sharedAppConfig].sid, self.topicID.integerValue, [Global userId], _discussContent, _detailModel.publishStatus.integerValue, sign];
    if(![NSString isNilOrEmpty:attUrls])
        bodyString = [bodyString stringByAppendingString:[NSString stringWithFormat:@"&attUrls=%@", attUrls]];
        
    [addAskRequest setHTTPBody:[bodyString dataUsingEncoding:NSUTF8StringEncoding]];
    __weak __typeof (self)weakSelf = self;
    [addAskRequest setCompletionBlock:^(NSData *data) {
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers  error:nil];
        if ([[dic objectForKey:@"success"] boolValue]) {
            [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(showMyTip:) userInfo:NSLocalizedString([dic objectForKey:@"msg"],nil) repeats:NO];
            [weakSelf loadDetailListData:YES];
            [_commentController.view removeFromSuperview];
        }else{
            [Global showTip:[NSString stringWithFormat:@"%@%@", NSLocalizedString(@"提交失败",nil),[dic objectForKey:@"msg"]]];
        }
    }];
    [addAskRequest setFailedBlock:^(NSError *error) {
        [Global showTipNoNetWork];
    }];
    [addAskRequest startAsynchronous];
    
    // 若参与，默认关注此话题
    if (!_headerView.followButton.selected) {
        //IsByDiscuss是否因为参与而关注
        [self toFollowTopic:_headerView.followButton IsByDiscuss:YES];
    }
}

- (void)toFollowTopic:(UIButton *)followBtn IsByDiscuss:(BOOL)isByDiscuss
{
    NSString *urlString = [NSString stringWithFormat:@"%@/topicApi/topicFollow", [AppConfig sharedAppConfig].serverIf];
    HttpRequest *addAskRequest = [HttpRequest requestWithURL:[NSURL URLWithString:urlString]];
    [addAskRequest setValue:@"newaircloud.com" forHTTPHeaderField:@"Referer"];
    [addAskRequest setHTTPMethod:@"POST"];
    NSString *sign = [AESCrypt encrypt:[NSString stringWithFormat:@"%@%@%@", [AppConfig sharedAppConfig].sid, [Global userId], self.topicID] password:key];
    NSString *bodyString = [NSString stringWithFormat:@"sid=%@&topicID=%ld&uid=%@&sign=%@&type=%d",[AppConfig sharedAppConfig].sid, self.topicID.integerValue, [Global userId], sign, !followBtn.selected];
    [addAskRequest setHTTPBody:[bodyString dataUsingEncoding:NSUTF8StringEncoding]];
    [addAskRequest setCompletionBlock:^(NSData *data) {
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers  error:nil];
        NSDictionary *topicConfigDict = [[NSUserDefaults standardUserDefaults] objectForKey:FDTopicConfigsNameKey];
        NSString *alertCancel = [NSString stringWithFormat:@"取消%@",[topicConfigDict objectForKey:FDTopicFollowWordKey]];
        NSString *alertSuccess = [NSString stringWithFormat:@"%@",[topicConfigDict objectForKey:FDTopicFollowWordKey]];
        NSString *alertStr = !followBtn.selected ? NSLocalizedString(alertSuccess,nil) : NSLocalizedString(alertCancel,nil);
        if ([[dic objectForKey:@"success"] boolValue]) {
            if (!isByDiscuss)
                [Global showTip:[NSString stringWithFormat:@"%@%@",alertStr, NSLocalizedString(@"成功",nil)]];
        }else{
            if (!isByDiscuss)
                [Global showTip:[NSString stringWithFormat:@"%@%@",alertStr, NSLocalizedString(@"失败, 请重新尝试",nil)]];
        }
        // 更新关注状态和关注人数、以及话题列表
        [self loadTopicDetailInfomation];
    }];
    [addAskRequest setFailedBlock:^(NSError *error) {
        [Global showTipNoNetWork];
    }];
    [addAskRequest startAsynchronous];
}

- (void)toPraiseAnswer:(UIButton *)praiseBtn IndexPath:(NSIndexPath *)indexPath
{
    /* 点赞功能分两部分
     1.更新用户对该讨论是否点赞(接口没有属性，本地记录)
     2.更新该讨论点赞数目(接口有数据)
     */
    praiseBtn.selected = YES;
    FDTopicPlusDetailCell *cell = (FDTopicPlusDetailCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    NSString *prasieKey = [NSString stringWithFormat:@"Topic_Praise_%ld", cell.discussID.integerValue];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:prasieKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSString *sign = [AESCrypt encrypt:[NSString stringWithFormat:@"%@%zd", [AppConfig sharedAppConfig].sid, cell.discussID.integerValue] password:key];
    NSString *urlString = [NSString stringWithFormat:@"%@/topicApi/discussPraise", [AppConfig sharedAppConfig].serverIf];
    HttpRequest *praiseRequest = [HttpRequest requestWithURL:[NSURL URLWithString:urlString]];
    [praiseRequest setValue:@"newaircloud.com" forHTTPHeaderField:@"Referer"];
    [praiseRequest setHTTPMethod:@"POST"];
    NSString *bodyString = [NSString stringWithFormat:@"sid=%@&discussID=%ld&sign=%@",[AppConfig sharedAppConfig].sid, cell.discussID.integerValue, sign];
    [praiseRequest setHTTPBody:[bodyString dataUsingEncoding:NSUTF8StringEncoding]];
    __weak __typeof (self)weakSelf = self;
    [praiseRequest setCompletionBlock:^(NSData *data) {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers  error:nil];
        NSString *alertStr = NSLocalizedString(@"点赞",nil);
        NSNumber *praiseCount = [dic objectForKey:@"praiseCount"];
        if (praiseCount && ![praiseCount isEqualToNumber:@0]){
            [cell updatePraiseCount:[praiseCount stringValue]];
            FDTopicDetailListModel *topicDetailModel = self.dataSource[indexPath.row];
            topicDetailModel.praiseCount = praiseCount;
            [weakSelf.tableView reloadData];
        }else {
            [Global showTip:[NSString stringWithFormat:@"%@%@",alertStr, NSLocalizedString(@"失败, 请重新尝试",nil)]];
            praiseBtn.selected = NO;
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:prasieKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
    }];
    [praiseRequest setFailedBlock:^(NSError *error) {
        [Global showTipNoNetWork];
    }];
    [praiseRequest startAsynchronous];
}

- (void)showMyTip:(NSTimer *)timer
{
    NSString *userInfo = (NSString *)[timer userInfo];
    [Global showTip:userInfo];
}

#pragma mark - lazy

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kSWidth, kSHeight - 48) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor whiteColor];
        if (self.viewControllerType == FDViewControllerForItemVC) {
            //那么_tableView的y=0时相对于self.view为-(FDTopicPlusDetailHeaderHeight+25)
            _tableView.contentInset = UIEdgeInsetsMake(FDTopicPlusDetailHeaderHeight+25, 0, 0, 0);
            _tableView.contentOffset = CGPointMake(0, -FDTopicPlusDetailHeaderHeight-25);
            //        _tableView.separatorInset = UIEdgeInsetsMake(0, 10, 0, 10);//tableViewCell系统的分界线左右距离边界各10
            //        _tableView.layoutMargins = UIEdgeInsetsZero;
        }
        
        switch (self.viewControllerType) {
            case FDViewControllerForTabbarVC:
                _tableView.frame = CGRectMake(0, 0, kSWidth, kSHeight - kNavBarHeight - kTabBarHeight);
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
//                _tableView.frame = CGRectMake(0, 0, kSWidth, kSHeight - kNavBarHeight-[ColumnBarConfig sharedColumnBarConfig].columnHeaderHeight - kTabBarHeight);
                break;
            case FDViewControllerForUserCenterVC:
                _tableView.contentInset = UIEdgeInsetsMake(kNavBarHeight, 0, 0, 0);
                break;
            case FDViewControllerForDetailVC:
                _tableView.frame = CGRectMake(0, 0, kSWidth, kSHeight - kNavBarHeight);
                break;
            case FDViewControllerForItemVC:
                _tableView.frame = CGRectMake(0, 0, kSWidth, kSHeight - 48);
                break;
            default:
                break;
        }
    }
    return _tableView;
}

- (FDTopicPlusDetailHeader *)headerView {
    if (!_headerView) {
        // _tableView的y=0时相对于self.view为-(FDTopicPlusDetailHeaderHeight+25)
        // 属于tableview但想在tableview上面，那么y设置为- FDTopicPlusDetailHeaderHeight，此时相对于self.view的y为0
        _headerView = [[FDTopicPlusDetailHeader alloc] initWithFrame:CGRectMake(0, - FDTopicPlusDetailHeaderHeight, kSWidth, FDTopicPlusDetailHeaderHeight+25)];
        __weak __typeof(self)weakSelf = self;
        [_headerView.followButton addAction:^(UIButton *btn) {
            if(![NSString isNilOrEmpty:[Global userId]])
                [weakSelf toFollowTopic:btn IsByDiscuss:NO];
            else
                [weakSelf toLoginWithBlock:^{
                    [weakSelf toFollowTopic:btn IsByDiscuss:NO];
                }];
        }];
    }
    return _headerView;
}

- (NSMutableArray *)dataSource
{
    if (!_dataSource) {
        _dataSource = [[NSMutableArray alloc] init];
    }
    return _dataSource;
}


#pragma mark ====== 阿里云存储

- (void)initOSSClient {
    
    id<OSSCredentialProvider> credential = [[OSSPlainTextAKSKPairCredentialProvider alloc] initWithPlainTextAccessKey:[_dicInfo objectForKey:@"accessKeyId"] secretKey:[_dicInfo objectForKey:@"accessKeySecret"]];
    
    OSSClientConfiguration * conf = [OSSClientConfiguration new];
    conf.maxRetryCount = 2;
    conf.timeoutIntervalForRequest = 30;
    conf.timeoutIntervalForResource = 24 * 60 * 60;
    
    _client = [[OSSClient alloc] initWithEndpoint:[NSString stringWithFormat:@"http://%@",[_dicInfo objectForKey:@"endpoint"]] credentialProvider:credential clientConfiguration:conf];
}

- (void)loadOSSInfo
{
    _dicInfo = [NSDictionary dictionary];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/api/getOSSInfo?sid=%@",[AppConfig sharedAppConfig].serverIf,[AppConfig sharedAppConfig].sid];
    XYLog(@"%@",urlString);
    HttpRequest *request = [HttpRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    [request setCompletionBlock:^(NSData *data) {
        NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        NSString *strEncrypt = [responseDict objectForKey:@"info"];
        if (strEncrypt != nil){
            //开始解密newaircloud_vjow9Dej#JDj4[oIDF
            NSString *strDecrypt = [AESCrypt decrypt:strEncrypt password:key];
            NSData *dataDecrypt = [strDecrypt dataUsingEncoding:NSUTF8StringEncoding];
            _dicInfo = [NSJSONSerialization JSONObjectWithData:dataDecrypt options:NSJSONReadingMutableContainers error:nil];
            [self initOSSClient];
        }
    }];
    
    [request setFailedBlock:^(NSError *error)
     {
         XYLog(@"send inform attachment error: %@", error);
     }];
    [request startAsynchronous];
}

#pragma mark 上传图片
// 上传图片
- (void)sendPicsToAliyun
{
    if([NSString isNilOrEmpty:[_dicInfo objectForKey:@"bucket"]]){
        [Global showTipNoNetWork];
        [self loadOSSInfo];
        return;
    }
    
    __block int j = 1;
    __block NSMutableArray *picUrlArr = [[NSMutableArray alloc] init];
    dispatch_group_t serviceGroup = dispatch_group_create();
    for (int i = 0; i < _selectedPhotos.count; i++) {
        
        NSTimeInterval interval = [[NSDate date] timeIntervalSince1970] * 1000;
        dispatch_group_enter(serviceGroup);
        OSSPutObjectRequest * put = [OSSPutObjectRequest new];
        put.bucketName = [_dicInfo objectForKey:@"bucket"];
        put.objectKey = [NSString stringWithFormat:@"%@%@_img_%f.png",[_dicInfo objectForKey:@"uploadDir"],[_dicInfo objectForKey:@"uploadFile"],interval];
        /* 两种压缩方式，png和jpeg，对清晰度不是很要求的话后者压缩力度很大且很快 */
        //    put.uploadingData = UIImagePNGRepresentation(image);
        put.uploadingData = [Global compressImageData:_selectedPhotos[i]];
        XYLog(@"第%d张图片大小为%ldKB",i, put.uploadingData.length/1024);
        
        OSSTask * putTask = [_client putObject:put];
        [putTask continueWithBlock:^id(OSSTask *task) {
            if (!task.error) {
                NSString *url = [NSString stringWithFormat:@"%@/%@",[_dicInfo objectForKey:@"picRoot"],put.objectKey];
                [picUrlArr addObject:url];
                j = j<_selectedPhotos.count ? j+1 : j;
                if (j == _selectedPhotos.count) {
                    NSString *alertTitle = [NSString stringWithFormat:@"%@%@",@"正在上传中...",@"99%"];
                    [self showLoading:alertTitle];
                }else {
                    NSString*alertTitle = [NSString stringWithFormat:@"%@%.0f%@",@"正在上传中...",((float)j/(_selectedPhotos.count))*100, @"%"];
                    XYLog(@"分子j=%d,分母count=%lu,分数float=%f",j,(unsigned long)_selectedPhotos.count,((float)j/(_selectedPhotos.count)));
                    [self showLoading:alertTitle];
                }
            } else {
                XYLog(@"upload object failed, error: %@" , task.error);
            }
            dispatch_group_leave(serviceGroup);
            return nil;
        }];
    }
    
    dispatch_group_notify(serviceGroup, dispatch_get_main_queue(),^{
        if(picUrlArr.count != _selectedPhotos.count){
            [self showLoading:NSLocalizedString(@"网络不给力，请检查一下网络设置", nil)];
            return;
        }
        NSArray *picUrlsTemp = [picUrlArr sortedArrayUsingSelector:@selector(compare:)];
        NSMutableArray *picUrls = [NSMutableArray array];
        for (NSString *url in picUrlsTemp) {
            NSMutableDictionary *dictTmp = [[NSMutableDictionary alloc] init];
            [dictTmp setObject:url forKey:@"url"];
            // 字典转json字符串
//            NSString *jsonDic = [Global dictionaryToJson:dictTmp];
            [picUrls addObject:dictTmp];
        }
        // 数组转json字符串
//        picUrlsJson = [Global objArrayToJSON:picUrls];
        // 那些层需要转成json串，取决于后台怎么解析的，这里只是最外面包一层
        NSMutableDictionary *allUrlDict = [NSMutableDictionary dictionaryWithObject:picUrls forKey:@"pics"];
        NSString *allUrls = [Global dictionaryToJson:allUrlDict];
        allUrls = [allUrls stringByReplacingOccurrencesOfString:@" " withString:@""];
        allUrls = [allUrls stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        allUrls = [allUrls stringByReplacingOccurrencesOfString:@"\\" withString:@""];
        [self sendDicuss:allUrls];
        
    });
}

- (void)showLoading:(NSString *)alertTitle{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //通知主线程刷新
        [Global showTipAlways:alertTitle];
    });
}

#pragma mark - 通知处理
- (void)changeUserInfo
{
    [self loadDetailListData:YES];
}

@end
