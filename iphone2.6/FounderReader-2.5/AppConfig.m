//
//  AppConfig.m
//  FounderReader-2.5
//
//  Created by chenfei on 4/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppConfig.h"
#import "NSString+Helper.h"

static AppConfig *__appConfig = nil;
@interface AppConfig ()
@end

@implementation AppConfig

@synthesize serverIf, appId, isHomeAddSearch, isArticleShowDefaultImage;
@synthesize isTileView,has_startHelpPage,topViewStyle, shareAppLabel;
@synthesize startConfigUrl, isNavigationAddSearch;
@synthesize memberIf;

- (id)init
{
    self = [super init];
    if (self) {
        NSDictionary *appConfigDict = [NSDictionary dictionaryWithContentsOfFile:pathForMainBundleResource(@"app_config.plist")];
        self.tabBarPersonalCenterIcon_normal = [appConfigDict objectForKey:@"tabBarPersonalCenterIcon_normal"];
        self.tabBarPersonalCenterIcon_selected = [appConfigDict objectForKey:@"tabBarPersonalCenterIcon_selected"];
        self.IPV6DelineDate = [appConfigDict objectForKey:@"IPV6DelineDate"];
        self.serverIf = [self checkIPV6Net] ? @"http://h5v6.newaircloud.com" : [appConfigDict objectForKey:@"server_if"];
        self.isHomeAddSearch = [[appConfigDict objectForKey:@"isHomeAddSearch"] boolValue];
        self.isNavigationAddSearch = [[appConfigDict objectForKey:@"isNavigationAddSearch"] boolValue];
        self.isColumnEidtInRight =  [[appConfigDict objectForKey:@"isColumnEidtInRight"] boolValue];
        self.isChangeSearchAtUser = [[appConfigDict objectForKey:@"isChangeSearchAtUser"] boolValue];
        self.isAppearReadCount = [[appConfigDict objectForKey:@"isAppearReadCount"] boolValue];
        self.isLiveAppearReadCount = [[appConfigDict objectForKey:@"isLiveAppearReadCount"] boolValue];
        self.isCarouselAppearReadCount = [[appConfigDict objectForKey:@"isCarouselAppearReadCount"] boolValue];
        self.isCarouselLiveAppearReadCount = [[appConfigDict objectForKey:@"isCarouselLiveAppearReadCount"] boolValue];
        self.isAppearDate = [[appConfigDict objectForKey:@"isAppearDate"] boolValue];
        self.isCarouselAppearDate = [[appConfigDict objectForKey:@"isCarouselAppearDate"] boolValue];
        self.isRightWithThumbnail = [[appConfigDict objectForKey:@"isRightWithThumbnail"] boolValue];
        self.isNewspaperApperCover = [[appConfigDict objectForKey:@"isNewspaperApperCover"] boolValue];
        self.isArticleShowDefaultImage = [[appConfigDict objectForKey:@"isArticleShowDefaultImage"] boolValue];
        self.appId = 1;
        self.isTileView = [[appConfigDict objectForKey:@"is_TileView"] boolValue];
        self.topViewStyle = [[appConfigDict objectForKey:@"topView_style"] intValue];
        self.has_startHelpPage = [[appConfigDict objectForKey:@"has_startHelpPage"] boolValue];
        self.sid = [appConfigDict objectForKey:@"ss_id"];
        //去前后空格和换行符
        self.sid = [self.sid stringByTrimmingCharactersInSet:
                    [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        self.startConfigUrl = [NSString stringWithFormat:@"%@/api/getConfig?sid=%@",self.serverIf,self.sid];
        self.integralName = NSLocalizedString([appConfigDict objectForKey:@"integralName"],nil);
        self.isOpenSpeech = [[appConfigDict objectForKey:@"isOpenSpeech"] boolValue];
        self.isPaperVertical = [[appConfigDict objectForKey:@"isPaperVertical"] boolValue];
        self.initialAnnouncer = [self setupAnnouncer :[appConfigDict objectForKey:@"initialAnnouncer"]];
        self.isShowShareInvitationCode = [[appConfigDict objectForKey:@"isShowShareInvitationCode"] boolValue];
        self.shareAppLabel = [appConfigDict objectForKey:@"shareAppLabel"];
        if(self.shareAppLabel == nil){
            self.shareAppLabel = NSLocalizedString(@"分享给好友",nil);
        }
        else{
            self.shareAppLabel = NSLocalizedString([appConfigDict objectForKey:@"shareAppLabel"],nil);
        }
        self.isHideLogin_QQ = [[appConfigDict objectForKey:@"isHideLogin_QQ"] boolValue];
        self.isHideLogin_WeChat = [[appConfigDict objectForKey:@"isHideLogin_WeChat"] boolValue];
        self.isHideLogin_WeiBo = [[appConfigDict objectForKey:@"isHideLogin_WeiBo"] boolValue];
        self.isNeedBindPhoneNumber = [[appConfigDict objectForKey:@"isNeedBindPhoneNumber"] boolValue];
        self.inviteShareTime = [appConfigDict objectForKey:@"inviteShareTime"];
        
        self.firstTimeNoNetworkAlertTitle = [appConfigDict objectForKey:@"firstTimeNoNetworkAlertTitle"];
        self.firstTimeNoNetworkAlertContent = [appConfigDict objectForKey:@"firstTimeNoNetworkAlertContent"];
        self.isNeedLoginBeforeEnter = [[appConfigDict objectForKey:@"isNeedLoginBeforeEnter"] boolValue];
        self.tabbarIconNormal1 = [appConfigDict objectForKey:@"tabbarIconNormal1"];
        self.tabbarIconNormal2 = [appConfigDict objectForKey:@"tabbarIconNormal2"];
        self.tabbarIconNormal3 = [appConfigDict objectForKey:@"tabbarIconNormal3"];
        self.tabbarIconNormal4 = [appConfigDict objectForKey:@"tabbarIconNormal4"];
        self.tabbarIconNormal5 = [appConfigDict objectForKey:@"tabbarIconNormal5"];
        self.tabbarIconHighlight1 = [appConfigDict objectForKey:@"tabbarIconHighlight1"];
        self.tabbarIconHighlight2 = [appConfigDict objectForKey:@"tabbarIconHighlight2"];
        self.tabbarIconHighlight3 = [appConfigDict objectForKey:@"tabbarIconHighlight3"];
        self.tabbarIconHighlight4 = [appConfigDict objectForKey:@"tabbarIconHighlight4"];
        self.tabbarIconHighlight5 = [appConfigDict objectForKey:@"tabbarIconHighlight5"];
        
        self.defaultAreaCode = [appConfigDict objectForKey:@"defaultAreaCode"];
        self.defaultAreaCountry = [appConfigDict objectForKey:@"defaultAreaCountry"];
        self.isOnlyAliDaYu = [[appConfigDict objectForKey:@"isOnlyAliDaYu"] boolValue];
        
        NSDictionary * thirdParam = [appConfigDict objectForKey:@"thirdParam"];
        self.thirdLoginTime = [thirdParam objectForKey:@"thirdLoginTime"];
        self.kUMengAppKey = [thirdParam objectForKey:@"kUMengAppKey"];
        self.kGtAppId = [thirdParam objectForKey:@"kGtAppId"];
        self.kGtAppKey = [thirdParam objectForKey:@"kGtAppKey"];
        self.kGtAppSecret = [thirdParam objectForKey:@"kGtAppSecret"];
        self.kMobAppKey = [thirdParam objectForKey:@"kMobAppKey"];
        self.kMobQQAppId = [thirdParam objectForKey:@"kMobQQAppId"];
        self.kMobQQAppSecret = [thirdParam objectForKey:@"kMobQQAppSecret"];
        self.kMobWeChatAppId = [thirdParam objectForKey:@"kMobWeChatAppId"];
        self.kMobWeChatAppSecret = [thirdParam objectForKey:@"kMobWeChatAppSecret"];
        self.kMobWeiboAppKey = [thirdParam objectForKey:@"kMobWeiboAppKey"];
        self.kMobWeiboAppSecret = [thirdParam objectForKey:@"kMobWeiboAppSecret"];
        self.kMobWeiboURL = [thirdParam objectForKey:@"kMobWeiboURL"];
        self.kMobSMSAppKey = [thirdParam objectForKey:@"kMobSMSAppKey"];
        self.kMobSMSAppSecret = [thirdParam objectForKey:@"kMobSMSAppSecret"];
        self.kMobFBAppKey = [thirdParam objectForKey:@"kMobFBAppKey"];
        self.kMobFBAppSecret = [thirdParam objectForKey:@"kMobFBAppSecret"];
        self.kIFlyAppId = [thirdParam objectForKey:@"kIFlyAppId"];
        self.kYouZanUserAgeny = [thirdParam objectForKey:@"kYouZanUserAgeny"];
        self.kYouZanLoadUrl = [thirdParam objectForKey:@"kYouZanLoadUrl"];
        self.kMWAppKey = [thirdParam objectForKey:@"kMWAppKey"];
        self.kMWMLinkKey = [thirdParam objectForKey:@"kMWMLinkKey"];
    }
    return self;
}

+ (AppConfig *)sharedAppConfig
{
    if (__appConfig == nil) {
        __appConfig = [[self alloc] init];
    }
    return __appConfig;
}

// 设置初始播音员
- (NSString *)setupAnnouncer:(NSString *)announcerIndex
{
    if ([NSString isNilOrEmpty:announcerIndex]) {
        return @"xiaoyan";
    }
    switch ([announcerIndex intValue]) {
        case 1:
            return @"xiaoyan";
            break;
        case 2:
            return @"xiaoyu";
            break;
        case 3:
            return @"vixm";
            break;
        case 4:
            return @"vixl";
            break;
            
        default:
            return @"xiaoyan";
            break;
    }
}

- (BOOL)checkIPV6Net
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY-MM-dd"];
    
    NSDate *dateEnd = [formatter dateFromString:self.IPV6DelineDate];
    NSTimeInterval timeEnd = [dateEnd timeIntervalSince1970];
    NSTimeInterval timeNow = [[NSDate date] timeIntervalSince1970];
    
    return timeEnd > timeNow;
}

@end
