//
//  NSString+TimeStringHandler.m
//  FounderReader-2.5
//
//  Created by snitsky on 2016/12/5.
//
//

#import "NSString+TimeStringHandler.h"



@implementation NSString (TimeStringHandler)

- (NSDate *)timeFromStringWithDateFormat:(NSString *)dateFormat {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = dateFormat;
    return [formatter dateFromString:self];
}

- (BOOL)isLaterThanNowWithDateFormat:(NSString *)dateFormat {
    return [self timeFromStringWithDateFormat:dateFormat].timeIntervalSinceNow > 0;
}

- (NSString *)timeStringForQAndA {
    
    NSInteger days = - [self calculateDaysToDate:[NSDate date] withDateFormat:TimeToSeconds];
    
    if (![self isLaterThanNowWithDateFormat:TimeToSeconds] || days > 3) {
        //本地时间晚于self or 3天以后
        return [self substringWithRange:NSMakeRange(5, 5)];
    }
    
    double deltaSeconds = [self timeFromStringWithDateFormat:TimeToSeconds].timeIntervalSinceNow;
    double deltaMinutes = deltaSeconds / 60.0f;
    
    if (deltaMinutes < 60) {
        return [NSString stringWithFormat:@"%zd%@",MAX(1, (NSInteger)deltaMinutes),NSLocalizedString(@"分钟后", nil)];
    } else if (deltaMinutes < (24 * 60)) {
        
        return [NSString stringWithFormat:@"%zd%@", (NSInteger)deltaMinutes/60,NSLocalizedString(@"小时后", nil)];
        
    } else {
        return [NSString stringWithFormat:@"%zd%@", days,NSLocalizedString(@"天后", nil)];
    }
}

- (NSString *)timeStringForLive {
    NSInteger days = - [self calculateDaysToDate:[NSDate date] withDateFormat:TimeToMinutes];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"HH:mm";
    NSString *timeString = [formatter stringFromDate:[self timeFromStringWithDateFormat:TimeToMinutes]];
    if (days == 0) {
        return [NSString stringWithFormat:@"今天 %@", timeString];
    } else if (days == 1) {
        return [NSString stringWithFormat:@"明天 %@", timeString];
    } else {
        formatter.dateFormat = @"M月d日";
        return [formatter stringFromDate:[self timeFromStringWithDateFormat:TimeToMinutes]];
    }
}

- (NSInteger)calculateDaysToDate:(NSDate *)date withDateFormat:(NSString *)dateFormat {
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [self currentCalendar];
    
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&fromDate
                 interval:NULL forDate:[self timeFromStringWithDateFormat:dateFormat]];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&toDate
                 interval:NULL forDate:date];
    
    NSDateComponents *dateComponents = [calendar components:NSCalendarUnitDay
                                                   fromDate:fromDate
                                                     toDate:toDate
                                                    options:NSCalendarWrapComponents];
    return [dateComponents day];
}

- (NSCalendar *)currentCalendar {
    if ([NSCalendar respondsToSelector:@selector(calendarWithIdentifier:)]) {
        return [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    }
    return [NSCalendar currentCalendar];
}

@end
