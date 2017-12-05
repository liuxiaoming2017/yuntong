//
//  NJWebPageController.m
//  FounderReader-2.5
//
//  Created by ld on 15-9-9.
//
//

#import "NJWebPageController.h"
#import "ColumnBarConfig.h"
#import "YXLoginViewController.h"
#import "UserAccountDefine.h"
#import "UIDevice-Reachability.h"
#import "CreditWebViewController.h"
#import "CreditNavigationController.h"
#import "shareCustomView.h"
#import "NSString+Helper.h"
#import "Global.h"
#import "UserAccountDefine.h"
#import "ColorStyleConfig.h"
#import "UIWebView+ShareURLCheck.h"

@interface NJWebPageController ()<UIWebViewDelegate,UIGestureRecognizerDelegate>
@property (nonatomic, retain) UIWebView *webView;
@property (nonatomic, retain) UIView *toolBarView;
@property (nonatomic, retain) UISwipeGestureRecognizer *rightRecognizer;
@end

@implementation NJWebPageController
@synthesize toolBarView,webView;
@synthesize parentColumn;

-(void)dealloc
{
    self.webView.delegate = nil;
    self.webView.scrollView.delegate = nil;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupNav];
    
    webView = [[UIWebView alloc] initWithFrame:CGRectMake(0,0, kSWidth, kSHeight-64)];
    self.webView.mediaPlaybackRequiresUserAction = NO;
    self.webView.delegate = self;
    self.webView.scalesPageToFit = YES;
    // url中必须对中文进行编码
    NSString *nickNameUTF8 = [NSString encodeString:[Global userInfoByKey:KuserAccountNickName]];
    NSString *extInfo = [NSString stringWithFormat:@"phone=%@&nickname=%@",[Global userPhone], nickNameUTF8];
    NSString *webUrl = [NSString stringWithFormat:@"%@&%@", parentColumn.linkUrl, extInfo];
    if([parentColumn.linkUrl rangeOfString:@"?"].location == NSNotFound){
        webUrl = [NSString stringWithFormat:@"%@?%@", parentColumn.linkUrl, extInfo];
    }
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:webUrl]];
    [self.webView loadRequest:request];
    [self.view addSubview:self.webView];
    
    self.rightRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(goPrePage)];
    self.rightRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    self.rightRecognizer.cancelsTouchesInView = NO;
    self.rightRecognizer.delegate = self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [self.webView stopLoading];
  
    return;
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if (gestureRecognizer == self.rightRecognizer)
    {
        return YES;
    }
    return NO;
}
-(void)setupNav
{
    self.title = self.parentColumn.columnName;
    // 设置导航默认标题的颜色及字体大小
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [ColorStyleConfig sharedColorStyleConfig].navbar_titlecolor_didselect,
                                                                    NSFontAttributeName : [UIFont boldSystemFontOfSize:18]};
    
    UIButton *preBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    preBtn.tag = 111;
    [preBtn setImage:[UIImage imageNamed:@"nav_bar_back"] forState:UIControlStateNormal];
    [preBtn sizeToFit];
    preBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    preBtn.contentEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
    [preBtn addTarget:self action:@selector(goPrePage) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:preBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    UIButton *deleteBtn = [[UIButton alloc] initWithFrame:CGRectMake(kSWidth - 30, 30, 24, 24)];
    deleteBtn.tag = 112;
    [deleteBtn addTarget:self action:@selector(cancelBack) forControlEvents:UIControlEventTouchUpInside];
    [deleteBtn setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    if (self.hiddenClose) {
        deleteBtn.hidden = YES;
    }
    else
    {
        deleteBtn.hidden = NO;
    }
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:deleteBtn];
    
}
 -(void)goPrePage
 {
     if ([self.webView canGoBack]) {
         [self.webView goBack];
     }else
     {
         [self cancelBack];
     }
 }

