//
//  SeeLivePhotosView.h
//  FounderReader-2.5
//
//  Created by 周志扬 on 15/9/8.
//
//

#import <UIKit/UIKit.h>
#import "ImageViewCf.h"
#import "SDPhotoBrowser.h"
@interface SeeLivePhotosView : UIView<SDPhotoBrowserDelegate>
{
    CGFloat IMGHeight;
    UIImage *BIGImage;
}
@property (nonatomic ,retain) NSArray *photosViewArr;
@property (nonatomic ,assign)NSInteger number;
/**
 *  根据图片个数计算相册的尺寸
 */
+ (CGSize)sizeViewWithCount:(int)count andSummaryWidth:(CGFloat)summaryWidth;

@end
