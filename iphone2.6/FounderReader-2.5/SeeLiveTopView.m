//
//  SeeLiveTopView.m
//  FounderReader-2.5
//
//  Created by yanbf on 16/10/17.
//
//

#import "SeeLiveTopView.h"

#import "DirectFram.h"
#import "SeeMethod.h"
#import "UIView+Extention.h"
#import "SeeViewmodel.h"
#import "TopDiscussmodel.h"
#import "LocalNotificationManager.h"
#import "AppStartInfo.h"
#import "NSString+Helper.h"
#import "FileLoader.h"
#import "ColumnBarConfig.h"
#import "UIDevice-Reachability.h"
#import "YXLoginViewController.h"
#import "UIImageView+WebCache.h"
#import "LiveSteamModel.h"
#import "Global.h"
#import "UIAlertView+Helper.h"
#import "NSString+TimeStringHandler.h"
#import "NSMutableAttributedString + Extension.h"

#define maxHeightForTitle 70



#define kZXVideoPlayerOriginalWidth  MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)
#define kZXVideoPlayerOriginalHeight (kZXVideoPlayerOriginalWidth * (9.0 / 16.0))

#define kZXPlayerControlViewHideNotification @"ZXPlayerControlViewHideNotification"

static const CGFloat kVideoControlBarHeight = 40.0; // 上下bar的高度
static const CGFloat kVideoControlAnimationTimeInterval = 0.3;// 隐藏动画速度
static const CGFloat kVideoControlTimeLabelFontSize = 10.0; // 时间文字的大小
static const CGFloat kVideoControlTitleLabelFontSize = 15.0; // 标题文字的大小
static const CGFloat kVideoControlBarAutoFadeOutTimeInterval = 3.0; //自动隐藏时间

@interface SeeLiveTopView ()

@property (nonatomic, strong) UIView *liveRemindView;// 提醒视图
@property (nonatomic, strong) UILabel *liveingJoinLable; // 直播时的参与人数
@property (nonatomic, strong) UILabel *remindLable;
@property (nonatomic, strong) UIView *alertView;
@property (nonatomic, strong) UILabel *alertLable;
@property (nonatomic, strong) UIButton *alertBtn;
@property (nonatomic, strong) UIImageView *topBar;
@property (nonatomic, strong) UIView *bottomBar;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UIButton *pauseButton;
@property (nonatomic, strong) UIButton *fullScreenButton;
@property (nonatomic, strong) UIButton *shrinkScreenButton;
@property (nonatomic, strong) UISlider *progressSlider;
@property (nonatomic, strong) UIButton *remindBtn;
@property (nonatomic, strong) UIProgressView *bufferProgressView;// 缓冲进度条
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, assign) BOOL isBarShowing;
@property (nonatomic, assign) BOOL isFullscreenMode;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic,assign) BOOL isVertical;


@end

@implementation SeeLiveTopView
@synthesize seePlayer,remindBtn,remindLable;

-(void)creatTopView
{
    [self creatTopView:self.discussModel andSteam:self.steamModel];
}

// 添加顶部视图(图文or视频/直播)
-(void)creatTopView:(TopDiscussmodel *)topmodel andSteam:(LiveSteamModel *)steam{
    UIImageView *topImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kSWidth, kLiveImageTextViewH)];
    topImageView.tag = 661;
    [topImageView sd_setImageWithURL:[NSURL URLWithString:[topmodel.picImage stringByAppendingString:@"@!md31"]] placeholderImage:[Global getBgImage31]];
    topImageView.contentMode = UIViewContentModeScaleAspectFill;
    topImageView.clipsToBounds = YES;
    topImageView.frame = CGRectMake(0, 0, kSWidth, CGRectGetMaxY(topImageView.frame));
    
    if (self.steamModel.isLiveVideoType == NO) {// 图文
        [self addSubview:topImageView];
        
        // 图文提醒
        self.liveRemindView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSWidth, kLiveImageTextViewH)];
        self.liveRemindView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
        self.topBar.alpha = 0.0;
        self.bottomBar.alpha = 0.0;
        [self addLiveRemindView];
    }
    else if (self.steamModel.isLiveVideoType == YES) {// 视频
        topImageView.frame = self.bounds;
        [self.alertView addSubview:topImageView];
        UIView *view = [[UIView alloc] initWithFrame:self.bounds];
        view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.7];
        [self.alertView addSubview:view];
        self.liveRemindView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSWidth, kLiveVideoViewH)];
        
        [self addLiveVideoView];
        [self addSubview:seePlayer.playerView];
        
    }
}

#pragma mark - 直播相关
/// slider value changed
- (void)progressSliderValueChanged:(UISlider *)slider
{
    double totalTime = CMTimeGetSeconds(seePlayer.totalDuration);
    double currentTime = slider.value*totalTime;
    CMTime time = CMTimeMakeWithSeconds(currentTime, 1);
    [seePlayer seekTo:time];
    [seePlayer play];
    [self setTimeLabelValues:currentTime totalTime:totalTime];
}

