//
//  FDMyTopicCell.m
//  FounderReader-2.5
//
//  Created by Julian on 2017/5/5.
//
//

#import "FDMyTopicCell.h"
#import "FDMyTopicImageView.h"
#import "FDMyTopic.h"
#import "UIImageView+WebCache.h"
#import "UIView+Extention.h"
#import "NewsListConfig.h"
#import "NSMutableAttributedString + Extension.h"
#import "UIButton+Block.h"

#define kMarginW 15
#define kMarginH 10

@interface FDMyTopicCell()

@property (strong, nonatomic) UIImageView *statusImageView;
@property (strong, nonatomic) UILabel *contentLabel;
@property (strong, nonatomic) FDMyTopicImageView *topicImageView;
@property (strong, nonatomic) UILabel *dateLabel;
@property (strong, nonatomic) UILabel *praiseLabel;
@property (strong, nonatomic) UILabel *commentLabel;
@property (strong, nonatomic) UIView *interactBgView;
@property (strong, nonatomic) UILabel *reasonLabel;
@property (strong, nonatomic) UIView *separateView;
@property (strong, nonatomic) UIView *placeHolderView;

@end

@implementation FDMyTopicCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI
{
    [self.contentView addSubview:self.placeHolderView];
    [self.contentView addSubview:self.statusImageView];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.contentLabel];
    [self.contentView addSubview:self.interactBgView];
    [self.contentView addSubview:self.topicImageView];
    [self.contentView addSubview:self.dateLabel];
    [self.contentView addSubview:self.reasonLabel];
    [self.contentView addSubview:self.separateView];
}

