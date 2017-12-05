//
//  BottomPersonalCenterController.m
//  FounderReader-2.5
//
//  Created by mac on 2017/6/19.
//
//

#import "BottomPersonalCenterController.h"
#import "ColumnBarConfig.h"
#import "ChangeUserInfoController.h"
#import "YXLoginViewController.h"
#import "CreditWebViewController.h"
#import "TinyMallViewController.h"
#import "MyInteractionController.h"
#import "SearchPageController.h"
#import "DishViewController.h"
#import "PeopleDailyPageController.h"
#import "SetupPageController.h"
#import "FDScanViewController.h"
#import "NJWebPageController.h"
#import "UserAccountDefine.h"
#import <AVFoundation/AVFoundation.h>
#import "ImageViewCf.h"
#import "AESCrypt.h"
#import "NewsListConfig.h"
#import "PersonMenu.h"
#import "PersonMenuCell.h"
#import "WaterView.h"
#import "UIDevice+FCUUID.h"
#import <UMMobClick/MobClick.h>
#import "FZChangePhoneNumberController.h"
@interface BottomPersonalCenterController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong)UITableView * personalTableView;
@property (nonatomic,strong)ImageViewCf * iconIV;
@property (nonatomic,strong)UILabel * nameLabel;
@property (nonatomic,strong)UILabel * integralLabel;
@property (nonatomic,strong)UIImageView * integralIV;

@property (nonatomic,strong)UIImageView * headBgView;
@property (nonatomic,strong)UIView * headView;
@property (nonatomic,strong)NSMutableArray * dataSource;
@property (nonatomic,strong)UILabel * loginLabel;
@property (nonatomic,strong)UIButton * loginBtn;


@end

@implementation BottomPersonalCenterController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self titleLableWithTitle:@"个人中心"];
    [self setUpUI];
}

