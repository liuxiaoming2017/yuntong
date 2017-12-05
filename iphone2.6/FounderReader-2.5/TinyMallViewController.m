//
//  TinyMallViewController.m
//  FounderReader-2.5
//
//  Created by Julian on 2016/11/7.
//
//

#import "TinyMallViewController.h"
#import "YZSDK.h"
#import "TinyMallUser.h"
#import "YXLoginViewController.h"
#import "PersonalCenterViewController.h"
#import "CDRTranslucentSideBar.h"
#import "EGORefreshTableHeaderView.h"
#import "UIDevice-Reachability.h"
#import "UIWebView+ShareURLCheck.h"
#import "AppStartInfo.h"

//返回参数函数处理
static NSString *YZLoginNotice = @"check_login";
static NSString *YZShareNotice = @"share_data";
static NSString *YZWebReady = @"web_ready";

//分享相关参数
static NSString *SHARE_TITLE = @"title";
static NSString *SHARE_LINK = @"link";
static NSString *SHARE_IMAGE_URL = @"img_url";
static NSString *SHARE_DESC = @"desc";

@interface TinyMallViewController ()<UIWebViewDelegate,CDRTranslucentSideBarDelegate, EGORefreshTableHeaderDelegate, UIScrollViewDelegate>
{
    UIBarButtonItem *_userCenterBarButtonItem;
    UIBarButtonItem *_backBarButtonItem;
    UIBarButtonItem *_dismissBarButtonItem;
    NSString *_currentUrlStr;
}
@property(nonatomic,retain)  PersonalCenterViewController *leftController;
@property (nonatomic, retain) CDRTranslucentSideBar *sideBar;
@property (strong, nonatomic) UIWebView *webView;

@property (strong, nonatomic) EGORefreshTableHeaderView *refreshHeaderView;
@property (assign, nonatomic) BOOL reloading;

@end

@implementation TinyMallViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.viewControllerType == FDViewControllerForCloumnVC) {
       [self.navigationController setNavigationBarHidden:YES animated:YES];
    }else{
     [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    
    // 可以先浏览商城必要时再登录
    self.needLogin = NO;
    
    //self.navigationItem.rightBarButtonItem.enabled = NO;//默认分享按钮不可用
    
    //加载链接
    if (self.isFromLeftMenu) {
        [self loginAndloadUrl:[AppConfig sharedAppConfig].kYouZanLoadUrl];
    }else {
        [self loginAndloadUrl:parentColumn.linkUrl];
    }
}

- (void)leftAndRightButton
{
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)recognizer {
    
    [self.leftController downLoadMyScore];
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

- (void)left
{
    [self.leftController downLoadMyScore];
    [self.sideBar show];
}
- (void)setupUI {
    
    [self setupNav];
    NSInteger onlyOne = [[[NSUserDefaults standardUserDefaults] objectForKey:@"onlyOne"] integerValue];
    if (onlyOne == 2 && ![AppStartInfo sharedAppStartInfo].ucTabisShow){
        self.tabBarController.tabBar.hidden = YES;
    }
    //由于添加下拉刷新控件造成scrollView的contentInset计算错误
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, kSWidth, kSHeight - kNavBarHeight - (_isFromLeftMenu||onlyOne ? 0 : kTabBarHeight))];
    [self.view addSubview:self.webView];
    self.webView.delegate = self;
    self.webView.backgroundColor = [UIColor whiteColor];
    [self setupRefreshView];
}

- (void)setupRefreshView {
    self.refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - 80 - 20.f, kSWidth, 80)];
    self.refreshHeaderView.delegate = self;
    [self.webView.scrollView addSubview:self.refreshHeaderView];
    self.webView.scrollView.delegate = self;
    [self.refreshHeaderView refreshLastUpdatedDate];
}

- (void)setupNav
{
    [self titleLableWithTitle:NSLocalizedString(@"正在加载...",nil)];
    
    [self initLeftVC];
    
    [self initBarButtonItem];
    
    if (self.isFromLeftMenu) {
        self.navigationItem.leftBarButtonItem = _dismissBarButtonItem;
    }else {
        if (![AppStartInfo sharedAppStartInfo].ucTabisShow) {
            self.navigationItem.leftBarButtonItem = _userCenterBarButtonItem;
        }
    }
    
    [self.navigationController.navigationBar setBackgroundImage:[Global navigationImage] forBarMetrics:UIBarMetricsDefault];
    //去掉NavigationBar底部的那条黑线
    self.navigationController.navigationBar.barStyle = UIBaselineAdjustmentNone;
}

- (void)initLeftVC
{
    self.leftController = [[PersonalCenterViewController alloc] init];
    self.leftController.view.frame = CGRectMake(0, 0, 240, self.view.bounds.size.height+64);
    
    self.sideBar = [[CDRTranslucentSideBar alloc] init];
    self.sideBar.sideBarWidth = self.view.bounds.size.width * 0.5;
    self.sideBar.view.frame = CGRectMake(0, 0,self.view.bounds.size.width * 0.5, self.view.bounds.size.height);
    [self.sideBar setContentViewInSideBar:self.leftController.view];
    self.sideBar.delegate = self;
    self.leftController.sideBar = self.sideBar;
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    if (![AppStartInfo sharedAppStartInfo].ucTabisShow && self.viewControllerType == FDViewControllerForTabbarVC) {
        [self.view addGestureRecognizer:panGestureRecognizer];
    }
}

