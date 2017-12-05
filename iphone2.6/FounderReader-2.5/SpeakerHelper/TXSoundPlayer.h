//
//  TXSoundPlayer.h
//  test
//
//  Created by Julian on 16/4/5.
//  Copyright © 2016年 . All rights reserved.
//

//  Created by  Julian on 16-4-5.
//  Copyright (c) 2016年. All rights reserved.

#import <Foundation/Foundation.h>

@interface TXSoundPlayer : NSObject
{
    NSMutableDictionary* soundSet;  //声音设置
    NSString* path;  //配置文件路径
}

@property(nonatomic,assign)float rate;   //语速
@property(nonatomic,assign)float volume; //音量
@property(nonatomic,assign)float pitchMultiplier;  //音调
@property(nonatomic,assign)BOOL autoPlay;  //自动播放


+(TXSoundPlayer*)soundPlayerInstance;

-(void)play:(NSString*)text;

- (void)pause;

- (void)continu;

-(void)setDefault;

-(void)writeSoundSet;

@end
