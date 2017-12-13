//
//  AppDelegate.m
//  FounderReader-2.5
//
//  Created by chenfei on 4/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
// $LastChangedBy: guo.lh $
// $LastChangedRevision: 9202 $
// $LastChangedDate: 2013-03-01 17:28:27 +0800 (Fri, 01 Mar 2013) $
// $HeadURL: https://dmkb.hold.founder.com/svn/dam/FounderReader/trunk/FounderReader-2.5/AppDelegate.m $
//
#import "AppDelegate.h"
#import "AppConfig.h"
#import "Column.h"
#import "DataLib/DataLib.h"
#import "ZipArchive.h"
#import "ColumnRequest.h"
#import "Article.h"
#import "NewsCellUtil.h"
#import "UIDevice-Reachability.h"
#import "RNCachingURLProtocol.h"
#import "MWApi.h"

#import "YZSDK.h"
#import <UMMobClick/MobClick.h>
#import "UIAlertView+Helper.h"
#import "NSString+Helper.h"
#import "UIHelperView.h"
#import "CacheManager.h"
#import <MapKit/MapKit.h>
#import "AppStartInfo.h"
#import "ColumnBarConfig.h"
#import "SDImageCache.h"
#import <AudioToolbox/AudioToolbox.h>
#import "ImageDetailPageController.h"
#import "TemplateNewDetailViewController.h"
#import "SpecialNewsPageController.h"
#import "SeeRootViewController.h"
#import "CreditMenuViewController.h"
#import "TemplateDetailPageController.h"
#import "RootWebPageController.h"
#import "PoliticalPageController.h"
#import "AESCrypt.h"
#import "GrayScale.h"
#import "LocalNotificationManager.h"
#import <AVFoundation/AVAudioSession.h>
#import "MyUrlCache.h"
#import "FileLoader.h"
#import "UIPrivacyView.h"
#import "ColorStyleConfig.h"
#import "ColumnBarPageController.h"
#import "NoNetWorkPageController.h"
#import "NewsPageController.h"
#import "UIPlayerView.h"
#import "FounderIntegralRequest.h"
#import "YXLoginViewController.h"
#import "FDServiceSortController.h"
#import <UMMobClick/MobClick.h>
#import <UMSocialCore/UMSocialCore.h>
#import "UMessage.h"
#import <UserNotifications/UserNotifications.h>
#import "GovAffairController.h"

@interface AppDelegate()<CLLocationManagerDelegate,UNUserNotificationCenterDelegate>
{
    int adResidenceTime;
    NSDictionary *_localNotificatinUserInfo;
}
@property (nonatomic, unsafe_unretained) UIBackgroundTaskIdentifier bgTask;
@property (retain, nonatomic) NSDictionary *pushNotificationKey;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (assign, nonatomic) BOOL isNotFirstTimeShowNoNetworkAlert;
@property (retain, nonatomic) NSDictionary *personDic;
-(void)loadSSSplashView;
-(void)getRootChannels:(FinishDataBlock)finishedBlock;
-(void)loadTabBarIcon:(NSString *)imgUrl ChildVc:(ChannelPageController *)childVc index:(int)index finishedBlock:(FinishDataBlock2)finishedBlock;
@end


@implementation AppDelegate

@synthesize window = _window;

@synthesize channels;

@synthesize tabBarController;
@synthesize pushNotificationKey;
@synthesize isAllOrientation;

bool isAppNormalStart()
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [[userDefaults objectForKey:@"normal_start"] boolValue];
}
/**
 *  创建根控制器
 */
