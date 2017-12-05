//
//  TXTexttoSpeechTTS.m
//  test
//
//  Created by Julian on 16/4/5.
//  Copyright © 2016年 . All rights reserved.
//

//  Created by  Julian on 16-4-5.
//  Copyright (c) 2016年. All rights reserved.
//

#import "TXTexttoSpeechTTS.h"
#import "iflyMSC/IFlySpeechError.h"
#import "iflyMSC/IFlySpeechSynthesizer.h"
#import <AVFoundation/AVAudioSession.h>
#import <MediaPlayer/MediaPlayer.h>
#import "AppConfig.h"

@implementation TXTexttoSpeechTTS
{
    //句子集
    NSMutableArray *_sentenceRangeArray;
    
    //当前朗读句子
    NSInteger _readIndex;
    
    //总段落
    NSString *_text;
    
    //是否彻底停止
    BOOL _isStopSpeaking;
}

static TXTexttoSpeechTTS *manager=nil;

-(id)init
{
    if (self=[super init]) {
    }
    return self;
}
+(id)shareManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (manager==nil) {
            manager=[[self alloc]init];
            
        }
    });
    return manager;
}

/**
 *  @brief 播放语音
 *
 *  @param str  播报的文字
 *  @param name 播报的人
 */
- (void)playVoice:(NSString *)str
{
    
    //菊花转呀转~
    //    [Global showTipAlways:@"正在加载..."];
    
    //每一网页播报完之后_isStopSpeaking会被改为yes，再播报的时候需改回来
    _isStopSpeaking = NO;
    
    if ([self isBlankString:str]) {
        if (_delegate && [_delegate respondsToSelector:@selector(loadNewText)]){
            str = [_delegate loadNewText];
        }
    }
    _text = str;
    
    [self initSynthesizer];
    
    [self cutTextToSentenceWithText];
    
    if (_sentenceRangeArray.count > 0) {
        //初始化将阅读句子的位置，从下标是0开始
        _readIndex = 0;
        
        [self startSynBtnHandlerWithReadRange:[_sentenceRangeArray objectAtIndex:_readIndex]];
    }
}

/**
 *  @brief 开始通用合成
 *
 *  @param rangeObj 句子的位置信息
 */
- (void)startSynBtnHandlerWithReadRange:(NSValue *)rangeObj {
    
    if (_delegate && [_delegate respondsToSelector:@selector(addReadingTextBackgroundColor:)]){
        //给当前句子加上背景色
        [_delegate addReadingTextBackgroundColor:rangeObj.rangeValue];
    }
    //暂停当前线程0.05秒
    //    [NSThread sleepForTimeInterval:0.05];
    
    [iFlySpeechSynthesizer startSpeaking:[_text substringWithRange:rangeObj.rangeValue]];
    
    //    [self showIdleInfo];
    
    
}

/**
 *  @breif 界面显示播放信息
 */
- (void)showIdleInfo {
    
    /*后台状态下继续播放音频
     1.设置本应用capabilities-》background modes -》 Audio打钩
     2.设置本应用音频会话的类别
     */
    
    //每个IOS应用都有一个音频会话
    AVAudioSession *session = [AVAudioSession sharedInstance];
    //这个类别会静止其他应用的音频回放。这时，即使屏幕被锁定或者设备为静音模式，音频回放都会继续
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    [session setActive:YES error:nil];
    
    /*锁屏状态下，展示音频信息和锁屏操作音频*/
    //允许应用接收锁屏界面的远程控制点击
    //    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    //展示锁屏音频信息
    [self setLockScreenNowPlayingInfo];
}
/**
 *  @brief 展示锁屏时的歌曲信息
 */
- (void)setLockScreenNowPlayingInfo {
    
    if (NSClassFromString(@"MPNowPlayingInfoCenter")) {//判断兼容
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        
        [dict setObject:@"新空云" forKey:MPMediaItemPropertyTitle];
        [dict setObject:@"播报新闻" forKey:MPMediaItemPropertyArtist];
        [dict setObject:[[MPMediaItemArtwork alloc] initWithImage:[UIImage imageNamed:@"sinaIcon.png"]] forKey:MPMediaItemPropertyArtwork];
        
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:dict];
    }
}

