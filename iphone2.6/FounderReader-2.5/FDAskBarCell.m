//
//  FDAskBarCell.m
//  FounderReader-2.5
//
//  Created by Julian on 2017/3/30.
//
//

#import "FDAskBarCell.h"
#import "UIView+Extention.h"
#import "UIImageView+WebCache.h"
#import "NewsListConfig.h"
#import "NSMutableAttributedString + Extension.h"
#import "NSString+TimeStringHandler.h"

@interface FDAskBarCell()

@property (strong, nonatomic) UIView *seprateView;
@property (strong, nonatomic) UIImageView *mainImageView;
@property (strong, nonatomic) UIImageView *avaterView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *statusLabel;

@end

@implementation FDAskBarCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupContentView];
    }
    return self;
}

- (void)setupContentView
{
    [self.contentView addSubview:self.seprateView];
    [self.contentView addSubview:self.mainImageView];
    [self.contentView addSubview:self.avaterView];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.statusLabel];
    
    [self setupUI];
}

- (void)setupUI
{
    self.backgroundColor = [UIColor whiteColor];
    CGFloat placeholderHeight = 6;
    CGFloat avaterHeight = 60;
    
    _seprateView.frame = CGRectMake(0, 0, kSWidth, placeholderHeight);
    _seprateView.backgroundColor = [UIColor colorWithRed:237/255.f green:237/255.f blue:237/255.f alpha:1];
    
    _avaterView.frame = CGRectMake(10, placeholderHeight + 10, avaterHeight, avaterHeight);
    _avaterView.backgroundColor = [UIColor whiteColor];
    _avaterView.layer.masksToBounds = YES;
    _avaterView.layer.cornerRadius = avaterHeight/2.f;
    _avaterView.layer.borderColor = [UIColor whiteColor].CGColor;
    _avaterView.layer.borderWidth = 3;
    _avaterView.contentMode = UIViewContentModeScaleAspectFill;
    _mainImageView.frame = CGRectMake(0, placeholderHeight + 10 + avaterHeight/2.f, kSWidth, kSWidth / 3.f);
    
    _titleLabel.frame = CGRectMake(10, CGRectGetMaxY(_mainImageView.frame) + 10, kSWidth - 20, 50);
    
    _statusLabel.frame = CGRectMake(kSWidth - 10 - 38-3, CGRectGetMaxY(_mainImageView.frame) - 4 - 16-2, 38+3, 16+2);
    _statusLabel.textColor = [UIColor whiteColor];
    _statusLabel.font = [UIFont systemFontOfSize:11];
    _statusLabel.textAlignment = NSTextAlignmentCenter;
    _statusLabel.clipsToBounds = YES;
    _statusLabel.layer.cornerRadius = 2;
    _statusLabel.textColor = [UIColor whiteColor];
}

- (void)updateCellWithArticle:(Article *)article
{
    
    
    NSString *imageUrl = [NSString stringWithFormat:@"%@@!md31", article.imageUrlBig];
    [_avaterView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[Global getBgImage11]];
    [_mainImageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[Global getBgImage31]];
    
    if ([article.askStartTime isLaterThanNowWithDateFormat:TimeToMinutes]) {
        _statusLabel.text = NSLocalizedString(@"未开始", nil);
        _statusLabel.backgroundColor = [colorWithHexString(@"a292f5") colorWithAlphaComponent:.8];
    } else if ([article.askEndTime isLaterThanNowWithDateFormat:TimeToMinutes]) {
        _statusLabel.text = NSLocalizedString(@"进行中", nil);
        _statusLabel.backgroundColor = [colorWithHexString(@"00d1bc") colorWithAlphaComponent:.8];
        
    } else {
        _statusLabel.text = NSLocalizedString(@"已结束", nil);
        _statusLabel.backgroundColor = [colorWithHexString(@"666666") colorWithAlphaComponent:.8];
    }
    
    _titleLabel.numberOfLines = 0;
    if (article.isRead) {
        _titleLabel.textColor = [NewsListConfig sharedListConfig].middleCellSummaryTextColor;
    } else {
        _titleLabel.textColor = colorWithHexString(@"333333");
    }
    CGFloat lineSpacing;
    if (kSWidth == 375 ||kSWidth == 414) {
        lineSpacing = 7;
    }else
        lineSpacing = 4;
    NSMutableAttributedString *string = [NSMutableAttributedString attributedStringWithString:article.title Font:[UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleCellTitleFontSize] lineSpacing:lineSpacing];
    _titleLabel.height = [string boundingHeightWithSize:CGSizeMake(kSWidth-20, 0) font:[UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleCellTitleFontSize] lineSpacing:lineSpacing maxLines:2];
    _titleLabel.attributedText = string;
}

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

- (UIImageView *)avaterView
{
    if (!_avaterView) {
        _avaterView = [[UIImageView alloc] init];
    }
    return _avaterView;
}

- (UILabel *)statusLabel
{
    if (!_statusLabel) {
        _statusLabel = [[UILabel alloc] init];
    }
    return _statusLabel;
}

@end