//MARK- 播放进度
/// 监听播放进度
- (void)monitorVideoPlayback
{
    
    double currentTime = CMTimeGetSeconds(seePlayer.currentTime);
    double totalTime = CMTimeGetSeconds(seePlayer.totalDuration);
    
    CMTime durationV = seePlayer.totalDuration;
    CMTime currentV = seePlayer.currentTime;
    if(durationV.flags != kCMTimeFlags_Valid && currentV.flags != kCMTimeFlags_Valid)
        return;
    
    // 更新时间
    [self setTimeLabelValues:currentTime totalTime:totalTime];
    // 更新播放进度
    self.progressSlider.value = currentTime / totalTime;
    
}
/// 更新播放时间显示
- (void)setTimeLabelValues:(double)currentTime totalTime:(double)totalTime {
    
    NSString *timeElapsedString = nil;
    NSUInteger dCurrentSeconds = currentTime;
    NSUInteger dHours1 = floor(dCurrentSeconds / 3600); //时
    NSUInteger dMinutes1 = floor(dCurrentSeconds % 3600 / 60); //分
    NSUInteger dSeconds1 = floor(dCurrentSeconds % 3600 % 60); // 秒
    if (dHours1) {
        timeElapsedString = [NSString stringWithFormat:@"%02lu:%02lu:%02lu", (unsigned long)dHours1, (unsigned long)dMinutes1, (unsigned long)dSeconds1];
    }
    else {
        timeElapsedString = [NSString stringWithFormat:@"%02lu:%02lu",(unsigned long)dMinutes1, (unsigned long)dSeconds1];
    }
    if (dSeconds1 != 00) {
        [self.indicatorView stopAnimating];
    }else if (dSeconds1 == 00  && seePlayer.status == PLPlayerStatusPlaying) {
        [self.indicatorView startAnimating];
    }
    
    NSString *timeRmainingString = nil;
    NSUInteger dTotalSeconds = totalTime;
    NSUInteger dHours = floor(dTotalSeconds / 3600); //时
    NSUInteger dMinutes = floor(dTotalSeconds % 3600 / 60); //分
    NSUInteger dSeconds = floor(dTotalSeconds % 3600 % 60); // 秒
    if (dHours) {
        timeRmainingString = [NSString stringWithFormat:@"%02lu:%02lu:%02lu", (unsigned long)dHours, (unsigned long)dMinutes, (unsigned long)dSeconds];
    }
    else {
        timeRmainingString = [NSString stringWithFormat:@"%02lu:%02lu",(unsigned long)dMinutes, (unsigned long)dSeconds];
    }
    self.timeLabel.text = [NSString stringWithFormat:@"%@/%@",timeElapsedString,timeRmainingString];
    
}

/// 开启定时器
- (void)startDurationTimer
{
    
    if (self.durationTimer) {
        [self.durationTimer setFireDate:[NSDate date]];
    } else {
        self.durationTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(monitorVideoPlayback) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.durationTimer forMode:NSRunLoopCommonModes];
    }
}
/// 暂停定时器
- (void)stopDurationTimer
{
    [_durationTimer invalidate];
     [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
//    if (_durationTimer) {
//        [self.durationTimer setFireDate:[NSDate distantFuture]];
//    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (!self.isVertical) {
        seePlayer.playerView.frame = self.bounds;
    }
    
    self.topBar.frame = CGRectMake(CGRectGetMinX(self.bounds), CGRectGetMinY(self.bounds), CGRectGetWidth(self.bounds), kVideoControlBarHeight);
    
    self.bottomBar.frame = CGRectMake(CGRectGetMinX(self.bounds), CGRectGetHeight(self.bounds) - kVideoControlBarHeight, CGRectGetWidth(self.bounds), kVideoControlBarHeight);
    
    self.playButton.frame = CGRectMake(CGRectGetMinX(self.bottomBar.bounds), CGRectGetHeight(self.bottomBar.bounds)/2 - CGRectGetHeight(self.playButton.bounds)/2, CGRectGetWidth(self.playButton.bounds), CGRectGetHeight(self.playButton.bounds));
    
    self.pauseButton.frame = self.playButton.frame;
    
    self.fullScreenButton.frame = CGRectMake(CGRectGetWidth(self.bottomBar.bounds) - CGRectGetWidth(self.fullScreenButton.bounds), CGRectGetHeight(self.bottomBar.bounds)/2 - CGRectGetHeight(self.fullScreenButton.bounds)/2, CGRectGetWidth(self.fullScreenButton.bounds), CGRectGetHeight(self.fullScreenButton.bounds));
    
    self.shrinkScreenButton.frame = self.fullScreenButton.frame;
    
    self.progressSlider.frame = CGRectMake(CGRectGetMaxX(self.playButton.frame), 0, CGRectGetMinX(self.fullScreenButton.frame) - CGRectGetMaxX(self.playButton.frame), kVideoControlBarHeight);
    
    self.liveingJoinLable.frame = self.progressSlider.frame;
    
    self.timeLabel.frame = CGRectMake(CGRectGetMidX(self.progressSlider.frame), CGRectGetHeight(self.bottomBar.bounds) - CGRectGetHeight(self.timeLabel.bounds) - 2.0, CGRectGetWidth(self.progressSlider.bounds)/2, CGRectGetHeight(self.timeLabel.bounds));
    
    self.indicatorView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    
    // 缓冲进度条
    self.bufferProgressView.bounds = CGRectMake(0, 0, self.progressSlider.bounds.size.width - 7, self.progressSlider.bounds.size.height);
    self.bufferProgressView.center = CGPointMake(self.progressSlider.center.x + 2, self.progressSlider.center.y);
    //     标题
    self.titleLabel.frame = CGRectMake(10, 12, kSWidth-20, 15);
    
    seePlayer.playerView.userInteractionEnabled = YES;
    [self addSubview:self.topBar];
    [self addSubview:self.bottomBar];
    [self.bottomBar addSubview:self.playButton];
    [self.bottomBar addSubview:self.pauseButton];
    [self.bottomBar addSubview:self.fullScreenButton];
    [self.bottomBar addSubview:self.shrinkScreenButton];
    [self.bottomBar addSubview:self.progressSlider];
    [self.bottomBar addSubview:self.liveingJoinLable];
    [self.bottomBar addSubview:self.timeLabel];
    [self addSubview:self.indicatorView];

    [self.bottomBar insertSubview:self.bufferProgressView belowSubview:self.progressSlider];
    [self.topBar addSubview:self.titleLabel];
    self.alertView.frame = self.bounds;
    [self addSubview:self.alertView];
    
    self.alertLable.frame = CGRectMake(0, self.centerY-70, CGRectGetWidth(self.bounds), 70);
    self.alertBtn.frame = CGRectMake(0, CGRectGetMaxY(self.alertLable.frame), 80, 30);
    self.alertBtn.centerX = self.centerX;
    [self.alertView addSubview:self.alertLable];
    [self.alertView addSubview:self.alertBtn];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.isBarShowing = YES;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
        [self addGestureRecognizer:tapGesture];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(autoFadeOutControlBar) name:@"AutoHideBarViews" object:nil];
        
    }
    return self;
}

