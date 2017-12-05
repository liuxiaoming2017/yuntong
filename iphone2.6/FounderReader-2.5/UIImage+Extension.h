//
//  UIImage+Extension.h
//  FounderReader-2.5
//
//  Created by snitsky on 2017/2/24.
//
//

#import <UIKit/UIKit.h>

@interface UIImage (Extension)

- (UIImage *)roundedWithBorderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor;

+ (UIImage*)imageWithColor:(UIColor*)color;
@end
