//
//  Global.m
//  FounderReader-2.5
//
//  Created by chenfei on 4/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Global.h"
#import <AVFoundation/AVFoundation.h>
#import "DataLib/DataLib.h"
#import "UserAccountDefine.h"
#import "NSDate+Extension.h"
#import <objc/runtime.h>
#import "ColorStyleConfig.h"
#import "MYTapGestureRecognizer.h"
#import "ColumnBarConfig.h"

BOOL hasNewVersion = NO;
@implementation Global

+ (UIImage *)thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time
{
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    
    NSParameterAssert(asset);
    
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.appliesPreferredTrackTransform = YES;
    generator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    
    CGImageRef imageRef = NULL;
    NSError *error = nil;
    imageRef = [generator copyCGImageAtTime:CMTimeMake(time, 60) actualTime:NULL error:&error];
    
    if (!imageRef)
        XYLog(@"抽帧错误: %@", error);
    
    UIImage *thumbnail = imageRef ? [[UIImage alloc] initWithCGImage:imageRef]  : nil;
    CGImageRelease(imageRef);
    return thumbnail;
}

+ (NSString *)uuid
{	
	CFUUIDRef theUUID = CFUUIDCreate(NULL);
	CFStringRef string = CFUUIDCreateString(NULL, theUUID);
	CFRelease(theUUID);
	
	return (__bridge NSString *)string;
}

+ (NSString *)fontSize
{
    NSString *fontSize = [[NSUserDefaults standardUserDefaults] objectForKey:@"Font_Size"];
    if(fontSize == nil){
        fontSize = @"md";
    }
    return fontSize;
}

+ (void)setFontSize:(NSString *)value
{
	[[NSUserDefaults standardUserDefaults] setValue:value forKey:@"Font_Size"];
}

+ (BOOL)isWanNetWorking
{
    return [[Reachability reachabilityWithHostName:@"www.baidu.com"] isReachableViaWWAN];
}

//2g/3g网络不下载图片
+ (BOOL)isWANswitch
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"isReachableViaWWAN_FM"];
}

+ (void)setWANswitch:(BOOL)value
{
	[[NSUserDefaults standardUserDefaults] setBool:value forKey:@"isReachableViaWWAN_FM"];
}


+ (void)setFontName:(NSString *)fontName
{
    return;
    /*
    NSString *font = [[UIFont systemFontOfSize:1] fontName];
    if ([fontName isEqualToString:@"方正兰亭纤黑"]) {
        font = @"FZLTHThin--GB1-0-YS";
    }
    
    [[NSUserDefaults standardUserDefaults] setValue:font forKey:@"font_name"];
     */
}

+ (NSString *)fontName{
    return [[UIFont systemFontOfSize:1] fontName];
    /*
    NSString *font = [[NSUserDefaults standardUserDefaults] stringForKey:@"font_name"];
    if (font == nil) {
        font = [[UIFont systemFontOfSize:1] fontName];
    }
    return font;
     */
}

+ (NSString *)fontShowName{
    
    NSString *font = [[NSUserDefaults standardUserDefaults] stringForKey:@"font_name"];
    
    if([font isEqualToString:@"FZLTHThin--GB1-0-YS"]){
        
        return @"方正兰亭纤黑";
    }
    else{
        return @"系统默认字体";
    }
}

