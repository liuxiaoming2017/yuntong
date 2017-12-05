//
//  ChangeUserInfoController.m
//  FounderReader-2.5
//
//  Created by ld on 14-12-29.
//
//

#import "ChangeUserInfoController.h"
#import "ImageViewCf.h"
#import "UserAccountDefine.h"
#import "ChangeUserIconController.h"
#import "HttpRequest.h"
#import "FCReader_OpenUDID.h"
#import "NSString+MD5Addition.h"
#import "NSStringAdditions.h"
#import "RegexKitLite.h"
#import "AppStartInfo.h"
#import "UIImage+Helper.h"
#import "PersonalCenterViewController.h"
#import "NewsListConfig.h"
#import "ChangeUserIconController.h"
#import "ColumnBarConfig.h"
#import "ColorStyleConfig.h"
#import "AESCrypt.h"
#import <AliyunOSSiOS/OSSService.h>
#import <AliyunOSSiOS/OSSCompat.h>
#import "YZSDK.h"
#import "Defines.h"
#import "YXLoginViewController.h"
#import "FZChangePhoneNumberController.h"

#define CELL_HEIGHT 40*proportion
#define CELL_TEXT_LEFT 110
#define freeHeight 44
#define topGap 12
#define labelHeight 30

@interface ChangeUserInfoController ()<UITextFieldDelegate,UIAlertViewDelegate>
{
    ChangeUserIconController *controller;
    OSSClient * client;
}

@property(nonatomic,retain) UITextField *nickTextField;
@property(nonatomic,retain) UITextField *mailTextField;
@property(nonatomic,retain) UITextField *originalPWTextField;
@property(nonatomic,retain) UITextField *changePWTextField;
@property(nonatomic,retain) UITextField *againPWTextField;

@property(nonatomic,retain) UITextField *phoneTextField;
@property(nonatomic,retain) UITextField *adressTextField;
@property(nonatomic,retain) UITextField *birthTextField;
@property(nonatomic,retain) UITextField *sexTextField;
@property(nonatomic,retain) UITextField *areaTextField;
@property(nonatomic,retain) UIDatePicker *datePicker;
@property(nonatomic,retain) UIView *backView;
@property(nonatomic,retain) UIImageView *columnBgView;

@property(nonatomic,retain) ImageViewCf *userIcon;
@property(nonatomic,retain) ChangeUserIconController *controller;
@property(nonatomic,strong) UIButton * bindButton;
@property (nonatomic,assign) BOOL isChangeBind;
@end

@implementation ChangeUserInfoController

@synthesize nickTextField,mailTextField,originalPWTextField,changePWTextField,againPWTextField,phoneTextField,adressTextField,areaTextField,sexTextField,birthTextField,datePicker,backView,columnBgView;
@synthesize userIcon,controller;


