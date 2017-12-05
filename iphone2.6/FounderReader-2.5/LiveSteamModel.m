//
//  liveSteamModel.m
//  FounderReader-2.5
//
//  Created by yanbf on 2016/10/18.
//
//

#import "LiveSteamModel.h"

@implementation LiveSteamModel


+ (instancetype)steamFromDiction:(NSDictionary *)dict {
    
    return [[self alloc] initSteamWithDict:dict];

}

- (instancetype)initSteamWithDict:(NSDictionary *)dict {
    if (self == [super init]) {
        
        if (![dict isKindOfClass:[NSNull class]]) {
            self.rmtpUrl = [dict objectForKey:@"rtmpUrl"];
            self.playbackUrl = [dict objectForKey:@"playbackUrl"];
            self.playStatus = [[dict objectForKey:@"playStatus"] integerValue];
            self.disabled = [[dict objectForKey:@"disabled"] integerValue];
            // 直播地址或者回顾地址存在任意一个就是视频
            if ((self.playStatus == 3 && self.playbackUrl != nil) || (self.rmtpUrl != nil && self.playStatus == 2)) {
                self.isLiveVideoType = YES;
            }
            else { // 否则显示图文
                self.isLiveVideoType = NO;
            }
        }
        
    }
    return self;
}




- (void)setValue:(id)value forUndefinedKey:(NSString *)key{}

@end
