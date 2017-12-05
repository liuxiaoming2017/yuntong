//
//  FDTopicPlusDetailCell.m
//  FounderReader-2.5
//
//  Created by snitsky on 2017/5/5.
//
//

#import "FDTopicPlusDetailCell.h"
#import "FDMyTopicImageView.h"
#import "FDTopicDetailListModel.h"
#import "UIView+Extention.h"
#import "UIImageView+WebCache.h"
#import "ColumnBarConfig.h"
#import "UIView + ExtendTouchRect.h"
#import "UIButton+Block.h"

#define kMarginH_15 15
#define kMarginH_10 10

@interface FDTopicPlusDetailCell()

@property (strong, nonatomic) FDTopicDetailListModel *topicModel;

@property (strong, nonatomic) UIImageView *avaterImageView;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *publishTimeLabel;
@property (strong, nonatomic) UIView *interactBgView;
@property (strong, nonatomic) UILabel *praiseLabel;
@property (strong, nonatomic) UIButton *commentBtn;
@property (strong, nonatomic) UILabel *commentLabel;
@property (strong, nonatomic) UILabel *contentLabel;
@property (strong, nonatomic) FDMyTopicImageView *topicImageView;
@property (strong, nonatomic) UIButton *moreBtn;
@property (strong, nonatomic) UIView *separateView;

@end

@implementation FDTopicPlusDetailCell

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
    [self.contentView addSubview:self.avaterImageView];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.publishTimeLabel];
    [self.contentView addSubview:self.interactBgView];
    [self.contentView addSubview:self.contentLabel];
    [self.contentView addSubview:self.topicImageView];
    [self.contentView addSubview:self.separateView];
    [self.contentView addSubview:self.moreBtn];
}

