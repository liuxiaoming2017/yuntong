//
//  CreditWebViewController.m
//  dui88-iOS-sdk
//
//  Created by xuhengfei on 14-5-16.
//  Copyright (c) 2014年 cpp. All rights reserved.
//

#import "CreditMenuViewController.h"
#import "CreditWebView.h"
#import "CreditConstant.h"
#import "YXLoginViewController.h"
#import "AESCrypt.h"
#import "CreditSecondViewController.h"
#import "PersonalCenterViewController.h"
#import "CDRTranslucentSideBar.h"
#import "ColumnBarConfig.h"
#import "NJWebPageController.h"
#import "shareCustomView.h"
#import "ColorStyleConfig.h"
#import "UIDevice-Reachability.h"
#import "UIWebView+ShareURLCheck.h"
#import "AppStartInfo.h"

@interface CreditMenuViewController ()<UIWebViewDelegate,CDRTranslucentSideBarDelegate>
    
@property(nonatomic,strong) NSURLRequest *request;
@property(nonatomic,strong) CreditWebView *webView;
@property(nonatomic,strong) NSString *shareUrl;
@property(nonatomic,strong) NSString *shareTitle;
@property(nonatomic,strong) NSString *shareSubtitle;
@property(nonatomic,strong) NSString *shareThumbnail;
@property (nonatomic, strong) NSDictionary *loginData;
@property(nonatomic,strong) UIBarButtonItem *shareButton;
@property(nonatomic,retain)  PersonalCenterViewController *leftController;
@property (nonatomic, retain) CDRTranslucentSideBar *sideBar;
@property(nonatomic,strong) UIActivityIndicatorView *activity;

@end

static BOOL byPresent = NO;
static UINavigationController *navController;
static NSString *originUserAgent;
@implementation CreditMenuViewController


-(id)initWithUrl:(NSString *)url{
    self=[super init];
    self.request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    return self;
}

-(id)initWithUrlByPresent:(NSString *)url{
    self.navigationItem.rightBarButtonItem = nil;
    self=[self initWithUrl:url];
    
    
    byPresent=YES;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(shouldNewOpen:) name:@"dbnewopen" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(shouldBackRefresh:) name:@"dbbackrefresh" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(shouldBack:) name:@"dbback" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(shouldBackRoot:) name:@"dbbackroot" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(shouldBackRootRefresh:) name:@"dbbackrootrefresh" object:nil];
    
    return self;
}
-(id)initWithRequest:(NSURLRequest *)request{
    self=[super init];
    self.request=request;
    
       
    return self;
}
-(void)dismissFirst
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)dismiss
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

-(void)viewWillDisappear:(BOOL)animated{
    [[NSUserDefaults standardUserDefaults]registerDefaults:@{@"UserAgent":originUserAgent}];
}
-(void)viewWillAppear:(BOOL)animated{
    
    self.tabBarController.tabBar.hidden = NO;
    NSString *duibaForeground = [[NSUserDefaults standardUserDefaults] objectForKey:@"duiba-foreground"];
    if ([duibaForeground isEqualToString:@"true"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"duiba-load-WebView" object:self userInfo:nil];
    }
    [[NSUserDefaults standardUserDefaults] setObject:@"false" forKey:@"duiba-foreground"];
    //添加分享按钮的监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDuibaShareClick:) name:@"duiba-share-click" object:nil];
    //添加对兑换页面登录按钮的监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDuibaLoginClick:) name:@"duiba-login-click" object:nil];
    //添加对兑换页面登录成功重新加载页面的监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDuibareloadWeb) name:@"duiba-load-WebView" object:nil];
    if(originUserAgent==nil){
        UIWebView* webView = [[UIWebView alloc] initWithFrame:CGRectZero];
        originUserAgent = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    }
    NSString *ua = [originUserAgent stringByAppendingFormat:@" Duiba/%@",DUIBA_VERSION];
    [[NSUserDefaults standardUserDefaults]registerDefaults:@{@"UserAgent":ua}];
    if (self.viewControllerType == FDViewControllerForCloumnVC) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }else{
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
}

