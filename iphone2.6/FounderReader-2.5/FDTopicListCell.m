//
//  FDTopicListCell.m
//  FounderReader-2.5
//
//  Created by Julian on 2017/4/27.
//
//

#import "FDTopicListCell.h"
#import "UIView+Extention.h"
#import "UIImageView+WebCache.h"
#import "NewsListConfig.h"
#import "NSMutableAttributedString + Extension.h"
#import "ColumnBarConfig.h"
#import "UIImage+vImage.h"
#import "UIView + BlurBackgroud.h"

@interface FDTopicListCell()

@property(nonatomic, strong)Article *topicArticle;

@property (strong, nonatomic) UIImageView *mainImageView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *attentionLabel;
@property (strong, nonatomic) UILabel *joinLabel;
@property (strong, nonatomic) UIView *seprateView;
@property (strong, nonatomic) UIView *placeHolderView;

@property (strong, nonatomic) NSDictionary *topicConfigDict;

@end

@implementation FDTopicListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupContentView];
    }
    return self;
}

- (void)setupContentView
{
    [self.contentView addSubview:self.placeHolderView];
    [self.contentView addSubview:self.mainImageView];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.attentionLabel];
    [self.contentView addSubview:self.joinLabel];
    [self.contentView addSubview:self.attentionBtn];
    [self.contentView addSubview:self.seprateView];
}

- (void)setTopicArticle:(Article *)topicArticle IsFirstRow:(BOOL)isFirstRow
{
    _topicArticle = topicArticle;
    _isFirstRow = isFirstRow;
    
    if (_isFromMyTopic)
        [_attentionBtn removeFromSuperview];
    
    self.backgroundColor = [UIColor whiteColor];
    if (topicArticle.isBigPic)
        [self configBigCell];
    else
        [self configMiddleCell];
}

