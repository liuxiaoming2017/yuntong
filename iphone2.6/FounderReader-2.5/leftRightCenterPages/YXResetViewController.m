 //
//  YXRegistViewController.m
//  FounderReader-2.5
//
//  Created by ld on 14-12-25.
//
//
#import "ColorStyleConfig.h"
#import "YXResetViewController.h"
#import "UIDevice-Reachability.h"
#import "NSStringAdditions.h"
#import "HttpRequest.h"
#import "AppStartInfo.h"
#import "NSString+MD5Addition.h"
#import "AppConfig.h"
#import "CommentConfig.h"
#import "UserAccountDefine.h"
//#import "SMS_SDK/SMS_SDK.h"
#import "NSStringAdditions.h"
#import "RegexKitLite.h"
#import "NewsListConfig.h"
#import "UIView+Extention.h"
#import "ColumnBarConfig.h"
#import "AESCrypt.h"
#import "NSString+Base64.h"
#import "NSData+Base64.h"
#import "FDPickerView.h"
#import "FDAreaPickerViewController.h"
#define TEXTFILD_X 70
#define kTimeCount_60 60
#define kTimeCount_300 300

@interface YXResetViewController ()
{
    NSInteger timerCount;
    NSTimer *SMStimer;
    BOOL _isGetVerifyCodeByAli;
    FDPickerView *_pickView;
    NSString *_areaCode;
}
@property (nonatomic, retain) UITextField *mailTextField;
@property (nonatomic, retain) UILabel *regionLabel; // 地区
@property (nonatomic, retain) UITextField *phoneTextField;
@property (nonatomic, retain) UITextField *checkTextField;
@property (nonatomic, retain) UITextField *nicknameTextField;
@property (nonatomic, retain) UITextField *pwTextField;
@property (nonatomic, retain) UITextField *pw2TextField;

@property (nonatomic, retain) UIButton *getCheckCodeButton;

@property (strong, nonatomic) FDAreaPickerModel *areaModel;
@property (copy, nonatomic) NSString *phoneNumber;

@end

@implementation YXResetViewController

@synthesize mailTextField,phoneTextField,pwTextField,pw2TextField,checkTextField,nicknameTextField;
@synthesize getCheckCodeButton;
@synthesize isForgetPassWord;
@synthesize phoneNum;

-(void)dealloc
{
    self.nicknameTextField = nil;
    self.mailTextField = nil;
    self.phoneTextField = nil;
    self.pwTextField = nil;
    self.pw2TextField = nil;
    self.checkTextField = nil;
//    [self invalidateTime];
    self.phoneNum = nil;
//    [super dealloc];
}

- (FDAreaPickerModel *)areaModel {
    if (!_areaModel) {
        _areaModel = [[FDAreaPickerModel alloc] init];
        _areaModel.code = [AppConfig sharedAppConfig].defaultAreaCode;
        _areaModel.country = NSLocalizedString([AppConfig sharedAppConfig].defaultAreaCountry,nil);
    }
    return _areaModel;
}

- (void)invalidateTime
{
    
    if (SMStimer)
    {
        if (SMStimer.isValid)
        {
            [SMStimer invalidate];
        }
        
        SMStimer = nil;
    }
}

