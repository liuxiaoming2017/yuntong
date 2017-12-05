//
//  NSMutableAttributedString + Extension.h
//  watermelon
//
//  Created by snitsky on 16/6/15.
//  Copyright © 2016年 snitsky. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableAttributedString (Extension)

+ (instancetype)attributedStringWithString:(NSString *)str
                                      Font:(UIFont*)font
                               lineSpacing:(CGFloat)lineSpacing;

- (void)setLineSpacing:(CGFloat)lineSpacing;

- (void)setLineSpacing:(CGFloat)lineSpacing
         lineBreakMode:(NSLineBreakMode)lineBreakMode;

- (CGFloat)boundingHeightWithSize:(CGSize)size
                             font:(UIFont *)font
                      lineSpacing:(CGFloat)lineSpacing
                         maxLines:(NSUInteger)maxLines;

@end
