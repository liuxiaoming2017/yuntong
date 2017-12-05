//
//  NSTimer+Addition.h
//  FounderReader-2.5
//
//  Created by 袁野 on 15/9/10.
//
//

#import <Foundation/Foundation.h>

@interface NSTimer (Addition)

- (void)pauseTimer;
- (void)resumeTimer;
- (void)resumeTimerAfterTimeInterval:(NSTimeInterval)interval;
@end