- (void)configBigCell
{
    CGFloat mainImageViewW = kSWidth-15*2;
    CGFloat mainImageViewH = mainImageViewW*9/16.0f;
    CGFloat contentViewH = !_isFirstRow ? mainImageViewH + 8*2 + 7 : mainImageViewH + 8*2 + 2*7;
    
    _placeHolderView.hidden = !self.isFirstRow;
    
    if (!_placeHolderView.hidden)
        _mainImageView.frame = CGRectMake(15, CGRectGetMaxY(_placeHolderView.frame)+8, mainImageViewW, mainImageViewH);
    else
        _mainImageView.frame = CGRectMake(15, 8, mainImageViewW, mainImageViewH);
    _mainImageView.layer.masksToBounds = YES;
    _mainImageView.layer.cornerRadius = 4.0f;
    [_mainImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@@!md169", _topicArticle.imgUrl]] placeholderImage:[Global getBgImage169] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//        if (image)
//            _mainImageView.image = [UIImage boxblurImage:image withBlurNumber:0.1];//不知为何有些图片 变成了红色
    }];
    [_mainImageView addBlurBackgroudWithStyle:UIBlurEffectStyleDark atIndex:1 alpha:0.2];
    
    _titleLabel.textColor = colorWithHexString(@"ffffff");
    _titleLabel.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    _titleLabel.shadowOffset = CGSizeMake(0.5, 0.5);
    CGFloat fontSize = 19.0f;
    _titleLabel.font = [UIFont systemFontOfSize:fontSize];
    _titleLabel.numberOfLines = 2;
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = (kSWidth == 375 ||kSWidth == 414) ? 6 : 3;
    NSDictionary *attributes = @{
                                 NSFontAttributeName:[UIFont systemFontOfSize:fontSize],
                                 NSParagraphStyleAttributeName:paragraphStyle
                                 };
    NSAttributedString *topTitleStr = [[NSAttributedString alloc] initWithString:_topicArticle.title attributes:attributes];
    NSStringDrawingOptions options  = NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
    CGRect topTitleRect = [topTitleStr boundingRectWithSize:CGSizeMake(kSWidth-40*2, 0) options:options context:nil];
    _titleLabel.frame = CGRectMake((kSWidth-topTitleRect.size.width)/2.0f, 0, topTitleRect.size.width, topTitleRect.size.height);
    _titleLabel.centerY = _mainImageView.centerY;//self.contentView.centerY是cell系统默认的高度的中心
    _titleLabel.attributedText = topTitleStr;
    _titleLabel.textAlignment = NSTextAlignmentCenter;//这里设置才有用
    
    NSString *interestCountStr;
    if (_topicArticle.interestCount.integerValue < 0)
        interestCountStr = @"0";
    else if (_topicArticle.interestCount.integerValue > 9999)
        interestCountStr = @"9999+";
    else
        interestCountStr = [NSString stringWithFormat:@"%lld", _topicArticle.interestCount.longLongValue];
    
    //先赋值,再动态获取视图大小sizeToFit
    _attentionLabel.text = [NSString stringWithFormat:@"%@%@",interestCountStr,NSLocalizedString([self.topicConfigDict objectForKey:FDTopicFollowWordKey], nil)];
    _attentionLabel.font = [UIFont systemFontOfSize:14];
    _attentionLabel.textAlignment = NSTextAlignmentCenter;//注：sizeToFit的NSTextAlignmentLeft和TextAlignmentRight生成的尺寸有大区别
    [_attentionLabel sizeToFit];
    _attentionLabel.frame = CGRectMake(15+10, contentViewH-7-8-10-20,_attentionLabel.width+12,20);
    _attentionLabel.textColor = colorWithHexString(@"ffffff");
    _attentionLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
    _attentionLabel.layer.borderColor = colorWithHexString(@"ffffff").CGColor;
    _attentionLabel.layer.borderWidth = 0.5f;
    _attentionLabel.layer.masksToBounds = YES;
    _attentionLabel.layer.cornerRadius = 2.5f;
    
    NSString *topicCountStr = nil;
    if (_topicArticle.topicCount.integerValue < 0)
        topicCountStr = @"0";
    else if (_topicArticle.topicCount.integerValue > 9999)
        topicCountStr = @"9999+";
    else
        topicCountStr = [NSString stringWithFormat:@"%lld", _topicArticle.topicCount.longLongValue];
    _joinLabel.text = [NSString stringWithFormat:@"%@%@", topicCountStr, NSLocalizedString([_topicConfigDict objectForKey:FDTopicJoinWordKey], nil)];
    _joinLabel.textAlignment = NSTextAlignmentCenter;
    _joinLabel.font = [UIFont systemFontOfSize:14];
    [_joinLabel sizeToFit];
    _joinLabel.frame = CGRectMake(CGRectGetMaxX(_attentionLabel.frame)+10, 0,_joinLabel.width+12,20);
    _joinLabel.centerY = _attentionLabel.centerY;
    _joinLabel.textColor = colorWithHexString(@"ffffff");
    _joinLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
    _joinLabel.layer.borderColor = colorWithHexString(@"ffffff").CGColor;
    _joinLabel.layer.borderWidth = 0.5f;
    _joinLabel.layer.masksToBounds = YES;
    _joinLabel.layer.cornerRadius = 2.5f;
    
    _attentionBtn.frame = CGRectMake(kSWidth-15-10-55, 0, 55, 20);
    _attentionBtn.centerY = _attentionLabel.centerY;
    _attentionBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [_attentionBtn setTitleColor:colorWithHexString(@"ffffff") forState:UIControlStateNormal];
    _attentionBtn.layer.cornerRadius = _attentionBtn.height/2.0f;
    _attentionBtn.layer.borderWidth = 0.5f;
    if (_topicArticle.isFollow && [Global userId].length) {
        _attentionBtn.layer.borderColor = colorWithHexString(@"dcdcdc").CGColor;
        _attentionBtn.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
        [_attentionBtn setTitle:NSLocalizedString([self.topicConfigDict objectForKey:FDTopicFollowedWordKey], nil) forState:UIControlStateNormal];
    } else {
        _attentionBtn.layer.borderWidth = 0;
        _attentionBtn.backgroundColor = [ColumnBarConfig sharedColumnBarConfig].column_all_color;
        [_attentionBtn setTitle:NSLocalizedString([self.topicConfigDict objectForKey:FDTopicFollowWordKey], nil) forState:UIControlStateNormal];
    }
    
    _seprateView.frame = CGRectMake(0, contentViewH-7, kSWidth, 7);
    _seprateView.backgroundColor = [UIColor colorWithRed:237/255.f green:237/255.f blue:237/255.f alpha:1];
    
}

