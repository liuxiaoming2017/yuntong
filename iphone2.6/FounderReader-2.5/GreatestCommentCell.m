//
//  GreatestCommentCell.m
//  FounderReader-2.5
//
//  Created by ld on 14-8-1.
//
//
#import "GreatestCommentCell.h"
#import "CommentConfig.h"
#import "AppConfig.h"
#import "HttpRequest.h"
#import "CommentConfig.h"
#import "UIImageView+WebCache.h"
#import "UIView+Extention.h"
#import "ColumnBarConfig.h"
#import "UIView + ExtendTouchRect.h"

@interface GreatestCommentCell ()

@property (strong, nonatomic) UIImageView *askBarImage1;
@property (strong, nonatomic) UIImageView *askBarImage2;
@property (strong, nonatomic) UIView *borderView;
@property (strong, nonatomic) UIImageView *topicSignImageView;

@end

@implementation GreatestCommentCell


//-(void)dealloc
//{
//    [super dealloc];
//}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    //用户头像、评论绘制
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        CommentConfig *config = [CommentConfig sharedCommentConfig];
        //点赞数
        greatCountLabel = [[Label alloc] init];
        greatCountLabel.font = [UIFont systemFontOfSize:config.usernameFontSize+1];
        greatCountLabel.textColor = [UIColor lightGrayColor];
        greatCountLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:greatCountLabel];
        //点赞的图片
        handIconImageView = [[UIImageView alloc]init];
        self.handIconImageView.image = [UIImage imageNamed:@"btn_comment_normal"];
        [self addSubview:self.handIconImageView];
        //点赞的事件
        greatButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.greatButton.frame = CGRectMake(260, 0, 60, 50);
        [self addSubview:greatButton];
        
        handIconImageView.frame = CGRectMake(kSWidth-16-10, 13, 16, 16);
        greatCountLabel.frame = CGRectMake(handIconImageView.frame.origin.x-16-5, 15, 16, 16);
        self.greatButton.frame = CGRectMake(greatCountLabel.frame.origin.x-10, 0, 57, 42);
        
        if ([reuseIdentifier isEqualToString:@"GreatCommentCell2"]) {
            greatCountLabel.frame = CGRectMake(170, 10, 40, 23);
            handIconImageView.frame =CGRectMake(210, 10, 23, 23);
            greatButton.frame = CGRectMake(187, 0, 60, 50);
        
        }
        [self.contentView addSubview:self.borderView];
        [self.contentView addSubview:self.askBarImage1];
        [self.contentView addSubview:self.askBarImage2];
    }
    return self;
}

/**
 *  点赞动画
 *
 *  @param sender 点击的button
 */
-(void)greatAnimate:(UIButton *)sender
{
    self.handIconImageView.image = [UIImage imageNamed:@"btn-great-comment-press"];
    sender.enabled = NO;
    UILabel *label_great = [[UILabel alloc]initWithFrame:self.handIconImageView.frame];
    label_great.font = [UIFont boldSystemFontOfSize:18];
    label_great.textColor = [UIColor colorWithRed:0x13/255.0 green:0xAF/255.0 blue:0xFD/255.0 alpha:1];
    label_great.text = @"+1";
    label_great.alpha = 1;
    [self addSubview:label_great]; 
    [UIView beginAnimations:@"great" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:1];
    
    label_great.frame = CGRectMake(self.handIconImageView.frame.origin.x
                                   , self.handIconImageView.frame.origin.y-30,
                                   self.handIconImageView.frame.size.width,
                                   self.handIconImageView.frame.size.height);
    label_great.alpha = 0;
    [UIView commitAnimations];
    
}

- (void)updateWithModel:(Comment *)comment articleType:(ArticleType)articleType {
    [self updateWithModel:comment authorID:@0 articleType:articleType];
}

