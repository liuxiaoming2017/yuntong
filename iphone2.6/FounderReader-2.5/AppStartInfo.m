//
//  AppStartInfo.m
//  FounderReader-2.5
//
//  Created by ld on 15-7-15.
//
//

#import "AppStartInfo.h"
#import "NSString+Helper.h"
#import "AppConfig.h"
#import "Article.h"

static AppStartInfo *__appStartInfo = nil;

@implementation AppStartInfo

@synthesize columnsPlistDic, founderBDAppID, founderBDUrl;

@synthesize startPages;

@synthesize mallUrl;
@synthesize adArticle;



+ (AppStartInfo *)sharedAppStartInfo
{
    if (__appStartInfo == nil) {
        __appStartInfo = [[self alloc] init];
    }
    return __appStartInfo;
}

- (void)configWithDictionary:(NSDictionary *)dict
{
    if (dict == nil)
    {
        return;
    }
    
    //    新空云
    self.startPages = [dict objectForKey:@"adv"];
    self.appVersion = [dict objectForKey:@"iOSVer"];
    self.appDownloadUrl = [dict objectForKey:@"iOSUrl"];
    self.iOSDes = [dict objectForKey:@"iOSDes"];
    self.contentTemplate = [dict objectForKey:@"templateUrl"];
    self.appName = [dict objectForKey:@"appName"];
    self.forceUpdate = [[dict objectForKey:@"forceUpdate"] intValue];
    self.founderBDAppID = [NSString stringFromNil:[dict objectForKey:@"founderBDAppID"]];
    self.founderBDUrl = [NSString stringFromNil:[dict objectForKey:@"founderBDUrl"]];
    self.webUrl = [dict objectForKey:@"webUrl"];
    self.officialIcon = [dict objectForKey:@"officialIcon"];
    //个人中心相关信息
    self.mallUrl = [NSString stringFromNil:[dict objectForKey:@"mallUrl"]];
    self.configUrl = [NSString stringFromNil:[dict objectForKey:@"configUrl"]];
    self.ucTabisShow = [[dict objectForKey:@"ucTabisShow"] boolValue];
    self.ucTabPosition = [[dict objectForKey:@"ucTabPosition"] integerValue];
    self.ucTabString = [dict objectForKey:@"ucTabString"];
    self.ucTabIcon = [dict objectForKey:@"ucTabIcon"];
    self.siteId = 1;
    
    self.adArticle = [Article articleFromDict:[dict objectForKey:@"article"]];
    [AppConfig sharedAppConfig].memberIf = [NSString stringFromNil:[dict objectForKey:@"memberCenterUrl"]];
    
}
@end
