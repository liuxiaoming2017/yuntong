//
//  FDTopicPlusDetailHeader.m
//  FounderReader-2.5
//
//  Created by snitsky on 2017/5/5.
//
//

#import "FDTopicPlusDetailHeader.h"
#import "UIView+Extention.h"
#import "UIImageView+WebCache.h"
#import "NSMutableAttributedString + Extension.h"
#import "ColumnBarConfig.h"
#import "NSDate+Extension.h"
#import "NSString+TimeStringHandler.h"
#import "UIView + BlurBackgroud.h"

@interface FDTopicPlusDetailHeader ()

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *descriptionLabel;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIView *sectionView;
@property (strong, nonatomic) UILabel *followCountLabel;
@property (strong, nonatomic) UILabel *endTimeLabel;

@property (strong, nonatomic) NSDictionary *topicConfigDict;

@end

@implementation FDTopicPlusDetailHeader

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.imageView];
    [self addSubview:self.titleLabel];
    [self addSubview:self.descriptionLabel];
    [self addSubview:self.followButton];
    [self addSubview:self.sectionView];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if (object == self.superview && [keyPath isEqualToString:@"contentOffset"]) {
        NSValue *newContentOffset = [change valueForKey:NSKeyValueChangeNewKey];
        NSValue *oldContentOffset = [change valueForKey:NSKeyValueChangeOldKey];
        if ([newContentOffset CGSizeValue].height != [oldContentOffset CGSizeValue].height) {
            [self layoutViewForContentOffsetY:[newContentOffset CGSizeValue].height];
        }
    }
}

- (void)layoutViewForContentOffsetY:(CGFloat)y {
    // self是tableview的子视图
    XYLog(@"ContentOffsetY0 = %f",y);
    self.y = y;
    if (y + FDTopicPlusDetailHeaderHeight+25 < 0) {
        //完全显示HeaderView阶段
        self.y = y;
        self.titleLabel.alpha = 1;
        self.descriptionLabel.alpha = 1;
        self.followButton.alpha = 1;
        self.navTitleLabel.alpha = 0;
        XYLog(@"ContentOffsetY1 = %f",y);
    } else if (y + kNavBarHeight +25 > 0) {
        //完全显示导航栏阶段
        self.y = y - FDTopicPlusDetailHeaderHeight + kNavBarHeight;
        self.titleLabel.alpha = 0;
        self.descriptionLabel.alpha = 0;
        self.followButton.alpha = 0;
        self.navTitleLabel.alpha = 1;
        XYLog(@"ContentOffsetY2 = %f",y);
    } else {
        //过渡阶段
        self.y = - FDTopicPlusDetailHeaderHeight-25;
        CGFloat subviewAlpha = - (y + kNavBarHeight) / (FDTopicPlusDetailHeaderHeight+25 - kNavBarHeight);
        self.titleLabel.alpha = subviewAlpha;
        self.descriptionLabel.alpha = subviewAlpha;
        self.followButton.alpha = subviewAlpha;
        self.navTitleLabel.alpha = 1 - subviewAlpha >= 0.5 ? 1 - subviewAlpha : 0;//避免相互重影
        XYLog(@"subviewAlpha = %f",subviewAlpha);
        XYLog(@"ContentOffsetY3 = %f",y);
    }
}

- (void)updateUIWithModel:(FDTopicPlusDetaiHeaderlModel *)model
{
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:model.imgUrl] placeholderImage:nil];
    [self.imageView addBlurBackgroudWithStyle:UIBlurEffectStyleDark atIndex:1 alpha:0.2];
    
    self.navTitleLabel.text = model.title;
    
    CGFloat lineSpacing = (kSWidth == 375 ||kSWidth == 414) ? 7 : 4;
    NSMutableAttributedString *titleString = [NSMutableAttributedString attributedStringWithString:model.title Font:[UIFont boldSystemFontOfSize:18] lineSpacing:lineSpacing];
    self.titleLabel.attributedText = titleString;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.y = self.titleLabel.attributedText.length > 19 ? 40 : 60;
    
    NSMutableAttributedString *descriptionString = [NSMutableAttributedString attributedStringWithString:model.topicPlusDescription Font:[UIFont systemFontOfSize:15] lineSpacing:lineSpacing-1];
    self.descriptionLabel.attributedText = descriptionString;
    self.descriptionLabel.textAlignment = NSTextAlignmentCenter;
    self.descriptionLabel.y = self.descriptionLabel.attributedText.length > 23 ? 20+FDTopicPlusDetailHeaderHeight/3 : 15+FDTopicPlusDetailHeaderHeight/3;
    
    _followButton.y = self.descriptionLabel.attributedText.length > 23 ? FDTopicPlusDetailHeaderHeight - 54*kSWidth/414.f : FDTopicPlusDetailHeaderHeight - 63*kSWidth/414.f;
    [_followButton setTitle:NSLocalizedString([self.topicConfigDict objectForKey:FDTopicFollowWordKey],nil) forState:UIControlStateNormal];
    [_followButton setTitle:NSLocalizedString([_topicConfigDict objectForKey:FDTopicFollowedWordKey],nil) forState:UIControlStateSelected];
    self.followButton.selected = model.isFollow;
    
    NSString *interestCountStr = model.interestCount.integerValue > 9999 ? @"9999+" : model.interestCount.stringValue;
    self.followCountLabel.text = [NSString stringWithFormat:@"%@ %@", interestCountStr, [_topicConfigDict objectForKey:FDTopicFollowWordKey]];
    [self.followCountLabel sizeToFit];
    self.followCountLabel.origin = CGPointMake(15, (25-self.followCountLabel.height)/2.0f);
    
    self.endTimeLabel.text = [NSDate intervalSinceEndDate:model.endTime];
    [self.endTimeLabel sizeToFit];
    self.endTimeLabel.origin = CGPointMake(kSWidth-15-self.endTimeLabel.width, (25-self.endTimeLabel.height)/2.0f);
