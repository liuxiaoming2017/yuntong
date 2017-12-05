//
//  RootWebPageController.m
//  FounderReader-2.5
//
//  Created by sa on 15-7-31.
//
//

#import "RootWebPageController.h"
#import "Column.h"
#import "NJWebPageController.h"
#import "YXLoginViewController.h"
#import "NSString+Helper.h"
#import "Global.h"
#import "UserAccountDefine.h"
#import "UIDevice-Reachability.h"
#import "UIWebView+ShareURLCheck.h"
#import "AppStartInfo.h"

@interface RootWebPageController ()<UIWebViewDelegate,UIAlertViewDelegate,UIScrollViewDelegate,CDRTranslucentSideBarDelegate>

@property (nonatomic, copy)NSString *loadedURL;

@property (nonatomic, assign)BOOL isLoad;

@end

@implementation RootWebPageController
{
   
}

@synthesize sideBar,leftController;

-(void)left
{
    [self.sideBar show];
    return;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _firstClick = 0;
    self.navigationItem.rightBarButtonItem = nil;

    self.view.backgroundColor = [UIColor whiteColor];
    [self titleLableWithTitle:parentColumn.columnName];

    webView = [[UIWebView alloc] init];
    webView.mediaPlaybackRequiresUserAction = NO;
    webView.scalesPageToFit = YES;
    webView.delegate = self;
    webView.scrollView.delegate = self;
    webView.frame = CGRectMake(0, 0, kSWidth,kSHeight-64);
    webView.backgroundColor = [UIColor clearColor];
    [self.view addSubview: webView];
    
    NSString *nickNameUTF8 = [NSString encodeString:[Global userInfoByKey:KuserAccountNickName]];
    NSString *extInfo = [NSString stringWithFormat:@"phone=%@&nickname=%@",[Global userPhone], nickNameUTF8];
    NSString *webUrl = [NSString stringWithFormat:@"%@&%@", parentColumn.linkUrl, extInfo];
    if([parentColumn.linkUrl rangeOfString:@"?"].location == NSNotFound){
        webUrl = [NSString stringWithFormat:@"%@?%@", parentColumn.linkUrl, extInfo];
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:webUrl]];
    
    [webView loadRequest:request];
    
    [self showActivityIndicatorView];
    leftController = [[PersonalCenterViewController alloc] init];
    self.leftController.view.frame = CGRectMake(0, 0, 240, self.view.bounds.size.height+64);
    
    sideBar = [[CDRTranslucentSideBar alloc] init];
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

-(void)viewWillAppear:(BOOL)animated
{
    self.isLoad = NO;
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden=NO;
    self.tabBarController.tabBar.hidden = NO;
}

-(void)showActivityIndicatorView
{
    UIView *view = [self.view viewWithTag:321];
    if (!view) {
        UIView *hudView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 135, 135)];
        hudView.tag = 321;
        hudView.backgroundColor = [UIColor lightTextColor];
        hudView.center = self.view.center;
        [self.view addSubview:hudView];
        UIActivityIndicatorView *little = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(50, 15, 30, 30)];
        little.color = [UIColor grayColor];
        [little startAnimating];
        [hudView addSubview:little];
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, 135, 30)];
        title.font = [UIFont systemFontOfSize:15];
        title.textAlignment = 1;
        title.text = NSLocalizedString(@"正在加载...", nil);
        [hudView addSubview:title];
    }
    view.hidden = NO;
}

-(void)hiddenActivityIndicatorView
{
    UIView *view = [self.view viewWithTag:321];
    view.hidden = YES;
    
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [webView stopLoading];
}

- (void)webViewDidStartLoad:(UIWebView *)sender
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    webView.hidden = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)sender
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self performSelector:@selector(showWebViewAfter) withObject:nil afterDelay:.1];
    [self hiddenActivityIndicatorView];
    _firstClick = 1;

}

- (void)webView:(UIWebView *)sender didFailLoadWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    //如果为主链接加载失败,显示错误视图
    NSString *currentURL = [error.userInfo objectForKey:@"NSErrorFailingURLKey"];
    NSString *mainURL = webView.request.URL.absoluteString;
    if (![UIDevice networkAvailable] || !mainURL.length || [mainURL isEqualToString:currentURL]) {
        webView.hidden = NO;
        [self hiddenActivityIndicatorView];
        [Global showWebErrorView:self];
    }
}

-(void)onWebError:(id)sender{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:parentColumn.linkUrl]];
    [webView loadRequest:request];
    [self showActivityIndicatorView];
    [Global hideWebErrorView:self];
}

-(void)showWebViewAfter
{
    webView.hidden = NO;
}
- (BOOL)webView:(UIWebView *)sender shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (![UIWebView checkShareURLWithRequest:request navigationType:navigationType WebView:webView]) {
        return NO;
    }
    if (navigationType != UIWebViewNavigationTypeOther) {
        self.loadedURL = request.URL.absoluteString;
    }
    if (!self.isLoad && [request.URL.absoluteString isEqualToString:self.loadedURL]) {
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            if (connectionError || ([response respondsToSelector:@selector(statusCode)] && [((NSHTTPURLResponse *)response) statusCode] != 200 && [((NSHTTPURLResponse *)response) statusCode] != 302)) {
                //Show error message
//                [Global showWebErrorView:self];
            }else {
                self.isLoad = YES;
                NJWebPageController * controller = [[NJWebPageController alloc] init];
                Column *one = [[Column alloc] init];
                one.linkUrl = request.URL.absoluteString;
                one.columnName = @"";
                controller.parentColumn = one;
                controller.isFromModal = YES;
                [self presentViewController:[Global controllerToNav:controller] animated:YES completion:nil];
            }
        }];
        return NO;
    }
    self.isLoad = NO;
    return YES;
    
//    
//    if (!_firstClick) {
//        return YES;
//    }
//    NSURL *url = [request URL];
//    NSString *urlString = [url absoluteString];
//    if (![NSString isNilOrEmpty:urlString] && [urlString hasPrefix:@"http"])
//    {
//        NJWebPageController * controller = [[NJWebPageController alloc] init];
//        Column *one = [[Column alloc] init];
//        one.linkUrl = urlString;
//        one.columnName = @"";
//        controller.parentColumn = one;
//        controller.isFromModal = YES;
//        [self presentViewController:[Global controllerToNav:controller] animated:YES completion:nil];
//        //[self.navigationController pushViewController:controller animated:YES];
//        return NO;
//    }
//    return YES;

}
-(void)showLoginPage
{
    YXLoginViewController *controller = [[YXLoginViewController alloc]init];
    [controller rightPageNavTopButtons];
    
    [self presentViewController:[Global controllerToNav:controller]  animated:YES completion:^{
    }]; 
}

#pragma mark - leftPage delegate

- (void)sideBar:(CDRTranslucentSideBar *)sideBar1 willAppear:(BOOL)animated {

    [self.leftController updateUserInfo];
}

- (void)sideBar:(CDRTranslucentSideBar *)sideBar1 willDisappear:(BOOL)animated {

}

#pragma mark - Gesture Handler

- (void)handlePanGesture:(UIPanGestureRecognizer *)recognizer {
    
    // if you have left and right sidebar, you can control the pan gesture by start point.
    CGPoint translatedPoint = [recognizer translationInView:self.view];
    if (translatedPoint.x > 0){
        if (recognizer.state == UIGestureRecognizerStateBegan) {
            self.sideBar.isCurrentPanGestureTarget = YES;
        }
        
        [self.sideBar handlePanGestureToShow:recognizer inView:self.view];
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    //禁用双击和手势缩放
    return nil;
}
@end
