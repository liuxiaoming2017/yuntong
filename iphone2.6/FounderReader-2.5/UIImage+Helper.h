//
//  UIImage+Helper.h
//  E-Publishing
//
//  Created by chenfei on 10/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Helper)

+ (UIImage *)imageInMainBundleWithFileName:(NSString *)fileName;
+ (UIImage *)reSizeImage:(UIImage *)image toSize:(CGSize)reSize;
+ (UIImage*) createImageWithColor: (UIColor*) color;
@end
