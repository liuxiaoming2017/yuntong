//
//  TXSoundPlayer.m
//  test
//
//  Created by Julian on 16/4/5.
//  Copyright © 2016年 . All rights reserved.
//

//  Created by  Julian on 16-4-5.
//  Copyright (c) 2016年. All rights reserved.
//

#import "TXSoundPlayer.h"
#import <AVFoundation/AVFoundation.h>

static TXSoundPlayer* soundplayer=nil;

@interface TXSoundPlayer ()
{
    AVSpeechSynthesizer* _player;
}

@end

@implementation TXSoundPlayer

+(TXSoundPlayer*)soundPlayerInstance
{
    if(soundplayer==nil)
    {
        soundplayer=[[TXSoundPlayer alloc]init];
        [soundplayer initSoundSet];
    }
    return soundplayer;
}

//播放声音
-(void)play:(NSString*)text
{
    if(text)
    {
        _player=[[AVSpeechSynthesizer alloc]init];
        AVSpeechUtterance* u=[[AVSpeechUtterance alloc]initWithString:text];//设置要朗读的字符串
        u.voice=[AVSpeechSynthesisVoice voiceWithLanguage:@"zh-CN"];//设置语言 "zh-HK" "zh-TW"
        u.volume=self.volume;  //设置音量（0.0~1.0）默认为1.0
        u.rate=self.rate;  //设置语速
        u.pitchMultiplier=self.pitchMultiplier;  //设置语调 (0.5~2) 默认1.0
        [_player speakUtterance:u]; //语音合成器会生成音频
    }
}

- (void)pause
{
    [_player pauseSpeakingAtBoundary:AVSpeechBoundaryImmediate];
}

- (void)continu
{
    [_player continueSpeaking];
}

//初始化配置
-(void)initSoundSet
{
    path=[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"SoundSet.plist"];
    soundSet=[NSMutableDictionary dictionaryWithContentsOfFile:path];
    if(soundSet==nil)
    {
        soundSet=[NSMutableDictionary dictionary];
        [soundplayer setDefault];
        [soundplayer writeSoundSet];
    }
    else
    {
        self.autoPlay=[[soundSet valueForKeyPath:@"autoPlay"] boolValue];
        self.volume=[[soundSet valueForKeyPath:@"volume"] floatValue];
        self.rate=[[soundSet valueForKeyPath:@"rate"] floatValue];
        self.pitchMultiplier=[[soundSet valueForKeyPath:@"pitchMultiplier"] floatValue];
    }
}

//恢复默认设置
-(void)setDefault
{
    self.volume=0.7;
    self.rate=0.5;//0.166;
    self.pitchMultiplier=1.0;
}

//将设置写入配置文件
-(void)writeSoundSet
{
    [soundSet setValue:[NSNumber numberWithBool:self.autoPlay] forKey:@"autoPlay"];
    [soundSet setValue:[NSNumber numberWithFloat:self.volume] forKey:@"volume"];
    [soundSet setValue:[NSNumber numberWithFloat:self.rate] forKey:@"rate"];
    [soundSet setValue:[NSNumber numberWithFloat:self.pitchMultiplier] forKey:@"pitchMultiplier"];
    [soundSet writeToFile:path atomically:YES];
}

@end
