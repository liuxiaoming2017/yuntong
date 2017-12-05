//
//  LocalNotificationManager.h
//  NewPodcast
//
//  Created by Julian on 16/7/20.
//  Copyright © 2016年 NewPodcast. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocalNotificationManager : NSObject

+ (void)configLocalNotificationWithFireDate:(NSDate *)fireDate alertMessage:(NSString *)message userInfo:(NSDictionary *)userInfo;

+ (void)cancelLocalNotificationWithKey:(NSString *)key;

+ (BOOL)checkLocalNotificationWithKey:(NSString *)key;

@end
