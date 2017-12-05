//
//  FDQuestionsAndAnwsersPlusDetailTopHeaderView.m
//  FounderReader-2.5
//
//  Created by Julian on 2017/3/23.
//
//

#import "FDQuestionsAndAnwsersPlusDetailHeaderView.h"
#import "NSString+Helper.h"
#import "FDQuestionsAndAnwsersPlusDetailModel.h"
#import "UIButton+Block.h"
#import "UIView+Extention.h"
#import "NSString+TimeStringHandler.h"

@interface FDQuestionsAndAnwsersPlusDetailHeaderView()

@property (nonatomic, assign)BOOL isShow;
@property (nonatomic, assign)CGRect summaryRect;

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *occupationLabel;
@property (nonatomic, strong) UILabel *summaryLabel;
@property (nonatomic, strong) UIButton *moreBtn;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UILabel *askCountLabel;
@property (nonatomic, strong) UILabel *askStatusLabel;
@property (nonatomic, strong) UILabel *timeLabel;

@end

@implementation FDQuestionsAndAnwsersPlusDetailHeaderView

- (instancetype)init
{
    if (self = [super init]) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI
{
    self.backgroundColor = [UIColor whiteColor];
    
    [self addSubview:self.nameLabel];
    [self addSubview:self.occupationLabel];
    [self addSubview:self.summaryLabel];
    [self addSubview:self.moreBtn];
    [self addSubview:self.bottomView];
    
    [self.bottomView addSubview:self.askCountLabel];
    [self.bottomView addSubview:self.askStatusLabel];
    [self.bottomView addSubview:self.timeLabel];
}

- (void)setDetailModel:(FDQuestionsAndAnwsersPlusDetailModel *)detailModel
{
    _detailModel = detailModel;
    
    CGSize nameSize = [_detailModel.authorName sizeWithFont:18 LineSpacing:0 maxSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
    _nameLabel.frame = CGRectMake((kSWidth-nameSize.width)/2.0f, 25, nameSize.width, nameSize.height);
    _nameLabel.text = _detailModel.authorName;
    _nameLabel.font = [UIFont systemFontOfSize:18];
    
    CGSize occupationSize = [_detailModel.authorTitle sizeWithFont:16 LineSpacing:0 maxSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
    _occupationLabel.frame = CGRectMake((kSWidth-occupationSize.width)/2.0f, CGRectGetMaxY(_nameLabel.frame)+5, occupationSize.width, occupationSize.height);
    _occupationLabel.text = _detailModel.authorTitle;
    _occupationLabel.textColor = [UIColor grayColor];
    _occupationLabel.font = [UIFont systemFontOfSize:16];
    
    _summaryLabel.font = [UIFont systemFontOfSize:18];
    _summaryLabel.numberOfLines = 3;
    //_summaryLabel.textAlignment = NSTextAlignmentCenter; 对于属性文本无效
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = (kSWidth == 375 ||kSWidth == 414) ? 7 : 3;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    NSDictionary *attributes = @{
                   NSFontAttributeName:[UIFont systemFontOfSize:18],
                   NSForegroundColorAttributeName:colorWithHexString(@"333333"),
                   NSParagraphStyleAttributeName:paragraphStyle
                   };
    NSAttributedString *topSummaryStr = [[NSAttributedString alloc] initWithString:_detailModel.authorDesc attributes:attributes];
    NSStringDrawingOptions options  = NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
    _summaryRect = [topSummaryStr boundingRectWithSize:CGSizeMake(kSWidth-20, 0) options:options context:nil];
    _summaryRect = [_detailModel.authorDesc boundingRectWithSize:CGSizeMake(kSWidth-20, 0) options:options attributes:attributes context:nil];
    _summaryLabel.frame = CGRectMake(10, CGRectGetMaxY(_occupationLabel.frame)+10,kSWidth-20,_summaryRect.size.height);
    _summaryLabel.attributedText = topSummaryStr;
    
    UIImage *moreImage = [UIImage imageNamed:@"icon-more-close"];
    _moreBtn.frame = CGRectMake((kSWidth-moreImage.size.width)/2.0f,CGRectGetMaxY(_summaryLabel.frame)+10, moreImage.size.width+10,moreImage.size.height+10);
    // 图片往上移动
    _moreBtn.imageEdgeInsets = UIEdgeInsetsMake(-5, 5, 5, 5);
    [_moreBtn setImage:[UIImage imageNamed:@"icon-more-close"] forState:UIControlStateNormal];
    [_moreBtn setImage:[UIImage imageNamed:@"icon-more-open"] forState:UIControlStateSelected];
    _moreBtn.hidden = YES;
    __weak __typeof(self)weakSelf = self;
    [_moreBtn addAction:^(UIButton *btn) {
        btn.selected = !btn.selected;
        _isShow = btn.selected;
        [weakSelf layoutUI];
    }];
    
    _bottomView.frame = CGRectMake(0, CGRectGetMaxY(_summaryLabel.frame)+10, kSWidth, 25);
    _bottomView.backgroundColor = UIColorFromString(@"246,246,246");
    
    NSString *askCount = [NSString stringWithFormat:@"%ld%@",_detailModel.askCount.integerValue,NSLocalizedString(@"个提问",nil)];
    CGSize askCountSize = [askCount sizeWithFont:14 LineSpacing:0 maxSize:CGSizeMake(CGFLOAT_MAX, _bottomView.height)];
    _askCountLabel.frame = CGRectMake(10, 0, askCountSize.width, _bottomView.height);
    _askCountLabel.font = [UIFont systemFontOfSize:14];
    _askCountLabel.textColor = colorWithHexString(@"999999");
    _askCountLabel.text = askCount;
    
    //0未发布、1已发布、2删除、3关闭
    if ([_detailModel.beginTime isLaterThanNowWithDateFormat:TimeToSeconds]) {
        _askStatusLabel.text = NSLocalizedString(@"尚未开始", nil);
        NSString *string = NSLocalizedString(@"开始", nil);
        _timeLabel.text = [NSString stringWithFormat:@"%@ %@", [_detailModel.beginTime timeStringForQAndA], string];
    } else if ([_detailModel.endTime isLaterThanNowWithDateFormat:TimeToSeconds]) {
        _askStatusLabel.text = NSLocalizedString(@"提问进行中", nil);
        NSString *string = NSLocalizedString(@"结束", nil);
        _timeLabel.text = [NSString stringWithFormat:@"%@ %@", [_detailModel.endTime timeStringForQAndA], string];
    } else {
        _askStatusLabel.text = NSLocalizedString(@"提问已结束", nil);
        _timeLabel.text = @"";
    }
    
    //    [_timeLabel sizeToFit]; ==因为sizeToFit]不是特别精确,这里布局不能用
    CGSize timeSize = [_timeLabel.text sizeWithFont:14 LineSpacing:0 maxSize:CGSizeMake(CGFLOAT_MAX, _bottomView.height)];
    _timeLabel.frame = CGRectMake(kSWidth-10-timeSize.width, 0, timeSize.width, _bottomView.height);
    _timeLabel.textColor = colorWithHexString(@"999999");
    _timeLabel.font = [UIFont systemFontOfSize:14];
    
    //前提是已经设好了text值
    [_askStatusLabel sizeToFit];
    _askStatusLabel.textAlignment = NSTextAlignmentRight;//因为sizeToFit]不是特别精确
    _askStatusLabel.origin = CGPointMake(_timeLabel.x-5-_askStatusLabel.width, (_bottomView.height-_askStatusLabel.height)/2.0f);
    _askStatusLabel.font = [UIFont systemFontOfSize:14];
    _askStatusLabel.textColor = colorWithHexString(@"999999");
    
    [self layoutUI];
}

- (void)layoutUI
{
    __weak __typeof(self)weakSelf = self;
//    [UIView animateWithDuration:0.4f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^(){
        if (_summaryRect.size.height > 80) {
            // 文字大于三行，显示展开收起按钮
            _moreBtn.hidden = NO;
            _summaryLabel.height = _summaryRect.size.height;
            if (_isShow) {
                _summaryLabel.numberOfLines = 0;
            } else {
                _summaryLabel.numberOfLines = 4;
                // 虽然可以不用变为80，但为了避免高度不变文字行数变少导致居中显示了。
                _summaryLabel.height = 80;
            }
        } else {
            // 文字小于三行，隐藏展开收起按钮
            _moreBtn.hidden = YES;
            _summaryLabel.numberOfLines = 3;
        }
        _moreBtn.y = CGRectGetMaxY(_summaryLabel.frame)+10;
        _bottomView.y = _moreBtn.hidden ? CGRectGetMaxY(_summaryLabel.frame)+10 : CGRectGetMaxY(_moreBtn.frame)+10;
        weakSelf.frame = CGRectMake(0, 0, kSWidth, CGRectGetMaxY(_bottomView.frame));
//    } completion:^(BOOL finished) {
        //千万不能在这里赋值header高度，因为这是异步的，而controller会先用到，不能让它后执行
//        weakSelf.frame = CGRectMake(0, 0, kSWidth, CGRectGetMaxY(_bottomView.frame));
//    }];
    if (self.headerMoreBlock)
        self.headerMoreBlock();
}

- (UILabel *)nameLabel
{
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
    }
    return _nameLabel;
}

- (UILabel *)occupationLabel
{
    if (!_occupationLabel) {
        _occupationLabel = [[UILabel alloc] init];
    }
    return _occupationLabel;
}

- (UILabel *)summaryLabel
{
    if (!_summaryLabel) {
        _summaryLabel = [[UILabel alloc] init];
    }
    return _summaryLabel;
}

- (UIButton *)moreBtn
{
    if (!_moreBtn) {
        _moreBtn = [[UIButton alloc] init];
    }
    return _moreBtn;
}

- (UIView *)bottomView
{
    if (!_bottomView) {
        _bottomView = [[UIView alloc] init];
    }
    return _bottomView;
}

- (UILabel *)askCountLabel
{
    if (!_askCountLabel) {
        _askCountLabel = [[UILabel alloc] init];
    }
    return _askCountLabel;
}

- (UILabel *)askStatusLabel
{
    if (!_askStatusLabel) {
        _askStatusLabel = [[UILabel alloc] init];
    }
    return _askStatusLabel;
}

- (UILabel *)timeLabel
{
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
    }
    return _timeLabel;
}

@end