- (void)layoutCell:(FDTopicDetailListModel *)topicModel IsHeader:(BOOL)isHeader
{
    _topicModel = topicModel;
    
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    //"discussStatus": 0/1/2, //参与状态(0:待审核;1:已发布;2:驳回)
    _avaterImageView.frame = CGRectMake(kMarginH_15, kMarginH_15, 25, 25);
    _avaterImageView.layer.masksToBounds = YES;
    _avaterImageView.layer.cornerRadius = _avaterImageView.width/2.0f;
    [_avaterImageView sd_setImageWithURL:[NSURL URLWithString:topicModel.faceUrl] placeholderImage:[Global getBgImage11]];
    
    _nameLabel.frame = CGRectMake(CGRectGetMaxX(_avaterImageView.frame)+kMarginH_10, 13, kSWidth-CGRectGetMaxX(_avaterImageView.frame)-kMarginH_15*2, 16);
    _nameLabel.font = [UIFont systemFontOfSize:13];
    _nameLabel.textAlignment = NSTextAlignmentLeft;
    _nameLabel.textColor = [ColumnBarConfig sharedColumnBarConfig].column_all_color;
    _nameLabel.text = topicModel.nickName;
    
    _publishTimeLabel.frame = CGRectMake(_nameLabel.x, CGRectGetMaxY(_nameLabel.frame)+2, kSWidth-CGRectGetMaxX(_avaterImageView.frame)-kMarginH_15*2, 13.5);
    _publishTimeLabel.font = [UIFont systemFontOfSize:11.5];
    _publishTimeLabel.textAlignment = NSTextAlignmentLeft;
    _publishTimeLabel.textColor = colorWithHexString(@"999999");
    _publishTimeLabel.text = intervalSinceNow(topicModel.createTime);
    
    _praiseLabel.text = topicModel.praiseCount.stringValue;
    NSString *prasieKey = [NSString stringWithFormat:@"Topic_Praise_%ld", _topicModel.discussID.integerValue];
    BOOL isPraise = [[[NSUserDefaults standardUserDefaults] objectForKey:prasieKey] boolValue];
    _praiseLabel.textColor = isPraise ? [ColumnBarConfig sharedColumnBarConfig].column_all_color : colorWithHexString(@"999999");
    _praiseLabel.font = [UIFont systemFontOfSize:13];
    _praiseLabel.text = topicModel.praiseCount.stringValue;
    [_praiseLabel sizeToFit];
    _praiseLabel.textAlignment = NSTextAlignmentRight;
    [_praiseBtn setTouchExtendInset:UIEdgeInsetsMake(-50, -10, -10, -10)];
    _praiseBtn.selected = isPraise;
    
    _commentLabel.text = topicModel.commentCount.stringValue;
    NSString *commentKey = [NSString stringWithFormat:@"Topic_Comment_%ld", _topicModel.discussID.integerValue];
    BOOL isComment = [[[NSUserDefaults standardUserDefaults] objectForKey:commentKey] boolValue];
    _commentLabel.textColor = isComment ? [ColumnBarConfig sharedColumnBarConfig].column_all_color : colorWithHexString(@"999999");
    _commentLabel.font = [UIFont systemFontOfSize:13];
    _commentLabel.text = topicModel.commentCount.stringValue;
    [_commentLabel sizeToFit];
    _commentLabel.textAlignment = NSTextAlignmentRight;
    _commentBtn.selected = isComment;
    
    _interactBgView.width = _praiseLabel.width+5+_praiseBtn.width+10+_commentLabel.width+5+_commentBtn.width;
    _interactBgView.x = kSWidth-kMarginH_15-_interactBgView.width;
    _praiseLabel.origin = CGPointMake(0, 0);
    _praiseBtn.x = CGRectGetMaxX(_praiseLabel.frame)+5;
    _commentLabel.origin = CGPointMake(CGRectGetMaxX(_praiseBtn.frame)+kMarginH_10, 0);
    _commentBtn.x = CGRectGetMaxX(_commentLabel.frame)+5;
    _interactBgView.centerY = _avaterImageView.centerY;
    _praiseBtn.centerY = _praiseLabel.centerY;
    _commentBtn.centerY = _commentLabel.centerY;
    if (isHeader)
        _interactBgView.hidden = YES;
    
    // 内容=纯文字、内容=纯图片、内容=文字+图片
    _contentLabel.hidden = [NSString isNilOrEmpty:topicModel.content];
    if (!_contentLabel.hidden) {
        _contentLabel.frame = CGRectMake(_nameLabel.x, CGRectGetMaxY(_publishTimeLabel.frame)+kMarginH_10, kSWidth-kMarginH_15*2-25-kMarginH_10, topicModel.contentH);
        _contentLabel.textColor = colorWithHexString(@"333333");
        _contentLabel.font = [UIFont systemFontOfSize:15.25f];
        if (!isHeader)
            _contentLabel.numberOfLines = ![topicModel.pics count] ? 4 : 2;
        else
            _contentLabel.numberOfLines = 0;
        _contentLabel.attributedText = topicModel.attrContent;
    }
    
    _topicImageView.hidden = ![topicModel.pics count];
    if (!_topicImageView.hidden) {
        [_topicImageView removeFromSuperview];
        CGFloat topicImageY = _contentLabel.hidden ? CGRectGetMaxY(_publishTimeLabel.frame)+kMarginH_15 : CGRectGetMaxY(_contentLabel.frame)+kMarginH_15;
        CGRect imagesFrame = CGRectMake(_nameLabel.x, topicImageY, kSWidth-kMarginH_15-_nameLabel.x, topicModel.imagesH);
        _topicImageView = [FDMyTopicImageView TopicImageViewWithFrame:imagesFrame ImageArray:topicModel.pics IsHeader:isHeader ImageSize:topicModel.imagesSizeByCaculate];
        [self.contentView addSubview:_topicImageView];
    }
    
    //topicModel.contentH等于设置默认的高度，则实际高度大于了默认高度
    if (topicModel.contentH == 42 || topicModel.contentH == 46 || topicModel.contentH == 86 || topicModel.contentH == 98){
        _moreBtn.hidden = NO;
    } else {
        _moreBtn.hidden = !([topicModel.pics count] > 3);
    }
//    _moreBtn.hidden = isHeader;isHeader为YES隐藏more按钮，但isHeader为NO时并不一定显示
    if (isHeader)
        _moreBtn.hidden = YES;
    if (!_moreBtn.hidden) {
        _moreBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_moreBtn setTitle:NSLocalizedString(@"更多精彩内容 看详情", nil) forState:UIControlStateNormal];
        _moreBtn.titleLabel.textAlignment = NSTextAlignmentRight;
        [_moreBtn sizeToFit];
        CGFloat moreY = _topicImageView.hidden ? CGRectGetMaxY(_contentLabel.frame)+kMarginH_15 : CGRectGetMaxY(_topicImageView.frame)+kMarginH_15;
        _moreBtn.frame = CGRectMake(kSWidth-kMarginH_15-_moreBtn.width, moreY, _moreBtn.width, 16);
        [_moreBtn setTitleColor:[ColumnBarConfig sharedColumnBarConfig].column_all_color forState:UIControlStateNormal];
        _moreBtn.userInteractionEnabled = NO;//点击更多按钮如点击cell时设定
    }
    
    CGFloat separateY = 0;
    if (!_moreBtn.hidden) {
        separateY = CGRectGetMaxY(_moreBtn.frame)+kMarginH_15;
    }else {
        separateY = _topicImageView.hidden ? CGRectGetMaxY(_contentLabel.frame)+kMarginH_15 : CGRectGetMaxY(_topicImageView.frame)+kMarginH_15;
    }
    _separateView.frame = CGRectMake(0, separateY, kSWidth, 0.5);
    _separateView.backgroundColor = colorWithHexString(@"d5d5d5");
    if (isHeader)
        _separateView.hidden = YES;
}

- (void)updatePraiseCount:(NSString *)praiseCount
{
    _topicModel.praiseCount = [NSNumber numberWithInteger:praiseCount.integerValue];
    _praiseLabel.text = praiseCount;
    [_praiseLabel sizeToFit];
}

#pragma mark - lazy
- (UIImageView *)avaterImageView
{
    if (!_avaterImageView) {
        _avaterImageView = [[UIImageView alloc] init];
    }
    return _avaterImageView;
}

- (UILabel *)nameLabel
{
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
    }
    return _nameLabel;
}

- (UILabel *)contentLabel
{
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] init];
    }
    return _contentLabel;
}

- (FDMyTopicImageView *)topicImageView
{
    if (!_topicImageView) {
        _topicImageView = [[FDMyTopicImageView alloc] init];
    }
    return _topicImageView;
}

- (UIButton *)praiseBtn
{
    if (!_praiseBtn) {
        _praiseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_praiseBtn setImage:[UIImage imageNamed:@"topic_praise_normal"] forState:UIControlStateNormal];
        [_praiseBtn setImage:[UIImage imageNamed:@"topic_praise_press"] forState:UIControlStateSelected];
        [_praiseBtn sizeToFit];
        [_praiseBtn setTouchExtendInset:UIEdgeInsetsMake(-50, -10, -10, -10)];
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

- (UILabel *)publishTimeLabel
{
    if (!_publishTimeLabel) {
        _publishTimeLabel = [[UILabel alloc] init];
    }
    return _publishTimeLabel;
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

- (UIButton *)moreBtn
{
    if (!_moreBtn) {
        _moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    return _moreBtn;
}

- (NSNumber *)discussID
{
    return _topicModel.discussID;
}

@end
