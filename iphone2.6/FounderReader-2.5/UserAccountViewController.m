//
//  UserAccountViewController.m
//  AppSetting
//
//  Created by guo.lh on 13-7-23.
//  Copyright (c) 2013年 Beijing Founder Electronics Co.,Ltd. All rights reserved.
//

#import "UserAccountViewController.h"
#import "UserAccountCreatViewController.h"
#import "FileLoader.h"
#import "MBProgressHUD.h"
#import "NSString+Helper.h"
#import "ArticleRequest.h"
#import "NSString+MD5Addition.h"
#import "RegexKitLite.h"
#import "UIAlertView+Helper.h"
#import "UIDevice-Reachability.h"
#import "UserAccountDefine.h"
#import "AppConfig.h"
#import "FCReader_OpenUDID.h"
#import "CommentConfig.h"
#import "AppStartInfo.h"

#define kloginButtontag 101

@interface UserAccountViewController ()
@property(nonatomic,retain) UITextField *emailTexiField;
@property(nonatomic,retain) UITextField *passWordTexiField;
@property(nonatomic,retain) UIView *footerView;
@property(nonatomic,retain) UITableView *loginTableview;
@property(nonatomic,retain) UIButton *loginButton;

@property(nonatomic,retain) UIWebView *webView;

@end

@implementation UserAccountViewController
@synthesize emailTexiField,passWordTexiField,footerView;
@synthesize loginTableview;
@synthesize loginButton;
@synthesize accountDelegate = _accountDelegate;
@synthesize fartherNavigation = _fartherNavigation;

@synthesize webView;

-(void)dealloc
{
    self.loginTableview = nil;
    self.footerView = nil;
    self.emailTexiField = nil;
    self.passWordTexiField = nil;
    self.loginButton = nil;
    self.webView = nil;
    
//    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

-(void)viewWillDisappear:(BOOL)animated
{
    self.loginTableview = nil;
    [super viewWillDisappear:animated];
    [self.emailTexiField resignFirstResponder];
    [self.passWordTexiField resignFirstResponder];
    self.emailTexiField.text = @"";
    self.passWordTexiField.text = @"";
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.emailTexiField.text = [[NSUserDefaults standardUserDefaults] valueForKey:KuserAccountLoginName];
    self.passWordTexiField.text = [[NSUserDefaults standardUserDefaults] valueForKey:KuserAccountLoginPassWord];
    if (self.passWordTexiField.text.length > 0) {
    
        [self user_LogIn:nil];
    }
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSString *user = [[NSUserDefaults standardUserDefaults] objectForKey:KuserAccountLoginName];
    if ([NSString isNilOrEmpty:user])
    {
        self.title = @"我的账户";
        if (!self.loginTableview) {
            loginTableview = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
            UIImageView *bgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"user_bgImage"]];
            loginTableview.backgroundView = bgView;
 
            [self.view addSubview:self.loginTableview];
            self.loginTableview.dataSource = self;
            self.loginTableview.delegate = self;
        }
        
        [self textFields];
        [self createrFooterView];
    }
    
    [self titleLableWithTitle:@"用户登录"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
   
    if ([AppConfig sharedAppConfig].topViewStyle==2 || [AppConfig sharedAppConfig].topViewStyle==3)
        [self rightPageNavTopButtons];
}

