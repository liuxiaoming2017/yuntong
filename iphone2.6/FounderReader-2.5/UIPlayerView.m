//
//  UIPlayerView.m
//  FounderReader-2.5
//
//  Created by mac on 16/9/30.
//
//

#import "UIPlayerView.h"
#import "XYAVPlayer.h"
#import <MediaPlayer/MediaPlayer.h>

static UIPlayerView *_playerView;
@implementation UIPlayerView
@synthesize closeBtnClick, operationBtnClick, titleClick, loadAudioProgress;
@synthesize mp3ClickFinish, voiceClickFinish, voiceClickBegin, currentAudioTime;

// 单例
+ (instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _playerView = [[UIPlayerView alloc] initWithFrame:CGRectMake(0, 0, kSWidth, 1)];
        [[NSNotificationCenter defaultCenter] addObserver:_playerView selector:@selector(audioPause) name:AVAudioSessionInterruptionNotification object:[AVAudioSession sharedInstance]];
    });
    return _playerView;
}


- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
    
        self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.6];
        //播放标题
        _titleBtn = [[UIButton alloc] initWithFrame:CGRectMake(39, 11, kSWidth-129, 34/2)];
        [_titleBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _titleBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        _titleBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [_titleBtn addTarget:self action:@selector(onTitleClick) forControlEvents:UIControlEventTouchUpInside];
        _titleBtn.titleLabel.lineBreakMode =  NSLineBreakByTruncatingTail;
        [self addSubview:_titleBtn];
        //关闭按钮
        _closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(kSWidth-30, 0, 30, 39)];
        [_closeBtn setImage:[UIImage imageNamed:@"closeIcon"] forState:UIControlStateNormal];
        [_closeBtn addTarget:self action:@selector(onCloseBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_closeBtn];
        //控制按钮
        self.playerButton = [[UIButton alloc]initWithFrame:CGRectMake(kSWidth - 70, 0, 30, 39)];
        [self.playerButton setImage:[UIImage imageNamed:@"pause_icon"] forState:UIControlStateNormal];
        [self.playerButton setImage:[UIImage imageNamed:@"playing_icon"] forState:UIControlStateSelected];
        [self.playerButton addTarget:self action:@selector(playerButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.playerButton];
        //播放图标动画
        _hornImageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 11, 17, 17)];//初始化
        _hornImageView.center = CGPointMake(19.5, 19.5);//中心坐标
        NSMutableArray *images = [[NSMutableArray alloc]initWithCapacity:3];
        for (int i=0; i<3; i++) {
            NSString *imageName = [NSString stringWithFormat:@"hornIcon-%d",i+1];
            UIImage *image = [UIImage imageNamed:imageName];
            [images addObject:image];
        }
        _hornImageView.animationImages = images;
        
        //动画的总时长(一组动画坐下来的时间 6张图片显示一遍的总时间)
        _hornImageView.animationDuration = 1;
        _hornImageView.animationRepeatCount = 10000;//动画进行几次结束
        [self addSubview:_hornImageView];
        
        _progress = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 37 , kSWidth, 2)];
        _progress.tintColor = [UIColor colorWithRed:19/255.0 green:183/255.0 blue:246/255.0 alpha:1.0];
        _progress.progress = 0.0;
        [self addSubview:_progress];
       
        //操作按钮
        _operationBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 39, 39)];
        [_operationBtn addTarget:self action:@selector(onOperateBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_operationBtn];
        
        _avTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(onPlayTimer) userInfo:nil repeats:YES];
        
        // 监听下一首的播放
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nextAudioPlay:) name:kClientPlayNextAudioNotificationName object:nil];
        // 监听播放结束
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeAudioViewCilck:) name:kCloseAudioViewNotificationName object:nil];
    }
    return self;
}

-(void)loadPlayerView:(UIView *)view frame:(CGRect)frame{
    
    _curParentView = view;
    [self removeFromSuperview];
    [view addSubview:self];
    self.frame = frame;
    if(self.isAudioPlaying && self.audioStatus != 0){
        self.hidden = NO;
        if(self.audioStatus == 2){
            [_hornImageView startAnimating];
        }
        else if(self.audioStatus == 1){
            [_hornImageView stopAnimating];
            _hornImageView.image = [UIImage imageNamed:@"hornIcon-3"];
        }
    }
    else{
        self.hidden = YES;
    }
}

-(Article *)getCurrentArticle{
    
    return [[XYAVPlayer shareInstance] getCurrentArticle];
}

-(NSString *)getCurrentAudioDuration{
    if(self.currentAudioTime == nil)
        return @"0";
    else
        return self.currentAudioTime;
}

