//
//  CommentCell.m
//  FounderReader-2.5
//
//  Created by chenfei on 5/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CommentCell.h"
#import "CommentConfig.h"
#import "ColumnBarConfig.h"
#import "AppStartInfo.h"
@implementation CommentCell

@synthesize userNameLabel, timeLabel, contentLabel,greatCountLabel,greatButton,tableview;
@synthesize userPhoto,handIconImageView,bgview;
@synthesize moreComment,sep;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CommentConfig *config = [CommentConfig sharedCommentConfig];
        
        //灰色背景
        self.blackView = [[UIView alloc] init];
        self.blackView.backgroundColor = [UIColor colorWithRed:0xED/255.0 green:0xED/255.0 blue:0xED/255.0 alpha:1];
        self.blackView.layer.cornerRadius = 2;
        self.blackView.layer.masksToBounds = YES;
        [self.contentView addSubview:self.blackView];
        
        //用户头像
        userPhoto = [[ImageViewCf alloc] init];
        [userPhoto setDefaultImage:[UIImage imageNamed:@"me_icon_head-app"]];
        userPhoto.contentMode = UIViewContentModeScaleAspectFill;
        userPhoto.layer.masksToBounds = YES;
        userPhoto.layer.cornerRadius = IMGHW * 0.5;
        self.userPhoto.frame = CGRectMake(10, 13, IMGHW, IMGHW);
        [self.contentView addSubview:self.userPhoto];
        
        //用户名
        userNameLabel = [[Label alloc] initWithFrame:CGRectMake(CGRectGetMaxX(userPhoto.frame)+9, userPhoto.frame.origin.y+1, 185, 15)];
        userNameLabel.backgroundColor = [UIColor clearColor];
        userNameLabel.textColor = [ColumnBarConfig sharedColumnBarConfig].column_all_color;
        [self.contentView addSubview:userNameLabel];
        
        //时间
        timeLabel = [[Label alloc] initWithFrame:CGRectMake(CGRectGetMaxX(userPhoto.frame)+9, CGRectGetMaxY(userNameLabel.frame)+5, 160, 12)];
        timeLabel.backgroundColor = [UIColor clearColor];
        timeLabel.textColor = [UIColor lightGrayColor];
        timeLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:timeLabel];

        //评论内容
        CGRect rect2 = CGRectMake(10, CGRectGetMaxY(userNameLabel.frame)+10, self.bounds.size.width-30-55, self.bounds.size.height-34-18-27);
        contentLabel = [[Label alloc] init];
        contentLabel.textColor = config.contentTextColor;
        contentLabel.numberOfLines = 0;
        
        if (IS_IPHONE_6P)
        {
        contentLabel.font = [UIFont systemFontOfSize:17];
        timeLabel.font = [UIFont systemFontOfSize:13];
        userNameLabel.font = [UIFont systemFontOfSize:14];
        
        }
        else if (IS_IPHONE_6)
        {
        contentLabel.font = [UIFont systemFontOfSize:17];
        timeLabel.font = [UIFont systemFontOfSize:11];
        userNameLabel.font = [UIFont systemFontOfSize:14];
       
        }
        else
        {
        contentLabel.font = [UIFont systemFontOfSize:13];
        timeLabel.font = [UIFont systemFontOfSize:10];
        userNameLabel.font = [UIFont systemFontOfSize:14];
        
        }
        [self addSubview:contentLabel];
        if ([reuseIdentifier isEqualToString:@"GreatCommentCell2"]) {
            userPhoto.frame = CGRectMake(10, 8, 30, 30);
            userNameLabel.frame= CGRectMake(50, 10, 185, 15);
            timeLabel.frame =CGRectMake(50, 28, 160, 12);
            contentLabel.frame =rect2;
        }
        
        //父评论用户名
        self.userNameParentLabel = [[Label alloc] initWithFrame:CGRectMake(70, 17, 185, 15)];
        self.userNameParentLabel.backgroundColor = [UIColor clearColor];
        self.userNameParentLabel.textColor = [ColumnBarConfig sharedColumnBarConfig].column_all_color;
        [self.contentView addSubview:self.userNameParentLabel];
        
        //评论的父评论内容
        CGRect rect3 = CGRectMake(10, 74, self.bounds.size.width-30-55, self.bounds.size.height-34-18-27);
        self.contentParentLabel = [[Label alloc] init];
        //        contentLabel.font = [UIFont systemFontOfSize:13];//config.contentFontSize
        self.contentParentLabel.textColor = config.contentTextColor;
        self.contentParentLabel.numberOfLines = 0;
        
        if (IS_IPHONE_6P)
        {
            self.contentParentLabel.font = [UIFont systemFontOfSize:17];
            self.userNameParentLabel.font = [UIFont systemFontOfSize:16];
            
        }
        else if (IS_IPHONE_6)
        {
            self.contentParentLabel.font = [UIFont systemFontOfSize:17];
            self.userNameParentLabel.font = [UIFont systemFontOfSize:15];
            
        }
        else
        {
            self.contentParentLabel.font = [UIFont systemFontOfSize:13];
            self.userNameParentLabel.font = [UIFont systemFontOfSize:13];
            
        }
        [self addSubview:self.contentParentLabel];
        
        
        if ([reuseIdentifier isEqualToString:@"GreatCommentCell2"]) {
            self.userNameParentLabel.frame= CGRectMake(50, 10, 185, 15);
            self.contentParentLabel.frame =rect3;
        }
        
        
        
        
        moreComment = [[UIButton alloc] init];
        
        [moreComment setTitle:NSLocalizedString(@"查看更多回复",nil) forState:UIControlStateNormal] ;
        NSInteger FontSize ;
        if (IS_IPHONE_6P) {
            FontSize = 15;
        }else if (IS_IPHONE_6){
            FontSize = 15;
        }else
            FontSize = 12;
        moreComment.titleLabel.font = [UIFont systemFontOfSize:FontSize];
        [moreComment setTitleColor:[UIColor colorWithRed:20/255.0 green:123/255.0 blue:227/255.0 alpha:1.0]forState:UIControlStateNormal];
        moreComment.hidden = YES;
        [self.contentView addSubview:moreComment];
        
        sep = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"newsList_separator"]];
        
        sep.frame = CGRectMake(0, 0, kSWidth, 0.5);
        [self.contentView addSubview:sep];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setEvenColor
{
    UIView *bgView = [[UIView alloc] init];
    bgView.backgroundColor = [CommentConfig sharedCommentConfig].evenCellBgColor;
    self.backgroundView = bgView;
}

- (void)setOddColor
{
    UIView *bgView = [[UIView alloc] init];
    bgView.backgroundColor = [CommentConfig sharedCommentConfig].oddCellBgColor;
    self.backgroundView = bgView; 
}
-(void)configQACell:(Comment *)comment
{
    if (self.userPhoto.superview) {
        [self.userPhoto removeFromSuperview];
    }
    userNameLabel.frame = CGRectMake(70, 17, 185, 15);
    userNameLabel.text = comment.userName;
    userNameLabel.edgeInsets = UIEdgeInsetsMake(5, 0, 0, 0);
    userNameLabel.textColor = [UIColor lightGrayColor];
    
    timeLabel.frame = CGRectMake(kSWidth-130, 0, 120, 20);
    timeLabel.text = intervalSinceNow(comment.commentTime);
    timeLabel.edgeInsets = UIEdgeInsetsMake(5, 0, 0, 0);
    timeLabel.textColor = [UIColor lightGrayColor];
    contentLabel.text = comment.content;
//    contentLabel.font = [UIFont systemFontOfSize:12];
}
@end