+(void)setDefaultCustomerRemoteNotificationOpen
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"CustomerRemoteNotificationOpen_YX"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+(void)setCustomerRemoteNotificationOpen:(BOOL)value
{
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:@"CustomerRemoteNotificationOpen_YX"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isOpenCustomerRemoteNotification {
    BOOL isOpenCustomerRemoteNotification = [[NSUserDefaults standardUserDefaults] boolForKey:@"CustomerRemoteNotificationOpen_YX"];
    return isOpenCustomerRemoteNotification;
}

+(BOOL)customerRemoteNotificationOpen{
    
    UIUserNotificationType types = [[[UIApplication sharedApplication] currentUserNotificationSettings] types];
    return (types & UIUserNotificationTypeAlert);//意思是枚举集合type是否存在并且枚举集合type是否包含UIUserNotificationTypeAlert
}

+(NSString *)userId{
    
    NSString *userid = [[NSUserDefaults standardUserDefaults] objectForKey:KuserAccountUserId];
    if (!userid) {
        userid = @"";
    }
    return userid;
}

+(BOOL)isThirtyLogin
{
//    if([Global userId].length > 0 && ([ShareSDK hasAuthorized:SSDKPlatformTypeSinaWeibo]
//       || [ShareSDK hasAuthorized:SSDKPlatformSubTypeQZone]
//       || [ShareSDK hasAuthorized:SSDKPlatformTypeWechat])){
//
//        return YES;
//    }
//    return NO;
    
}
+(NSString *)userName{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *userName = [defaults stringForKey:KuserAccountNickName];
    if ([userName length] == 0) {
        return @"";
    }
    return userName;
}

+(NSString *)userPhone{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *userPhone = [defaults stringForKey:KuserAccountPhone];
    if ([userPhone length] == 0) {
        return @"";
    }
    return userPhone;
}
//获取会员本地记录信息
+(NSString *)userInfoByKey:(NSString *)key{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *keyValue = [defaults stringForKey:key];
    if ([keyValue length] == 0) {
        return @"";
    }
    return keyValue;
}
//获取会员本地所有记录信息的JSON串
+(NSString *)userInfoStr{
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:[Global userInfoByKey:KuserAccountUserId] forKey:@"userID"];
    [dict setValue:[Global userInfoByKey:KuserAccountPhone] forKey:@"userPhone"];
    [dict setValue:[Global userInfoByKey:KuserAccountLoginName] forKey:@"loginName"];
    [dict setValue:[Global userInfoByKey:KuserAccountNickName] forKey:@"nickName"];
    [dict setValue:[Global userInfoByKey:KuserAccountLoginPassWord] forKey:@"password"];
    [dict setValue:[Global userInfoByKey:KuserAccountMail] forKey:@"email"];
    [dict setValue:[Global userInfoByKey:KuserAccountFace] forKey:@"faceUrl"];
    [dict setValue:[Global userInfoByKey:KuserAccountType] forKey:@"uType"];
    [dict setValue:[Global userInfoByKey:KuserAccountssoCode] forKey:@"openID"];
   
    /*
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    if(error == nil){
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    else{
        return @"";
        XYLog(@"%@", [error description]);
    }
    */
    
    //硬拼
    return [NSString stringWithFormat:@"{\"userID\":\"%@\", \"userPhone\":\"%@\", \"loginName\":\"%@\", \"nickName\":\"%@\", \"password\":\"%@\", \"email\":\"%@\", \"faceUrl\":\"%@\", \"uType\":\"%@\", \"openID\":\"%@\"}",
     [Global userInfoByKey:KuserAccountUserId], [Global userInfoByKey:KuserAccountPhone], [Global userInfoByKey:KuserAccountLoginName], [Global userInfoByKey:KuserAccountNickName], [Global userInfoByKey:KuserAccountLoginPassWord], [Global userInfoByKey:KuserAccountMail], [Global userInfoByKey:KuserAccountFace], [Global userInfoByKey:KuserAccountType], [Global userInfoByKey:KuserAccountssoCode]];
    
}
//对图片尺寸进行压缩--
+(UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize
{
    // Create a graphics image context
    UIGraphicsBeginImageContext(newSize);
    
    // Tell the old image to draw in this new context, with the desired
    // new size
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    
    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // End the context
    UIGraphicsEndImageContext();
    
    // Return the new image.
    return newImage;
}

+ (void)showTip:(NSString*)tip
{
    [Global showMessage:tip duration:2];
}

+ (void)hideTip
{
    [Global hideMessage];
}

+ (void)showTipNoNetWork
{
    [Global showMessage:NSLocalizedString(@"网络不给力，请检查一下网络设置",nil) duration:2];
}

+(void)showCustomMessage:(NSString *)str
{
    [Global showMessage:str duration:2];
}

+ (void)showTipAlways:(NSString*)tip
{
    [Global showMessage:tip duration:60];
}

+ (void)hideMessage
{
    UIWindow * window = [UIApplication sharedApplication].keyWindow;
    UIView *tipView = [window viewWithTag:1111111];
    if(tipView){
        [tipView removeFromSuperview];
    }
}

+ (void)showMessage:(NSString *)message duration:(NSTimeInterval)time {
    UIWindow * window = [UIApplication sharedApplication].keyWindow;
    [Global showMessage:message duration:time onView:window];
}

+ (void)showMessage:(NSString *)message duration:(NSTimeInterval)time onView:(UIView *)view
{
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    UIWindow * window = [UIApplication sharedApplication].keyWindow;
    UIView *lastView = [window viewWithTag:1111111];
    if(lastView){
        [lastView removeFromSuperview];
    }
    UIView *showview =  [[UIView alloc]init];
    showview.backgroundColor = [UIColor blackColor];
    showview.frame = CGRectMake(1, 1, 1, 1);
    showview.alpha = 0.9f;
    showview.layer.cornerRadius = 5.0f;
    showview.layer.masksToBounds = YES;
    showview.tag = 1111111;
    [view addSubview:showview];
    
    UILabel *label = [[UILabel alloc]init];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    
    NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:14],
                                 NSParagraphStyleAttributeName:paragraphStyle.copy};
    
    CGSize labelSize = [message boundingRectWithSize:CGSizeMake(kSWidth/2, 999)
                                             options:NSStringDrawingUsesLineFragmentOrigin
                                          attributes:attributes context:nil].size;
    
    label.frame = CGRectMake(10, 15, labelSize.width + 20, labelSize.height);
    label.text = message;
    label.numberOfLines = 5;
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:14];
    [showview addSubview:label];
    
    showview.frame = CGRectMake((screenSize.width - labelSize.width - 40)/2,
                                (screenSize.height - labelSize.height - 20)/2,
                                labelSize.width+40,
                                labelSize.height+30);
    [UIView animateWithDuration:time animations:^{
        showview.alpha = 0;
    } completion:^(BOOL finished) {
        [showview removeFromSuperview];
    }];
}
/**
 *  视频格式转换MOV2MP4
 *
 *  @param sourceURL     数据源URL
 *  @param destURL       目标URL
 *  @param finishedBlock 完成后调用block
 */
