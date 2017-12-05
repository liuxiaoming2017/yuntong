//
//  AppConfig.h
//  FounderReader-2.5
//
//  Created by chenfei on 4/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppConfig : NSObject {
    NSString *serverIf;
    int appId;
    BOOL hasAds;
}

@property(nonatomic, retain) NSString *serverIf;
@property(nonatomic, retain) NSString *startConfigUrl;
@property(nonatomic, retain) NSString *sid;
@property(nonatomic, copy) NSString * tabBarPersonalCenterIcon_selected;
@property(nonatomic, copy) NSString * tabBarPersonalCenterIcon_normal;
@property(nonatomic, assign) int appId;
@property(nonatomic, assign) BOOL isTileView;
@property(nonatomic, assign) int topViewStyle;
@property(nonatomic, assign) BOOL isHomeAddSearch;
@property(nonatomic, assign) BOOL isNavigationAddSearch;
@property(nonatomic, assign) BOOL isColumnEidtInRight;
@property(nonatomic, assign) BOOL isChangeSearchAtUser;
@property(nonatomic, assign) BOOL has_startHelpPage;
@property(nonatomic, assign) BOOL isAppearReadCount;
@property(nonatomic, assign) BOOL isLiveAppearReadCount;
@property(nonatomic, assign) BOOL isCarouselAppearReadCount;
@property(nonatomic, assign) BOOL isCarouselLiveAppearReadCount;
@property(nonatomic, assign) BOOL isAppearDate;
@property(nonatomic, assign) BOOL isCarouselAppearDate;
@property(nonatomic, assign) BOOL isRightWithThumbnail;
@property(nonatomic, assign) BOOL isNewspaperApperCover;
@property(nonatomic, retain) NSString *memberIf;
@property(nonatomic, assign) BOOL isArticleShowDefaultImage;//是否显示稿件的默认占位图
@property(nonatomic, copy) NSString *integralName;
@property(nonatomic, assign) BOOL isOpenSpeech;
@property(nonatomic, copy) NSString *initialAnnouncer;
@property(nonatomic, assign) BOOL isShowShareInvitationCode;
@property(nonatomic, copy) NSString *shareAppLabel; //分享好友的标签名字
@property(nonatomic, retain) NSString *kUMengAppKey;// 设置友盟appKey
@property(nonatomic, assign) BOOL isHideLogin_QQ;
@property(nonatomic, assign) BOOL isHideLogin_WeChat;
@property(nonatomic, assign) BOOL isHideLogin_WeiBo;
@property(nonatomic, assign) BOOL isNeedBindPhoneNumber;//是否强制绑定手机号码
@property(nonatomic, retain) NSString *inviteShareTime;
@property(nonatomic, retain) NSString *thirdLoginTime;
@property(nonatomic, retain) NSString *IPV6DelineDate;
// 个推对接参数--GeTuiSdk
@property(nonatomic, retain) NSString *kGtAppId;// 设置app的个推appId
@property(nonatomic, retain) NSString *kGtAppKey;// 设置app的个推appKey
@property(nonatomic, retain) NSString *kGtAppSecret;// 设置app的个推appSecret
// 掌淘Mob对接参数--ShareSDK
@property(nonatomic, retain) NSString *kMobAppKey;// 在ShareSDK官网中注册的应用Key
// QQ
@property(nonatomic, retain) NSString *kMobQQAppId;// QQ应用Key
@property(nonatomic, retain) NSString *kMobQQAppSecret;// QQ应用密钥
// 微信
@property(nonatomic, retain) NSString *kMobWeChatAppId;// 微信应用ID
@property(nonatomic, retain) NSString *kMobWeChatAppSecret;// 微信应用密钥
// 微博
@property(nonatomic, retain) NSString *kMobWeiboAppKey;// 微博应用Key
@property(nonatomic, retain) NSString *kMobWeiboAppSecret;// 微博应用秘钥
@property(nonatomic, retain) NSString *kMobWeiboURL;// 微博应用回调地址
// 短信
@property(nonatomic, retain) NSString *kMobSMSAppKey;// 短信应用Key
@property(nonatomic, retain) NSString *kMobSMSAppSecret;// 短信应用秘钥
// FaceBook
@property(nonatomic, retain) NSString *kMobFBAppKey;// FaceBook应用Key
@property(nonatomic, retain) NSString *kMobFBAppSecret;// FaceBook应用秘钥
// 科大讯飞
@property(nonatomic, retain) NSString *kIFlyAppId;//科大讯飞应用Id
@property(nonatomic, assign) BOOL isPaperVertical;//数字报是否纵向翻页

//有赞商城参数
@property(nonatomic, retain) NSString *kYouZanUserAgeny;// 设置有赞商城用户代理
@property(nonatomic, retain) NSString *kYouZanLoadUrl;// 设置有赞商城网址

/**
 魔窗
 */
@property (copy, nonatomic) NSString *kMWAppKey;
@property (copy, nonatomic) NSString *kMWMLinkKey;

@property (assign, nonatomic) BOOL isNeedLoginBeforeEnter;

@property (copy, nonatomic) NSString *firstTimeNoNetworkAlertTitle;
@property (copy, nonatomic) NSString *firstTimeNoNetworkAlertContent;


@property (copy, nonatomic) NSString *tabbarIconNormal1;
@property (copy, nonatomic) NSString *tabbarIconNormal2;
@property (copy, nonatomic) NSString *tabbarIconNormal3;
@property (copy, nonatomic) NSString *tabbarIconNormal4;
@property (copy, nonatomic) NSString *tabbarIconNormal5;
@property (copy, nonatomic) NSString *tabbarIconHighlight1;
@property (copy, nonatomic) NSString *tabbarIconHighlight2;
@property (copy, nonatomic) NSString *tabbarIconHighlight3;
@property (copy, nonatomic) NSString *tabbarIconHighlight4;
@property (copy, nonatomic) NSString *tabbarIconHighlight5;

@property (copy, nonatomic) NSString *defaultAreaCode;
@property (copy, nonatomic) NSString *defaultAreaCountry;
@property (assign, nonatomic) BOOL isOnlyAliDaYu;

+ (AppConfig *)sharedAppConfig;

@end
