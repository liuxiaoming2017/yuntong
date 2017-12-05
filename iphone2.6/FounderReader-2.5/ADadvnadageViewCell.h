//
//  AVDTableViewCell.h
//  FounderReader-2.5
//
//  Created by 周志扬 on 15/8/28.
// 广告cell样式

#import <UIKit/UIKit.h>
#import "ImageViewCf.h"
#import "TableViewCell.h"

@interface ADadvnadageViewCell : TableViewCell
{
    FLAnimatedImageView *thumbnail;
    UILabel   *titleLabel;
    UIView *blackView;
    UILabel *flagLabel;
}
@property(nonatomic,retain) UIView *footSeq;
@property(nonatomic,retain)  UILabel *typeLabel;
@property (nonatomic,retain) UILabel *commentLabel;
@end
