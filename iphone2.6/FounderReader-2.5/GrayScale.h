//
//  GrayScale.h
//  XOGameFrame
//
//  Created by song on 11-1-12.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIImage (grayscale)

- (UIImage *)convertImageColorScale3xWithRGBColorStr:(NSString *) RGBColorStr;
- (UIImage *)convertImageColorScale2xWithRGBColorStr:(NSString *) RGBColorStr;
- (UIImage *)convertImageColorScaleWithRGBColorStr:(NSString *) RGBColorStr;
@end
