//
//  YXLoginViewController.m
//  FounderReader-2.5
//
//  Created by ld on 14-12-24.
//
//
#import "ColorStyleConfig.h"
#import "YXLoginViewController.h"
#import "UserColumnButton.h"
#import "YXRegistViewController.h"
#import "UserAccountDefine.h"
#import "NSStringAdditions.h"
#import "RegexKitLite.h"
#import "UIDevice-Reachability.h"
#import "HttpRequest.h"
#import "AppStartInfo.h"
#import "NSString+MD5Addition.h"
#import "FCReader_OpenUDID.h"
#import "AppConfig.h"
#import "DataLib/DataLib.h"
#import "CommentConfig.h"
#import "Defines.h"
#import "UIImage+Helper.h"
#import "YXResetViewController.h"
#import "UIAlertView+Helper.h"
#import "UIView+Extention.h"
#import "NewsListConfig.h"
#import "NJWebPageController.h"
#import "FounderIntegralRequest.h"
#import "ColumnBarConfig.h"
#import "ChangeUserInfoController.h"
#import "AESCrypt.h"
#import "FDAreaPickerViewController.h"
#import "FZChangePhoneNumberController.h"
#import "YZSDK.h"

#import <UShareUI/UMSocialUIUtility.h>

#define SCREENW [UIScreen mainScreen].bounds.size.width
#define SCREENH [UIScreen mainScreen].bounds.size.height
#define HEIGHTS 25
@interface YXLoginViewController ()<UITextFieldDelegate>
{
    BOOL _isRegister;
}
@property(nonatomic,retain)UILabel *label;
@property(nonatomic,retain)UIButton *smallButton;
@property(nonatomic,retain) UILabel *regionLabel;
@property(nonatomic,retain) UITextField *phoneTextField;
@property(nonatomic,retain) UITextField *PWTextField;
@property (assign,nonatomic) NSInteger num;

@property (strong, nonatomic) FDAreaPickerModel *areaModel;
@property (nonatomic,assign) BOOL clearInfo;
@end

@implementation YXLoginViewController
@synthesize phoneTextField,PWTextField;
@synthesize delegate,smallButton,label;

