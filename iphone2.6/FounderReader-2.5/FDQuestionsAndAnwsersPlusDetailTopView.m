//
//  FDQuestionsAndAnwsersPlusDetailTopView.m
//  FounderReader-2.5
//
//  Created by Julian on 2017/3/15.
//
//

#import "FDQuestionsAndAnwsersPlusDetailTopView.h"
#import "FDQuestionsAndAnwsersPlusDetailModel.h"
#import "NSString+Helper.h"
#import "UIView+Extention.h"
#import "ColumnBarConfig.h"
#import "UIButton+Block.h"
#import "UIImageView+WebCache.h"
#import "UIView + BlurBackgroud.h"

@interface FDQuestionsAndAnwsersPlusDetailTopView()

@property (nonatomic, strong) UIView *attentionBgView;
@property (nonatomic, strong) UILabel *attentionCountLabel;
@property (nonatomic, strong) UIImageView *avaterImageView;

@end

@implementation FDQuestionsAndAnwsersPlusDetailTopView

- (instancetype)init
{
    if (self = [super init]) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI
{
    self.backgroundColor = [UIColor clearColor];
    
    [self addSubview:self.titleLable];
    [self addSubview:self.attentionBgView];
    
    [self.attentionBgView addSubview:self.attentionCountLabel];
    [self.attentionBgView addSubview:self.avaterImageView];
    [self.attentionBgView addSubview:self.attentionBtn];
}

- (void)setDetailModel:(FDQuestionsAndAnwsersPlusDetailModel *)detailModel
{
    _detailModel = detailModel;
    
    
    _titleLable.textColor = colorWithHexString(@"ffffff");
    _titleLable.textAlignment = NSTextAlignmentCenter;
    //加阴影
    _titleLable.font = [UIFont systemFontOfSize:19];
    _titleLable.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    _titleLable.shadowOffset = CGSizeMake(0.5, 0.5);
    
    _titleLable.numberOfLines = 3;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = (kSWidth == 375 ||kSWidth == 414) ? 6 : 3;
    NSDictionary *attributes = @{
                                 NSFontAttributeName:[UIFont systemFontOfSize:19],
                                 NSParagraphStyleAttributeName:paragraphStyle
                                 };
    NSAttributedString *topTitleStr = [[NSAttributedString alloc] initWithString:_detailModel.title attributes:attributes];
    NSStringDrawingOptions options  = NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
    CGRect topTitleRect = [topTitleStr boundingRectWithSize:CGSizeMake(kSWidth*3/4.0f, 0) options:options context:nil];
    _titleLable.frame = CGRectMake((kSWidth-topTitleRect.size.width)/2.0f,(kSWidth/2.0f-topTitleRect.size.height)/2.0f-kNavBarHeight,topTitleRect.size.width,topTitleRect.size.height);
    _titleLable.attributedText = topTitleStr;
    
    CGFloat attentionBgViewH = 30;
    _attentionBgView.frame = CGRectMake(0, self.height-attentionBgViewH, kSWidth, attentionBgViewH);
    _attentionBgView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    
    CGFloat avaterImageViewW = 60;
    _avaterImageView.frame = CGRectMake((_attentionBgView.width-avaterImageViewW)/2.0f, (_attentionBgView.height-avaterImageViewW)/2.0f, avaterImageViewW, avaterImageViewW);
    [_avaterImageView sd_setImageWithURL:[NSURL URLWithString:_detailModel.authorFace] placeholderImage:[UIImage imageNamed:@"me_icon_head-app"]];
    _avaterImageView.layer.masksToBounds = YES;
    _avaterImageView.layer.cornerRadius = avaterImageViewW/2.0f;
    _avaterImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    _avaterImageView.layer.borderWidth = 2.0f;
    
    NSString *attentionCount = [NSString stringWithFormat:@"%ld%@",_detailModel.interestCount.integerValue,NSLocalizedString(@"人关注",nil)];
    CGSize attentionCountSize = [attentionCount sizeWithFont:15 LineSpacing:0 maxSize:CGSizeMake(CGFLOAT_MAX, 30)];
    _attentionCountLabel.frame = CGRectMake((_avaterImageView.x-attentionCountSize.width)/2.0f, (attentionBgViewH-attentionCountSize.height)/2.0f, attentionCountSize.width+5, attentionCountSize.height);
    _attentionCountLabel.font = [UIFont systemFontOfSize:15];
    _attentionCountLabel.text = attentionCount;
    _attentionCountLabel.textColor = [ColumnBarConfig sharedColumnBarConfig].column_all_color;
    
    CGFloat attentionW = 65;
    _attentionBtn.frame = CGRectMake(CGRectGetMaxX(_avaterImageView.frame)+((kSWidth-CGRectGetMaxX(_avaterImageView.frame))-attentionW)/2.0f, 3, attentionW, attentionBgViewH-6);
    _attentionBtn.layer.masksToBounds = YES;
    _attentionBtn.layer.cornerRadius = 3;
    _attentionBtn.layer.borderWidth = 0.8f;
    _attentionBtn.layer.borderColor = [ColumnBarConfig sharedColumnBarConfig].column_all_color.CGColor;
    [_attentionBtn setTitleColor:[ColumnBarConfig sharedColumnBarConfig].column_all_color forState:UIControlStateNormal];
    [_attentionBtn setTitle:NSLocalizedString(@"关注Ta",nil) forState:UIControlStateNormal];
    [_attentionBtn setTitle:NSLocalizedString(@"已关注",nil) forState:UIControlStateSelected];
    _attentionBtn.selected = _detailModel.isFollow;
    _attentionBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    __weak __typeof(self)weakSelf = self;
    [_attentionBtn addAction:^(UIButton *btn) {
        if (weakSelf.attentionBlock)
            weakSelf.attentionBlock(btn);
    }];
}

// MARK:LazyLoad
- (UILabel *)titleLable {
    if (!_titleLable)
        _titleLable = [[UILabel alloc] init];
    return _titleLable;
}

- (UIView *)attentionBgView {
    if (!_attentionBgView) {
        _attentionBgView = [[UIView alloc] init];
        _attentionBgView.userInteractionEnabled = YES;
    }
    return _attentionBgView;
}

- (UILabel *)attentionCountLabel {
    if (!_attentionCountLabel)
        _attentionCountLabel = [[UILabel alloc] init];
    return _attentionCountLabel;
}

- (UIImageView *)avaterImageView {
    if (!_avaterImageView) {
        _avaterImageView = [[UIImageView alloc] init];\
    }
    return _avaterImageView;
}

- (UIButton *)attentionBtn
{
    if (!_attentionBtn) {
        _attentionBtn = [[UIButton alloc] init];
    }
    return _attentionBtn;
}

@end
