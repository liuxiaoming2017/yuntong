//
//  PersonalCenterViewController.m
//  FounderReader-2.5
//
//  Created by lx on 15/8/13.
//
//
#import "SearchPageController.h"
#import "PersonalCenterViewController.h"
#import "ChangeUserInfoController.h"
#import "YXLoginViewController.h"
#import "FavoritePageController.h"
#import "SearchPageController.h"
#import "SetupPageController.h"
#import "Column.h"
#import "UIImage+Helper.h"
#import "MyCommentLIstController.h"
#import "NewsListConfig.h"
#import "UIView+Extention.h"
#import "AboutPageController.h"
#import "ColumnBarConfig.h"
#import "CreditWebViewController.h"
#import "CreditNavigationController.h"
#import "AESCrypt.h"
#import "Global.h"
#import "FounderIntegralRequest.h"
#import "NJWebPageController.h"
#import "DishViewController.h"
#import "PeopleDailyPageController.h"
#import "TemplateNewDetailViewController.h"
#import "MyInteractionController.h"
#import "TinyMallViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "FDScanViewController.h"
#import "UIDevice+FCUUID.h"
#import <UMMobClick/MobClick.h>

#import "FZChangePhoneNumberController.h"
#import "FavoritePageController.h"
#import "MyCommentLIstController.h"
#define pointScale 0.5

@interface PersonalCenterViewController ()
@property (nonatomic, retain) ImageViewCf *userImageView;
@property (nonatomic, retain) UILabel *userNameLabel;
@property (nonatomic, retain) UILabel *userMoneyLabel;
@property (nonatomic, retain) UIImageView *columnBar;
@property (nonatomic, retain) NSMutableArray *myMessages;
@property (nonatomic, retain) NSMutableArray *myImages;
@property (nonatomic, retain) NSMutableArray *controllerName;
@property (nonatomic, retain) UIImageView *headBackView;
@property (nonatomic, strong) UIView *dotView;
@end

@implementation PersonalCenterViewController
@synthesize userImageView,userNameLabel,userMoneyLabel,columnBar;
@synthesize myMessages,myImages,controllerName;
@synthesize tableView,headBackView;