- (id)init
{
    self = [super init];
    if (self) {
       
        self.isForgetPassWord = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // 修改页面标题颜色
    NSMutableDictionary *textTitleAttrs = [NSMutableDictionary dictionary];
    textTitleAttrs[NSForegroundColorAttributeName] = [ColorStyleConfig sharedColorStyleConfig].navbar_titlecolor_selected;
    textTitleAttrs[NSFontAttributeName] = [UIFont systemFontOfSize:18];
    self.navigationController.navigationBar.titleTextAttributes = textTitleAttrs;
    
    self.tableView.scrollEnabled = NO;

    //      地区
    self.regionLabel = [[UILabel alloc] initWithFrame:CGRectMake(TEXTFILD_X, 0, kSWidth-2*TEXTFILD_X, 50*proportion)];
    self.regionLabel.font = [UIFont systemFontOfSize:14];
    self.regionLabel.text = self.areaModel.country;
    self.regionLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *regionTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(regionClicked:)];
    [self.regionLabel addGestureRecognizer:regionTapGestureRecognizer];
    
    // 手机号码
    phoneTextField = [[UITextField alloc]initWithFrame:CGRectMake(TEXTFILD_X, 0, self.view.bounds.size.width-65, 50*proportion)];
    self.phoneTextField.font = [UIFont systemFontOfSize:14];
    self.phoneTextField.keyboardType = UIKeyboardTypeNumberPad;
    self.phoneTextField.placeholder = NSLocalizedString(@"请输入手机号",nil);
    if (phoneNum.length) {
        self.phoneTextField.text = phoneNum;
    }
    // 在手机号输入完成之时，验证手机号是否之前通过验证
    //[self.phoneTextField addTarget:self action:@selector(verifyPhone) forControlEvents:UIControlEventEditingDidEnd];
    
    // 验证码
    checkTextField = [[UITextField alloc]initWithFrame:CGRectMake(TEXTFILD_X, 0, kSWidth-70-10-TEXTFILD_X , 50*proportion)];
    self.checkTextField.font = [UIFont systemFontOfSize:14];
    self.checkTextField.keyboardType = UIKeyboardTypeNumberPad;
    self.checkTextField.placeholder = NSLocalizedString(@"请输入短信验证码",nil);
    
    // 密码
    pwTextField = [[UITextField alloc]initWithFrame:CGRectMake(TEXTFILD_X, 0, self.view.bounds.size.width-65, 50*proportion)];
    self.pwTextField.font = [UIFont systemFontOfSize:14];
    self.pwTextField.keyboardType = UIKeyboardTypeEmailAddress;
    self.pwTextField.placeholder = NSLocalizedString(@"请输入密码(6~25位,数字和字母均可)",nil);
    if (self.isForgetPassWord) {
        self.pwTextField.placeholder = NSLocalizedString(@"请输入新密码(6~25位,数字和字母均可)",nil);
    }
    self.pwTextField.secureTextEntry = YES;
 
    // 确认密码
    pw2TextField = [[UITextField alloc]initWithFrame:CGRectMake(TEXTFILD_X, 0, self.view.bounds.size.width-65, 50*proportion)];
    self.pw2TextField.font = [UIFont systemFontOfSize:14];
    self.pw2TextField.keyboardType = UIKeyboardTypeEmailAddress;
    self.pw2TextField.placeholder = NSLocalizedString(@"请确认密码",nil);
    self.pw2TextField.secureTextEntry = YES;
    [self.view addSubview:self.pw2TextField];
    
  
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.height, 80)];
    self.tableView.tableFooterView = footView;
    footView.userInteractionEnabled = YES;
    
    UIButton *registButton = [UIButton buttonWithType:UIButtonTypeCustom];
    registButton.frame = CGRectMake(20*proportion, 20*proportion, self.view.bounds.size.width-40*proportion, 36*proportion);
    registButton.layer.cornerRadius = 3*proportion;
    registButton.backgroundColor = [ColorStyleConfig sharedColorStyleConfig].login_button_color;
    [registButton addTarget:self action:@selector(submitButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    if (self.isForgetPassWord) {
        [registButton setTitle:NSLocalizedString(@"确认",nil) forState:UIControlStateNormal];
    }else{
        [registButton setTitle:NSLocalizedString(@"注册",nil) forState:UIControlStateNormal];
    }
    [footView addSubview:registButton];

    
    getCheckCodeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.getCheckCodeButton.frame = CGRectMake(self.view.bounds.size.width - 75, (50-20)/2, 65, 20);
    self.getCheckCodeButton.centerY = 25*proportion;
    self.getCheckCodeButton.layer.cornerRadius = 8;
    self.getCheckCodeButton.layer.borderWidth = 1;
    self.getCheckCodeButton.layer.borderColor = /*[UIColor colorWithRed:156/255.0 green:202/255.0 blue:241/255.0 alpha:.5].CGColor*/[ColorStyleConfig sharedColorStyleConfig].login_button_color.CGColor;
    [self.getCheckCodeButton setTitle:NSLocalizedString(@"获取",nil) forState:UIControlStateNormal];
    self.getCheckCodeButton.titleLabel.font = [UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleCellDateFontSize];
    [self.getCheckCodeButton setTitleColor:/*[UIColor colorWithRed:14/255.0 green:114/255.0 blue:254/255.0 alpha:1]*/[ColorStyleConfig sharedColorStyleConfig].login_button_color
                                  forState:UIControlStateNormal];
  
    [self.getCheckCodeButton addTarget:self action:@selector(getButtonClicked:)
                      forControlEvents:UIControlEventTouchUpInside];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyBoardDown_regist:)];
    tapRecognizer.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:tapRecognizer];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)regionClicked:(UITapGestureRecognizer *)tap {
    __weak __typeof (self)weakSelf = self;
    FDAreaPickerViewController *vc = [[FDAreaPickerViewController alloc] initWithDefaultModel:self.areaModel FDAreaPickerBlock:^(FDAreaPickerModel *model) {
        weakSelf.areaModel = model;
        weakSelf.regionLabel.text = model.country;
    }];
    [self.navigationController pushViewController:vc animated:YES];
}