-(void)leftAndRightButton
{
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftButton setImage:[UIImage imageNamed:@"nav_bar_back"] forState:UIControlStateNormal];
    [leftButton sizeToFit];
    leftButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    leftButton.contentEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
    [leftButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    if (![AppConfig sharedAppConfig].isNeedLoginBeforeEnter) {
        UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
        self.navigationItem.leftBarButtonItem = leftItem;
    }
}
-(void)goBack{
    if (self.clearInfo) {
        [self clearloginInfo];
    }
    if (self.loginFailedBlock && [NSString isNilOrEmpty:[Global userId]]) {
        self.loginFailedBlock(self);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)clearloginInfo{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setObject:@"" forKey:KuserAccountUserId];
    [defaults setObject:@"" forKey:KuserAccountLoginName];
    [defaults setObject:@"" forKey:KuserAccountLoginPassWord];
    [defaults setObject:@"" forKey:KuserAccountPhone];
    [defaults setObject:@"" forKey:KuserAccountFace];
    [defaults setObject:@"" forKey:KuserAccountMail];
    [defaults setObject:@"" forKey:KuserAccountLoginId];
    [defaults setObject:@"" forKey:KuserAccountNickName];
    [defaults setObject:@"" forKey:KuserAccountRegisterName];
    [defaults setObject:@"" forKey:KuserAccountRegisterPassWord];
    [defaults setObject:@"" forKey:KuserAccountRegisterNickName];
    [defaults synchronize];
    [self logOutWithShareType];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"duiba-load-WebView" object:self userInfo:nil];
    
    //退出有赞商城
    [YZSDK logoutYouzan];
}
-(void)logOutWithShareType
{
//    if ([ShareSDK hasAuthorized:SSDKPlatformTypeSinaWeibo]) {
//        [ShareSDK cancelAuthorize:SSDKPlatformTypeSinaWeibo];
//    }
//    else if ([ShareSDK hasAuthorized:SSDKPlatformSubTypeQZone]) {
//        [ShareSDK cancelAuthorize:SSDKPlatformSubTypeQZone];
//    }
//    else if ([ShareSDK hasAuthorized:SSDKPlatformSubTypeWechatSession]) {
//        [ShareSDK cancelAuthorize:SSDKPlatformSubTypeWechatSession];
//    }
    
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:KuserAccountUserId];
}
- (FDAreaPickerModel *)areaModel {
    if (!_areaModel) {
        _areaModel = [[FDAreaPickerModel alloc] init];
        _areaModel.code = [AppConfig sharedAppConfig].defaultAreaCode;
        _areaModel.country = NSLocalizedString([AppConfig sharedAppConfig].defaultAreaCountry,nil);
    }
    return _areaModel;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    //      地区图标
    UIImageView *regionImg = [[UIImageView alloc]initWithFrame:CGRectMake(40, 70*proportion, 30, 30)];
    regionImg.image = [UIImage imageNamed:@"userRegion"];
    regionImg.layer.cornerRadius = 10;
    [self.view addSubview:regionImg];
    
    //      地区
    self.regionLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(regionImg.frame) + 10, regionImg.frame.origin.y-5, self.view.bounds.size.width-110, 30)];
    self.regionLabel.centerY = regionImg.centerY;
    self.regionLabel.font = [UIFont systemFontOfSize:16];
    self.regionLabel.text = self.areaModel.country;
    [self.view addSubview:self.regionLabel];
    self.regionLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *regionTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(regionClicked:)];
    [self.regionLabel addGestureRecognizer:regionTapGestureRecognizer];
    
    //      横线
    UILabel *regionLine = [[UILabel alloc]initWithFrame:CGRectMake(40, CGRectGetMaxY(self.regionLabel.frame)+10, kSWidth-80, 1)];
    regionLine.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
    [self.view addSubview:regionLine];

    
    //      用户名图标
    UIImageView *userImg = [[UIImageView alloc]initWithFrame:CGRectMake(regionImg.frame.origin.x,regionImg.frame.origin.y+50, regionImg.frame.size.width, regionImg.frame.size.width)];
    userImg.image = [UIImage imageNamed:@"userImage"];
    userImg.layer.cornerRadius = 10;
    [self.view addSubview:userImg];

    //        手机号
    phoneTextField = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(userImg.frame) + 10, userImg.frame.origin.y-5, self.view.bounds.size.width-110, 30)];
    userImg.centerY = phoneTextField.centerY;
    self.phoneTextField.font = [UIFont systemFontOfSize:16];
    self.phoneTextField.placeholder = NSLocalizedString(@"手机",nil);
    [self.view addSubview:self.phoneTextField];
    self.phoneTextField.keyboardType = UIKeyboardTypeEmailAddress;
    
    //      横线
    UILabel *userLine = [[UILabel alloc]initWithFrame:CGRectMake(40, CGRectGetMaxY(phoneTextField.frame)+10, kSWidth-80, 1)];
    userLine.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
    [self.view addSubview:userLine];
    
    //      密码图标
    UIImageView *passwordImg = [[UIImageView alloc] initWithFrame:CGRectMake(userImg.frame.origin.x,userImg.frame.origin.y+50, userImg.frame.size.width, userImg.frame.size.width)];
    passwordImg.image = [UIImage imageNamed:@"passwordNJ"];
    passwordImg.layer.cornerRadius = 10;
    [self.view addSubview:passwordImg];
    
    //      密码
    PWTextField = [[UITextField alloc]initWithFrame:CGRectMake(CGRectGetMaxX(passwordImg.frame) + 10, 70, self.view.bounds.size.width-175, 30)];
    PWTextField.centerY = passwordImg.centerY;
    self.PWTextField.font = [UIFont systemFontOfSize:16];
    self.PWTextField.placeholder = NSLocalizedString(@"密码",nil);
    self.PWTextField.delegate = self;
    self.PWTextField.secureTextEntry = YES;
    self.PWTextField.keyboardType = UIKeyboardTypeEmailAddress;
    [self.view addSubview:self.PWTextField];
    
    //      密码下面横线
    UILabel *passwordLine = [[UILabel alloc]initWithFrame:CGRectMake(40, CGRectGetMaxY(PWTextField.frame)+10, kSWidth-80, 1)];
    passwordLine.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
    [self.view addSubview:passwordLine];

    //      忘记密码
    UIButton *forgetButton = [UIButton buttonWithType:UIButtonTypeCustom];
    forgetButton.titleLabel.font = [UIFont systemFontOfSize:10];
    forgetButton.frame = CGRectMake(self.view.bounds.size.width-105, 75, 65, 20);
    [forgetButton setTitle:NSLocalizedString(@"忘记密码",nil) forState:UIControlStateNormal];
    [forgetButton setTitleColor:[UIColor colorWithRed:182/255.0 green:180/255.0 blue:181/255.0 alpha:1] forState:UIControlStateNormal];
    forgetButton.layer.borderWidth = 1;
    forgetButton.layer.borderColor = [UIColor colorWithRed:182/255.0 green:180/255.0 blue:181/255.0 alpha:1].CGColor;
    forgetButton.layer.cornerRadius = 8;
    forgetButton.centerY = PWTextField.centerY;
    [self.view addSubview:forgetButton];
    [forgetButton addTarget:self action:@selector(forgetPassWord:) forControlEvents:UIControlEventTouchUpInside];
    
    
    //用户服务协议
    UIView *userView=[[UIView alloc]initWithFrame:CGRectMake(userImg.frame.origin.x, CGRectGetMaxY(passwordLine.frame)+10, self.view.bounds.size.width-20, 45)];
    smallButton=[UIButton buttonWithType:UIButtonTypeCustom];
    smallButton.frame=CGRectMake(0, 8, 15*proportion, 15*proportion);
    [smallButton setImage:[UIImage imageNamed:@"checkbox_normal"] forState:UIControlStateNormal];
    [smallButton setImage:[UIImage imageNamed:@"checkbox_press"] forState:UIControlStateSelected];
    smallButton.selected=YES;
    [smallButton addTarget:self action:@selector(smallbtnClick) forControlEvents:UIControlEventTouchUpInside];
    UILabel *wordLabel=[[UILabel alloc]initWithFrame:CGRectMake(20*proportion, 10, 70 * proportion, 12*proportion)];
    wordLabel.text = NSLocalizedString(@"已阅读并同意",nil);
    wordLabel.font=[UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleCellDateFontSize];
    wordLabel.textColor = [UIColor grayColor];
    
    UIButton*userButton=[UIButton buttonWithType:UIButtonTypeCustom];
    userButton.frame=CGRectMake(wordLabel.frame.origin.x+wordLabel.frame.size.width, 10, 70*proportion, 12*proportion);
    userButton.titleLabel.font = [UIFont systemFontOfSize: [NewsListConfig sharedListConfig].middleCellDateFontSize];
    [userButton setTitle:NSLocalizedString(@"用户服务协议",nil) forState:UIControlStateNormal];
    [userButton setTitleColor:[ColumnBarConfig sharedColumnBarConfig].column_all_color forState:UIControlStateNormal];
    [userButton addTarget:self action:@selector(userbtnClick) forControlEvents:UIControlEventTouchUpInside];
    [userView addSubview:userButton];
    [userView addSubview:wordLabel];
    [userView addSubview:smallButton];
    [self.view addSubview:userView];

    //      登陆按钮
    UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    loginButton.frame = CGRectMake(kSWidth * 0.5 + 10, CGRectGetMaxY(userView.frame) + 10, (kSWidth - 90)*0.5, 25*proportion);
    loginButton.layer.cornerRadius = 3;
    loginButton.backgroundColor = [ColorStyleConfig sharedColorStyleConfig].login_button_color;
    [loginButton setTitle:NSLocalizedString(@"登录",nil) forState:UIControlStateNormal];
    [loginButton setTintColor:[UIColor colorWithRed:0xff/255.0 green:0xff/255.0 blue:0xff/255.0 alpha:1]];
    loginButton.titleLabel.font = [UIFont fontWithName:[Global fontName] size:[NewsListConfig sharedListConfig].middleActiveCellTitleFontSize];
    [self.view addSubview:loginButton];
    [loginButton addTarget:self action:@selector(logIn:) forControlEvents:UIControlEventTouchUpInside];
    
    //      注册按钮
    UIButton *registButton = [UIButton buttonWithType:UIButtonTypeCustom];
    registButton.frame = CGRectMake(userImg.frame.origin.x, loginButton.frame.origin.y, (kSWidth - 90)*0.5, 25*proportion);
    registButton.layer.cornerRadius = 3;
    registButton.layer.borderWidth = 1;
    registButton.layer.borderColor = [ColorStyleConfig sharedColorStyleConfig].login_button_color.CGColor;
    [registButton setTitle:NSLocalizedString(@"注册",nil) forState:UIControlStateNormal];
    registButton.titleLabel.font = [UIFont fontWithName:[Global fontName] size:[NewsListConfig sharedListConfig].middleActiveCellTitleFontSize];
    [registButton setTitleColor:[ColorStyleConfig sharedColorStyleConfig].login_button_color forState:UIControlStateNormal];
    [self.view addSubview:registButton];
    [registButton addTarget:self action:@selector(registButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    registButton.userInteractionEnabled=YES;
    UITapGestureRecognizer *labelTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(registButtonClicked:)];
    [registButton addGestureRecognizer:labelTapGestureRecognizer];
    
    //      第三方登陆标题
    label = [[UILabel alloc]initWithFrame:CGRectMake(kSWidth * 0.5 - 60, CGRectGetMaxY(registButton.frame)+80*proportion, 120, 20)];
    if (kSHeight == 480) {
        label.frame = CGRectMake(kSWidth * 0.5 - 60, CGRectGetMaxY(registButton.frame)+30*proportion, 120, 20);
    }
    label.text = NSLocalizedString(@"快捷登录,立即体验",nil);
    label.backgroundColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleCellDateFontSize];
    label.textColor = [ColorStyleConfig sharedColorStyleConfig].login_button_color;
    [self.view addSubview:label];
    [self configThirdPartyButton];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardDownb)];
    tapRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapRecognizer];

}