- (void)createTabRootController{

    NSDictionary *columnClassDic = [[NSDictionary alloc] initWithContentsOfFile:pathForMainBundleResource(@"column_className.plist")];
    NSArray *array = [NSArray arrayWithArray:self.channels];
    for (int i = 0; i < array.count; i++) {
        Column *channel = array[i];
        if (channel.showcolumn||(![channel.columnName isEqualToString:@"检察日报"]&&![channel.columnName isEqualToString:@"检务大厅"]&&![channel.columnName isEqualToString:@"自媒体"])) {
            [self.channels removeObject:channel];
        }
    }
    
    /* 配置个人中心 */
    if ([AppStartInfo sharedAppStartInfo].ucTabisShow) {
        Column * channel = [[Column alloc]init];
        NSInteger chanelCount = MIN(self.channels.count, 4);
        NSInteger ucTabPosition = [AppStartInfo sharedAppStartInfo].ucTabPosition;
        //ucTabPosition表示个人中心放在第几个后面，规定不能放在第一个和大于总频道数时，默认放在最后一个
        if (ucTabPosition <= 0 || ucTabPosition >= chanelCount) {
            if (self.channels.count >= 4){
                if (ucTabPosition <=4) {
                    [self.channels insertObject:channel atIndex:[AppStartInfo sharedAppStartInfo].ucTabPosition];
                }else if(ucTabPosition>4){
                    [self.channels insertObject:channel atIndex:4];
                }else{
                    [self.channels addObject:channel];
                }
            }else{
                [self.channels addObject:channel];//当insert的index大于数组count时，crash，需要addObject
                 }
            }else {
            [self.channels insertObject:channel atIndex:[AppStartInfo sharedAppStartInfo].ucTabPosition];
        }
        channel.columnName = [AppStartInfo sharedAppStartInfo].ucTabString;
        channel.iconUrl = [AppStartInfo sharedAppStartInfo].ucTabIcon;
        channel.columnStyle = @"个人中心";
    }
    
    if (self.channels.count == 1) {
        [[NSUserDefaults standardUserDefaults] setInteger:2 forKey:@"onlyOne"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"onlyOne"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    for (int i = 0; i < MIN(self.channels.count, 5); i++) {
        Column *channel = nil;
        channel = [self.channels objectAtIndex:i];
        
        NSString *className = nil;
        if (columnClassDic != nil) {
            if([channel.columnStyle isEqualToString:@""]){
                channel.columnStyle = @"新闻";
            }
            className = [columnClassDic objectForKey:[NSString stringWithFormat:@"%@",channel.columnStyle]];
        }
        if(className == nil){
            //如columnStyle为"新闻icon"时，配置文件没有"新闻icon"的控制器，就默认取"新闻"的控制器
            className = @"NewsPageController";
        }
        if([[AppConfig sharedAppConfig].sid isEqualToString:@"xy"] && [channel.columnName isEqualToString:@"商城"]){
            className = @"CreditMenuViewController";
        }
        if ([[channel.keyword allKeys] containsObject:@"isYouZan"] && [channel.keyword[@"isYouZan"] boolValue]) {
            className = @"TinyMallViewController";
        }
        
        __block ChannelPageController *pageController = [[NSClassFromString(className) alloc] init];
        pageController.parentColumn = channel;
        if ([pageController isKindOfClass:[NewsPageController class]] && i==0) {
            ColumnBarPageController *firstNewsVC = (ColumnBarPageController *)pageController;
            firstNewsVC.isFirstNewsVC = YES;
        }
        
        if ([pageController isKindOfClass:[FDTopicPlusDetailViewController class]]) {
            NSNumber *topicID = channel.keyword[@"topicDetailID"] ? channel.keyword[@"topicDetailID"] : 0;
            pageController = [[FDTopicPlusDetailViewController alloc] initWithTopicID:topicID viewControllerType:FDViewControllerForTabbarVC];
            pageController.parentColumn = channel;
        }
        
        if(i == 0){
            pageController.isMain = YES;
        }

        if(i == 1){
            GovAffairController *govController = [[GovAffairController alloc]init];
            [self addChildVc:govController title:@"政务" image:channel.iconUrl selectedImage:channel.iconUrl index:i];
        }else{
        
        [self addChildVc:pageController title:channel.columnName image:channel.iconUrl selectedImage:channel.iconUrl index:i];
        }
    }
    
}

/**
 *  添加一个子控制器
 *
 *  @param childVc       子控制器
 *  @param title         标题
 *  @param image         图片
 *  @param selectedImage 选中的图片
 */
#pragma - mark 添加子控制器
- (void)addChildVc:(ChannelPageController *)childVc title:(NSString *)title image:(NSString *)image selectedImage:(NSString *)selectedImage index:(int)index
{
    // 包装一个导航控制器
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:childVc];
    
    // 设置navigationbar文字的样式
    NSMutableDictionary *textTitleAttrs = [NSMutableDictionary dictionary];
    textTitleAttrs[NSForegroundColorAttributeName] = [UIColor whiteColor];
    [childVc.navigationController.navigationBar setTitleTextAttributes: textTitleAttrs];
    [childVc.navigationController.navigationBar setBackgroundImage:[Global navigationImage] forBarMetrics:UIBarMetricsDefault];
    
    // 设置子控制器的文字
    childVc.title = title; // 同时设置tabbar和navigationBar的文字
    self.tabBarController.tabBar.backgroundColor = [UIColor whiteColor];
    self.tabBarController.tabBar.barTintColor = [UIColor whiteColor];
    // 设置tabbar文字的样式
    NSMutableDictionary *textAttrs = [NSMutableDictionary dictionary];
    textAttrs[NSForegroundColorAttributeName] = UIColorFromString([ColorStyleConfig sharedColorStyleConfig].tabbar_titlecolorstring_diselect);
    textAttrs[NSFontAttributeName] = [UIFont systemFontOfSize:13];
    [childVc.tabBarItem setTitleTextAttributes:textAttrs forState:UIControlStateNormal];
    
    NSMutableDictionary *selectTextAttrs = [NSMutableDictionary dictionary];
    selectTextAttrs[NSForegroundColorAttributeName] = [ColumnBarConfig sharedColumnBarConfig].column_all_color;
    selectTextAttrs[NSFontAttributeName] = [UIFont systemFontOfSize:13];
    [childVc.tabBarItem setTitleTextAttributes:selectTextAttrs forState:UIControlStateSelected];
    [childVc.tabBarItem setImageInsets:UIEdgeInsetsMake(-4, 0, 4, 0)];
    [childVc.tabBarItem setTitlePositionAdjustment:UIOffsetMake(0, 0)];
   
    // 设置子控制器的图片
    if ([AppStartInfo sharedAppStartInfo].ucTabisShow && [childVc.parentColumn.columnStyle isEqualToString:@"个人中心"] && [NSString isNilOrEmpty:[AppStartInfo sharedAppStartInfo].ucTabIcon]) {
        childVc.tabBarItem.image = [[UIImage imageNamed:[AppConfig sharedAppConfig].tabBarPersonalCenterIcon_normal] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        childVc.tabBarItem.selectedImage = [[UIImage imageNamed:[AppConfig sharedAppConfig].tabBarPersonalCenterIcon_selected] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }else{
        [self loadTabBarIcon:image ChildVc:childVc index:index finishedBlock:^(UIImage *imageNormal, UIImage *imagePress){
            if(imageNormal){
                childVc.tabBarItem.image = [imageNormal imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
                childVc.tabBarItem.selectedImage = [imagePress imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
                

            }else{
                if ([AppStartInfo sharedAppStartInfo].ucTabisShow && [childVc.parentColumn.columnStyle isEqualToString:@"个人中心"]) {
                    childVc.tabBarItem.image = [[UIImage imageNamed:[AppConfig sharedAppConfig].tabBarPersonalCenterIcon_normal] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
                    childVc.tabBarItem.selectedImage = [[UIImage imageNamed:[AppConfig sharedAppConfig].tabBarPersonalCenterIcon_selected] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
                }else {
                    UIImage *image = [UIImage imageNamed:@"channel_default"];
                    childVc.tabBarItem.image = image;
                    childVc.tabBarItem.selectedImage = [image convertImageColorScaleWithRGBColorStr:[ColorStyleConfig sharedColorStyleConfig].tabbar_imagecolorstring_diselect];
                    
                }
            }
        }];
    }
    // 添加为子控制器
    [self.tabBarController addChildViewController:nav];
    // 当只有一个菜单时底部标签工具栏不显示
    NSInteger onlyOne = [[[NSUserDefaults standardUserDefaults] objectForKey:@"onlyOne"] integerValue];
    if (onlyOne == 2)
    {
        for (UIView *v in [self.tabBarController.view subviews]) {
            if ([v isKindOfClass:[UITabBar class]]) {
                
                [UIView animateWithDuration:0.0f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^(){
                    
                    CGRect frame = v.frame;
                    frame.origin.y += 49.0f;
                    v.frame = frame;
                    
                } completion:nil];
            }
        }
    }
}
- (UIImage *)image:(UIImage*)image byScalingToSize:(CGSize)targetSize {
    UIImage *sourceImage = image;
    UIImage *newImage = nil;
    
    UIGraphicsBeginImageContext(targetSize);
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = CGPointZero;
    thumbnailRect.size.width  = targetSize.width;
    thumbnailRect.size.height = targetSize.height;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage ;
}

-(void)loadTabBarIcon:(NSString *)imgUrl ChildVc:(ChannelPageController *)childVc index:(int)index finishedBlock:(FinishDataBlock2)finishedBlock{
    
    NSString *filePath = docDirPathFromURL(imgUrl);
    NSString *filePath2xNormal = [filePath stringByAppendingString:@"_normal@2x.png"];
    NSString *filePath2xPress = [filePath stringByAppendingString:@"_press@2x.png"];
    BOOL isFirstLoad = !isFileExists(filePath2xNormal);//是否第一次加载
    if ([AppStartInfo sharedAppStartInfo].ucTabisShow && [childVc.parentColumn.columnStyle isEqualToString:@"个人中心"]) {
        //“取链接后缀即图片名判断沙盒是否已经存在”对于替换的个人中心图标来说，两个图标文件名可能是一样的而链接的站点代号不一样。
        NSString *userCenterIcon = [[NSUserDefaults standardUserDefaults] objectForKey:@"userCenterIcon"];
        if ([NSString isNilOrEmpty:userCenterIcon] || ![userCenterIcon isEqualToString:imgUrl]) {
            isFirstLoad = YES;
            [[NSUserDefaults standardUserDefaults] setObject:imgUrl forKey:@"userCenterIcon"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }else {
            isFirstLoad = NO;
        }
    }
    if(!isFirstLoad){
        UIImage *imgNormal = [[UIImage alloc] initWithContentsOfFile:filePath2xNormal];
        UIImage *imgPress = [[UIImage alloc] initWithContentsOfFile:filePath2xPress];
        finishedBlock(imgNormal, imgPress);
        return;
    } else {
        UIImage *imgNormal;
        UIImage *imgHighlight;
        NSString *imgNormalString = [[AppConfig sharedAppConfig] valueForKey:[NSString stringWithFormat:@"tabbarIconNormal%zd", index+1]];
        if (!imgNormalString.length) {
            imgNormalString = @"channel_default";
        }
        imgNormal = [UIImage imageNamed:imgNormalString];
        
        NSString *imgHighlightString = [[AppConfig sharedAppConfig] valueForKey:[NSString stringWithFormat:@"tabbarIconHighlight%zd", index+1]];
        if (!imgHighlightString.length) {
            imgHighlightString = @"channel_default";
        }
        imgHighlight = [UIImage imageNamed:imgHighlightString];
        finishedBlock(imgNormal, imgHighlight);
    }
    
    HttpRequest *request = [[HttpRequest alloc] initWithURL:[NSURL URLWithString:imgUrl]];
    [request setCompletionBlock:^(NSData *data){
        
        UIImage *image = [UIImage imageWithData:data];
        
        if(image){
            image = [self image:image byScalingToSize:CGSizeMake(44, 42)];
            NSData *pressData = UIImagePNGRepresentation(image);
            [pressData writeToFile:filePath2xPress options:NSDataWritingAtomic error:nil];
            UIImage *imageNormal = [image convertImageColorScaleWithRGBColorStr:[ColorStyleConfig sharedColorStyleConfig].tabbar_imagecolorstring_diselect];
            NSData *normalData = UIImagePNGRepresentation(imageNormal);
            [normalData writeToFile:filePath2xNormal options:NSDataWritingAtomic error:nil];
            UIImage *imgNormal = [[UIImage alloc] initWithContentsOfFile:filePath2xNormal];
            UIImage *imgPress = [[UIImage alloc] initWithContentsOfFile:filePath2xPress];
            
            finishedBlock(imgNormal, imgPress);
        }
        else{
//            UIImage *image = [UIImage imageNamed:@"channel_default"];
            finishedBlock(nil, nil);
        }
     }];
    
    [request setFailedBlock:^(NSError *error){

        //[Global showTipNoNetWork];
//        UIImage *image = [UIImage imageNamed:@"channel_default"];
        finishedBlock(nil, nil);
    }];
    
    [request startAsynchronous];
}
#pragma mark - 加载配置信息
//加载服务器配置信息
-(void)getConfigLoad:(NSString *)startConfigUrl finishedBlock:(FinishDataBlock)finishedBlock{
    
    NSString *filePath = docDirPathFromURL(startConfigUrl);
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    BOOL isFirstLoad = data == nil;//是否第一次加载
    if(!isFirstLoad){
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers  error:nil];
        AppStartInfo *svrIf = [AppStartInfo sharedAppStartInfo];
        [svrIf configWithDictionary:dict];
        [self settingWithAppStartInfo:svrIf];
        finishedBlock([NSNumber numberWithBool:YES]);
    }
    
    HttpRequest *request = [[HttpRequest alloc] initWithURL:[NSURL URLWithString:startConfigUrl]];
    [request setCompletionBlock:^(NSData *data)
     {
         NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers  error:nil];
         if(dict){
        
             AppStartInfo *svrIf = [AppStartInfo sharedAppStartInfo];
             if (isFirstLoad) {
                 [svrIf configWithDictionary:dict];
                 [self settingWithAppStartInfo:svrIf];
             }
             [[NSFileManager defaultManager] createFileAtPath:filePath contents:data attributes:nil];
         }
         
         if(isFirstLoad){
             finishedBlock([NSNumber numberWithBool:YES]);
         }
     }];
    
    [request setFailedBlock:^(NSError *error)
     {
         if(isFirstLoad){
             //iOS第一次启动时需要弹出授权使用蜂窝网络，定时重复请求，直到加载成功
             //[NSThread sleepForTimeInterval:2];
             //[self loadFasterStart];
             if (!_isNotFirstTimeShowNoNetworkAlert) {
                 _isNotFirstTimeShowNoNetworkAlert = YES;
                 UIAlertController *alert = [UIAlertController alertControllerWithTitle:[AppConfig sharedAppConfig].firstTimeNoNetworkAlertTitle message:[AppConfig sharedAppConfig].firstTimeNoNetworkAlertContent preferredStyle:UIAlertControllerStyleAlert];
                 [alert addAction:
                  [UIAlertAction actionWithTitle:NSLocalizedString(@"确认", nil) style:UIAlertActionStyleCancel handler:NULL]];
                 [[self currentViewController] presentViewController:alert animated:YES completion:NULL];
             }
         }
         else{
             [Global showTipNoNetWork];
         }
     }];
    
    [request startAsynchronous];
}

#pragma - mark 后期修改,个人中心配置
- (void)settingWithAppStartInfo:(AppStartInfo *)svrIf{
    //测试后期修改
    svrIf.ucTabisShow = [self.personDic objectForKey:@"ucTabisShow"];
    svrIf.ucTabPosition = [[self.personDic objectForKey:@"ucTabPosition"] integerValue];
    svrIf.ucTabString = [self.personDic objectForKey:@"ucTabString"];
}

#pragma mark - **加载频道信息
-(void)getRootChannels:(FinishDataBlock)finishedBlock{
    
    NSString *getColumnsUrl = [NSString stringWithFormat:@"%@/api/getColumns?sid=%@&cid=0", [AppConfig sharedAppConfig].serverIf, [AppConfig sharedAppConfig].sid];
    NSString *filePath = docDirPathFromURL(getColumnsUrl);
    BOOL isFirstLoad = !isFileExists(filePath);//是否第一次加载
    
     //本地获取
//    NSString *filePath2 = [[NSBundle mainBundle] pathForResource:@"getColumns" ofType:@"json"];
//    NSData *data2 = [NSData dataWithContentsOfFile:filePath2];
//    NSDictionary *dict2 = [NSJSONSerialization JSONObjectWithData:data2 options:NSJSONReadingMutableContainers  error:nil];
    
    if(!isFirstLoad){
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers  error:nil];
        NSArray *__channels = [Column columnsFromArray:[dict objectForKey:@"columns"]];
        self.channels = [NSMutableArray arrayWithArray:__channels];
        finishedBlock([NSNumber numberWithBool:YES]);
    }
    
    HttpRequest *request = [[HttpRequest alloc] initWithURL:[NSURL URLWithString:getColumnsUrl]];
    [request setCompletionBlock:^(NSData *data)
     {
         NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers  error:nil];
         NSArray *__channels = [Column columnsFromArray:[dict objectForKey:@"columns"]];
         self.channels = [NSMutableArray arrayWithArray:__channels];
         if(self.channels.count > 0){
             [[NSFileManager defaultManager] createFileAtPath:filePath contents:data attributes:nil];
         }
         
         if(isFirstLoad){
             finishedBlock([NSNumber numberWithBool:YES]);
         }
     }];
    
    [request setFailedBlock:^(NSError *error)
     {
         [Global showTipNoNetWork];
     }];
    
    [request startAsynchronous];
}

/**
 *  快速启动
 */
- (void)loadFasterStart{

    AppConfig *appConfig = [AppConfig sharedAppConfig];
    [self getConfigLoad:appConfig.startConfigUrl finishedBlock:^(NSNumber *success){
        NSLog(@"cofigurl:%@",[AppStartInfo sharedAppStartInfo].configUrl);
        //测试,注释
        //if([AppStartInfo sharedAppStartInfo].configUrl.length > 0){
            [self getRootChannels:^(NSNumber *success){
                if(self.channels.count > 0){
                    [self createTabRootController];
                    [self loadSSSplashView];
                    //延迟加载一些初始化工作
                    [self performSelector:@selector(lazyLoadTask) withObject:nil afterDelay:3.0f];
                }
            }];
       // }
    }];
}

-(void)setupAnnounceParam
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[AppConfig sharedAppConfig].initialAnnouncer forKey:@"VoiceAnnouncer"];//播音员
    [userDefaults setInteger:50 forKey:@"VoiceSpeed"];//语速
    [userDefaults setInteger:50 forKey:@"VoiceTone"];//语调
    [userDefaults setInteger:50 forKey:@"VoiceVolume"];//音量
    [userDefaults synchronize];
}
-(void)setUpMobClick{
    
    UMConfigInstance.appKey = [AppConfig sharedAppConfig].kUMengAppKey;
    UMConfigInstance.ePolicy = SEND_INTERVAL;
    [MobClick startWithConfigure:UMConfigInstance];
}

#pragma mark - 初始化友盟分享
- (void)configUSharePlatforms
{
//    [[UMSocialManager defaultManager] setUmSocialAppkey:[AppConfig sharedAppConfig].kUMengAppKey];
//    [[UMSocialManager defaultManager] openLog:YES];
    
    [[UMSocialManager defaultManager] setUmSocialAppkey:@"5861e5daf5ade41326001eab"];
    [[UMSocialManager defaultManager] openLog:YES];
    
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_WechatSession appKey:@"wxdc1e388c3822c80b" appSecret:@"3baf1193c85774b3fd9d18447d76cab0" redirectURL:nil];
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_QQ appKey:@"1106481807"/*设置QQ平台的appID*/  appSecret:@"Rg775dKcXzD7cyhm" redirectURL:nil];
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_Sina appKey:@"3921700954"  appSecret:@"04b48b094faeb16683c32669824ebdad" redirectURL:@"https://sns.whalecloud.com/sina2/callback"];
    
}
/**
 *  解压模板文件
 *
 *  @param filePath 路径url
 *
 *  @return 是否成功解压
 */