- (void)layoutCell:(FDMyTopic *)myTopic IsHeader:(BOOL)isHeader IsFirstRow:(BOOL)isFirstRow
{
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    _placeHolderView.hidden = !isFirstRow;
    
    //"discussStatus": 0/1/2, //参与状态(0:待审核;1:已发布;2:驳回)
    if (!_placeHolderView.hidden)
        _statusImageView.frame = CGRectMake(kMarginW, kMarginW+7, 24, 24);
    else
        _statusImageView.frame = CGRectMake(kMarginW, kMarginW, 24, 24);
    
    _statusImageView.layer.masksToBounds = YES;
    _statusImageView.layer.cornerRadius = self.statusImageView.width/2.0f;
    switch (myTopic.discussStatus.integerValue) {
        case 0:
            _statusImageView.image = [UIImage imageNamed:@"myTopic_toAudit"];
            break;
        case 1:
            _statusImageView.image = [UIImage imageNamed:@"myTopic_Passed"];
            break;
        case 2:
            _statusImageView.image = [UIImage imageNamed:@"myTopic_noPassed"];
            break;
        default:
            break;
    }
    
    _titleLabel.textColor = [NewsListConfig sharedListConfig].middleCellTitleTextColor;
    _titleLabel.numberOfLines = 2;
    _titleLabel.font = [UIFont systemFontOfSize:17];
    _titleLabel.textAlignment = NSTextAlignmentLeft;
    CGFloat titleLabelW = kSWidth-kMarginW*3-_statusImageView.width;
    _titleLabel.frame = CGRectMake(CGRectGetMaxX(_statusImageView.frame)+kMarginH, _statusImageView.y, titleLabelW, myTopic.titleH);
    if (myTopic.titleH < 30) {
        _titleLabel.centerY = _statusImageView.centerY;
    }
    _titleLabel.attributedText = myTopic.attrTitle;
    
    // 内容=纯文字、内容=纯图片、内容=文字+图片
    _contentLabel.hidden = [NSString isNilOrEmpty:myTopic.content];
    if (!_contentLabel.hidden) {
        CGFloat contentY = myTopic.titleH < 30 ? CGRectGetMaxY(_statusImageView.frame)+kMarginW : CGRectGetMaxY(_titleLabel.frame)+kMarginW;
        _contentLabel.frame = CGRectMake(_statusImageView.x+1, contentY, kSWidth-kMarginW*2, myTopic.contentH);
        _contentLabel.textColor = colorWithHexString(@"666666");
        _contentLabel.font = [UIFont systemFontOfSize:15];
        _contentLabel.numberOfLines = ![myTopic.pics count] ? 4 : 2;
        _contentLabel.attributedText = myTopic.attrContent;
    }
    
    _topicImageView.hidden = ![myTopic.pics count];
    if (!_topicImageView.hidden) {
        [_topicImageView removeFromSuperview];
        CGFloat topicImageY = _contentLabel.hidden ? CGRectGetMaxY(_titleLabel.frame)+kMarginH : CGRectGetMaxY(_contentLabel.frame)+kMarginH;
        CGRect imagesFrame = CGRectMake(_statusImageView.x+1, topicImageY, kSWidth-2*kMarginW, myTopic.imagesH);
        _topicImageView = [FDMyTopicImageView TopicImageViewWithFrame:imagesFrame ImageArray:myTopic.pics IsHeader:isHeader ImageSize:CGSizeZero];
        _topicImageView.origin = CGPointMake(_statusImageView.x+1, topicImageY);
        [self.contentView addSubview:_topicImageView];
    }
    
    // 内容和图片必有一样存在值
    CGFloat dateY = _topicImageView.hidden ? CGRectGetMaxY(_contentLabel.frame)+kMarginW : CGRectGetMaxY(_topicImageView.frame)+kMarginW;
    _dateLabel.textColor = colorWithHexString(@"999999");
    _dateLabel.font = [UIFont systemFontOfSize:14];
    _dateLabel.text = myTopic.createTime;
    [_dateLabel sizeToFit];
    _dateLabel.textAlignment = NSTextAlignmentRight;
    _dateLabel.origin = CGPointMake(kSWidth-kMarginW-_dateLabel.width, dateY);
    
    _interactBgView.hidden = !(myTopic.discussStatus.integerValue == 1);
    if (!_interactBgView.hidden) {
        _interactBgView.origin = CGPointMake(_statusImageView.x+1, dateY);
        
        _praiseBtn.origin = CGPointMake(0, 0);
        
        _praiseLabel.text = myTopic.praiseCount.stringValue;
        _praiseLabel.textColor = colorWithHexString(@"999999");
        _praiseLabel.font = [UIFont systemFontOfSize:13];
        _praiseLabel.text = myTopic.praiseCount.stringValue;
        [_praiseLabel sizeToFit];
        _praiseLabel.textAlignment = NSTextAlignmentRight;
        _praiseLabel.x = CGRectGetMaxX(_praiseBtn.frame)+5;
        _praiseLabel.centerY = _praiseBtn.centerY;
        
        _commentBtn.origin = CGPointMake(CGRectGetMaxX(_praiseLabel.frame)+kMarginW, 0);
        
        _commentLabel.text = myTopic.commentCount.stringValue;
        _commentLabel.textColor = colorWithHexString(@"999999");
        _commentLabel.font = [UIFont systemFontOfSize:13];
        _commentLabel.text = myTopic.commentCount.stringValue;
        [_commentLabel sizeToFit];
        _commentLabel.textAlignment = NSTextAlignmentRight;
        _commentLabel.x = CGRectGetMaxX(_commentBtn.frame)+5;
        _commentLabel.centerY = _commentBtn.centerY;
    }
    
    _reasonLabel.hidden = !(myTopic.discussStatus.integerValue == 2);
    if (isHeader)
        _reasonLabel.hidden = YES;
    if (!_reasonLabel.hidden) {
        _reasonLabel.frame = CGRectMake(kMarginW, CGRectGetMaxY(_dateLabel.frame)+kMarginH, kSWidth-2*kMarginW, 16);
        _reasonLabel.textColor = [UIColor redColor];
        _reasonLabel.font = [UIFont systemFontOfSize:14];
        _reasonLabel.numberOfLines = 1;
        _reasonLabel.textAlignment = NSTextAlignmentLeft;
        _reasonLabel.text = myTopic.reason;
    }
    
    CGFloat separateY = _reasonLabel.hidden ? CGRectGetMaxY(_dateLabel.frame)+kMarginH : CGRectGetMaxY(_reasonLabel.frame)+kMarginH;
    _separateView.frame = CGRectMake(0, separateY, kSWidth, 0.5);
    _separateView.backgroundColor = colorWithHexString(@"d5d5d5");
    
    if (isHeader){
        _separateView.y = dateY;
        _dateLabel.origin = CGPointMake(15, CGRectGetMaxY(_separateView.frame)+10);
        _dateLabel.text = [NSLocalizedString(@"提交时间：", nil) stringByAppendingString:myTopic.createTime];
        [_dateLabel sizeToFit];
    }
}

