//
//  SeeRootViewController.m
//  FounderReader-2.5
//
//  Created by lx on 15/8/17.
//
//

#import "SeeRootViewController.h"
#import "SeeMethod.h"
#import "SeeDirectView.h"
#import "HttpRequest.h"
#import "AppConfig.h"
#import "YXLoginViewController.h"
#import "UIDevice-Reachability.h"
#import "CommentViewControllerGuo.h"
#import "GreatestCommentPageController.h"
#import "SeeMethod.h"
#import "ColumnBarConfig.h"
#import "SeeLiveTopView.h"
#import "SeeContentLable.h"
#import "LocalNotificationManager.h"
#import "LiveSteamModel.h"
#import "TopDiscussmodel.h"
#import "LiveArticleInfoModel.h"
#import "FileLoader.h"
#import "UIView+Extention.h"
#import <MediaPlayer/MediaPlayer.h>

static CGFloat kMiddleViewH = 40; //中部视图的高度
static CGFloat kLeftAndRightViewH = 35; //左右切换按钮的高度

@interface SeeRootViewController ()<UIGestureRecognizerDelegate> {
    
    UIInterfaceOrientation   _lastOrientation;
    
}

@property (nonatomic, strong) UIView *statusView; //状态栏bgV
@property (nonatomic, retain) UIButton *leftBtn;
@property (nonatomic, retain) UIButton *rightBtn;
@property (nonatomic, retain) UIButton *upDownBtn;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, retain) UIView *footView;
@property (nonatomic, strong) UIView *middleView;
@property (nonatomic, strong) UIView *leftAndRightView;
@property (nonatomic, assign) BOOL isBack;
@property (nonatomic, assign) BOOL isUp; //是否展开middleView  YES:闭合 NO:展开
@property (nonatomic, strong) CALayer *leftbottomBorder;
@property (nonatomic, strong) CALayer *rightbottomBorder;
@property (nonatomic, strong) CALayer *middleViewBottomBorder;
@property (nonatomic, assign) CGFloat contentLableHeight;//稿件简介的高度

@property (nonatomic, copy) NSString *msg; // 直播未发布的字段
@property (nonatomic, copy) NSString *playbackUrl;
@property (nonatomic, copy) NSString *rmtpUrl;
@property (nonatomic, assign) BOOL isLiveVideoType;
@property (nonatomic, assign) NSInteger playStatus;

@property (nonatomic, strong) LiveSteamModel *steamModel;
@property (nonatomic, strong) TopDiscussmodel *descripetion;
@property (nonatomic, strong) LiveArticleInfoModel *articleInfoModel;
@property (nonatomic, strong) SeeDirectView *dirct_seeding;
@property (nonatomic, strong) SeeLiveTopView * liveTopView;

@property (nonatomic, strong) MPMoviePlayerViewController * moviePlayer;
@end

@implementation SeeRootViewController
{
    GreatestCommentPageController *comment;
    SeeContentLable *_contentLableView;
}