- (BOOL)unzipTemplateFile:(NSString *)filePath
{
    BOOL ok = NO;
    
    ZipArchive *zipArchive = [[ZipArchive alloc] init];
    BOOL open_ok = [zipArchive UnzipOpenFile:filePath];
    if (open_ok) {
        ok = [zipArchive UnzipFileTo:cacheDirPath() overWrite:YES];
        [zipArchive UnzipCloseFile];
    }
    return ok;
}


/**
 *  加载HTML模板
 */
- (void)loadHTMLTemplate:(FinishDataBlock)finishedBlock
{
    FileRequest *request = [[FileRequest alloc] initWithFileURL:[AppStartInfo sharedAppStartInfo].contentTemplate];
    [request setCompletionBlock:^(NSData *data)
     {
         //内置模版引用的第三方固定js文件，服务器只放动态修改的文件
         NSString *filePath = [[NSBundle mainBundle] pathForResource:@"temp_dependent" ofType:@"zip"];
         [self unzipTemplateFile:filePath];
         //解压服务端的模版压缩包
         NSString *path = cachePathFromURL([AppStartInfo sharedAppStartInfo].contentTemplate);
         if (![data writeToFile:path atomically:YES]){
             [Global showTip:@"解压模版到本地失败，请重试！"];
             finishedBlock([NSNumber numberWithBool:NO]);
         }
         else{
             [self unzipTemplateFile:path];
             finishedBlock([NSNumber numberWithBool:YES]);
         }
     }];
    
    [request setFailedBlock:^(NSError *error)
     {
         [Global showTipNoNetWork];
         finishedBlock([NSNumber numberWithBool:NO]);
     }];
    [request startAsynchronous];
}

