//
//  Defines.h
//  FounderReader-2.5
//
//  Created by chenfei on 4/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef FounderReader_2_5_Defines_h
#define FounderReader_2_5_Defines_h

#define appUpdateVersion    @"appUpdate_version"

#ifdef DEBUG
#define XYLog(...) NSLog(__VA_ARGS__)
#else
#define XYLog(...)
#endif

#define kSmallImage     2
#define kMiddleImage    3
#define kBigImage       1

#define kInformTypeInform   1
#define kInformTypeFeedback 2

#define kSmallFont  12
#define kMiddleFont 14
#define kBigFont    16
#define kBigFont1    18
#define kBigFont2    18
#define kFontStep   2

#define kPhoneNumberRegExp @"(^1[3-9][0-9]{9})"
#define kEmailAddressRegExp @"(^[_A-Za-z0-9-]+(\\.[_A-Za-z0-9-]+)*@[A-Za-z0-9]+(\\.[A-Za-z0-9]+)*(\\.[A-Za-z]{2,}))"

#define kDBName @"xy_reader_new16.db"  //如果数据库结构变化，记得修改kLastColumn_RefreshTime的版本号，否则由于记住上次刷新时间，新更新的应用在刷新时间间隔未到之前是不刷新新闻列表的
#define kLastColumn_RefreshTime @"column_refreshtime37"
#define kTemplateName @"template.zip"


#define kUmengShareEmail    @"share_email"
#define kUmengShareWeibo    @"share_weibo"
#define kUmengFavorite      @"favorite"

//测滑用
#define kConfigItemIndex    @"configItemIndex"
#define kCurrentColumnCount @"currentColumnCount"
#define kCurrentColumnIndex @"currentColumnIndex"

// 视频直播的H
#define kLiveVideoViewH kSWidth * 9 / 16
// 图文直播的H
#define kLiveImageTextViewH kSWidth/3

#define KchangeUserIconNotification @"changeUserIconNotification" //用户头像更新通知key
#define KchangeUserInfoNotification @"changeUserInfoNotification" //用户信息更新通知key

#endif

#define iOS8 [[UIDevice currentDevice].systemVersion floatValue] > 8.0 ? 1 : 0
//iphone5
//#ifndef IS_IPHONE
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_6P (IS_IPHONE && [[UIScreen mainScreen] bounds].size.width == 414.0f)
#define IS_IPHONE_6 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.width == 375.0f)
#define IS_IPHONE_5 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0f)
#define IS_IPHONE_4 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 480.0f)
//#endif

#define iPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)

#define kWindow [UIApplication sharedApplication].keyWindow
#define kSWidth  [UIScreen mainScreen].bounds.size.width
#define kSHeight [UIScreen mainScreen].bounds.size.height
#define kTabBarHeight (iPhoneX ? 83 : 49)
#define kNavBarHeight (iPhoneX ? 88 : 64)
#define kNavHeight 44
#define kStatusBarHeight (iPhoneX ? 44 : 20)
#define XaddHeight (iPhoneX ? 24 : 0)
#define kScale kSWidth/375.0
#define kHScale kSHeight/667.0
#define proportion kSWidth/320.0
#define liveCellContentW kSWidth - 30
#define liveProportion (kSWidth-64)/256.0
#define kRandomColor [UIColor colorWithRed:(arc4random()%256)/255.0f green:(arc4random()%256)/255.0f blue:(arc4random()%256)/255.0f alpha:1]
#define UCTabisShow YES
//已经读过的稿件集合
#define kSaveIsReadFileName             @"saveIsReadDicFile"
#define kSaveSpecialIsReadFileName      @"saveSpecialIsReadDicFile" //专题

//已经点赞的稿件集合
#define kSaveIsAgreeFileName             @"NJXHsaveIsAgreeDicFile"

//15天重新注册远程通知
#define kLastRmoteNotificationTime  @"LastRmoteNotificationTime"
#define kfifteenDaySeconds 15*24*60*60

//评论内容字体
#define CONTENT_FONT 13

//本地栏目定位城市
#define kPrePositionCity                            @"PrePositionCity"
#define kpositionCity                               @"positionCity"
#define kpositionCityColumnName                     @"positionCityColumnName"
#define kpositionCityColumnId                       @"positionCityColumnId"
#define kpositionCityDefaultColumnName              @"positionCityDefaultColumnName"
#define kpositionCityDefaultColumnId                @"positionCityDefaultColumnId"
#define kpositionCityCustomerColumnName             @"positionCityCustomerColumnName"
#define kpositionCityCustomerColumnId               @"positionCityCustomerColumnId"
#define kpositionCityCustomerColumnImageUrl         @"positionCityCustomerColumnImageUrl"

//本地推送
#define kLiveRemindNotificationKey @"LiveRemindNotificationKey"
#define kOpenLiveDetailNotificationName @"OpenLiveDetailNotification"
#define kClientPlayNextAudioNotificationName @"clientPlayNextAudio"
#define kCloseAudioViewNotificationName @"closeAudioView"


