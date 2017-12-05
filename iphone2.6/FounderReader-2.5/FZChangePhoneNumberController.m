//
//  FZChangePhoneNumberController.m
//  FounderReader-2.5
//
//  Created by mac on 2017/6/26.
//

#import "FZChangePhoneNumberController.h"
#import "YXLoginViewController.h"
#import "AppConfig.h"
#import "Defines.h"
#import "UserAccountDefine.h"
#import "YZSDK.h"
#import "Global.h"
#import "FDAreaPickerViewController.h"
#import "FDAreaPickerModel.h"
#import "ColorStyleConfig.h"
#import "UIView+Extention.h"
#import "NewsListConfig.h"
#import "UIAlertView+Helper.h"
#import "NSStringAdditions.h"
#import "RegexKitLite.h"
#import "AESCrypt.h"
#import "UIDevice-Reachability.h"
#import "ChangeUserInfoController.h"
#import "NSString+MD5Addition.h"
#import "ChangeUserInfoController.h"

#define kTimeCount_60 60
#define kTimeCount_300 300

@interface FZChangePhoneNumberController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,UIAlertViewDelegate>
{
   int timerCount;
    NSTimer * SMStimer;
}
@property (nonatomic,strong) UITableView * contentTableView;
@property (nonatomic,strong) UILabel * areaLabel;
@property (nonatomic,strong) FDAreaPickerModel * areaModel;
@property (nonatomic,strong) UITextField * phoneTF;
@property (nonatomic,strong) UITextField * codeTF;
@property (nonatomic,strong) UIButton * completeBtn;
@property (nonatomic,strong) UIButton * getCheckCodeButton;
@property (nonatomic,strong) NSString * phoneNumber;
@property (nonatomic,assign) BOOL isGetVerifyCodeByAli;
@property (nonatomic,assign) BOOL isChangePhone;
@property (nonatomic,assign) BOOL bindSuccess;
@end