-(void)dealloc
{
    self.userNameLabel = nil;
    self.userMoneyLabel = nil;
    self.userImageView = nil;
    self.columnBar = nil;
    self.headBackView = nil;
    //移除了所有的通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userDidLogin)
                                                 name:@"USERDIDLOGIN"
                                               object:nil];
    
    //左半背景
    UIView *tableViewBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSWidth/2.0f, kSHeight)];
    tableViewBgView.backgroundColor = UIColorFromString(@"0,0,0");
    [self.view addSubview:tableViewBgView];
    
    //列表视图
    tableView = [[UITableView alloc] init];
    self.tableView.scrollEnabled = YES;
    self.tableView.separatorStyle = UITableViewCellAccessoryNone;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.frame = CGRectMake(0, 0, kSWidth * 0.5, kSHeight-(27*proportion + 10 + 10));
    self.tableView.backgroundColor = UIColorFromString(@"0,0,0");
    [tableViewBgView addSubview:self.tableView];
    
    //头像背景
    headBackView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 750*pointScale, kSHeight * 0.35)];
    if (kSHeight<568) {
        headBackView.frame = CGRectMake(0, -20, 750*pointScale, kSHeight * 0.4);
    }
    headBackView.backgroundColor = [UIColor clearColor];
    headBackView.userInteractionEnabled = YES;
    UIImageView *headImgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 750*pointScale,  400*pointScale)];
    headImgView.image = [UIImage reSizeImage:[UIImage imageNamed:@"letfbg"] toSize:CGSizeMake(750*pointScale, 460*pointScale)];
    self.tableView.tableHeaderView = headBackView;
    
    //头像
    userImageView = [[ImageViewCf alloc] initWithFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width/4-70/2,70-20,70*proportion,70*proportion)];
    userImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.userImageView setDefaultImage:[UIImage imageNamed:@"icon-user-center"]];
    self.userImageView.layer.masksToBounds = YES;
    self.userImageView.layer.cornerRadius = userImageView.frame.size.width*0.5;
    self.userImageView.userInteractionEnabled = YES;
    userImageView.centerX = kSWidth*0.25;
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(signButtonClick:)];
    [self.userImageView addGestureRecognizer:recognizer];
    [headBackView addSubview:self.userImageView];
    
    //头像描边
    UIImageView *backImageView = [[UIImageView alloc] init];
    backImageView.center = userImageView.center;
    backImageView.frame = self.userImageView.frame;
    backImageView.height += 2;
    backImageView.image = [UIImage imageNamed:@"icon-user_layer"];
    [headBackView addSubview:backImageView];
    
    //昵称
    userNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(userImageView.frame)+10*proportion, kSWidth* 0.5 - 18*proportion/2.0f, 18*proportion)];
    userNameLabel.centerX = userImageView.centerX;
    self.userNameLabel.font = [UIFont boldSystemFontOfSize:[NewsListConfig sharedListConfig].leftUserNameFontSize];
    self.userNameLabel.backgroundColor = [UIColor clearColor];
    self.userNameLabel.textAlignment = NSTextAlignmentCenter;
    self.userNameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.userNameLabel.textColor = [UIColor whiteColor];//UIColorFromString(@"176,189,199");//UIColorFromString(@"88,88,88");
    self.userNameLabel.text = NSLocalizedString(@"立即登录",nil);
    [headBackView addSubview:self.userNameLabel];
    
    //积分数
    userMoneyLabel = [[UILabel alloc]initWithFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width/4-90/2, CGRectGetMaxY(userNameLabel.frame)+11*proportion, 90, 20)];
    self.userMoneyLabel.textColor = [ColumnBarConfig sharedColumnBarConfig].column_all_color;
    self.userMoneyLabel.font = [UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleCellDateFontSize ];
    self.userMoneyLabel.backgroundColor = [UIColor clearColor];
    self.userMoneyLabel.textAlignment = NSTextAlignmentCenter;
    self.userMoneyLabel.layer.borderWidth = .7;
    self.userMoneyLabel.layer.borderColor = [ColumnBarConfig sharedColumnBarConfig].column_all_color.CGColor;
    self.userMoneyLabel.centerX = kSWidth * 0.25;
    self.userMoneyLabel.text = [NSString stringWithFormat:@" %@%@ ", NSLocalizedString(@"登录赚",nil), [AppConfig sharedAppConfig].integralName];
    self.userMoneyLabel.layer.masksToBounds = YES;
    self.userMoneyLabel.layer.cornerRadius = 10;
    [headBackView addSubview:self.userMoneyLabel];
    self.userMoneyLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *moneyTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toMymoneyClick)];
    [self.userMoneyLabel addGestureRecognizer:moneyTap];
   
    UIButton *footBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, kSHeight - 30*proportion, kSWidth * 0.25, 20*proportion)];
    footBtn.centerX = kSWidth * 0.25;
    footBtn.backgroundColor = [UIColor clearColor];
    [footBtn setTitle:NSLocalizedString(@"输入邀请码",nil) forState:UIControlStateNormal];
    footBtn.layer.borderWidth = 1*proportion;
    footBtn.layer.cornerRadius = 20*0.5*proportion;
    footBtn.layer.borderColor = UIColorFromString(@"139,162,180").CGColor;
    footBtn.titleLabel.textColor = UIColorFromString(@"139,162,180");
    [footBtn setTitleColor:UIColorFromString(@"139,162,180") forState:UIControlStateNormal];
    footBtn.titleLabel.font = [UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleCellDateFontSize];
    footBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [footBtn addTarget:self action:@selector(inviteCodeButtonClick) forControlEvents:UIControlEventTouchUpInside];
    //[self.view addSubview:footBtn];
    
    //右半部空白view
    UIView *tapView = [[UIView alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width, 0, kSWidth-self.tableView.frame.size.width, kSHeight)];
    tapView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:tapView];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeAwayView)];
    [tapView addGestureRecognizer:tapRecognizer];
    
    //分享邀请码
    if (![AppConfig sharedAppConfig].isShowShareInvitationCode) {
        self.tableView.height = kSHeight;
    }else {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
        [formatter setDateFormat:@"YYYY-MM-dd"];
        
        NSDate *dateEnd = [formatter dateFromString:[AppConfig sharedAppConfig].inviteShareTime];
        NSTimeInterval timeEnd = [dateEnd timeIntervalSince1970];
        
        NSTimeInterval timeNow = [[NSDate date] timeIntervalSince1970];
        if (timeEnd < timeNow ) {
            UIView *inviteCodeBgView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.height - 23*proportion - 10, 90*proportion, 23*proportion)];
            inviteCodeBgView.centerX = self.tableView.centerX;
            inviteCodeBgView.backgroundColor = [UIColor clearColor];
            inviteCodeBgView.layer.masksToBounds = YES;
            inviteCodeBgView.layer.cornerRadius = 4;
            inviteCodeBgView.layer.borderColor = [ColumnBarConfig sharedColumnBarConfig].column_all_color.CGColor;
            inviteCodeBgView.layer.borderWidth = 0.5;
            inviteCodeBgView.userInteractionEnabled = YES;
            tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shareInviteCodeClick)];
            [inviteCodeBgView addGestureRecognizer:tapRecognizer];
            [tableViewBgView addSubview:inviteCodeBgView];
            
            UIImageView *inviteCodeImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_left_invitecode"]];
            [inviteCodeBgView addSubview:inviteCodeImageView];
            inviteCodeImageView.x = 8;
            inviteCodeImageView.y = (inviteCodeBgView.height - inviteCodeImageView.height)/2.0f;
            
            UILabel *inviteCodeLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(inviteCodeImageView.frame)+5, (inviteCodeBgView.height - 20)/2.0f, inviteCodeBgView.width-(CGRectGetMaxX(inviteCodeImageView.frame)+5+8), 20)];
            inviteCodeLabel.text = [AppConfig sharedAppConfig].shareAppLabel;
            inviteCodeLabel.textAlignment = 1;
            inviteCodeLabel.font = [UIFont systemFontOfSize:[NewsListConfig sharedListConfig].leftUserNameFontSize - 5.50f] ;
            inviteCodeLabel.textColor = [ColumnBarConfig sharedColumnBarConfig].column_all_color;
            [inviteCodeBgView addSubview:inviteCodeLabel];
        }
    }
    
    //加载视图列表数据
    NSArray *left_presonMenus = [[NSArray alloc] initWithContentsOfFile:pathForMainBundleResource(@"left_presonMenu.plist")];
    if (left_presonMenus.count)
    {
        self.myMessages = [[NSMutableArray alloc] initWithCapacity:left_presonMenus.count];
        self.myImages = [[NSMutableArray alloc] initWithCapacity:left_presonMenus.count];
        self.controllerName = [[NSMutableArray alloc] initWithCapacity:left_presonMenus.count];
        for (int i = 0; i < left_presonMenus.count; i++) {
            NSDictionary *dic = [left_presonMenus objectAtIndex:i];
            if (dic != nil)
            {
                [self.myMessages addObject:NSLocalizedString([dic objectForKey:@"name"], nil)];
                [self.myImages addObject:[dic objectForKey:@"image"]];
                [self.controllerName addObject:[dic objectForKey:@"class"]];
            }
            
        }
    }
    
    //更新会员信息
    [self updateUserInfo];
    //更新积分数
    [self updateMoneyNumber];
    
}