@synthesize statusView,leftBtn,rightBtn,upDownBtn,mainModel,liveFrame,footView,leftAndRightView,middleView,scrollview,isBack,leftbottomBorder,rightbottomBorder,middleViewBottomBorder;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 防止scrollView自动布局
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    _isUp = YES;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    statusView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSWidth, kStatusBarHeight)];
    statusView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:statusView];
    
    [Global showTipAlways:NSLocalizedString(@"正在加载...",nil)];
    // 先加载数据, 加载数据完成后, 添加控件,设置位置
    [self loadLiveDatasource];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeUpAndDownView) name:@"CloseUpAndDownView" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(takeContentLableHeight:) name:@"ContentLableHeight" object:nil];

    [self addFootView];
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AutoHideBarViews" object:nil];
    
    [self.dirct_seeding creatDirect];
}
//MARK: 加载网络数据+加载页面
-(void)loadLiveDatasource
{
    // 新空云新接口
    // http://h5.newaircloud.com/api/getLiveList?sid=xkycs&id=13314&lastFileID=0&rowNumber=0&aid=273958
    // NSString *testStr = @"http://h5test.newaircloud.com"; //测试
    NSString *urlString = [NSString stringWithFormat:@"%@/api/getLiveList?sid=%@&id=%d&lastFileID=0&rowNumber=0&aid=%d",[AppConfig sharedAppConfig].serverIf, [AppConfig sharedAppConfig].sid, self.seeArticle.linkID,self.seeArticle.fileId];
    FileLoader *request = [FileLoader fileLoaderWithUrl:urlString];
    [request setCompletionBlock:^(NSData *data) {
        
        NSDictionary *dataArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers  error:nil];
        
        self.msg = [dataArray valueForKey:@"msg"];

        NSDictionary *main = [dataArray valueForKey:@"main"];
        self.descripetion = [TopDiscussmodel topSeeDirectFromDiction:main];
        [Global hideTip];
        
        NSDictionary *liveStream = [main valueForKey:@"liveStream"];
        NSDictionary *articleInfo = [main valueForKey:@"articleInfo"];
        self.steamModel = [LiveSteamModel steamFromDiction:liveStream];
        if (liveStream.count == 0) {
            self.isLiveVideoType = NO;// NO
            self.steamModel.isLiveVideoType = NO;
        }else {
            self.isLiveVideoType = YES;
            self.steamModel.isLiveVideoType = YES;
        }
        
        self.articleInfoModel = [LiveArticleInfoModel articleInfoFromeDiction:articleInfo];
        
        middleView = [[UIView alloc] init];
        self.scrollview = [[UIScrollView alloc] init];
        
        if (self.isLiveVideoType == NO) { // 图文
            _liveTopView = [[SeeLiveTopView alloc] initWithFrame:CGRectMake(0, kStatusBarHeight, kSWidth, kLiveImageTextViewH)];
            
            [self addMiddleView];
            _isUp = NO;
            _contentLableView.hidden = NO;
            
            CGFloat middleViewH = kMiddleViewH;
            XYLog(@"%f",self.contentLableHeight);
            if (self.contentLableHeight != 0) {
                middleViewH = 25+self.contentLableHeight+ kLeftAndRightViewH;
            }
            middleView.frame = CGRectMake(0, kLiveImageTextViewH + kStatusBarHeight, kSWidth, middleViewH);
            
            self.scrollview.frame = CGRectMake(0, kLiveImageTextViewH + kStatusBarHeight + middleViewH , kSWidth, kSHeight-kLiveImageTextViewH - kStatusBarHeight - middleViewH-40 - 3);
            self.scrollview.contentSize =CGSizeMake(kSWidth*2, kSHeight-kLiveImageTextViewH - kStatusBarHeight - middleViewH -40 -  3);
            
            [self addLiveTopView];
            [self addLiveScrollview];
            [self creatUIdetails];
            
        }else if (self.isLiveVideoType == YES) { // 视频
            
            _liveTopView = [[SeeLiveTopView alloc] initWithFrame:CGRectMake(0, kStatusBarHeight, kSWidth, kLiveVideoViewH)];
            [self addMiddleView];
            
            CGFloat middleViewH = kMiddleViewH;
            if (self.contentLableHeight != 0) {
                middleViewH = 60;
            }
            middleView.frame = CGRectMake(0, kLiveVideoViewH+kStatusBarHeight, kSWidth, middleViewH);
            
            self.scrollview.frame = CGRectMake(0, kLiveVideoViewH + kStatusBarHeight + middleViewH , kSWidth, kSHeight-kLiveVideoViewH - kStatusBarHeight - middleViewH - 40 - 3);
            self.scrollview.contentSize = CGSizeMake(kSWidth*2, kSHeight-kLiveVideoViewH - kStatusBarHeight - middleViewH - 40 - 3);
            
            [self addLiveTopView];
            [self addLiveScrollview];
            [self creatUIdetails];
        }
        
    }];
    [request setFailedBlock:^(NSError *error) {
        [Global hideTip];
        [Global showTipNoNetWork];
    }];
    
    [request startAsynchronous];
}

- (void)addLiveTopView {
    
    _liveTopView.article = self.seeArticle;
    _liveTopView.fileid = self.seeArticle.linkID;
    _liveTopView.aid = self.seeArticle.fileId;
    _liveTopView.title = self.seeArticle.title;
    _liveTopView.articleType = self.seeArticle.articleType;
    
    _liveTopView.discussModel = self.descripetion;
    _liveTopView.steamModel = self.steamModel;
    _liveTopView.articleInfoModel = self.articleInfoModel;
    
    _liveTopView.isLiveVideoType = self.isLiveVideoType;
    _liveTopView.backgroundColor = [UIColor blackColor];
    // topView (图文or视频)
    NSString *notiKey = [NSString stringWithFormat:@"%@%d", kLiveRemindNotificationKey, self.seeArticle.fileId];
    _liveTopView.liveRemindStatus = [LocalNotificationManager checkLocalNotificationWithKey:notiKey] ? NSLocalizedString(@"已开启提醒", nil)  : NSLocalizedString(@"开启提醒", nil);
    [_liveTopView creatTopView];
    
    [self.view addSubview:_liveTopView];
}