// 问答+&话题+
- (void)updateWithModel:(Comment *)comment authorID:(NSNumber *)authorID articleType:(ArticleType)articleType;{
    //问答+
    if (authorID.integerValue !=0) {
        if (comment.ueserID == authorID.integerValue) {
            self.borderView.layer.borderColor = colorWithHexString(@"00d0ba").CGColor;
            self.userNameLabel.textColor = colorWithHexString(@"00d0ba");
            self.askBarImage1.image = [UIImage imageNamed:@"icon_ask_man"];
            self.askBarImage1.width = 38;
        } else if (comment.ueserID == 0) {
            self.borderView.layer.borderColor = colorWithHexString(@"f39700").CGColor;
            self.userNameLabel.textColor = colorWithHexString(@"f39700");
            self.askBarImage1.image = [UIImage imageNamed:@"icon_official"];
            self.askBarImage1.width = 29.5;
        } else {
            self.borderView.layer.borderColor = [UIColor clearColor].CGColor;
            self.userNameLabel.textColor = [ColumnBarConfig sharedColumnBarConfig].column_all_color;
            self.askBarImage1.image = nil;
        }
        if (comment.parentUserID == authorID.integerValue) {
            self.userNameParentLabel.textColor = colorWithHexString(@"00d0ba");
            self.askBarImage2.image = [UIImage imageNamed:@"icon_ask_man"];
            self.askBarImage2.width = 38;
        } else if (comment.parentUserID == 0 && comment.parentContent.length) {
            self.userNameParentLabel.textColor = colorWithHexString(@"f39700");
            self.askBarImage2.image = [UIImage imageNamed:@"icon_official"];
            self.askBarImage2.width = 29.5;
        } else {
            self.userNameParentLabel.textColor = [ColumnBarConfig sharedColumnBarConfig].column_all_color;
            self.askBarImage2.image = nil;
        }
    }
    
    [self.userPhoto sd_setImageWithURL:[NSURL URLWithString:comment.userIcon] placeholderImage:[UIImage imageNamed:@"me_icon_head-app"]];
        
    self.timeLabel.text = intervalSinceNow(comment.commentTime);
    // 点赞
    self.greatCountLabel.text = [NSString stringWithFormat:@"%ld",(long)comment.greatCount];
    
    //self.greatButton.tag = indexPath.row;
        
    BOOL bestId = [[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"%ld",(long)comment.ID]];
    if (bestId == 0) {
        self.greatButton.enabled = YES;
        //[cell.greatButton addTarget:self action:@selector(greatButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        self.handIconImageView.image = [UIImage imageNamed:@"btn_comment_normal"];
    }else{
        self.greatCountLabel.text = [NSString stringWithFormat:@"%ld",(long)comment.greatCount + 1];
        self.greatButton.enabled = YES;
        self.handIconImageView.image = [UIImage imageNamed:@"btn_comment_press"];
        }
    
    
    CGFloat contentY = CGRectGetMaxY(self.timeLabel.frame) + 10;
    CGFloat contentW = kSWidth - self.userNameLabel.x - 10;
    // 子评论内容
    self.contentLabel.numberOfLines = 0;
    CGFloat height = [self getAttributeTextHight:comment.content andWidth:contentW];
    self.contentLabel.attributedText = [self getAttributeText:comment.content andWidth:contentW];
    self.contentLabel.frame = CGRectMake(CGRectGetMaxX(self.userPhoto.frame)+9, contentY, contentW, height);
    
    if (comment.parentID != -1 && comment.parentID != 0) {
        // 父评论的用户名
        CGFloat userNameParentY = contentY + height + 10;
        self.userNameParentLabel.frame = CGRectMake(CGRectGetMaxX(self.userPhoto.frame)+9+10, userNameParentY+10, contentW-10, 20);
        self.userNameParentLabel.text = comment.parentUserName;
        
        // 父评论的内容
        self.contentParentLabel.numberOfLines = 0;
        CGFloat contentParentY = userNameParentY + 20 + 10;
        CGFloat contentParentHeight = [self getAttributeTextHight:comment.parentContent andWidth:contentW-10];
        self.contentParentLabel.attributedText = [self getAttributeText:comment.parentContent andWidth:contentW-10];
        self.contentParentLabel.frame = CGRectMake(CGRectGetMaxX(self.userPhoto.frame)+9+10, contentParentY+10, contentW-10, contentParentHeight);
        
        self.blackView.frame = CGRectMake(CGRectGetMaxX(self.userPhoto.frame)+9, userNameParentY, contentW, contentParentHeight+30+2*10);
        self.userNameParentLabel.hidden = NO;
        self.contentParentLabel.hidden = NO;
        self.blackView.hidden = NO;
    }
    else
    {
        self.userNameParentLabel.hidden = YES;
        self.contentParentLabel.hidden = YES;
        self.blackView.hidden = YES;
    }
    self.timeLabel.text = intervalSinceNow(comment.commentTime);
    NSString *regex = @"(^1[3-9][0-9]{9})";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isMatch = [pred evaluateWithObject:comment.userName];
    if (isMatch) {
        NSMutableString *userName = [[NSMutableString  alloc] initWithString:comment.userName];
        [userName replaceCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
        self.userNameLabel.text = userName;
    }else
    {
        self.userNameLabel.text = comment.userName.length == 0 ? [CommentConfig sharedCommentConfig].defaultNickName : comment.userName;
    }
    [self.userNameLabel sizeToFit];
    [self.userNameParentLabel sizeToFit];
    self.askBarImage1.x = CGRectGetMaxX(self.userNameLabel.frame)+6;
    self.askBarImage2.x = CGRectGetMaxX(self.userNameParentLabel.frame)+6;
    self.askBarImage2.centerY = self.userNameParentLabel.centerY;
    
    //话题+定制
    if (comment.ueserID == 0 || comment.ueserID == -1) {
        NSDictionary *topicConfigDict = [[NSUserDefaults standardUserDefaults] objectForKey:FDTopicConfigsNameKey];
        
        NSString *photoUrl = NSLocalizedString([topicConfigDict objectForKey:FDTopicGovImageWordKey], nil);
        if (articleType == ArticleType_QAAPLUS) {
            [self.userPhoto setDefaultImage:[UIImage imageNamed:@"me_icon_head-app"]];
        }else{
            [self.userPhoto sd_setImageWithURL:[NSURL URLWithString:photoUrl] placeholderImage:[UIImage imageNamed:@"me_icon_head-app"]];
        }
        [self.contentView addSubview:self.topicSignImageView];
        
        self.userNameLabel.text = NSLocalizedString([topicConfigDict objectForKey:FDTopicGovNameWordKey], nil);
        self.userNameLabel.textColor = colorWithHexString(@"f39700");
    }else
        [self.topicSignImageView removeFromSuperview];
}

- (CGFloat)getAttributeTextHight:(NSString *)textStr andWidth:(CGFloat)width
{
    if (textStr == nil || [textStr isEqual:[NSNull null]]) {
        textStr = @" ";
        
    }
    UILabel *label = [[UILabel alloc]init];
    label.numberOfLines = 0;
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc]init];
    [style setLineSpacing:4.0f];
    NSInteger leng = width;
    
    if (IS_IPHONE_6P) {
        NSDictionary *attrsDictionary = @{NSFontAttributeName: [UIFont fontWithName:[Global fontName] size:17]};
        NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc]initWithString:textStr attributes:attrsDictionary];
        if (attStr.length < leng) {
            leng = attStr.length;
        }
        CGSize size = CGSizeMake(325, 900);
        [attStr addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, leng)];
        label.attributedText = attStr;
        CGSize labelSize = [label sizeThatFits:size];
        
        return labelSize.height;
        
    }else if (IS_IPHONE_6) {
        
        NSDictionary *attrsDictionary = @{NSFontAttributeName: [UIFont fontWithName:[Global fontName] size:17]};
        NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc]initWithString:textStr attributes:attrsDictionary];
        if (attStr.length < leng) {
            leng = attStr.length;
        }
        CGSize size = CGSizeMake(280, 900);
        [attStr addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, leng)];
        label.attributedText = attStr;
        CGSize labelSize = [label sizeThatFits:size];
        
        return labelSize.height;
        
    }else {
        NSDictionary *attrsDictionary = @{NSFontAttributeName: [UIFont fontWithName:[Global fontName] size:13]};
        NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc]initWithString:textStr attributes:attrsDictionary];
        if (attStr.length < leng) {
            leng = attStr.length;
        }
        CGSize size = CGSizeMake(230, 900);
        [attStr addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, leng)];
        label.attributedText = attStr;
        CGSize labelSize = [label sizeThatFits:size];
        
        return labelSize.height;
        
    }
}

