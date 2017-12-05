//
//  UIImage+Helper.m
//  E-Publishing
//
//  Created by chenfei on 10/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIImage+Helper.h"

@implementation UIImage (Helper)

+ (UIImage *)imageInMainBundleWithFileName:(NSString *)fileName
{
    NSInteger len = [fileName length];
    NSString *suffix = [fileName substringFromIndex:len-4];
    if (![suffix isEqualToString:@".png"])
        fileName = [fileName stringByAppendingString:@".png"];
    NSString * resourceFilePath = [[NSBundle mainBundle] resourcePath];
    NSString * imagePath = [resourceFilePath stringByAppendingPathComponent:fileName];
    UIImage * image = [UIImage imageWithContentsOfFile:imagePath];
    return image;
}

+ (UIImage *)reSizeImage:(UIImage *)image toSize:(CGSize)reSize
{
    UIGraphicsBeginImageContext(CGSizeMake(reSize.width, reSize.height));
    [image drawInRect:CGRectMake(0, 0, reSize.width, reSize.height)];
    UIImage *reSizeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return reSizeImage;
}

+ (UIImage*) createImageWithColor: (UIColor*) color
{
    CGRect rect=CGRectMake(0,0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

@end