- (void)initBarButtonItem {
    
    UIButton *userCenterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [userCenterButton setImage:[UIImage imageNamed:@"icon-head"] forState:UIControlStateNormal];
    [userCenterButton sizeToFit];
    userCenterButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    userCenterButton.contentEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
    
    [userCenterButton addTarget:self action:@selector(left) forControlEvents:UIControlEventTouchUpInside];
    _userCenterBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:userCenterButton];
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:[UIImage imageNamed:@"nav_bar_back"] forState:UIControlStateNormal];
    [backButton sizeToFit];
    backButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    backButton.contentEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
    
    [backButton addTarget:self action:@selector(navigationShouldPopOnBackButton) forControlEvents:UIControlEventTouchUpInside];
    _backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    UIButton *dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [dismissButton setImage:[UIImage imageNamed:@"nav_bar_back"] forState:UIControlStateNormal];
    [dismissButton sizeToFit];
    dismissButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    dismissButton.contentEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
    
    [dismissButton addTarget:self action:@selector(dismissBack) forControlEvents:UIControlEventTouchUpInside];
    _dismissBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:dismissButton];
    
    //初始化分享按钮
//    UIBarButtonItem *shareButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"分享" style:UIBarButtonItemStylePlain target:self action:@selector(shareButtonItemAction)];
//    self.navigationItem.rightBarButtonItem = shareButtonItem;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"icon-refresh"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(refreshWebView)];
}

- (void)refreshWebView {
    [self.webView reload];
}

- (BOOL)navigationShouldPopOnBackButton {
    if ([self.webView canGoBack]) {
        [self.webView goBack];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    return NO;
}

- (void)dismissBack
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - YouzanSDK Method

/**
 *  通知有赞网页 开始初始化环境
 */
- (void)initYouzanSDK {
    [self.webView stringByEvaluatingJavaScriptFromString:[[YZSDK sharedInstance] jsBridgeWhenWebDidLoad]];
}

/**
 *  触发分享功能
 */
- (void)shareButtonItemAction {
    NSString *jsonString = [[YZSDK sharedInstance] jsBridgeWhenShareBtnClick];
    [self.webView stringByEvaluatingJavaScriptFromString:jsonString];
}

/**
 *  解析分享数据
 *
 *  @param data
 */
- (void)parseShareData:(NSURL *)data {
    NSDictionary *shareDic = [[YZSDK sharedInstance] shareDataInfo:data];
    NSString *message = [NSString stringWithFormat:@"%@\r%@" , shareDic[SHARE_TITLE],shareDic[SHARE_LINK]];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"数据已经复制到黏贴版" message:message delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil];
    [alertView show];
    //复制到粘贴板
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = message;
}

/**
 *  加载链接。
 *
 *  @remark 这里强制先登录再加载链接，你的工程里由你控制。
 *  @param urlString 链接
 */
- (void)loginAndloadUrl:(NSString*)urlString {
    
    _currentUrlStr = urlString;
    
    // 判断是否需要先登录才能浏览商城
    if (!self.needLogin) {
        [self loadWithString:urlString];
        return;
    }
    
    TinyMallUser *model = [TinyMallUser sharedManage];
    if(![NSString isNilOrEmpty:[model userId]]){
        // 判断是否已经登录过有赞商城
        if(!model.isLogined) {
            [self registerYZUser:model Url:urlString];
        } else {
            [self loadWithString:urlString];
        }
    }else {
        YXLoginViewController *controller = [[YXLoginViewController alloc] init];
        [controller rightPageNavTopButtons];
        controller.loginSuccessBlock = ^(){
            [self registerYZUser:model Url:urlString];
        };
        controller.loginFailedBlock = ^(YXLoginViewController *loginSelf){
        };
        [self presentViewController:[Global controllerToNav:controller] animated:YES completion:nil];
    }
}

- (void)registerYZUser:(TinyMallUser *)model Url:(NSString*)urlString
{
    YZUserModel *userModel = [TinyMallUser modelWithUser:model];
    [YZSDK registerYZUser:userModel callBack:^(NSString *message, BOOL isError) {
        if(!isError) {
            model.isLogined = YES;
            [self loadWithString:urlString];
        } else {
            model.isLogined = NO;
        }
    }];
}

/**
 *  收到网页通知需要买家登录
 *
 *  @remark 这里页面已经展示，收到网页通知，最后实现登录。
 *  @param model 买家信息
 */
- (void)loginWhenReceiveNoticeWithModel:(YZUserModel *)model {
    NSString *string = [[YZSDK sharedInstance] webUserInfoLogin:model];
    [self.webView stringByEvaluatingJavaScriptFromString:string];
}

