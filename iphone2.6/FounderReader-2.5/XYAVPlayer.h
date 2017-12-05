//
//  XYAVPlayer.h
//  FounderReader-2.5
//
//  Created by yanbf on 16/9/10.
//
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "Article.h"


typedef NS_ENUM(NSUInteger, XYPlayerStatus) {
    XYPlayerFirstTime, // 首次
    XYPlayerPause, // 暂停
    XYPlayerPlaying, // 播放
};

@interface XYAVPlayer : NSObject

@property (copy, nonatomic) NSString* audioDuration; //播放时长
@property (assign, nonatomic) XYPlayerStatus playingStatus;
@property (strong, nonatomic) NSMutableArray *arrayPlayList; //播放列表
@property (strong, nonatomic) AVPlayer *audioPlayer;
@property (strong, nonatomic) NSMutableArray *playList; //播放列表
@property (nonatomic, assign) BOOL userPause;
+ (instancetype)shareInstance;

- (void)audioPlayOrStop;
// 获取音频总时长
- (NSString *)displayTotalTime;
//把音频文件加入播放列表
- (void)addPlayList:(NSArray *)articles;
//点击播放按钮
- (BOOL)clickPlay:(Article *)article;
//获取当前播放的稿件信息
- (Article *)getCurrentArticle;

@end