-(void)gotoBack
{
    if([_accountDelegate respondsToSelector:@selector(gotoPage:)]){
        [self.accountDelegate gotoPage:self.navigationController];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)textFields
{
	if (!self.emailTexiField)
	{
		CGRect frame = CGRectMake(12, 9.0, 285, 20);
		emailTexiField = [[UITextField alloc] initWithFrame:frame];
		self.emailTexiField.textColor = [UIColor colorWithRed:0x8D/255.0 green:0x8D/255.0 blue:0x8D/255.0 alpha:1];
		//self.emailTexiField.font = [UIFont systemFontOfSize:14.0];
        self.emailTexiField.text = @"";
		self.emailTexiField.placeholder = @"请输入您的手机号";
		self.emailTexiField.backgroundColor = [UIColor clearColor];
		self.emailTexiField.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.emailTexiField.keyboardType = UIKeyboardTypeNumberPad;
		self.emailTexiField.delegate = self;
	}

    if (!self.passWordTexiField)
	{
		CGRect frame = CGRectMake(12, 9.0, 283, 20);
		passWordTexiField = [[UITextField alloc] initWithFrame:frame];
		self.passWordTexiField.textColor = [UIColor colorWithRed:0x8D/255.0 green:0x8D/255.0 blue:0x8D/255.0 alpha:1];
		//self.passWordTexiField.font = [UIFont systemFontOfSize:14.0];
        self.passWordTexiField.text = @"";
		self.passWordTexiField.placeholder = @"密码";
        self.passWordTexiField.secureTextEntry = YES;
		self.passWordTexiField.backgroundColor = [UIColor clearColor];
		self.passWordTexiField.returnKeyType = UIReturnKeyDone;
		self.passWordTexiField.clearButtonMode = UITextFieldViewModeWhileEditing;
		self.passWordTexiField.delegate = self;
	}
}

-(void)loginButtons
{
    loginButton =  [[UIButton alloc] initWithFrame:CGRectMake(165, 2, 146, 38.5)];
    UIImage *imageHot = [UIImage imageNamed:@"login_selected.png"];
    [self.loginButton setImage:imageHot forState:UIControlStateNormal];
   
    self.loginButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    [self.loginButton addTarget:self action:@selector(user_LogIn:) forControlEvents:UIControlEventTouchUpInside];
   
    [self.footerView addSubview:self.loginButton];

    // 返回
    UIButton *signUpButtons =  [[UIButton alloc] initWithFrame:CGRectMake(10, 2, 146, 38.5)];
    UIImage  *image = [UIImage imageNamed:@"signup_small.png"];
    [signUpButtons setImage:image forState:UIControlStateNormal];
    
    UIImage  *imageHl = [UIImage imageNamed:@"signup_small_selected.png"];
    [signUpButtons setImage:imageHl forState:UIControlStateHighlighted];
    
    signUpButtons.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    [signUpButtons addTarget:self action:@selector(showRegisterPage) forControlEvents:UIControlEventTouchDown];
    
    [self.footerView addSubview:signUpButtons];
 
  // 返回
//    UIButton *forgetButton =  [UIButton buttonWithType:UIButtonTypeCustom];
//    forgetButton.frame = CGRectMake(235, 60, 80, 10);
//    [forgetButton setTitle:@"忘记密码" forState:UIControlStateNormal];
//    [forgetButton setTitleColor:[UIColor colorWithRed:0x9D/255.0 green:0x9D/255.0 blue:0x9D/255.0 alpha:1.0] forState:UIControlStateNormal];
//   forgetButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    
//    [self.footerView addSubview:forgetButton];
}

-(void)createrFooterView
{
    footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSWidth, 150)];
    [self loginButtons];
     self.loginTableview.tableFooterView = self.footerView;
    
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"userAccountCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil){ 
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:CellIdentifier];
        
    }
    if ( 0 == indexPath.row )
    {
        [cell.contentView addSubview:self.emailTexiField];
    }
    else if ( 1 == indexPath.row )
    {
        [cell.contentView addSubview:self.passWordTexiField];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

-(void)showRegisterPage
{
    UIImage  *image = [UIImage imageNamed:@"login_gray.png"];
    [self.loginButton setImage:image forState:UIControlStateNormal];
    UserAccountCreatViewController *controller = [[UserAccountCreatViewController alloc]initWithStyle:UITableViewStyleGrouped];
    [self.navigationController pushViewController:controller animated:YES];
 
}

-(void)user_LogIn:(UIButton *)sender
{
    if (![self isEmailStyle]) {
        return;
    }
    else if([NSString isNilOrEmpty:self.passWordTexiField.text])
    {
        [UIAlertView showAlert:@"您输入的密码为空"];
        return;
    }
    if (![UIDevice networkAvailable]) {
        
        [self noNetworkAvailable];
        return;
    }
    [self userLoginRequest];
    
}

- (void)userLoginRequest
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    hud.labelText = @"登录中...";
    hud.minSize = CGSizeMake(135.f, 135.f);
    
    NSString *urlString = [NSString stringWithFormat:@"%@login", [AppStartInfo sharedAppStartInfo].registServer];
    NSURL *url = [NSURL URLWithString:urlString];
    HttpRequest *request = [HttpRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    NSString *informString = [NSString stringWithFormat:@"loginName=%@&password=%@&customerId=%d&deviceType=1&deviceId=%@&appId=%d&siteId=%d",self.emailTexiField.text,[self.passWordTexiField.text stringFromMD5],[AppStartInfo sharedAppStartInfo].customerId,[FCReader_OpenUDID value], [AppConfig sharedAppConfig].appId, [AppStartInfo sharedAppStartInfo].siteId];
    NSData *informData = [informString dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:informData];
    NSLog(@"url:%@ post:%@", urlString, informString);
    [request setCompletionBlock:^(NSData *data) {
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:nil error:nil];
        if ([[dict objectForKey:@"success"] boolValue]){
            
            NSString *userid = [dict objectForKey:@"userId"];
            if (userid == nil) {
                userid = self.emailTexiField.text;
            }
            
            NSString *nickname = [dict objectForKey:@"nickName"];
            if (nickname == nil) {
                nickname = [CommentConfig sharedCommentConfig].defaultNickName;;
            }
            
            NSString *phone = [dict objectForKey:@"phone"];
            if (phone == nil) {
                if([self.emailTexiField.text isMatchedByRegex:kPhoneNumberRegExp])
                    phone = self.emailTexiField.text;
                else
                    phone = @"";
            }
            
            NSString *email = [dict objectForKey:@"email"];
            if (email == nil) {
                if([self.emailTexiField.text isMatchedByRegex:KuserAccountMail])
                    email = self.emailTexiField.text;
                else
                    email = @"";
            }
            
            [[NSUserDefaults standardUserDefaults] setObject:self.emailTexiField.text forKey:KuserAccountLoginName];
            [[NSUserDefaults standardUserDefaults] setObject:userid forKey:KuserAccountLoginId];
            [[NSUserDefaults standardUserDefaults] setObject:email forKey:KuserAccountMail];
            [[NSUserDefaults standardUserDefaults] setObject:phone forKey:KuserAccountPhone];
            
            [[NSUserDefaults standardUserDefaults] setObject:nickname forKey:KuserAccountNickName];
            [hud hide:YES afterDelay:0];
            
            if([_accountDelegate respondsToSelector:@selector(gotoPage:)]){
                [self.accountDelegate gotoPage:self.navigationController];
            }

        }
        else{
            NSString *errorInfo = [dict objectForKey:@"errorInfo"];
            [hud hide:YES afterDelay:0.1];
            [UIAlertView showAlert:errorInfo];
            return;
        }
    }];
    
    [request setFailedBlock:^(NSError *error) {
//        hud.labelText = @"登录失败";
        hud.labelText = @"网络不给力，请检查一下网络设置";
        [hud hide:YES afterDelay:1];
    }];
    
    [request startAsynchronous];
}