- (NSMutableAttributedString *)attributedString:(NSString *)string {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
    [attributedString setLineSpacing:7];
    return attributedString;
}

//MARK: 初始化播放器
- (void)addLiveVideoView {
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    PLPlayerOption *option = [PLPlayerOption defaultOption];
    [option setOptionValue:@10 forKey:PLPlayerOptionKeyTimeoutIntervalForMediaPackets];
    
    seePlayer.delegateQueue = dispatch_get_main_queue();
  
//    // 更改需要修改的 option 属性键所对应的值——用默认！
//    [option setOptionValue:@15 forKey:PLPlayerOptionKeyTimeoutIntervalForMediaPackets];
//    [option setOptionValue:@1000 forKey:PLPlayerOptionKeyMaxL1BufferDuration];
//    [option setOptionValue:@1000 forKey:PLPlayerOptionKeyMaxL2BufferDuration];
//    [option setOptionValue:@(kPLLogInfo) forKey:PLPlayerOptionKeyLogLevel];
//    [option setOptionValue:[QNDnsManager new] forKey:PLPlayerOptionKeyDNSManager];
    
    
    /* 10.3号七牛给的demo里并没有配置, 但是测试后发现, 在真机测试的时候, 还是打开的时候性能比较好
     但是在模拟器上的时候, 要把这个关闭, 崩溃次数太多 */
#if TARGET_IPHONE_SIMULATOR//模拟器
    XYLog(@"模拟器");
#elif TARGET_OS_IPHONE//真机
    [option setOptionValue:@(YES) forKey:PLPlayerOptionKeyVideoToolbox];
    // 有的真机只有声音没画面，avplayer兼容性没FFmpeg好
    [option setOptionValue:@(YES) forKey:PLPlayerOptionKeyVODFFmpegEnable];
#endif
    
    seePlayer.playerView.backgroundColor = [UIColor blackColor];
    // 测试地址
    // self.playURL = @"http://www.w3school.com.cn/i/movie.mp4"; //短
    // self.playURL = @"http://play.68mtv.com:8080/play1/5961.mp4"; //长
    if (self.steamModel.disabled) {
        seePlayer = [PLPlayer playerLiveWithURL:[NSURL URLWithString:self.steamModel.rmtpUrl] option:option];
        self.progressSlider.hidden = YES;
        self.timeLabel.hidden = YES;
        self.liveingJoinLable.hidden = NO;
        
        self.alertLable.attributedText = [self attributedString:NSLocalizedString(@"直播进入休息阶段，\n请稍后点击播放哦！",nil)];
        _alertLable.textAlignment = NSTextAlignmentCenter;
        self.alertView.hidden = NO;
        self.alertBtn.hidden = NO;
    }
    //正在直播
    else if (self.isLiveVideoType && self.steamModel.playStatus == 2) {
        seePlayer = [PLPlayer playerLiveWithURL:[NSURL URLWithString:self.steamModel.rmtpUrl] option:option];
        self.progressSlider.hidden = YES;
        self.timeLabel.hidden = YES;
        self.liveingJoinLable.hidden = NO;
        if (![UIDevice networkAvailable]) {
            self.alertLable.attributedText = [self attributedString:NSLocalizedString(@"没有可用的网络数据，\n请联网后重试",nil)];
            _alertLable.textAlignment = NSTextAlignmentCenter;
            self.alertView.hidden = NO;
            self.alertBtn.hidden = YES;
        }
        if ([UIDevice activeWLAN]) {
            self.alertLable.attributedText = [self attributedString:NSLocalizedString(@"直播进入休息阶段，\n请稍后点击播放哦！",nil)];
            self.alertBtn.hidden = NO;
            _alertLable.textAlignment = NSTextAlignmentCenter;
            [self playBtnClick];
        }
        if ([UIDevice activeWWAN]) {
            self.alertLable.attributedText = [self attributedString:NSLocalizedString(@"您当前使用的是移动网络，\n播放将产生流量费用。",nil)];
            _alertLable.textAlignment = NSTextAlignmentCenter;
            self.alertView.hidden = NO;
            self.alertBtn.hidden = NO;
        }
    }
    // 直播回顾
    if (self.steamModel.playStatus == 3 && self.steamModel.playbackUrl != nil) {
        
        seePlayer = [[PLPlayer alloc] initWithURL:[NSURL URLWithString:self.steamModel.playbackUrl] option:option];
        self.progressSlider.hidden = YES;
        self.timeLabel.hidden = YES;
        self.liveingJoinLable.hidden = NO;
        if (![UIDevice networkAvailable]) {
            self.alertLable.attributedText = [self attributedString:NSLocalizedString(@"没有可用的网络数据，\n请联网后重试",nil)];
            _alertLable.textAlignment = NSTextAlignmentCenter;
            self.alertView.hidden = NO;
            self.alertBtn.hidden = YES;
        }
        if ([UIDevice activeWLAN]) {
            self.alertLable.attributedText = [self attributedString:NSLocalizedString(@"\n点击屏幕  重新加载",nil)];
            _alertLable.textAlignment = NSTextAlignmentCenter;
            [self playBtnClick];
        }
        if ([UIDevice activeWWAN]) {
            self.alertLable.attributedText = [self attributedString:NSLocalizedString(@"您当前使用的是移动网络，\n播放将产生流量费用。",nil)];
            _alertLable.textAlignment = NSTextAlignmentCenter;
            self.alertView.hidden = NO;
            self.alertBtn.hidden = NO;
        }
    }
    // 设定代理 (optional)
    seePlayer.delegate = self;
    // 自动重连
    seePlayer.autoReconnectEnable = NO;
}