- (void)unzipWWW{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *pathStr = [cacheDirPath() stringByAppendingPathComponent:@"www"];
    if(![fileManager fileExistsAtPath:pathStr]){
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"www" ofType:@"zip"];
    [self unzipTemplateFile:filePath];
    }
}


/**
 *  添加第三方登陆及短信验证码
 */
- (void)initShareSDK
{
    
}

//可以延迟加载的任务，统一放在这里，可以加快启动速度
- (void)lazyLoadTask{
    
    [self initShareSDK];
    
    // 下载模版
   // [self loadHTMLTemplate:^(NSNumber *success){}];
    
    NSLog(@"haha:%@",cacheDirPath());
    
    [self unzipWWW];
    
    //友盟统计初始化设置
    UMConfigInstance.appKey = [AppConfig sharedAppConfig].kUMengAppKey;
    [MobClick startWithConfigure:UMConfigInstance];
    
    // 初始化有赞商城
    [self initYouZanSDK];
    //设置webview本地缓存容量 容易导致打开文章闪退，具体原因还未清楚
    //MyUrlCache* testCache = [[MyUrlCache alloc]initWithMemoryCapacity:1024*1024*12 diskCapacity:1024*1024*120 diskPath:@"webCache.db"];
    //[testCache initilize];
    //[NSURLCache setSharedURLCache:testCache];
    
    //设置允许WebView播放声音
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *setCategoryError = nil;
    BOOL ok = [audioSession setCategory:AVAudioSessionCategoryPlayback error:&setCategoryError];
    if (!ok) {
        XYLog(@"%s setCategoryError=%@", __PRETTY_FUNCTION__, setCategoryError);
    }
   
}