@implementation FZChangePhoneNumberController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUI];

}
-(void)setUI{
    
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],UITextAttributeTextColor,nil]];
    self.view.backgroundColor = [UIColor whiteColor];
    NSString *phone = [[NSUserDefaults standardUserDefaults] objectForKey:KuserAccountPhone];
    if (phone.length) {
        self.isChangePhone = YES;
    }
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftButton setImage:[UIImage imageNamed:@"nav_bar_back"] forState:UIControlStateNormal];
    [leftButton sizeToFit];
    leftButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    leftButton.contentEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
    [leftButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    self.contentTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kSWidth, kSHeight-kStatusBarHeight-kNavHeight)];
    self.contentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.contentTableView.rowHeight = 50 * proportion;
    self.contentTableView.delegate = self;
    self.contentTableView.dataSource = self;
    [self.view addSubview:self.contentTableView];
    
    UIView * footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSWidth, kSHeight)];
    self.contentTableView.tableFooterView = footView;
    self.completeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.completeBtn.frame = CGRectMake(20*proportion, 20*proportion, self.view.bounds.size.width-40*proportion, 36*proportion);
    self.completeBtn.layer.cornerRadius = 3*proportion;
    self.completeBtn.backgroundColor = [ColorStyleConfig sharedColorStyleConfig].login_button_color;
    [self.completeBtn addTarget:self action:@selector(completeBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.completeBtn setTitle:NSLocalizedString(@"确认",nil) forState:UIControlStateNormal];
    [footView addSubview:self.completeBtn];
    UITapGestureRecognizer * resignTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(resignTapClicked)];
    [self.contentTableView addGestureRecognizer:resignTap];
}
- (FDAreaPickerModel *)areaModel {
    if (!_areaModel) {
        _areaModel = [[FDAreaPickerModel alloc] init];
        _areaModel.code = [AppConfig sharedAppConfig].defaultAreaCode;
        _areaModel.country = NSLocalizedString([AppConfig sharedAppConfig].defaultAreaCountry,nil);
    }
    return _areaModel;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"kcell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"kcell"];
    }
    UIImageView * iconView = [[UIImageView alloc]initWithFrame:CGRectMake(30, 10, 50*proportion-20, 50*proportion-20)];
    [cell.contentView addSubview:iconView];
    if (indexPath.row == 0) {
        self.areaLabel = [[UILabel alloc]initWithFrame:CGRectMake(70*proportion, 0, kSWidth - 140, 50*proportion)];
        self.areaLabel.font = [UIFont systemFontOfSize:14];
        self.areaLabel.text = self.areaModel.country;
        self.areaLabel.userInteractionEnabled = YES;
        UITapGestureRecognizer *regionTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(regionClicked:)];
        [self.areaLabel addGestureRecognizer:regionTap];
        iconView.image = [UIImage imageNamed:@"userRegion"];
        [cell.contentView addSubview:self.areaLabel];
    }else if (indexPath.row == 1){
        self.phoneTF = [[UITextField alloc]initWithFrame:CGRectMake(70*proportion, 0, self.view.bounds.size.width-90, 50*proportion)];
        self.phoneTF.font = [UIFont systemFontOfSize:14];
        self.phoneTF.keyboardType = UIKeyboardTypeNumberPad;
        self.phoneTF.placeholder = NSLocalizedString(@"请输入手机号",nil);
        iconView.image = [UIImage imageNamed:@"userImage"];
        [cell addSubview:self.phoneTF];
    }else if (indexPath.row == 2){
        self.codeTF = [[UITextField alloc]initWithFrame:CGRectMake(70*proportion, 0, kSWidth-70-10-90 , 50*proportion)];
        self.codeTF.font = [UIFont systemFontOfSize:14];
        self.codeTF.keyboardType = UIKeyboardTypeNumberPad;
        self.codeTF.placeholder = NSLocalizedString(@"请输入短信验证码",nil);
        iconView.image = [UIImage imageNamed:@"securitycode"];
        self.getCheckCodeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.getCheckCodeButton.frame = CGRectMake(self.view.bounds.size.width - 65-20*proportion, (50-20)/2, 65, 30*proportion);
        self.getCheckCodeButton.centerY = 25*proportion;
        self.getCheckCodeButton.layer.cornerRadius = 4;
        self.getCheckCodeButton.layer.borderWidth = 1;
        self.getCheckCodeButton.layer.borderColor = /*[UIColor colorWithRed:156/255.0 green:202/255.0 blue:241/255.0 alpha:.5].CGColor*/[ColorStyleConfig sharedColorStyleConfig].login_button_color.CGColor;
        [self.getCheckCodeButton setTitle:NSLocalizedString(@"获取",nil) forState:UIControlStateNormal];
        self.getCheckCodeButton.titleLabel.font = [UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleCellDateFontSize];
        [self.getCheckCodeButton setTitleColor:/*[UIColor colorWithRed:14/255.0 green:114/255.0 blue:254/255.0 alpha:1]*/[ColorStyleConfig sharedColorStyleConfig].login_button_color
                                      forState:UIControlStateNormal];
        
        [self.getCheckCodeButton addTarget:self action:@selector(getCodeButtonClicked)
                          forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:self.getCheckCodeButton];
        [cell addSubview:self.codeTF];
    }
    //cell的分割线颜色的更改
    UIView *sep = [[UIView alloc] initWithFrame:CGRectMake(10, 50*proportion, kSWidth-20, 0.5)];
    sep.backgroundColor=[UIColor colorWithRed:221/255.0 green:221/255.0 blue:221/255.0 alpha:1];
    [cell.contentView addSubview:sep];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
