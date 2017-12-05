//
//  PhotoView.m
//  HTML
//
//  Created by chen fei on 12-3-28.
//  Copyright (c) 2012年 founder. All rights reserved.
//

#import "PhotoView.h"

#define kSummaryLabelHeight 35

@implementation PhotoView

@synthesize imageView;
@synthesize summaryLabel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
        
        bgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"imageset_background"]];
        [self addSubview:bgView];
        
        imageView = [[ImageViewCf alloc] init];
//        imageView.defaultIcon = [UIImage imageNamed:@"contentview_image_default"];
        [self addSubview:imageView];
        
        closeView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"contentview_image_close"]];
        [self addSubview:closeView];
        
        summaryLabel = [[Label alloc] init];
        summaryLabel.backgroundColor = [UIColor clearColor];
        summaryLabel.font = [UIFont systemFontOfSize:12];
        summaryLabel.numberOfLines = 0;
        summaryLabel.edgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
        summaryLabel.lineBreakMode = NSLineBreakByCharWrapping;
        summaryLabel.textColor = [UIColor whiteColor];
        summaryLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:summaryLabel];
        
        saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [saveButton setImage:[UIImage imageNamed:@"toolbar_save"] forState:UIControlStateNormal];
        [saveButton addTarget:self action:@selector(saveButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:saveButton];
    }
    return self;
} 

- (void)setImageViewFrame:(CGRect)frame
{
    oldFrame = frame;
    imageView.frame = frame;
    bgView.frame = CGRectMake(frame.origin.x-3, frame.origin.y-3, frame.size.width+6, frame.size.height+30);
    closeView.frame = CGRectMake(frame.origin.x-10, frame.origin.y-10, 20, 20);
    summaryLabel.frame = CGRectMake(frame.origin.x, frame.origin.y+frame.size.height, frame.size.width-25, kSummaryLabelHeight);
    saveButton.frame = CGRectMake(frame.origin.x+frame.size.width-25, frame.origin.y+frame.size.height+5, 25, 25);
}

- (void)extendPhoto
{
    if (self.imageView.image == nil)
        return;
    
    CGSize oldSize = self.imageView.image.size;
    CGSize newSize;
    
    CGSize size = CGSizeMake(300, 400);
    float scaleX = size.width / oldSize.width;
    float scaleY = size.height / oldSize.height;
    float scale = scaleX < scaleY ? scaleX : scaleY;
    newSize = CGSizeMake(oldSize.width * scale, oldSize.height * scale);
    
    CGRect newFrame = CGRectMake(self.center.x-newSize.width/2, self.center.y-newSize.height/2, newSize.width, newSize.height);
    
    [UIView animateWithDuration:0.8 animations:^(void) {
        imageView.frame = newFrame;
        bgView.frame = CGRectMake(newFrame.origin.x-3, newFrame.origin.y-3, newFrame.size.width+6, newFrame.size.height+41);
        closeView.frame = CGRectMake(newFrame.origin.x-10, newFrame.origin.y-10, 20, 20);
        if (newSize.width < 150)
            summaryLabel.hidden = YES;
        else
            summaryLabel.frame = CGRectMake(newFrame.origin.x, newFrame.origin.y+newFrame.size.height, newFrame.size.width-25, kSummaryLabelHeight);
        saveButton.frame = CGRectMake(newFrame.origin.x+newFrame.size.width-25, newFrame.origin.y+newFrame.size.height+5, 25, 25);
        self.alpha = 1;
    } completion:^(BOOL finished) {
    }];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [UIView animateWithDuration:0.5 animations:^(void) {
        imageView.frame = oldFrame;
        bgView.frame = CGRectMake(oldFrame.origin.x-3, oldFrame.origin.y-3, oldFrame.size.width+6, oldFrame.size.height+6);
        closeView.frame = CGRectMake(oldFrame.origin.x-10, oldFrame.origin.y-10, 20, 20);
        summaryLabel.frame = CGRectMake(oldFrame.origin.x, oldFrame.origin.y+oldFrame.size.height, oldFrame.size.width-25, kSummaryLabelHeight);
        saveButton.frame = CGRectMake(oldFrame.origin.x+oldFrame.size.width-25, oldFrame.origin.y+oldFrame.size.height+5, 25, 25);
        self.alpha = 0;
    }];
    
    [self performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.5];
}

- (void)saveButtonClicked:(id)sender
{
    UIImageWriteToSavedPhotosAlbum(imageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), 0);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error)
        [Global showTip:NSLocalizedString(@"保存失败",nil)];
    else
        [Global showTip:NSLocalizedString(@"保存成功",nil)];
}

@end
