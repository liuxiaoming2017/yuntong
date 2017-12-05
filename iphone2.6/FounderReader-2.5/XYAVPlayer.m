//
//  XYAVPlayer.m
//  FounderReader-2.5
//
//  Created by yanbf on 16/9/10.
//
//

#import "XYAVPlayer.h"
#import <MediaPlayer/MediaPlayer.h>

@interface XYAVPlayer () {
    
    // 准备播放第几个
    NSInteger _readyPlayIndex;
    // 当前播放的是第几个
    NSInteger _currentPlayIndex;
    NSInteger _currentArticleID;
    
};
@property (copy, nonatomic) NSString *urlString;
@property (strong, nonatomic) XYAVPlayer *player;
@end

@implementation XYAVPlayer

+ (instancetype)shareInstance {
    static XYAVPlayer *player = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        player = [[XYAVPlayer alloc] init];
        player.playList = [NSMutableArray array];
    });
    return player;
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.audioPlayer.currentItem removeObserver:self forKeyPath:@"status"];
    [self.audioPlayer.currentItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
}



// 在新闻栏目的时候, 点击播放, 走正常逻辑
- (BOOL)clickPlay:(Article *)article {
    //如果不是音频稿件，直接返回
    if(![self articleIsMp3:article])
        return NO;
    //检查当前稿件是否在播放列表
    BOOL isExist = NO;
    for(Article *play in self.playList){
        if(play.fileId == article.fileId){
            isExist = YES;
            break;
        }
    }
    //如果不在播放列表，则加入到播放列表
    if(!isExist){
        [self.playList addObject:article];
    }
    //如果正在播放，则停止播放
    if (self.playingStatus != 0 && isExist) {
        [self audioPlayOrStop];
        return NO;
    }
    //播放当前稿件
    _urlString = article.audioUrl;
    _currentArticleID = article.fileId;
    
    //加入后台模式
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    [audioSession setActive:YES error:nil];
    if (self.audioPlayer != nil) {
        [self.audioPlayer.currentItem removeObserver:self forKeyPath:@"status"];
        [self.audioPlayer.currentItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
        self.audioPlayer = nil;
    }
    // 初始化播放器
    NSString * audioStr = [article.audioUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    self.audioPlayer = [AVPlayer playerWithURL:[NSURL URLWithString:audioStr]];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0){
       self.audioPlayer.automaticallyWaitsToMinimizeStalling = NO;
    }
    [self.audioPlayer play];
    self.playingStatus = 2;

    //控制中心显示项
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:article.title forKey:MPMediaItemPropertyTitle];
    //更新字典
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:dict];
    
    // 先移除上次的通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    // 播放结束发送通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dequeueReusable:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    // 添加观察者, 监听播放状态
    
    [self.audioPlayer.currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [self.audioPlayer.currentItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    return YES;
}

//判断稿件是否为音频稿件
-(BOOL)articleIsMp3:(Article *)article{
    
    NSString *urlStr = article.audioUrl;
    if ([NSString isNilOrEmpty:urlStr] || [[urlStr lowercaseString] rangeOfString:@".mp3"].location == NSNotFound) {
        return NO;
    }
    return YES;
}
// 添加到播放列表
- (void)addPlayList:(NSArray *)articles{

        for (NSInteger i = 0; i < articles.count; i++) {
            Article * article = articles[i];
            if (![self.playList containsObject:article]) {
                [self.playList addObject:article];
            }
        }
//    for (Article * article in articles) {
//       
//        if (![self articleIsMp3:article]) {
//            continue;
//        }
//        BOOL isExist = NO;
//        for(Article *play in self.playList){
//            if(play.fileId == article.fileId){
//                isExist = YES;
//                break;
//            }
//        }
//        if(!isExist){
//            [self.playList addObject:article];
//        }
//    }
}
//获取当前播放的稿件信息
-(Article *)getCurrentArticle{
    for(Article *play in self.playList){
        if(play.fileId == _currentArticleID){
            return play;
        }
    }
    return nil;
}

- (NSString *)displayTotalTime
{
    //AVURLAsset *audioAVURLAsset = [AVURLAsset assetWithURL:[NSURL URLWithString:_urlString]];
    //CMTime durationV = audioAVURLAsset.duration;
    CMTime durationV = _audioPlayer.currentItem.duration;
    NSUInteger dTotalSeconds = CMTimeGetSeconds(durationV);
    NSUInteger dHours = floor(dTotalSeconds / 3600); //时
    NSUInteger dMinutes = floor(dTotalSeconds % 3600 / 60); //分
    NSUInteger dSeconds = floor(dTotalSeconds % 3600 % 60); // 秒
    NSString *audioDurationText = nil;
    if (dHours) {
        audioDurationText = [NSString stringWithFormat:@"%02lu:%02lu:%02lu", (unsigned long)dHours, (unsigned long)dMinutes, (unsigned long)dSeconds];
    }
    else {
        audioDurationText = [NSString stringWithFormat:@"%02lu:%02lu",(unsigned long)dMinutes, (unsigned long)dSeconds];
    }

    XYLog(@"%@",audioDurationText);
    
    return audioDurationText;
}

/*判断正在播放的下一首是否是音频稿件；不是就退出播放, 不往下判断*/
- (void)dequeueReusable:(NSNotification *)n {
    
    NSInteger currentPlayIndex = 0;
    for(Article *article in self.playList){
        
        if(_currentArticleID == article.fileId){
            break;
        }
        currentPlayIndex++;
    }
    [self.audioPlayer.currentItem removeObserver:self  forKeyPath:@"status"];
    [self.audioPlayer.currentItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    
    if(currentPlayIndex >= self.playList.count-1){
        // 当没有音频稿件的时候 发送通知
        [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:nil];
        _currentArticleID = -1;
        [self.audioPlayer replaceCurrentItemWithPlayerItem:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:kCloseAudioViewNotificationName object:nil userInfo:@{@"isClose" : @"yes"}];
        if (self.audioPlayer != nil) {
            self.audioPlayer = nil;
        }
        return;
    }
    Article *nextArticle = self.playList[currentPlayIndex+1];
    if (![self articleIsMp3:nextArticle]) {
        [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:nil];
        _currentArticleID = -1;
        [self.audioPlayer replaceCurrentItemWithPlayerItem:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:kCloseAudioViewNotificationName object:nil userInfo:@{@"isClose" : @"yes"}];
        if (self.audioPlayer != nil) {
            self.audioPlayer = nil;
        }
        return;
    }
    _currentArticleID = nextArticle.fileId;
    NSString * audioStr = [nextArticle.audioUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    AVPlayerItem *item = [[AVPlayerItem alloc] initWithURL:[NSURL URLWithString:audioStr]];
    [self.audioPlayer replaceCurrentItemWithPlayerItem:item];
    [self.audioPlayer.currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [self.audioPlayer.currentItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    [self.audioPlayer play];
    // 播放下一首的时候发送通知
    [[NSNotificationCenter defaultCenter] postNotificationName:kClientPlayNextAudioNotificationName object:nextArticle userInfo:nil];
   
}

// 播放暂停
- (void)audioPlayOrStop {
    
    if (self.playingStatus == 2) {
        [_audioPlayer pause];
        self.playingStatus = 1;
        
    }else if (self.playingStatus == 1) {
        self.playingStatus = 2;
        [_audioPlayer play];
    }
}

- (void)audioPlay {
    self.playingStatus = 2;
    [_audioPlayer play];
}

- (void)audioPause {
    [_audioPlayer pause];
    self.playingStatus = 1;
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    AVPlayerItem * songItem = object;
    if ([keyPath isEqualToString:@"status"]) {
        switch (self.audioPlayer.status) {
            case AVPlayerStatusUnknown:
                NSLog(@"未知状态，此时不能播放");
                break;
            case AVPlayerStatusReadyToPlay:
                NSLog(@"准备完毕，可以播放");
                break;
            case AVPlayerStatusFailed:
                NSLog(@"加载失败，网络或者服务器出现问题");
                break;
            default:
                break;
        }
    }else if([keyPath isEqualToString:@"loadedTimeRanges"]) {
        NSArray * array = songItem.loadedTimeRanges;
        CMTimeRange timeRange = [array.firstObject CMTimeRangeValue]; //本次缓冲的时间范围
        NSTimeInterval totalBuffer = CMTimeGetSeconds(timeRange.start) + CMTimeGetSeconds(timeRange.duration); //缓冲总长度
        NSLog(@"共缓冲%.2f",totalBuffer);
        NSLog(@"总长度%.2f",CMTimeGetSeconds(songItem.duration));
        XYLog(@"%d---%d",[self isPlaying],self.userPause);
        if (![self isPlaying] && !self.userPause) {
            [self.audioPlayer play];
        }
    }
}
- (Boolean)isPlaying
{
    if([[UIDevice currentDevice] systemVersion].intValue>=10){
        return self.audioPlayer.timeControlStatus == AVPlayerTimeControlStatusPlaying;
    }else{
        return self.audioPlayer.rate==1;
    }
}
@end