-(void)showLoginPage
{
    YXLoginViewController *controller = [[YXLoginViewController alloc]init];
    [controller rightPageNavTopButtons];
    [self presentViewController:[Global controllerToNav:controller] animated:YES completion:nil];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
}

-(void)onDuibaShareClick:(NSNotification *)notify{
    NSDictionary *dict=notify.userInfo;
    NSString *shareUrl=[dict objectForKey:@"shareUrl"];//分享url
    NSString *shareTitle=[dict objectForKey:@"shareTitle"];//标题
    NSString *shareThumbnail=[dict objectForKey:@"shareThumbnail"];//缩略图
    //NSString *shareSubTitle=[dict objectForKey:@"shareSubtitle"];//副标题
    NSString *shareContent = [NSString stringWithFormat:@"我在%@发现了一个不错的商品，进来看看哦～", appName()];
    [shareCustomView shareWithContent:shareContent image:shareThumbnail title:shareTitle url:shareUrl type:0 completion:^(NSString *resultJson){
        [self.webView performSelectorOnMainThread:@selector(giveResultWithWebView:) withObject:@{@"webView":self.webView, @"resultJson":resultJson} waitUntilDone:NO];
    }];
}

//当兑吧页面内点击登录时，会调用此处函数
//请在此处弹出登录层，进行登录处理
//登录成功后，请从dict拿到当前页面currentUrl
//让服务器端重新生成一次自动登录地址，并附带redirect=currentUrl参数
//使用新生成的自动登录地址，让webView重新进行一次加载
-(void)onDuibaLoginClick:(NSNotification *)notify{
    self.loginData=notify.userInfo;
    if (![Global userId].length) {
        [self showLoginPage];
        return;
    }
}

-(void)onDuibareloadWeb
{
    NSString *url = nil;
    if ([Global userId].length)
    {
        if ([self.loginData objectForKey:@"currentUrl"] != nil && ![[self.loginData objectForKey:@"currentUrl"] isEqualToString:@""]) {
            url = [NSString stringWithFormat:@"%@/api/getMall?sid=%@&uid=%@&redirect=%@",[AppConfig sharedAppConfig].serverIf,[AppConfig sharedAppConfig].sid,[Global userId],[self.loginData objectForKey:@"currentUrl"]];
        }
        else
        {
            url = [NSString stringWithFormat:@"%@/api/getMall?sid=%@&uid=%@",[AppConfig sharedAppConfig].serverIf,[AppConfig sharedAppConfig].sid,[Global userId]];
        }
    }
    else
    {
        url = [NSString stringWithFormat:@"%@/api/getMall?sid=%@",[AppConfig sharedAppConfig].serverIf,[AppConfig sharedAppConfig].sid];
    }
    HttpRequest *request = [HttpRequest requestWithURLCache:[NSURL URLWithString:url]];
    [request setCompletionBlock:^(id data) {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers 
                                                              error:nil];
        if ([[dic objectForKey:@"success"] boolValue]) {
            NSString *mallUrl = [dic objectForKey:@"mallUrl"];
            NSString *decryptUrl = [AESCrypt decrypt:mallUrl password:key];
            [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:decryptUrl]]];
        }
        else
        {
            XYLog(@"%@",[dic objectForKey:@"msg"]);
        }
    }];
    [request setFailedBlock:^(NSError *error) {
        [Global showWebErrorView:self];
    }];
    [request startAsynchronous];
}
- (void)leftAndRightButton
{
    UIImage * image = nil;
    if (self.viewControllerType == FDViewControllerForDetailVC) {
        image =[UIImage imageNamed:@"nav_bar_back"];
    }else{
        image =[UIImage imageNamed:@"icon-head"];
    }
    if (![AppStartInfo sharedAppStartInfo].ucTabisShow || self.viewControllerType == FDViewControllerForDetailVC) {
        
        UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [leftButton setImage:image forState:UIControlStateNormal];
        [leftButton sizeToFit];
        leftButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        leftButton.contentEdgeInsets = UIEdgeInsetsMake(0, -6, 0, 0);
        
        [leftButton addTarget:self action:@selector(left) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
        self.navigationItem.leftBarButtonItem = leftItem;
    }
    
    
    //增加右上角的积分规则和积分排行
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 40)];
    UIButton *rightButton1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightButton1 setImage:[UIImage imageNamed:@"icon-scoreRank"] forState:UIControlStateNormal];
    //[rightButton1 sizeToFit];
    rightButton1.frame = CGRectMake(0, 0, 40, 40);
    rightButton1.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    rightButton1.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -6);
    [rightButton1 addTarget:self action:@selector(scoreRank) forControlEvents:UIControlEventTouchUpInside];
    [rightView addSubview:rightButton1];
    UIButton *rightButton2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightButton2 setImage:[UIImage imageNamed:@"icon-integralRule"] forState:UIControlStateNormal];
    //[rightButton2 sizeToFit];
    rightButton2.frame = CGRectMake(40, 0, 40, 40);
    rightButton2.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    rightButton2.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -6);
    [rightButton2 addTarget:self action:@selector(integralRule) forControlEvents:UIControlEventTouchUpInside];
    [rightView addSubview:rightButton2];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightView];
    [self.navigationItem setRightBarButtonItem:rightItem];
    
    
    [self.navigationController.navigationBar setBackgroundImage:[Global navigationImage] forBarMetrics:UIBarMetricsDefault];
    //去掉NavigationBar底部的那条黑线
    self.navigationController.navigationBar.barStyle = UIBaselineAdjustmentNone;
}