- (UIImageView *)statusImageView
{
    if (!_statusImageView) {
        _statusImageView = [[UIImageView alloc] init];
    }
    return _statusImageView;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
    }
    return _titleLabel;
}

- (UILabel *)contentLabel
{
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] init];
    }
    return _contentLabel;
}

- (UIButton *)praiseBtn
{
    if (!_praiseBtn) {
        _praiseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_praiseBtn setImage:[UIImage imageNamed:@"topic_praise_normal"] forState:UIControlStateNormal];
        [_praiseBtn setImage:[UIImage imageNamed:@"topic_praise_press"] forState:UIControlStateSelected];
        [_praiseBtn sizeToFit];
    }
    return _praiseBtn;
}

- (UILabel *)praiseLabel
{
    if (!_praiseLabel) {
        _praiseLabel = [[UILabel alloc] init];
    }
    return _praiseLabel;
}

- (UIButton *)commentBtn
{
    if (!_commentBtn) {
        _commentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_commentBtn setImage:[UIImage imageNamed:@"topic_comment_normal"] forState:UIControlStateNormal];
        [_commentBtn setImage:[UIImage imageNamed:@"topic_comment_press"] forState:UIControlStateSelected];
        [_commentBtn sizeToFit];
    }
    return _commentBtn;
}

- (UILabel *)commentLabel
{
    if (!_commentLabel) {
        _commentLabel = [[UILabel alloc] init];
    }
    return _commentLabel;
}

- (UILabel *)dateLabel
{
    if (!_dateLabel) {
        _dateLabel = [[UILabel alloc] init];
    }
    return _dateLabel;
}

- (UILabel *)reasonLabel
{
    if (!_reasonLabel) {
        _reasonLabel = [[UILabel alloc] init];
    }
    return _reasonLabel;
}

- (UIView *)separateView
{
    if (!_separateView) {
        _separateView = [[UIView alloc] init];
    }
    return _separateView;
}

- (UIView *)interactBgView
{
    if (!_interactBgView) {
        _interactBgView = [[UIView alloc] init];
        _interactBgView.size = CGSizeMake(81, 16);
        _interactBgView.userInteractionEnabled = YES;
        
        [_interactBgView addSubview:self.praiseBtn];
        [_interactBgView addSubview:self.praiseLabel];
        [_interactBgView addSubview:self.commentBtn];
        [_interactBgView addSubview:self.commentLabel];
    }
    return _interactBgView;
}

- (FDMyTopicImageView *)topicImageView
{
    if (!_topicImageView) {
        _topicImageView = [[FDMyTopicImageView alloc] init];
    }
    return _topicImageView;
}

- (UIView *)placeHolderView
{
    if (!_placeHolderView) {
        _placeHolderView = [[UIView alloc] init];
        _placeHolderView.frame = CGRectMake(0, 0, kSWidth, 7);
        _placeHolderView.backgroundColor = [UIColor colorWithRed:237/255.f green:237/255.f blue:237/255.f alpha:1];
    }
    return _placeHolderView;
}

@end