-(void)cancelBack
{
    // A present B，则A.presentedViewController = B; B.presentingViewController = A;
    if (self.presentingViewController)
        [self dismissViewControllerAnimated:YES completion:nil];
    else
        [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (![UIWebView checkShareURLWithRequest:request navigationType:navigationType WebView:self.webView]) {
        return NO;
    }
    NSURL *url = [request URL];
    NSString *urlString = [url absoluteString];
    
    if ([[urlString lowercaseString] containsString:@"checkuserlogin"]) {
        //是否登录
        if (![Global userId].length) {
            [self showLoginPage];
        }else{
            NSString *inviteCode = [[NSUserDefaults standardUserDefaults] objectForKey:KuserAccountInviteCode];
            inviteCode = [NSString isNilOrEmpty:inviteCode] || ![Global userId].length ? @"" : inviteCode;
            NSString *jsMethod = [NSString stringWithFormat:@"userCodeFromClient('%@','%@');", [Global userId], inviteCode];
            [self.webView stringByEvaluatingJavaScriptFromString:jsMethod];
            NSString *postUserInfo = [NSString stringWithFormat:@"postUserInfo('%@');", [Global userInfoStr]];
            [self.webView stringByEvaluatingJavaScriptFromString:postUserInfo];
        }
        return NO;//return no表示webview不去加载该checkUserLogin链接
    }
    else if ([urlString containsString:@"/userShare"]) {
        
        NSRange range = [urlString rangeOfString:@"?"];
        if (range.location == NSNotFound) {
            return NO;
        }
        NSString *paramsString = [urlString substringFromIndex:range.location + 1];
        NSArray *paramsArray = [paramsString componentsSeparatedByString:@"&"];
        NSString *type;
        NSString *codeStr;
        NSString *imgUrl;
        for (NSString *string in paramsArray) {
            if ([string hasPrefix:@"type"]) {
                type = [string substringFromIndex:5];
            } else if ([string hasPrefix:@"code"]) {
                codeStr = [string substringFromIndex:5];
            } else if ([string hasPrefix:@"imgUrl"]) {
                imgUrl = [string substringFromIndex:7];
            }
        }
        if (!(type.length && codeStr.length)) {
            return NO;
        }
        
        //缓存起来，可能是六位的地推邀请码
        [[NSUserDefaults standardUserDefaults] setObject:codeStr forKey:KuserAccountInviteCode];
        [[NSUserDefaults standardUserDefaults] synchronize];
        NSString *title = [NSString stringWithFormat:@"【%@】%@【%@】", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"], NSLocalizedString(@"邀请你一起加入哦，邀请码为", nil), codeStr];

        NSString *description = [NSString stringWithFormat:@"%@【%@】%@%@%@", NSLocalizedString(@"邀请码", nil), codeStr, NSLocalizedString(@"，与好友一起下载应用，共享", nil), [AppConfig sharedAppConfig].integralName, NSLocalizedString(@"赢大礼。", nil)];
        NSString *url = [NSString stringWithFormat:@"%@/invitecode_share?code=%@&sc=%@", [AppConfig sharedAppConfig].serverIf, codeStr, [AppConfig sharedAppConfig].sid];
        
        [shareCustomView shareWithContentInWeb:type.intValue Content:description image:imgUrl  title:title url:url completion:^(NSString *resultJson){
            [self.webView performSelectorOnMainThread:@selector(giveResultWithWebView:) withObject:@{@"webView":self.webView, @"resultJson":resultJson} waitUntilDone:NO];
        }];
        
        return NO;//return no表示webview不去加载该userShare链接
    }
    else if ([urlString containsString:@"/sendCode"]) {
        NSRange range = [urlString rangeOfString:@"code="];
        NSString *codeStr = [urlString substringFromIndex:range.location + range.length];
        //缓存起来，可能是绑定的新的邀请码如六位的地推邀请码
        [[NSUserDefaults standardUserDefaults] setObject:codeStr forKey:KuserAccountInviteCode];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return NO;
    }
    else if ([urlString containsString:@"/webjifen"]) {
        
        CreditWebViewController *web = [[CreditWebViewController alloc] init];
        CreditNavigationController *nav = [[CreditNavigationController alloc]initWithRootViewController:web];
        UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [leftButton setImage:[UIImage imageNamed:@"btn_return"] forState:UIControlStateNormal];
        [leftButton sizeToFit];
        leftButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        leftButton.contentEdgeInsets = UIEdgeInsetsMake(10, -10, 10, 30);
        
        [leftButton addTarget:self action:@selector(goBackToMyCredit) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
        [web.navigationItem setLeftBarButtonItem:leftItem];
        
        [nav setNavColorStyle:[UIColor colorWithPatternImage:[Global navigationImage]]];
        [nav.navigationBar setBackgroundImage:[Global navigationImage] forBarMetrics:UIBarMetricsDefault];
        [self presentViewController:nav animated:YES completion:nil];
        return NO;
    
    }
    else if ([urlString containsString:@"/jifenrule"]) {
       
        NJWebPageController *controller = [[NJWebPageController alloc] init];
        Column *column = [[Column alloc] init];
        //    /uc/ruleDefine
        column.linkUrl = [NSString stringWithFormat:@"%@/uc/ruleDefine?sid=%@",[AppConfig sharedAppConfig].serverIf, [AppConfig sharedAppConfig].sid];
        column.columnName = NSLocalizedString(@"积分规则",nil);
        controller.parentColumn = column;
        [self presentViewController:[Global controllerToNav:controller] animated:YES completion:nil];
        return NO;
    }
    else if ([urlString containsString:@"/activateInvite"]) {

        return NO;
    }
    return YES;
}

- (void)goBackToMyCredit
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    XYLog(@"url=%@", [[webView.request URL] absoluteString]);
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)view
{
    XYLog(@"url=%@", [[webView.request URL] absoluteString]);
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    if (self.title.length == 0 || self.isShowHtmlTitle) {
        NSString* title = [view stringByEvaluatingJavaScriptFromString:@"document.title"];
        if(title.length > 8){
            title = [title substringToIndex:8];
            title = [title stringByAppendingString:@"..."];
        }
        self.title = title;
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    XYLog(@"url=%@\n error=%@", [[webView.request URL] absoluteString],[error description]);
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    //如果为主链接加载失败,显示错误视图
    NSString *currentURL = [error.userInfo objectForKey:@"NSErrorFailingURLKey"];
    NSString *mainURL = webView.request.URL.absoluteString;
    if (![UIDevice networkAvailable] || !mainURL.length || [mainURL isEqualToString:currentURL]) {
        [Global showWebErrorView:self];
    }
}

-(void)onWebError:(id)sender{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:parentColumn.linkUrl]];
    [webView loadRequest:request];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [Global hideWebErrorView:self];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return nil;
}

-(void)showLoginPage
{
    YXLoginViewController *controller = [[YXLoginViewController alloc]init];
    controller.loginSuccessBlock = ^(){
        NSString *jsMethod = [NSString stringWithFormat:@"userCodeFromClient('%@','%@');", [Global userId], [[NSUserDefaults standardUserDefaults] objectForKey:KuserAccountInviteCode]];
        [self.webView stringByEvaluatingJavaScriptFromString:jsMethod];
        NSString *postUserInfo = [NSString stringWithFormat:@"postUserInfo('%@');", [Global userInfoStr]];
        [self.webView stringByEvaluatingJavaScriptFromString:postUserInfo];
    };
    [controller rightPageNavTopButtons];
    [self presentViewController:[self controllerToNav:controller] animated:YES completion:nil];
}

- (UINavigationController *)controllerToNav:(UIViewController *)controller
{
    
    NSDictionary *navBarConfigDict = [NSDictionary dictionaryWithContentsOfFile:pathForMainBundleResource(@"nav_bar_config.plist")];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:controller];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")){
        [nav.navigationBar setBackgroundImage:[Global navigationImage] forBarMetrics:UIBarMetricsDefault];
        UIColor *navBarTintColor = UIColorFromString([navBarConfigDict objectForKey:@"tint_color"]);
        nav.navigationBar.tintColor = navBarTintColor;
        
    }
    else{
        [nav.navigationBar setBackgroundImage:[Global navigationImage] forBarMetrics:UIBarMetricsDefault];
        UIColor *navBarTintColor = UIColorFromString([navBarConfigDict objectForKey:@"tint_color_6"]);
        nav.navigationBar.tintColor = navBarTintColor;
    }
    
    return nav;
}

@end
