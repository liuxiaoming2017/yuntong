//
//  CreditWebViewController.m
//  dui88-iOS-sdk
//
//  Created by xuhengfei on 14-5-16.
//  Copyright (c) 2014年 cpp. All rights reserved.
//

#import "CreditSecondViewController.h"
#import "CreditWebView.h"
#import "CreditConstant.h"
#import "YXLoginViewController.h"
#import "AESCrypt.h"
#import "shareCustomView.h"
#import "ColumnBarConfig.h"
#import "ColorStyleConfig.h"
#import "UIDevice-Reachability.h"
#import "UIWebView+ShareURLCheck.h"

@interface CreditSecondViewController ()<UIWebViewDelegate>
    
@property(nonatomic,strong) NSURLRequest *request;
@property(nonatomic,strong) CreditWebView *webView;
@property(nonatomic,strong) NSString *shareUrl;
@property(nonatomic,strong) NSString *shareTitle;
@property(nonatomic,strong) NSString *shareSubtitle;
@property(nonatomic,strong) NSString *shareThumbnail;
@property (nonatomic, strong) NSDictionary *loginData;
@property(nonatomic,strong) UIBarButtonItem *shareButton;


@property(nonatomic,strong) UIActivityIndicatorView *activity;

@end

static BOOL byPresent=NO;
static UINavigationController *navController;
static NSString *originUserAgent;
@implementation CreditSecondViewController


-(id)initWithUrl:(NSString *)url{
    self=[super init];
    self.request=[NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    
    
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
    [self.tabBarController.tabBar setHidden:NO];
}
-(void)viewWillAppear:(BOOL)animated{
    
    [self.tabBarController.tabBar setHidden:YES];
    //添加分享按钮的监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDuibaShareClick:) name:@"duiba-share-click" object:nil];
    //添加登录按钮的监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDuibaLoginClick:) name:@"duiba-login-click" object:nil];
    //添加登录成功重新加载页面的监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDuibareloadWeb) name:@"duiba-load-WebView" object:nil];
    
    if(originUserAgent==nil){
        UIWebView* webView = [[UIWebView alloc] initWithFrame:CGRectZero];
        originUserAgent = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    }
    NSString *ua=[originUserAgent stringByAppendingFormat:@" Duiba/%@",DUIBA_VERSION];
    [[NSUserDefaults standardUserDefaults]registerDefaults:@{@"UserAgent":ua}];
}

-(void)showLoginPage
{
    YXLoginViewController *controller = [[YXLoginViewController alloc]init];
    [controller rightPageNavTopButtons];
    [self presentViewController:[Global controllerToNav:controller] animated:YES completion:nil];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 913) {
        
    }
}
-(void)onDuibaShareClick:(NSNotification *)notify{
    NSDictionary *dict=notify.userInfo;
    NSString *shareUrl=[dict objectForKey:@"shareUrl"];//分享url
    NSString *shareTitle=[dict objectForKey:@"shareTitle"];//标题
    NSString *shareThumbnail=[dict objectForKey:@"shareThumbnail"];//缩略图
    if (![shareThumbnail containsString:@"https"])
        shareThumbnail = [shareThumbnail containsString:@"http"] ? [shareThumbnail stringByReplacingOccurrencesOfString:@"https" withString:@"http"] : [NSString stringWithFormat:@"https:%@",shareThumbnail];
    NSString *shareContent = [NSString stringWithFormat:@"我在%@发现了一个不错的商品，进来看看哦～", appName()];
    //NSString *shareSubTitle=[dict objectForKey:@"shareSubtitle"];//副标题
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
    XYLog(@"currentUrl=%@",[self.loginData objectForKey:@"currentUrl"]);
}
-(void)onDuibareloadWeb
{
    if (![Global userId].length){
        return;
    }
    NSString *currentUrl = [self.loginData objectForKey:@"currentUrl"];
    if(currentUrl == nil){
        return;
    }
    
    NSString *url = [NSString stringWithFormat:@"%@/api/getMall?sid=%@&uid=%@&redirect=%@",[AppConfig sharedAppConfig].serverIf,[AppConfig sharedAppConfig].sid,[Global userId], currentUrl];
    
    HttpRequest *request = [HttpRequest requestWithURL:[NSURL URLWithString:url]];
    [request setCompletionBlock:^(id data) {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if ([[dic objectForKey:@"success"] boolValue]) {
            NSString *mallUrl = [dic objectForKey:@"mallUrl"];
            NSString *decryptUrl = [AESCrypt decrypt:mallUrl password:key];
            [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:decryptUrl]]];
        }
        else{
            XYLog(@"%@",[dic objectForKey:@"msg"]);
        }
    }];
    [request setFailedBlock:^(NSError *error) {
        XYLog(@"网络连接失败");
    }];
    [request startAsynchronous];
    XYLog(@"currentUrl=%@",[self.loginData objectForKey:@"currentUrl"]);
}
- (void)leftAndRightButton
{
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftButton setImage:[UIImage imageNamed:@"btn_return"] forState:UIControlStateNormal];
    [leftButton sizeToFit];
    leftButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    leftButton.contentEdgeInsets = UIEdgeInsetsMake(10, -10, 10, 30);
    
    [leftButton addTarget:self action:@selector(goBackIOS6) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    [self.navigationController.navigationBar setBackgroundImage:[Global navigationImage] forBarMetrics:UIBarMetricsDefault];
    //去掉NavigationBar底部的那条黑线
    self.navigationController.navigationBar.barStyle = UIBaselineAdjustmentNone;
}