// 验证手机号是否之前通过验证
- (BOOL)verifyPhone
{
    if ([[self open] integerValue]) {
        [self.getCheckCodeButton setTitle:@"已验证" forState:UIControlStateNormal];
        self.checkTextField.text = NSLocalizedString(@"您的手机号已验证成功",nil);
        self.checkTextField.enabled = NO;
        self.getCheckCodeButton.userInteractionEnabled = NO;
        self.checkTextField.userInteractionEnabled = NO;
        self.phoneTextField.userInteractionEnabled = NO;
    }
    return [[self open] integerValue];
}

- (void)checkVerifyCode {
    if (_isGetVerifyCodeByAli) {
        NSString *verifyCode = [[NSUserDefaults standardUserDefaults] objectForKey:@"verifyCode"];
        [self.checkTextField.text isEqualToString:verifyCode] ? [self verifyCodeSuccess] : [self verifyCodeFailed];
    } else {
        NSString *areaCode = self.areaModel.code;
        if ([areaCode hasPrefix:@"00"]) {
            areaCode = [areaCode substringFromIndex:2];
        }
//        [SMSSDK commitVerificationCode:self.checkTextField.text phoneNumber:self.phoneTextField.text zone:areaCode result:^(NSError *error) {
//            error == NULL ? [self verifyCodeSuccess] : [self verifyCodeFailed];
//        }];
    }
}

- (void)verifyCodeSuccess
{
    XYLog(@"验证成功");
    [SMStimer invalidate];
    SMStimer = nil;
    timerCount = 0;
    self.checkTextField.text = NSLocalizedString(@"您的手机号已验证成功",nil);
    [self.getCheckCodeButton setTitle:@"已验证" forState:UIControlStateNormal];
    self.getCheckCodeButton.userInteractionEnabled = NO;
    self.checkTextField.userInteractionEnabled = NO;
    
    // 将该手机号验证成功状态存到本地
    [self savePhoneNum:self.phoneTextField.text andCaptchaStatus:@"1"];
    
    // 去注册
    [self registButtonClicked:nil];
    
}

- (void)verifyCodeFailed
{
    [Global showTip:NSLocalizedString(@"验证码输入错误，请重新输入",nil)];
    self.checkTextField.text = nil;
}




-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.title = NSLocalizedString(@"用户注册",nil);
    if (self.isForgetPassWord) {
        self.title = NSLocalizedString(@"重置密码",nil);
    }
    [self leftAndRightButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
   
}

#pragma mark - table view delegate
- (CGFloat)tableView:(UITableView *)sender heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

    return 50*proportion;

}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}
#pragma mark - table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}


