//
//  TemplateNewDetailViewController.m
//  FounderReader-2.5
//
//  Created by wxq on 12-5-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TemplateNewDetailViewController.h"
#import "Thumbnail.h"
#import "DataLib/DataLib.h"
#import "NSString+Helper.h"
#import "FileLoader.h"
#import "UIImage+Helper.h"
#import "shareCustomView.h"
#import "UIDevice-Reachability.h"
#import "AdNewDetailViewController.h"
#import "ColorStyleConfig.h"
#import "RNCachingURLProtocol.h"
#import "YXLoginViewController.h"
#import "UIView+Extention.h"
#import "CommentViewControllerGuo.h"
#import "UIWebView+ShareURLCheck.h"

@interface TemplateNewDetailViewController ()<UIGestureRecognizerDelegate, CommentViewDelegate>
{
    //一级链接稿件加载完成(可能捕捉不完全)
    BOOL _isLinkDidLoad;
}

@property (nonatomic, strong) UILabel *labelTop;

@property (copy, nonatomic) NSString *currentURLString;
@property (strong, nonatomic) UIView *postCommentView;
@property (strong, nonatomic) CommentViewControllerGuo *commentController;

@property (assign, nonatomic) NSInteger viewControllersCount;
@end

@implementation TemplateNewDetailViewController
@synthesize adArticle = _adArticle;
@synthesize imageFlag = _imageFlag;
@synthesize columnUrl;


- (void)viewDidDisappear:(BOOL)animated {
    if (self.navigationController.viewControllers.count < _viewControllersCount) {
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
    }
}


- (id)init
{
    if (self = [super init]) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    _viewControllersCount = self.navigationController.viewControllers.count;
    [Global showTipAlways:NSLocalizedString(@"正在加载...", nil)];
    
    // 关闭评论
    if (self.adArticle.type == ArticleType_ADV_List || self.adArticle.type == ArticleType_ADV_Top || self.adArticle.type == ArticleType_ADV_Essay)
    {
        isDiscussClose = YES;
        isGreatClose = YES;
    }
    else
    {
        isDiscussClose = _adArticle.discussClosed;
        isGreatClose = NO;
    }
    
    [super viewDidLoad];
    
    [NSURLProtocol registerClass:[RNCachingURLProtocol class]];
    
    [self addTopViewLable];
    
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, kStatusBarHeight, kSWidth, kSHeight-kStatusBarHeight-kTabBarHeight)];
    self.webView.scalesPageToFit = YES;
    //html5音频自动播放
    self.webView.allowsInlineMediaPlayback = YES;
    self.webView.mediaPlaybackRequiresUserAction = NO;
    self.webView.dataDetectorTypes = UIDataDetectorTypePhoneNumber;//自动检测网页上的电话号码，单击可以拨打
    self.webView.delegate = self;
    /** 想要goBack不刷新页面的核心代码 BEGIN */
//    [[NSUserDefaults standardUserDefaults] setInteger:2 forKey: @"WebKitCacheModelPreferenceKey"];
//    [[NSUserDefaults standardUserDefaults] setInteger:1 forKey: @"WebKitMediaPlaybackAllowsInline"];
//    id webView = [self.webView valueForKeyPath:@"_internal.browserView._webView"];
//    id preferences = [webView valueForKey:@"preferences"];
//    [preferences performSelector:@selector(_postCacheModelChangedNotification)];
    /** 想要goBack不刷新页面的核心代码 END */
    
    NSURL *url = [NSURL URLWithString:_adArticle.contentUrl];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
    
    [self.view addSubview: self.webView];
    

    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoStarted:)name:@"UIMoviePlayerControllerDidEnterFullscreenNotification"object:nil];// 播放器即将播放通知
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoFinished:)name:@"UIMoviePlayerControllerDidExitFullscreenNotification"object:nil];// 播放器即将退出通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoStarted:) name:UIWindowDidBecomeVisibleNotification object:nil];//进入全屏
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoFinished:) name:UIWindowDidBecomeHiddenNotification object:nil];//退出全屏
    UIView *statusView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 20)];
    statusView.backgroundColor = [UIColor whiteColor];
    [self updateToolbar];
    //[FounderEventRequest articleviewDateAnaly:_adArticle.fileId column:self.column.fullColumn];
}

- (void)updateToolbar {
    [super updateToolbar];
    
    if ([self.adArticle.extproperty hasPrefix:@"questionsAndAnswers"]) {
        //互动+
        [self.footview hidePraiseButton];
        [self.footview hideCollectButton];
        [self.footview hideCommentButton];
        [self addPostCommentView];
    }
}


- (void)addTopViewLable
{
    _labelTop = [[UILabel alloc] init];
    _labelTop.frame = CGRectMake(0, 0, kSWidth, kStatusBarHeight);
    _labelTop.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_labelTop];
    
}

