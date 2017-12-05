//
//  ImagePagingViewCell.m
//  FounderReader-2.5
//
//  Created by chenfei on 5/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ImagePagingViewCell.h"
#import "UIImageView+WebCache.h"
#import "UIImage+GIF.h"
#import "FLAnimatedImage.h"

@implementation ImagePagingViewCell

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.bouncesZoom = YES;
        //        self.alwaysBounceHorizontal = YES;
        self.minimumZoomScale = 1.0;
        self.maximumZoomScale = CGFLOAT_MAX;
        self.delegate = self;
        
        imageView = [[FLAnimatedImageView alloc] initWithFrame:self.bounds];
        imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.bounces = NO;
        [self addSubview:imageView];
        
    }
    return self;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

- (UIImage *)image
{
    return imageView.image;
}

- (void)setImageUrl:(NSString *)imageUrl
{
    if ([imageUrl containsString:@".gif"]) {
        imageView.image = [Global getBgImage169];
        [self loadAnimatedImageWithURL:[NSURL URLWithString:imageUrl] completion:^(FLAnimatedImage *animatedImage) {
            [imageView setAnimatedImage:animatedImage];
        }];
    }else{
        [imageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[Global getBgImage169]];
}
}
    
- (void)loadAnimatedImageWithURL:(NSURL *const)url completion:(void (^)(FLAnimatedImage *animatedImage))completion
{
    NSString *const filename = url.lastPathComponent;
    NSString *const diskPath = [NSHomeDirectory() stringByAppendingPathComponent:filename];
    
    NSData * __block animatedImageData = [[NSFileManager defaultManager] contentsAtPath:diskPath];
    FLAnimatedImage * __block animatedImage = [[FLAnimatedImage alloc] initWithAnimatedGIFData:animatedImageData];
    
    if (animatedImage) {
        if (completion) {
            completion(animatedImage);
        }
    } else {
        [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            animatedImageData = data;
            animatedImage = [[FLAnimatedImage alloc] initWithAnimatedGIFData:animatedImageData];
            if (animatedImage) {
                if (completion) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(animatedImage);
                    });
                }
                [data writeToFile:diskPath atomically:YES];
            }
        }] resume];
    }
}


- (void)addTarget:(id)target action:(SEL)action
{
    _target = target;
    _action = action;
}

#pragma scroll view delegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    //缩放后图片位于scrollview中间
    [self centerScrollViewContents];
}

- (void)centerScrollViewContents {
    CGSize boundsSize = self.bounds.size;
    CGRect contentsFrame = imageView.frame;
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }
    
    imageView.frame = contentsFrame;
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    if ([touch tapCount] == 1) {
        if ([_target respondsToSelector:_action])
            [_target performSelector:_action withObject:self afterDelay:0.2];
    } else if ([touch tapCount] == 2) {
        [NSObject cancelPreviousPerformRequestsWithTarget:_target selector:_action object:self];
        //双击时1<->2倍
        self.minimumZoomScale = 1.0;
        self.maximumZoomScale = 3.0;
        float scale = (self.zoomScale == self.minimumZoomScale) ? self.maximumZoomScale : self.minimumZoomScale;
        [self setZoomScale:scale animated:YES];
        //其他无穷倍，如缩放（这里没用手势，直接用scrlloview自带的缩放事件，所以双击完之后马上比例变回去）
        self.minimumZoomScale = 1.0;
        self.maximumZoomScale = CGFLOAT_MAX;    }
}



- (void)setDefaultImage:(UIImage *)image{
//    [imageView setDefaultImage:image];
}
@end
