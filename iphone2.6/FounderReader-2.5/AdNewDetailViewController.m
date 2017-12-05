//
//  AdNewDetailViewController.m
//  FounderReader-2.5
//
//  Created by wxq on 12-5-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AdNewDetailViewController.h"
#import "DataLib/DataLib.h"
#import "FileRequest.h"
#import "NSString+Helper.h"
#import "AppConfig.h"
#import "UIImage+Helper.h"
#import "shareCustomView.h"
#import "NJEventRequest.h"
#import "UIDevice-Reachability.h"
#import "RNCachingURLProtocol.h"
#import "UIWebView+ShareURLCheck.h"
#import "YXLoginViewController.h"
#import "UserAccountDefine.h"
#import "NSString+Helper.h"
@interface AdNewDetailViewController ()<UIGestureRecognizerDelegate,WKScriptMessageHandler, WKNavigationDelegate, WKUIDelegate>
{
    
}
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) UILabel *labelTop;
@property (nonatomic, assign) BOOL isCheckuserlogin;
@end

@implementation AdNewDetailViewController
@synthesize adArticle = _adArticle;
@synthesize imageFlag = _imageFlag;
@synthesize columnUrl = _columnUrl;
@synthesize webView = _webView;


- (id)init
{
    self = [super init];
    if (self) {

    }
    return self;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self.navigationController setNavigationBarHidden:YES];
    
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear: animated];
    
}
- (void)viewDidLoad {
    
    [super viewDidLoad];
    [NSURLProtocol registerClass:[RNCachingURLProtocol class]];

    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    
    // 设置偏好设置
    config.preferences = [[WKPreferences alloc] init];
    // 默认为0
    config.preferences.minimumFontSize = 10;
    // 默认认为YES
    config.preferences.javaScriptEnabled = YES;
    // 在iOS上默认为NO，表示不能自动通过窗口打开
    config.preferences.javaScriptCanOpenWindowsAutomatically = NO;
    
    // web内容处理池
    config.processPool = [[WKProcessPool alloc] init];
    
    // 通过JS与webview内容交互
    config.userContentController = [[WKUserContentController alloc] init];
    // 注入JS对象名称AppModel，当JS通过AppModel来调用时，
    // 我们可以在WKScriptMessageHandler代理中接收到
    [config.userContentController addScriptMessageHandler:self name:@"AppModel"];
    self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 20, kSWidth, kSHeight-20-49)
                                      configuration:config];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.adArticle.contentUrl]]];
    [self.view addSubview:self.webView];
    
    // 导航代理
    self.webView.navigationDelegate = self;
    // 与webview UI交互代理
    self.webView.UIDelegate = self;
    
    // 添加KVO监听
    [self.webView addObserver:self
                   forKeyPath:@"loading"
                      options:NSKeyValueObservingOptionNew
                      context:nil];
    [self.webView addObserver:self
                   forKeyPath:@"title"
                      options:NSKeyValueObservingOptionNew
                      context:nil];
    [self.webView addObserver:self
                   forKeyPath:@"estimatedProgress"
                      options:NSKeyValueObservingOptionNew
                      context:nil];
    
    // 添加进入条
    self.progressView = [[UIProgressView alloc] init];
    self.progressView.frame = CGRectMake(0, 20, kSWidth, kSHeight-20-49);
    self.progressView.progressTintColor = [UIColor redColor];//进度条颜色

    [self GetBack];
    
}
- (void)GetBack
{
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = nil;
    
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, kSHeight-49, kSWidth, 49)];
    footView.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1];
    UIView *topview = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kSWidth, 0.4)];
    if (IS_IPHONE_6P) {
        topview.frame = CGRectMake(0, 0, kSWidth, 0.6);
    }
    topview.alpha = 0.6;
    topview.backgroundColor = [UIColor grayColor];
    [footView addSubview:topview];
    
    UIButton *btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    btnBack.frame = CGRectMake(10, 4, 40, 40);
    [btnBack setImage:[UIImage imageNamed:@"toolbar_gd_back"] forState:UIControlStateNormal];
    [btnBack addTarget:self action:@selector(goBackPageBack) forControlEvents:UIControlEventTouchUpInside];
    [footView addSubview:btnBack];
    [footView bringSubviewToFront:btnBack];
    
    btnClose = [UIButton buttonWithType:UIButtonTypeCustom];
    btnClose.frame = CGRectMake(60, 4, 40, 40);
    [btnClose setImage:[UIImage imageNamed:@"btn_web_close"] forState:UIControlStateNormal];
    [btnClose addTarget:self action:@selector(closeView) forControlEvents:UIControlEventTouchUpInside];
    [footView addSubview:btnClose];
    [footView bringSubviewToFront:btnClose];
    
    UIButton *btnShare = [UIButton buttonWithType:UIButtonTypeCustom];
    btnShare.frame = CGRectMake(kSWidth - 50, 4, 40, 40);
    [btnShare setImage:[UIImage imageNamed:@"btn-share"] forState:UIControlStateNormal];
    [btnShare addTarget:self action:@selector(shareClick) forControlEvents:UIControlEventTouchUpInside];
    [footView addSubview:btnShare];
    [footView bringSubviewToFront:btnShare];
    
    [self.view addSubview:footView];
}

