//
//  LocalNotificationManager.m
//  NewPodcast
//
//  Created by Julian on 16/7/20.
//  Copyright © 2016年 NewPodcast. All rights reserved.
//

#import "LocalNotificationManager.h"

@implementation LocalNotificationManager

/**
 *  注册通知
 *
 *  @param fireDate 本地通知触发时间
 *  @param message  本地通知的具体显示内容
 *  @param userInfo 本地通知相关信息设置
 */
+ (void)configLocalNotificationWithFireDate:(NSDate *)fireDate alertMessage:(NSString *)message userInfo:(NSDictionary *)userInfo{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    // 设置触发通知的时间
    notification.fireDate = fireDate;
    // 时区
    notification.timeZone = [NSTimeZone defaultTimeZone];
    // 设置重复的间隔
    notification.repeatInterval = 0;//0表示不重复
    // 通知内容
    notification.alertBody = message;
    notification.alertAction =  @"查看";
    notification.applicationIconBadgeNumber = 1;
    // 通知被触发时播放的声音
    notification.soundName = UILocalNotificationDefaultSoundName;
    // 设置通知的相关信息，这个很重要，可以添加一些标记性内容，方便以后区分和获取通知的信息
    notification.userInfo = userInfo;
    // 执行通知注册
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    
}

/**
 *  取消通知
 *
 *  @return
 */
+ (void)cancelLocalNotificationWithKey:(NSString *)key {
    // 获取所有本地通知数组
    NSArray *localNotifications = [UIApplication sharedApplication].scheduledLocalNotifications;
    
    for (UILocalNotification *notification in localNotifications) {
        NSDictionary *userInfo = notification.userInfo;
        if (userInfo) {
            // 根据设置通知参数时指定的key来获取通知参数
            NSString *info = userInfo[key];
            
            // 如果找到需要取消的通知，则取消
            if (info != nil) {
                [[UIApplication sharedApplication] cancelLocalNotification:notification];
                break;
            }
        }
    }
}

/**
 *  检查通知
 */
+ (BOOL)checkLocalNotificationWithKey:(NSString *)key
{
    // 获取所有本地通知数组
    NSArray *localNotifications = [UIApplication sharedApplication].scheduledLocalNotifications;
    
    for (UILocalNotification *notification in localNotifications) {
        NSDictionary *userInfo = notification.userInfo;
        if (userInfo) {
            // 根据设置通知参数时指定的key来获取通知参数
            NSString *info = userInfo[key];
            
            // 如果找到说明有该通知
            if (info != nil) {
                return YES;
            }
        }
    }
    return NO;
}

@end