- (void)initYouZanSDK
{
    //打印日志
    [YZSDK setOpenDebugLog:NO];
    //设置AppID和AppSecret 如果想自定义原生商城UI的话需要初始化appid和appsecret，h5只是加载提供的商城链接即可
//    [YZSDK setOpenInterfaceAppID:[AppConfig sharedAppConfig].kYouZanAppId appSecret:[AppConfig sharedAppConfig].kYouZanAppSecret];
    //设置UA
    [YZSDK userAgentInit:[AppConfig sharedAppConfig].kYouZanUserAgeny version:@""];
}

#pragma mark - application delegate
/**
 *  显示启动页
 *
 *  @param splashController
 */
- (void)showStartPageDetailPage:(SSSplashViewController *)splashController
{
    self.window.rootViewController = self.tabBarController;
    
    if (!splashController.pid){
        return;
    }
    
    Article *article = [[Article alloc] init];
    article.fileId = splashController.pid;
    article.contentUrl = splashController.webUrl;
    article.articleType = 0;
    article.type = ArticleType_ADV_List;
    article.title = splashController.titleText;
    article.publishTime = splashController.startTime;
    Column *column = [[Column alloc] init];
    //TemplateNewDetailViewController *controller = [[TemplateNewDetailViewController alloc] init];
    //controller.adArticle = article;
    //controller.articles = [NSArray arrayWithObject:article];
    //controller.isNavGoback = YES;
    //[self.window.rootViewController presentViewController:controller animated:NO completion:nil];
    [NewsCellUtil clickNewsCell:article column:column in:self.window.rootViewController];
}

- (void)splashDidfinished:(SSSplashViewController *)splashController
{
    self.window.rootViewController = self.tabBarController;
        [self addPrivacyView];
    //启动首页加载完毕后再打开推送稿件
    [self handleRemoteNotification:self.pushNotificationKey];
}

-(void)loadSSSplashView
{
    SSSplashViewController *splashController = [[SSSplashViewController alloc] init];
    splashController.startPages = [AppStartInfo sharedAppStartInfo].startPages;
    splashController.delegate = self;
    self.window.rootViewController = splashController;
}

#pragma mark --- App初始化
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.alpha = 1.0;
    [self.window makeKeyAndVisible];
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    // 手动弹出定位权限框
    _locationManager = [[CLLocationManager alloc] init];
    [_locationManager requestWhenInUseAuthorization];
    
    //友盟推送初始化
    [self UMMessageInitWith:launchOptions];
//    [UMessage startWithAppkey:@"5a0195ac8f4a9d5294000049" launchOptions:launchOptions];
//    [UMessage registerForRemoteNotifications];
//    [UMessage setLogEnabled:YES];
    
    copyMainBundleResourceToCacheDir(kDBName);
    self.window.backgroundColor = [UIColor whiteColor];
    self.tabBarController = [[NATabBarController alloc] init];
    self.tabBarController.delegate = self;
    //初始化语音播报参数
    [self setupAnnounceParam];
    
    //初始化友盟统计
    [self setUpMobClick];
    //友盟分享
    [self configUSharePlatforms];
    
    BOOL isNotFirstTimeStartApp = [[NSUserDefaults standardUserDefaults] boolForKey:@"isNotFirstTimeStartApp"];
    if (!isNotFirstTimeStartApp) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isNotFirstTimeStartApp"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        //魔窗(在rootViewController创建后配置)
        [MWApi registerApp:[AppConfig sharedAppConfig].kMWAppKey];
        //普通稿件
        [MWApi registerMLinkHandlerWithKey:[AppConfig sharedAppConfig].kMWMLinkKey
                                   handler:^(NSURL * _Nonnull url, NSDictionary * _Nullable params) {
                                       //#warning "for test"
                                       //                                   UIAlertController *alert = [UIAlertController alertControllerWithTitle:url.absoluteString message:nil preferredStyle:UIAlertControllerStyleAlert];
                                       //                                   [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:NULL]];
                                       //                                   [[self currentViewController] presentViewController:alert animated:YES completion:NULL];
                                       //                                   return;
                                       NSDictionary *dict = params;
                                       if (!dict || ![dict isKindOfClass:[NSDictionary class]]){
                                           return;
                                       }
                                       //推送消息增加aid字段表示稿件id；原id字段如果为直播则为直播ID，专题则为专题栏目ID，稿件则为稿件ID；
                                       int artId = [[dict objectForKey:@"id"] intValue];
                                       if(artId > 0){
                                           int articleID = artId;
                                           if([dict objectForKey:@"aid"]){
                                               articleID = [[dict objectForKey:@"aid"] intValue];
                                           }
                                           int linkID = artId;
                                           Article *article = [[Article alloc] init];
                                           article.fileId = articleID;
                                           article.lastID = [NSNumber numberWithInt:articleID];
                                           article.title = [dict objectForKey:@"ti"];
                                           //0：文章；1：图集；2：视频；3：专题；4：链接；5：没用；6：直播；7：活动；8：广告
                                           int type = 0;
                                           switch ([[dict objectForKey:@"type"] intValue]) {
                                                   /*
                                                    1 普通稿件(视频稿件)
                                                    2 组图稿件
                                                    3 专题稿件
                                                    4 直播稿件
                                                    5 问答稿件
                                                    6 投票稿件
                                                    7 数字报稿件
                                                    */
                                               case 1:
                                                   type = 0;
                                                   break;
                                               case 2:
                                                   type = 1;
                                                   break;
                                               case 3:
                                                   type = 3;
                                                   break;
                                               case 4:
                                                   type = 6;
                                                   break;
                                               case 5:
                                                   type = 4;
                                                   //article.extproperty = @"questionsAndAnswers";
                                                   article.columnId = 11169;
                                                   break;
                                               case 6:
                                                   type = 4;
                                                   break;
                                               case 7:
                                                   type = 0;
                                                   break;
                                               case 102:
                                                   type = 102;
                                               default:
                                                   break;
                                           }
                                           article.articleType = type;
                                           article.linkID = linkID;
                                           Column *column = [[Column alloc] init];
                                           if(article.articleType == ArticleType_SPECIAL || article.articleType == ArticleType_LIVESHOW){
                                               column.columnId = linkID;
                                           }
                                           if (article.articleType == ArticleType_QAAPLUS) {
                                               article.lastID = [NSNumber numberWithInt:articleID ];
                                           }
                                           self.window.rootViewController = self.tabBarController;
                                           
                                           [NewsCellUtil clickNewsCell:article column:column in:[self currentViewController]];
                                           
                                       }
                                       
                                   }];

    }
        /* 处理程序杀死后接收并点击本地推送的处理代码 */
    // 如果是正常启动应用程序,那么launchOptions参数是null; 如果是通过其它方式启动应用程序如推送,那么launchOptions就有值
    if (launchOptions[UIApplicationLaunchOptionsLocalNotificationKey]) {
        Article *article = [Article articleFromDict:launchOptions];
        if(article.fileId){
            SeeRootViewController *controller = [[SeeRootViewController alloc] init];
            controller.seeArticle = article;
            controller.isNavGoback = YES;
            [[self currentViewController] presentViewController:controller animated:NO completion:nil];
           
        }
    }

    //设置webview的用户代理App标识
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectZero];
    NSString *oldAgent = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    NSString *newAgent = [oldAgent stringByAppendingString:@" xkyApp"];
    NSDictionary *dictionnary = [[NSDictionary alloc] initWithObjectsAndKeys:newAgent, @"UserAgent", nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionnary];
    
    self.personDic = [NSDictionary dictionaryWithContentsOfFile:pathForMainBundleResource(@"personSetting.plist")];
    
    NoNetWorkPageController *controller = [[NoNetWorkPageController alloc] init];
    [controller setFinishBlock:^(id data){
        [self loadFasterStart];
    }];
    self.window.rootViewController = controller;
    
    if ([AppConfig sharedAppConfig].isNeedLoginBeforeEnter && [NSString isNilOrEmpty:[Global userId]]) {
        YXLoginViewController *controller = [[YXLoginViewController alloc] init];
        [self.window.rootViewController presentViewController:[Global controllerToNav:controller] animated:YES completion:NULL];
    }
    

