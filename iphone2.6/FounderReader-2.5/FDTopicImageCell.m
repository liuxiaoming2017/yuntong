//
//  TZTestCell.m
//  TZImagePickerController
//
//  Created by 谭真 on 16/1/3.
//  Copyright © 2016年 谭真. All rights reserved.
//

#import "FDTopicImageCell.h"
#import "UIView+Layout.h"
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "TZImagePickerController/TZImagePickerController.h"
#import "UIView + ExtendTouchRect.h"

@implementation FDTopicImageCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        _imageView = [[UIImageView alloc] init];
        _imageView.backgroundColor = [UIColor clearColor];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_imageView];
        self.clipsToBounds = YES;
        
        _videoImageView = [[UIImageView alloc] init];
        _videoImageView.image = [UIImage imageNamedFromMyBundle:@"MMVideoPreviewPlay"];
        _videoImageView.contentMode = UIViewContentModeScaleAspectFill;
        _videoImageView.hidden = YES;
        [self addSubview:_videoImageView];
        
        _deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _deleteBtn.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        [_deleteBtn setImage:[UIImage imageNamed:@"topic_photo_remove"] forState:UIControlStateNormal];
        _deleteBtn.frame = CGRectMake(self.tz_width - 15 - 5, 5, 15, 15);
        [_deleteBtn setTouchExtendInset:UIEdgeInsetsMake(-50, -10, -10, -10)];
        //内部图片往下移一点
        _deleteBtn.imageEdgeInsets = UIEdgeInsetsMake(1, 0, 0, 0);//上左下右
        _deleteBtn.alpha = 0.6;
        _deleteBtn.layer.masksToBounds = YES;
        _deleteBtn.layer.cornerRadius = _deleteBtn.frame.size.width/2.0f;
        [self addSubview:_deleteBtn];
        
        _gifLable = [[UILabel alloc] init];
        _gifLable.text = @"GIF";
        _gifLable.textColor = [UIColor whiteColor];
        _gifLable.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
        _gifLable.textAlignment = NSTextAlignmentCenter;
        _gifLable.font = [UIFont systemFontOfSize:10];
        _gifLable.frame = CGRectMake(self.tz_width - 25, self.tz_height - 14, 25, 14);
        [self addSubview:_gifLable];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _imageView.frame = self.bounds;
    CGFloat width = self.tz_width / 3.0;
    _videoImageView.frame = CGRectMake(width, width, width, width);
}

- (void)setAsset:(id)asset {
    _asset = asset;
    if ([asset isKindOfClass:[PHAsset class]]) {
        PHAsset *phAsset = asset;
        _videoImageView.hidden = phAsset.mediaType != PHAssetMediaTypeVideo;
        _gifLable.hidden = ![[phAsset valueForKey:@"filename"] containsString:@"GIF"];
    } else if ([asset isKindOfClass:[ALAsset class]]) {
        ALAsset *alAsset = asset;
        _videoImageView.hidden = ![[alAsset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo];
        _gifLable.hidden = YES;
    }
 }

- (void)setRow:(NSInteger)row {
    _row = row;
    _deleteBtn.tag = row;
}

- (UIView *)snapshotView {
    UIView *snapshotView = [[UIView alloc]init];
    
    UIView *cellSnapshotView = nil;
    
    if ([self respondsToSelector:@selector(snapshotViewAfterScreenUpdates:)]) {
        cellSnapshotView = [self snapshotViewAfterScreenUpdates:NO];
    } else {
        CGSize size = CGSizeMake(self.bounds.size.width + 20, self.bounds.size.height + 20);
        UIGraphicsBeginImageContextWithOptions(size, self.opaque, 0);
        [self.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage * cellSnapshotImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        cellSnapshotView = [[UIImageView alloc]initWithImage:cellSnapshotImage];
    }
    
    snapshotView.frame = CGRectMake(0, 0, cellSnapshotView.frame.size.width, cellSnapshotView.frame.size.height);
    cellSnapshotView.frame = CGRectMake(0, 0, cellSnapshotView.frame.size.width, cellSnapshotView.frame.size.height);
    
    [snapshotView addSubview:cellSnapshotView];
    return snapshotView;
}

@end
