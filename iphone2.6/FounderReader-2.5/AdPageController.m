//
//  AdPageController.m
//  FounderReader-2.5
//
//  Created by wxq on 12-5-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//  链接栏目页面

#import "AdPageController.h"
#import "Thumbnail.h"
#import "DataLib/DataLib.h"
#import "FileRequest.h"
#import <UMMobClick/MobClick.h>
#import "NSString+Helper.h"
#import "FileLoader.h"
#import "AppConfig.h"
#import "UIImage+Helper.h"
#import "shareCustomView.h"
#import "NJEventRequest.h"
#import "AppStartInfo.h"
#import "UIDevice-Reachability.h"
#import "NJWebPageController.h"
#import "UIWebView+ShareURLCheck.h"
#import "ColorStyleConfig.h"
#import "ColumnBarConfig.h"

@interface AdPageController ()<UIScrollViewDelegate,UIGestureRecognizerDelegate>

@property (nonatomic, copy)NSString *loadedURL;

@property (nonatomic, assign)BOOL isLoad;

@property (nonatomic, retain) UIPanGestureRecognizer *pan;

@end

@implementation AdPageController

- (id)initWithColumn:(Column *)column
{
    self = [super init];
    if (self) {
        self.columnUrl = column.linkUrl;
        self.adColumn = column;
    }
    return self;
}

- (id)initWithColumn:(Column *)column viewControllerType:(FDViewControllerType)viewControllerType
{
    self = [super init];
    if (self) {
        self.columnUrl = column.linkUrl;
        self.adColumn = column;
        self.viewControllerType = viewControllerType;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupNav];
    
    _firstClick = 0;
    _webView = [[UIWebView alloc] init];
    _webView.scalesPageToFit = YES;
    NSInteger onlyOne = [[[NSUserDefaults standardUserDefaults] objectForKey:@"onlyOne"] integerValue];
    if (onlyOne == 2 && ![AppStartInfo sharedAppStartInfo].ucTabisShow)
    {
        _webView.frame = CGRectMake(0, 0, kSWidth,kSHeight-kNavBarHeight-[ColumnBarConfig sharedColumnBarConfig].columnHeaderHeight);
    }
    else
    {
        _webView.frame = CGRectMake(0, 0, kSWidth,kSHeight-64-49-[ColumnBarConfig sharedColumnBarConfig].columnHeaderHeight);
    }
    //html5音频自动播放
    self.webView.allowsInlineMediaPlayback = YES;
    self.webView.mediaPlaybackRequiresUserAction = NO;
    self.webView.delegate = self;
    [self.view addSubview:self.webView];
    NSURL *url = nil;
    url = [NSURL URLWithString:self.columnUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
}

- (void)setupNav {
    if (self.viewControllerType != FDViewControllerForDetailVC)
        return;
    
    self.webView.frame = CGRectMake(0, 0, kSWidth, kSHeight-64);
    [self titleLableWithTitle:self.adColumn.columnName];
    self.navigationItem.rightBarButtonItem =nil;
    // 设置导航默认标题的颜色及字体大小
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [ColorStyleConfig sharedColorStyleConfig].navbar_titlecolor_didselect,NSFontAttributeName : [UIFont boldSystemFontOfSize:18]};
    
    UIButton *preBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    preBtn.tag = 111;
    [preBtn setImage:[UIImage imageNamed:@"nav_bar_back"] forState:UIControlStateNormal];
    [preBtn sizeToFit];
    preBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    preBtn.contentEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
    [preBtn addTarget:self action:@selector(goRightPageBack) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:preBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    // leftBarButtonItem点击范围太大，点击“我的提问”容易触碰leftBarButtonItem返回
    UIView *view = [[UIView alloc] init];
    view.frame = CGRectMake(20 + preBtn.frame.size.width, 0, 60, 44);
    [self.navigationController.navigationBar addSubview:view];
}

-(void)goRightPageBack{
    if (self.viewControllerType == FDViewControllerForDetailVC) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [super goRightPageBack];
    }
}
- (void)viewWillAppear:(BOOL)animated
{
    self.isLoad = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    [super viewWillAppear:animated];
    if (self.viewControllerType != FDViewControllerForDetailVC) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }else {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
    NSLog(@"navigationBar=%d",self.navigationController.navigationBar.hidden);
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //[self.webView stopLoading];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - web view delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (![UIWebView checkShareURLWithRequest:request navigationType:navigationType WebView:self.webView]) {
        return NO;
    }
    if (navigationType != UIWebViewNavigationTypeOther) {
        self.loadedURL = request.URL.absoluteString;
    }
    if (!self.isLoad && [request.URL.absoluteString isEqualToString:self.loadedURL]) {
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            if (connectionError || ([response respondsToSelector:@selector(statusCode)] && [((NSHTTPURLResponse *)response) statusCode] != 200 && [((NSHTTPURLResponse *)response) statusCode] != 302)) {
                //Show error message
                [Global showWebErrorView:self];
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
}
-(void)webViewDidFinishLoad:(UIWebView *)webView1
{
    _firstClick = 1;
}
- (void)webViewDidStartLoad:(UIWebView *)webView
{

}


- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    
    [Global showWebErrorView:self];
}

-(void)onWebError:(id)sender{
    _firstClick = 0;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.columnUrl]];
    [self.webView loadRequest:request];
    [Global hideWebErrorView:self];
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
@end