/**
 *  获取评论的回复高度
 *
 *  @param name    回复用户名
 *  @param commnet 回复内容
 *  @param time    回复时间
 *
 *  @return 字符串高度
 */
- (CGFloat )setUsername:(NSString *)name WithComment:(NSString *)commnet WithTime:(NSString *)time{
    time = [time substringWithRange:NSMakeRange(5, 11)];
    //拼接的一个字符串
    NSString *tempStr = @"";
    tempStr = [NSString stringWithFormat:@"%@:  ",name];
    tempStr = [tempStr stringByAppendingString:commnet];
    tempStr = [tempStr stringByAppendingString:@"      "];
    tempStr = [tempStr stringByAppendingString:time];
    NSInteger FontSize ;
    if (IS_IPHONE_6P) {
        FontSize = 16;
    }else if (IS_IPHONE_6){
        FontSize = 16;
    }else
        FontSize = 12;
    NSMutableAttributedString *noteStr = [[NSMutableAttributedString alloc] initWithString:tempStr];
    NSRange nameRange = NSMakeRange(0, [[noteStr string] rangeOfString:@":"].location + 1);
    NSRange commentRange = NSMakeRange(nameRange.location + nameRange.length , [[noteStr string] rangeOfString:commnet].length + 2 );
    NSRange timeRange =NSMakeRange(commentRange.location + commentRange.length +6, [[noteStr string] rangeOfString:time].length );
    [noteStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:FontSize] range:nameRange];
    [noteStr addAttribute:NSForegroundColorAttributeName value: [UIColor colorWithRed:20/255.0 green:123/255.0 blue:227/255.0 alpha:1.0] range:nameRange];
    
    [noteStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:FontSize] range:commentRange];
    [noteStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0] range:commentRange];
    
    [noteStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:FontSize-3] range:timeRange];
    [noteStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0] range:timeRange];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    // 字体的行间距
    paragraphStyle.lineSpacing = 4*proportion;
    [noteStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, noteStr.length)];
    
    NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:FontSize], NSFontAttributeName,nil];
    CGSize commentUserSize = [tempStr boundingRectWithSize:CGSizeMake(240*proportion, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:tdic context:nil].size;
    
    if (IS_IPHONE_6P) {
        return commentUserSize.height = 1.25 *commentUserSize.height - 4*proportion ;
    }else if (IS_IPHONE_6){
        return commentUserSize.height = 1.25 *commentUserSize.height - 4*proportion ;
    }else
        return commentUserSize.height = 1.333 *commentUserSize.height - 4*proportion ;
}

