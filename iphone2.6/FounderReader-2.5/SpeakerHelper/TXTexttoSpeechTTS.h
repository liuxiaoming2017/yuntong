//
//  TXTexttoSpeechTTS.h
//  test
//
//  Created by Julian on 16/4/5.
//  Copyright © 2016年 . All rights reserved.
//

//  Created by  Julian on 16-4-5.
//  Copyright (c) 2016年. All rights reserved.

#import <Foundation/Foundation.h>
#import "iflyMSC/IFlySpeechSynthesizer.h"
#import "iflyMSC/IFlySpeechUtility.h"

@protocol ProgressDelegate <NSObject>

- (void)addReadingTextBackgroundColor:(NSRange)rang;
- (void)clearAllTextBackgroundColor;
- (NSString *)loadNewText;
- (void)changeSpeakViewTitle:(NSString *)title;

@end

@interface TXTexttoSpeechTTS : NSObject<IFlySpeechSynthesizerDelegate>
{
    IFlySpeechSynthesizer* iFlySpeechSynthesizer;
}
@property(nonatomic,copy)void(^onResult)(NSString*);
@property (nonatomic, weak) id<ProgressDelegate> delegate;
+(id)shareManager;
//播放
-(void)playVoice:(NSString*)str;
//暂停
- (void)pauseVoice;
//恢复
- (void)resumeVoice;
//关闭
- (void)closeReading:(UIButton *)sender;

@end