#pragma mark - UIWebView Delegate

- (void)webViewDidStartLoad:(UIWebView *)webView {
    _reloading = YES;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    _currentUrlStr = [[webView.request URL] absoluteString];
    self.navigationItem.title = @"载入中...";
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    _reloading = NO;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    _currentUrlStr = [[webView.request URL] absoluteString];
    if (self.isFromLeftMenu) {
        [self titleLableWithTitle:self.mallTitle];
    }else {
        [self titleLableWithTitle:parentColumn.columnName];
    }
    if (!([self.webView canGoBack] || self.isFromLeftMenu)) {
        if (![AppStartInfo sharedAppStartInfo].ucTabisShow) {
            self.navigationItem.leftBarButtonItem = _userCenterBarButtonItem;
        }
    }
    if (!webView.isLoading) {
        [self.refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.webView.scrollView];
    }
    self.navigationItem.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    [self initYouzanSDK];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    _reloading = YES;
    NSLog(@"%s:%@。",__FUNCTION__,error.localizedDescription);
    _currentUrlStr = [[webView.request URL] absoluteString];
    //如果为主链接加载失败,显示刷新界面,停止下拉刷新
    NSString *currentURL = [error.userInfo objectForKey:@"NSErrorFailingURLKey"];
    NSString *mainURL = webView.request.URL.absoluteString;
    if (![UIDevice networkAvailable] || !mainURL.length || [mainURL isEqualToString:currentURL]) {
        [Global showWebErrorView:self];
        [self.refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.webView.scrollView];
    }
    if (!([self.webView canGoBack] || self.isFromLeftMenu)) {
        if (![AppStartInfo sharedAppStartInfo].ucTabisShow) {
            self.navigationItem.leftBarButtonItem = _userCenterBarButtonItem;
        }
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (![UIWebView checkShareURLWithRequest:request navigationType:navigationType WebView:self.webView]) {
        return NO;
    }
    _currentUrlStr = [[webView.request URL] absoluteString];
    NSURL *url = [request URL];
    NSLog(@"%s:%@。",__FUNCTION__,[url absoluteString]);
    
    if(![[url absoluteString] hasPrefix:@"http"]){ // 有赞的本地通知基本都在这处理。
        
        NSString *noticeKeyFromYouzan = [[YZSDK sharedInstance] parseYOUZANScheme:url];
        /* 需要登录 */
        if([noticeKeyFromYouzan isEqualToString:YZLoginNotice]) {
            if (![NSString isNilOrEmpty:[Global userId]]) {
                [self loginYouZan];
            }else {
                YXLoginViewController *controller = [[YXLoginViewController alloc]init];
                [controller rightPageNavTopButtons];
                controller.loginSuccessBlock = ^(){
                    [self loginYouZan];
                };
                controller.loginFailedBlock = ^(YXLoginViewController *loginSelf){
                    if ([webView canGoBack]) {
                        [webView goBack];
                    }
                };
                [self presentViewController:[Global controllerToNav:controller] animated:YES completion:nil];
            }
            return NO;
        } else if([noticeKeyFromYouzan isEqualToString:YZShareNotice]) {//分享
//            [self parseShareData:url];
            return NO;
        } else if([noticeKeyFromYouzan isEqualToString:YZWebReady]) {//有赞环境初始化成功，分享按钮可用
            //self.navigationItem.rightBarButtonItem.enabled = YES;
            return NO;
        }
        return YES;
    }
    
    if([[url absoluteString] containsString:@"homepage"]) {
        if (self.isFromLeftMenu) {
            self.navigationItem.leftBarButtonItem = _dismissBarButtonItem;
        }else {
            if (![AppStartInfo sharedAppStartInfo].ucTabisShow) {
                self.navigationItem.leftBarButtonItem = _userCenterBarButtonItem;
            }
        }
    }else {
        self.navigationItem.leftBarButtonItem = _backBarButtonItem;
    }
    
    //加载新链接时，分享按钮先置为不可用，直到有赞环境初始化成功方可使用
    //self.navigationItem.rightBarButtonItem.enabled = NO;
    
    return YES;    
}

- (void)onWebError:(id)sender{
    [Global hideWebErrorView:self];
    if ([NSString isNilOrEmpty:_currentUrlStr]) {
        _currentUrlStr = self.isFromLeftMenu ? [AppConfig sharedAppConfig].kYouZanLoadUrl : parentColumn.linkUrl;
    }
    [self loadWithString:_currentUrlStr];
}

- (void)loginYouZan
{
    TinyMallUser *model = [TinyMallUser sharedManage];
    YZUserModel *userModel = [TinyMallUser modelWithUser:model];
    [self loginWhenReceiveNoticeWithModel:userModel];
}

#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    
    [self.webView reload];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
    
    return _reloading; // should return if data source model is reloading
    
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
    
    return [NSDate date]; // should return date data source was last changed
}


#pragma mark - Action

- (void)closeItemBarButtonAction {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Private Method

- (void)loadWithString:(NSString *)urlStr {
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:urlRequest];
}



@end
