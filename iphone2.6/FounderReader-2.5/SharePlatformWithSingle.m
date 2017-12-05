//
//  SharePlatformWithSingle.m
//  FounderReader-2.5
//
//  Created by Julian on 16/8/1.
//
//

#import "SharePlatformWithSingle.h"
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKUI/ShareSDK+SSUI.h>

static id _publishContent;

@implementation SharePlatformWithSingle

+ (void)sharePlatformWithSingle:(int)platformTag Content:(NSString *)content image:image title:(NSString *)title url:(NSString *)url {
    int shareType = 0;
    switch (platformTag) {
        case 1:
            shareType = SSDKPlatformSubTypeWechatTimeline;
            break;
        case 2:
            shareType = SSDKPlatformSubTypeWechatSession;
            break;
        case 3:
            shareType = SSDKPlatformTypeSinaWeibo;
            break;
        case 4:
            shareType = SSDKPlatformSubTypeQZone;
            break;
        case 5:
            shareType = SSDKPlatformTypeQQ;
            break;
        case 6:
            shareType = SSDKPlatformTypeMail;
            break;
        case 7:
            shareType = SSDKPlatformTypeSMS;
            break;
        case 8:
            shareType = SSDKPlatformTypeCopy;
            break;
        default:
            break;
    }
    
    
}

@end
