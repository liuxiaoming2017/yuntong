//
//  MiddleCell.h
//  FounderReader-2.5
//
//  Created by chenfei on 4/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TableViewCell.h"
#import "ImageViewCf.h"
#import "SBPlayer.h"
//视频列表cell

@protocol ScrollPlayVideoCellDelegate<NSObject>
- (void)playButtonClick:(UIButton *)sender;
@end

@interface VideoCell : TableViewCell {
   
    UIImageView *cellBgView;
    UILabel   *titleLabel;
    UILabel   *summaryLabel;
    UILabel *dateLabel;
}
@property (nonatomic,strong) SBPlayer  *player;
@property (nonatomic,weak) id<ScrollPlayVideoCellDelegate> delegate;
- (void)shouldToPlay;
-(void)configBigimageWithArticle:(Article *)article;
@property (nonatomic,assign) NSInteger row;
@property (nonatomic,strong) UIView *videoBackView;
@end