#pragma mark - 分享邀请码
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
    [self.view.superview.viewController presentViewController:[Global controllerToNav:controller] animated:YES completion:nil];
}

#pragma mark - 我的积分
- (void)toMymoneyClick
{
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
    [self.view.superview.viewController presentViewController:[Global controllerToNav:controller] animated:YES completion:nil];
}

#pragma mark - 进入积分商城
-(void)goBackIOS6
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)inviteCodeButtonClick
{
}


-(void)viewWillAppear:(BOOL)animated
{
    /* 因为本controller.view层次位置的原因，不会运行该方法，给个登录通知 */
    [super viewWillAppear:animated];
    [self.tableView reloadData];
    [self updateUserInfo];
    
//    tableView.tableHeaderView = headBackView;
    
    self.navigationController.navigationBarHidden = YES;
    self.tableView.userInteractionEnabled = YES;
}

- (void)userDidLogin
{
    [self updateUserInfo];
}

-(void)updateUserInfo
{
    [self downLoadMyScore];
    NSString *userId = [Global userId];
    NSString *loginName = [[NSUserDefaults standardUserDefaults] objectForKey:KuserAccountLoginName];
    NSString *icon = [[NSUserDefaults standardUserDefaults] objectForKey:KuserAccountFace];
    NSString *nick = [[NSUserDefaults standardUserDefaults] objectForKey:KuserAccountNickName];
    if (icon.length) {
        //微博登录头像不更新
        [self.userImageView setUrlString:icon];
        
    }else{
        [self.userImageView setDefaultImage:[UIImage imageNamed:@"icon-user-center"]];
        
    }
    
    if (nick.length) {
        self.userNameLabel.text = nick;
        
    }else{
        self.userNameLabel.text = loginName;
    }
    
    if (!userId.length) {
        self.userNameLabel.text = NSLocalizedString(@"立即登录",nil);
        self.userMoneyLabel.text = [NSString stringWithFormat:@" %@%@ ", NSLocalizedString(@"登录赚",nil), [AppConfig sharedAppConfig].integralName];
        self.userMoneyLabel.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width/4-90/2, CGRectGetMaxY(userNameLabel.frame)+11*proportion, 90, 20);
    }else
    {
        [self updateMoneyNumber];
    }
}

