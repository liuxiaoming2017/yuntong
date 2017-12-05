//
//  UIView+Extention.h
//  Twitter
//
//  Created by 袁野 on 15/7/27.
//  Copyright © 2015年 yuanye. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Extention)
@property (nonatomic,assign) CGFloat x;
@property (nonatomic,assign) CGFloat y;
@property (nonatomic,assign) CGFloat width;
@property (nonatomic,assign) CGFloat height;
@property (nonatomic,assign) CGSize size;
@property (nonatomic,assign) CGPoint origin;
@property (nonatomic,assign) CGFloat centerX;
@property (nonatomic,assign) CGFloat centerY;
- (UIViewController*)viewController;
@end