-(void)dealloc
{
    self.adressTextField = nil;
    self.nickTextField = nil;
    self.mailTextField = nil;
    self.originalPWTextField = nil;
    self.changePWTextField = nil;
    self.againPWTextField = nil;
    self.userIcon = nil;
//    [super dealloc];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    self.title = NSLocalizedString(@"修改资料",nil);
}
-(void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KchangeUserIconNotification object:nil];
    [super viewDidUnload];
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [Global hideTip];
    [super viewWillDisappear:animated];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadData];
    // 修改页面标题颜色
    NSMutableDictionary *textTitleAttrs = [NSMutableDictionary dictionary];
    textTitleAttrs[NSForegroundColorAttributeName] = [ColorStyleConfig sharedColorStyleConfig].navbar_titlecolor_selected;//[ColumnBarConfig sharedColumnBarConfig].columnNameFontSeledColor;
    textTitleAttrs[NSFontAttributeName] = [UIFont systemFontOfSize:18];
    self.navigationController.navigationBar.titleTextAttributes = textTitleAttrs;
    
    [self rightButton];
    nickTextField = [[UITextField alloc]initWithFrame:CGRectMake(CELL_TEXT_LEFT, 0, self.view.bounds.size.width-120, CELL_HEIGHT)];
    self.nickTextField.font = [UIFont systemFontOfSize:[NewsListConfig sharedListConfig].leftUserNameFontSize - 2];
    self.nickTextField.placeholder = NSLocalizedString(@"请填写昵称",nil);
    NSString *nick = [[NSUserDefaults standardUserDefaults] objectForKey:KuserAccountNickName];
    if (nick.length) {
        self.nickTextField.text = nick;
    }
    nickTextField.delegate = self;
    
    
    mailTextField = [[UITextField alloc]initWithFrame:CGRectMake(CELL_TEXT_LEFT, 0, self.view.bounds.size.width-120, CELL_HEIGHT)];
    self.mailTextField.font = [UIFont systemFontOfSize:[NewsListConfig sharedListConfig].leftUserNameFontSize - 2];
    self.mailTextField.placeholder = NSLocalizedString(@"请填写邮箱",nil);
    
    NSString *mail = [[NSUserDefaults standardUserDefaults] objectForKey:KuserAccountMail];
    if (mail.length) {
        self.mailTextField.text = mail;
    }
     NSString *phone = [[NSUserDefaults standardUserDefaults] objectForKey:KuserAccountPhone];
    self.mailTextField.delegate = self;
    self.bindButton = [[UIButton alloc]initWithFrame:CGRectMake(kSWidth-15, 10, 60, CELL_HEIGHT-20)];
    self.bindButton.backgroundColor = [ColorStyleConfig sharedColorStyleConfig].login_button_color;
    [self.bindButton addTarget:self action:@selector(bindButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    if (phone.length) {
        [self.bindButton setTitle:NSLocalizedString(@"重新绑定", nil) forState:UIControlStateNormal];
        self.bindButton.frame = CGRectMake(kSWidth-87, 10, 70, CELL_HEIGHT-20);
    }else{
        [self.bindButton setTitle:NSLocalizedString(@"绑定", nil) forState:UIControlStateNormal];
        self.bindButton.frame = CGRectMake(kSWidth-67, 10, 50, CELL_HEIGHT-20);
    }
    self.bindButton.titleLabel.font = [UIFont systemFontOfSize:14];
    self.bindButton.layer.masksToBounds = YES;
    self.bindButton.layer.cornerRadius = 4;
    
    
    
    phoneTextField = [[UITextField alloc]initWithFrame:CGRectMake(CELL_TEXT_LEFT, 0, self.view.bounds.size.width-200, CELL_HEIGHT)];
    self.phoneTextField.font = [UIFont systemFontOfSize:[NewsListConfig sharedListConfig].leftUserNameFontSize - 2];
    phoneTextField.userInteractionEnabled = NO;
//    self.phoneTextField.placeholder = NSLocalizedString(@"请输入新手机号",nil);
    
   
    if (phone.length) {
        self.phoneTextField.text = phone;
    }
    self.phoneTextField.delegate = self;
    
    birthTextField = [[UITextField alloc]initWithFrame:CGRectMake(CELL_TEXT_LEFT, 0, self.view.bounds.size.width-120, CELL_HEIGHT)];
    self.birthTextField.font = [UIFont systemFontOfSize:[NewsListConfig sharedListConfig].leftUserNameFontSize - 2];
    self.birthTextField.placeholder = NSLocalizedString(@"选填",nil);
    self.birthTextField.tag = 1001;
    NSString *birth = [[NSUserDefaults standardUserDefaults] objectForKey:KuserAccountbirth];
    if (birth.length) {
        self.birthTextField.text = birth;
    }
    self.birthTextField.delegate = self;
    
    sexTextField = [[UITextField alloc]initWithFrame:CGRectMake(CELL_TEXT_LEFT, 0, self.view.bounds.size.width-120, CELL_HEIGHT)];
    self.sexTextField.font = [UIFont systemFontOfSize:[NewsListConfig sharedListConfig].leftUserNameFontSize - 2];
    self.sexTextField.placeholder = NSLocalizedString(@"选填",nil);
    self.sexTextField.tag = 1002;
    NSString *sex = [[NSUserDefaults standardUserDefaults] objectForKey:KuserAccountsex];
    if (sex.length) {
        self.sexTextField.text = sex;
    }
    self.sexTextField.delegate = self;
    
    
    self.columnValue = @[NSLocalizedString(@"男",nil),NSLocalizedString(@"女",nil), NSLocalizedString(@"保密",nil)];
    _sexView = [[UIView alloc] initWithFrame:CGRectMake(CELL_TEXT_LEFT, 205-35, 60, 90)];
    for (int i = 0; i < self.columnValue.count; i++) {
        UIButton *btn = [[UIButton alloc] init];
        btn.frame = CGRectMake(0, 30*i, self.sexView.bounds.size.width, self.sexView.bounds.size.height/self.columnValue.count);
        btn.tag = 200+i;
        [btn setTitle:self.columnValue[i] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(selectButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.sexView addSubview:btn];

    }
    
    
    
    areaTextField = [[UITextField alloc]initWithFrame:CGRectMake(CELL_TEXT_LEFT, 0, self.view.bounds.size.width-120, CELL_HEIGHT)];
    self.areaTextField.font = [UIFont systemFontOfSize:[NewsListConfig sharedListConfig].leftUserNameFontSize - 2];
    self.areaTextField.placeholder = NSLocalizedString(@"选填",nil);
    

    
    NSString *area = [[NSUserDefaults standardUserDefaults] objectForKey:KuserAccountarea];
    if (area.length) {
        self.areaTextField.text = area;
    }
    self.areaTextField.delegate = self;
    
    adressTextField = [[UITextField alloc]initWithFrame:CGRectMake(CELL_TEXT_LEFT, 0, self.view.bounds.size.width-120, CELL_HEIGHT)];
    self.adressTextField.font = [UIFont systemFontOfSize:[NewsListConfig sharedListConfig].leftUserNameFontSize - 2];
    self.adressTextField.placeholder = NSLocalizedString(@"选填",nil);
    
    NSString *address = [[NSUserDefaults standardUserDefaults] objectForKey:KuserAccountAdress];
    if (address.length) {
        self.adressTextField.text = address;
    }
    self.adressTextField.delegate = self;
    
    originalPWTextField = [[UITextField alloc]initWithFrame:CGRectMake(CELL_TEXT_LEFT, 0, self.view.bounds.size.width-120, CELL_HEIGHT)];
    self.originalPWTextField.font = [UIFont systemFontOfSize:[NewsListConfig sharedListConfig].leftUserNameFontSize - 2];
    self.originalPWTextField.placeholder = NSLocalizedString(@"原始密码",nil);
    self.originalPWTextField.delegate = self;
    self.originalPWTextField.secureTextEntry = YES;
    
    
    changePWTextField = [[UITextField alloc]initWithFrame:CGRectMake(CELL_TEXT_LEFT, 0, self.view.bounds.size.width-120, CELL_HEIGHT)];
    self.changePWTextField.font = [UIFont systemFontOfSize:[NewsListConfig sharedListConfig].leftUserNameFontSize - 2];
    self.changePWTextField.placeholder = NSLocalizedString(@"修改密码",nil);
    self.changePWTextField.delegate = self;
    self.changePWTextField.secureTextEntry = YES;

    
    againPWTextField = [[UITextField alloc]initWithFrame:CGRectMake(CELL_TEXT_LEFT, 0, self.view.bounds.size.width-120, CELL_HEIGHT)];
    self.againPWTextField.font = [UIFont systemFontOfSize:[NewsListConfig sharedListConfig].leftUserNameFontSize - 2];
    self.againPWTextField.placeholder = NSLocalizedString(@"重复密码",nil);
    self.againPWTextField.delegate = self;
    self.againPWTextField.secureTextEntry = YES;
    
    
    UIButton *confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    confirmButton.frame = CGRectMake(20, kSHeight - 64 - 60*kHScale, self.view.bounds.size.width-40, 40*kHScale);
    [confirmButton addTarget:self action:@selector(confirm:) forControlEvents:UIControlEventTouchUpInside];
    confirmButton.layer.cornerRadius = 4;
    confirmButton.layer.masksToBounds = YES;
    [confirmButton setTitle:NSLocalizedString(@"退出登录",nil) forState:UIControlStateNormal];
    confirmButton.backgroundColor = [ColorStyleConfig sharedColorStyleConfig].login_button_color;
    
    
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 65)];
    [self.view addSubview:confirmButton];
    self.tableView.tableFooterView = footView;
    footView.userInteractionEnabled = YES;

    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardDown)];
    tapRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapRecognizer];