//MARK: --action
-(void)goBack{
    NSString *phone = [[NSUserDefaults standardUserDefaults] objectForKey:KuserAccountPhone];
    if ([AppConfig sharedAppConfig].isNeedBindPhoneNumber && !phone.length && !self.isFromeLogin) {//退出当前帐号去登录页面
        [self clearInfo];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"USERDIDLOGOUT" object:nil];
        if (self.isPush) {
            [self.navigationController popViewControllerAnimated:NO];
        }else{
            [self dismissViewControllerAnimated:NO completion:nil];
        }
        if (self.cancleBindCallBack) {
            self.cancleBindCallBack();
        }
        return;
    }else{
        if (self.isPush || self.isFromeLogin) {
            if (self.isFromeLogin && !self.bindSuccess) {
                [self clearInfo];
                [Global showTip:NSLocalizedString(@"没有绑定手机号，将退出第三方登录", nil)];
            }
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

-(void)clearInfo{
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
- (void)regionClicked:(UITapGestureRecognizer *)tap {
    __weak __typeof (self)weakSelf = self;
    FDAreaPickerViewController *vc = [[FDAreaPickerViewController alloc] initWithDefaultModel:self.areaModel FDAreaPickerBlock:^(FDAreaPickerModel *model) {
        weakSelf.areaModel = model;
        weakSelf.areaLabel.text = model.country;
    }];
    
    [self.navigationController pushViewController:vc animated:YES];
}
-(void)resignTapClicked{
    [self.phoneTF resignFirstResponder];
    [self.codeTF resignFirstResponder];
}
-(void)completeBtnClicked{
    
    [self.view endEditing:YES];
    
    if(self.phoneTF.text.length == 0){
        [UIAlertView showAlert:NSLocalizedString(@"请输入手机号",nil)];
        return;
    }
    
    if(self.codeTF.text.length == 0){
        [UIAlertView showAlert:NSLocalizedString(@"请输入短信验证码",nil)];
        return;
    }
    
 if (![self.codeTF.text isEqualToString:NSLocalizedString(@"您的手机号已验证成功",nil)]) {
        
        if (self.codeTF.text.length < 4 || self.codeTF.text.length > 6) {
            [UIAlertView showAlert:NSLocalizedString(@"请输入4~6位正确的验证码",nil)];
            self.codeTF.text = nil;
            return;
        }
        // 去验证验证码
        [self checkVerifyCode];
 }
    
   
}
- (void)checkVerifyCode {
     [Global showTipAlways:NSLocalizedString(@"发送中...",nil)];
    if (_isGetVerifyCodeByAli) {
        NSString *verifyCode = [[NSUserDefaults standardUserDefaults] objectForKey:@"verifyCode"];
        [self.codeTF.text isEqualToString:verifyCode] ? [self verifyCodeSuccess] : [self verifyCodeFailed];
    } else {
        NSString *areaCode = self.areaModel.code;
        if ([areaCode hasPrefix:@"00"]) {
            areaCode = [areaCode substringFromIndex:2];
        }
    
//        [SMSSDK commitVerificationCode:self.codeTF.text phoneNumber:self.phoneTF.text zone:areaCode result:^(NSError *error) {
//            error == NULL ? [self verifyCodeSuccess] : [self verifyCodeFailed];
//        }];
    }
}
- (void)verifyCodeSuccess
{
    [Global hideTip];
    XYLog(@"验证成功");
    [SMStimer invalidate];
    SMStimer = nil;
    timerCount = 0;

    [self sendUserInfo];
}

- (void)savePhoneNum:(NSString *)phone andCaptchaStatus:(NSString *)captchaStatus {
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [user setObject:captchaStatus forKey:phone];
    [user setObject:self.phoneTF.text forKey:KuserAccountPhone];
    
}
- (void)verifyCodeFailed
{
    [Global showTip:NSLocalizedString(@"验证码输入错误，请重新输入",nil)];
    self.codeTF.text = nil;
}
-(void)getCodeButtonClicked{
    if (![self isPhoneNumber:self.phoneTF.text]) {
        return;
    }
    [self.view endEditing:YES];
    
    if (![self isPhoneNumberStyle:self.phoneTF.text]) {
        return;
    }
    
    // 先去验证该号码是否是之前已验证过的
//    if ([self verifyPhone]) {
//        return;
//    }
    
    if (![UIDevice networkAvailable]) {
        return;
    }
    
    UIAlertView* alert=[[UIAlertView alloc] initWithTitle:self.phoneTF.text
                                                  message:NSLocalizedString(@"获取验证码到上面的手机号码",nil)
                                                 delegate:self
                                        cancelButtonTitle:NSLocalizedString(@"取消",nil)
                                        otherButtonTitles:NSLocalizedString(@"确认",nil), nil];
    [alert show];
    
}
- (BOOL)verifyPhone
{
    if ([[self open] integerValue]) {
        [self.getCheckCodeButton setTitle:NSLocalizedString(@"已验证", nil) forState:UIControlStateNormal];
        self.codeTF.text = NSLocalizedString(@"您的手机号已验证成功",nil);
        self.codeTF.enabled = NO;
        self.getCheckCodeButton.userInteractionEnabled = NO;
        self.codeTF.userInteractionEnabled = NO;
        self.phoneTF.userInteractionEnabled = NO;
    }
    return [[self open] integerValue];
}
// ,取出对应号码的验证状态 1,成功 0,失败
- (NSString *)open {
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSString *str = [user objectForKey:self.phoneTF.text];
    return str;
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (1 == buttonIndex){
        [self getVerifyCode];
    }
}

/**
 *  获取验证码
 */
-(void)getVerifyCode
{
    [self closeGetCode];
    
    [Global showTipAlways:NSLocalizedString(@"发送中...",nil)];
    
    self.phoneNumber = self.phoneTF.text;
    /* 友盟SMS是免费的，第一次先用友盟进行短信验证，若【用户点击了重复获取】一律采用阿里大于 */
    if ([AppConfig sharedAppConfig].isOnlyAliDaYu) {
        [self getVerifyCodeByAli];
    }else {
        if ([self.getCheckCodeButton.titleLabel.text isEqualToString:NSLocalizedString(@"重新获取",nil)]) {
            if (self.areaModel.code != [AppConfig sharedAppConfig].defaultAreaCode) {
                self.phoneNumber = [self.areaModel.code stringByAppendingString:self.phoneTF.text];
            }
            [self getVerifyCodeByAli];
        }else {
            
            NSString *areaCode = self.areaModel.code;
            if ([areaCode hasPrefix:@"00"]) {
                areaCode = [areaCode substringFromIndex:2];
            }
            
//            [SMSSDK getVerificationCodeByMethod:SMSGetCodeMethodSMS phoneNumber:self.phoneNumber zone:areaCode customIdentifier:nil result:^(NSError *error) {
//                if (error == NULL) {
//                    // 若返回结果太慢，用户已经点击【重新获取】采用阿里大于后则不提示
//                    if (!_isGetVerifyCodeByAli) {
//                        [Global showTip:NSLocalizedString(@"获取验证码成功",nil)];
//                    }
//                }else{
//                    XYLog(@"验证码错误是:%@",error);
//                    if (error.code == 472 || error.code == 476 || error.code == 479 || error.code == 478 || error.code == 477 || error.code == 462 ||error.code == 463||error.code == 464 ||error.code == 465 ||error.code == 467) {
//                        [self getVerifyCodeByAli];
//                    }else{
//                        timerCount = _isGetVerifyCodeByAli ? kTimeCount_300 : kTimeCount_60;
//                        [Global showTip:NSLocalizedString(@"获取验证码失败",nil)];
//                    }
//                }
//            }];
        }
    }
}

// 从阿里大于获取短信验证
- (void)getVerifyCodeByAli
{
    _isGetVerifyCodeByAli = YES;
    
    NSString *urlString = [NSString stringWithFormat:@"%@/api/getSMSCode", [AppConfig sharedAppConfig].serverIf];
    NSURL *url = [NSURL URLWithString:urlString];
    
    HttpRequest *request = [HttpRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appName = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    
    NSString *sign = [AESCrypt encrypt:[NSString stringWithFormat:@"%@%@%@", [AppConfig sharedAppConfig].sid, appName, self.phoneTF.text] password:key];
    //(sid+appName+mobile)
    NSString * informString = [NSString stringWithFormat:@"sid=%@&appName=%@&mobile=%@&sign=%@", [AppConfig sharedAppConfig].sid,appName, self.phoneTF.text, sign];
    
    NSData *informData = [informString dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:informData];
    [request setCompletionBlock:^(NSData *data) {
        // 服务器传回正确验证码，用于后面与用户实际收到且输入的验证码做比对
        // 由于后台设定5分钟之类相同电话获取的验证码是一样的，且只是5分钟之内不会传回该相同验证码，本地需要存储起来第一次收到的验证码
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers  error:nil];
        if ([[dict objectForKey:@"success"] boolValue]){
            [Global showTip:NSLocalizedString(@"获取验证码成功",nil)];
            NSString *verifyCode = [AESCrypt decrypt:dict[@"code"] password:key];
            if (![NSString isNilOrEmpty: verifyCode]) {
                [[NSUserDefaults standardUserDefaults] setObject:verifyCode forKey:@"verifyCode"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        } else {
            if ([NSString isNilOrEmpty:dict[@"msg"]]) {
                [self showFailedUI:nil];
            } else {
                NSData *jsonData = [dict[@"msg"] dataUsingEncoding:NSUTF8StringEncoding];
                NSError *err;
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                    options:NSJSONReadingMutableContainers
                                                                      error:&err];
                if ([dic[@"msg"] containsString:@"5分钟"]) {
                    //提示用户5分钟之内，查看自己短信
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:[dic objectForKey:@"msg"] preferredStyle:UIAlertControllerStyleAlert];
                    [self presentViewController:alert animated:YES completion:nil];
                    //控制提示框显示的时间为2秒
                    [self performSelector:@selector(dismiss:) withObject:alert afterDelay:2.0];
                    timerCount = 0;
                    [SMStimer invalidate];
                    [self openGetCode];
                } else {
                    [self showFailedUI:nil];
                }
            }
        }
    }];
    
    [request setFailedBlock:^(NSError *error) {
        [self showFailedUI:error];
    }];
    
    [request startAsynchronous];
}

- (void)dismiss:(UIAlertController *)alert{
    [alert dismissViewControllerAnimated:YES completion:nil];
}

- (void)showFailedUI:(id)error
{
    XYLog(@"验证码错误是:%@",error);
    [Global showTipNoNetWork];
    [Global showTip:NSLocalizedString(@"获取验证码失败",nil)];
    timerCount = 0;
    [SMStimer invalidate];
    [self openGetCode];
}
-(void)closeGetCode
{
    self.getCheckCodeButton.userInteractionEnabled = NO;
    self.phoneTF.enabled = NO;
    SMStimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                target:self
                                              selector:@selector(updateTime)
                                              userInfo:nil
                                               repeats:YES];
}
-(void)updateTime
{
    timerCount++;
    NSInteger times = _isGetVerifyCodeByAli ? kTimeCount_300 : kTimeCount_60;
    if (timerCount >= times) {
        timerCount = 0;
        [SMStimer invalidate];
        [self openGetCode];
        return;
    }
    [self.getCheckCodeButton setTitle:[NSString stringWithFormat:@"%li%@",times - timerCount,NSLocalizedString(@"秒",nil)] forState:UIControlStateNormal];
}
-(void)openGetCode
{
    self.phoneTF.enabled = YES;
    self.codeTF.enabled = YES;
    [self.getCheckCodeButton setTitle:NSLocalizedString(@"重新获取",nil) forState:UIControlStateNormal];
    self.getCheckCodeButton.userInteractionEnabled = YES;
}
//MARK: --UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    CGPoint point = [textField convertPoint:CGPointZero toView:self.view.window];
    CGFloat moveHeight = point.y + textField.height + 214 + 20 - kSHeight;
    if (moveHeight > -64) {
        [UIView animateWithDuration:.3 animations:^{
            self.view.y = -64 - moveHeight;
        }];
        
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [UIView animateWithDuration:.3 animations:^{
        self.view.y = 64;
    }];
}
- (BOOL)isPhoneNumberStyle:(NSString *)phoneMain
{
    if ([NSString isNilOrEmpty:phoneMain]) {
        [UIAlertView showAlert:NSLocalizedString(@"您输入的手机号为空",nil)];
        return NO;
    }
    else
    {
        if ([phoneMain rangeOfString:@"@"].location != NSNotFound) {
            if (!([phoneMain rangeOfString:@".com"].location != NSNotFound || [phoneMain rangeOfString:@".cn"].location != NSNotFound)) {
                [UIAlertView showAlert:NSLocalizedString(@"请输入有效的邮箱",nil)];
                return NO;
            }
        }
        else if (phoneMain.length > 11){
            [UIAlertView showAlert:NSLocalizedString(@"请输入有效的手机号",nil)];
            return NO;
        }else if(phoneMain.length == 11){
            if (![phoneMain isMatchedByRegex:kPhoneNumberRegExp]) {
                [UIAlertView showAlert:NSLocalizedString(@"请输入有效的手机号",nil)];
                return NO;
            }
        }
        //长度低于11的也能获取验证码，因为澳门香港地区一般都少于11位
    }
    return YES;
}

- (BOOL)isPhoneNumber:(NSString *)phoneNum
{
    if ([NSString isNilOrEmpty:phoneNum]) {
        [UIAlertView showAlert:NSLocalizedString(@"您输入的手机号为空",nil)];
        return NO;
    }
    else if (![phoneNum isMatchedByRegex:kPhoneNumberRegExp]) {
        [UIAlertView showAlert:NSLocalizedString(@"请输入有效的手机号",nil)];
        return NO;
    }
    return YES;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void)sendUserInfo
{
    [Global showTipAlways:NSLocalizedString(@"发送中...",nil)];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/api/modifyUserInfo", [AppConfig sharedAppConfig].serverIf];
    
    NSURL *url = [NSURL URLWithString:urlString];
    HttpRequest *request = [HttpRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    
    NSString *userId = [Global userId];
    
    NSString *infoString = nil;
    
    NSString *password = [[NSUserDefaults standardUserDefaults] objectForKey:KuserAccountLoginPassWord];
    
    //第三方登录账号，密码为第三方的OpenID
    if([Global isThirtyLogin]){
        password = [[NSUserDefaults standardUserDefaults] objectForKey:KuserAccountssoCode];
    }else{
        password = [password stringFromMD5];
    }
    infoString = [NSString stringWithFormat:@"sid=%@&uid=%@&password=%@",[AppConfig sharedAppConfig].sid, userId,password];

    if ([Global isThirtyLogin]) {
        infoString = [NSString stringWithFormat:@"%@&otherPhone=%@",infoString,self.phoneTF.text];
    }
    __weak typeof(self) weakSelf = self;
    NSData *infoData = [infoString dataUsingEncoding:NSUTF8StringEncoding];
    
    [request setHTTPBody:infoData];
    
    [request setCompletionBlock:^(NSData *data) {
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers  error:nil];
        if ([[dict objectForKey:@"success"] boolValue]){
            weakSelf.codeTF.text = NSLocalizedString(@"您的手机号已验证成功",nil);
            [weakSelf.getCheckCodeButton setTitle:NSLocalizedString(@"已验证", nil) forState:UIControlStateNormal];
            weakSelf.getCheckCodeButton.userInteractionEnabled = NO;
            weakSelf.codeTF.userInteractionEnabled = NO;
            self.bindSuccess = YES;
            if (weakSelf.isChangePhone) {
                 [Global showTip:NSLocalizedString(@"手机号已更换成功",nil)];
            }else{
                [Global showTip:NSLocalizedString(@"手机号已绑定成功",nil)];
            }
            [[NSUserDefaults standardUserDefaults] setObject:weakSelf.phoneTF.text forKey:KuserAccountPhone];
            // 将该手机号验证成功状态存到本地
            [weakSelf savePhoneNum:weakSelf.phoneTF.text andCaptchaStatus:@"1"];
            if (weakSelf.bindSuccessCallBack && !weakSelf.isFromeLogin) {
                weakSelf.bindSuccessCallBack(weakSelf.phoneTF.text);
            }
            if (weakSelf.isFromeLogin) {
                ChangeUserInfoController * change = [[ChangeUserInfoController alloc]init];
                change.isFromeLogin = YES;
                change.changeUserInfoSuccessBlock = ^{
                    if (weakSelf.bindSuccessCallBack) {
                        weakSelf.bindSuccessCallBack(weakSelf.phoneTF.text);
                    }
                };
                [self.navigationController pushViewController:change animated:YES];
                return ;
            }
            if (weakSelf.isPush) {
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }else{
                [weakSelf dismissViewControllerAnimated:YES completion:nil];
            }
        }else{
            NSString *errorInfo = [dict objectForKey:@"msg"];
            [Global showTip:errorInfo];
        }
    }];
    
    [request setFailedBlock:^(NSError *error) {
        
        if (weakSelf.isChangePhone) {
            [Global showTip:NSLocalizedString(@"手机号更换失败",nil)];
        }else{
            [Global showTip:NSLocalizedString(@"手机号绑定失败",nil)];
        }
    }];
    
    [request startAsynchronous];
}

@end
