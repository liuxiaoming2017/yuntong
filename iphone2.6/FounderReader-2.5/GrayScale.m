//
//  GrayScale.m
//  XOGameFrame
//
//  Created by song on 11-1-12.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GrayScale.h"

@implementation UIImage (grayscale)

typedef enum {
    ALPHA = 0,
    BLUE = 1,
    GREEN = 2,
    RED = 3
} PIXELS;

- (UIImage *)convertImageColorScale3xWithRGBColorStr:(NSString *) RGBColorStr {
    if(RGBColorStr == nil)
        return nil;
    NSArray *array = [RGBColorStr componentsSeparatedByString:@","];
    
    //    assert([array count] >= 3);
    
    CGSize size = [self size];
    int width = 3*size.width;
    int height = 3*size.height;
    
    // the pixels will be painted to this array
    uint32_t *pixels = (uint32_t *) malloc(width * height * sizeof(uint32_t));
    
    // clear the pixels so any transparency is preserved
    memset(pixels, 0, width * height * sizeof(uint32_t));
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // create a context with RGBA pixels
    CGContextRef context = CGBitmapContextCreate(pixels, width, height, 8, width * sizeof(uint32_t), colorSpace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast);
    
    // paint the bitmap to our context which will fill in the pixels array
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), [self CGImage]);
    
    for(int y = 0; y < height; y++) {
        for(int x = 0; x < width; x++) {
            uint8_t *rgbaPixel = (uint8_t *) &pixels[y * width + x];
            // set the pixels to gray
            if ([NSString isNilOrEmpty:RGBColorStr]) {
                // convert to grayscale using recommended method: http://en.wikipedia.org/wiki/Grayscale#Converting_color_to_grayscale
                uint32_t gray = 0.3 * rgbaPixel[RED] + 0.59 * rgbaPixel[GREEN] + 0.11 * rgbaPixel[BLUE];
                rgbaPixel[RED] = gray;
                rgbaPixel[GREEN] = gray;
                rgbaPixel[BLUE] = gray;
            }else {
                CGFloat red = [[array objectAtIndex:0] floatValue];
                CGFloat green = [[array objectAtIndex:1] floatValue];
                CGFloat blue = [[array objectAtIndex:2] floatValue];
                rgbaPixel[RED] = red;
                rgbaPixel[GREEN] = green;
                rgbaPixel[BLUE] = blue;
            }
        }
    }
    
    // create a new CGImageRef from our context with the modified pixels
    CGImageRef image = CGBitmapContextCreateImage(context);
    
    // we're done with the context, color space, and pixels
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    free(pixels);
    
    // make a new UIImage to return
    UIImage *resultUIImage = [UIImage imageWithCGImage:image];
    
    // we're done with image now too
    CGImageRelease(image);
    
    return resultUIImage;
}

- (UIImage *)convertImageColorScale2xWithRGBColorStr:(NSString *) RGBColorStr {
    
    if(RGBColorStr == nil)
        return nil;
    NSArray *array = [RGBColorStr componentsSeparatedByString:@","];
    
    //    assert([array count] >= 3);
    
    CGSize size = [self size];
    int width = 2*size.width;
    int height = 2*size.height;
    
    // the pixels will be painted to this array
    uint32_t *pixels = (uint32_t *) malloc(width * height * sizeof(uint32_t));
    
    // clear the pixels so any transparency is preserved
    memset(pixels, 0, width * height * sizeof(uint32_t));
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // create a context with RGBA pixels
    CGContextRef context = CGBitmapContextCreate(pixels, width, height, 8, width * sizeof(uint32_t), colorSpace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast);
    
    // paint the bitmap to our context which will fill in the pixels array
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), [self CGImage]);
    
    for(int y = 0; y < height; y++) {
        for(int x = 0; x < width; x++) {
            uint8_t *rgbaPixel = (uint8_t *) &pixels[y * width + x];
            // set the pixels to gray
            if ([NSString isNilOrEmpty:RGBColorStr]) {
                // convert to grayscale using recommended method: http://en.wikipedia.org/wiki/Grayscale#Converting_color_to_grayscale
                uint32_t gray = 0.3 * rgbaPixel[RED] + 0.59 * rgbaPixel[GREEN] + 0.11 * rgbaPixel[BLUE];
                rgbaPixel[RED] = gray;
                rgbaPixel[GREEN] = gray;
                rgbaPixel[BLUE] = gray;
            }else {
                CGFloat red = [[array objectAtIndex:0] floatValue];
                CGFloat green = [[array objectAtIndex:1] floatValue];
                CGFloat blue = [[array objectAtIndex:2] floatValue];
                rgbaPixel[RED] = red;
                rgbaPixel[GREEN] = green;
                rgbaPixel[BLUE] = blue;
            }
        }
    }
    
    // create a new CGImageRef from our context with the modified pixels
    CGImageRef image = CGBitmapContextCreateImage(context);
    
    // we're done with the context, color space, and pixels
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    free(pixels);
    
    // make a new UIImage to return
    UIImage *resultUIImage = [UIImage imageWithCGImage:image];
    
    // we're done with image now too
    CGImageRelease(image);
    
    return resultUIImage;
}

- (UIImage *)convertImageColorScaleWithRGBColorStr:(NSString *) RGBColorStr {
    
    if(RGBColorStr == nil)
        return nil;
    NSArray *array = [RGBColorStr componentsSeparatedByString:@","];
    
    //    assert([array count] >= 3);
    
    CGSize size = [self size];
    int width = size.width;
    int height = size.height;
    
    // the pixels will be painted to this array
    uint32_t *pixels = (uint32_t *) malloc(width * height * sizeof(uint32_t));
    
    // clear the pixels so any transparency is preserved
    memset(pixels, 0, width * height * sizeof(uint32_t));
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // create a context with RGBA pixels
    CGContextRef context = CGBitmapContextCreate(pixels, width, height, 8, width * sizeof(uint32_t), colorSpace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast);
    
    // paint the bitmap to our context which will fill in the pixels array
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), [self CGImage]);
    
    for(int y = 0; y < height; y++) {
        for(int x = 0; x < width; x++) {
            uint8_t *rgbaPixel = (uint8_t *) &pixels[y * width + x];
            // set the pixels to gray
            if ([NSString isNilOrEmpty:RGBColorStr]) {
                // convert to grayscale using recommended method: http://en.wikipedia.org/wiki/Grayscale#Converting_color_to_grayscale
                uint32_t gray = 0.3 * rgbaPixel[RED] + 0.59 * rgbaPixel[GREEN] + 0.11 * rgbaPixel[BLUE];
                rgbaPixel[RED] = gray;
                rgbaPixel[GREEN] = gray;
                rgbaPixel[BLUE] = gray;
            }else {
                CGFloat red = [[array objectAtIndex:0] floatValue];
                CGFloat green = [[array objectAtIndex:1] floatValue];
                CGFloat blue = [[array objectAtIndex:2] floatValue];
                rgbaPixel[RED] = red;
                rgbaPixel[GREEN] = green;
                rgbaPixel[BLUE] = blue;
            }
        }
    }
    
    // create a new CGImageRef from our context with the modified pixels
    CGImageRef image = CGBitmapContextCreateImage(context);
    
    // we're done with the context, color space, and pixels
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    free(pixels);
    
    // make a new UIImage to return
    UIImage *resultUIImage = [UIImage imageWithCGImage:image];
    
    // we're done with image now too
    CGImageRelease(image);
    
    return resultUIImage;
}

@end