- (void)addLiveRemindView {
    
    CGFloat remindLableX = 0;
    CGFloat remindLableH = 15;
    CGFloat remindBtnH = 28;
    CGFloat remindLableY = (kLiveVideoViewH - (remindLableH + remindBtnH + 20)) / 2;
    if (self.isLiveVideoType == NO) {
        remindLableY = (kLiveImageTextViewH - (remindLableH + remindBtnH + 20)) / 2;
    }
    CGFloat remindLableW = kSWidth;
    CGFloat remindBtnW = 95;
    CGFloat remindBtnX = (kSWidth - remindBtnW) / 2;
    CGFloat remindBtnY = remindLableY + remindLableH + 20;
    
    // 直播提醒标题
    remindLable = [[UILabel alloc] initWithFrame:CGRectMake(remindLableX, remindLableY, remindLableW, remindLableH)];
    
    remindLable.font = [UIFont systemFontOfSize:15];
    remindLable.textColor = [UIColor whiteColor];
    remindLable.textAlignment = NSTextAlignmentCenter;
    
    // 直播提醒按钮
    remindBtn = [[UIButton alloc] initWithFrame:CGRectMake(remindBtnX, remindBtnY, remindBtnW, remindBtnH)];
    remindBtn.backgroundColor = [ColumnBarConfig sharedColumnBarConfig].column_all_color;
    if (self.liveRemindStatus == nil) {
        [remindBtn setTitle:NSLocalizedString(@"开启提醒",nil) forState:UIControlStateNormal];
        [remindBtn setTitle:NSLocalizedString(@"开启提醒",nil) forState:UIControlStateHighlighted];
    }else if ([self.liveRemindStatus isEqualToString:NSLocalizedString(@"开启提醒",nil)]) {
        [remindBtn setTitle:NSLocalizedString(@"开启提醒",nil) forState:UIControlStateNormal];
        [remindBtn setTitle:NSLocalizedString(@"开启提醒",nil) forState:UIControlStateHighlighted];
    }else if ([self.liveRemindStatus isEqualToString:NSLocalizedString(@"已开启提醒",nil)]) {
        [remindBtn setTitle:NSLocalizedString(@"已开启提醒",nil) forState:UIControlStateNormal];
        [remindBtn setTitle:NSLocalizedString(@"已开启提醒",nil) forState:UIControlStateHighlighted];
    }
    
    remindBtn.tintColor = [UIColor whiteColor];
    remindBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    remindBtn.layer.cornerRadius = 14;
    remindBtn.layer.masksToBounds = YES;
    [remindBtn addTarget:self action:@selector(openOrNotLiveRemindClick) forControlEvents:UIControlEventTouchUpInside];
    
    // 直播参与人数
    CGFloat liveJoinLableH = 12;
    CGFloat liveJoinLableY = kLiveVideoViewH - liveJoinLableH - 10;
    if (self.isLiveVideoType == NO) {
        liveJoinLableY = kLiveImageTextViewH - liveJoinLableH - 10;
    }
    CGFloat liveJoinLableW = kSWidth - 10;
    CGFloat liveJoinLableX = 0;
    UILabel *liveJoinLable = [[UILabel alloc] initWithFrame:CGRectMake(liveJoinLableX, liveJoinLableY, liveJoinLableW, liveJoinLableH)];
    liveJoinLable.textColor = [UIColor whiteColor];
    liveJoinLable.text = [NSString stringWithFormat:@"%ld%@",self.articleInfoModel.countClick,NSLocalizedString(@"人参与",nil)];
    liveJoinLable.textAlignment = NSTextAlignmentRight;
    liveJoinLable.font = [UIFont systemFontOfSize:12];
    
    
    [self addSubview:self.liveRemindView]; // 添加直播提醒
    
    [self.liveRemindView addSubview:remindLable];
    [self.liveRemindView addSubview:remindBtn];
    [self.liveRemindView addSubview:liveJoinLable];
    self.liveRemindView.hidden = YES; // 默认隐藏
    [self setSignData:self.articleInfoModel];
}

// 分隔即将直播的时间
- (void)setSignData:(LiveArticleInfoModel *)articleInfoModel
{
    NSString *startDateTimeStr = nil;
    NSString *endDateTimeStr = nil;
    
    if ([NSString isNilOrEmpty:articleInfoModel.liveStartTime]
        || [NSString isNilOrEmpty:articleInfoModel.liveEndTime]) {
        
        return ;
    }else{
        startDateTimeStr = articleInfoModel.liveStartTime;
        endDateTimeStr = articleInfoModel.liveEndTime;
    }
    // 筛出已结束的稿件
    if ([startDateTimeStr isLaterThanNowWithDateFormat:TimeToMinutes]){
        
        remindLable.text = [NSString stringWithFormat:@"%@: %@ - %@",NSLocalizedString(@"本次直播时间",nil), [startDateTimeStr timeStringForLive], [endDateTimeStr timeStringForLive]];
        self.liveRemindView.hidden = NO;
        
    }
    
}