//点击积分排行
- (void)scoreRank
{
    if (![Global userId].length) {
        YXLoginViewController *controller = [[YXLoginViewController alloc]init];
        [controller rightPageNavTopButtons];
        controller.loginSuccessBlock = ^(){
            [self showScoreRank];
        };
        [self presentViewController:[Global controllerToNav:controller] animated:YES completion:nil];
        return;
    }
    [self showScoreRank];
}
//显示积分排行页面
-(void)showScoreRank{
    NJWebPageController * controller = [[NJWebPageController alloc] init];
    Column *one = [[Column alloc] init];
    
    one.linkUrl = [NSString stringWithFormat:@"%@/myScore?sc=%@&uid=%@",[AppConfig sharedAppConfig].serverIf, [AppConfig sharedAppConfig].sid, [Global userId]];
    one.columnName = [NSString stringWithFormat:@"我的%@", [AppConfig sharedAppConfig].integralName];
    controller.parentColumn = one;
    controller.isFromModal = YES;
    [self presentViewController:[Global controllerToNav:controller] animated:YES completion:nil];
}

- (void)integralRule
{
    NJWebPageController *controller = [[NJWebPageController alloc] init];
    Column *column = [[Column alloc] init];
    column.linkUrl = [NSString stringWithFormat:@"%@/uc/ruleDefine?sid=%@",[AppConfig sharedAppConfig].serverIf, [AppConfig sharedAppConfig].sid];
    column.columnName = [NSString stringWithFormat:@"%@规则", [AppConfig sharedAppConfig].integralName];
    controller.parentColumn = column;
    controller.hiddenClose = YES;
    [self presentViewController:[Global controllerToNav:controller] animated:YES completion:nil];
}
-(void)left
{
    if (self.viewControllerType == FDViewControllerForDetailVC) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    [self.leftController downLoadMyScore];
    [self.leftController updateUserInfo];
    [self.sideBar show];
    return;
}