- (void)mp3Click:(Article *)article{
  
    self.isAudioPlaying = YES;
    Article *curArticle = [self getCurrentArticle];
    if(curArticle == nil){
        [XYAVPlayer shareInstance].playingStatus = 0;
        [[XYAVPlayer shareInstance] clickPlay:article];
        self.audioStatus = 1;
        [self mp3ClickStatus:article];
    }
    else if(curArticle.fileId != article.fileId){
        //其他音频切换
        [XYAVPlayer shareInstance].playingStatus = 0;
       BOOL playSuccess = [[XYAVPlayer shareInstance] clickPlay:article];
        self.progress.progress = 0;
        if (playSuccess) {
            self.audioStatus = 0;
        }
        [self mp3ClickStatus:article];
    }
    else{
        if(self.audioStatus == 0){
            [[XYAVPlayer shareInstance] clickPlay:article];
            self.audioStatus = 1;
            [self mp3ClickStatus:article];
        }
        else{
            //当前音频切换状态
            [self onOperateBtnClick];
        }
    }
    if(self.mp3ClickFinish){
        self.mp3ClickFinish(self);
    }
}
//判断稿件是否为音频稿件
-(BOOL)articleIsMp3:(Article *)article{
    
    NSString *urlStr = article.audioUrl;
    if ([NSString isNilOrEmpty:urlStr] || [[urlStr lowercaseString] rangeOfString:@".mp3"].location == NSNotFound) {
        return NO;
    }
    return YES;
}
- (void)mp3ClickStatus:(Article *)article{
    NSString * audioTitle = article.audioTitle;
    if (article.audioTitle == nil || [article.audioTitle isEqualToString:@""]) {
        audioTitle = article.title;
    }
    [_titleBtn setTitle:audioTitle forState:UIControlStateNormal];
    self.hidden = NO;
    if(self.audioStatus == 0){
        self.audioStatus = 2;
        self.playerButton.selected = NO;
        [_hornImageView startAnimating];
    }
    else if(self.audioStatus == 1){
        self.playerButton.selected = NO;
        self.audioStatus = 2;
        [_hornImageView startAnimating];
    }
    else if(self.audioStatus == 2){
        self.playerButton.selected = YES;
        self.audioStatus = 1;
        [_hornImageView stopAnimating];
        _hornImageView.image = [UIImage imageNamed:@"hornIcon-3"];
    }
}

// 点击语音播报
- (void)voiceClick:(Article *)article{
    self.hidden = NO;
    if(self.voiceClickBegin){
        self.voiceClickBegin(self);
    }
    //如果音频正在播放，则暂停
    XYAVPlayer *player = [XYAVPlayer shareInstance];
    if (player.playingStatus != 0) {
        player.playingStatus = 1;
        self.audioStatus = 1;
        [player.audioPlayer pause];
    }

    if (self.voiceStatus == 1) {
        //开始喇叭动画
        [_hornImageView startAnimating];
    }
    else if(self.voiceStatus == 2){
        [_hornImageView stopAnimating];
        _hornImageView.image = [UIImage imageNamed:@"hornIcon-3"];
    }
    NSString * audioTitle = article.audioTitle;
    if (article.audioTitle == nil || [article.audioTitle isEqualToString:@""]) {
        audioTitle = article.title;
    }
    [_titleBtn setTitle:audioTitle forState:UIControlStateNormal];

    if(self.voiceClickFinish){
        self.voiceClickFinish(self);
    }
}
- (void)playerButtonClicked:(UIButton *)button{
    if (button.selected) {
        self.userPause = NO;
        [self audioPlay];
    }else{
        self.userPause = YES;
        [self audioPause];
    }
    button.selected = !button.selected;
    
}
//点击关闭按钮
- (void)onCloseBtnClick {
    
    self.hidden = YES;
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:nil];
    if (self.isVoicePlaying) {
        if (self.voiceStatus != 0) {
            self.voiceStatus = 0;
        }
    }
    XYAVPlayer *player = [XYAVPlayer shareInstance];
    player.playingStatus = 0;
    self.audioStatus = 0;
    self.progress.progress = 0;
    if (player.audioPlayer != nil) {
        [player.audioPlayer.currentItem removeObserver:player forKeyPath:@"status"];
        [player.audioPlayer.currentItem removeObserver:player forKeyPath:@"loadedTimeRanges"];
        player.audioPlayer = nil;
    }
    if(closeBtnClick){
        closeBtnClick(self);
    }
}

- (void)audioPlay {
    XYAVPlayer *player = [XYAVPlayer shareInstance];
    player.userPause = self.userPause;
    if (self.isAudioPlaying) { //音频播放时的喇叭操作
        if (player.playingStatus == 1) {
            [player.audioPlayer play];
            player.playingStatus = 2;
            self.audioStatus = 2;
            [_hornImageView startAnimating];
        }
        if(operationBtnClick){
            operationBtnClick(self);
        }
    }
    
}

- (void)audioPause {
    XYAVPlayer *player = [XYAVPlayer shareInstance];
    player.userPause = self.userPause;
    if (self.isAudioPlaying) { //音频播放时的喇叭操作
        if (player.playingStatus == 2) {
            player.playingStatus = 1;
            self.audioStatus = 1;
            [player.audioPlayer pause];
            [_hornImageView stopAnimating];
            _hornImageView.image = [UIImage imageNamed:@"hornIcon-3"];
        }
        if(operationBtnClick){
            operationBtnClick(self);
        }
    }
}

