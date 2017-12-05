//
//  NSMutableAttributedString + Extension.m
//  watermelon
//
//  Created by snitsky on 16/6/15.
//  Copyright © 2016年 snitsky. All rights reserved.
//

#import "NSMutableAttributedString + Extension.h"

@implementation NSMutableAttributedString (Extension)

- (void)setLineSpacing:(CGFloat)lineSpacing {
    [self setLineSpacing:lineSpacing
           lineBreakMode:NSLineBreakByTruncatingTail];
}

- (void)setLineSpacing:(CGFloat)lineSpacing
         lineBreakMode:(NSLineBreakMode)lineBreakMode {
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = lineSpacing;
    paragraphStyle.lineBreakMode = lineBreakMode;
    [self addAttribute:NSParagraphStyleAttributeName
                 value:paragraphStyle
                 range:NSMakeRange(0, self.length)];
}

+ (instancetype)attributedStringWithString:(NSString *)str
                                      Font:(UIFont*)font
                               lineSpacing:(CGFloat)lineSpacing {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = lineSpacing;
    NSDictionary *attributes = @{NSFontAttributeName:font,
                                 NSParagraphStyleAttributeName:paragraphStyle,
                                 };
    return [[NSMutableAttributedString alloc] initWithString:str
                                                  attributes:attributes];
}

- (CGFloat)boundingHeightWithSize:(CGSize)size
                             font:(UIFont *)font
                      lineSpacing:(CGFloat)lineSpacing
                         maxLines:(NSUInteger)maxLines {
    CGRect rect = [self boundingRectWithSize:size
                                     options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                     context:nil];
    CGFloat height = rect.size.height;
    if (maxLines) {
        height = MIN(height, (font.lineHeight + lineSpacing) * maxLines - lineSpacing);
    }
    if (height <= font.lineHeight + lineSpacing) {
        height = font.lineHeight;
        [self setLineSpacing:0];
    } else {
        [self setLineSpacing:lineSpacing];
    }
    return height;
}

@end
