//
//  ImagePagingViewCell.h
//  FounderReader-2.5
//
//  Created by chenfei on 5/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageViewCf.h"
@class FLAnimatedImageView;

@interface ImagePagingViewCell : UIScrollView <UIScrollViewDelegate> {
    FLAnimatedImageView *imageView;
    
    id _target;
    SEL _action;
}

- (UIImage *)image;

- (void)setImageUrl:(NSString *)imageUrl;
- (void)setDefaultImage:(UIImage *)image;
- (void)addTarget:(id)target action:(SEL)action;

@end