/**
 *  将评论内容变为属性字符串
 *
 *  @param textStr 评论内容
 *  @param width   最大宽度
 *
 *  @return 属性字符串
 */
- (NSMutableAttributedString *)getAttributeText:(NSString *)textStr andWidth:(CGFloat)width
{
    if (textStr == nil) {
        textStr = @" ";
        
    }
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc]init];
    [style setLineSpacing:4.0f];
    NSInteger leng = width;
    
    if (IS_IPHONE_6P) {
        NSDictionary *attrsDictionary = @{NSFontAttributeName: [UIFont fontWithName:[Global fontName] size:17]};
        
        NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc]initWithString:textStr attributes:attrsDictionary];
        
        if (attStr.length < leng) {
            leng = attStr.length;
        }
        
        [attStr addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, leng)];
        
        return attStr;
        
    }else if (IS_IPHONE_6) {
        
        NSDictionary *attrsDictionary = @{NSFontAttributeName: [UIFont fontWithName:[Global fontName] size:17]};
        
        NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc]initWithString:textStr attributes:attrsDictionary];
        
        if (attStr.length < leng) {
            leng = attStr.length;
        }
        
        [attStr addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, leng)];
        
        return attStr;
        
    }else {
        NSDictionary *attrsDictionary = @{NSFontAttributeName: [UIFont fontWithName:[Global fontName] size:13]};
        
        NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc]initWithString:textStr attributes:attrsDictionary];
        
        if (attStr.length < leng) {
            leng = attStr.length;
        }
        
        [attStr addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, leng)];
        
        return attStr;
        
    }
    
}

- (UIImageView *)askBarImage1 {
    if (!_askBarImage1) {
        _askBarImage1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 38, 10)];
        _askBarImage1.centerY = self.userNameLabel.centerY+1;
    }
    return _askBarImage1;
}

- (UIImageView *)askBarImage2 {
    if (!_askBarImage2) {
        _askBarImage2 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 38, 10)];
    }
    return _askBarImage2;
}

- (UIView *)borderView {
    if (!_borderView) {
        _borderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, IMGHW+4, IMGHW+4)];
        _borderView.layer.cornerRadius = (IMGHW+4)/2.f;
        _borderView.layer.borderWidth = .5;
        _borderView.layer.borderColor = [UIColor clearColor].CGColor;
        _borderView.center = self.userPhoto.center;
    }
    return _borderView;
}

- (UIImageView *)topicSignImageView {
    if (!_topicSignImageView) {
        _topicSignImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"topic_official_sign"]];
        _topicSignImageView.origin = CGPointMake(CGRectGetMaxX(self.userPhoto.frame)-_topicSignImageView.width, CGRectGetMaxY(self.userPhoto.frame)-_topicSignImageView.height);
    }
    return _topicSignImageView;
}

@end
