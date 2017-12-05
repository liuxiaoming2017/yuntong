//
//  SeeDirectPhotosView.h
//  FounderReader-2.5
//
//  Created by 周志扬 on 15/9/6.
//
//

#import <UIKit/UIKit.h>
#import "ImageViewCf.h"
#import "SeeViewmodel.h"
#import "SDPhotoBrowser.h"
@interface SeeDirectPhotosView : UIView<SDPhotoBrowserDelegate>
@property (nonatomic ,retain) NSArray *photos;
@property (nonatomic ,retain) ImageViewCf *imageView;

@property (nonatomic ,assign)NSInteger number;

/**
 *  根据图片个数计算相册的尺寸
 */
+ (CGSize)sizeWithCount:(int)count;
- (void)viewImageClick;
//- (instancetype)initWithtop:(SeeViewmodel *)topModel;
@end