-(void)updateMoneyNumber
{
    NSString *uid = [Global userId];
    NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleCellDateFontSize ] , NSFontAttributeName,nil];
    if (!uid.length) {
        self.userNameLabel.text = NSLocalizedString(@"立即登录",nil);
        self.userMoneyLabel.text = [NSString stringWithFormat:@" %@%@ ", NSLocalizedString(@"登录赚",nil), [AppConfig sharedAppConfig].integralName];
        NSString *str = [NSString stringWithFormat:@" %@%@ ", NSLocalizedString(@"登录赚",nil), [AppConfig sharedAppConfig].integralName];
        CGSize size = [str boundingRectWithSize:CGSizeMake(kSWidth*0.5, 20) options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading attributes:tdic context:nil].size;
        
         userMoneyLabel.width = size.width+10;
        return;
    }
    NSString *money = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@%@",uid,KuserAccountMoneyStr]] ;
    if (money == nil || [money isEqualToString:@""]) {
        money = @"";
    }
    NSString *moneyNum = [NSString stringWithFormat:@" %@ %@",money, [AppConfig sharedAppConfig].integralName];
    CGSize size = [moneyNum boundingRectWithSize:CGSizeMake(kSWidth*0.5, 20) options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading attributes:tdic context:nil].size;
    
    userMoneyLabel.size = size;
    userMoneyLabel.width = size.width+10;
    userMoneyLabel.height = 20;
    userMoneyLabel.centerX = kSWidth * 0.25;
    self.userMoneyLabel.text =moneyNum;
}


-(void)signButtonClick:(UIButton*)sender
{
    /*
    if ([Global isThirtyLogin]) {
        UIAlertView *logoutAlertView = [[UIAlertView alloc] initWithTitle:@"是否确认退出登录" message:@"" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:@"取消", nil];
        logoutAlertView.tag = 911;
        [logoutAlertView show];
        return;
    }
    else
    */
    if ([Global userId].length > 0)
    {
        NSString * phone = [[NSUserDefaults standardUserDefaults] objectForKey:KuserAccountPhone];
        if ([AppConfig sharedAppConfig].isNeedBindPhoneNumber && !phone.length ) {
            FZChangePhoneNumberController * changePhone = [[FZChangePhoneNumberController alloc]init];
            changePhone.title = NSLocalizedString(@"绑定手机号", nil);
            changePhone.isPush = NO;
            __weak typeof(self) weakSelf = self;
            changePhone.cancleBindCallBack = ^{
                [weakSelf showLoginPage];
            };
            changePhone.isPush = NO;
            [self presentViewController:[Global controllerToNav:changePhone] animated:YES completion:nil];
            return;
        }
        
        ChangeUserInfoController *controller = [[ChangeUserInfoController alloc]init];
        [self.view.superview.viewController presentViewController:[Global controllerToNav:controller] animated:YES completion:nil];
        return;
    }
    [self showLoginPage];
    
}

-(void)settingButtonClick:(UIButton*)sender
{
    [self showSetupButtonPage];
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
    
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:KthirdPartyUserAccountUserId];
    
    [self updateUserInfo];
}