/**
 *  切割文本
 */
- (void)cutTextToSentenceWithText
{
    //初始化数组 严禁用[NSMutableArray array],因为创建的是临时变量，这里有回调，会被回收
    _sentenceRangeArray = [[NSMutableArray alloc] init];
    
    //替换换行符 \u2028一种编码形式的换行分隔符
    _text = [_text stringByReplacingOccurrencesOfString:@"\u2028" withString:@"\n"];
    
    //设定字符串特性对象，用于校正字符串
    //\ufffc为对象占位符,目的是当文本中有图像时,只复制文本信息； \u2028目的是去掉换行符；whitespace去掉首尾空格；Newline：去掉回车\n
    NSMutableCharacterSet *textCharacters = [NSMutableCharacterSet characterSetWithCharactersInString:@"\ufffc\u2028"];
    [textCharacters formUnionWithCharacterSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    //NSStringEnumerationBySentences按句切割
    //NSStringEnumerationLocalized基于本地区的词和句的分界来划分。因为词或句的界线可能基于地区的变化而变化。
    [_text enumerateSubstringsInRange:NSMakeRange(0,_text.length)
                              options:NSStringEnumerationBySentences
                           usingBlock:^(NSString *substring,
                                        NSRange substringRange,
                                        NSRange enclosingRange,
                                        BOOL *stop){//回调回来
                               if ([substring stringByTrimmingCharactersInSet:textCharacters].length > 0) {
                                   //数组只能装对象，将rang封装成对象
                                   [_sentenceRangeArray addObject:[NSValue valueWithRange:substringRange]];
                                   
                               }
                           }];
    
}

/**
 *  @brief 实例化语音合成器
 *
 *  @param name 播音员
 */
- (void)initSynthesizer
{
    //初始化科大讯飞
    NSString *initString = [[NSString alloc] initWithFormat:@"appid=%@",[AppConfig sharedAppConfig].kIFlyAppId];
    [IFlySpeechUtility createUtility:initString];
    //    iFlySpeechSynthesizer = [IFlySpeechSynthesizer createWithParams:@"appid=52bbb432" delegate:self];
    
    iFlySpeechSynthesizer =[IFlySpeechSynthesizer sharedInstance];
    iFlySpeechSynthesizer.delegate = self;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    // 设置语音合成的参数-(BOOL) setParameter:(NSString *) value forKey:(NSString*)key;
    [ iFlySpeechSynthesizer setParameter:[NSString stringWithFormat:@"%ld",[userDefaults integerForKey:@"VoiceSpeed"]] forKey:@"speed"];//合成的语速,取值范围 0~100
    [ iFlySpeechSynthesizer setParameter:[NSString stringWithFormat:@"%ld",[userDefaults integerForKey:@"VoiceVolume"]] forKey:@"volume"];//合成的音量;取值范围 0~100
    [ iFlySpeechSynthesizer setParameter:[NSString stringWithFormat:@"%ld",[userDefaults integerForKey:@"VoiceTone"]] forKey:@"pitch"];//合成的音调;取值范围 0~100
    //发音人,默认为”xiaoyan”;可以设置的参数列表可参考个 性化发音人列表;
    [ iFlySpeechSynthesizer setParameter:[userDefaults objectForKey:@"VoiceAnnouncer"] forKey:@"voice_name"];
    [ iFlySpeechSynthesizer setParameter:@"8000" forKey:@"sample_rate"];//音频采样率,目前支持的采样率有 16000 和 8000;
}

/**
 *  @brief 阅读下一个句子
 */
- (void)readNextSentence {
    //暂停播放
    //    [self pauseVoice];
    
    //清掉背景颜色
    if (_delegate && [_delegate respondsToSelector:@selector(clearAllTextBackgroundColor)]){
        [_delegate clearAllTextBackgroundColor];
    }
    
    if ([_sentenceRangeArray count] <= (_readIndex+1)) {//没有下一句，去加载新的段落
        
        if (_delegate && [_delegate respondsToSelector:@selector(loadNewText)]){
            NSString *newText = [_delegate loadNewText];
            //有新段落，去切割和播放；没有新段落，停止播放
            if (newText && ![newText isEqualToString:@""]) {
                [self playVoice:newText];
            }else{
                [self closeReading:nil];
                // 播放完毕,让listenView隐藏
                NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"yes",@"isCloseVoice", nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"isCloseView" object:self userInfo:dict];
            }
        }
        
    }else{//有下一句，继续播放
        
        //        NSLog(@"%@", [_sentenceRangeArray objectAtIndex:_readIndex]);
        
        _readIndex++;
        
        [self startSynBtnHandlerWithReadRange:[_sentenceRangeArray objectAtIndex:_readIndex]];
    }
    
}