- (void)configMiddleCell
{
    CGFloat contentViewH = [NewsListConfig sharedListConfig].middleCellHeight + 7;
    CGFloat mainImageViewH = contentViewH - 10*2 - 7;
    CGFloat mainImageViewW = !_isFirstRow ? mainImageViewH * 16/9.0f : mainImageViewH * 16/9.0f + 7;
    
    _placeHolderView.hidden = !self.isFirstRow;
    
    if (!_placeHolderView.hidden)
        _mainImageView.frame = CGRectMake(kSWidth-15-mainImageViewW, CGRectGetMaxY(_placeHolderView.frame)+10, mainImageViewW, mainImageViewH);
    else
        _mainImageView.frame = CGRectMake(kSWidth-15-mainImageViewW, 10, mainImageViewW, mainImageViewH);
    _mainImageView.layer.masksToBounds = YES;
    _mainImageView.layer.cornerRadius = 4.0f;
    [_mainImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@@!md169", _topicArticle.imgUrl]] placeholderImage:[Global getBgImage169]];
    
    _titleLabel.textColor = _topicArticle.isRead ? [NewsListConfig sharedListConfig].middleCellSummaryTextColor : colorWithHexString(@"333333");
    _titleLabel.numberOfLines = 2;
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    CGFloat fontSize = [NewsListConfig sharedListConfig].middleCellTitleFontSize;
    _titleLabel.font = [UIFont systemFontOfSize:fontSize];
    _titleLabel.textColor = colorWithHexString(@"333333");
    _titleLabel.shadowColor = nil;
    _titleLabel.shadowOffset = CGSizeMake(0, 0);
    CGFloat lineSpacing = (kSWidth == 375 ||kSWidth == 414) ? 6 : 3;
    NSMutableAttributedString *string = [NSMutableAttributedString attributedStringWithString:_topicArticle.title Font:[UIFont systemFontOfSize:fontSize] lineSpacing:lineSpacing];
    CGFloat titleLabelW = kSWidth-15*2-6-mainImageViewW;
    CGFloat titleLabelH = [string boundingHeightWithSize:CGSizeMake(titleLabelW, 0) font:[UIFont systemFontOfSize:fontSize] lineSpacing:lineSpacing maxLines:2];
    _titleLabel.frame = CGRectMake(15, _mainImageView.y, titleLabelW, titleLabelH);
    _titleLabel.attributedText = string;
    
    _attentionBtn.frame = CGRectMake(_mainImageView.x-10-55, contentViewH-17-20, 55, 20);
    _attentionBtn.titleLabel.font = [UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleCellDateFontSize];
    _attentionBtn.layer.cornerRadius = _attentionBtn.height/2.0f;
    _attentionBtn.layer.borderWidth = 0.5f;
    if (_topicArticle.isFollow && [Global userId].length) {
        [_attentionBtn setTitleColor:colorWithHexString(@"666666") forState:UIControlStateNormal];
        _attentionBtn.layer.borderColor = colorWithHexString(@"dcdcdc").CGColor;
        _attentionBtn.backgroundColor = [UIColor clearColor];
        [_attentionBtn setTitle:NSLocalizedString([self.topicConfigDict objectForKey:FDTopicFollowedWordKey], nil) forState:UIControlStateNormal];
    } else {
        _attentionBtn.layer.borderWidth = 0;
        [_attentionBtn setTitleColor:colorWithHexString(@"ffffff") forState:UIControlStateNormal];
        _attentionBtn.backgroundColor = [ColumnBarConfig sharedColumnBarConfig].column_all_color;
        [_attentionBtn setTitle:NSLocalizedString([self.topicConfigDict objectForKey:FDTopicFollowWordKey], nil) forState:UIControlStateNormal];
    }
    
    NSString *interestCountStr;
    if (_topicArticle.interestCount.integerValue < 0)
        interestCountStr = @"0";
    else if (_topicArticle.interestCount.integerValue > 9999)
        interestCountStr = @"9999+";
    else
        interestCountStr = [NSString stringWithFormat:@"%lld", _topicArticle.interestCount.longLongValue];
    
    _attentionLabel.text = [NSString stringWithFormat:@"%@%@",interestCountStr, NSLocalizedString([self.topicConfigDict objectForKey:FDTopicFollowWordKey], nil)];
    [_attentionLabel sizeToFit];
    CGSize attentionSize = [_attentionLabel.text sizeWithFont:14 LineSpacing:0 maxSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
    _attentionLabel.frame = CGRectMake(15, 0, attentionSize.width, 20);
    _attentionLabel.centerY = _attentionBtn.centerY;
    _attentionLabel.font = [UIFont systemFontOfSize:14];
    _attentionLabel.textColor = colorWithHexString(@"999999");
    _attentionLabel.backgroundColor = [UIColor clearColor];
    _attentionLabel.layer.borderWidth = 0;
    
    NSString *topicCountStr;
    if (_topicArticle.topicCount.integerValue < 0)
        topicCountStr = @"0";
    else if (_topicArticle.topicCount.integerValue > 9999)
        topicCountStr = @"9999+";
    else
        topicCountStr = [NSString stringWithFormat:@"%lld", _topicArticle.topicCount.longLongValue];
    
    _joinLabel.text = [NSString stringWithFormat:@"%@%@",topicCountStr, NSLocalizedString([self.topicConfigDict objectForKey:FDTopicJoinWordKey], nil)];
    [_joinLabel sizeToFit];
    _joinLabel.textAlignment = NSTextAlignmentLeft;
    _joinLabel.origin = CGPointMake(CGRectGetMaxX(_attentionLabel.frame)+8, 0);
    _joinLabel.centerY = _attentionLabel.centerY;
    _joinLabel.font = [UIFont systemFontOfSize:14];
    _joinLabel.textColor = colorWithHexString(@"999999");
    _joinLabel.backgroundColor = [UIColor clearColor];
    _joinLabel.layer.borderWidth = 0;
    
    _seprateView.frame = CGRectMake(0, contentViewH-7, kSWidth, 7);
    _seprateView.backgroundColor = [UIColor colorWithRed:237/255.f green:237/255.f blue:237/255.f alpha:1];
}

#pragma mark - 短按/长按时回调方法 delegate
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    if (selected)//因为此方法加载初始cell时也要回调
        [self setAttentionBtnColorByclick];
}
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    if (highlighted)
        [self setAttentionBtnColorByclick];
}
//- (void)layoutSubviews
//{
//    [super layoutSubviews];
//    [self setAttentionBtnColorByclick];
//}