//    DELETE(tapRecognizer);
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changeUserIcon)
                                                 name:KchangeUserIconNotification
                                               object:nil];
    
    //UIDatePicker
    datePicker = [[UIDatePicker alloc] init];
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    NSLocale *locale = [[NSLocale alloc]initWithLocaleIdentifier:@"zh_Hans_CN"];
    [self.datePicker setLocale:locale];
    self.datePicker.minuteInterval = 3600;
    [self.datePicker addTarget:self action:@selector(chooseDate:) forControlEvents:UIControlEventValueChanged];

    
    backView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kSWidth, kSHeight)];
    backView.backgroundColor = [UIColor blackColor];
    backView.alpha = 0.6;
    
    tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideDate)];
    tapRecognizer.cancelsTouchesInView = NO;
    [backView addGestureRecognizer:tapRecognizer];

    if([Global isThirtyLogin]){
        self.originalPWTextField.hidden = YES;
        self.changePWTextField.hidden = YES;
        self.againPWTextField.hidden = YES;
    }
    
}
- (void)loadData
{
    NSString *urlString = [NSString stringWithFormat:@"%@/api/getOSSInfo?sid=%@",[AppConfig sharedAppConfig].serverIf,[AppConfig sharedAppConfig].sid];
    XYLog(@"%@",urlString);
    HttpRequest *request = [HttpRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    [request setCompletionBlock:^(NSData *data) {
        NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers  error:nil];
        NSString *strEncrypt = [responseDict objectForKey:@"info"];
        if (strEncrypt != nil)
        {
            //开始解密newaircloud_vjow9Dej#JDj4[oIDF
            NSString *strDecrypt = [AESCrypt decrypt:strEncrypt password:key];
            NSData *dataDecrypt = [strDecrypt dataUsingEncoding:NSUTF8StringEncoding];
            self.dicInfo = [NSJSONSerialization JSONObjectWithData:dataDecrypt options:NSJSONReadingMutableContainers error:nil];
            [self initOSSClient];
        }
    }];
    
    [request setFailedBlock:^(NSError *error)
     {
         XYLog(@"send inform attachment error: %@", error);
     }];
    [request startAsynchronous];
}
- (void)initOSSClient {
    
    id<OSSCredentialProvider> credential = [[OSSPlainTextAKSKPairCredentialProvider alloc] initWithPlainTextAccessKey:[self.dicInfo objectForKey:@"accessKeyId"]
                                                                                                            secretKey:[self.dicInfo objectForKey:@"accessKeySecret"]];
    
    OSSClientConfiguration * conf = [OSSClientConfiguration new];
    conf.maxRetryCount = 2;
    conf.timeoutIntervalForRequest = 30;
    conf.timeoutIntervalForResource = 24 * 60 * 60;
    
    client = [[OSSClient alloc] initWithEndpoint:[NSString stringWithFormat:@"http://%@",[self.dicInfo objectForKey:@"endpoint"]] credentialProvider:credential clientConfiguration:conf];
}
-(void)selectButton:(UIButton *)button
{
    sexTextField.text = [NSString stringWithFormat:@"%@",self.columnValue[button.tag-200]];
    if (self.sexView.superview) {
        [self.sexView removeFromSuperview];
    }

}
- (void)rightButton{
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *rImage = [UIImage imageNamed:@"btn_new_sure"];
    [rightButton setBackgroundImage:rImage forState:UIControlStateNormal];
    //    [rightButton setBackgroundImage:[UIImage imageNamed:@"Policebackpress"] forState:UIControlStateHighlighted];
    rightButton.frame = CGRectMake(0, 0, 25*proportion, 25*proportion);
    [rightButton addTarget:self action:@selector(save:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rItem;

    
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftButton setImage:[UIImage imageNamed:@"nav_bar_back"] forState:UIControlStateNormal];
    [leftButton sizeToFit];
    leftButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    leftButton.contentEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
    [leftButton addTarget:self action:@selector(goRightPageBack) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = leftItem;

}

-(void)changeUserIcon
{
    NSData *userIconData = [NSData dataWithContentsOfFile:[cacheDirPath() stringByAppendingPathComponent:cacheUserIconName]];
    if (userIconData.length) {
        self.userIcon.image = [UIImage imageWithData:userIconData];
        [self sendFaceIcon];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

- (BOOL)validateForm
{
    if ([NSString isNilOrEmpty:self.nickTextField.text]) {
        [UIAlertView showAlert:NSLocalizedString(@"昵称为必填项",nil)];
        return NO;
    }
    if (self.nickTextField.text.length > 12) {
        [UIAlertView showAlert:NSLocalizedString(@"昵称不能超过12个字符",nil)];
        return NO;
    }
    
    if (![NSString isNilOrEmpty:self.mailTextField.text]) {
        if (![self.mailTextField.text isMatchedByRegex:kEmailAddressRegExp]) {
            [UIAlertView showAlert:NSLocalizedString(@"您输入的邮箱地址不正确",nil)];
            return NO;
        }
    }
//    if (![NSString isNilOrEmpty:self.phoneTextField.text]) {
//        if (![self.phoneTextField.text isMatchedByRegex:kPhoneNumberRegExp]) {
//            [UIAlertView showAlert:@"请输入有效的手机号"];
//            return NO;
//        }
//    }
//    else
//    {
//        [UIAlertView showAlert:@"手机号为必填项"];
//        return NO;
//    }
    if (![NSString isNilOrEmpty:self.originalPWTextField.text]) {
        if (![self.originalPWTextField.text isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:KuserAccountLoginPassWord]]) {
            XYLog(@"%@",self.originalPWTextField.text);
            XYLog(@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:KuserAccountLoginPassWord]);
            [UIAlertView showAlert:NSLocalizedString(@"请检查现有的密码是否正确",nil)];
            return NO;
        }
    }
    
    if (![NSString isNilOrEmpty:self.againPWTextField.text]) {
        
        if ([NSString isNilOrEmpty:self.changePWTextField.text]) {
            
            [UIAlertView showAlert:NSLocalizedString(@"请输入修改密码",nil)];
            return NO;
        }
        if (self.changePWTextField.text.length < 6 || self.changePWTextField.text.length > 25) {
            [UIAlertView showAlert:NSLocalizedString(@"密码长度在6~25位之间",nil)];
            return NO;
        }
    }
    if (![NSString isNilOrEmpty:self.changePWTextField.text]) {
        
        if ([NSString isNilOrEmpty:self.againPWTextField.text]) {
            
            [UIAlertView showAlert:NSLocalizedString(@"请输入重复密码",nil)];
            return NO;
        }
    }
    
    if (![NSString isNilOrEmpty:self.changePWTextField.text] && ![NSString isNilOrEmpty:self.againPWTextField.text]) {
       
        if (![self.changePWTextField.text isEqualToString:self.againPWTextField.text]) {
            
            [UIAlertView showAlert:NSLocalizedString(@"请检查修改密码是否一致",nil)];
            return NO;
        }
    }
    
    return YES;
}

-(void)confirm:(UIButton *)sender
{
    [self clearUserInfo];
}

-(void)save:(UIButton *)sender
{

    if ([self validateForm]) {

         [self sendUserInfo:nil goBack:YES];
    }
}

-(void)changeIcon:(UIButton *)sender
{
    controller = [[ChangeUserIconController alloc]init];
    [[UIApplication sharedApplication].keyWindow addSubview:controller.view];
    controller.view.center = CGPointMake([UIApplication sharedApplication].keyWindow.frame.size.width*2, [UIApplication sharedApplication].keyWindow.frame.size.height/2);
    
    [UIView animateWithDuration:.3 animations:^{
        controller.view.center = CGPointMake([UIApplication sharedApplication].keyWindow.frame.size.width/2, [UIApplication sharedApplication].keyWindow.frame.size.height/2);
    }];
    
}


-(void)keyboardDown
{
    [self.nickTextField resignFirstResponder];
    [self.mailTextField resignFirstResponder];
    [self.originalPWTextField resignFirstResponder];
    [self.changePWTextField resignFirstResponder];
    [self.againPWTextField resignFirstResponder];
    
    [self.phoneTextField resignFirstResponder];
    [self.birthTextField resignFirstResponder];
//    [self.sexTextField resignFirstResponder];
    [self.areaTextField resignFirstResponder];
    [self.adressTextField resignFirstResponder];
    
}

-(void)hideDate
{
//    [UIView beginAnimations:nil context:nil];
//    [UIView setAnimationDuration:0.3f];
//    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    
    [datePicker removeFromSuperview];
    [backView removeFromSuperview];
    
    //[UIView commitAnimations];
}

#pragma mark - table view delegate
- (CGFloat)tableView:(UITableView *)sender heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!indexPath.row)
    {
        return 60*proportion;
    }
    else if (1 == indexPath.row)
    {
        return 5;//第二个分割
    }
    else
    {
        return CELL_HEIGHT;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
     [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row) {
        
    }else{
        [self changeIcon:nil];
    }
    
    
}
#pragma mark - table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([Global isThirtyLogin])
        return 5;
    else
        return 8;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!indexPath.row) {
        NSString * cellId = @"userInfoFirstCell";
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        
        if (!cell){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
            userIcon = [[ImageViewCf alloc]initWithFrame:CGRectMake(20, 9*proportion, 42*proportion, 42*proportion)];
            userIcon.layer.cornerRadius = 21*proportion;
            userIcon.layer.masksToBounds = YES;
            userIcon.contentMode = UIViewContentModeScaleAspectFill;
            NSString *icon = [[NSUserDefaults standardUserDefaults] objectForKey:KuserAccountFace];
            [userIcon setDefaultImage:[UIImage imageNamed:@"icon-user-center"]];
            if (icon.length){
                [userIcon setUrlString:icon];
            }
            [cell.contentView addSubview:userIcon];
            
            UILabel *userIconLabel = [[UILabel alloc] initWithFrame:CGRectMake(80*proportion, 0, 80*proportion, 60*proportion)];
            userIconLabel.text = NSLocalizedString(@"修改头像",nil);
            userIconLabel.font = [UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleCellTitleFontSize];
            [cell.contentView addSubview:userIconLabel];
 
            
        }
        cell.selectionStyle =UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }
    else if (1 == indexPath.row)
    {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"blankcell"];
        cell.backgroundColor = UIColorFromString(@"237,237,237");
        cell.selectionStyle =UITableViewCellSelectionStyleNone;
        return cell;
    }
    else{
        NSArray *showText =nil;
        NSArray *textFieldArry = nil;
        if ([Global isThirtyLogin]) {
            
            showText = @[NSLocalizedString(@"昵称",nil),NSLocalizedString(@"地址",nil),NSLocalizedString(@"手机号",nil)];
            textFieldArry = [NSArray arrayWithObjects:nickTextField,adressTextField,phoneTextField,nil];
        }else{
            showText = @[NSLocalizedString(@"昵称",nil),NSLocalizedString(@"邮箱",nil),NSLocalizedString(@"地址",nil),NSLocalizedString(@"原始密码",nil),NSLocalizedString(@"修改密码",nil),NSLocalizedString(@"重复密码",nil)];
            textFieldArry = [NSArray arrayWithObjects:nickTextField,mailTextField,adressTextField,originalPWTextField,changePWTextField,againPWTextField, nil];
        }
        NSString * cellId = [NSString stringWithFormat:@"userInfoCell%ld",(long)indexPath.row];
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        
        if (!cell){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
            UILabel *cellLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 80, CELL_HEIGHT)];
            cellLabel.tag = 501;
            cellLabel.text = NSLocalizedString(@"修改密码",nil);
            cellLabel.font = [UIFont systemFontOfSize:[NewsListConfig sharedListConfig].leftUserNameFontSize - 2];
            [cell.contentView addSubview:cellLabel];
 
            
            UITextField *cellTextField = [textFieldArry objectAtIndex:indexPath.row-2];
            [cell.contentView addSubview:cellTextField];
            if (indexPath.row == 4 && [Global isThirtyLogin]) {
                [cell addSubview:self.bindButton];
            }
        }
        
        UILabel *cellLabel = (UILabel *)[cell.contentView viewWithTag:501];
        cellLabel.text = [showText objectAtIndex:indexPath.row-2];
        
        UIView *sep = [[UIView alloc] initWithFrame:CGRectMake(10, CELL_HEIGHT-0.5, kSWidth-20, 0.5)];
        sep.backgroundColor=[UIColor colorWithRed:221/255.0 green:221/255.0 blue:221/255.0 alpha:1];
        [cell.contentView addSubview:sep];
 
        cell.selectionStyle =UITableViewCellSelectionStyleNone;
        return cell;
    }
}