- (void)viewDidLoad
{
    if(!byPresent && navController==nil){
        navController=self.navigationController;
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(shouldNewOpen:) name:@"dbnewopen" object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(shouldBackRefresh:) name:@"dbbackrefresh" object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(shouldBack:) name:@"dbback" object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(shouldBackRoot:) name:@"dbbackroot" object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(shouldBackRootRefresh:) name:@"dbbackrootrefresh" object:nil];
    }
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(setRefreshCurrentUrl:) name:@"duiba-autologin-visit" object:nil];
    
    [super viewDidLoad];
	self.webView=[[CreditWebView alloc]initWithFrame:self.view.bounds andUrl:[[self.request URL] absoluteString]];
    [self.view addSubview:self.webView];
    [self.webView loadRequest:self.request];
    self.webView.webDelegate=self;
    self.webView.scrollView.delegate = self;
    
    UILabel *label = [[UILabel alloc] init];
    label.text = NSLocalizedString(@"正在加载...",nil);
    label.textColor = [ColorStyleConfig sharedColorStyleConfig].navbar_titlecolor_selected;
    label.frame = CGRectMake(0, 0, 100, 44);
    label.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = label;
    
    
    self.activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];//指定进度轮的大小
    [self.activity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    [self.activity hidesWhenStopped];
    [self.activity setCenter:self.view.center];//指定进度轮中心点
    
    [self.activity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];//设置进度轮显示类型
    self.activity.color=[UIColor blackColor];
    
    [self.view addSubview:self.activity];
    
    
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
    
    [self onDuibareloadWeb];
    
}
- (void)handlePanGesture:(UIPanGestureRecognizer *)recognizer {
    
    [self.leftController downLoadMyScore];
    [self.leftController updateUserInfo];
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

- (void)disnone
{
    return;
}


-(void)viewDidAppear:(BOOL)animated{

    self.webView.frame=self.view.bounds;
    if(self.needRefreshUrl!=nil){
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.needRefreshUrl]]];
        self.needRefreshUrl=nil;
    }
}


-(void)setRefreshCurrentUrl:(NSNotification*)notify{
    if([notify.userInfo objectForKey:@"webView"]!=self.webView){
        self.needRefreshUrl=self.webView.request.URL.absoluteString;
    }
}

-(void)refreshParentPage:(NSURLRequest *)request{
    [self.webView loadRequest:request];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    if(navController!=nil && !byPresent){
        NSInteger count=navController.viewControllers.count;
        BOOL containCredit=NO;
        for(int i=0;i<count;i++){
            UIViewController *vc=[navController.viewControllers objectAtIndex:i];
            if([vc isKindOfClass:[CreditMenuViewController class]]){
                containCredit=YES;
                break;
            }
        }
        if(!containCredit){
            navController=nil;
        }
    }
    
}
#pragma mark WebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (![UIWebView checkShareURLWithRequest:request navigationType:navigationType WebView:self.webView]) {
        return NO;
    }
    return YES;
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    //如果为主链接加载失败,显示错误视图
    NSString *currentURL = [error.userInfo objectForKey:@"NSErrorFailingURLKey"];
    NSString *mainURL = webView.request.URL.absoluteString;
    if (![UIDevice networkAvailable] || !mainURL.length || [mainURL isEqualToString:currentURL]) {
        [Global showWebErrorView:self];
        [self.activity stopAnimating];
    }
}

- (void)onWebError:(id)sender{
    [self onDuibareloadWeb];
    [Global hideWebErrorView:self];
}