-(void)updateLoginFace
{
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 911){
        
        if (buttonIndex == 0)
        {
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
            [self updateLoginFace];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"duiba-load-WebView" object:self userInfo:nil];
        }
    }
}
-(void)showLoginPage
{
    YXLoginViewController *controller = [[YXLoginViewController alloc]init];
    [controller rightPageNavTopButtons];
    NSString * phone = [[NSUserDefaults standardUserDefaults] objectForKey:KuserAccountPhone];
    if ([AppConfig sharedAppConfig].isNeedBindPhoneNumber && !phone.length) {
        controller.isFromBind = YES;
    }
    [appDelegate().window.rootViewController presentViewController:[Global controllerToNav:controller] animated:YES completion:nil];
}

-(void)showSetupButtonPage
{
    SetupPageController *controller = [[SetupPageController alloc] init];
    [appDelegate().window.rootViewController presentViewController:[Global controllerToNav:controller] animated:YES completion:nil];
}

- (void)downLoadMyScore{
    if (![Global userId].length) {
        return;
    }
    
    FounderIntegralRequest *intergralRequest = [[FounderIntegralRequest alloc] init];
    [intergralRequest getAllIntegral];
    [intergralRequest setIntegralBlock:^(NSDictionary *integralDict) {
        NSNumber *scores = [integralDict objectForKey:@"scores"];
        if (scores == nil) {
            return;
        }
        NSString *scoresStr = [NSString stringWithFormat:@"%@", scores];
        [[NSUserDefaults standardUserDefaults] setObject:scoresStr forKey:[NSString stringWithFormat:@"%@%@",[Global userId],KuserAccountMoneyStr]];
        [self updateMoneyNumber];
        
        //小红点
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:[NSString stringWithFormat:@"%@%@",[Global userId],KuserAccountAskDotViewShow]];
        [[NSUserDefaults standardUserDefaults] synchronize];
        NSDictionary *interaction = integralDict[@"interaction"];
        if (interaction[@"askPlusReply"]) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[NSString stringWithFormat:@"%@%@",[Global userId],KuserAccountAskDotViewShow]];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
//        for (NSDictionary *dotDict in integralDict[@"interaction"][@"list"]) {
//            NSString *type = dotDict[@"type"];
//            if ([type isEqualToString:@"ask"]) {
//                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[NSString stringWithFormat:@"%@%@",[Global userId],KuserAccountAskDotViewShow]];
//                [[NSUserDefaults standardUserDefaults] synchronize];
//            }
//        }
        [self.tableView reloadData];
    }];
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
#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (IS_IPHONE_4) {
        return 40*proportion;
    }
    return 50*proportion;
}

