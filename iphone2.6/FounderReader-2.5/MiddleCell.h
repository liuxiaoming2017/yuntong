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
#import "Comment.h"
#import "FLAnimatedImage.h"


@interface MiddleCell : TableViewCell {
    
    FLAnimatedImageView *thumbnail;
    UILabel   *titleLabel;
    UILabel   *summaryLabel;
    UILabel *dateLabel;
    UIImageView *cellBgView;
    UIImageView *thumbnailbackground;
    UILabel *statusLabel;
    
    UIView *messageBackView;
    UILabel *authorLabel;
    UIView *bkView;
    UIImageView *sanjiao;
    UIImageView *groupViewLine;
    UIView *pointviewBg;
    UIView *footSeq;
}
@property(nonatomic,retain) UIImageView *imgIcon;
@property(nonatomic,retain) UIImageView *cellBgView;
@property(nonatomic,retain) UIImageView *timerSign;
@property(nonatomic,retain) UIImageView *commentSign;
@property(nonatomic,retain) UILabel *commentLabel;
@property(nonatomic,assign) CGPoint point;
@property(nonatomic,retain) UIView *messageBackView;
@property(nonatomic ,retain)UIView *smallBlackView;
@property(nonatomic,retain) UIImageView *groupViewLine;
@property(nonatomic,retain) UIView *pointviewBg;
@property(nonatomic, retain) UIView *signView; //直播、活动、投票状态背景
@property(nonatomic, retain) UILabel *signLabel; //直播、活动、投票状态
@property(nonatomic, retain) UILabel *liveDateLabel;//直播、活动、投票时间
@property(nonatomic, retain) UIView *liveRemindBgView; //直播提醒背景
@property(nonatomic, retain) UILabel *liveRemindLabel; //直播提醒状态
@property(nonatomic,retain) UIImageView *liveRemindImageView;//直播提醒闹钟
@property(nonatomic,retain) UIView *footSeq;
@property (strong, nonatomic) UIButton *relationButton;
@property (assign, nonatomic) NSUInteger cellType;
- (void)showThumbnail:(BOOL)show;
- (void)loadAnimatedImageWithURL:(NSURL *const)url completion:(void (^)(FLAnimatedImage *animatedImage))completion;
@end