- (void)setAttentionBtnColorByclick
{
    if (self.topicArticle.isBigPic)
        _attentionBtn.backgroundColor = !self.topicArticle.isFollow ? [ColumnBarConfig sharedColumnBarConfig].column_all_color : [UIColor clearColor];
    else
        _attentionBtn.backgroundColor = !self.topicArticle.isFollow ? [ColumnBarConfig sharedColumnBarConfig].column_all_color : [UIColor clearColor];
}

///MARK: Lazy

- (UIView *)seprateView
{
    if (!_seprateView) {
        _seprateView = [[UIImageView alloc] init];
    }
    return _seprateView;
}

- (UIImageView *)mainImageView
{
    if (!_mainImageView) {
        _mainImageView = [[UIImageView alloc] init];
    }
    return _mainImageView;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
    }
    return _titleLabel;
}

- (UILabel *)attentionLabel
{
    if (!_attentionLabel) {
        _attentionLabel = [[UILabel alloc] init];
    }
    return _attentionLabel;
}

- (UILabel *)joinLabel
{
    if (!_joinLabel) {
        _joinLabel = [[UILabel alloc] init];
    }
    return _joinLabel;
}

- (UIButton *)attentionBtn
{
    if (!_attentionBtn) {
        _attentionBtn = [[UIButton alloc] init];
    }
    return _attentionBtn;
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

- (NSDictionary *)topicConfigDict
{
    //实时刷新
    _topicConfigDict = [[NSUserDefaults standardUserDefaults] objectForKey:FDTopicConfigsNameKey];
    return _topicConfigDict;
}

@end