- (void)regionClicked:(UITapGestureRecognizer *)tap {
    __weak __typeof (self)weakSelf = self;
    FDAreaPickerViewController *vc = [[FDAreaPickerViewController alloc] initWithDefaultModel:self.areaModel FDAreaPickerBlock:^(FDAreaPickerModel *model) {
        weakSelf.areaModel = model;
        weakSelf.regionLabel.text = model.country;
    }];
    [self.navigationController pushViewController:vc animated:YES];
}

//用户服务协议点击
-(void)userbtnClick{
    
    NJWebPageController *controller = [[NJWebPageController alloc] init];
    Column *column = [[Column alloc] init];
    column.linkUrl = [NSString stringWithFormat:@"%@/protocol.html",[AppStartInfo sharedAppStartInfo].configUrl];
    column.columnName = NSLocalizedString(@"服务协议",nil);
    controller.parentColumn = column;
    controller.hiddenClose = YES;
    controller.isFromModal = YES;
    [self presentViewController:[Global controllerToNav:controller] animated:YES completion:nil];
}
-(void)keyboardDownb
{
    [self.phoneTextField resignFirstResponder];
    [self.PWTextField resignFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self keyboardDownb];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self titleLableWithTitle:NSLocalizedString(@"立即登录",nil)];
    self.tabBarController.tabBar.hidden = YES ;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

/**
 *  第三方登陆按钮
 */