// 喇叭操作点击事件
- (void)onOperateBtnClick{
    
    if (self.isVoicePlaying) { //云播播放时的喇叭操作
        if (self.voiceStatus == 2){
            // 暂停
            self.voiceStatus = 1;
            [_hornImageView stopAnimating];//停止动画
            _hornImageView.image = [UIImage imageNamed:@"hornIcon-3"];
        }
        else if (self.voiceStatus == 1){
            // 继续
            self.voiceStatus = 2;
            [_hornImageView startAnimating];//开始动画
        }
    }
    
    if (self.isAudioPlaying) { //音频播放时的喇叭操作
        XYAVPlayer *player = [XYAVPlayer shareInstance];
        if (player.playingStatus == 2) {
            player.userPause = YES;
            player.playingStatus = 1;
            self.audioStatus = 1;
            [player.audioPlayer pause];
            [_hornImageView stopAnimating];
            self.playerButton.selected = YES;
            _hornImageView.image = [UIImage imageNamed:@"hornIcon-3"];
        }
        else if (player.playingStatus == 1) {
            player.userPause = NO;
            [player.audioPlayer play];
            player.playingStatus = 2;
            self.audioStatus = 2;
            self.playerButton.selected = NO;
            [_hornImageView startAnimating];
        }
    }
    if(operationBtnClick){
        operationBtnClick(self);
    }
}

// 点击标题
- (void)onTitleClick{
    
    Article *article = [[XYAVPlayer shareInstance] getCurrentArticle];
    if(titleClick && article){
        titleClick(self);
    }
}

// 播放进度
- (void)onPlayTimer {
    XYAVPlayer *player = [XYAVPlayer shareInstance];
    CMTime durationV = player.audioPlayer.currentItem.duration;
    if(durationV.flags != kCMTimeFlags_Valid)
        return;
    NSUInteger dTotalSeconds = CMTimeGetSeconds(durationV);
    NSUInteger dHours = floor(dTotalSeconds / 3600); //时
    NSUInteger dMinutes = floor(dTotalSeconds % 3600 / 60); //分
    NSUInteger dSeconds = floor(dTotalSeconds % 3600 % 60); // 秒
    if (dHours) {
        self.currentAudioTime = [NSString stringWithFormat:@"%02lu:%02lu:%02lu", (unsigned long)dHours, (unsigned long)dMinutes, (unsigned long)dSeconds];
    }
    else {
        self.currentAudioTime = [NSString stringWithFormat:@"%02lu:%02lu",(unsigned long)dMinutes, (unsigned long)dSeconds];
    }

    self.progress.progress = CMTimeGetSeconds(player.audioPlayer.currentItem.currentTime) / CMTimeGetSeconds(player.audioPlayer.currentItem.duration);
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[self getCurrentArticle].title forKey:MPMediaItemPropertyTitle];
    double currentTime = (double)CMTimeGetSeconds(player.audioPlayer.currentItem.currentTime);
    double propertyTime = (double)CMTimeGetSeconds(player.audioPlayer.currentItem.duration);
    [dict setObject:[NSNumber numberWithDouble:propertyTime] forKey:MPMediaItemPropertyPlaybackDuration];
    [dict setObject:[NSNumber numberWithDouble:currentTime] forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
    if (currentTime >= propertyTime) {
        dict = nil;
    }
    [dict setObject:[[MPMediaItemArtwork alloc] initWithImage:[UIImage imageNamed:@"music_background_pic"]]
             forKey:MPMediaItemPropertyArtwork];
    //更新字典
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:dict];
    if(self.loadAudioProgress && self.progress.progress < 1.0){
        self.loadAudioProgress(self);
    }
}

// 播放结束
- (void)closeAudioViewCilck:(NSNotification *)notic {
    NSDictionary *dict = notic.userInfo;
    if ([[dict objectForKey:@"isClose"] isEqualToString:@"yes"]) {
        
        self.isAudioPlaying = NO;
        self.audioStatus = 0;
        self.progress.progress = 0.0;
        self.hidden = YES;
        if(self.loadAudioProgress){
            self.loadAudioProgress(self);
        }
    }
}
// 下一首
- (void)nextAudioPlay:(NSNotification *)notic {
    Article *curArticle = (Article *)notic.object;
    self.audioStatus = 0;
    [self mp3ClickStatus:curArticle];
    self.progress.progress = 0;

}

-(BOOL)isCurrentView:(UIView *)parentView{
    if(parentView == _curParentView)
        return YES;
    else
        return NO;
}

-(void)unLoadBlock{
    self.closeBtnClick = nil;
    self.operationBtnClick = nil;
    self.titleClick = nil;
    self.mp3ClickFinish = nil;
    self.voiceClickFinish = nil;
    self.loadAudioProgress = nil;
    self.isVoicePlaying = NO;
    self.voiceStatus = 0;
}
@end