-(void)webViewDidStartLoad:(UIWebView *)webView{
    [self.activity startAnimating];
    if (![UIDevice networkAvailable]) {
        [Global showWebErrorView:self];
        [self.activity stopAnimating];
    }
}
-(void)webViewDidFinishLoad:(UIWebView *)webView{
    
    UILabel *label = [[UILabel alloc] init];
    label.text = self.title;
    label.textColor = [ColorStyleConfig sharedColorStyleConfig].navbar_titlecolor_selected;
    label.frame = CGRectMake(0, 0, 100, 44);
    label.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = label;
    
    NSString *content=[webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('duiba-share-url').getAttribute('content');"];
    if(content.length>0){
        NSArray *d=[content componentsSeparatedByString:@"|"];
        if(d.count==4){
            self.shareUrl=[d objectAtIndex:0];
            self.shareThumbnail=[d objectAtIndex:1];
            self.shareTitle=[d objectAtIndex:2];
            self.shareSubtitle=[d objectAtIndex:3];
            
            if(self.shareButton==nil){
                self.shareButton=[[UIBarButtonItem alloc] initWithTitle:@"分享" style:UIBarButtonItemStylePlain target:self action:@selector(onShareClick)];
                self.shareButton.tintColor = [ColumnBarConfig sharedColumnBarConfig].column_all_color;
            }
            
            if(self.navigationItem.rightBarButtonItem==nil){
                self.navigationItem.rightBarButtonItem=self.shareButton;
            }
        }
    }else{
        if(self.shareButton!= nil && self.shareButton==self.navigationItem.rightBarButtonItem){
            self.navigationItem.rightBarButtonItem=nil;
        }
    }
    [self.activity stopAnimating];
}



-(void)onShareClick{
    NSMutableDictionary *dict=[NSMutableDictionary dictionary];
    [dict setObject:self.shareUrl forKey:@"shareUrl"];
    [dict setObject:self.shareThumbnail forKey:@"shareThumbnail"];
    [dict setObject:self.shareTitle forKey:@"shareTitle"];
    [dict setObject:self.shareSubtitle forKey:@"shareSubtitle"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"duiba-share-click" object:self userInfo:dict];
}

-(UINavigationController*)getNavCon{
    if(byPresent){
        return self.navigationController;
    }
    return navController;
}

#pragma mark 5 activite


-(void)shouldNewOpen:(NSNotification*)notification{

    CreditSecondViewController *controller = [[CreditSecondViewController alloc]initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[notification.userInfo objectForKey:@"url"]]]];
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:controller animated:YES];
}

-(void)shouldBackRefresh:(NSNotification*) notification{
    NSInteger count=[[self getNavCon].viewControllers count];
    
    
    if(count>1){
        CreditMenuViewController *second=[[self getNavCon].viewControllers objectAtIndex:count-2];
        second.needRefreshUrl=[notification.userInfo objectForKey:@"url"];
    }
    
    [[self getNavCon] popViewControllerAnimated:YES];
}
-(void)shouldBack:(NSNotification*)notification{
    [[self getNavCon] popViewControllerAnimated:YES];
}
-(void)shouldBackRoot:(NSNotification*)notification{
    NSInteger count=[self getNavCon].viewControllers.count;
    CreditMenuViewController *rootVC=nil;
    for(int i=0;i<count;i++){
        UIViewController *vc=[[self getNavCon].viewControllers objectAtIndex:i];
        if([vc isKindOfClass:[CreditMenuViewController class]]){
            rootVC=(CreditMenuViewController*)vc;
            break;
        }
    }
    if(rootVC!=nil){
        [[self getNavCon] popToViewController:rootVC animated:YES];
    }else{
        [[self getNavCon] popViewControllerAnimated:YES];
    }
}
-(void)shouldBackRootRefresh:(NSNotification*)notification{
    NSInteger count=[self getNavCon].viewControllers.count;
    CreditMenuViewController *rootVC=nil;
    for(int i=0;i<count;i++){
        UIViewController *vc=[[self getNavCon].viewControllers objectAtIndex:i];
        if([vc isKindOfClass:[CreditMenuViewController class]]){
            rootVC=(CreditMenuViewController*)vc;
            break;
        }
    }
    if(rootVC!=nil){
        rootVC.needRefreshUrl=[notification.userInfo objectForKey:@"url"];
        [[self getNavCon] popToViewController:rootVC animated:YES];
    }else{
        [[self getNavCon] popViewControllerAnimated:YES];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    float y = scrollView.contentOffset.y;
    if (y < -64) {
        [self onDuibareloadWeb];
    }
}
@end
 