- (void)tableView:(UITableView *)sender didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [sender deselectRowAtIndexPath:indexPath animated:YES];
    NSString *contrllerStr = [self.controllerName objectAtIndex:indexPath.row];
   
    if ([contrllerStr isEqualToString:@"CreditWebViewController"])
    {//积分商城
        [self interalWebView];
        [MobClick event:@"left_function" attributes:@{@"home_left_select_click":NSLocalizedString(@"积分商城", nil)}];
        return;
    }else if ([contrllerStr isEqualToString:@"TinyMallViewController"])
    {//有赞商城
        TinyMallViewController *mallVC = [[TinyMallViewController alloc] init];
        mallVC.isFromLeftMenu = YES;
        [MobClick event:@"left_function" attributes:@{@"home_left_select_click":NSLocalizedString(@"有赞商城", nil)}];
        mallVC.mallTitle = myMessages[indexPath.row];
        [self.view.superview.viewController presentViewController:[Global controllerToNav:mallVC] animated:YES completion:nil];
        return;
    }
    else if ([contrllerStr isEqualToString:@"SetupPageController"])
    {//设置
        [self showSetupButtonPage];
        [MobClick event:@"left_function" attributes:@{@"home_left_select_click":NSLocalizedString(@"设置", nil)}];
        return;
    }
    else if ([contrllerStr isEqualToString:@"MyInteractionController"]) {
        //我的互动
        [MobClick event:@"left_function" attributes:@{@"home_left_select_click":NSLocalizedString(@"我的互动", nil)}];
        MyInteractionController *interactionController = [[MyInteractionController alloc] init];
        [self.view.superview.viewController presentViewController:[Global controllerToNav:interactionController] animated:YES completion:nil];
        return;
    }
    //搜索
    else if([contrllerStr isEqualToString:@"SearchPageController"]){
        [MobClick event:@"left_function" attributes:@{@"home_left_select_click":NSLocalizedString(@"搜索", nil)}];
        SearchPageController *controller = [[NSClassFromString(contrllerStr) alloc] init];
        controller.hidesBottomBarWhenPushed = YES;
        [self.view.superview.viewController presentViewController:[Global controllerToNav:controller] animated:YES completion:nil];
    }
    // 报料
    else if([contrllerStr isEqualToString:@"DishViewController"]){
        [MobClick event:@"left_function" attributes:@{@"home_left_select_click":NSLocalizedString(@"报料", nil)}];
        DishViewController *controller = [[NSClassFromString(contrllerStr) alloc] init];
        controller.hidesBottomBarWhenPushed = YES;
        controller.navStyle = 1;
        [self.view.superview.viewController presentViewController:[Global controllerToNav:controller] animated:YES completion:nil];
    }
    //读报
    else if([contrllerStr isEqualToString:@"PeopleDailyPageController"]){
        [MobClick event:@"left_function" attributes:@{@"home_left_select_click":NSLocalizedString(@"读报", nil)}];
        PeopleDailyPageController *controller = [[PeopleDailyPageController alloc] init];
        controller.hidesBottomBarWhenPushed = YES;
        controller.navStyle = 1;
        [self.view.superview.viewController presentViewController:[Global controllerToNav:controller] animated:YES completion:nil];
    }
    //评论
    else if([contrllerStr isEqualToString:@"MyCommentLIstController"]){
        if (![Global userId].length) {
            YXLoginViewController *controller = [[YXLoginViewController alloc]init];
            controller.loginSuccessBlock = ^(){
                ChannelPageController *controller = [[NSClassFromString(contrllerStr) alloc] init];
                controller.hidesBottomBarWhenPushed = YES;
                [self.view.superview.viewController presentViewController:[Global controllerToNav:controller] animated:YES completion:nil];
            };
            [controller rightPageNavTopButtons];
            [self.view.superview.viewController presentViewController:[Global controllerToNav:controller] animated:YES completion:nil];
            return;
        }
        else{
            [MobClick event:@"left_function" attributes:@{@"home_left_select_click":NSLocalizedString(@"评论", nil)}];
            ChannelPageController *controller = [[NSClassFromString(contrllerStr) alloc] init];
            controller.hidesBottomBarWhenPushed = YES;
            [self.view.superview.viewController presentViewController:[Global controllerToNav:controller] animated:YES completion:nil];
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
            [self.view.superview.viewController presentViewController:[Global controllerToNav:controller] animated:YES completion:nil];
            return;
        }
        else{
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
            [self.view.superview.viewController presentViewController:[Global controllerToNav:controller] animated:YES completion:nil];
            return;
        }
        else{
        [self showMyAnswerControllerWithContrllerStr:contrllerStr];
            [MobClick event:@"left_function" attributes:@{@"home_left_select_click":NSLocalizedString(@"我的提问", nil)}];
        }
    }
    else if ([contrllerStr isEqualToString:@"FDScanViewController"]) {
        //扫一扫
        [MobClick event:@"left_function" attributes:@{@"home_left_select_click":NSLocalizedString(@"扫一扫", nil)}];
        if ([self canOpenCamera]) {
            FDScanViewController *vc = [[FDScanViewController alloc] init];
            [self.view.superview.viewController presentViewController:[Global controllerToNav:vc] animated:YES completion:nil];
            return;
        }
    }else if ([contrllerStr isEqualToString:@"FavoritePageController"]){
        FavoritePageController *favc = [[FavoritePageController alloc]init];
        [self.view.superview.viewController presentViewController:[Global controllerToNav:favc] animated:YES completion:nil];
        return;
    }else if ([contrllerStr isEqualToString:@"MyCommentLIstController"]){
        MyCommentLIstController *comvc = [[MyCommentLIstController alloc] init];
        [self.view.superview.viewController presentViewController:[Global controllerToNav:comvc] animated:YES completion:nil];
        return;
    }
    else
    {
        [MobClick event:@"left_function" attributes:@{@"home_left_select_click":contrllerStr}];
        ChannelPageController *controller = [[NSClassFromString(contrllerStr) alloc] init];
        controller.hidesBottomBarWhenPushed = YES;
        [self.view.superview.viewController presentViewController:[Global controllerToNav:controller] animated:YES completion:nil];
    }
    
    self.navigationController.navigationBarHidden = NO;
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


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.myMessages.count;
}

