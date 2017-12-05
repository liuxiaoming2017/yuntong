//
//  SeeLiveTopView.h
//  FounderReader-2.5
//
//  Created by yanbf on 16/10/17.
//
//

#import <UIKit/UIKit.h>
#import "SeeViewmodel.h"
#import "TopDiscussmodel.h"
#import "LiveSteamModel.h"
#import "LiveArticleInfoModel.h"
#import "PLPlayerKit.h"
#import "HappyDNS.h"
#import "Article.h"

@interface SeeLiveTopView : UIView<PLPlayerDelegate>


@property (nonatomic, strong) Article *article;
@property (nonatomic, assign) int fileid;
@property (nonatomic, assign) int aid;
@property (nonatomic, assign) int articleType;
@property (nonatomic, retain) SeeViewmodel *mainModel;
@property (nonatomic, retain) TopDiscussmodel *discussModel;
@property (nonatomic, retain) LiveSteamModel *steamModel;
@property (nonatomic, retain) LiveArticleInfoModel *articleInfoModel;
@property (nonatomic, strong) PLPlayer *seePlayer; //七牛播放器
@property (nonatomic, copy) NSString *playURL;
@property (nonatomic, strong) NSTimer *durationTimer;

@property (nonatomic, copy) NSString *playbackUrl;
@property (nonatomic, copy) NSString *rmtpUrl;
@property (nonatomic, assign) BOOL isLiveVideoType;
@property (nonatomic, assign) NSInteger playStatus;

@property (nonatomic, copy) NSString *liveingJoinLableText; //直播参与人数
@property (nonatomic, copy) NSString *title; // 标题
@property (nonatomic, copy) NSString *liveStartTime; //直播开始时间
@property (nonatomic, copy) NSString *liveEndTime; // 结束时间
@property (nonatomic, copy) NSString *liveRemindStatus; // 直播提醒状态
@property (nonatomic, copy) void(^videoPlayerWillChangeToOriginalScreenModeBlock)();// 屏幕切换时,控制视图的隐藏

@property (nonatomic, assign, readonly, getter=getDeviceOrientation) UIDeviceOrientation deviceOrientation; // 设备方向

//- (instancetype)initWithFrame:(CGRect)frame;
- (void)creatTopView;

@end