-(void)goBackIOS6{
    
    NSArray *viewcontrollers = self.navigationController.viewControllers;
    if (viewcontrollers.count > 1) {
        if ([viewcontrollers objectAtIndex:viewcontrollers.count-1] == self) {
            //push方式
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    else{
        //present方式
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)viewDidLoad
{
    self.navigationItem.rightBarButtonItem = nil;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(setRefreshCurrentUrl:) name:@"duiba-autologin-visit" object:nil];
    
    [super viewDidLoad];
	self.webView=[[CreditWebView alloc]initWithFrame:CGRectMake(0, 0, kSWidth, kSHeight-64) andUrl:[[self.request URL] absoluteString]];
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
    
    self.tabBarController.hidesBottomBarWhenPushed = YES;
    
}
- (void)disnone
{
    return;
}

-(void)viewDidAppear:(BOOL)animated{
    
    //self.webView.frame=CGRectMake(0, 0, kSWidth, kSHeight-15);
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
            if([vc isKindOfClass:[CreditSecondViewController class]]){
                containCredit=YES;
                break;
            }
        }
        if(!containCredit){
            navController=nil;
        }
    }
    
}

- (void)onWebError:(id)sender{
    [self.webView loadRequest:self.request];
    [Global hideWebErrorView:self];
}

#pragma mark WebViewDelegate
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    //如果为主链接加载失败,显示错误视图
    NSString *currentURL = [error.userInfo objectForKey:@"NSErrorFailingURLKey"];
    NSString *mainURL = webView.request.URL.absoluteString;
    if (![UIDevice networkAvailable] || !mainURL.length || [mainURL isEqualToString:currentURL]) {
        [Global showWebErrorView:self];
        [self.activity stopAnimating];
    }
}
-(void)webViewDidStartLoad:(UIWebView *)webView{
    [self.activity startAnimating];
    if (![UIDevice networkAvailable]) {
        [Global showWebErrorView:self];
        [self.activity stopAnimating];
    }
}
-(void)webViewDidFinishLoad:(UIWebView *)webView{
    
    [self.activity stopAnimating];
    [Global hideWebErrorView:self];
    self.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    UILabel *label = [[UILabel alloc] init];
    label.text = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    label.textColor = [UIColor whiteColor];
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
     
    CreditSecondViewController *newvc=[[CreditSecondViewController alloc]initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[notification.userInfo objectForKey:@"url"]]]];
    [self.navigationController pushViewController:newvc animated:YES];
}
-(void)shouldBackRefresh:(NSNotification*) notification{
    NSInteger count=[[self getNavCon].viewControllers count];
    
    
    if(count>1){
        CreditSecondViewController *second=[[self getNavCon].viewControllers objectAtIndex:count-2];
        second.needRefreshUrl=[notification.userInfo objectForKey:@"url"];
    }
    
    [[self getNavCon] popViewControllerAnimated:YES];
}
-(void)shouldBack:(NSNotification*)notification{
    [[self getNavCon] dismissViewControllerAnimated:YES completion:nil];
}
-(void)shouldBackRoot:(NSNotification*)notification{
    NSInteger count=[self getNavCon].viewControllers.count;
    CreditSecondViewController *rootVC=nil;
    for(int i=0;i<count;i++){
        UIViewController *vc=[[self getNavCon].viewControllers objectAtIndex:i];
        if([vc isKindOfClass:[CreditSecondViewController class]]){
            rootVC=(CreditSecondViewController*)vc;
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
    CreditSecondViewController *rootVC=nil;
    for(int i=0;i<count;i++){
        UIViewController *vc=[[self getNavCon].viewControllers objectAtIndex:i];
        if([vc isKindOfClass:[CreditSecondViewController class]]){
            rootVC=(CreditSecondViewController*)vc;
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

@end
 