- (void)addLiveScrollview {
    self.scrollview.pagingEnabled = YES;
    self.scrollview.scrollsToTop = YES;
    self.scrollview.delegate = self;
    self.scrollview.contentOffset = CGPointMake(0, 0);
    self.scrollview.showsHorizontalScrollIndicator = NO;
    self.scrollview.showsVerticalScrollIndicator = NO;
    self.scrollview.bounces = YES;
    [self.view addSubview:self.scrollview];
    [self.view sendSubviewToBack:self.scrollview];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES ;
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    //[[UIApplication sharedApplication] setStatusBarHidden:NO];
    //    _liveTopView.backgroundColor = [UIColor blackColor];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    appDelegate().isAllOrientation = NO;
    [Global hideTip];
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
    [UIApplication sharedApplication].idleTimerDisabled =NO;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (_liveTopView.seePlayer.status != PLPlayerStatusUnknow) {
        [_liveTopView.seePlayer stop];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    __weak typeof(self) weakSelf = self;

    self.liveTopView.videoPlayerWillChangeToOriginalScreenModeBlock = ^(){
        if (weakSelf.liveTopView.deviceOrientation == UIDeviceOrientationPortrait) {
            weakSelf.middleView.hidden = NO;
            weakSelf.scrollview.hidden = NO;
        }else {
            weakSelf.middleView.hidden = YES;
            weakSelf.scrollview.hidden = YES;
        }
    };
}
- (void)addMiddleView
{
    // 中部切换
    middleView.backgroundColor = [UIColor whiteColor];
    // 展开按钮
    upDownBtn = [[UIButton alloc] initWithFrame:CGRectMake((kSWidth - 36)/2, 0, 36, 25)];
    [upDownBtn addTarget:self action:@selector(upDownClick) forControlEvents:UIControlEventTouchUpInside];
    
    [upDownBtn setBackgroundImage:[UIImage imageNamed:@"icon-down"] forState:UIControlStateNormal];
    [upDownBtn setBackgroundImage:[UIImage imageNamed:@"icon-down"] forState:UIControlStateHighlighted];
    
    if (self.isLiveVideoType == NO) {
        [upDownBtn setBackgroundImage:[UIImage imageNamed:@"icon-up"] forState:UIControlStateNormal];
        [upDownBtn setBackgroundImage:[UIImage imageNamed:@"icon-up"] forState:UIControlStateHighlighted];
    }
    
    // 简介
    _contentLableView = [[SeeContentLable alloc] initWithFrame:CGRectMake(0, upDownBtn.bounds.size.height + 2, kSWidth, self.contentLableHeight)];
    _contentLableView.discussmodel = self.descripetion;
    _contentLableView.fileid = self.seeArticle.linkID;
    _contentLableView.aid = self.seeArticle.fileId;
    _contentLableView.msg = self.msg;
    //    _contentLableView.articleType = self.seeArticle.articleType;
    [_contentLableView creatContentLableView];

    [middleView addSubview:_contentLableView];
    _contentLableView.hidden = YES;
    _contentLableView.contentLable.font = [UIFont fontWithName:[Global fontName] size:17];
    
    if ([_contentLableView.contentLable.text isEqualToString:@""]) {
        
        upDownBtn.hidden = YES;
    }
    // 左右切换按钮父视图
    if (self.contentLableHeight == 0) {
        leftAndRightView = [[UIView alloc] initWithFrame:CGRectMake(0, kMiddleViewH - kLeftAndRightViewH, kSWidth, kLeftAndRightViewH)];
    }else {
        leftAndRightView = [[UIView alloc] initWithFrame:CGRectMake(0, upDownBtn.bounds.size.height + 1, kSWidth, kLeftAndRightViewH)];
    }

    if (self.isLiveVideoType == NO) {
        if (self.contentLableHeight != 0) {
            CGFloat heightH = 25+self.contentLableHeight;
            leftAndRightView.frame = CGRectMake(0, heightH, kSWidth, kLeftAndRightViewH);
        }else {
            upDownBtn.hidden = YES;
        }
    }
    
    middleViewBottomBorder = [CALayer layer];
    float height3 = leftAndRightView.frame.size.height;
    float width3 = leftAndRightView.frame.size.width;
    middleViewBottomBorder.frame = CGRectMake(0, height3-1, width3, 1);
    middleViewBottomBorder.backgroundColor = [UIColor colorWithRed:221/255.0 green:221/255.0 blue:221/255.0 alpha:1.0].CGColor;
    [leftAndRightView.layer addSublayer:middleViewBottomBorder];
    
    // 左边直播
    leftBtn = [[UIButton alloc] initWithFrame:CGRectMake(kSWidth*0.5-20-55 - 25, 0, 60, kLeftAndRightViewH)];
    leftBtn.tag = 1888;
    leftBtn.selected = YES;
    [leftBtn setTitle:[NSString stringWithFormat:@"%@",NSLocalizedString(@"直播",nil)] forState:UIControlStateNormal];
    [leftBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
    leftBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [leftBtn setTitleColor:[ColumnBarConfig sharedColumnBarConfig].column_all_color forState:UIControlStateSelected];
    [leftBtn setTitleColor:[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(headLeftBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    leftbottomBorder = [CALayer layer];
    float height1=leftBtn.frame.size.height;
    float width1=leftBtn.frame.size.width + 10.0f;
    leftbottomBorder.frame = CGRectMake(0.0f, height1-1, width1, 1.0f);
    leftbottomBorder.backgroundColor = [ColumnBarConfig sharedColumnBarConfig].column_all_color.CGColor;
    [leftBtn.layer addSublayer:leftbottomBorder];
    
    // 右边聊天室
    rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(kSWidth * 0.5 +10 + 25, 0, 60, kLeftAndRightViewH)];
    rightBtn.tag = 1887;
    [rightBtn setTitle:[NSString stringWithFormat:@"%@",NSLocalizedString(@"聊天室",nil)] forState:UIControlStateNormal];
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [rightBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
    [rightBtn setTitleColor:[ColumnBarConfig sharedColumnBarConfig].column_all_color forState:UIControlStateSelected];
    [rightBtn setTitleColor:[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(headRightBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    rightbottomBorder = [CALayer layer];
    float height2 = rightBtn.frame.size.height;
    float width2 = rightBtn.frame.size.width + 10.0f;
    rightbottomBorder.frame = CGRectMake(0.0f, height2-1, width2, 1.0f);
    rightbottomBorder.backgroundColor = [ColumnBarConfig sharedColumnBarConfig].column_all_color.CGColor;
    [rightBtn.layer addSublayer:rightbottomBorder];
    rightbottomBorder.hidden = YES;
    
    [middleView addSubview:upDownBtn];
    [middleView addSubview:leftAndRightView];
    
    [leftAndRightView addSubview:leftBtn];
    [leftAndRightView addSubview:rightBtn];
    
    [self.view addSubview:middleView];
}

// 获取直播topV的高
- (void)takeContentLableHeight:(NSNotification *)notic {
    NSDictionary *dict = notic.userInfo;
    self.contentLableHeight = [[dict objectForKey:@"contentLableHeight"] integerValue];
}


// 滑动时, 自动关闭middView
- (void)closeUpAndDownView {
    if (_isUp == NO) {
        [self upDownClick];
    }
}

- (void)upDownClick {
    // 根据直播内容的高度展开的高度
    CGFloat upDownHeight;
    if (self.contentLableHeight == 0.0) {
        upDownHeight = 0.0;
    }else {
        upDownHeight = self.contentLableHeight;
    }
    if (_isUp) {
        // 闭合的时候(默认是闭合的),点击的时候展开
        [upDownBtn setBackgroundImage:[UIImage imageNamed:@"icon-up"] forState:UIControlStateNormal];
        [upDownBtn setBackgroundImage:[UIImage imageNamed:@"icon-up"] forState:UIControlStateHighlighted];
        
        _isUp = NO;
        [UIView animateWithDuration:0.4f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^(){
            
            CGRect frame = middleView.frame;
            frame.size.height += upDownHeight;
            middleView.frame = frame;
            
            CGRect frame2 = scrollview.frame;
            frame2.origin.y += upDownHeight;
            
            if (self.isLiveVideoType == NO) {
                frame2.size.height -= upDownHeight;
                scrollview.frame = frame2;
                self.dirct_seeding.height -= upDownHeight;
                self.dirct_seeding.directtableview.height -= upDownHeight;
            }else {
                scrollview.frame = frame2;
            }
            
            CGRect frame3 = leftAndRightView.frame;
            frame3.origin.y += upDownHeight;
            leftAndRightView.frame = frame3;
            
            _contentLableView.hidden = NO;
        } completion:nil];
    }else {
        // 展开的时候, 点击的时候闭合
        [upDownBtn setBackgroundImage:[UIImage imageNamed:@"icon-down"] forState:UIControlStateNormal];
        [upDownBtn setBackgroundImage:[UIImage imageNamed:@"icon-down"] forState:UIControlStateHighlighted];
        
        _isUp = YES;
        [UIView animateWithDuration:0.4f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^(){
            
            CGRect frame = middleView.frame;
            frame.size.height -= upDownHeight;
            middleView.frame = frame;
            XYLog(@"%f",self.contentLableHeight);
            
            CGRect frame2 = scrollview.frame;
            frame2.origin.y -= upDownHeight;
            if (self.isLiveVideoType == NO) {
                frame2.size.height += upDownHeight;
                scrollview.frame = frame2;
                self.dirct_seeding.height += upDownHeight;
                self.dirct_seeding.directtableview.height += upDownHeight;
            }else {
                scrollview.frame = frame2;
            }
            
            CGRect frame3 = leftAndRightView.frame;
            frame3.origin.y -= upDownHeight;
            leftAndRightView.frame = frame3;
            
            _contentLableView.hidden = YES;
        } completion:nil];
    }
    XYLog(@"%@",NSStringFromCGRect(scrollview.frame));
}

- (void)headLeftBtn:(UIButton *)btn{
    if (!btn.isSelected) {
        btn.selected = !btn.isSelected;
        self.rightBtn.selected = !self.rightBtn.isSelected;
        rightbottomBorder.hidden = YES;
        leftbottomBorder.hidden = NO;
        [UIView animateWithDuration:0.3 animations:^{
            self.scrollview.contentOffset = CGPointMake(0, 0);
        }];
    }else {
        XYLog(@"回到顶部");
        [self.dirct_seeding.directtableview setContentOffset:CGPointMake(0, 0) animated:YES];
    }
}
- (void)headRightBtn:(UIButton *)btn{
    if (!btn.isSelected) {
        btn.selected = !btn.isSelected;
        self.leftBtn.selected = !self.leftBtn.isSelected;
        rightbottomBorder.hidden = NO;
        leftbottomBorder.hidden = YES;
        [UIView animateWithDuration:0.3 animations:^{
            self.scrollview.contentOffset = CGPointMake(kSWidth, 0);
        }];
    }else {
        
        [comment.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadCommentTableViewDate" object:nil];
////        comment.reloading = YES;
        [comment.refreshHeaderView egoRefreshScrollViewDidScroll:self.scrollview];
////        [comment.tableView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
////        [comment.refreshHeaderView setState:EGOOPullRefreshNormal];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.scrollview) {
        
        if (isBack == YES)
        {
            if (scrollView.contentOffset.x <0) {
                [self goBackBack];
            }
        }
        self.currentIndex = self.scrollview.contentOffset.x /self.scrollview.bounds.size.width;
        //计算页码
        CGFloat scrollViewW = kSWidth;
        CGFloat x = scrollView.contentOffset.x;
        _currentIndex = (x + scrollViewW / 2) / scrollViewW;
        if (!_currentIndex) {
            self.leftBtn.selected = YES;
            self.rightBtn.selected = NO;
            self.leftbottomBorder.hidden = NO;
            self.rightbottomBorder.hidden = YES;
        }else{
            self.rightBtn.selected = YES;
            self.leftBtn.selected = NO;
            self.rightbottomBorder.hidden = NO;
            self.leftbottomBorder.hidden = YES;
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (scrollView.contentOffset.x == kSWidth) {
        isBack = NO;
    }else {
        isBack = YES;
    }
}

-(void)creatUIdetails {
    
    //正在直播
    self.dirct_seeding = [[SeeDirectView alloc] initWithFrame:CGRectMake(0,0, kSWidth,self.scrollview.frame.size.height)];
    self.dirct_seeding.backgroundColor = [UIColor colorWithRed:0xED/255.0 green:0xED/255.0 blue:0xED/255.0 alpha:1];
    self.dirct_seeding.article = self.seeArticle;
    self.dirct_seeding.fileid = self.seeArticle.linkID;
    self.dirct_seeding.aid = self.seeArticle.fileId;
    self.dirct_seeding.articleType = self.seeArticle.articleType; //图文?视频?
    self.dirct_seeding.backgroundColor = [UIColor redColor];
    __weak typeof(self) weakSelf = self;
    self.dirct_seeding.playerButtonClickedBlock = ^(NSURL *urlStr) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        //创建视频播放器的控制器
        strongSelf.moviePlayer = [[MPMoviePlayerViewController alloc]initWithContentURL:urlStr];
        //播放的是普通的视频
        strongSelf.moviePlayer.moviePlayer.movieSourceType = MPMovieSourceTypeFile;
        //播放
        [strongSelf.moviePlayer.moviePlayer play];
        
        [strongSelf presentMoviePlayerViewControllerAnimated:strongSelf.moviePlayer];
    };
    [self.dirct_seeding creatDirect];
    [self.scrollview addSubview:self.dirct_seeding];

    // 聊天室
    comment = [[GreatestCommentPageController alloc] init];
    //直播稿件的id是它的linkID
    comment.isSeeRoot = 1;
    comment.article = self.seeArticle;
    comment.isLiveVideoType = self.isLiveVideoType;
    comment.view.frame = CGRectMake(kSWidth, -20, kSWidth,self.scrollview.frame.size.height + 60);
    comment.view.height = self.scrollview.height;
    comment.tableView.height = self.scrollview.height;
    [comment loadComments:YES];
    [self.scrollview addSubview:comment.view];
    [self addChildViewController:comment];
    
}

- (void)goBackBack
{
    if(self.navigationController && self.navigationController.viewControllers[0] != self){
        [self.navigationController popViewControllerAnimated:YES];
    }
    else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)addFootView
{
    footView = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.bounds.size.height-kTabBarHeight, kSWidth, kTabBarHeight)];
    footView.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1];
    
    UIView *topview = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kSWidth, 0.4)];
    if (IS_IPHONE_6P) {
        topview.frame = CGRectMake(0, 0, kSWidth, 0.6);
    }
    topview.alpha = 0.6;
    topview.backgroundColor = [UIColor grayColor];
    [footView addSubview:topview];
    
    UIButton *backBtn = [[UIButton alloc]initWithFrame:CGRectZero];
    
    UIButton *bg = [UIButton buttonWithType:UIButtonTypeCustom];
    [bg setImage:[UIImage imageNamed:@"commentBtn"] forState:UIControlStateNormal];
    if (IS_IPHONE_6)
    {
        backBtn.frame = CGRectMake(5, 12, 25, 25);
        bg.frame = CGRectMake(32, 8, 290, 30);
        
    }else if (IS_IPHONE_6P)
    {
        backBtn.frame = CGRectMake(5, 12, 25, 25);
        bg.frame = CGRectMake(34, 9, 330, 30);
        [bg setImage:[UIImage imageNamed:@"ditect_write6p"] forState:UIControlStateNormal];
        
    }else
    {
        backBtn.frame = CGRectMake(5, 12, 25, 25);
        bg.frame = CGRectMake(30, 8, 240, 30);
    }
    
    [backBtn setImage:[UIImage imageNamed:@"btn-comment-back"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backClick1:) forControlEvents:UIControlEventTouchUpInside];
    [bg addTarget:self action:@selector(commentItemClicked:) forControlEvents:UIControlEventTouchUpInside];
    UIButton *shareBtn = [SeeMethod newButtonWithFrame:CGRectMake(kSWidth-43, 8, 32, 32) type:UIButtonTypeSystem title:nil target:self UIImage:@"toolbar_share_new" andAction:@selector(shareClick)];
    [footView addSubview:backBtn];
    [footView addSubview:shareBtn];
    [footView addSubview:bg];
    [self.view addSubview:footView];
}

- (void)backClick1:(UIButton *)btn{
//    在聊天室的时候,返回到直播列表
//    if (self.scrollview.contentOffset.x == 0) {
//        [self goBackBack];
//    }else{
//        self.scrollview.contentOffset = CGPointMake(0, 0);
//        leftbottomBorder.hidden = NO;
//        rightbottomBorder.hidden = YES;
//    }
    // 直接返回到稿件列表
    [self goBackBack];
}

- (void)commentItemClicked:(id)sender
{
    self.scrollview.contentOffset = CGPointMake(kSWidth, 0);
    
    [comment writeComment];
    
}

- (void)shareClick{
    
    [self.dirct_seeding shareAllButtonClickHandler:nil];
    
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _liveTopView.durationTimer = nil;
    [_liveTopView.durationTimer invalidate];
}


@end