-(void)configThirdPartyButton
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY-MM-dd"];
    
    NSDate *dateEnd = [formatter dateFromString:[AppConfig sharedAppConfig].thirdLoginTime];
    NSTimeInterval timeEnd = [dateEnd timeIntervalSince1970];
    
    NSTimeInterval timeNow = [[NSDate date] timeIntervalSince1970];
    if (timeEnd > timeNow ) {
        label.hidden = YES;
        return;
    }
    
    NSMutableArray *imageNameArry = [NSMutableArray array];
    NSMutableArray *titleArray = [NSMutableArray array];
    NSMutableArray *loginTypeArray = [NSMutableArray array];
    if (![AppConfig sharedAppConfig].isHideLogin_QQ) {
        //if([TencentOAuth iphoneQQInstalled])
        {
            [imageNameArry addObject:@"logo_qq"];
            [titleArray addObject:@"QQ"];
            [loginTypeArray addObject:[NSNumber numberWithInteger:UMSocialPlatformType_QQ]];
        }
    }
    if (![AppConfig sharedAppConfig].isHideLogin_WeChat) {
        //if([WXApi isWXAppInstalled])
        {
            [imageNameArry addObject:@"logo_wechat"];
            [titleArray addObject:NSLocalizedString(@"微信",nil)];
            [loginTypeArray addObject:[NSNumber numberWithInteger:UMSocialPlatformType_WechatSession]];
        }
    }
    if (![AppConfig sharedAppConfig].isHideLogin_WeiBo) {
        [imageNameArry addObject:@"logo_sinaweibo"];
        [titleArray addObject:NSLocalizedString(@"微博",nil)];
        [loginTypeArray addObject:[NSNumber numberWithInteger:UMSocialPlatformType_Sina]];
    }
        
    if([[AppConfig sharedAppConfig].sid isEqualToString:@"aomen"])
    {
        
        [imageNameArry addObject:@"logo_facebook"];
        [titleArray addObject:@"FaceBook"];
        [loginTypeArray addObject:[NSNumber numberWithInteger:UMSocialPlatformType_Facebook]];
    }
    int iconWidth = kSWidth / 3;
    int iconSpan = kSWidth / 9;
    if(imageNameArry.count == 4){
        iconWidth = kSWidth / 4;
        iconSpan = kSWidth / 12;
    }
    
    for (int i = 0; i<imageNameArry.count; i++) {
        
        ColumnButton *columnButton = [[ColumnButton alloc] initWithFrame:CGRectMake( i * iconWidth, CGRectGetMaxY(label.frame) + 20, iconWidth, iconWidth)];
        if (IS_IPHONE_5 || IS_IPHONE_4) {
            columnButton = [[ColumnButton alloc] initWithFrame:CGRectMake( i * iconWidth, CGRectGetMaxY(label.frame), iconWidth, iconWidth)];
        }
        columnButton.thumbnail.frame = CGRectMake(iconSpan, iconSpan, iconWidth-2*iconSpan, iconWidth-2*iconSpan);
        columnButton.thumbnail.image = [UIImage imageNamed:[imageNameArry objectAtIndex:i]];
        columnButton.nameLabel.frame = CGRectMake(0, 50, columnButton.frame.size.width, [NewsListConfig sharedListConfig].middleCellDateFontSize+1);
        columnButton.nameLabel.y = CGRectGetMaxY(columnButton.thumbnail.frame)+10;
        columnButton.nameLabel.text = titleArray[i];
        columnButton.nameLabel.font = [UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleCellDateFontSize + 1];
        columnButton.nameLabel.textColor = [UIColor colorWithRed:0x66/255.0 green:0x66/255.0  blue:0x66/255.0 alpha:1];
        [columnButton addTarget:self action:@selector(thirdPartyButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:columnButton];
        
        columnButton.tag = 3000 + [loginTypeArray[i] integerValue];
    }
}

-(void)smallbtnClick{
    smallButton.selected=!smallButton.selected;
    
}
-(void)registButtonClicked:(UIButton *)sender
{
    
    YXRegistViewController *controller = [[YXRegistViewController alloc]init];
    controller.isForgetPassWord = NO;
    if (self.phoneTextField.text.length) {
        controller.phoneNum = self.phoneTextField.text;
    }
    //zzy 注册成功回调
    controller.registerSuccessBlock = ^(YXRegistViewController *controller, NSString *phone, NSString *password, FDAreaPickerModel *areaModel){
        [controller.navigationController popViewControllerAnimated:YES];
        //积分入库
        FounderIntegralRequest *IntegralRequest = [[FounderIntegralRequest alloc] init];
        [IntegralRequest addIntegralWithUType:UTYPE_REGISTER integralBlock:^(NSDictionary *integralDict) {
            
            if (!integralDict || !integralDict || ![[integralDict objectForKey:@"success"] boolValue]) {
                [Global showTip:NSLocalizedString(@"注册成功",nil)];
            }else{
                NSInteger score = [[integralDict objectForKey:@"score"] integerValue];
                if (score) {//score分数不为0提醒
                    [Global showTip:[NSString stringWithFormat:@"%@，%@+%ld", NSLocalizedString(@"注册成功",nil), [AppConfig sharedAppConfig].integralName, (long)score]];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"duiba-load-WebView" object:self userInfo:nil];
                }else{
                    [Global showTip:NSLocalizedString(@"注册成功",nil)];
                }
            }
            self.areaModel = areaModel;
            self.phoneTextField.text = phone;
            self.PWTextField.text = password;
            // 注册完之后去登录！
            _isRegister = YES;
            [self logIn:nil];
        }];
    };
    [self.navigationController pushViewController:controller animated:YES];
    
}

- (BOOL)isPhoneNumber
{
    if ([NSString isNilOrEmpty:self.phoneTextField.text]) {
        //[UIAlertView showAlert:NSLocalizedString(@"您输入的手机号为空",nil)];
        [self showAlwetController:@"您输入的手机号为空"];
        return NO;
    } else if (self.phoneTextField.text.length > 11){
        //[UIAlertView showAlert:NSLocalizedString(@"请输入有效的手机号",nil)];
        [self showAlwetController:@"请输入有效的手机号"];
        return NO;
    } else if(self.phoneTextField.text.length == 11){
        NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",kPhoneNumberRegExp];
        if(![phoneTest evaluateWithObject:self.phoneTextField.text]){
            [self showAlwetController:@"请输入有效的手机号"];
            return NO;
        }
    }
    //长度低于11的也能获取验证码，因为澳门香港地区一般都少于11位
    return YES;
}