#if !(defined(DEBUG) && DEBUG)
    NSDictionary *appConfigDict = [NSDictionary dictionaryWithContentsOfFile:pathForMainBundleResource(@"app_config.plist")];
    NSString *urlString = [appConfigDict objectForKey:@"server_if"];
    if ([urlString containsString:@"newaircloud.com"] && ![urlString containsString:@"https://h5.newaircloud.com"]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"域名配置错误" message:@"请使用https://h5.newaircloud.com" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:
        [UIAlertAction actionWithTitle:NSLocalizedString(@"确认", nil) style:UIAlertActionStyleCancel handler:NULL]];
        [[self currentViewController] presentViewController:alert animated:YES completion:NULL];
    }
    
#endif
    
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"FirstStart"];
    XYLog(@"应用进入后台状态");
    self.window.alpha = 1.0;
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kLastRmoteNotificationTime];

   
}


- (void)applicationWillEnterForeground:(UIApplication *)application
{
    self.window.alpha = 1.0;
    // 对于在商城别的标签下二次进入进行刷新处理
    [[NSUserDefaults standardUserDefaults] setObject:@"true" forKey:@"duiba-foreground"];
    // 对于在商城标签下二次进入进行刷新处理
    [[NSNotificationCenter defaultCenter] postNotificationName:@"duiba-load-WebView" object:self userInfo:nil];
    return;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    XYLog(@"应用进入激活状态");
    
    if (![NSString isNilOrEmpty:[Global userId]]) {
        //积分入库
        FounderIntegralRequest *IntegralRequest = [[FounderIntegralRequest alloc] init];
        NSString *dateSign = [NSString stringWithFormat:@"LoginDate-%@",[Global userId]];
        NSDate *loginDate = [[NSUserDefaults standardUserDefaults] objectForKey:dateSign];
        // 与上一次登录时间不是【同一日】才去请求登录积分，因为多次登录服务器也只是记一次分
        if (![IntegralRequest isSameDay:loginDate date2:[NSDate date]]) {
            
            [IntegralRequest addIntegralWithUType:UTYPE_LOGIN integralBlock:^(NSDictionary *integralDict) {
                if (!integralDict || ![[integralDict objectForKey:@"success"] boolValue]) {
                    [Global showTip:NSLocalizedString(@"登录成功",nil)];
                }else{
                    NSInteger score = [[integralDict objectForKey:@"score"] integerValue];
                    if (score) {//score分数不为0提醒
                        [Global showTip:[NSString stringWithFormat:@"%@，%@+%ld", NSLocalizedString(@"登录成功", nil), [AppConfig sharedAppConfig].integralName, (long)score]];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"duiba-load-WebView" object:self userInfo:nil];
                    }else{
                        
                        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:dateSign];
                    }
                }
            }];
        }
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    XYLog(@"应用进入非激活状态");
}
- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"FirstStart"];
    XYLog(@"应用进入终止状态");
    self.window.alpha = 1.0;
}

-(void)remoteControlReceivedWithEvent:(UIEvent *)event{
    if (event.type == UIEventTypeRemoteControl) {
        switch (event.subtype) {
            case UIEventSubtypeRemoteControlPlay:
                [[UIPlayerView shareInstance] audioPlay];
                break;
            case UIEventSubtypeRemoteControlPause:
                [[UIPlayerView shareInstance] audioPause];
                break;
            
            default:
                break;
        }
    }
}


- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    if(self.isAllOrientation)
    {
        return UIInterfaceOrientationMaskAll;
    }
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    BOOL result = [[UMSocialManager defaultManager] handleOpenURL:url];
    
    //    if ([url.scheme isEqualToString:[AppConfig sharedAppConfig].kMobWeChatAppId]) {
    //        //return [WXApi handleOpenURL:url delegate:self];
    //    }
    //必写
    [MWApi routeMLink:url];
    return result;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    BOOL result = [[UMSocialManager defaultManager] handleOpenURL:url];
    if (!result) {
        // 其他如支付等SDK的回调
    }
    return result;
}

//iOS9+
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(nonnull NSDictionary *)options
{
    BOOL result = [[UMSocialManager defaultManager] handleOpenURL:url];
    
    //    if ([url.scheme isEqualToString:[AppConfig sharedAppConfig].kMobWeChatAppId]) {
    //       // return [WXApi handleOpenURL:url delegate:self];
    //    }
    //必写
    [MWApi routeMLink:url];
    return result;
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray * _Nullable))restorationHandler {
    return [MWApi continueUserActivity:userActivity];
}

#pragma mark - 友盟推送初始化
//友盟初始化
- (void)UMMessageInitWith:(NSDictionary *)launchOptions
{
    [UMessage startWithAppkey:@"5a0195ac8f4a9d5294000049" launchOptions:launchOptions];
    //注册通知
    [UMessage registerForRemoteNotifications];
    //iOS10必须加下面这段代码。
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate=self;
    UNAuthorizationOptions types10=UNAuthorizationOptionBadge|  UNAuthorizationOptionAlert|UNAuthorizationOptionSound;
    [center requestAuthorizationWithOptions:types10     completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (granted) {
            //点击允许
        } else {
            //点击不允许
        }
    }];
    //打开日志，方便调试
    [UMessage setLogEnabled:YES];
}

