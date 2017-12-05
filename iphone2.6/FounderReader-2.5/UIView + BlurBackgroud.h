//
//  UIView + BlurBackgroud.h
//  SomeTests
//
//  Created by snitsky on 16/4/22.
//  Copyright © 2016年 snitsky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (BlurBackgroud)

- (UIView *)addBlurBackgroudAtIndex:(NSInteger)index;

- (UIView *)addBlurBackgroudWithStyle:(UIBlurEffectStyle)style atIndex:(NSInteger)index alpha:(CGFloat)alpha;

@end
