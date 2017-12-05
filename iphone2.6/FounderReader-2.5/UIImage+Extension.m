//
//  UIImage+Extension.m
//  FounderReader-2.5
//
//  Created by snitsky on 2017/2/24.
//
//

#import "UIImage+Extension.h"

@implementation UIImage (Extension)

- (UIImage *)roundedWithBorderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor {
    CGFloat inset = 1;
    CGFloat width = self.size.width;
    CGFloat height = self.size.height;
    CGFloat cornerRadius;
    UIBezierPath *maskShape;
    if (width > height) {
        cornerRadius = height / 2.0 - inset;
        maskShape = [UIBezierPath bezierPathWithRoundedRect:CGRectMake((width-height)/2.0 + inset, 0 + inset, height-2*inset, height-2*inset) cornerRadius:cornerRadius];
    }else{
        cornerRadius = width / 2.0 - inset;
        maskShape = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0+inset, (height-width)/2.0+inset, width-2*inset, width-2*inset) cornerRadius:cornerRadius];
    }
    
    UIGraphicsBeginImageContextWithOptions(self.size, NO, [UIScreen mainScreen].scale);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(ctx);
    CGContextAddPath(ctx, maskShape.CGPath);
    CGContextClip(ctx);
    
    CGContextTranslateCTM(ctx, 0, height);
    CGContextScaleCTM(ctx, 1.0, -1.0);
    CGContextDrawImage(ctx, CGRectMake(0, 0, width, height), self.CGImage);
    CGContextRestoreGState(ctx);
    
    if (borderWidth > 0) {
        [borderColor setStroke];
        CGFloat halfWidth = borderWidth / 2.0;
        UIBezierPath *border = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(halfWidth, halfWidth, self.size.width - borderWidth , self.size.width - borderWidth)];
        CGContextSetShouldAntialias(ctx, YES);
        CGContextSetAllowsAntialiasing(ctx, YES);
        CGContextSetLineWidth(ctx, borderWidth);
        CGContextAddPath(ctx, border.CGPath);
        CGContextStrokePath(ctx);
    }
    
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultingImage;
}

+ (UIImage*)imageWithColor:(UIColor*)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