// 实现 <PLPlayerDelegate> 来控制流状态的变更
- (void)player:(nonnull PLPlayer *)player statusDidChange:(PLPlayerStatus)state {
    
    // 这里会返回流的各种状态，你可以根据状态做 UI 定制及各类其他业务操作
    // 除了 Error 状态，其他状态都会回调这个方法
    if (state == PLPlayerStatusPaused) {
        [player pause];
        self.playButton.hidden = NO;
        self.pauseButton.hidden = YES;
        [self.indicatorView stopAnimating];
    }
    if (state == PLPlayerStatusPreparing) {
        XYLog(@"正在准备播放组件");
        [self.indicatorView startAnimating];
    }
    if (state == PLPlayerStatusReady) { //刚进来
        self.isBarShowing = YES;
        //        [self autoFadeOutControlBar];
        [self animateHide];
        XYLog(@"准备完成,开始播放");
    }
    if (state == PLPlayerStatusCaching) { //3
        XYLog(@"推流中断");
        [self.indicatorView startAnimating];
        
    }
    if (state == PLPlayerStateAutoReconnecting) {
        XYLog(@"正在重新连接");
        [self.indicatorView startAnimating];
    }
    if (state == PLPlayerStatusStopped) {
        XYLog(@"播放停止");
        self.playButton.hidden = NO;
        self.pauseButton.hidden = YES;
        if (self.isFullscreenMode) {
            [self changeToOrientation:UIDeviceOrientationPortrait];
            if (self.isVertical) {
                [self shrinkScreenButtonClick];
            }
        }
        [self stopDurationTimer];
        //        [self animateShow];
        [self.indicatorView stopAnimating];
        double totalTime = CMTimeGetSeconds(seePlayer.totalDuration);
        [self setTimeLabelValues:0 totalTime:totalTime];
        self.progressSlider.value = 0.0;
    }
    if (state == PLPlayerStatusPlaying) { //4
        self.fullScreenButton.userInteractionEnabled = YES;
        XYLog(@"播放中...");
        // 开启定时器
       [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
        self.isVertical = seePlayer.width < seePlayer.height;
        if (self.isVertical) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"KScreenRotates" object:nil userInfo:@{@"canRotate":@"NO"}];
        }else{
             [[NSNotificationCenter defaultCenter] postNotificationName:@"KScreenRotates" object:nil userInfo:@{@"canRotate":@"YES"}];
        }
        if (!self.isFullscreenMode&&self.isVertical) {
            CGFloat width = kLiveVideoViewH * seePlayer.width/seePlayer.height;
            seePlayer.playerView.bounds = CGRectMake(0, 0, width, kLiveVideoViewH);
            seePlayer.playerView.center = CGPointMake(kSWidth*0.5, kLiveVideoViewH * 0.5);
        }
        [self.indicatorView stopAnimating];
    }
    
    if (seePlayer.playing) {
        self.alertView.hidden = YES;
    }
}

- (void)player:(nonnull PLPlayer *)player stoppedWithError:(nullable NSError *)error {
    // 当发生错误时，会回调这个方法
    XYLog(@"没有播放的错误是%@",error);

   if (![UIDevice networkAvailable]) {
        XYLog(@"断网了");
       self.alertLable.attributedText = [self attributedString:NSLocalizedString(@"没有可用的网络数据，\n请联网后重试",nil)];
       _alertLable.textAlignment = NSTextAlignmentCenter;
        self.alertView.hidden = NO;
       self.alertBtn.hidden = YES;
        [self stopBtnClick];
        [self.indicatorView stopAnimating];
       
    }else {
        NSString *urlString = [NSString stringWithFormat:@"%@/api/getLiveList?sid=%@&id=%d&lastFileID=0&rowNumber=0&aid=%d",[AppConfig sharedAppConfig].serverIf, [AppConfig sharedAppConfig].sid, self.article.linkID,self.article.fileId];
        FileLoader *request = [FileLoader fileLoaderWithUrl:urlString];
        [request setCompletionBlock:^(NSData *data) {
            NSDictionary *dataArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers  error:nil];
            NSDictionary *main = [dataArray valueForKey:@"main"];
            NSDictionary *liveStream = [main valueForKey:@"liveStream"];
            self.steamModel.disabled = [[liveStream valueForKey:@"disabled"] integerValue];
            if (self.steamModel.disabled == 1) {// 后台禁止推流
                self.alertLable.attributedText = [self attributedString:NSLocalizedString(@"直播进入休息阶段，\n请稍后点击播放哦！",nil)];
                _alertLable.textAlignment = NSTextAlignmentCenter;
                self.alertView.hidden = NO;
                self.alertBtn.hidden = NO;
            }else { // 推流段中断
                self.alertLable.attributedText = [self attributedString:NSLocalizedString(@"\n点击屏幕  重新加载",nil)];
                _alertLable.textAlignment = NSTextAlignmentCenter;
                self.alertView.hidden = NO;
                self.alertBtn.hidden = YES;
            }
            [self.indicatorView stopAnimating];
        }];
        [request setFailedBlock:^(NSError *error) {
//            [Global hideTip];
//            [Global showTipNoNetWork];
        }];
        
        [request startAsynchronous];
    }
}

//MARK: 点击事件
- (void)alertBtnClick {
    self.alertView.hidden = YES;
    self.alertBtn.hidden = YES;
    [self playBtnClick];
}