- (void)addTopViewLable
{
    _labelTop = [[UILabel alloc] init];
    _labelTop.frame = CGRectMake(0, 0, kSWidth, 20);
    _labelTop.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1];
    [self.view addSubview:_labelTop];
    
}
-(void)closeView
{
    if (self.isMore == 1)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)goBackPageBack{
    if ([self.webView canGoBack]) {
        [self.webView goBack];
        [self.webView reload];
    }
    else
    {
        if (self.isMore == 1)
        {
            [self dismissViewControllerAnimated:YES completion:nil];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    
}
-(void)shareClick
{
    [self shareAllButtonClickHandler:nil];
    
}

- (void)shareAllButtonClickHandler:(UIButton *)sender
{
    if (![UIDevice networkAvailable]) {
        [Global showTipNoNetWork];
        return;
    }
   
    [shareCustomView shareWithContent:@"" image:[self newsImage] title:[self newsTitle] url:[self newsLink] type:0 completion:^(NSString *resultJson){
        [self.webView performSelectorOnMainThread:@selector(giveResultWithWebView:) withObject:@{@"webView":webView, @"resultJson":resultJson} waitUntilDone:NO];
    }];
    
}
- (NSString *)newsTitle
{
    NSString *text = self.adArticle.title;
    if (![self.adArticle.title isKindOfClass:[NSString class]])
        text = @"";
    return text;
}

- (NSString *)newsLink
{
    NSString *text = self.adArticle.contentUrl;
    if (![self.adArticle.contentUrl isKindOfClass:[NSString class]])
        text = @"";
    return text;
}

- (id)newsImage{
    
    if ([NSString isNilOrEmpty:self.adArticle.imageUrl]) {
        return [Global getAppIcon];
    }
    else{
        return _adArticle.imageUrl;
    }
}
#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController
      didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([message.name isEqualToString:@"AppModel"]) {
        // 打印所传过来的参数，只支持NSNumber, NSString, NSDate, NSArray,
        // NSDictionary, and NSNull类型
        XYLog(@"%@", message.body);
    }
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"loading"]) {
        XYLog(@"loading");
    } else if ([keyPath isEqualToString:@"title"]) {
        self.title = self.webView.title;
    } else if ([keyPath isEqualToString:@"estimatedProgress"]) {
        XYLog(@"progress: %f", self.webView.estimatedProgress);
        self.progressView.progress = self.webView.estimatedProgress;
    }
    
    // 加载完成
    if (!self.webView.loading) {
        // 手动调用JS代码
        // 每次页面完成都弹出来，大家可以在测试时再打开
        NSString *js = @"callJsAlert()";
        [self.webView evaluateJavaScript:js completionHandler:^(id _Nullable response, NSError * _Nullable error) {
            XYLog(@"response: %@ error: %@", response, error);
            XYLog(@"call js alert by native");
        }];
        
        [UIView animateWithDuration:0.5 animations:^{
            self.progressView.alpha = 0;
        }];
    }
}
-(void)showLoginPage
{
    YXLoginViewController *controller = [[YXLoginViewController alloc]init];
    [controller rightPageNavTopButtons];
    controller.loginSuccessBlock =^(){
        NSString *postUserInfo = [NSString stringWithFormat:@"postUserInfo('%@');", [Global userInfoStr]];
        [self.webView evaluateJavaScript:postUserInfo completionHandler:^(id response, NSError * _Nullable error) {
            NSLog(@"%@", response);
        }];
    };
    
    [self presentViewController:[Global controllerToNav:controller]  animated:YES completion:^{
    }];
}
#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSString *strRequest = [navigationAction.request.URL.absoluteString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if ([strRequest containsString:@"checkuserlogin"]) {
        self.isCheckuserlogin = YES;
    }
    self.progressView.alpha = 1.0;
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    decisionHandler(WKNavigationResponsePolicyAllow);
    XYLog(@"%s", __FUNCTION__);
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    XYLog(@"%s", __FUNCTION__);
}

- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    XYLog(@"%s", __FUNCTION__);
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    XYLog(@"%s", __FUNCTION__);
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation {
    XYLog(@"%s", __FUNCTION__);
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    XYLog(@"%s", __FUNCTION__);
    if (self.isCheckuserlogin) {
        //是否登录
        if (![Global userId].length) {
            [self showLoginPage];
        }else{
            NSString *postUserInfo = [NSString stringWithFormat:@"postUserInfo('%@');", [Global userInfoStr]];
            [self.webView evaluateJavaScript:postUserInfo completionHandler:^(id response, NSError * _Nullable error) {
                NSLog(@"%@", response);
            }];
        }
    }
    
}

- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    if (self.isCheckuserlogin) {
        //是否登录
        if (![Global userId].length) {
            [self showLoginPage];
        }else{
            NSString *postUserInfo = [NSString stringWithFormat:@"postUserInfo('%@');", [Global userInfoStr]];
            [self.webView evaluateJavaScript:postUserInfo completionHandler:^(id response, NSError * _Nullable error) {
                NSLog(@"%@", response);
            }];
        }
    }
}

- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *__nullable credential))completionHandler {
    XYLog(@"%s", __FUNCTION__);
    completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
}

- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView {
    XYLog(@"%s", __FUNCTION__);
}

#pragma mark - WKUIDelegate
- (void)webViewDidClose:(WKWebView *)webView {
    XYLog(@"%s", __FUNCTION__);
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    XYLog(@"%s", __FUNCTION__);
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"alert" message:@"JS调用alert" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"确定",nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }]];
    
    [self presentViewController:alert animated:YES completion:NULL];
    XYLog(@"%@", message);
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler {
    XYLog(@"%s", __FUNCTION__);
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"confirm" message:@"JS调用confirm" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"确定",nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"取消",nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }]];
    [self presentViewController:alert animated:YES completion:NULL];
    
    XYLog(@"%@", message);
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * __nullable result))completionHandler {
    XYLog(@"%s", __FUNCTION__);
    
    XYLog(@"%@", prompt);
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"textinput" message:@"JS调用输入框" preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.textColor = [UIColor redColor];
    }];
    
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"确定",nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler([[alert.textFields lastObject] text]);
    }]];
    
    [self presentViewController:alert animated:YES completion:NULL];
}
@end
