//
//  MyCommentCell.m
//  FounderReader-2.5
//
//  Created by 袁野 on 15/9/16.
//
//
#import "UIView+Extention.h"
#import "MyCommentCell.h"
#import "NewsListConfig.h"
#import "CommentConfig.h"
#import "ImageViewCf.h"
#import "ColumnBarConfig.h"
#import "UserAccountDefine.h"
#import "UIImageView+WebCache.h"

#define IMGHW 25
#define MARGIN 10

@implementation MyCommentCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier Forum:( MyCommentModel*)model{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CommentConfig *config = [CommentConfig sharedCommentConfig];
        //用户头像
        self.userPhoto = [[UIImageView alloc] init];
        self.userPhoto.frame = CGRectMake(MARGIN, MARGIN, IMGHW, IMGHW);
        [self.userPhoto sd_setImageWithURL:[NSURL URLWithString:[[NSUserDefaults standardUserDefaults] objectForKey:KuserAccountFace]] placeholderImage:[UIImage imageNamed:@"me_icon_head-app"]];
        self.userPhoto.contentMode = UIViewContentModeScaleAspectFill;
        self.userPhoto.layer.masksToBounds = YES;
        self.userPhoto.layer.cornerRadius = IMGHW * 0.5;
        [self.contentView addSubview:self.userPhoto];
        
        //用户名
        self.userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.userPhoto.frame)+MARGIN, MARGIN, 185, 15)];
        self.userNameLabel.backgroundColor = [UIColor clearColor];
        self.userNameLabel.textColor = [ColumnBarConfig sharedColumnBarConfig].column_all_color;
        self.userNameLabel.text = [[NSUserDefaults standardUserDefaults] objectForKey:KuserAccountNickName];
        [self.contentView addSubview:self.userNameLabel];
        
        //时间
        self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.userPhoto.frame)+MARGIN, CGRectGetMaxY(self.userNameLabel.frame)+MARGIN/2, 160, 12)];
        self.timeLabel.backgroundColor = [UIColor clearColor];
        self.timeLabel.textColor = [UIColor lightGrayColor];
        self.timeLabel.textAlignment = NSTextAlignmentLeft;
        self.timeLabel.text = intervalSinceNow(model.created);
        [self.contentView addSubview:self.timeLabel];
        
        //评论内容
        self.contentLabel = [[UILabel alloc] init];
        self.contentLabel.textColor = config.contentTextColor;
        self.contentLabel.numberOfLines = 0;
        //计算Lable高度
        NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:17*kScale], NSFontAttributeName,nil];
        CGSize size = [model.content boundingRectWithSize:CGSizeMake(kSWidth-60, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading attributes:tdic context:nil].size;
        
        
        self.contentLabel.frame = (CGRect){{CGRectGetMaxX(self.userPhoto.frame)+9, CGRectGetMaxY(self.timeLabel.frame)+MARGIN}, size};
        self.contentLabel.text = model.content;
        [self addSubview:self.contentLabel];
        
        self.contentLabel.font = [UIFont systemFontOfSize:17*kScale];
        self.timeLabel.font = [UIFont systemFontOfSize:11*kScale];
        self.userNameLabel.font = [UIFont systemFontOfSize:15*kScale];
        
        //原文背景
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(MARGIN, CGRectGetMaxY(self.contentLabel.frame)+MARGIN, kSWidth-MARGIN*2, 30)];
        bgView.backgroundColor = [UIColor colorWithRed:0xED/255.0 green:0xED/255.0 blue:0xED/255.0 alpha:1];
        bgView.layer.cornerRadius = 3;
        bgView.layer.masksToBounds = YES;
        [self.contentView addSubview:bgView];
        
        //原文
        self.title = [[UILabel alloc]init];
        self.title.font = [UIFont systemFontOfSize:11*proportion];
        if ((NSNull *)model.title != [NSNull null]&&model.title!=nil) {
             NSString *content = [@"原文:" stringByAppendingString:model.title];
            self.title.text = content;
        }
        self.title.textColor = [UIColor grayColor];
        self.title.frame = CGRectMake(MARGIN, 7.5, bgView.width - 5*2, 15);
        [bgView addSubview:self.title];
        
        //下面的横线
        self.footSeq =[[UIView alloc] init];
        self.footSeq.backgroundColor = UIColorFromString(@"221,221,221");
        //self.contentView.height默认44
        self.footSeq.frame = CGRectMake(0, CGRectGetMaxY(bgView.frame)+MARGIN - 1, kSWidth, 0.5);
        [self.contentView addSubview:self.footSeq];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
