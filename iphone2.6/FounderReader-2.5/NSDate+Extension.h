//
//  NSDate+Extension.h


//

#import <Foundation/Foundation.h>

@interface NSDate (Extension)

/**
 *  是否是与当前时间是同一年
 *
 *  @param date 传入对比的时间
 *
 *  @return 
 */
+ (BOOL)isThisYearWithDate:(NSDate *)date;

/**
 *  判断与今天否是同一天,是否是今天
 *
 *  @param date
 *
 *  @return
 */
+ (BOOL)isTodayWithDate:(NSDate *)date;


/**
 *  与当前时间对比,判断是否是昨天
 *
 *  @param date
 *
 *  @return
 */
+ (BOOL)isYesterdayWithDate:(NSDate *)date;

+ (NSString *)intervalSinceEndDate:(NSString *)endDate;

@end
