//
//  NSString+Helper.m
//  FounderReader-2.5
//
//  Created by chenfei on 4/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSString+Helper.h"

@implementation NSString (Helper)

+ (BOOL)isNilOrEmpty:(NSString *)string
{
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    return string == nil || [string length] == 0;
}


+(NSString *)convertColumnNameToDate:(NSString *)columnName
{
    NSDate *date = [self convertDateStringToDate:columnName];
    
    NSDateFormatter *formatter =[[NSDateFormatter alloc] init];
    [formatter setTimeStyle:NSDateFormatterMediumStyle];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSInteger unitFlags = NSCalendarUnitWeekday;
    
    //int week=0;week1是星期天,week7是星期六;
    NSDateComponents *comps = [calendar components:unitFlags fromDate:date];
    int weekInt = (int)[comps weekday];
    
    NSString *weekChina = [self convertIntToWeek:weekInt];
    
    NSString*dateChina =  [NSString stringWithFormat:@"%@   %@",columnName,weekChina];
    return dateChina;
}

// 格式化时间，从字符转到时间类型
+(NSDate *)convertDateStringToDate:(NSString *)dateString
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMdd"];
    NSDate *result = [formatter dateFromString:dateString];
 
    return result;
}

+(NSString *)convertIntToWeek:(NSInteger)weekInt
{
    switch (weekInt) {
        case 2:
            return @"星期一";
            break;
        case 3:
            return @"星期二";
            break;
        case 4:
            return @"星期三";
            break;
        case 5:
            return @"星期四";
            break;
        case 6:
            return @"星期五";
            break;
        case 7:
            return @"星期六";
            break;
        case 1:
            return @"星期日";
            break;
            
        default:
            return @"";
            break;
    }
    
}
+(NSString *)stringFromDate:(NSDate *)date withFormate:( NSString *)dateFormat
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    if (!dateFormat)
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    else
        [dateFormatter setDateFormat:dateFormat];
    NSString *dateString = [dateFormatter stringFromDate:date];
 
    return dateString;
}

+(NSString *)stringFromNil:(NSString*)str
{
    if (str!=nil )
        return str;
    return @"";
}

+ (NSString*)encodeString:(NSString*)unencodedString{
    
    // CharactersToBeEscaped =@"%<^>\"`{|}!*';!:@&=+$,/?%#[`]" ;
    // CharactersToLeaveUnescaped = @"[].";
    //;
    NSString *encodedString = (NSString *)
    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                              (CFStringRef)unencodedString,
                                                              NULL,
                                                              (CFStringRef)@":/?#[]@!$&’()*+,;=",
                                                              kCFStringEncodingUTF8));
    //NSString *encodedString = [unencodedString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLPasswordAllowedCharacterSet]];
    return encodedString;
}

- (CGSize)sizeWithFont:(CGFloat)fontSize LineSpacing:(CGFloat)lineSpacing maxSize:(CGSize)maxSize
{
    if ([NSString isNilOrEmpty:self]) return CGSizeMake(0, 0);
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = lineSpacing;
    NSDictionary *attributes = @{
                                 NSFontAttributeName:[UIFont systemFontOfSize:fontSize],
                                 NSParagraphStyleAttributeName:paragraphStyle
                                 };
    return [self boundingRectWithSize:maxSize options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attributes context:nil].size;
}

- (NSAttributedString *)stringWithFont:(CGFloat)fontSize LineSpacing:(CGFloat)lineSpacing
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = lineSpacing;
    NSDictionary *attributes = @{
                                 NSFontAttributeName:[UIFont systemFontOfSize:fontSize],
                                 NSParagraphStyleAttributeName:paragraphStyle
                                 };
    return [[NSAttributedString alloc] initWithString:self attributes:attributes];
}

@end