-(void)yxLogout:(UIButton *)sender
{
    UIAlertView *logoutAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"是否确认退出登录",nil) message:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"确认",nil) otherButtonTitles:NSLocalizedString(@"取消",nil), nil];
//    logoutAlertView.tag = 911;
    [logoutAlertView show];
 
    return;
}

-(void)clearUserInfo
{
    NSString *userId = [Global userId];
    if (userId.length) {
        UIAlertView *logoutAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"是否确认退出登录",nil) message:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"确认",nil) otherButtonTitles:NSLocalizedString(@"取消",nil), nil];
        logoutAlertView.tag = 911;
        [logoutAlertView show];
        return;
    }

}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 911){
        
        if (buttonIndex == 0)
        {
          [self goRightPageBack];
          [self logOutAccount];
        }
    }
}
-(void)logOutAccount{
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
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"USERDIDLOGOUT" object:nil];
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
-(void)leftRightNavTopButtons
{
    if (self.isMenu) {
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
        {
            UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"whiteBack"] style:UIBarButtonItemStylePlain target:self action:@selector(goMenuRightPageBack)];
            self.navigationItem.leftBarButtonItem = leftItem;
 
        }else{
            UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
            UIImage *leftImage = [UIImage imageNamed:@"whiteBack"];
            [leftButton setBackgroundImage:leftImage forState:UIControlStateNormal];
            leftButton.frame = CGRectMake(0, 0, leftImage.size.width, leftImage.size.height);
            [leftButton addTarget:self action:@selector(goMenuRightPageBack) forControlEvents:UIControlEventTouchUpInside];
            UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
            self.navigationItem.leftBarButtonItem = leftItem;
 
        }
    }
    else
    {
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
        {
            UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"whiteBack"] style:UIBarButtonItemStylePlain target:self action:@selector(goRightPageBack)];
            self.navigationItem.leftBarButtonItem = leftItem;
 
        }else{
            UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
            UIImage *leftImage = [UIImage imageNamed:@"whiteBack"];
            [leftButton setBackgroundImage:leftImage forState:UIControlStateNormal];
            leftButton.frame = CGRectMake(0, 0, leftImage.size.width, leftImage.size.height);
            [leftButton addTarget:self action:@selector(goRightPageBack) forControlEvents:UIControlEventTouchUpInside];
            UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
            self.navigationItem.leftBarButtonItem = leftItem;
 
        }
    }
    
    self.title = NSLocalizedString(@"修改资料",nil);
    