- (UITableViewCell *)tableView:(UITableView *)sender cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"message"];
    cell.shouldIndentWhileEditing = NO;
  
    CGFloat imageViewY;
    if (!indexPath.row) {
        imageViewY = (50*proportion - 27)/2.0;
        if (IS_IPHONE_4) {
            imageViewY = (40*proportion - 27)/2.0;
        }
    }else{
        imageViewY = (50*proportion - 23)/2.0;
        if (IS_IPHONE_4) {
            imageViewY = (40*proportion - 23)/2.0;
        }
    }
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.image = [UIImage imageNamed:self.myImages[indexPath.row]];
    imageView.frame = CGRectMake(28*proportion, imageViewY, 23, 23);
    
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageView.frame)+15*proportion, (50*proportion - 23)/2.0, 150, 23)];
    
    if (IS_IPHONE_4) {
        label.frame = CGRectMake(CGRectGetMaxX(imageView.frame)+15*proportion, (40*proportion - 23)/2.0, 150, 23);
    }
    label.font = [UIFont systemFontOfSize:[NewsListConfig sharedListConfig].leftUserNameFontSize - 2];
    NSString *text = [self.myMessages objectAtIndex:indexPath.row];
    label.text = [text containsString:@"积分"] ? [text stringByReplacingOccurrencesOfString:@"积分" withString: [AppConfig sharedAppConfig].integralName] : text;
    label.textColor = [UIColor whiteColor];//UIColorFromString(@"139,162,180");
    label.backgroundColor = [UIColor clearColor];
    [cell.contentView addSubview:imageView];
    [cell.contentView addSubview:label];

    cell.selectionStyle = 1;
    cell.selectedBackgroundView =[[UIView alloc] initWithFrame:cell.frame];

    cell.selectedBackgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"icon_left_btn-press"]];

    cell.backgroundColor = [UIColor clearColor];
    
    //小红点
    NSString *contrllerStr = [self.controllerName objectAtIndex:indexPath.row];
    if ([contrllerStr isEqualToString:@"MyInteractionController"]) {
        CGFloat diameter = 5;
        CGFloat x = CGRectGetMinX(label.frame) - 10 - diameter/2.f;
        CGFloat y = CGRectGetMidY(label.frame) - diameter/2.f;
        _dotView = [[UIView alloc] initWithFrame:CGRectMake(x, y, diameter, diameter)];
        _dotView.clipsToBounds = YES;
        _dotView.layer.cornerRadius = diameter/2.f;
        _dotView.backgroundColor = [UIColor redColor];
        [cell.contentView addSubview:_dotView];
        _dotView.hidden = ![[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"%@%@",[Global userId],KuserAccountAskDotViewShow]];
    }
    
    return cell;
}


-(void)removeAwayView
{
    [self.sideBar dismissAnimated:YES];
}

- (void)ActivityControllerWithContrllerStr:(NSString *)contrllerStr {
    //http://h5.newaircloud.com/myactivity?sc=xy&uid=123&sign=AES(sc+uid)
    NJWebPageController * controller = [[NJWebPageController alloc] init];
    Column *one = [[Column alloc] init];
    one.linkUrl = [NSString stringWithFormat:@"%@/myactivity?sc=%@&uid=%@&sign=%@",[AppConfig sharedAppConfig].serverIf,[AppConfig sharedAppConfig].sid, [Global userId], [AESCrypt encrypt:[NSString stringWithFormat:@"%@%@", [AppConfig sharedAppConfig].sid,[Global userId]] password:key]];
    one.columnName = NSLocalizedString(@"我的活动",nil);
    controller.parentColumn = one;
    controller.isFromModal = YES;
    [self.view.superview.viewController presentViewController:[Global controllerToNav:controller] animated:YES completion:nil];
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
    [self.view.superview.viewController presentViewController:[Global controllerToNav:controller] animated:YES completion:nil];
}

@end