+ (BOOL)transMov2Mp4:(NSURL*)sourceURL destURL:(NSString*)destURL finishedBlock:(FinishDataBlock)finishedBlock
{
    //NSURL *_sourceURL = [NSURL URLWithString:sourceURL];
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:sourceURL options:nil];
    
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    
    if ([compatiblePresets containsObject:AVAssetExportPresetMediumQuality] || [compatiblePresets containsObject:AVAssetExportPresetHighestQuality])
    {
        //设置视频压缩的精度
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]initWithAsset:avAsset presetName:AVAssetExportPresetMediumQuality];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *cachesDir = [paths objectAtIndex:0];
        destURL = [NSString stringWithFormat:@"%@\temp%@",cachesDir,destURL];
        
        //删除临时文件
        NSFileManager *defaultManager;
        defaultManager = [NSFileManager defaultManager];
        [defaultManager removeItemAtPath:destURL error:nil];
        
        exportSession.outputURL = [NSURL fileURLWithPath:destURL];
        exportSession.outputFileType = AVFileTypeMPEG4;
        
        CMTime start = CMTimeMakeWithSeconds(0.0, 600);
        
        CMTime time = [avAsset duration];
        int seconds = ceil(time.value/time.timescale);
        CMTime duration = CMTimeMakeWithSeconds(seconds, 600);
        
        CMTimeRange range = CMTimeRangeMake(start, duration);
        exportSession.timeRange = range;
        
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            
            switch ([exportSession status]) {
                    
                case AVAssetExportSessionStatusFailed:
                    XYLog(@"Export failed: %@", [[exportSession error] localizedDescription]);
                    break;
                    
                case AVAssetExportSessionStatusCancelled:
                    
                    XYLog(@"Export canceled");
                    break;
                    
                default:
                    
                    finishedBlock([NSData dataWithContentsOfFile:destURL]);
                    
                    //删除临时文件
                    //                    NSFileManager *defaultManager;
                    //                    defaultManager = [NSFileManager defaultManager];
                    //                    [defaultManager removeItemAtPath:destURL error:nil];
                    //[defaultManager removeFileAtPath: destURL handler: nil];
                    break;
                    
            }
        }];
    }
    return YES;
}