-(void)closeView
{
    if (self.isMore == 1)
    {
        [self dismissViewControllerAnimated:NO completion:nil];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)goBackPageBack{
    if ([self.webView canGoBack]) {
        [self.webView goBack];
        return;
    }
    if (self.isMore == 1)
    {
        [self dismissViewControllerAnimated:NO completion:nil];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    [NSURLProtocol registerClass:[RNCachingURLProtocol class]];
    // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated
{
    self.view.backgroundColor = [UIColor whiteColor];
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    self.tabBarController.tabBar.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [Global hideTip];
    [super viewWillDisappear:animated];
}

/*
 当播放到一半的时候我点击一个按钮使webview移除掉，这时虽然webview移除了，但是还有声音，也就是说视频还在播放，
 要怎样在webview移除的时候也让视频停止播放？
 解决办法：
 让webview调用一个 about:blank的url。就可以停止视频播放。
 */

- (void)cellClicked:(Thumbnail *)sender
{
    //if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
    //    return;
    
    [[UIApplication sharedApplication] setStatusBarHidden:![UIApplication sharedApplication].statusBarHidden withAnimation:UIStatusBarAnimationSlide];
    [self.navigationController setNavigationBarHidden:!self.navigationController.navigationBarHidden animated:YES];
}

- (void)shareArticle:(UIButton *)sender{
    
    [self shareAllButtonClickHandler:sender];
}


- (NSString *)newsTitle
{
    NSString *text = _adArticle.title;
    if (![_adArticle.title isKindOfClass:[NSString class]])
        text = @"";
    return text;
}

- (NSString *)newsLink
{
    NSString *text = _adArticle.shareUrl;
    if (![_adArticle.shareUrl isKindOfClass:[NSString class]])
        text = @"";
    return text;
}

- (id)newsImage
{
    if ([NSString isNilOrEmpty:_adArticle.imageUrl]) {
        return [Global getAppIcon];
    }
    else{
        return _adArticle.imageUrl;
    }
}
- (void)shareAllButtonClickHandler:(UIButton *)sender
{
    if (![UIDevice networkAvailable]) {
        [Global showTipNoNetWork];
        return;
    }

    UIImage *newsImage = [self newsImage];
    [shareCustomView shareWithContent:@"" image:newsImage title:[self newsTitle] url:[self newsLink] type:0 completion:^(NSString *resultJson){
        [self.webView performSelectorOnMainThread:@selector(giveResultWithWebView:) withObject:@{@"webView":self.webView, @"resultJson":resultJson} waitUntilDone:NO];
//        [FounderEventRequest founderEventShareAppinit:_adArticle.fileId];
//        [FounderEventRequest shareDateAnaly:_adArticle.fileId column:self.column.fullColumn];
    }];
}

- (void)updateFootView:(BOOL)isCommentFootView {
    _postCommentView.hidden = !isCommentFootView;
    

}

- (void)addPostCommentView
{
    _postCommentView = [[UIView alloc] initWithFrame:CGRectMake(30, self.view.bounds.size.height-45, kSWidth - 30, 45)];
    _postCommentView.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1];
    
    UIButton *postCommentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [postCommentButton setImage:[UIImage imageNamed:@"commentBtn"] forState:UIControlStateNormal];
    if (IS_IPHONE_6)
    {
        postCommentButton.frame = CGRectMake(2, 6, 290, 30);
        
    }else if (IS_IPHONE_6P)
    {
        postCommentButton.frame = CGRectMake(4, 7, 330, 30);
        [postCommentButton setImage:[UIImage imageNamed:@"ditect_write6p"] forState:UIControlStateNormal];
        
    }else
    {
        postCommentButton.frame = CGRectMake(2, 6, 235, 30);
    }

    [postCommentButton addTarget:self action:@selector(postCommentButtonClick) forControlEvents:UIControlEventTouchUpInside];
    //UIButton *shareBtn = [SeeMethod newButtonWithFrame:CGRectMake(kSWidth-43, 8, 32, 32) type:UIButtonTypeSystem title:nil target:self UIImage:@"toolbar_share_new" andAction:@selector(shareClick)];
    //[_postCommentView addSubview:shareBtn];
    _postCommentView.width = postCommentButton.width + postCommentButton.x;
    [_postCommentView addSubview:postCommentButton];
    [self.view addSubview:_postCommentView];
    _postCommentView.hidden = YES;
}

- (void)postCommentButtonClick {
    if (![UIDevice networkAvailable]) {
        [Global showTipNoNetWork];
        return;
    }
    
    __weak __typeof(self)weakSelf = self;
    if(![NSString isNilOrEmpty:[Global userId]])
        [self toCommentClick];
    else
        [self toLoginWithBlock:^{
            [weakSelf toCommentClick];
        }];
}

- (void)toCommentClick
{
    _commentController = [[CommentViewControllerGuo alloc] init];
    _commentController.delegate = self;
    NSString *qid = [_currentURLString componentsSeparatedByString:@"qid="].lastObject;
    _commentController.rootID = qid.intValue;
    Article *article = [[Article alloc] init];
    article.articleType = 101;
    _commentController.article = article;
    _commentController.urlStr = [NSString stringWithFormat:@"%@/api/submitComment",[AppConfig sharedAppConfig].serverIf];
    _commentController.sourceType = 4;
    [appDelegate().window addSubview:_commentController.view];
    
}

- (void)reloadTableView {
    [self.webView reload];
}

#pragma mark - web view delegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    if ([_currentURLString containsString:@"askPlusColumnInfo"]) {
        [Global showTipAlways:NSLocalizedString(@"正在加载...", nil)];
    }
}

