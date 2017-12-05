//
//  SetupPageController.m
//  FounderReader-2.5
//
//  Created by chenfei on 4/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import "ColorStyleConfig.h"
#import "SetupPageController.h"
#import "FontSettingsController.h"
#import "CacheManager.h"
#import "AppConfig.h"
#import "UIDevice-Reachability.h"
#import "UIAlertView+Helper.h"
#import "NSString+Helper.h"
#import "AppStartInfo.h"
#import "UserAccountDefine.h"
#import <StoreKit/StoreKit.h>
#import "FeedBackViewController.h"
#import "shareCustomView.h"

#import "YXLoginViewController.h"
#import "HttpRequest.h"
#import "NewsListConfig.h"
#import "UIView+Extention.h"
#import "SDWebImage/SDImageCache.h"
#import "NJWebPageController.h"
#import "MyUrlCache.h"
#import "AppDelegate.h"
#import "SetupVoicePlayerPageController.h"

#define BUNDLE_NAME @"Resource.bundle"
#define IMAGE_SIZE 35.0
#define BASE_TAG 100
#define ARROWNOTICE @"arrowNotice"
#import <UMMobClick/MobClick.h>

@interface SetupPageController ()

@property(nonatomic,retain) NSMutableArray *titleArray;
@end

@implementation SetupPageController

- (void)loadView
{
    tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kSWidth, 300) style:UITableViewStylePlain];
    tableView.dataSource = self;
    tableView.delegate = self;
    self.view = tableView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.titleArray = [[NSMutableArray alloc] init];
    [self.titleArray addObject:NSLocalizedString(@"正文字号",nil)];
    [self.titleArray addObject:NSLocalizedString(@"推送设置",nil)];
    if ([AppConfig sharedAppConfig].isOpenSpeech){
        [self.titleArray addObject:NSLocalizedString(@"语音播报设置",nil)];
    }
    NSArray *arr = @[NSLocalizedString(@"清理缓存",nil),NSLocalizedString(@"意见反馈",nil),NSLocalizedString(@"关于我们",nil)];
    [self.titleArray addObject:arr];
  
    [self rightPageNavTopButtons];
    
    UIButton *confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    confirmButton.frame = CGRectMake(20, 30, self.view.bounds.size.width-40, 35);
    [confirmButton addTarget:self action:@selector(clearUserInfo:) forControlEvents:UIControlEventTouchUpInside];
    confirmButton.layer.cornerRadius = 4;
    confirmButton.layer.masksToBounds = YES;
    [confirmButton setTitle:NSLocalizedString(@"退出登录",nil) forState:UIControlStateNormal];
    confirmButton.backgroundColor = [ColorStyleConfig sharedColorStyleConfig].login_button_color;
    NSString *userId = [Global userId];
    if (userId.length) {
        confirmButton.alpha = 1;
    }else {
        confirmButton.alpha = 0;
    }
    
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 65)];
    UIButton *viewVersion = [UIButton buttonWithType:UIButtonTypeCustom];
    viewVersion.frame = CGRectMake(0, 20, self.view.bounds.size.width, 45);
    viewVersion.backgroundColor = [UIColor clearColor];
    [viewVersion addTarget:self action:@selector(viewVersionInfo) forControlEvents:UIControlEventTouchUpInside];
    [footView addSubview:viewVersion];
    tableView.tableFooterView = footView;
    tableView.scrollEnabled = NO;
    footView.userInteractionEnabled = YES;
 
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    inviteCode = @"";
    _cacheSizeLabel = [[UILabel alloc] initWithFrame:CGRectMake(kSWidth - 65, 0, 60, 50)];
    self.cacheSizeLabel.textColor = [UIColor lightGrayColor];
    self.cacheSizeLabel.textAlignment = NSTextAlignmentCenter;
    self.cacheSizeLabel.font = [UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleCellDateFontSize] ;
}