//    [self.navigationController.navigationBar setShadowImage:[UIImage createImageWithColor:[UIColor redColor]]];
}
-(void)goMenuRightPageBack
{
        [self.navigationController popViewControllerAnimated:YES];
}
-(void)goRightPageBack
{
    if (self.isFromeLogin) {
        if (self.changeUserInfoSuccessBlock) {
            self.changeUserInfoSuccessBlock();
        }
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    NSString *phone = [[NSUserDefaults standardUserDefaults] objectForKey:KuserAccountPhone];
    if ([AppConfig sharedAppConfig].isNeedBindPhoneNumber && !phone.length) {
        [self logOutAccount];
        YXLoginViewController * loginVC = [[YXLoginViewController alloc]init];
        [self presentViewController:loginVC animated:YES completion:nil];
        return;
    }else{
        [self.navigationController popViewControllerAnimated:YES];
        [self dismissViewControllerAnimated:YES completion:^{
            if (self.changeUserInfoSuccessBlock) {
                self.changeUserInfoSuccessBlock();
            }
            if ([AppConfig sharedAppConfig].isNeedLoginBeforeEnter && [NSString isNilOrEmpty:[Global userId]]) {
                YXLoginViewController *vc = [[YXLoginViewController alloc] init];
                [[appDelegate() currentViewController] presentViewController:[Global controllerToNav:vc] animated:YES completion:NULL];
            }
        }];
    }
}
#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

/**
 *  @brief 修改头像到服务器
 */
- (void)sendFaceIcon
{
    if (self.dicInfo == nil) {
        return;
    }

    OSSPutObjectRequest * put = [OSSPutObjectRequest new];
    
    // required fields
    put.bucketName = [self.dicInfo objectForKey:@"bucket"];
    put.objectKey = [NSString stringWithFormat:@"%@%@_1.png",[self.dicInfo objectForKey:@"uploadDir"],[self.dicInfo objectForKey:@"uploadFile"]];
    
//    NSData *body = [self buildMultipartFormDataPostBody];
    NSData *data = UIImageJPEGRepresentation(userIcon.image, .3);
    put.uploadingData = data;
    
    OSSTask * putTask = [client putObject:put];
    // 异步
//    [putTask continueWithBlock:^id(OSSTask *task) {
//        XYLog(@"objectKey: %@", put.objectKey);
//        if (!task.error)
//        {
//            NSString *userFaceUrl = [NSString stringWithFormat:@"%@/%@",[self.dicInfo objectForKey:@"picRoot"],put.objectKey];
//            if (userFaceUrl.length)
//            {
//                [[NSUserDefaults standardUserDefaults] setValue:userFaceUrl forKey:KuserAccountFace];
//            }
//        }
//        else
//        {
//            XYLog(@"upload object failed, error: %@" , task.error);
//        }
//        return nil;
//    }];
    
    // 同步
    [putTask waitUntilFinished];
    if (!putTask.error) {
        NSString *userFaceUrl = [NSString stringWithFormat:@"%@/%@",[self.dicInfo objectForKey:@"picRoot"],put.objectKey];
        if (userFaceUrl.length) {
            [[NSUserDefaults standardUserDefaults] setValue:userFaceUrl forKey:KuserAccountFace];
            [self sendUserInfo:nil goBack:NO];
        }
    } else {
        XYLog(@"头像上传失败");
    }
}

- (NSData *)buildMultipartFormDataPostBody
{
    NSString *boundary = @"293iosfksdfkiowjksdf31jsiuwq003s02dsaffafass3qw";
    
    NSMutableData *body = [NSMutableData data];
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"upload1\"; filename=\"%@\"\r\n",@"image.jpg"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:UIImageJPEGRepresentation(userIcon.image, .3)];
    [body appendData:[@"\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
 
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    return body;
}

- (void)sendUserInfo:(NSArray *)urls goBack:(BOOL)back
{
    [Global showTipAlways:NSLocalizedString(@"发送中...",nil)];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/api/modifyUserInfo", [AppConfig sharedAppConfig].serverIf];

    NSURL *url = [NSURL URLWithString:urlString];
    HttpRequest *request = [HttpRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    
    NSString *userId = [Global userId];

    if (!self.nickTextField.text) {
        self.nickTextField.text = @"";
    }
    if (!self.mailTextField.text) {
        self.mailTextField.text = @"";
    }
    
    NSString *infoString = nil;
    
    NSString *password = [[NSUserDefaults standardUserDefaults] objectForKey:KuserAccountLoginPassWord];
    
    //第三方登录账号，密码为第三方的OpenID
    if([Global isThirtyLogin]){
        password = [[NSUserDefaults standardUserDefaults] objectForKey:KuserAccountssoCode];
    }
    else{
        password = [password stringFromMD5];
    }
    NSString *faceUrl = [[NSUserDefaults standardUserDefaults] objectForKey:KuserAccountFace];
    
    NSString *nickName = nickTextField.text;
    nickName = stringSpecialsupport(nickName);
    if ([againPWTextField.text isEmpty]) {
        infoString = [NSString stringWithFormat:@"sid=%@&uid=%@&nickName=%@&email=%@&password=%@&address=%@&faceUrl=%@",[AppConfig sharedAppConfig].sid, userId,nickName,mailTextField.text,password,adressTextField.text,faceUrl];
    }
    else
    {
        infoString = [NSString stringWithFormat:@"sid=%@&uid=%@&nickName=%@&email=%@&password=%@&newPassword=%@&address=%@&faceUrl=%@",[AppConfig sharedAppConfig].sid, userId,nickName,mailTextField.text,[originalPWTextField.text stringFromMD5],[againPWTextField.text stringFromMD5],adressTextField.text,faceUrl];
    }
    if ([Global isThirtyLogin]) {
        infoString = [NSString stringWithFormat:@"%@&%@",infoString,self.phoneTextField.text];
    }
    NSData *infoData = [infoString dataUsingEncoding:NSUTF8StringEncoding];
    
    [request setHTTPBody:infoData];
    
    [request setCompletionBlock:^(NSData *data) {
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers  error:nil];
        if ([[dict objectForKey:@"success"] boolValue]){
            
            [Global showTip:NSLocalizedString(@"用户信息更新成功",nil)];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:KchangeUserInfoNotification object:nil];
            
            [[NSUserDefaults standardUserDefaults] setObject:mailTextField.text forKey:KuserAccountMail];
            [[NSUserDefaults standardUserDefaults] setObject:nickTextField.text forKey:KuserAccountNickName];
            if (againPWTextField.text != nil && ![againPWTextField.text isEqualToString:@""]) {
                [[NSUserDefaults standardUserDefaults] setObject:againPWTextField.text forKey:KuserAccountLoginPassWord];
            }
            [[NSUserDefaults standardUserDefaults] setObject:adressTextField.text forKey:KuserAccountAdress];
            if (self.isChangeBind) {
                self.isChangeBind = NO;
            }else{
                if (back) {
                    [self goRightPageBack];
                }
            }
        }else{
            NSString *errorInfo = [dict objectForKey:@"msg"];
            [Global showTip:errorInfo];
        }
    }];
    
    [request setFailedBlock:^(NSError *error) {
        
        [Global showTip:NSLocalizedString(@"修改用户信息失败",nil)];
    }];
    
    [request startAsynchronous];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    //如果当前要显示的键盘，那么把UIDatePicker（如果在视图中）隐藏
    if (textField.tag != 1001) {
        if (self.datePicker.superview) {
            [self.datePicker removeFromSuperview];
        }
//        return YES;
    }
    //UIDatePicker以及在当前视图上就不用再显示了
    else if (self.datePicker.superview == nil && textField.tag == 1001) {
        //close all keyboard or data picker visible currently
        //        [self.testNameField resignFirstResponder];
        //        [self.testLocationField resignFirstResponder];
        //        [self.testOtherField resignFirstResponder];
        
        //此处将Y坐标设在最底下，为了一会动画的展示
        self.datePicker.frame = CGRectMake(10, kSHeight, kSWidth-20, 213);
        [datePicker setCalendar:[NSCalendar currentCalendar]];
        [self.view addSubview:backView];
        self.datePicker.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:self.datePicker];
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3f];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        self.datePicker.center = CGPointMake(self.datePicker.center.x, 200);
        [UIView commitAnimations];
    }
    
    if (textField.tag != 1002) {
        if (self.sexView.superview) {
            [self.sexView removeFromSuperview];
        }
//        else
//        {
//            
//        }
//        return YES;
    }
    //UIDatePicker以及在当前视图上就不用再显示了
    else if (self.sexView.superview == nil && textField.tag == 1002) {
        self.sexView.backgroundColor = UIColorFromString(@"234,234,234");
        self.sexView.hidden = NO;
        [self.view addSubview:self.sexView];
    }
    if (textField.tag != 1001 && textField.tag != 1002) {
        return YES;
    }
    return NO;
}

- (void)chooseDate:(UIDatePicker *)sender {
    NSDate *selectedDate = sender.date;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd";
    NSString *dateString = [formatter stringFromDate:selectedDate];
    self.birthTextField.text = dateString;
 
}
-(void)bindButtonClicked{
    NSString *phone = [[NSUserDefaults standardUserDefaults] objectForKey:KuserAccountPhone];
    FZChangePhoneNumberController * FZVC = [[FZChangePhoneNumberController alloc]init];
    if (phone.length) {
        FZVC.title = NSLocalizedString(@"更换手机号", nil);
    }else{
      FZVC.title = NSLocalizedString(@"绑定手机号", nil);
    }
    self.isChangeBind = YES;
    FZVC.isPush =YES;
    __weak typeof(self)weakSelf = self;
     FZVC.bindSuccessCallBack = ^(NSString * phone) {
         weakSelf.phoneTextField.text = phone;
         [weakSelf.bindButton setTitle:NSLocalizedString(@"重新绑定", nil) forState:UIControlStateNormal];
         weakSelf.bindButton.frame = CGRectMake(kSWidth-87, 10, 70, CELL_HEIGHT-20);
         [weakSelf sendUserInfo:nil goBack:NO];
     };
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:FZVC animated:YES];
}
@end