-(void)setUpUI{
    self.automaticallyAdjustsScrollViewInsets = NO;
    //[UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    self.navigationController.navigationBar.hidden = YES;
    
   
    
    WaterView * headbg = [[WaterView alloc] initWithFrame:CGRectMake(0, 0, kSWidth, 152*kScale)];
    
    self.loginBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 61*kHScale, 88*kScale, 28*kHScale)];
    self.loginBtn.center = CGPointMake(kSWidth * 0.5, 70*kHScale);
    
    [self.loginBtn addTarget:self action:@selector(loginBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.loginBtn setTitle:NSLocalizedString(@"立即登录",nil) forState:UIControlStateNormal];
    self.loginBtn.titleLabel.textColor = [UIColor whiteColor];
    CGFloat fontSize = 16;
    if (kSWidth < 325) {
        fontSize = 14;
    }
    self.loginBtn.titleLabel.font = [UIFont systemFontOfSize:fontSize];
    self.loginBtn.hidden = YES;
    self.loginBtn.layer.masksToBounds = YES;
    self.loginBtn.layer.cornerRadius = 14.0;
    self.loginBtn.layer.borderWidth = 1.0;
    self.loginBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    self.loginBtn.backgroundColor = [UIColor clearColor];
    [headbg addSubview:self.loginBtn];
    
    self.loginLabel = [[UILabel alloc]init];
    self.loginLabel.hidden = YES;
    self.loginLabel.frame = CGRectMake(kSWidth * 0.5-50, CGRectGetMaxY(self.loginBtn.frame) + 10*kHScale, 100, 14);
    self.loginLabel.text = [NSString stringWithFormat:@" %@%@ ", NSLocalizedString(@"登录赚",nil), [AppConfig sharedAppConfig].integralName];
    self.loginLabel.textColor = [UIColor whiteColor];
    self.loginLabel.textAlignment = NSTextAlignmentCenter;
    self.loginLabel.font = [UIFont systemFontOfSize:13];
    [headbg addSubview:self.loginLabel];
    
    self.iconIV = [[ImageViewCf alloc]initWithFrame:CGRectMake(55*kScale, 42*kHScale, 60, 60)];
    self.iconIV.layer.cornerRadius = 30;
    self.iconIV.layer.masksToBounds = YES;
    self.iconIV.hidden = YES;
    self.iconIV.userInteractionEnabled = YES;
    self.iconIV.layer.borderColor = [UIColor whiteColor].CGColor;
    self.iconIV.layer.borderWidth = 2.0;
    UITapGestureRecognizer * changeInfoTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(loginBtnClicked)];
    [self.iconIV addGestureRecognizer:changeInfoTap];
    [headbg addSubview:self.iconIV];
    
    self.nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(130*kScale, self.iconIV.center.y-23, kSWidth-130, 16)];
    self.nameLabel.textAlignment = NSTextAlignmentLeft;
    self.nameLabel.hidden = YES;
    self.nameLabel.textColor = [UIColor whiteColor];
    self.nameLabel.font = [UIFont systemFontOfSize:16];
    [headbg addSubview:self.nameLabel];
    
    self.integralIV = [[UIImageView alloc]initWithFrame:CGRectMake(130*kHScale, CGRectGetMaxY(self.nameLabel.frame)+14, 11, 11)];
    self.integralIV.image = [UIImage imageNamed:@"mine_integral"];
    self.integralIV.hidden = YES;
    [headbg addSubview:self.integralIV];
    
    self.integralLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.integralIV.frame)+8, CGRectGetMaxY(self.nameLabel.frame)+14, kSWidth-110, 12)];
    self.integralLabel.textAlignment = NSTextAlignmentLeft;
    self.integralLabel.hidden = YES;
    self.integralLabel.textColor = [UIColor whiteColor];
    self.integralLabel.font = [UIFont systemFontOfSize:12];
    self.integralLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(integralClicked)];
    [self.integralLabel addGestureRecognizer:tap];
    [headbg addSubview:self.integralLabel];
    
     self.headBgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, -152*kHScale, kSWidth, 152*kHScale)];
    self.headBgView.backgroundColor = [ColumnBarConfig sharedColumnBarConfig].column_all_color;
    
    
    self.personalTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kSWidth, kSHeight-kTabBarHeight)];
    self.personalTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.personalTableView.delegate = self;
    self.personalTableView.dataSource = self;
    [self.view addSubview:self.personalTableView];
    self.personalTableView.tableHeaderView = headbg;
    
    [self.personalTableView addSubview:self.headBgView];
}
-(void)updateUserInfo
{
    
    NSString *userId = [Global userId];
    NSString *loginName = [[NSUserDefaults standardUserDefaults] objectForKey:KuserAccountLoginName];
    NSString *icon = [[NSUserDefaults standardUserDefaults] objectForKey:KuserAccountFace];
    NSString *nick = [[NSUserDefaults standardUserDefaults] objectForKey:KuserAccountNickName];
    if (icon.length) {
        //微博登录头像不更新
        [self.iconIV setUrlString:icon];
        
    }else{
        [self.iconIV setDefaultImage:[UIImage imageNamed:@"icon-user-center"]];
        
    }
    
    if (nick.length) {
        self.nameLabel.text = nick;
        
    }else{
        self.nameLabel.text = loginName;
    }
    
    if (userId.length)
    {
        self.nameLabel.hidden = NO;
        self.integralIV.hidden = NO;
        self.integralLabel.hidden = NO;
        self.iconIV.hidden = NO;
        self.loginLabel.hidden = YES;
        self.loginBtn.hidden = YES;
        
        [self updateMoneyNumber];
    }else{
        self.loginLabel.hidden = NO;
        self.loginBtn.hidden = NO;
        self.nameLabel.hidden = YES;
        self.integralIV.hidden = YES;
        self.integralLabel.hidden = YES;
        self.iconIV.hidden = YES;
    }
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
//    self.tabBarController.tabBar.hidden= NO;
    [self updateUserInfo];
}
-(void)updateMoneyNumber
{
    NSString *uid = [Global userId];
    if (!uid.length) {
        return;
    }
    NSString *money = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@%@",uid,KuserAccountMoneyStr]] ;
    if (money == nil || [money isEqualToString:@""]) {
        money = @"100";
    }
    NSString *moneyNum = [NSString stringWithFormat:@" %@ %@",money, [AppConfig sharedAppConfig].integralName];
    self.integralLabel.text =moneyNum;
}