- (void)playBtnClick{
    
    if (![UIDevice networkAvailable]) {
        self.alertView.hidden = NO;
        self.alertBtn.hidden = NO;
        self.alertLable.attributedText = [self attributedString:NSLocalizedString(@"没有可用的网络数据，\n请联网后重试",nil)];
        _alertLable.textAlignment = NSTextAlignmentCenter;
        return;
    }
    NSString *urlString = [NSString stringWithFormat:@"%@/api/getLiveList?sid=%@&id=%d&lastFileID=0&rowNumber=0&aid=%d",[AppConfig sharedAppConfig].serverIf, [AppConfig sharedAppConfig].sid, self.article.linkID,self.article.fileId];
    FileLoader *request = [FileLoader fileLoaderWithUrl:urlString];
    [request setCompletionBlock:^(NSData *data) {
        NSDictionary *dataArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers  error:nil];
        NSDictionary *main = [dataArray valueForKey:@"main"];
        NSDictionary *liveStream = [main valueForKey:@"liveStream"];
        self.steamModel.disabled = [[liveStream valueForKey:@"disabled"] integerValue];
        if (self.steamModel.disabled == 1) {
            self.alertView.hidden = NO;
            self.alertBtn.hidden = NO;
        }else {
            if (seePlayer.status == PLPlayerStatusPaused) {
                [seePlayer resume];
            }else if (seePlayer.status == PLPlayerStatusUnknow || seePlayer.status == PLPlayerStatusStopped){
                if (self.steamModel.playStatus == 3 && self.steamModel.playbackUrl != nil) {
                    [self startDurationTimer];
                    self.progressSlider.hidden = NO;
                    self.timeLabel.hidden = NO;
                    self.liveingJoinLable.hidden = YES;
                }
                [seePlayer play];
                [self.indicatorView startAnimating];
            }
            
            if (seePlayer.status == PLPlayerStatusError) {
                [seePlayer play];
            }
            self.alertView.hidden = YES;
            self.playButton.hidden = YES;
            self.pauseButton.hidden = NO;
        }
        [self.indicatorView stopAnimating];
    }];
    [request setFailedBlock:^(NSError *error) {
        //            [Global hideTip];
        //            [Global showTipNoNetWork];
    }];
    
    [request startAsynchronous];
}

-(void)stopBtnClick{
    if (seePlayer.status == PLPlayerStatusReady) {
        [seePlayer stop];
        
    }else {
        [seePlayer pause];
    }
    self.playButton.hidden = NO;
    self.pauseButton.hidden = YES;
    [self.indicatorView stopAnimating];
}

/**
 *  开启或关闭直播提醒
 */
- (void)openOrNotLiveRemindClick
{
    NSString *notiKey = [NSString stringWithFormat:@"%@%d", kLiveRemindNotificationKey, self.aid];
    if ([remindBtn.titleLabel.text isEqualToString:NSLocalizedString(@"已开启提醒",nil)] && [LocalNotificationManager checkLocalNotificationWithKey:notiKey]) {
        [UIAlertView showAlert:NSLocalizedString(@"直播提醒已关闭", nil)];
        [remindBtn setTitle:NSLocalizedString(@"开启提醒", nil) forState:UIControlStateNormal];[remindBtn setTitle:NSLocalizedString(@"开启提醒", nil) forState:UIControlStateHighlighted];
        [LocalNotificationManager cancelLocalNotificationWithKey:notiKey];
    }else {
        [UIAlertView showAlert:NSLocalizedString(@"直播提醒开启成功", nil)];
        [remindBtn setTitle:NSLocalizedString(@"已开启提醒", nil) forState:UIControlStateNormal];
        [remindBtn setTitle:NSLocalizedString(@"已开启提醒", nil) forState:UIControlStateHighlighted];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        NSDictionary *userInfo = @{notiKey:@"直播提醒",
                                   @"fileID":[NSString stringWithFormat:@"%d",self.aid],
                                   @"linkID":[NSString stringWithFormat:@"%d",self.fileid],
                                   @"articleType":[NSString stringWithFormat:@"%d",self.articleType],
                                   @"title":self.title};
        // 检查本地通知
        [LocalNotificationManager configLocalNotificationWithFireDate:[formatter dateFromString:self.articleInfoModel.liveStartTime] alertMessage:[NSString stringWithFormat:@"%@：%@",NSLocalizedString(@"您订阅的直播即将开始",nil), self.title]  userInfo:userInfo];
    }
}

- (void)onTap:(UITapGestureRecognizer *)gesture
{
    
    if (!self.steamModel.isLiveVideoType) {
        return;
    }
    if (gesture.state == UIGestureRecognizerStateRecognized) {
        if (self.isBarShowing) {
            [self animateHide];
        } else {
            [self animateShow];
            // 显示状态栏
            // [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimcation:UIStatusBarAnimationFade];
        }
    }
    if (self.alertView.hidden == NO) {
        [self playBtnClick];
    }
}

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    self.isBarShowing = YES;
}

- (void)animateHide
{
    if (!self.isBarShowing) {
        return;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kZXPlayerControlViewHideNotification object:nil];
    
    [UIView animateWithDuration:kVideoControlAnimationTimeInterval animations:^{
        self.topBar.alpha = 0.0;
        self.bottomBar.alpha = 0.0;
    } completion:^(BOOL finished) {
        self.isBarShowing = NO;
    }];
}

- (void)animateShow
{
    if (self.isBarShowing) {
        return;
    }
    [UIView animateWithDuration:kVideoControlAnimationTimeInterval animations:^{
        self.topBar.alpha = 1.0;
        self.bottomBar.alpha = 1.0;
    } completion:^(BOOL finished) {
        self.isBarShowing = YES;
        [self autoFadeOutControlBar];
    }];
}

- (void)autoFadeOutControlBar
{
    if (!self.isBarShowing) {
        return;
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(animateHide) object:nil];
    [self performSelector:@selector(animateHide) withObject:nil afterDelay:kVideoControlBarAutoFadeOutTimeInterval];
}

- (void)cancelAutoFadeOutControlBar
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(animateHide) object:nil];
}

