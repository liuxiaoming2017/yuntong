//
//  UIDetailPackage.m
//  FounderReader-2.5
//
//  Created by yan.bf on 16/2/2.
//
//

#import "FounderDetailPackage.h"

@implementation FounderDetailPackage

// 获取内容的高度（固定宽）
+ (CGFloat)HeightWithText:(NSString*)text Font:(UIFont*)font width:(float)width
{
    CGSize size = CGSizeMake(width, 10000);
     NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName,nil];
    size =[text boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading attributes:dic context:nil].size;
    
    return size.height;
}


// 获取内容的宽度（固定高）
+ (CGFloat)WidthWithText:(NSString*)text Font:(UIFont*)font height:(float)height
{
    CGSize size = CGSizeMake(10000, height);
     NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName,nil];
    size =[text boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading attributes:dic context:nil].size;
    
    return size.width;
}

// 获取时间戳（由时间转为时间戳）
NSString *timeIntervalWithDate(NSDate *date)
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[date timeIntervalSince1970]];
    return timeSp;
}


// 获取时间（由时间戳转为时间）
NSString *dateWithTimeInterval(NSString *string)
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:[string doubleValue]];
    NSString *confromTimespStr = [formatter stringFromDate:confromTimesp];
    return confromTimespStr;
}
NSString *stringSpecialsupport(NSString *string)
{
    string = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef) string,NULL,(CFStringRef) @"!*'();:@&=+$,/?%#[]",kCFStringEncodingUTF8));
    return string;
}

@end