/**
 *  比较某时间距离现在的状态
 *
 *  @param dateStr
 *
 *  @return
 */
+(NSInteger)judgeDate:(NSString *)aDate{
    if (!aDate.length) {
        return DayType_Future;
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSDate * articleDate = [dateFormatter dateFromString:aDate];
    NSDate * currentDate = [NSDate date];
    NSTimeInterval time = [articleDate timeIntervalSinceNow];
    if (time < 0) {
        //开始时间小于现在，则正在直播
        return DayType_TodayOnTime;
    }
    NSCalendar * calendar = [NSCalendar currentCalendar];
    NSDateComponents * articleComponents = [calendar components:NSCalendarUnitYear| NSCalendarUnitDay|NSCalendarUnitMonth fromDate:articleDate];
    NSDateComponents * currentComponents = [calendar components:NSCalendarUnitYear| kCFCalendarUnitDay|NSCalendarUnitMonth fromDate:currentDate];
    NSInteger articleYear = articleComponents.year;
    NSInteger articleDay = articleComponents.day;
    NSInteger articleMonth = articleComponents.month;
    
    NSInteger currentYear = currentComponents.year;
    NSInteger currentDay = currentComponents.day;
    NSInteger currentMonth = currentComponents.month;
    NSInteger currentCount = [Global getNumberOfDaysOneMoth:currentDate];
    DayType type;
    
    if (articleYear == currentYear) {//今年
        if (articleMonth == currentMonth) {
            if (articleDay == currentDay) {
                type = DayType_TodayNextTime;
            }else if(articleDay == currentDay + 1){
                type = DayType_Tomorrow;
            }else if(articleDay == currentDay + 2){
                type = DayType_AfterTomorrow;
            }else{
                type = DayType_Future;
            }
        }else if(articleMonth == (currentMonth + 1)){
            if ((articleDay == 1)&& (currentDay == currentCount)) {
                type = DayType_Tomorrow;
            }else if((articleDay == 1)&& (currentDay == currentCount-1)){
                type = DayType_AfterTomorrow;
            }else if ((articleDay == 2) &&(currentDay == currentCount)){
                type = DayType_AfterTomorrow;
            }else{
                type = DayType_Future;
            }
        }else{
            type = DayType_Future;
        }
        
    }else if(articleYear == (currentYear +1)){
        if (currentMonth == 12 && articleMonth == 1 && articleDay == 1 && currentDay == currentCount) {
            type = DayType_Tomorrow;
        }else if(currentMonth == 12 && articleMonth == 1 && articleDay == 1 && currentDay == currentCount-1){
            type = DayType_AfterTomorrow;
        }else if(currentMonth == 12 && articleMonth == 1 && articleDay == 2 && currentDay == currentCount) {
            type = DayType_AfterTomorrow;
        }else{
            type = DayType_Future;
        }
    }else {
        type = DayType_Future;
    }
    return type;
}
+(NSInteger )getNumberOfDaysOneMoth:(NSDate *)date{
    NSCalendar *calender = [NSCalendar currentCalendar];
    NSRange range = [calender rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate: date];
    return range.length;
}


/**
 *  对象转换为字典
 *
 *  @param obj 需要转化的对象
 *
 *  @return 转换后的字典
 */
- (NSDictionary*)getObjectData:(id)obj {
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    unsigned int propsCount;
    
    objc_property_t *props = class_copyPropertyList([obj class], &propsCount);
    
    for(int i = 0;i < propsCount; i++) {
        
        objc_property_t prop = props[i];
        NSString *propName = [NSString stringWithUTF8String:property_getName(prop)];
        id value = [obj valueForKey:propName];
        if(value == nil) {
            
            value = [NSNull null];
        } else {
            value = [self getObjectInternal:value];
        }
        [dic setObject:value forKey:propName];
    }
    
    return dic;
}

- (id)getObjectInternal:(id)obj {
    
    if([obj isKindOfClass:[NSString class]]
       ||
       [obj isKindOfClass:[NSNumber class]]
       ||
       [obj isKindOfClass:[NSNull class]]) {
        
        return obj;
        
    }
    if([obj isKindOfClass:[NSArray class]]) {
        
        NSArray *objarr = obj;
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:objarr.count];
        
        for(int i = 0; i < objarr.count; i++) {
            
            [arr setObject:[self getObjectInternal:[objarr objectAtIndex:i]] atIndexedSubscript:i];
        }
        return arr;
    }
    if([obj isKindOfClass:[NSDictionary class]]) {
        
        NSDictionary *objdic = obj;
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:[objdic count]];
        
        for(NSString *key in objdic.allKeys) {
            
            [dic setObject:[self getObjectInternal:[objdic objectForKey:key]] forKey:key];
        }
        return dic;
    }
    return [self getObjectData:obj];
    
}
//显示没有网络的错误页面
+ (void)showWebErrorView:(UIViewController *)controller
{
    UIView *hudView = [[UIView alloc] init];
    hudView.tag = 111112;
    hudView.frame = CGRectMake(0, 0, kSWidth, controller.view.frame.size.height-kTabBarHeight);
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_no_wifi"]];
    imageView.frame = CGRectMake((kSWidth-130)/2, kSHeight*0.2, 130, 100);
    UILabel *labelT = [[UILabel alloc] init];
    labelT.frame = CGRectMake(kSWidth/2-60, kSHeight*0.6, 120, 35);
    labelT.text = NSLocalizedString(@"刷新",nil);
//    labelT.textColor = [UIColor colorWithRed:12/255.0 green:165/255.0 blue:242/255.0 alpha:1.0];
//    labelT.layer.borderColor = [UIColor colorWithRed:12/255.0 green:165/255.0 blue:242/255.0 alpha:1.0].CGColor;
//    labelT.layer.borderWidth = 1.0f;
    labelT.textColor = [UIColor whiteColor];
    labelT.layer.masksToBounds = YES;
    labelT.layer.cornerRadius = 5.0f;
    labelT.backgroundColor = [UIColor colorWithRed:12/255.0 green:165/255.0 blue:242/255.0 alpha:0.8];
    labelT.textAlignment = NSTextAlignmentCenter;
    labelT.font = [UIFont systemFontOfSize:14];
    [hudView addSubview:labelT];
    [hudView addSubview:imageView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:controller action:@selector(onWebError:)];
    [hudView addGestureRecognizer:tap];
    [controller.view addSubview:hudView];
    [controller.view bringSubviewToFront:hudView];
}
//隐藏没有网络的错误页面
+ (void)hideWebErrorView:(UIViewController *)controller
{
    UIView *hudView = [controller.view viewWithTag:111112];
    if(hudView){
        [hudView removeFromSuperview];
    }
}