#pragma mark -- TableViewDataSource && TableViewDelegate
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    PersonMenuCell * cell = [PersonMenuCell creatPersonalMenuCellWithTableView:tableView];
    PersonMenu * menu = self.dataSource[indexPath.row];
    cell.menu = menu;
    return cell;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 49*kHScale;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    PersonMenu * menu = self.dataSource[indexPath.row];
    NSString *contrllerStr = menu.class;
    
    if ([contrllerStr isEqualToString:@"CreditWebViewController"])
    {//积分商城
        [MobClick event:@"left_function" attributes:@{@"home_left_select_click":NSLocalizedString(@"积分商城", nil)}];
        [self interalWebView];
        return;
    }else if ([contrllerStr isEqualToString:@"TinyMallViewController"])
    {//有赞商城
        [MobClick event:@"left_function" attributes:@{@"home_left_select_click":NSLocalizedString(@"有赞商城", nil)}];
        TinyMallViewController *mallVC = [[TinyMallViewController alloc] init];
        mallVC.isFromLeftMenu = YES;
        mallVC.mallTitle = menu.name;
        [self presentViewController:[Global controllerToNav:mallVC] animated:YES completion:nil];
        return;
    }
    else if ([contrllerStr isEqualToString:@"SetupPageController"])
    {//设置
        [MobClick event:@"left_function" attributes:@{@"home_left_select_click":NSLocalizedString(@"设置", nil)}];
        [self showSetupButtonPage];
        return;
    }
    else if ([contrllerStr isEqualToString:@"MyInteractionController"]) {
        //我的互动
        [MobClick event:@"left_function" attributes:@{@"home_left_select_click":NSLocalizedString(@"我的互动", nil)}];
        MyInteractionController *interactionController = [[MyInteractionController alloc] init];
        [self presentViewController:[Global controllerToNav:interactionController] animated:YES completion:nil];
        return;
    }
    //搜索
    else if([contrllerStr isEqualToString:@"SearchPageController"]){
        [MobClick event:@"left_function" attributes:@{@"home_left_select_click":NSLocalizedString(@"搜索", nil)}];
        SearchPageController *controller = [[NSClassFromString(contrllerStr) alloc] init];
        controller.hidesBottomBarWhenPushed = YES;
        [self presentViewController:[Global controllerToNav:controller] animated:YES completion:nil];
    }
    // 报料
    else if([contrllerStr isEqualToString:@"DishViewController"]){
        [MobClick event:@"left_function" attributes:@{@"home_left_select_click":NSLocalizedString(@"报料", nil)}];
        DishViewController *controller = [[NSClassFromString(contrllerStr) alloc] init];
        controller.hidesBottomBarWhenPushed = YES;
        controller.navStyle = 1;
        [self presentViewController:[Global controllerToNav:controller] animated:YES completion:nil];
    }
    //读报
    else if([contrllerStr isEqualToString:@"PeopleDailyPageController"]){
        [MobClick event:@"left_function" attributes:@{@"home_left_select_click":NSLocalizedString(@"读报", nil)}];
        PeopleDailyPageController *controller = [[PeopleDailyPageController alloc] init];
        controller.hidesBottomBarWhenPushed = YES;
        controller.navStyle = 1;
        [self presentViewController:[Global controllerToNav:controller] animated:YES completion:nil];
    }
    //评论
    else if([contrllerStr isEqualToString:@"MyCommentLIstController"]){
        if (![Global userId].length) {
            YXLoginViewController *controller = [[YXLoginViewController alloc]init];
            controller.loginSuccessBlock = ^(){

                ChannelPageController *controller = [[NSClassFromString(contrllerStr) alloc] init];
                controller.hidesBottomBarWhenPushed = YES;
                [self presentViewController:[Global controllerToNav:controller] animated:YES completion:nil];
            };
            [controller rightPageNavTopButtons];
            [self presentViewController:[Global controllerToNav:controller] animated:YES completion:nil];
            return;
        }
        else{
            [MobClick event:@"left_function" attributes:@{@"home_left_select_click":NSLocalizedString(@"评论", nil)}];
            ChannelPageController *controller = [[NSClassFromString(contrllerStr) alloc] init];
            controller.hidesBottomBarWhenPushed = YES;
            [self presentViewController:[Global controllerToNav:controller] animated:YES completion:nil];
        }
    }
    //我的活动
    else if ([contrllerStr isEqualToString:@"MyActivityController"]) {
        if (![Global userId].length) {
            YXLoginViewController *controller = [[YXLoginViewController alloc]init];
            controller.loginSuccessBlock = ^(){
                [self ActivityControllerWithContrllerStr:contrllerStr];
            };
            [controller rightPageNavTopButtons];
            [self presentViewController:[Global controllerToNav:controller] animated:YES completion:nil];
            return;
        }else{
             [MobClick event:@"left_function" attributes:@{@"home_left_select_click":NSLocalizedString(@"我的活动", nil)}];
            [self ActivityControllerWithContrllerStr:contrllerStr];
        }
    }
    else if ([contrllerStr isEqualToString:@"MyAnswerController"]) {
        // 我的提问
        if (![Global userId].length) {
            YXLoginViewController *controller = [[YXLoginViewController alloc]init];
            controller.loginSuccessBlock = ^(){
                [self showMyAnswerControllerWithContrllerStr:contrllerStr];
            };
            [controller rightPageNavTopButtons];
            [self presentViewController:[Global controllerToNav:controller] animated:YES completion:nil];
            return;
        } else{
            [MobClick event:@"left_function" attributes:@{@"home_left_select_click":NSLocalizedString(@"我的提问", nil)}];
            [self showMyAnswerControllerWithContrllerStr:contrllerStr];
        }
    }else if ([contrllerStr isEqualToString:@"FDScanViewController"]) {
        //扫一扫
         [MobClick event:@"left_function" attributes:@{@"home_left_select_click":NSLocalizedString(@"扫一扫", nil)}];
        if ([self canOpenCamera]) {
            FDScanViewController *vc = [[FDScanViewController alloc] init];
            [self presentViewController:[Global controllerToNav:vc] animated:YES completion:nil];
            return;
        }
    }
    else if ([contrllerStr isEqualToString:@"InviteCodeViewController"]){

         [MobClick event:@"left_function" attributes:@{@"home_left_select_click":NSLocalizedString(@"邀请码", nil)}];
        [self shareInviteCodeClick];
    }else
    {
        [MobClick event:@"left_function" attributes:@{@"home_left_select_click":contrllerStr}];
        ChannelPageController *controller = [[NSClassFromString(contrllerStr) alloc] init];
        controller.hidesBottomBarWhenPushed = YES;
        [self presentViewController:[Global controllerToNav:controller] animated:YES completion:nil];
    }
    
    self.navigationController.navigationBarHidden = NO;
}
- (void)interalWebView
{
    CreditWebViewController *web = [[CreditWebViewController alloc] init];
    
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftButton setImage:[UIImage imageNamed:@"btn_return"] forState:UIControlStateNormal];
    [leftButton sizeToFit];
    leftButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    leftButton.contentEdgeInsets = UIEdgeInsetsMake(10, -10, 10, 30);
    
    [leftButton addTarget:self action:@selector(goBackIOS6) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    [web.navigationItem setLeftBarButtonItem:leftItem];
    [self presentViewController:[Global controllerToNav:web] animated:YES completion:nil];
}