-(void)leftAndRightButton
{
//    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
//    {
//        UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        UIImage *leftImage = [UIImage imageNamed:@"Policebackpress"];
//        [leftButton setBackgroundImage:leftImage forState:UIControlStateNormal];
//        leftButton.frame = CGRectMake(0, 0, 40, 40);
//        [leftButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
//        UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
//        self.navigationItem.leftBarButtonItem = leftItem;
// 
//    }else{
//        UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        UIImage *leftImage = [UIImage imageNamed:@"Policebackpress"];
//        [leftButton setBackgroundImage:leftImage forState:UIControlStateNormal];
//        leftButton.frame = CGRectMake(0, 0, 40, 40);
//        [leftButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
//        UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
//        self.navigationItem.leftBarButtonItem = leftItem;
// 
//    }
    
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftButton setImage:[UIImage imageNamed:@"nav_bar_back"] forState:UIControlStateNormal];
    [leftButton sizeToFit];
    leftButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    leftButton.contentEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
    [leftButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    self.navigationItem.rightBarButtonItem = nil;
    //self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *rowViewArry = [NSArray arrayWithObjects:self.regionLabel,self.phoneTextField,self.checkTextField,self.pwTextField,self.pw2TextField, nil];
    
    NSString * cellId = [NSString stringWithFormat:@"userRegisterCell%ld",(long)indexPath.row];
//    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellId];
     
    UITableViewCell * cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];

    
        if (2 == indexPath.row) {
            [cell.contentView addSubview:self.getCheckCodeButton];
        }
        UIImageView *img=  [[UIImageView alloc]initWithFrame:CGRectMake(30, 10, 25*proportion, 25*proportion)];
        img.centerY = 25*proportion;
        [cell.contentView addSubview:img];
        UIView *rowView = [rowViewArry objectAtIndex:indexPath.row];
        [cell.contentView addSubview:rowView];
        if (indexPath.row == 0) {
            img.image = [UIImage imageNamed:@"userRegion"];
        }
        if (indexPath.row == 1) {
            img.image = [UIImage imageNamed:@"userImage"];
        }
        if (indexPath.row == 2) {//icon_left_my_comment
            img.image = [UIImage imageNamed:@"securitycode"];
//            img.alpha = 0.9;
        }
        if (indexPath.row == 3) {
            img.image = [UIImage imageNamed:@"passwordNJ"];
        }
        if (indexPath.row == 4) {
            img.image = [UIImage imageNamed:@"passwordNJ"];
        }
        //cell的分割线颜色的更改
        UIView *sep = [[UIView alloc] initWithFrame:CGRectMake(10, 50*proportion, kSWidth-20, 0.5)];
        sep.backgroundColor=[UIColor colorWithRed:221/255.0 green:221/255.0 blue:221/255.0 alpha:1];
        [cell.contentView addSubview:sep];
 
//    }
    
    return cell;
}


-(void)registButtonClicked:(UIButton *)sender
{
    if (![self validataForm]) {
        return;
    }
    if (![UIDevice networkAvailable]) {
        [Global showTipNoNetWork];
        return;
    }
    
    if (self.isForgetPassWord) {
        [self forgetPassWordRequest];
        
    }else
    {
        [self userRegisterRequest];
    }
}

- (BOOL)validataForm
{
    if ([NSString isNilOrEmpty:self.pwTextField.text]) {
        [UIAlertView showAlert:NSLocalizedString(@"密码不能为空",nil)];
        return NO;
    }
    
    if (self.pwTextField.text.length < 6 || self.pwTextField.text.length > 25 || self.pw2TextField.text.length < 6 || self.pw2TextField.text.length > 25) {
        [UIAlertView showAlert:NSLocalizedString(@"密码长度在6~25位之间",nil)];
        return NO;
    }
    
    if (![self.pwTextField.text isEqualToString:self.pw2TextField.text]){
        
        [UIAlertView showAlert:NSLocalizedString(@"输入密码不一致",nil)];
        return NO;
    }
    
    return YES;
}