// 横屏
- (void)fullScreenButtonClick {
    if (self.isFullscreenMode) {
        return;
    }
    
    if (self.isVertical) {
        self.bottomBar.alpha = 0;
        [UIView animateWithDuration:0.25 animations:^{
            seePlayer.playerView.frame = CGRectMake(0, 0, kSWidth, kSHeight);
            [self layoutIfNeeded];
        } completion:^(BOOL finished) {
           self.frame = CGRectMake(0, 0, kSWidth, kSHeight);
            self.bottomBar.alpha = 1;
        }];
    }
    
    if (seePlayer.status == PLPlayerStatusPlaying) {
        self.playButton.hidden = YES;
        self.pauseButton.hidden = NO;
    }
    // 手动切换屏幕
    
    [self configDeviceOrientationObserver];
    appDelegate().isAllOrientation = YES;
    [self changeToOrientation:UIDeviceOrientationLandscapeLeft];
    self.fullScreenButton.hidden = YES;
    self.shrinkScreenButton.hidden = NO;
    self.isFullscreenMode = YES;
}
// 竖屏
- (void)shrinkScreenButtonClick {
    if (!self.isFullscreenMode) {
        return;
    }
    appDelegate().isAllOrientation = NO;
    if (self.isVertical && self.isFullscreenMode) {
        self.frame = CGRectMake(0, 0, kSWidth, kLiveVideoViewH);
        CGFloat width = kLiveVideoViewH * seePlayer.width/seePlayer.height;
        self.bottomBar.alpha = 0;
        [UIView animateWithDuration:0.25 animations:^{
            seePlayer.playerView.bounds = CGRectMake(0, 0, width, kLiveVideoViewH);
            seePlayer.playerView.center = CGPointMake(kSWidth*0.5, kLiveVideoViewH * 0.5);
            [self layoutIfNeeded];
        } completion:^(BOOL finished) {
           self.bottomBar.alpha = 1.0;
        }];
    }
    if (!self.isVertical) {
        [self changeToOrientation:UIDeviceOrientationPortrait];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    self.isFullscreenMode = NO;
    if (self.isVertical) {
        self.fullScreenButton.hidden = NO;
        self.shrinkScreenButton.hidden = YES;
    }
}


/// MARK: 设备方向

/// 设置监听设备旋转通知
- (void)configDeviceOrientationObserver
{
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onDeviceOrientationDidChange)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

/// 设备旋转方向改变
- (void)onDeviceOrientationDidChange
{
    UIDeviceOrientation orientation = self.getDeviceOrientation;
    if (self.isVertical) {
        return;
    }else{
        
        switch (orientation) {
            case UIDeviceOrientationPortrait: {           // Device oriented vertically, home button on the bottom
                XYLog(@"home键在 下");
                [self restoreOriginalScreen];
                appDelegate().isAllOrientation = NO;
                [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
            }
                break;
            case UIDeviceOrientationPortraitUpsideDown: { // Device oriented vertically, home button on the top
                XYLog(@"home键在 上");
            }
                break;
            case UIDeviceOrientationLandscapeLeft: {      // Device oriented horizontally, home button on the right
                XYLog(@"home键在 右");
                [self changeToFullScreenForOrientation:UIDeviceOrientationLandscapeLeft];
            }
                break;
            case UIDeviceOrientationLandscapeRight: {     // Device oriented horizontally, home button on the left
                XYLog(@"home键在 左");
                [self changeToFullScreenForOrientation:UIDeviceOrientationLandscapeRight];
            }
                break;
            default:
                break;
        }
    }
    
}

-(void)changeToVerticalFullScreen{
    if (self.videoPlayerWillChangeToOriginalScreenModeBlock) {
        self.videoPlayerWillChangeToOriginalScreenModeBlock();
    }
    [self layoutSubviews];
    self.isFullscreenMode = YES;
    self.fullScreenButton.hidden = YES;
    self.shrinkScreenButton.hidden = NO;
}
/// 切换到全屏模式
- (void)changeToFullScreenForOrientation:(UIDeviceOrientation)orientation
{
    if (self.isFullscreenMode) {
        return;
    }
    
    if (self.videoPlayerWillChangeToOriginalScreenModeBlock) {
        self.videoPlayerWillChangeToOriginalScreenModeBlock();
    }
    
    self.frame = [UIScreen mainScreen].bounds;
    
    self.isFullscreenMode = YES;
    self.fullScreenButton.hidden = YES;
    self.shrinkScreenButton.hidden = NO;
}

/// 切换到竖屏模式
- (void)restoreOriginalScreen
{
    if (!self.isFullscreenMode) {
        return;
    }
    
    if ([UIApplication sharedApplication].statusBarHidden) {
        //[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    }
    
    if (self.videoPlayerWillChangeToOriginalScreenModeBlock) {
        self.videoPlayerWillChangeToOriginalScreenModeBlock();
    }
    
    self.frame = CGRectMake(0, 20, kZXVideoPlayerOriginalWidth, kZXVideoPlayerOriginalHeight);
    
    self.isFullscreenMode = NO;
    self.fullScreenButton.hidden = NO;
    self.shrinkScreenButton.hidden = YES;
    
}

/// 手动切换设备方向
- (void)changeToOrientation:(UIDeviceOrientation)orientation
{
     if (self.isVertical) {
         [self changeToVerticalFullScreen];
         return;
     }
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val = orientation;
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}

- (UIDeviceOrientation)getDeviceOrientation
{
    return [UIDevice currentDevice].orientation;
}


#pragma mark - 懒加载

- (UIImageView *)topBar
{
    if (!_topBar) {
        _topBar = [UIImageView new];
        _topBar.accessibilityIdentifier = @"TopBar";
        _topBar.image = [UIImage imageNamed:@"live-top-shadow"];
    }
    return _topBar;
}

- (UIView *)bottomBar
{
    if (!_bottomBar) {
        _bottomBar = [UIView new];
        _bottomBar.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
    }
    return _bottomBar;
}

- (UIButton *)playButton
{
    if (!_playButton) {
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playButton setImage:[UIImage imageNamed:@"live-playBtn-icon"] forState:UIControlStateNormal];
        _playButton.bounds = CGRectMake(0, 0, kVideoControlBarHeight, kVideoControlBarHeight);
        [_playButton addTarget:self action:@selector(playBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playButton;
}

- (UIButton *)pauseButton
{
    if (!_pauseButton) {
        _pauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_pauseButton setImage:[UIImage imageNamed:@"live-stopBtn-icon"] forState:UIControlStateNormal];
        _pauseButton.bounds = CGRectMake(0, 0, kVideoControlBarHeight, kVideoControlBarHeight);
        [_pauseButton addTarget:self action:@selector(stopBtnClick) forControlEvents:UIControlEventTouchUpInside];
        _pauseButton.hidden = YES;
    }
    return _pauseButton;
}

- (UIButton *)fullScreenButton
{
    if (!_fullScreenButton) {
        _fullScreenButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_fullScreenButton setImage:[UIImage imageNamed:@"live-fullScreenButton-icon"] forState:UIControlStateNormal];
        [_shrinkScreenButton setImage:[UIImage imageNamed:@"live-live-fullScreenButton-icon"] forState:UIControlStateHighlighted];
        _fullScreenButton.bounds = CGRectMake(0, 0, kVideoControlBarHeight, kVideoControlBarHeight);
        _fullScreenButton.userInteractionEnabled = NO;
        [_fullScreenButton addTarget:self action:@selector(fullScreenButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _fullScreenButton;
}

- (UIButton *)shrinkScreenButton
{
    if (!_shrinkScreenButton) {
        _shrinkScreenButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_shrinkScreenButton setImage:[UIImage imageNamed:@"live-shrinkScreenButton-icon"] forState:UIControlStateNormal];
        [_shrinkScreenButton setImage:[UIImage imageNamed:@"live-shrinkScreenButton-icon"] forState:UIControlStateHighlighted];
        _shrinkScreenButton.bounds = CGRectMake(0, 0, kVideoControlBarHeight, kVideoControlBarHeight);
        [_shrinkScreenButton addTarget:self action:@selector(shrinkScreenButtonClick) forControlEvents:UIControlEventTouchUpInside];
        _shrinkScreenButton.hidden = YES;
    }
    return _shrinkScreenButton;
}

- (UISlider *)progressSlider
{
    if (!_progressSlider) {
        _progressSlider = [[UISlider alloc] init];
        [_progressSlider setThumbImage:[UIImage imageNamed:@"live-player-point"] forState:UIControlStateNormal];
        [_progressSlider setMinimumTrackTintColor:[UIColor whiteColor]];
        [_progressSlider setMaximumTrackTintColor:[[UIColor lightGrayColor] colorWithAlphaComponent:0.4]];
        _progressSlider.minimumValue = 0;
        _progressSlider.continuous = YES;
        _progressSlider.hidden = NO; //默认隐藏
        
        [_progressSlider addTarget:self action:@selector(progressSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _progressSlider;
}

- (UIProgressView *)bufferProgressView
{
    if (!_bufferProgressView) {
        _bufferProgressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        _bufferProgressView.progressTintColor = [UIColor colorWithWhite:1 alpha:0.6];
        _bufferProgressView.trackTintColor = [UIColor clearColor];
    }
    return _bufferProgressView;
}

- (UILabel *)liveingJoinLable {
    if (!_liveingJoinLable) {
        _liveingJoinLable = [[UILabel alloc] init];
        _liveingJoinLable.font = [UIFont systemFontOfSize:14];
        _liveingJoinLable.textColor = [UIColor whiteColor];
        
        _liveingJoinLable.text = [NSString stringWithFormat:@"%ld%@",self.articleInfoModel.countClick,NSLocalizedString(@"人参与",nil)];
        if (!self.articleInfoModel.countClick) {
            _liveingJoinLable.text = [NSString stringWithFormat:@"0%@",NSLocalizedString(@"人参与",nil) ];
        }
        _liveingJoinLable.hidden = YES;
    }
    return _liveingJoinLable;
}

- (UILabel *)timeLabel
{
    if (!_timeLabel) {
        _timeLabel = [UILabel new];
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.font = [UIFont systemFontOfSize:kVideoControlTimeLabelFontSize];
        _timeLabel.textColor = [UIColor whiteColor];
        _timeLabel.textAlignment = NSTextAlignmentRight;
        _timeLabel.bounds = CGRectMake(0, 0, kVideoControlTimeLabelFontSize, kVideoControlTimeLabelFontSize);
        _timeLabel.text = @"00:00/24:00";
    }
    return _timeLabel;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.font = [UIFont systemFontOfSize:kVideoControlTitleLabelFontSize];
        _titleLabel.text = self.title;
    }
    return _titleLabel;
}

- (UIActivityIndicatorView *)indicatorView
{
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [_indicatorView stopAnimating];
    }
    return _indicatorView;
}

- (UIView *)alertView {
    if (!_alertView) {
        _alertView = [[UIView alloc] init];
        _alertView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1.0];
        _alertView.hidden = YES; //默认隐藏
    }
    return _alertView;
}

- (UILabel *)alertLable {
    if (!_alertLable) {
        _alertLable = [[UILabel alloc] init];
        
        _alertLable.textColor = [UIColor whiteColor];
        _alertLable.attributedText = [self attributedString:NSLocalizedString(@"\n点击屏幕  重新加载",nil)];
        _alertLable.numberOfLines = 0;
        _alertLable.textAlignment = NSTextAlignmentCenter;
    }
    return _alertLable;
}
- (UIButton *)alertBtn {
    if (!_alertBtn) {
        
        _alertBtn = [[UIButton alloc] init];
        [_alertBtn setTitle:@"点击播放" forState:UIControlStateNormal];
        [_alertBtn addTarget:self action:@selector(alertBtnClick) forControlEvents:UIControlEventTouchUpInside];
        _alertBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        _alertBtn.layer.cornerRadius = 5;
        _alertBtn.layer.masksToBounds = YES;
        [_alertBtn.layer setBorderColor:[UIColor whiteColor].CGColor];//边框颜色
        [_alertBtn.layer setBorderWidth:1.0]; //边框宽度
        _alertBtn.hidden = YES;
    }
    return _alertBtn;
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"KScreenRotates" object:nil userInfo:@{@"canRotate":@"NO"}];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}
@end