/**
 *  判断输入类型
*/
- (BOOL)isPhoneNumberStyle
{
    if ([NSString isNilOrEmpty:self.phoneTextField.text]) {
        
        [self showAlwetController:@"您输入的手机号/邮箱为空"];
        return NO;
    }
    else
    {
        if ([self.phoneTextField.text rangeOfString:@"@"].location != NSNotFound) {
            if (!([self.phoneTextField.text rangeOfString:@".com"].location != NSNotFound || [self.phoneTextField.text rangeOfString:@".cn"].location != NSNotFound)) {
                //[UIAlertView showAlert:NSLocalizedString(@"请输入有效的邮箱",nil)];
                [self showAlwetController:@"请输入有效的邮箱"];
                return NO;
            }
        }
        
    }
    return YES;
}

- (void)logIn:(UIButton *)sender
{
    if (smallButton.selected) {
        //判断是否是邮箱
        if ([self.phoneTextField.text rangeOfString:@"@"].location != NSNotFound) {
            if (![self isPhoneNumberStyle]) {
                return;
            }
        }
        //判断是否是电话
        else if([self.phoneTextField.text rangeOfString:@"@"].location == NSNotFound)
        {
            if (![self isPhoneNumber]) {
                return;
            }
        }
        else if([NSString isNilOrEmpty:self.PWTextField.text])
        {
            
            [self showAlwetController:@"您输入的密码为空"];
            return;
        }
        
        if (![UIDevice networkAvailable]) {
            
            [Global showTipNoNetWork];
            return;
        }
        // 去登录！
        [self userLoginRequest];
    }
    else {
        
        [self showAlwetController:@"您还没有同意用户协议"];
    }
}

/**
 *  登陆请求
 */
- (void)userLoginRequest
{
    [Global showTipAlways:NSLocalizedString(@"登录中...",nil)];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/api/loginEx", [AppConfig sharedAppConfig].serverIf];
    NSURL *url = [NSURL URLWithString:urlString];
    HttpRequest *request = [HttpRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    NSString *informString = nil;
    //(sid+mobile+password)
    NSString *phoneNumber = self.phoneTextField.text;
    if (self.areaModel.code != [AppConfig sharedAppConfig].defaultAreaCode) {
        phoneNumber = [self.areaModel.code stringByAppendingString:phoneNumber];
    }
    //informString = [NSString stringWithFormat:@"sid=%@&mobile=%@&password=%@&deviceID=%@",[AppConfig sharedAppConfig].sid, phoneNumber, [self.PWTextField.text stringFromMD5], [GeTuiSdk clientId]];
    informString = [NSString stringWithFormat:@"sid=%@&mobile=%@&password=%@&deviceID=%@",[AppConfig sharedAppConfig].sid, phoneNumber, [self.PWTextField.text stringFromMD5], @"测试id"];
    NSString *sign = [AESCrypt encrypt:[NSString stringWithFormat:@"%@%@%@",[AppConfig sharedAppConfig].sid,phoneNumber,[self.PWTextField.text stringFromMD5]] password:key];
    informString = [NSString stringWithFormat:@"%@&sign=%@",informString,sign];

    NSData *informData = [informString dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:informData];
    XYLog(@"登录url:%@ post:%@", urlString, informString);
    [request setCompletionBlock:^(NSData *data) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers  error:nil];

        if ([[dict objectForKey:@"success"] boolValue])
        {
            NSString *uid = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"uid"] intValue]];;
            if (!uid) {
                uid = phoneNumber;
            }
            
