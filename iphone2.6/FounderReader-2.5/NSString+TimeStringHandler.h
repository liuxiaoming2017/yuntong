//
//  NSString+TimeStringHandler.h
//  FounderReader-2.5
//
//  Created by snitsky on 2016/12/5.
//
//

#import <Foundation/Foundation.h>
#define TimeToMinutes @"yyyy-MM-dd HH:mm"
#define TimeToSeconds @"yyyy-MM-dd HH:mm:ss"

@interface NSString (TimeStringHandler)

- (NSString *)timeStringForQAndA;

- (NSString *)timeStringForLive;

- (BOOL)isLaterThanNowWithDateFormat:(NSString *)dateFormat;

@end
