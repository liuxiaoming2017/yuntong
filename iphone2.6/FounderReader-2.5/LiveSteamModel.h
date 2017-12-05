//
//  liveSteamModel.h
//  FounderReader-2.5
//
//  Created by yanbf on 2016/10/18.
//
//

#import <Foundation/Foundation.h>

@interface LiveSteamModel : NSObject

/**直播流信息*/

/**是否是视频直播*/
@property (nonatomic, assign) BOOL isLiveVideoType;

@property (nonatomic, copy) NSString *rmtpUrl; // RTMP播放地址
@property (nonatomic, copy) NSString *playbackUrl;// 回顾的播放地址
/**
 如果liveStream为空的话，表示该场直播没有直播流，按照正常的图文直播逻辑处理；
 如果playStatus ＝ 1时，表示直播流正在准备中，还未开始视频流直播；
 如果playStatus = 2 时，表示正在直播，点击播放则进行直播；
 如果playStatus = 3时，表示直播已结束，如果有playbackUrl，则点击回放进行播放，如果没有，则按照正常图文直播逻辑处理；
 */
@property (nonatomic, assign) NSInteger playStatus;
@property (nonatomic, assign) NSInteger disabled;


+ (instancetype)steamFromDiction:(NSDictionary *)dict;
- (instancetype)initSteamWithDict:(NSDictionary *)dict;


@end
