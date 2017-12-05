//
//  PhotoView.h
//  HTML
//
//  Created by chen fei on 12-3-28.
//  Copyright (c) 2012年 founder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageViewCf.h"
#import "Label.h"

@interface PhotoView : UIView {
    UIImageView *bgView;
    UIImageView *closeView;
    ImageViewCf *imageView;
    Label *summaryLabel;
    UIButton *saveButton;
    
    CGRect oldFrame;
}

@property(nonatomic, retain) ImageViewCf *imageView;
@property(nonatomic, retain) Label *summaryLabel;

- (void)setImageViewFrame:(CGRect)frame;
- (void)extendPhoto;

@end
