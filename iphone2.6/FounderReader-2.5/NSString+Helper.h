//
//  NSString+Helper.h
//  FounderReader-2.5
//
//  Created by chenfei on 4/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//



@interface NSString (Helper)

+ (BOOL)isNilOrEmpty:(NSString *)string;
+(NSString *)convertColumnNameToDate:(NSString *)columnName;
+(NSString *)stringFromDate:(NSDate *)date withFormate:( NSString *)dateFormat;
+(NSString *)stringFromNil:(NSString*)str;
+ (NSString*)encodeString:(NSString*)unencodedString;
- (CGSize)sizeWithFont:(CGFloat)fontSize LineSpacing:(CGFloat)lineSpacing maxSize:(CGSize)maxSize;
- (NSAttributedString *)stringWithFont:(CGFloat)fontSize LineSpacing:(CGFloat)lineSpacing;
@end