-(void)viewVersionInfo{
    [UIAlertView showAlert:[NSString stringWithFormat:@"APP当前版本为：v%@ (b%@)", [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"],[NSBundle mainBundle].infoDictionary[@"CFBundleVersion"]]];
}
/*
- (void)evaluate{
    
    //初始化控制器
    SKStoreProductViewController *storeProductViewContorller = [[SKStoreProductViewController alloc] init];
    //设置代理请求为当前控制器本身
    storeProductViewContorller.delegate = self;
    //加载一个新的视图展示
    [storeProductViewContorller loadProductWithParameters:
     //appId唯一的
     @{SKStoreProductParameterITunesItemIdentifier : @"994395381"} completionBlock:^(BOOL result, NSError *error) {
         //block回调
         if(error){
             XYLog(@"error %@ with userInfo %@",error,[error userInfo]);
         }else{
             //模态弹出appstore
             [self presentViewController:storeProductViewContorller animated:YES completion:^{
                 
             }
              ];
         }
     }];
}

//取消按钮监听
- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
*/
-(void)clearUserInfo:(UIButton *)sender
{
    NSString *userId = [Global userId];
    if (userId.length) {
        UIAlertView *logoutAlertView = [[UIAlertView alloc] initWithTitle:@"是否确认退出登录" message:@"" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:@"取消", nil];
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
            [[NSNotificationCenter defaultCenter] postNotificationName:@"USERDIDLOGOUT" object:nil];
//            [self updateLoginFace];
            [self dismissViewControllerAnimated:YES completion:^{
                if ([AppConfig sharedAppConfig].isNeedLoginBeforeEnter && [NSString isNilOrEmpty:[Global userId]]) {
                    YXLoginViewController *vc = [[YXLoginViewController alloc] init];
                    [[appDelegate() currentViewController] presentViewController:[Global controllerToNav:vc] animated:YES completion:NULL];
                }
            }];
        }
    }
    // 非强制更新
    if (alertView.tag == 114) {
        if (buttonIndex == 0){
            //点击转到下载页
            NSURL *url = [NSURL URLWithString:[AppStartInfo sharedAppStartInfo].appDownloadUrl];
            if (url)
            {
                [[UIApplication sharedApplication] openURL:url];
            }
        }
    }
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self titleLableWithTitle:NSLocalizedString(@"设置",nil)];
    [tableView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - table view data source


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.titleArray.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *array = [self.titleArray objectAtIndex:section];
    if([array isKindOfClass:[NSArray class]]){
        
        return array.count;
    }
    else{
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0;
}
- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kSWidth, 20)];
    headView.backgroundColor = UIColorFromString(@"237,237,237");
    return headView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)sender cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"section=%ld, row=%ld",indexPath.section, indexPath.row);
    NSString *cellName = [self.titleArray objectAtIndex:indexPath.section];
    if(![cellName isKindOfClass:[NSString class]]){
        NSArray *array = [self.titleArray objectAtIndex:indexPath.section];
        cellName = [array objectAtIndex:indexPath.row];
    }
    [MobClick event:@"setting_use" attributes:@{@"setting_use_click":NSLocalizedString(cellName, nil)}];
    if ([cellName isEqualToString:NSLocalizedString(@"正文字号",nil)]) {
        UITableViewCell *fontCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FontCell"];
        fontCell.accessoryType = UITableViewCellAccessoryNone;

        UIImageView *backImage = [[UIImageView alloc]initWithFrame:CGRectMake(kSWidth - 30, (50-26)/2.0f, 26, 26)];
        backImage.image = [UIImage imageNamed:@"setRight"];
        [fontCell.contentView addSubview:backImage];

        fontCell.textLabel.font = [UIFont systemFontOfSize: [NewsListConfig sharedListConfig].leftUserNameFontSize-2];
        fontCell.textLabel.text = cellName;
        UILabel *fontLabel = [[UILabel alloc] initWithFrame:CGRectMake(kSWidth - 60, 15, 44, 20)];
        fontLabel.backgroundColor = [UIColor clearColor];
        fontLabel.textColor = [UIColor lightGrayColor];
        if ([[Global fontSize] isEqualToString:@"sm"])
            fontLabel.text = NSLocalizedString(@"小",nil);
        else if ([[Global fontSize] isEqualToString:@"md"])
            fontLabel.text = NSLocalizedString(@"中",nil);
        else if ([[Global fontSize] isEqualToString:@"lg"])
            fontLabel.text = NSLocalizedString(@"大",nil);
        else if ([[Global fontSize] isEqualToString:@"hg"])
            fontLabel.text = NSLocalizedString(@"超大",nil);
        fontLabel.font = [UIFont systemFontOfSize:[NewsListConfig sharedListConfig].leftUserNameFontSize-2];

        [fontCell.contentView addSubview:fontLabel];
        fontCell.selectionStyle = 0;
        UILabel *labelLine = [[UILabel alloc] initWithFrame:CGRectMake(0, 49.5, kSWidth, .5*proportion)];
        labelLine.backgroundColor = UIColorFromString(@"221,221,221");
        [fontCell.contentView addSubview:labelLine];
        UILabel *labelLine1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kSWidth, .5*proportion)];
        labelLine1.backgroundColor = UIColorFromString(@"221,221,221");
        
        [fontCell.contentView addSubview:labelLine1];
 
        return fontCell;
    }
    else if ([cellName isEqualToString:NSLocalizedString(@"个性化字体",nil)]){
        UITableViewCell *fontCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FontNameCell"];
        fontCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        fontCell.textLabel.text = cellName;
        fontCell.imageView.image = [UIImage imageNamed:@"setup_fontName"];
        UILabel *fontLabel = [[UILabel alloc] initWithFrame:CGRectMake(130, 0, 150, 50)];
        fontLabel.backgroundColor = [UIColor clearColor];
        fontLabel.textAlignment = NSTextAlignmentRight;
        fontCell.textLabel.text = cellName;
        [fontCell.contentView addSubview:fontLabel];
        fontCell.selectionStyle = 0;
        return fontCell;
    }
    else if ([cellName isEqualToString:NSLocalizedString(@"推送设置",nil)]) {

        UITableViewCell *downImageCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"downImageCell"];
        [downImageCell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        downImageCell.textLabel.text = cellName;
        downImageCell.textLabel.font = [UIFont systemFontOfSize:[NewsListConfig sharedListConfig].leftUserNameFontSize-2];
 
        UISwitch *switchCtrl = [[UISwitch alloc] initWithFrame:CGRectMake(kSWidth - 66, 10, 100, 30)];
        switchCtrl.onTintColor = [ColorStyleConfig sharedColorStyleConfig].login_button_color;
        switchCtrl.on = [Global customerRemoteNotificationOpen];
        [switchCtrl addTarget:self action:@selector(remoteNotificationControl:) forControlEvents:UIControlEventValueChanged];
        [downImageCell.contentView addSubview:switchCtrl];
        
        UILabel *labelLine = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kSWidth, .5*proportion)];
        labelLine.backgroundColor = UIColorFromString(@"221,221,221");
        [downImageCell.contentView addSubview:labelLine];
        UILabel *labelLine2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 49.5, kSWidth, .5*proportion)];
        labelLine2.backgroundColor = UIColorFromString(@"221,221,221");
        [downImageCell.contentView addSubview:labelLine2];
        downImageCell.selectionStyle = 0;
        
        return downImageCell;
    }
    else if([cellName isEqualToString:NSLocalizedString(@"语音播报设置",nil)]){
        UITableViewCell *voiceCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"voiceCell"];
        [voiceCell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        voiceCell.textLabel.text = cellName;
        voiceCell.textLabel.font = [UIFont systemFontOfSize:[NewsListConfig sharedListConfig].leftUserNameFontSize-2];
        
        UIImageView *backImage = [[UIImageView alloc]initWithFrame:CGRectMake(kSWidth - 30, 12, 26, 26)];
        backImage.image = [UIImage imageNamed:@"setRight"];
        [voiceCell.contentView addSubview:backImage];
        return voiceCell;
    }
    else{
        return [self configSetOptions:cellName];
    }
    return nil;
}
- (UITableViewCell *)configSetOptions:(NSString *)cellName
{
    UITableViewCell *fontCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FontCell"];
    fontCell.accessoryType = UITableViewCellAccessoryNone;
    [fontCell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    fontCell.textLabel.font = [UIFont systemFontOfSize:[NewsListConfig sharedListConfig].leftUserNameFontSize-2];
    fontCell.textLabel.text = cellName;
    if([cellName isEqualToString:NSLocalizedString(@"清理缓存",nil)])
    {
        UILabel *labelLine1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kSWidth, .5*proportion)];
        labelLine1.backgroundColor = UIColorFromString(@"221,221,221");
        [fontCell.contentView addSubview:labelLine1];
        
        fontCell.accessoryType = UITableViewCellAccessoryNone;
        [fontCell.contentView addSubview:self.cacheSizeLabel];
        self.cacheSizeLabel.text = [NSString stringWithFormat:@"%.2f M",[CacheManager folderSizeAtPath:cacheDirPath()]];
    }
    else if([cellName isEqualToString:NSLocalizedString(@"意见反馈",nil)])
    {
        UIImageView *backImage = [[UIImageView alloc]initWithFrame:CGRectMake(kSWidth - 30, 12, 26, 26)];
        backImage.image = [UIImage imageNamed:@"setRight"];
        [fontCell.contentView addSubview:backImage];
    }
    else if([cellName isEqualToString:NSLocalizedString(@"关于我们",nil)])
    {
        UIImageView *backImage = [[UIImageView alloc]initWithFrame:CGRectMake(kSWidth - 30, 12, 26, 26)];
        backImage.image = [UIImage imageNamed:@"setRight"];
        [fontCell.contentView addSubview:backImage];
        
        UILabel *aboutLabel = [[UILabel alloc]initWithFrame:CGRectMake(kSWidth - 88, 15, 80, 20)];
        aboutLabel.textColor = [UIColor lightGrayColor];
        aboutLabel.font = [UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleCellDateFontSize];
        aboutLabel.textAlignment = NSTextAlignmentCenter;
        aboutLabel.text = [NSString stringWithFormat:@"v%@", [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString*)kCFBundleVersionKey]];
        //[fontCell.contentView addSubview:aboutLabel];
        
        UILabel *labelLine1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 49.5, kSWidth, .5*proportion)];
        labelLine1.backgroundColor = UIColorFromString(@"221,221,221");
        [fontCell.contentView addSubview:labelLine1];
    }

    UILabel *labelLine = [[UILabel alloc] initWithFrame:CGRectMake(10, 49.5, kSWidth, .5)];
    labelLine.backgroundColor = UIColorFromString(@"221,221,221");
    fontCell.textLabel.text = cellName;
    [fontCell.contentView addSubview:labelLine];
    return fontCell;
}