- (void)forgetPassWordRequest
{
    [Global showTipAlways:NSLocalizedString(@"提交修改信息...",nil)];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/api/forgetPassword", [AppConfig sharedAppConfig].serverIf];
    NSURL *url = [NSURL URLWithString:urlString];
    HttpRequest *request = [HttpRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    NSString *strNormal = [NSString stringWithFormat:@"%@|%@|%@",[AppConfig sharedAppConfig].sid,self.phoneTextField.text,[self.pwTextField.text stringFromMD5]];
    NSString *strEncrypt = [AESCrypt encrypt:strNormal password:key];
    
    strEncrypt = stringSpecialsupport(strEncrypt);
    
    NSString *informString = [NSString stringWithFormat:@"sid=%@&mobile=%@&password=%@&sign=%@",[AppConfig sharedAppConfig].sid, self.phoneTextField.text,[self.pwTextField.text stringFromMD5],strEncrypt];

    NSData *informData = [informString dataUsingEncoding:NSUTF8StringEncoding];
    
    [request setHTTPBody:informData];
    
    [request setCompletionBlock:^(NSData *data) {
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers  error:nil];
        
        if ([[dict objectForKey:@"success"] boolValue]){

            [Global showTip:NSLocalizedString(@"修改成功",nil)];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else{
            [Global showTip:[dict objectForKey:@"msg"]];
            return;
        }
    }];
    
    [request setFailedBlock:^(NSError *error) {
        
        [Global showTipNoNetWork];
        
    }];
    
    [request startAsynchronous];
}


- (void)userRegisterRequest
{
    [Global showTipAlways:NSLocalizedString(@"提交账户信息...",nil)];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/register", [AppConfig sharedAppConfig].memberIf];
    
    NSURL *url = [NSURL URLWithString:urlString];
    HttpRequest *request = [HttpRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    
    NSString *informString = nil;
    if ([mailTextField.text rangeOfString:@"@"].location != NSNotFound) {
        informString = [NSString stringWithFormat:@"nickname=%@&mobile=%@&email=%@&password=%@",self.nicknameTextField.text,self.phoneNumber,self.mailTextField.text,[self.pwTextField.text stringFromMD5]];
    }
    else
    {
        informString = [NSString stringWithFormat:@"nickname=%@&mobile=%@&email=%@&password=%@",self.nicknameTextField.text,self.phoneNumber,@"",[self.pwTextField.text stringFromMD5]];
    }
    
    NSData *informData = [informString dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:informData];
    
    [request setCompletionBlock:^(NSData *data) {
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers  error:nil];
        
        [Global showTip:[dict objectForKey:@"msg"]];
        if ([[dict objectForKey:@"code"] boolValue]){
            [self performSelector:@selector(gotoPrePage) withObject:nil afterDelay:.3];
        }
    }];
    
    [request setFailedBlock:^(NSError *error) {
        [Global showTipNoNetWork];
    }];
    
    [request startAsynchronous];
}

- ( NSString *)handleUserRegister:(NSDictionary*)dict
{
    int result = [[dict objectForKey:@"success"] intValue];
    if (1 == result) {
        
        NSString *userid = [[dict objectForKey:@"userId"]stringValue];
        if (!userid) {
            userid = self.phoneTextField.text;
        }
        
        NSString *score = [dict objectForKey:@"score"];
        if (!score){
            score = @"";
        }
        NSString *email = [dict objectForKey:@"email"];
        if (!email){
            email = @"";
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:email forKey:KuserAccountMail];
        [[NSUserDefaults standardUserDefaults] setObject:self.phoneTextField.text forKey:KuserAccountLoginName];
        [[NSUserDefaults standardUserDefaults] setObject:userid forKey:KuserAccountUserId];
        [[NSUserDefaults standardUserDefaults] setObject:score forKey:KuserAccountMoneyStr];
        
        return NSLocalizedString(@"成功注册账户！",nil);
    }
    else{
        NSString *message = [dict objectForKey:@"errInfo"];
        return message;
    }
}

-(void)keyBoardDown_regist:(UITapGestureRecognizer *)recognizer
{
    [self.pw2TextField resignFirstResponder];
    [self.pwTextField resignFirstResponder];
}

-(void)submitButtonClicked:(UIButton *)sender
{
    [self.view endEditing:YES];
    
    if(self.phoneTextField.text.length == 0){
        [UIAlertView showAlert:NSLocalizedString(@"请输入手机号",nil)];
        return;
    }
    
    if(self.checkTextField.text.length == 0){
        [UIAlertView showAlert:NSLocalizedString(@"请输入短信验证码",nil)];
        return;
    }
    
    if (![self.checkTextField.text isEqualToString:NSLocalizedString(@"您的手机号已验证成功",nil)]) {
        
        if (self.checkTextField.text.length < 4 || self.checkTextField.text.length > 6) {
            [UIAlertView showAlert:NSLocalizedString(@"请输入4~6位正确的验证码",nil)];
            self.checkTextField.text = nil;
            return;
        }
        // 去验证验证码
        [self checkVerifyCode];
    }else
        [self registButtonClicked:nil];
    
    
}


- (void)savePhoneNum:(NSString *)phone andCaptchaStatus:(NSString *)captchaStatus {
    
    
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [user setObject:captchaStatus forKey:phone];
}

// ,取出对应号码的验证状态 1,成功 0,失败
- (NSString *)open {
    
    
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSString *str = [user objectForKey:self.phoneTextField.text];
    return str;
}

-(void)getButtonClicked:(UIButton *)sender
{
    if (![self isPhoneNumberStyle:self.phoneTextField.text]) {
        return;
    }
    
    // 先去验证该号码是否是之前已验证过的
//    if ([self verifyPhone]) {
//        return;
//    }
    
    if (![UIDevice networkAvailable]) {
        return;
    }
    
    UIAlertView* alert=[[UIAlertView alloc] initWithTitle:self.phoneTextField.text
                                                  message:NSLocalizedString(@"获取验证码到上面的手机号码",nil)
                                                 delegate:self
                                        cancelButtonTitle:NSLocalizedString(@"取消",nil)
                                        otherButtonTitles:NSLocalizedString(@"确认",nil), nil];
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (1 == buttonIndex){
        [self getVerifyCode];
        /* 取消港澳台
        if (self.phoneTextField.text.length != 11)
            [self setupPickView];
        else {
            _areaCode = @"86";
            [self getVerifyCode];
         
        }*/
    }
}

- (void)setupPickView
{
    if (_pickView) return;
    
    NSArray *areaList = [[NSArray alloc] initWithObjects:@"澳门",@"香港",@"台湾",nil];
    CGRect rect = CGRectMake(0, self.view.height-180, self.view.width, 180);
    FDPickerView *pickView = [FDPickerView pickerViewWithFrame:rect Title:@"选择电话所属区域" Items:areaList];
    __weak __typeof(pickView)weakPickView = pickView;
    pickView.pickerViewBlock = ^(NSInteger selectCode){
        NSArray *areaCodes = [[NSArray alloc] initWithObjects:@"853",@"852",@"886",nil];
        _areaCode = areaCodes[selectCode];
        [self getVerifyCode];
        [weakPickView removeFromSuperview];
    };
    [self.view addSubview:pickView];
}

/**
 *  获取验证码
 */
-(void)getVerifyCode
{
    [self closeGetCode];
    
    [Global showTipAlways:NSLocalizedString(@"发送中...",nil)];
    
    self.phoneNumber = self.phoneTextField.text;
    /* 友盟是免费的，第一次先用友盟进行短信验证，若【用户点击了重复获取】一律采用阿里大于 */
    if ([AppConfig sharedAppConfig].isOnlyAliDaYu) {
        [self getVerifyCodeByAli];
    }else {
        if ([self.getCheckCodeButton.titleLabel.text isEqualToString:NSLocalizedString(@"重新获取",nil)]) {
            if (self.areaModel.code != [AppConfig sharedAppConfig].defaultAreaCode) {
                self.phoneNumber = [self.areaModel.code stringByAppendingString:self.phoneTextField.text];
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
//                    if (error.code == 472 || error.code == 476 || error.code == 479 || error.code == 478 || error.code == 477 || error.code == 462 ||error.code == 463||error.code == 464 ||error.code == 465 ||error.code == 467) {
//                        [self getVerifyCodeByAli];
//                    }else{
//                        timerCount = _isGetVerifyCodeByAli ? kTimeCount_300 : kTimeCount_60;
//                        [Global showTip:NSLocalizedString(@"获取验证码失败",nil)];
//                    }
//                    XYLog(@"验证码错误是:%@",error);
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
    NSString *sign = [AESCrypt encrypt:[NSString stringWithFormat:@"%@%@%@", [AppConfig sharedAppConfig].sid, appName, self.phoneNumber] password:key];
    //(sid+appName+mobile)
    NSString * informString = [NSString stringWithFormat:@"sid=%@&appName=%@&mobile=%@&sign=%@", [AppConfig sharedAppConfig].sid,appName, self.phoneNumber, sign];
    
    NSData *informData = [informString dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:informData];
    [request setCompletionBlock:^(NSData *data) {
        // 服务器传回正确验证码，用于后面与用户实际收到且输入的验证码做比对
        // 由于后台设定5分钟之类相同电话获取的验证码是一样的，且只是5分钟之内不会传回该相同验证码，本地需要存储起来第一次收到的验证码
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
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
    self.phoneTextField.enabled = NO;
    self.mailTextField.enabled = NO;
    SMStimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                target:self
                                              selector:@selector(updateTime)
                                              userInfo:nil
                                               repeats:YES];
    
}

-(void)openGetCode
{
    self.getCheckCodeButton.userInteractionEnabled = YES;
    self.mailTextField.enabled = YES;
    self.phoneTextField.userInteractionEnabled = YES;
    [self.getCheckCodeButton setTitle:NSLocalizedString(@"重新获取",nil) forState:UIControlStateNormal];

}

//短信等待时间
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

-(void)gotoPrePage
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

-(void)goBack
{
    [Global hideTip];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
