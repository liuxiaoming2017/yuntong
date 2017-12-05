//
//  UIDetailPackage.h
//  FounderReader-2.5
//
//  Created by yan.bf on 16/2/2.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface FounderDetailPackage : NSObject

// 获取内容的高度（固定宽）
+ (CGFloat)HeightWithText:(NSString*)text Font:(UIFont*)font width:(float)width;

// 获取内容的宽度（固定高）
+ (CGFloat)WidthWithText:(NSString*)text Font:(UIFont*)font height:(float)height;

// 获取颜色（rgb三色值）
//UIColor *UIColorFromString(NSString *string);

// 获取时间戳--由时间转为时间戳
NSString *timeIntervalWithDate(NSDate *date);

// 获取时间--由时间戳转为时间
NSString *dateWithTimeInterval(NSString *string);

//对特殊字符进行融合支持  @"!*'();:@&=+$,/?%#[]"
NSString *stringSpecialsupport(NSString *string);

@end
