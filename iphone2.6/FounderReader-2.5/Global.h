//
//  Global.h
//  FounderReader-2.5
//
//  Created by chenfei on 4/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *key = @"newaircloud_vjow9Dej#JDj4[oIDF";
extern BOOL hasNewVersion;
typedef void (^FinishBlock)(NSString *resultJson);
typedef void (^FinishDataBlock)(id data);
typedef void (^FinishDataBlock2)(id data1, id data2);
typedef void (^Completion)();
@interface Global : NSObject

// 抽帧
+ (UIImage *)thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time;

+ (NSString *)uuid;

+ (NSString *)fontSize;
+ (void)setFontSize:(NSString *)value;
+ (NSString *)fontName;
+ (void)setFontName:(NSString *)fontname;
+ (NSString *)fontShowName;

//2g/3g网络不下载图片
+ (BOOL)isWanNetWorking;
+ (BOOL)isWANswitch;
+ (void)setWANswitch:(BOOL)value;

//远程推送设置

+(void)setCustomerRemoteNotificationOpen:(BOOL)value;
+(BOOL)customerRemoteNotificationOpen;
//设置默认推送打开
+(void)setDefaultCustomerRemoteNotificationOpen;
+ (BOOL)isOpenCustomerRemoteNotification;

+(NSString *)userId;
+(NSString *)userName;
+(NSString *)userPhone;
//获取会员本地记录信息
+(NSString *)userInfoByKey:(NSString *)key;
//获取会员本地所有记录信息的JSON串
+(NSString *)userInfoStr;
+(BOOL)isThirtyLogin;
+(UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize;
//弹出显示信息，2秒后自动隐藏
+ (void)showTip:(NSString*)tip;
//弹出显示信息，不隐藏，直到调用showTip才隐藏
+ (void)showTipAlways:(NSString*)tip;
+ (void)hideTip;
//显示网络不给力提示 
+ (void)showTipNoNetWork;
//弹出提示信息，N秒后消失
+ (void)showMessage:(NSString *)message duration:(NSTimeInterval)time;
+ (void)showMessage:(NSString *)message duration:(NSTimeInterval)time onView:(UIView *)view;
+(BOOL)transMov2Mp4:(NSURL*)sourceURL destURL:(NSString*)destURL finishedBlock:(FinishDataBlock)finishedBlock;
//显示没有网络的错误页面
+ (void)showWebErrorView:(UIViewController *)controller;
//隐藏没有网络的错误页面
+ (void)hideWebErrorView:(UIViewController *)controller;
//创建统一背景的导航控制器
+(UINavigationController *)controllerToNav:(UIViewController *)controller;
/**
 *  比较某时间距离现在的状态
 *
 *  @param dateStr
 *
 *  @return
 */
+ (NSInteger)judgeDate:(NSString *)dateStr;

// 模型对象转字典
- (NSDictionary*)getObjectData:(id)obj;
//获取4:3的默认背景图
+(UIImage *)getBgImage43;
//获取16:9的默认背景图
+(UIImage *)getBgImage169;
//获取9:16的默认背景图
+(UIImage *)getBgImage916;
//获取3:1的默认背景图
+(UIImage *)getBgImage31;
//获取4:1的默认背景图
+(UIImage *)getBgImage41;
//获取2:1的默认背景图
+(UIImage *)getBgImage21;
//获取1:1的默认背景图
+(UIImage *)getBgImage11;
//获取5:2的默认背景图
+(UIImage *)getBgImage52;
//获取APP icon图标
+(UIImage *)getAppIcon;
//导航栏背景图
+(UIImage *)navigationImage;
//栏目条背景图
+(UIImage *)columnBarImage;
//检查是否导航背景需要加横线（针对白色背景）
+(UIColor *)navigationLineColor;
//获取当前显示的控制器
+(UIViewController *)getCurrentVC;

//添加遮挡板、删除遮挡板
+ (void)addMaskViewWithBlock:(void (^)(void))block;
+ (void)removeMaskViewWithBlock:(void (^)(void))block;
// 字典转json字符串
+ (NSString *)dictionaryToJson:(NSDictionary *)dic;
// 数组转json字符串
+ (NSString *)objArrayToJSON:(NSArray *)array;

// 压缩图片，任意大小的图片压缩到100K~200k以内
+(NSData *)compressImageData:(UIImage *)myimage;

+(void)showCustomMessage:(NSString *)str;

@end