/**个推初始化*/ //个推改为友盟推送
//-(void)GeTuiInit{
//
//    //个推推送 通过 appId、 appKey 、appSecret 启动SDK，注：该方法需要在主线程中调用
//    [GeTuiSdk startSdkWithAppId:[AppConfig sharedAppConfig].kGtAppId appKey:[AppConfig sharedAppConfig].kGtAppKey appSecret:[AppConfig sharedAppConfig].kGtAppSecret delegate:self];
//    // 注册APNS和本地推送
//    [self registerRemoteNotification];
//}

/** 注册用户通知 */
//- (void)registerRemoteNotification {
//
//    // 定义用户通知类型(Remote.远程 - Badge.标记 Alert.提示 Sound.声音)
//    UIUserNotificationType types = UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound;
//    // 定义用户通知设置
//    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
//    // 注册用户通知 - 根据用户通知设置
//    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
//}

/** 已登记用户通知 */
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    // 注册远程通知（推送）
    [application registerForRemoteNotifications];
}

/** 远程通知注册成功委托 */
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
//    [GeTuiSdk registerDeviceToken:token];
    [UMessage registerDeviceToken:deviceToken];
   
}



/** 远程通知注册失败委托 */
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    XYLog(@"\n>>>[DeviceToken Error]:%@\n\n", error.description);
    //[self showAlertView:error.description];
}

- (void)showAlertView:(NSString *)str
{
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:str preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancleAct = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
    [alertVC addAction:cancleAct];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertVC animated:YES completion:NULL];
}

/** APP已经接收到“远程”通知(推送) - (App运行在后台/App运行在前台) */
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {

    [UMessage didReceiveRemoteNotification:userInfo];
    
    NSString *payload = [userInfo objectForKey:@"payload"];
    if(payload){
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[payload dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
        if(self.window.rootViewController == self.tabBarController){
            [self handleRemoteNotification:dict];
        }
        else{
            self.pushNotificationKey = dict;
        }
    }

    application.applicationIconBadgeNumber = 0;
}

/** APP已经接收到“远程”通知(推送) - 透传推送消息  */
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
    
    NSString *payload = [userInfo objectForKey:@"payload"];
    if(payload){
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[payload dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
        if(self.window.rootViewController == self.tabBarController){
            [self handleRemoteNotification:dict];
        }
        else{
            self.pushNotificationKey = dict;
        }
    }
    application.applicationIconBadgeNumber = 1;
    completionHandler(UIBackgroundFetchResultNewData);
}

#pragma mark - 处理本地推送通知[当APP运行中才调用]
/**
 *  本地通知回调函数，当应用程序在运行中时调用
 *  处理程序未被杀死时 1：程序在前台，调用该函数直接接收推送信息 2：程序在后台，用户点击本地推送调用该函数接收推送信息
 *  @param application
 *  @param notification
 */
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    
    NSString *notiKey = [NSString stringWithFormat:@"%@%@", kLiveRemindNotificationKey,notification.userInfo[@"fileID"]];
    // 取消该本地推送
    [LocalNotificationManager cancelLocalNotificationWithKey:notiKey];
    //如果应用是在前台
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        _localNotificatinUserInfo = notification.userInfo;
        UIAlertView *AlertView = [[UIAlertView alloc] initWithTitle:@"直播提醒" message:notification.userInfo[@"title"] delegate:self cancelButtonTitle:@"观看" otherButtonTitles:@"忽略", nil];
        [AlertView show];
    }else{
        //处理交互
        NSNotification *notify = [[NSNotification alloc] initWithName:kOpenLiveDetailNotificationName object:nil userInfo:notification.userInfo];
        [[NSNotificationCenter defaultCenter] postNotification:notify];
        // 更新显示的徽章个数
        NSInteger badge = [UIApplication sharedApplication].applicationIconBadgeNumber;
        badge--;
        badge = badge >= 0 ? badge : 0;
        [UIApplication sharedApplication].applicationIconBadgeNumber = badge;
    }
}


/** SDK收到透传消息回调 */
/*
- (void)GeTuiSdkDidReceivePayloadData:(NSData *)payloadData andTaskId:(NSString *)taskId andMsgId:(NSString *)msgId andOffLine:(BOOL)offLine fromGtAppId:(NSString *)appId {
    
    NSString *payloadMsg = nil;
    if (payloadData) {
        payloadMsg = [[NSString alloc] initWithBytes:payloadData.bytes length:payloadData.length encoding:NSUTF8StringEncoding];
        
        NSData *dataDic = [payloadMsg dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:dataDic options:NSJSONReadingMutableContainers error:nil];
        
        NSString *sendTitle = [NSString stringWithFormat:@"%@",[dict objectForKey:@"ti"]];
        // 如果应用在前台，直接走的是个推透传下发，不走APNs
        if (!offLine) {
           self.pushNotificationKey = dict;
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"推送热闻",nil) message:sendTitle delegate:self cancelButtonTitle:NSLocalizedString(@"阅读",nil) otherButtonTitles:NSLocalizedString(@"忽略",nil), nil];
            [alertView show];
        }
    }
}

// SDK启动成功返回cid 
- (void)GeTuiSdkDidRegisterClient:(NSString *)clientId {

    // [4-EXT-1]: 个推SDK已注册，返回clientId
    XYLog(@"\n>>>[GeTuiSdk RegisterClient]:%@\n\n", clientId);
}
// SDK遇到错误回调
- (void)GeTuiSdkDidOccurError:(NSError *)error {
    // [EXT]:个推错误报告，集成步骤发生的任何错误都在这里通知，如果集成后，无法正常收到消息，查看这里的通知。
    XYLog(@"\n>>>[GexinSdk error]:%@\n\n", [error localizedDescription]);
}

// SDK收到sendMessage消息回调
- (void)GeTuiSdkDidSendMessage:(NSString *)messageId result:(int)result {
    // [4-EXT]:发送上行消息结果反馈
    NSString *msg = [NSString stringWithFormat:@"sendmessage=%@,result=%d", messageId, result];
    XYLog(@"\n>>>[GexinSdk DidSendMessage]:%@\n\n", msg);
}
// SDK运行状态通知
- (void)GeTuiSDkDidNotifySdkState:(SdkStatus)aStatus {
    // [EXT]:通知SDK运行状态
    XYLog(@"\n>>>[GexinSdk SdkState]:%u\n\n", aStatus);
    XYLog(@"\n>>>[GexinSdk SdkState]:%u\n\n", aStatus);
}
// SDK设置推送模式回调
- (void)GeTuiSdkDidSetPushMode:(BOOL)isModeOff error:(NSError *)error {
    if (error) {
        XYLog(@"\n>>>[GexinSdk SetModeOff Error]:%@\n\n", [error localizedDescription]);
        return;
    }
    
    XYLog(@"\n>>>[GexinSdk SetModeOff]:%@\n\n", isModeOff ? @"开启" : @"关闭");
    XYLog(@"\n>>>[GexinSdk SetModeOff]:%@\n\n", isModeOff ? @"开启" : @"关闭");
}
*/

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView.title isEqualToString:@"直播提醒"]) {
        if (buttonIndex == 0){
            //处理交互
            NSNotification *notify = [[NSNotification alloc] initWithName:kOpenLiveDetailNotificationName object:nil userInfo:_localNotificatinUserInfo];
            [[NSNotificationCenter defaultCenter] postNotification:notify];
        }
        return;
    }
    
    if([alertView.title isEqualToString:@"推送热闻"]){
    
        if (buttonIndex == 0){
            [self handleRemoteNotification:self.pushNotificationKey];
        }
    }
    else if (alertView.tag == 910)
    {
        if (!isAppNormalStart()){
            [self loadFasterStart];
        }
    }
}

