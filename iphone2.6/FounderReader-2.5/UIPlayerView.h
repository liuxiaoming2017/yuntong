//
//  UIPlayerView.h
//  FounderReader-2.5
//
//  Created by mac on 16/9/30.
//
//

#import <UIKit/UIKit.h>
#import "Article.h"

@interface UIPlayerView : UIView{
    UIButton *_titleBtn;
    UIButton *_closeBtn;
    UIButton *_operationBtn;
    UIImageView *_hornImageView;
    UIProgressView *_progress;
    NSTimer *_avTimer;
    FinishDataBlock _operationBtnClick;
    FinishDataBlock _closeBtnClick;
    FinishDataBlock _titleClick;
    FinishDataBlock _loadAudioFinish;
    FinishDataBlock _mp3ClickFinish;
    FinishDataBlock _voiceClickFinish;
    FinishDataBlock _voiceClickBegin;
    UIView *_curParentView;
}
@property (nonatomic, assign) NSInteger voiceStatus; // 0/1/2 未/暂/播
@property (nonatomic, assign) BOOL isVoicePlaying; //云播报是否在播
@property (nonatomic, assign) NSInteger audioStatus; // 0/1/2 未/暂/播
@property (nonatomic, assign) BOOL isAudioPlaying; //音频是否在播
@property (nonatomic, strong) NSString *currentAudioTime; //音频时间进度
@property (nonatomic, strong) UIProgressView *progress; //进度
@property (nonatomic, strong) UIButton * playerButton;
@property (nonatomic, strong) FinishDataBlock operationBtnClick;
@property (nonatomic, strong) FinishDataBlock closeBtnClick;
@property (nonatomic, strong) FinishDataBlock titleClick;
@property (nonatomic, strong) FinishDataBlock loadAudioProgress;
@property (nonatomic, strong) FinishDataBlock mp3ClickFinish;
@property (nonatomic, strong) FinishDataBlock voiceClickBegin;
@property (nonatomic, strong) FinishDataBlock voiceClickFinish;
@property (nonatomic, assign) BOOL userPause;

@property (nonatomic, assign) BOOL isRightNowPlaying;
+ (instancetype)shareInstance;
//点击音频播放
- (void)mp3Click:(Article *)article;
//点击语音播报
- (void)voiceClick:(Article *)article;
//关闭
- (void)onCloseBtnClick;
//获取当前播放的稿件
- (Article *)getCurrentArticle;
//获取当前播放的音频长度
-(NSString *)getCurrentAudioDuration;
// 加载播放进度
-(void)loadPlayerView:(UIView *)view frame:(CGRect)frame;
-(BOOL)isCurrentView:(UIView *)parentView;
-(void)unLoadBlock;

- (void)audioPlay;
- (void)audioPause;


@end