-(void)clearAllRegisterINfo
{
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:KuserAccountRegisterName];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:KuserAccountRegisterPassWord];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:KuserAccountRegisterNickName];
}

-(void)setAllLoginInfo:(NSString *)loginName nickName:(NSString *)nickName
{
    if (![NSString isNilOrEmpty:loginName]) {
        [[NSUserDefaults standardUserDefaults] setObject:loginName forKey:KuserAccountLoginName];
         [[NSUserDefaults standardUserDefaults] setObject:self.passWordTexiField.text forKey:KuserAccountLoginPassWord];
    }
    if (![NSString isNilOrEmpty:nickName]) {
        [[NSUserDefaults standardUserDefaults] setObject:nickName forKey:KuserAccountNickName];
    }
    
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


- (BOOL)isEmailStyle
{
    if ([NSString isNilOrEmpty:self.emailTexiField.text]) {
        [UIAlertView showAlert:@"您输入的手机号为空"];
        return NO;
    }
    else if (![self.emailTexiField.text isMatchedByRegex:kPhoneNumberRegExp]) {
        [UIAlertView showAlert:@"请输入有效的手机号"];
        return NO;
    }

    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView  *)webView_
{
    NSLog(@"%@", webView_.request.URL.description);
    
    if (GetInformFinished) return;
    
    
    NSString *jsToGetHTMLSource = @"document.getElementsByTagName('html')[0].innerHTML";
    
    NSString *HTMLSource = [webView_ stringByEvaluatingJavaScriptFromString:jsToGetHTMLSource];
    
    NSString *text = nil;
    NSScanner *theScanner = [NSScanner scannerWithString:HTMLSource];
    [theScanner scanUpToString:@"/mp/sso/xxx.jsp?passport=" intoString:NULL];
    [theScanner scanUpToString:@"&amp;random=" intoString:&text];
    
    NSArray* kvPair = [text componentsSeparatedByString:@"="];
    NSArray *array;
    
    if (kvPair.count == 2) {
        NSString* value = [kvPair objectAtIndex:1];
        array = [value componentsSeparatedByString:@"#"];
        
        [[NSUserDefaults standardUserDefaults] setObject:array[0] forKey:KuserAccountLoginName];
        [[NSUserDefaults standardUserDefaults] setObject:array[1] forKey:KuserAccountLoginId];
        [[NSUserDefaults standardUserDefaults] setObject:array[3] forKey:KuserAccountNickName];
        [[NSUserDefaults standardUserDefaults] setObject:array[9] forKey:KuserAccountPhone];
        [[NSUserDefaults standardUserDefaults] setObject:array[7] forKey:KuserAccountFace];
        [[NSUserDefaults standardUserDefaults] setObject:array[5] forKey:KuserAccountMail];
     
        GetInformFinished = YES;
        [webView_ setHidden:YES];
        
        
        [self gotoBack];
    }
    
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    //NSURL *url = [request URL];
    //NSString *urlString = [url absoluteString];
    NSLog(@"shouldStartLoadWithRequest");
    
    if (GetInformFinished)
    {
        return NO;
    }

    // 加载页面触发请求
    return YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error;
{
    //[self gotoBack];
}
@end