//停止朗读
- (void)closeReading:(UIButton *)sender {
    
    _readIndex = 0;
    
    _isStopSpeaking = YES;
    
    if (_delegate && [_delegate respondsToSelector:@selector(clearAllTextBackgroundColor)]
        && [_delegate respondsToSelector:@selector(changeSpeakViewTitle:)]){
        [_delegate clearAllTextBackgroundColor];
        [_delegate changeSpeakViewTitle:@"播报"];
        
    }
    
    [self cancelSynBtnHandler];
    
    [self clearnReadData];
}

// 暂停播放
- (void)pauseVoice
{
    [iFlySpeechSynthesizer pauseSpeaking];
}

// 恢复播放
- (void)resumeVoice
{
    [iFlySpeechSynthesizer resumeSpeaking];
}

//取消合成: 1、取消通用合成，并停止播放
- (void)cancelSynBtnHandler {
    [iFlySpeechSynthesizer stopSpeaking];
}

//清空当前阅读内容
- (void)clearnReadData {
    
    _text = nil;
    [_sentenceRangeArray removeAllObjects];
    // 清空所有的背景色
    
}

#pragma mark - 语音播放的代理函数
/** 开始合成时回调 */
- (void) onSpeakBegin{
    
}
/** 回馈缓冲进度回调
 @param progress 缓冲进度，0-100
 @param message 附件信息，此版本为nil
 */
- (void) onBufferProgress:(int) progress message:(NSString *)msg{
    
}

/**回馈播放进度时回调
 @param progress 播放进度，0-100
 */
- (void) onSpeakProgress:(int) progress{
    
}

/** 暂停播放时回调 */
- (void) onSpeakPaused{
    
}

/** 恢复播放时回调 */
- (void) onSpeakResumed{
    
}

/** 结束回调
 当整个合成结束之后会回调此函数
 @param error 错误码
 */
- (void) onCompleted:(IFlySpeechError *)error
{
    if (error.errorCode ==0) {//阅读正常
        //停止播报后也会调用该方法，就不走readNextSentence了
        if (!_isStopSpeaking) {
            [self readNextSentence];
        }
    } else {//阅读错误
        if (error.errorCode == 20001 || error.errorCode == 10114 || error.errorCode == 10205) {//与网络有关
            [Global showTip:@"语音连接超时，请检查一下网络设置"];
        } else {
            [Global showTip:@"请尝试重新进入网页或者重启app重试"];
        }
        [self closeReading:nil];
        [_delegate changeSpeakViewTitle:@"重试"];
    }
    
    
}

/** 取消播放时
 当调用`cancel方法`之后会回调此函数
 */
- (void) onSpeakCancel
{
    [self cancelSynBtnHandler];
}

/**
 *  @brief 判断一个字符串是否为nil、空、空格
 *
 *  @param string 检验的字符串
 *
 *  @return 判断结果
 */
- (BOOL) isBlankString:(NSString *)string {
    if (string == nil || string == NULL) {
        return YES;
    }
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0) {
        return YES;
    }
    return NO;
}
@end