//创建统一背景的导航控制器
+(UINavigationController *)controllerToNav:(UIViewController *)controller{
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:controller];
    [nav.navigationBar setBackgroundImage:[Global navigationImage] forBarMetrics:UIBarMetricsDefault];
    UIColor *color = [ColorStyleConfig sharedColorStyleConfig].nav_bar_color;
    CGFloat redValue, greenValue, blueValue, alphaValue;
    if([color getRed:&redValue green:&greenValue blue:&blueValue alpha:&alphaValue]){
        if(redValue == 1.0 && greenValue == 1.0 && blueValue == 1.0){
            UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(0, nav.navigationBar.frame.size.height-0.5, kSWidth, 0.5)];
            line.backgroundColor = [UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:1.0];
            [nav.navigationBar addSubview:line];
        }
    }
     return nav;
}
//检查是否导航背景需要加横线（针对白色背景）
+(UIColor *)navigationLineColor{
    UIColor *color = [ColorStyleConfig sharedColorStyleConfig].nav_bar_color;
    CGFloat redValue, greenValue, blueValue, alphaValue;
    if([color getRed:&redValue green:&greenValue blue:&blueValue alpha:&alphaValue]){
        if(redValue == 1.0 && greenValue == 1.0 && blueValue == 1.0){
            return  [UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:1.0];
        }
    }
    return [UIColor clearColor];
}
//获取当前控制器
+(UIViewController *)getCurrentVC
{
    UIViewController *result = nil;
    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;
    
    return result;
}