#pragma mark - push notification
/**
 *  推送的数据
 *
 *  @param userInfo 数据字典
 */
- (void)handleRemoteNotification:(NSDictionary *)dict
{
    if (!dict || ![dict isKindOfClass:[NSDictionary class]]){
        return;
    }
    //推送消息增加aid字段表示稿件id；原id字段如果为直播则为直播ID，专题则为专题栏目ID，稿件则为稿件ID；
    int artId = [[dict objectForKey:@"id"] intValue];
    if(artId > 0){
        int articleID = artId;
        if([dict objectForKey:@"aid"]){
            articleID = [[dict objectForKey:@"aid"] intValue];
        }
        int linkID = artId;
        Article *article = [[Article alloc] init];
        article.fileId = articleID;
        article.title = [dict objectForKey:@"ti"];
        article.articleType = [[dict objectForKey:@"ty"] intValue];
        article.linkID = linkID;
        Column *column = [[Column alloc] init];
        if(article.articleType == ArticleType_SPECIAL || article.articleType == ArticleType_LIVESHOW){
            column.columnId = linkID;
        }
        if (article.articleType == ArticleType_QAAPLUS) {
            article.lastID = [NSNumber numberWithInt:articleID];
        }
        [NewsCellUtil clickNewsCell:article column:column in:[self currentViewController]];
    }
    
    self.pushNotificationKey = nil;
}

- (UIViewController *)currentViewController {
    UIViewController *vc = self.window.rootViewController;
    while (vc.presentedViewController) {
        vc = vc.presentedViewController;
        
        if ([vc isKindOfClass:[UINavigationController class]]) {
            vc = [(UINavigationController *)vc visibleViewController];
        } else if ([vc isKindOfClass:[UITabBarController class]]) {
            vc = [(UITabBarController *)vc selectedViewController];
        }
    }
    return vc;
}


- (void)printFontName
{
    /*
    NSArray *familys = [UIFont familyNames];
    
    for (int i = 0; i < [familys count]; i++)
    {
        NSString *family = [familys objectAtIndex:i];
        XYLog(@"=====Fontfamily:%@", family);
        if ([family compare:@"FZXiHeiGBK-YS01"] == NSOrderedSame)
        {
            NSArray *fonts = [UIFont fontNamesForFamilyName:family];
            for(int j = 0; j < [fonts count]; j++)
            {
                XYLog(@"***FontName:%@", [fonts objectAtIndex:j]);
            }
        }
    }
     */
}


- (void)showErrorAlertView
{
    if(!isAppNormalStart())
    {
        if (errorAlertView == nil)
        {
            errorAlertView = [[UIAlertView alloc] initWithTitle:@"非常抱歉，第一次启动需要保证联网，请检查一下手机的网络情况，再重新打开试试。" message:@"" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            errorAlertView.tag = 910;
        }
        [errorAlertView show];
    }
    else
    {
        [Global showTipNoNetWork];
    }
}



/**
 *  增加新手引导页面
 *
 *  @param 图片名称
 */
- (void)addHelperPage:(NSString *)viewName
{
    NSNumber *isViewName = [[NSUserDefaults standardUserDefaults] objectForKey:viewName];
    if ([AppConfig sharedAppConfig].has_startHelpPage && ![isViewName boolValue])
    {
        UIHelperView *helpview = [[UIHelperView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        [self.window addSubview:helpview];
        [helpview showHelp:viewName];
        
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:YES] forKey:viewName];
    }
}


//显示隐私声明
-(void)addPrivacyView{
    
    if([[AppConfig sharedAppConfig].sid isEqualToString:@"aomen"]){
        NSNumber *isAggreePrivacyPage = [[NSUserDefaults standardUserDefaults] objectForKey:@"IsAggreePrivacyPage"];
        if(![isAggreePrivacyPage boolValue]){
            UIPrivacyView *privacyView = [[UIPrivacyView alloc] initWithFrame:self.window.bounds];
            [self.window addSubview:privacyView];
        }
    }
}

#pragma mark - UITabBarControllerDelegate
- (BOOL)tabBarController:(UITabBarController *)tabBarController1 shouldSelectViewController:(UIViewController *)viewController
{
    //当前选中的tab
    UIViewController *selectVC = tabBarController1.selectedViewController;
    if ([selectVC isEqual:viewController]) {
        // 发送通知，回到顶部
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshNewsPageController" object:nil userInfo:nil];
        return NO;
    }
    [MobClick event:@"function_nav" attributes:@{@"home_column_click":viewController.tabBarItem.title}];
    return YES;
    
    /*
    NSLog(@"--tabbaritem.title--%@",viewController.tabBarItem.title);
    //这里我判断的是当前点击的tabBarItem的标题
    if ([viewController.tabBarItem.title isEqualToString:@"爆料"]) {
        //如果用户ID存在的话，说明已登陆
        if ([Global userId].length) {
            return YES;
        }
        else
        {
            //跳到登录页面
            YXLoginViewController *loginVC = [[YXLoginViewController alloc] init];
            //隐藏tabbar
            loginVC.hidesBottomBarWhenPushed = YES;
            loginVC.loginSuccessBlock = ^(YXLoginViewController *loginSelf){
                [loginSelf dismissViewControllerAnimated:YES completion:nil];
                tabBarController1.selectedViewController = viewController;
            };
            [loginVC rightPageNavTopButtons];
            [self.window.rootViewController presentViewController:[Global controllerToNav:loginVC] animated:YES completion:nil];
            
            return NO;
        }
    }
    else
        return YES;
    */
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication*)application
{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}
@end