-(void)webViewDidFinishLoad:(UIWebView *)webView1
{
    if ([_currentURLString containsString:@"askPlusColumnInfo"]) {
        [self updateFootView:YES];
    }
    [Global hideTip];
    if ([webView1 canGoBack]) {
        btnClose.hidden = NO;
    }
    else{
        btnClose.hidden = NO;
    }
    NSString *currentURL= self.webView.request.URL.absoluteString;
    //一级链接稿件加载完毕
    if (![currentURL containsString:@"newaircloud"]) {
        _isLinkDidLoad = YES;
    }
    NSString *url = nil;
    if (self.columnUrl != nil) {
        url = self.columnUrl;
    }
    else
    {
        url = _adArticle.contentUrl;
    }
    if ([currentURL isEqualToString:url])
        imageview2.hidden = NO;
    else
        imageview2.hidden = YES;
    
    //    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [Global hideTip];
    if ([_currentURLString containsString:@"askPlusColumnInfo"]) {
        [self updateFootView:NO];
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    if (![UIWebView checkShareURLWithRequest:request navigationType:navigationType WebView:self.webView]) {
        return NO;
    }
    NSURL *url = [request URL];
    _currentURLString = [url absoluteString];
    if (![_currentURLString containsString:@"askPlusColumnInfo"]) {
        [self updateFootView:NO];
    }
    
    if ([[_currentURLString lowercaseString] rangeOfString:@"checkuserlogin"].location != NSNotFound) { //调用APP登录接口
        //是否登录
        if (![Global userId].length) {
            
            YXLoginViewController *controller = [[YXLoginViewController alloc]init];
            controller.loginSuccessBlock = ^(){
                [self callJSMethod];
            };
            [controller rightPageNavTopButtons];
            [self presentViewController:[Global controllerToNav:controller] animated:YES completion:nil];
            
            return NO;
        }else{
            [self callJSMethod];
            return NO;
        }
    }
    
    //webview发生点击事件、并且不是一级网页加载时
    if (_isLinkDidLoad && navigationType == UIWebViewNavigationTypeLinkClicked) {
        
        AdNewDetailViewController *adNewDetailVC = [[AdNewDetailViewController alloc] init];
        self.adArticle.contentUrl = _currentURLString;
        adNewDetailVC.adArticle = self.adArticle;
        adNewDetailVC.isMore = YES;
        [self presentViewController:adNewDetailVC animated:NO completion:nil];
    }
    
    return YES;
    
}

- (void)callJSMethod
{
    NSString *jsMethod = [NSString stringWithFormat:@"clientCallHtml('%@','%@','%@');", [Global userName], [Global userPhone], [Global userId]];
    [self.webView stringByEvaluatingJavaScriptFromString:jsMethod];
    
    NSString *postUserInfo = [NSString stringWithFormat:@"postUserInfo('%@');", [Global userInfoStr]];
    [self.webView stringByEvaluatingJavaScriptFromString:postUserInfo];
}

- (void)zoomInOut:(NSString *)size
{
    return;
}
- (void)zoomInOut:(NSString *)size withIS:(int)top
{
    return;
}

-(void)goPrePage
{
    if ([(UIWebView*)self.view canGoBack])
    {
        [(UIWebView*)self.view  goBack];
    }
}

-(void)goNextPage
{
    if ([(UIWebView*)self.view  canGoForward])
    {
        [(UIWebView*)self.view  goForward];
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    // 注意：只有非根控制器才有滑动返回功能，根控制器没有。
    // 判断导航控制器是否只有一个子控制器，如果只有一个子控制器，肯定是根控制器
    if (self.childViewControllers.count == 1) {
        // 表示用户在根控制器界面，就不需要触发滑动手势，
        return NO;
    }
    return YES;
}

- (void)videoStarted:(NSNotification *)notification {// 开始播放
    
    appDelegate().isAllOrientation = YES;
}

- (void)videoFinished:(NSNotification *)notification {//完成播放
    appDelegate().isAllOrientation = NO;
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val = UIInterfaceOrientationPortrait;
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)goBothBack {
    if ([self.webView canGoBack]) {
        [self.webView goBack];
    } else {
        [super goBothBack];
        //文章返回事件
        Article *article = [articles objectAtIndex:currentIndex];
        //[FounderEventRequest articlereturnDateAnaly:article.fileId column:self.column.fullColumn];
    }
}

- (void)toLoginWithBlock:(void (^)(void))block
{
    YXLoginViewController *controller = [[YXLoginViewController alloc] init];
    [controller rightPageNavTopButtons];
    controller.loginSuccessBlock = ^(YXLoginViewController *loginSelf){
            if (block) block();
    };
    [self presentViewController:[Global controllerToNav:controller] animated:YES completion:nil];
}

@end