//    self.endTimeLabel.hidden = ![model.endTime isLaterThanNowWithDateFormat:TimeToSeconds];
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, 40, kSWidth-25*2, FDTopicPlusDetailHeaderHeight/3)];
        _titleLabel.numberOfLines = 2;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
        _titleLabel.shadowOffset = CGSizeMake(0.5, 0.5);
    }
    return _titleLabel;
}

- (UILabel *)descriptionLabel {
    if (!_descriptionLabel) {
        _descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, 15+FDTopicPlusDetailHeaderHeight/3, kSWidth-25*2, FDTopicPlusDetailHeaderHeight/3)];
        _descriptionLabel.numberOfLines = 2;
        _descriptionLabel.textAlignment = NSTextAlignmentCenter;
        _descriptionLabel.textColor = [UIColor whiteColor];
        _descriptionLabel.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
        _descriptionLabel.shadowOffset = CGSizeMake(0.5, 0.5);
    }
    return _descriptionLabel;
}

- (UIButton *)followButton {
    if (!_followButton) {
        _followButton = [[UIButton alloc] init];
        [_followButton setBackgroundColor:[ColumnBarConfig sharedColumnBarConfig].column_all_color];
        [_followButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _followButton.titleLabel.font = [UIFont systemFontOfSize:15];
        _followButton.y = FDTopicPlusDetailHeaderHeight - 50;
        _followButton.width = 80;
        _followButton.centerX = self.centerX;
        _followButton.height = 30;
        _followButton.layer.cornerRadius = 15;
        _followButton.layer.masksToBounds = YES;
    }
    return _followButton;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.frame = CGRectMake(0, 0, kSWidth, FDTopicPlusDetailHeaderHeight);//headerView的frame
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        UIView *maskView = [[UIView alloc] initWithFrame:_imageView.frame];
        maskView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.2];
        [_imageView addSubview:maskView];
    }
    return _imageView;
}

- (UILabel *)navTitleLabel {
    if (!_navTitleLabel) {
        _navTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, 20, kSWidth-25*2, 44)];
        _navTitleLabel.alpha = 0;
        _navTitleLabel.textAlignment = NSTextAlignmentCenter;
        _navTitleLabel.font = [UIFont boldSystemFontOfSize:18];
        _navTitleLabel.textColor = [UIColor whiteColor];
        _navTitleLabel.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
        _navTitleLabel.shadowOffset = CGSizeMake(0.5, 0.5);
    }
    return _navTitleLabel;
}

- (UIView *)sectionView
{
    if (!_sectionView) {
        _sectionView = [[UIView alloc] init];
        _sectionView.backgroundColor = colorWithHexString(@"ededed");
        _sectionView.frame = CGRectMake(0, CGRectGetMaxY(self.imageView.frame), kSWidth, 25);
        [_sectionView addSubview:self.followCountLabel];
        [_sectionView addSubview:self.endTimeLabel];
    }
    return _sectionView;
}

- (UILabel *)followCountLabel
{
    if (!_followCountLabel) {
        _followCountLabel = [[UILabel alloc] init];
        _followCountLabel.font = [UIFont systemFontOfSize:13];
        _followCountLabel.textColor = colorWithHexString(@"999999");
    }
    return _followCountLabel;
}

- (UILabel *)endTimeLabel
{
    if (!_endTimeLabel) {
        _endTimeLabel = [[UILabel alloc] init];
        _endTimeLabel.font = [UIFont systemFontOfSize:13];
        _endTimeLabel.textAlignment = NSTextAlignmentRight;
        _endTimeLabel.textColor = colorWithHexString(@"999999");
    }
    return _endTimeLabel;
}

- (NSDictionary *)topicConfigDict
{
    //实时刷新
    _topicConfigDict = [[NSUserDefaults standardUserDefaults] objectForKey:FDTopicConfigsNameKey];
    return _topicConfigDict;
}

@end