-(void)showSetupButtonPage
{
    SetupPageController *controller = [[SetupPageController alloc] init];
    [appDelegate().window.rootViewController presentViewController:[Global controllerToNav:controller] animated:YES completion:nil];
}
- (void)ActivityControllerWithContrllerStr:(NSString *)contrllerStr {
    //http://h5.newaircloud.com/myactivity?sc=xy&uid=123&sign=AES(sc+uid)
    NJWebPageController * controller = [[NJWebPageController alloc] init];
    Column *one = [[Column alloc] init];
    one.linkUrl = [NSString stringWithFormat:@"%@/myactivity?sc=%@&uid=%@&sign=%@",[AppConfig sharedAppConfig].serverIf,[AppConfig sharedAppConfig].sid, [Global userId], [AESCrypt encrypt:[NSString stringWithFormat:@"%@%@", [AppConfig sharedAppConfig].sid,[Global userId]] password:key]];
    one.columnName = NSLocalizedString(@"我的活动",nil);
    controller.parentColumn = one;
    controller.isFromModal = YES;
    [self presentViewController:[Global controllerToNav:controller] animated:YES completion:nil];
}
- (void)showMyAnswerControllerWithContrllerStr:(NSString *)contrllerStr {
    //http://h5.newaircloud.com/my_ask?sc=xy&uid=67&sign=AES(sc+uid)
    NJWebPageController * controller = [[NJWebPageController alloc] init];
    Column *one = [[Column alloc] init];
    one.linkUrl = [NSString stringWithFormat:@"%@/my_ask?sc=%@&uid=%@&sign=%@",[AppConfig sharedAppConfig].serverIf,[AppConfig sharedAppConfig].sid, [Global userId], [AESCrypt encrypt:[NSString stringWithFormat:@"%@%@", [AppConfig sharedAppConfig].sid,[Global userId]] password:key]];
    NSLog(@"%@", [AESCrypt encrypt:@"xy67" password:key]);
    one.columnName = NSLocalizedString(@"我的提问",nil);
    controller.parentColumn = one;
    controller.isFromModal = YES;
    [self presentViewController:[Global controllerToNav:controller] animated:YES completion:nil];
}
- (void)shareInviteCodeClick
{
    NJWebPageController * controller = [[NJWebPageController alloc] init];
    Column *one = [[Column alloc] init];
    
    NSString *inviteCode = [[NSUserDefaults standardUserDefaults] objectForKey:KuserAccountInviteCode];
    inviteCode = [NSString isNilOrEmpty:inviteCode] || ![Global userId].length ? @"" : inviteCode;//没登录或者登出也要置邀请码为空，因为邀请网页会记忆
    
    one.linkUrl = [NSString stringWithFormat:@"%@/invitecode?sc=%@&uid=%@&code=%@",[AppConfig sharedAppConfig].serverIf, [AppConfig sharedAppConfig].sid, [Global userId], inviteCode];
    one.linkUrl = [NSString stringWithFormat:@"%@&xky_deviceid=%@&xky_sign=%@", one.linkUrl,[[UIDevice currentDevice] uuid], [AESCrypt encrypt:[[UIDevice currentDevice] uuid] password:key]];
    one.columnName = NSLocalizedString(@"分享邀请码",nil);
    controller.parentColumn = one;
    controller.isFromModal = YES;
    [self presentViewController:[Global controllerToNav:controller] animated:YES completion:nil];
}
- (BOOL)canOpenCamera {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == AVAuthorizationStatusAuthorized || status == AVAuthorizationStatusNotDetermined) {
        return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    } else {
        [self openSettingsWithTitle:@"需要相机权限"];
        return NO;
    }
}
- (void)openSettingsWithTitle:(NSString *)title {
    UIAlertController *alert =
    [UIAlertController alertControllerWithTitle:title
                                        message:NSLocalizedString(@"请点击开启跳转到设置中设置", nil)
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:
     [UIAlertAction actionWithTitle:NSLocalizedString(@"开启", nil)
                              style:UIAlertActionStyleDestructive
                            handler:^(UIAlertAction *action) {
                                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                            }]];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"不开启", nil)
                                              style:UIAlertActionStyleDefault
                                            handler:NULL]];
    [self presentViewController:alert animated:YES completion:nil];
}
#pragma mark Setter && Getter
-(NSMutableArray *)dataSource{
    if (_dataSource == nil) {
        _dataSource = [[NSMutableArray alloc]init];
        NSArray * personMenus = [NSArray arrayWithContentsOfFile:pathForMainBundleResource(@"left_presonMenu.plist")];
        for (NSDictionary * dict in personMenus) {
            PersonMenu * menu = [PersonMenu initWith:dict];
            [_dataSource addObject:menu];
        }
        if ([AppConfig sharedAppConfig].isShowShareInvitationCode) {
            PersonMenu * menu = [PersonMenu initWith:@{@"icon":@"my_yaoqing",@"name":@"邀请码",@"class":@"InviteCodeViewController"}];
            [_dataSource addObject:menu];
        }
    }
    return _dataSource;
}
//MARK: --action
-(void)goBackIOS6
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)loginBtnClicked{
    if ([Global userId].length > 0)
    {
        NSString * phone = [[NSUserDefaults standardUserDefaults] objectForKey:KuserAccountPhone];
        if ([AppConfig sharedAppConfig].isNeedBindPhoneNumber && !phone.length) {
            FZChangePhoneNumberController * changePhone = [[FZChangePhoneNumberController alloc]init];
            changePhone.title = NSLocalizedString(@"绑定手机号", nil);
            changePhone.isPush = YES;
            __weak typeof(self) weakSelf = self;
            changePhone.cancleBindCallBack = ^{
                [weakSelf showLoginPage];
                weakSelf.navigationController.navigationBar.hidden = YES;
            };
            self.navigationController.navigationBar.hidden = NO;
            self.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:changePhone animated:YES];
            self.hidesBottomBarWhenPushed = NO;
            return;
        }
        ChangeUserInfoController *controller = [[ChangeUserInfoController alloc]init];
        self.navigationController.navigationBar.hidden = NO;
        self.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:controller animated:YES];
        self.hidesBottomBarWhenPushed=NO;
        return;
    }
    [self showLoginPage];
}
-(void)integralClicked{
    
        if (![Global userId].length) {
            [self showLoginPage];
            return;
        }
    
        NJWebPageController * controller = [[NJWebPageController alloc] init];
        Column *one = [[Column alloc] init];
        
        one.linkUrl = [NSString stringWithFormat:@"%@/myScore?sc=%@&uid=%@",[AppConfig sharedAppConfig].serverIf, [AppConfig sharedAppConfig].sid, [Global userId]];
        one.columnName = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"我的",nil), [AppConfig sharedAppConfig].integralName];
        controller.parentColumn = one;
        controller.isFromModal = YES;
        [self presentViewController:[Global controllerToNav:controller] animated:YES completion:nil];
}
-(void)showLoginPage
{
    YXLoginViewController *controller = [[YXLoginViewController alloc]init];
    [controller rightPageNavTopButtons];
    controller.loginSuccessBlock = ^() {
            [self updateUserInfo];
    };
    NSString * phone = [[NSUserDefaults standardUserDefaults] objectForKey:KuserAccountPhone];
    if ([AppConfig sharedAppConfig].isNeedBindPhoneNumber && !phone.length) {
        controller.isFromBind = YES;
    }
    UINavigationController * navi = [Global controllerToNav:controller];
    [appDelegate().window.rootViewController presentViewController:navi animated:YES completion:nil];
}
-(void)goBack{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGPoint point = scrollView.contentOffset;
    if (point.y < -152*kHScale) {
        CGRect frame = self.headBgView.frame;
        frame.origin.y = point.y;
        frame.size.height = -point.y;
        self.headBgView.frame = frame;
    }
}
-(void)leftAndRightButton{
    
}
-(void)left{
    
}
-(void)right{
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