//            NSString *sid = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"sid"] intValue]];
//            if(!sid){
//                sid=@"0";
//            }
            
            NSString *nickname = [dict objectForKey:@"nickName"];
            if (!nickname){
                nickname = [CommentConfig sharedCommentConfig].defaultNickName;
            }
            
            NSString *phone = [dict objectForKey:@"mobile"];
            if (!phone) {
                    phone = phoneNumber;
            }
            
            NSString *userFaceUrl = [dict objectForKey:@"faceUrl"];
            if (!userFaceUrl){
                userFaceUrl = @"";
            }
            
            NSString *scores = @"";
            scores = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"scores"] intValue]];
            if (!scores){
                scores = @"";
            }
            
            NSString *inviteCode = [dict objectForKey:@"inviteCode"];
            if (!inviteCode){
                inviteCode = @"";
            }
            
            NSString *email = [dict objectForKey:@"email"];
            if (!email){
                email = @"";
            }
            
            NSString *birthday = [dict objectForKey:@"birthday"];
            if (!birthday){
                birthday = @"";
            }
            
            
            NSString *sex = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"sex"] intValue]];
            if (!sex){
                sex = @"";
            }
            
            
            NSString *region = [dict objectForKey:@"region"];
            if (!region){
                region = @"";
            }
            
            
            NSString *address = [dict objectForKey:@"address"];
            if (!address){
                address = @"";
            }
            
            [[NSUserDefaults standardUserDefaults] setObject:phone forKey:KuserAccountLoginName];
            [[NSUserDefaults standardUserDefaults] setObject:self.PWTextField.text forKey:KuserAccountLoginPassWord];
            XYLog(@"%@",self.PWTextField.text);
            XYLog(@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:KuserAccountLoginPassWord]);
            [[NSUserDefaults standardUserDefaults] setObject:uid forKey:KuserAccountUserId];
            [[NSUserDefaults standardUserDefaults] setObject:email forKey:KuserAccountMail];
            [[NSUserDefaults standardUserDefaults] setObject:phone forKey:KuserAccountPhone];
            [[NSUserDefaults standardUserDefaults] setObject:nickname forKey:KuserAccountNickName];
            [[NSUserDefaults standardUserDefaults] setObject:userFaceUrl forKey:KuserAccountFace];
            [[NSUserDefaults standardUserDefaults] setObject:scores forKey:[NSString stringWithFormat:@"%@%@",uid,KuserAccountMoneyStr]];
            [[NSUserDefaults standardUserDefaults] setObject:inviteCode forKey:KuserAccountInviteCode];
            
            // [[NSUserDefaults standardUserDefaults] setObject:sid forKey:KuserAccountUserSid];
            [[NSUserDefaults standardUserDefaults] setObject:birthday forKey:KuserAccountbirth];
            [[NSUserDefaults standardUserDefaults] setObject:sex forKey:KuserAccountsex];
            [[NSUserDefaults standardUserDefaults] setObject:region forKey:KuserAccountarea];
            [[NSUserDefaults standardUserDefaults] setObject:address forKey:KuserAccountAdress];
            
            // 给需要“登录”动作的页面们一对多发送通知 登出亦然
            [[NSNotificationCenter defaultCenter] postNotificationName:@"USERDIDLOGIN" object:self userInfo:nil];
            // 商城重新加载处理
            [[NSNotificationCenter defaultCenter] postNotificationName:@"duiba-load-WebView" object:self userInfo:nil];
 
            //积分入库
            FounderIntegralRequest *IntegralRequest = [[FounderIntegralRequest alloc] init];
            NSString *dateSign = [NSString stringWithFormat:@"LoginDate-%@",[Global userId]];
            NSDate *loginDate = [[NSUserDefaults standardUserDefaults] objectForKey:dateSign];
            if ([IntegralRequest isSameDay:loginDate date2:[NSDate date]]) {
                [Global showTip:NSLocalizedString(@"登录成功",nil)];
            }else{
                [IntegralRequest addIntegralWithUType:UTYPE_LOGIN integralBlock:^(NSDictionary *integralDict) {
                    
                    if (!integralDict || ![[integralDict objectForKey:@"success"] boolValue]) {
                        [Global showTip:NSLocalizedString(@"登录成功",nil)];
                    }else{
                        NSInteger score = [[integralDict objectForKey:@"score"] integerValue];
                        if (score) {//score分数不为0提醒
                            [Global showTip:[NSString stringWithFormat:@"%@，%@+%ld", NSLocalizedString(@"登录成功", nil), [AppConfig sharedAppConfig].integralName, (long)score]];
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"duiba-load-WebView" object:self userInfo:nil];
                        }else{
                            [Global showTip:NSLocalizedString(@"登录成功",nil)];
                            [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:dateSign];
                        }
                    }
                    
                }];
            }
            if (self.delegate) {
                [self.navigationController popViewControllerAnimated:NO];
                [self.delegate loginFinished];
            }else{
                if (self.isNavBack) {
                    [self.navigationController popViewControllerAnimated:YES];
                }else{
                    //判断block回调是否存在
                        if (_isRegister) {
                            ChangeUserInfoController *controller = [[ChangeUserInfoController alloc]init];
                            [self presentViewController:[Global controllerToNav:controller] animated:YES completion:nil];
                            __weak typeof(self) weakSelf = self;
                            controller.changeUserInfoSuccessBlock = ^(){
                                __strong typeof(weakSelf) strongSelf = weakSelf;
                                strongSelf.loginSuccessBlock(strongSelf);
                                [strongSelf goPrePage];
                            };
                        }else {
                            if (self.loginSuccessBlock) {
                                self.loginSuccessBlock();
                            }
                            [self performSelector:@selector(goPrePage) withObject:nil afterDelay:1];
                        }
                    
                }
            }
        }
        else{
            if (self.loginFailedBlock) {
                self.loginFailedBlock(self);
            }
            NSString *errorInfo = [dict objectForKey:@"msg"];
            if ([errorInfo isEmpty]) {
                [Global showTipNoNetWork];
            }
            else{
                [Global showTip:errorInfo];
            }
        }
    }];
    
    [request setFailedBlock:^(NSError *error) {
        [Global showTipNoNetWork];
        if (self.loginFailedBlock) {
            self.loginFailedBlock(self);
        }
    }];
    
    [request startAsynchronous];
}

-(void)forgetPassWord:(UIButton *)sender
{
    
    YXResetViewController *controller = [[YXResetViewController alloc]init];
    if (self.phoneTextField.text.length) {
        controller.phoneNum = self.phoneTextField.text;
    }
    controller.isForgetPassWord = YES;
    [self.navigationController pushViewController:controller animated:YES];
    
}

-(void)goPrePage
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)thirdPartyButtonClicked:(UserColumnButton *)sender
{
    // 关闭页面事件交互，禁止用户点击返回(销毁页面致没获取用户信息)
    [self closeAllUserInteraction:NO];
    UMSocialPlatformType share = (UMSocialPlatformType)(sender.tag - 3000);
    [self loginWithUMShareType:share];
}

- (void)loginWithUMShareType:(UMSocialPlatformType)shareType
{
    [[UMSocialManager defaultManager] getUserInfoWithPlatform:shareType currentViewController:nil completion:^(id result, NSError *error) {
        if(error){
            [self closeAllUserInteraction:YES];
            NSString *errorMsg = [NSString stringWithFormat:@"Get info fail:\n%@", error];
                [Global showTip:errorMsg];
        }else{
            if ([result isKindOfClass:[UMSocialUserInfoResponse class]]) {
                UMSocialUserInfoResponse *response = result;
                [self saveLocalUserInfo:response withType:shareType];
                [self thirdPartyUserRegisterRequest:response withShareType:shareType];
            }
        }
    }];
}

/*
-(void)loginWithShareType:(SSDKPlatformType)sharetype
{
    
    [ShareSDK getUserInfo:sharetype onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error)
     {
         if (state == SSDKResponseStateSuccess)
         {
             [self saveLocalUserInfo:user withType:sharetype];
             [self thirdPartyUserRegisterRequest:user withShareType:sharetype];
         }
         else
         {
             [self closeAllUserInteraction:YES];
             NSString *errorMsg = [error.userInfo objectForKey:@"error_message"];
             if(errorMsg)
                 [Global showTip:errorMsg];
         }
     }];
}
*/