-(void)remoteNotificationControl:(UISwitch *)sender
{
    if([Global customerRemoteNotificationOpen]){
        [[UIApplication sharedApplication] unregisterForRemoteNotifications];
       // [GeTuiSdk setPushModeForOff:YES];
        
    }
    else{
        [Global showTip:NSLocalizedString(@"请在设置－》通知下找到本应用，开启允许通知。",nil)];
       // [GeTuiSdk setPushModeForOff:NO];
    }
}

/* 客户端推送开关 */
-(void)remoteNotificationControl2:(UISwitch *)sender
{
    
    /*
     * 开推送两个条件：客户端打开推送 + 个推服务器开启消息推送
     * 老代码这里只根据：客户端设置是否打开推送来判断推送有没打开
     */
    //不能只靠[Global customerRemoteNotificationOpen]判断是否开启推送，系统bug，不管代码有无注销推送，都为YES
    if([Global customerRemoteNotificationOpen]){
        if ([Global isOpenCustomerRemoteNotification]) {
            [[UIApplication sharedApplication] unregisterForRemoteNotifications];
           // [GeTuiSdk setPushModeForOff:YES];
        }else {
            // 定义用户通知类型(Remote.远程 - Badge.标记 Alert.提示 Sound.声音)
            UIUserNotificationType types = UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound;
            // 定义用户通知设置
            UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
            // 注册用户通知 - 根据用户通知设置
            [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
            [Global setCustomerRemoteNotificationOpen:YES];
           // [GeTuiSdk setPushModeForOff:NO];
        }
    }
    else{
        [Global showTip:NSLocalizedString(@"请在设置－》通知下找到本应用，开启允许通知。",nil)];
       // [GeTuiSdk setPushModeForOff:YES];
    }
}

/* 客户端静音推送 */
- (void)soundNotificationControl:(UISwitch *)sender
{
    // 首先保证是否开启推送
    if([Global customerRemoteNotificationOpen] && [Global isOpenCustomerRemoteNotification]){
        UIUserNotificationType types = sender.on ? UIUserNotificationTypeAlert | UIUserNotificationTypeBadge: UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound ;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
    else{
        [Global showTip:NSLocalizedString(@"请在设置－》通知下找到本应用，开启允许通知。",nil)];
    }
}

#pragma mark - table view delegate
- (void)tableView:(UITableView *)sender didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [sender cellForRowAtIndexPath:indexPath];
    [self didSelectOptions:cell.textLabel.text];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)didSelectOptions:(NSString *)cellName
{
    if([cellName isEqualToString:NSLocalizedString(@"正文字号",nil)]){
        FontSettingsController *controller = [[FontSettingsController alloc] init];
        [self.navigationController pushViewController:controller animated:YES];
    }
    else if([cellName isEqualToString:NSLocalizedString(@"语音播报设置",nil)])
    {
        SetupVoicePlayerPageController *voicePlayerVC = [[SetupVoicePlayerPageController alloc] init];
        [self.navigationController pushViewController:voicePlayerVC animated:YES];
    }
    else if([cellName isEqualToString:NSLocalizedString(@"清理缓存",nil)])
    {
        XYLog(@"清理缓存");
        [self clearCache];
    }
    else if([cellName isEqualToString:NSLocalizedString(@"意见反馈",nil)])
    {
        XYLog(@"意见反馈");
        FeedBackViewController *feedBack = [[FeedBackViewController alloc]init];
        [self.navigationController pushViewController:feedBack animated:YES];
        
    }
    else if([cellName isEqualToString:NSLocalizedString(@"关于我们",nil)])
    {
        NJWebPageController *controller = [[NJWebPageController alloc] init];
        Column *column = [[Column alloc] init];
        column.linkUrl = [NSString stringWithFormat:@"%@/aboutus.html",[AppStartInfo sharedAppStartInfo].configUrl];
        column.columnName = NSLocalizedString(@"关于我们",nil);
        controller.parentColumn = column;
        controller.hiddenClose = YES;
        controller.isFromModal = YES;
        [self presentViewController:[Global controllerToNav:controller] animated:YES completion:nil];
        
    }
    
}

#pragma mark - UIAlertView Delegate

// update版本更新
-(BOOL)appUpdateHasNewVersion
{
    BOOL hasAppNewVersion = NO;
    NSString *lastestVersion = [AppStartInfo sharedAppStartInfo].appVersion;
    NSString *nowVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    
    NSString *localVersion = [[NSUserDefaults standardUserDefaults] stringForKey:appUpdateVersion];
    if (localVersion.length)
    {
        hasAppNewVersion = [localVersion compare:lastestVersion options:NSNumericSearch] == NSOrderedDescending;
    }else{
        hasAppNewVersion = [lastestVersion compare:nowVersion options:NSNumericSearch] == NSOrderedDescending;
    }
    
    return hasAppNewVersion;
}

- (void)doClearCache
{
    [Global showTipAlways:NSLocalizedString(@"正在清理...",nil)];
    [[CacheManager sharedCacheManager] clearCache];
    [[SDImageCache sharedImageCache] clearDisk];
    //清除webview缓存，否则设置里清除缓存后可重复匿名投票
    //[MyUrlCache removeCaches];
    [NSTimer scheduledTimerWithTimeInterval:1.50f target:self selector:@selector(clearCacheDelay) userInfo:nil repeats:NO];
}

- (void)clearCacheDelay
{
    // 其实没必要，因为NSTimer主线程创建，就运行在主线程，否则就失去了意义
    dispatch_async(dispatch_get_main_queue(), ^{
        //通知主线程刷新
        [Global showTip:NSLocalizedString(@"清理完成",nil)];
        self.cacheSizeLabel.text = @"0.00 M";
    });
}

- (void)clearCache
{
    [self doClearCache];
}

-(void)updateSizeLabel
{
    self.cacheSizeLabel.text = [NSString stringWithFormat:@"%.2f M",[CacheManager folderSizeAtPath:cacheDirPath()]];
}

-(void)downImageAt3G:(UISwitch *)sender
{
    if (sender.on) {
        [Global setWANswitch:YES];
    }else{
        [Global setWANswitch:NO];
    }
}

-(void)showLoginPage
{
    YXLoginViewController *controller = [[YXLoginViewController alloc]init];
    [controller rightPageNavTopButtons];
    [self presentViewController:[Global controllerToNav:controller] animated:YES completion:^{
    }]; 
}
@end
