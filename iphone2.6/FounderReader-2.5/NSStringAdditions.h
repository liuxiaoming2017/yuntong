//
//  NSStringAdditions.h
//  E-Publishing
//
//  Created by guo.lh on 12-10-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (FounderMobile)

//===========guo====================
+(CGRect)stringToRect:(NSString *)rectString;

+ (BOOL)isNilOrEmpty:(NSString *)str;

+(NSArray *)stringDate:(NSString *)dateString;

- (BOOL)isValidEMail;

- (BOOL)isEmpty;

- (BOOL)hasSubString:(NSString *)subString isCaseInsensitive:(BOOL)b;

- (BOOL)isWhitespaceAndNewlines;
//===========guo====================

+ (NSString*)encodeBase64String:(NSString * )input;
@end




@interface UIAlertView (FounderMobile)

+ (void)showAlert:(NSString *)title;
+ (void)showAlert:(NSString *)title withMessage:(NSString *)message;
+ (void)showAlert:(NSString *)title second:(int)second;

@end