/**
 *  保存用户信息到本地
 *
 *  @param userInfo 用户信息
 */
-(void)saveLocalUserInfo:(UMSocialUserInfoResponse *)userInfo withType:(UMSocialPlatformType)sharetype
{
    [[NSUserDefaults standardUserDefaults] setObject:userInfo.uid forKey:KuserAccountssoCode];
    [[NSUserDefaults standardUserDefaults] setObject:userInfo.name forKey:KuserAccountNickName];
    [[NSUserDefaults standardUserDefaults] setObject:userInfo.iconurl forKey:KuserAccountFace];
    [self closeAllUserInteraction:YES];
}

- (void)thirdPartyUserRegisterRequest:(UMSocialUserInfoResponse *)userInfo withShareType:(UMSocialPlatformType)sharetype
{
    [Global showTipAlways:NSLocalizedString(@"授权中", nil)];
    NSString *type = @"";
    
    if (sharetype == UMSocialPlatformType_Sina) {
        type = @"1";
    }
    else if(sharetype == UMSocialPlatformType_QQ)
    {
        type = @"2";
    }
    else if(sharetype == UMSocialPlatformType_WechatSession)
    {
        type = @"3";
    }
    else if(sharetype == UMSocialPlatformType_Facebook)
    {
        type = @"4";
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@/api/loginByOtherEx", [AppConfig sharedAppConfig].serverIf];
    NSURL *url = [NSURL URLWithString:urlString];
    HttpRequest *request = [HttpRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    
    NSString *code = [[NSUserDefaults standardUserDefaults] objectForKey:KuserAccountssoCode];
    NSString *faceUrl = [[NSUserDefaults standardUserDefaults] objectForKey:KuserAccountFace];
    NSString *nickName = [[NSUserDefaults standardUserDefaults] objectForKey:KuserAccountNickName];
    //NSString *informString = [NSString stringWithFormat:@"sid=%@&code=%@&nickName=%@&uType=%@&faceUrl=%@&deviceID=%@",[AppConfig sharedAppConfig].sid,code,nickName , type, faceUrl, [GeTuiSdk clientId]];
    NSString *informString = [NSString stringWithFormat:@"sid=%@&code=%@&nickName=%@&uType=%@&faceUrl=%@&deviceID=%@",[AppConfig sharedAppConfig].sid,code,nickName , type, faceUrl, @"测试id"];
    NSString *sign = [AESCrypt encrypt:[NSString stringWithFormat:@"%@%@%@",[AppConfig sharedAppConfig].sid,code,nickName] password:key];
    informString = [NSString stringWithFormat:@"%@&sign=%@",informString,sign];
    //(sid+code+nickName)
    informString = [informString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *informData = [informString dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:informData];
    __weak typeof(self) weakSelf = self;
    [request setCompletionBlock:^(NSData *data) {
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers  error:nil];
        if ([[dict objectForKey:@"success"] boolValue])
        {
            [Global showTip:NSLocalizedString(@"授权成功", nil)];
            NSString *uid = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"uid"] intValue]];
            [[NSUserDefaults standardUserDefaults] setObject:uid forKey:KuserAccountUserId];
            if ([[dict objectForKey:@"mobile"] isKindOfClass:[NSNull class]]) {
                [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:KuserAccountPhone];
            }
            else
            {
                [[NSUserDefaults standardUserDefaults] setObject:[dict objectForKey:@"mobile"] forKey:KuserAccountPhone];
            }
            
            [[NSUserDefaults standardUserDefaults] setObject:[dict objectForKey:@"nickName"] forKey:KuserAccountNickName];
            [[NSUserDefaults standardUserDefaults] setObject:[dict objectForKey:@"faceUrl"] forKey:KuserAccountFace];
            [[NSUserDefaults standardUserDefaults] setObject:[dict objectForKey:@"address"] forKey:KuserAccountAdress];
            NSString *scores = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"scores"] intValue]];
            [[NSUserDefaults standardUserDefaults] setObject:scores forKey:[NSString stringWithFormat:@"%@%@",uid,KuserAccountMoneyStr]];
            NSString *inviteCode = [dict objectForKey:@"inviteCode"];
            if (!inviteCode){
                inviteCode = @"";
            }
            [[NSUserDefaults standardUserDefaults] setObject:inviteCode forKey:KuserAccountInviteCode];
            [[NSUserDefaults standardUserDefaults] setObject:type forKey:KuserAccountType];
            
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [self.delegate loginFinished];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"duiba-load-WebView" object:self userInfo:nil];
            //积分入库
            FounderIntegralRequest *IntegralRequest = [[FounderIntegralRequest alloc] init];
            //如果是第一次第三方登录，积分以注册计数
            NSString * phone = ![NSString isNilOrEmpty:dict[@"mobile"]] ? dict[@"mobile"] : @"";
            if ([[dict objectForKey:@"firstRegister"] boolValue]) {
                if((!phone.length || phone == nil) && [AppConfig sharedAppConfig].isNeedBindPhoneNumber){
                    self.clearInfo = YES;
                    FZChangePhoneNumberController * changeVC = [[FZChangePhoneNumberController alloc]init];
                    changeVC.title = NSLocalizedString(@"绑定手机号", nil);
                    changeVC.isPush= NO;
                    changeVC.isFromeLogin = YES;
                    changeVC.bindSuccessCallBack = ^(NSString *phone) {
                        [IntegralRequest addIntegralWithUType:UTYPE_REGISTER integralBlock:^(NSDictionary *integralDict) {
                            
                            if (!integralDict || ![[integralDict objectForKey:@"success"] boolValue]) {
                                [Global showTip:NSLocalizedString(@"注册并登录成功",nil)];
                                XYLog(@"第三方注册积分错误:%@", [integralDict objectForKey:@"msg"]);
                            }else{
                                NSInteger score = [[integralDict objectForKey:@"score"] integerValue];
                                if (score) {//score分数不为0提醒
                                    [Global showTip:[NSString stringWithFormat:@"%@，%@+%ld", NSLocalizedString(@"注册并登录成功",nil), [AppConfig sharedAppConfig].integralName,(long)score]];
                                    [[NSNotificationCenter defaultCenter] postNotificationName:@"duiba-load-WebView" object:self userInfo:nil];
                                }else{
                                    [Global showTip:NSLocalizedString(@"注册并登录成功",nil)];
                                }
                            }
                        }];
                        if (self.loginSuccessBlock) {
                            self.loginSuccessBlock();
                        }
                        
                    };
                    [weakSelf.navigationController pushViewController:changeVC animated:YES];
                    
                    return;
                }else{
                    [IntegralRequest addIntegralWithUType:UTYPE_REGISTER integralBlock:^(NSDictionary *integralDict) {
                        
                        if (!integralDict || ![[integralDict objectForKey:@"success"] boolValue]) {
                            [Global showTip:NSLocalizedString(@"注册并登录成功",nil)];
                            XYLog(@"第三方注册积分错误:%@", [integralDict objectForKey:@"msg"]);
                        }else{
                            NSInteger score = [[integralDict objectForKey:@"score"] integerValue];
                            if (score) {//score分数不为0提醒
                                [Global showTip:[NSString stringWithFormat:@"%@，%@+%ld", NSLocalizedString(@"注册并登录成功",nil), [AppConfig sharedAppConfig].integralName,(long)score]];
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"duiba-load-WebView" object:self userInfo:nil];
                            }else{
                                [Global showTip:NSLocalizedString(@"注册并登录成功",nil)];
                            }
                        }
                    }];
                }
            }else if((!phone.length || phone == nil) && [AppConfig sharedAppConfig].isNeedBindPhoneNumber){
                self.clearInfo = YES;
                FZChangePhoneNumberController * changeVC = [[FZChangePhoneNumberController alloc]init];
                changeVC.title = NSLocalizedString(@"绑定手机号", nil);
                changeVC.isPush= NO;
                changeVC.isFromeLogin = YES;
                changeVC.bindSuccessCallBack = ^(NSString * phone) {
                    if (self.loginSuccessBlock) {
                        self.loginSuccessBlock();
                    }
                };
               
                [weakSelf.navigationController pushViewController:changeVC animated:YES];
                
                return;
            }else{
                NSString *dateSign = [NSString stringWithFormat:@"LoginDate-%@",[Global userId]];
                NSDate *loginDate = [[NSUserDefaults standardUserDefaults] objectForKey:dateSign];
                if ([IntegralRequest isSameDay:loginDate date2:[NSDate date]]) {
                    [Global showTip:NSLocalizedString(@"登录成功",nil)];
                }
                else
                {
                    [IntegralRequest addIntegralWithUType:UTYPE_LOGIN integralBlock:^(NSDictionary *integralDict) {
                        
                        if (!integralDict || ![[integralDict objectForKey:@"success"] boolValue]) {
                            [Global showTip:NSLocalizedString(@"登录成功",nil)];
                            XYLog(@"登录积分错误:%@", [integralDict objectForKey:@"msg"]);
                        }else{
                            NSInteger score = [[integralDict objectForKey:@"score"] integerValue];
                            if (score) {//score分数不为0提醒
                             [Global showTip:[NSString stringWithFormat:@"%@，%@+%ld", NSLocalizedString(@"登录成功",nil), [AppConfig sharedAppConfig].integralName, (long)score]];
                            }else{
                               [Global showTip:NSLocalizedString(@"登录成功",nil)];
                               [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:dateSign];
                            }
                        }
                        
                    }];
                }
            }
        }
        else{
            [Global showTip:NSLocalizedString(@"授权失败", nil)];
            return;
        }
        ChangeUserInfoController * change = [[ChangeUserInfoController alloc]init];
        change.isFromeLogin = YES;
        change.changeUserInfoSuccessBlock = ^{
            if (self.loginSuccessBlock) {
                self.loginSuccessBlock();
            }
        };
        [self.navigationController pushViewController:change animated:YES];
    }];
    
    [request setFailedBlock:^(NSError *error) {
        [Global showTip:NSLocalizedString(@"登录失败",nil)];
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [request startAsynchronous];
}
-(void)logSuccessBack{
    if (self.delegate) {
        if (self.isNavBack) {
            [self.navigationController popViewControllerAnimated:YES];
        }else
        {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
    else
    {
        if (self.isNavBack) {
            [self.navigationController popViewControllerAnimated:YES];
        }else
        {
            //判断block回调是否存在
            if (self.loginSuccessBlock) {
                self.loginSuccessBlock(self);
            }
            else{
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }
    }
}
#pragma mark - 禁止整个页面交互
//整个界面事件的禁止
- (void)closeAllUserInteraction:(BOOL)isOpen
{
    self.navigationController.navigationBar.userInteractionEnabled = isOpen;//将nav事件禁止
    self.tabBarController.tabBar.userInteractionEnabled = isOpen;//将tabbar事件禁止
    self.view.userInteractionEnabled = isOpen;//界面
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self logIn:nil];
    return YES;
}

- (void)showAlwetController:(NSString *)str
{
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:str message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleCancel handler:nil];
    
    [alertVC addAction:cancleAction];
    [self presentViewController:alertVC animated:YES completion:nil];
}

@end
