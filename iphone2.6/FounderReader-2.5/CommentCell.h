//
//  CommentCell.h
//  FounderReader-2.5
//
//  Created by chenfei on 5/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Label.h"
#import "ImageViewCf.h"
#import "Comment.h"
#define IMGHW 25

@interface CommentCell : UITableViewCell {
    Label *userNameLabel;
    Label *timeLabel;
    Label *contentLabel;
    Label *greatCountLabel;
    
    UIButton *greatButton;
    UIImageView *handIconImageView;
    UITableView *tableview;
    UIView *bgview;

    UIButton *moreComment;
    
    UIImageView *sep;

}
@property(nonatomic, retain) UIView *blackView;
@property(nonatomic, retain) Label *userNameLabel;
@property(nonatomic, retain) Label *timeLabel;
@property(nonatomic, retain) Label *contentLabel;

@property(nonatomic, retain) Label *userNameParentLabel;
@property(nonatomic, retain) Label *contentParentLabel;

@property(nonatomic, retain) ImageViewCf *userPhoto;
@property(nonatomic,retain) Label *greatCountLabel;
@property(nonatomic,retain) UIButton *greatButton;
@property(nonatomic,retain) UIImageView *handIconImageView;

@property (nonatomic,retain)UIButton *moreComment;
@property(nonatomic,retain)UITableView *tableview;
@property(nonatomic,retain)UIView *bgview;

@property(nonatomic,retain) UIImageView *sep;
- (void)setEvenColor;
- (void)setOddColor;

-(void)configQACell:(Comment *)comment;
@end
