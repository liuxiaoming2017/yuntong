//
//  UIView + BlurBackgroud.m
//  SomeTests
//
//  Created by snitsky on 16/4/22.
//  Copyright © 2016年 snitsky. All rights reserved.
//

#import "UIView + BlurBackgroud.h"

@implementation UIView (BlurBackgroud)

- (UIView *)addBlurBackgroudAtIndex:(NSInteger)index {
    return [self addBlurBackgroudWithStyle:UIBlurEffectStyleExtraLight atIndex:index alpha:1];
}

- (UIView *)addBlurBackgroudWithStyle:(UIBlurEffectStyle)style atIndex:(NSInteger)index alpha:(CGFloat)alpha {
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[UIVisualEffectView class]]) {
            [view removeFromSuperview];
        }
    }
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:style];
    UIVisualEffectView *effectview = [[UIVisualEffectView alloc] initWithEffect:blur];
    effectview.frame = self.bounds;
    effectview.alpha = alpha;
    [self insertSubview:effectview atIndex:index];
    return effectview;
}

@end