//导航栏背景图
+(UIImage *)navigationImage{
    
    CGRect rect = CGRectMake(0.0f, 0.0f, kSWidth, kNavBarHeight);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [[ColorStyleConfig sharedColorStyleConfig].nav_bar_color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

//栏目条背景图
+(UIImage *)columnBarImage{
    
    CGRect rect = CGRectMake(0.0f, 0.0f, kSWidth, kNavBarHeight);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [[ColumnBarConfig sharedColumnBarConfig].columnBarBackgroundColor CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

//获取4:3的默认背景图
+(UIImage *)getBgImage43{
    return [UIImage imageNamed:@"bgicon43"];
}
//获取16:9的默认背景图
+(UIImage *)getBgImage169{
    return [UIImage imageNamed:@"bgicon169"];
}
//获取3:1的默认背景图
+(UIImage *)getBgImage31{
    return [UIImage imageNamed:@"bgicon31"];
}
//获取4:1的默认背景图
+(UIImage *)getBgImage41{
    return [UIImage imageNamed:@"bgicon41"];
}
//获取2:1的默认背景图
+(UIImage *)getBgImage21{
    return [UIImage imageNamed:@"bgicon21"];
}
//获取1:1的默认背景图
+(UIImage *)getBgImage11{
    return [UIImage imageNamed:@"bgicon11"];
}
//获取5:2的默认背景图
+(UIImage *)getBgImage52{
    return [UIImage imageNamed:@"bgicon52"];
}
//获取APP icon图标
+(UIImage *)getAppIcon{
    return [UIImage imageNamed:@"app_icon"];
}
//获取9:16的默认背景图
+(UIImage *)getBgImage916{
    return [UIImage imageNamed:@"bgicon916"];
}

+ (void)addMaskViewWithBlock:(void (^)(void))block {
    UIView *maskView = [kWindow viewWithTag:111111112];
    if(!maskView){
        UIView *maskView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        maskView.backgroundColor = [UIColor blackColor];
        maskView.alpha = 0.7;
        maskView.tag = 111111112;
//        MYTapGestureRecognizer *tap = [[MYTapGestureRecognizer alloc] initWithTarget:self action:@selector(removeMaskView:)];
//        tap.removeBlock = ^(){
//            if (block) {
//                block();
//            }
//        };
//        [maskView addGestureRecognizer:tap];
        [kWindow addSubview:maskView];
    }
}

+ (void)removeMaskViewWithBlock:(void (^)(void))block
{
    UIView *maskView = [kWindow viewWithTag:111111112];
    if(maskView){
        [maskView removeFromSuperview];
        if (block) {
            block();
        }
    }
}

+ (void)removeMaskView:(MYTapGestureRecognizer *)tap
{
    [self removeMaskViewWithBlock:^{
        tap.removeBlock();
    }];
}

+ (NSString *)dictionaryToJson:(NSDictionary *)dic
{
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

+ (NSString *)objArrayToJSON:(NSArray *)array {
    
    NSString *jsonStr = @"[";
    
    for (NSInteger i = 0; i < array.count; ++i) {
        if (i != 0) {
            jsonStr = [jsonStr stringByAppendingString:@","];
        }
        jsonStr = [jsonStr stringByAppendingString:array[i]];
    }
    jsonStr = [jsonStr stringByAppendingString:@"]"];
    
    return jsonStr;
}

// 压缩图片，任意大小的图片压缩到100K~200k以内
+(NSData *)compressImageData:(UIImage *)myimage
{
    /* 两种压缩方式，png和jpeg，对清晰度不是很要求的话后者压缩力度很大且很快 */
    NSData *data=UIImageJPEGRepresentation(myimage, 1.0);
    XYLog(@"%s  global压缩前图片大小为%.2fM", __func__, data.length/1024.0f/1024.0f);
    // 如果大于100k
    if (data.length>100*1024) {
        if (data.length>1024*1024) {//1M以及以上
            data=UIImageJPEGRepresentation(myimage, 0.1);
        }else if (data.length>512*1024) {//0.5M-1M
            data=UIImageJPEGRepresentation(myimage, 0.5);
        }else if (data.length>300*1024) {//0.3M-0.5M
            data=UIImageJPEGRepresentation(myimage, 0.9);
        }
    }
    XYLog(@"%s  global压缩后图片大小为%.2fM", __func__, data.length/1024.0f/1024.0f);
    return data;
}

@end
