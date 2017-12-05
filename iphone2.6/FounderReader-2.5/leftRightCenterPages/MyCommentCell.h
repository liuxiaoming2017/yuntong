//
//  MyCommentCell.h
//  FounderReader-2.5
//
//  Created by 袁野 on 15/9/16.
//
//

#import <UIKit/UIKit.h>
#define MARGIN 10
#define SYS_FONT(x)  [UIFont systemFontOfSize:x]
#import "MyCommentModel.h"
@class ImageViewCf;

@interface MyCommentCell : UITableViewCell

@property(nonatomic, retain) UIImageView *userPhoto;
@property(nonatomic, retain) UILabel *userNameLabel;
@property(nonatomic, retain) UILabel *timeLabel;
@property(nonatomic, retain) UILabel *contentLabel;
//@property (nonatomic,retain)UILabel *content;
@property (nonatomic,retain)UILabel *title;
@property (nonatomic,retain)UILabel *created;
@property(nonatomic,retain) UIView *footSeq;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier Forum:( MyCommentModel*)model;
@end
