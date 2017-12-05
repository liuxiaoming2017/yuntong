//
//  FDQuestionsAndAnwsersPlusCell.m
//  FounderReader-2.5
//
//  Created by snitsky on 2017/3/9.
//
//

#import "FDQuestionsAndAnwsersPlusCell.h"
#import "UIImageView+WebCache.h"
#import "NewsListConfig.h"
#import "UIView+Extention.h"
#import "NSString+TimeStringHandler.h"
#import "NSMutableAttributedString + Extension.h"

@interface FDQuestionsAndAnwsersPlusCell ()

@property (strong, nonatomic) UIImageView *mainImageView;
@property (strong, nonatomic) UIImageView *avaterView;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *positionLabel;
@property (strong, nonatomic) UILabel *tagLabel;
@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) UILabel *descLabel;
@property (strong, nonatomic) UILabel *typeLabel;
@property (strong, nonatomic) UILabel *followLabel;
@property (strong, nonatomic) UILabel *askLabel;

@end

@implementation FDQuestionsAndAnwsersPlusCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self setupContentView];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupContentView];
    }
    return self;
}

- (void)setupContentView {
    CGFloat placeholderHeight = 6;
    CGFloat avaterHeight = 60;
    self.backgroundColor = [UIColor whiteColor];
    UIView *placeholderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSWidth, placeholderHeight)];
    placeholderView.backgroundColor = [UIColor colorWithRed:237/255.f green:237/255.f blue:237/255.f alpha:1];
    [self.contentView addSubview:placeholderView];
    
    _mainImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, placeholderHeight + 10 + avaterHeight/2.f, kSWidth, kSWidth / 3.f)];
    [self.contentView addSubview:_mainImageView];
    
    UIView *avaterBackground = [[UIView alloc] initWithFrame:CGRectMake(10, placeholderHeight + 10, avaterHeight, avaterHeight)];
    avaterBackground.backgroundColor = [UIColor whiteColor];
    avaterBackground.layer.masksToBounds = YES;
    avaterBackground.layer.cornerRadius = avaterHeight /2.f;
    _avaterView = [[UIImageView alloc] initWithFrame:CGRectMake(1.5, 1.5, avaterHeight-3, avaterHeight-3)];
    _avaterView.layer.masksToBounds = YES;
    _avaterView.layer.cornerRadius = (avaterHeight-3) /2.f;
    [self.contentView addSubview:avaterBackground];
    [avaterBackground addSubview:_avaterView];
    
    
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10+avaterHeight+10, 25, 0, 15)];
    _nameLabel.font = [UIFont systemFontOfSize:15];
    [self.contentView addSubview:_nameLabel];
    
    _positionLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_nameLabel.frame)+10, 28, 0, 12)];
    _positionLabel.textColor = colorWithHexString(@"666666");
    _positionLabel.font = [UIFont systemFontOfSize:12];
    [self.contentView addSubview:_positionLabel];
    
    _tagLabel = [[UILabel alloc] initWithFrame:CGRectMake(kSWidth - 10 - 38-3, CGRectGetMaxY(_mainImageView.frame) - 4 - 16-2, 38+3, 16+2)];
    _tagLabel.textColor = [UIColor whiteColor];
    _tagLabel.font = [UIFont systemFontOfSize:11];
    _tagLabel.textAlignment = NSTextAlignmentCenter;
    _tagLabel.clipsToBounds = YES;
    _tagLabel.layer.cornerRadius = 2;
    _tagLabel.textColor = [UIColor whiteColor];
    [self.contentView addSubview:_tagLabel];
    
    _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 30, 0, 10)];
    _timeLabel.textColor = colorWithHexString(@"999999");
    _timeLabel.font = [UIFont systemFontOfSize:12];
    //[self.contentView addSubview:_timeLabel];
    
    
    _descLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(_mainImageView.frame) + 10, kSWidth - 20, 50)];
    [self.contentView addSubview:_descLabel];
    
    _typeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(_descLabel.frame) + 10, 0, 12)];
    _typeLabel.textColor = colorWithHexString(@"13b7f6");
    _typeLabel.font = [UIFont systemFontOfSize:12];
    [self.contentView addSubview:_typeLabel];
    
    _followLabel = [[UILabel alloc] init];
    _followLabel.textColor = colorWithHexString(@"999999");
    _followLabel.font = [UIFont systemFontOfSize:12];
    [self.contentView addSubview:_followLabel];
    
    _askLabel = [[UILabel alloc] init];
    _askLabel.textColor = colorWithHexString(@"999999");
    _askLabel.font = [UIFont systemFontOfSize:12];
    [self.contentView addSubview:_askLabel];
    
    _relationButton = [[UIButton alloc] initWithFrame:CGRectMake(kSWidth - 63, 0, 53, 20)];
    _relationButton.layer.cornerRadius = 3;
    _relationButton.layer.borderWidth = 1;
    [self.contentView addSubview:_relationButton];
}

- (void)updateCellWithArticle:(Article *)article hideBottom:(BOOL)hideBottom {
    [_mainImageView sd_setImageWithURL:[NSURL URLWithString:article.imgUrl] placeholderImage:[Global getBgImage31]];
    [_avaterView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@@!sm11",article.authorFace]] placeholderImage:[Global getBgImage11]];
    if (article.isRead) {
        _nameLabel.textColor = [NewsListConfig sharedListConfig].middleCellSummaryTextColor;
    } else {
        _nameLabel.textColor = colorWithHexString(@"333333");
    }
    if (article.isRead) {
        _positionLabel.textColor = [NewsListConfig sharedListConfig].middleCellSummaryTextColor;
    } else {
        _positionLabel.textColor = colorWithHexString(@"666666");
    }
    
    _nameLabel.text = article.authorName;
    [_nameLabel sizeToFit];
    if (_nameLabel.width > kSWidth/5*2) {
        _nameLabel.width = kSWidth/5*2;
    }
    
    _positionLabel.x = CGRectGetMaxX(_nameLabel.frame) + 10;
    _positionLabel.text = article.authorTitle;
    _positionLabel.width = kSWidth - 10 - _positionLabel.x;
    
    if ([article.beginTime isLaterThanNowWithDateFormat:TimeToSeconds]) {
        NSString *string = NSLocalizedString(@"开始", nil);
        _timeLabel.text = [NSString stringWithFormat:@"%@ %@", [article.beginTime timeStringForQAndA], string];
        _tagLabel.text = NSLocalizedString(@"未开始", nil);
        _tagLabel.backgroundColor = [colorWithHexString(@"a292f5") colorWithAlphaComponent:.8];
    } else if ([article.endTime isLaterThanNowWithDateFormat:TimeToSeconds]) {
        NSString *string = NSLocalizedString(@"结束", nil);
        _timeLabel.text = [NSString stringWithFormat:@"%@ %@", [article.endTime timeStringForQAndA], string];
        _tagLabel.text = NSLocalizedString(@"进行中", nil);
        _tagLabel.backgroundColor = [colorWithHexString(@"00d1bc") colorWithAlphaComponent:.8];
    } else {
        _timeLabel.text = @"";
        _tagLabel.text = NSLocalizedString(@"已结束", nil);
        _tagLabel.backgroundColor = [colorWithHexString(@"666666") colorWithAlphaComponent:.8];
    }
    [_timeLabel sizeToFit];
    [_timeLabel setX:kSWidth - 10 - CGRectGetWidth(_timeLabel.frame)];
    
    if (article.isRead) {
        _descLabel.textColor = [NewsListConfig sharedListConfig].middleCellSummaryTextColor;
    } else {
        _descLabel.textColor = colorWithHexString(@"333333");
    }
    
    _descLabel.font = [UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleCellTitleFontSize];
    _descLabel.numberOfLines = 2;
    CGFloat lineSpacing = kSWidth == 375 ||kSWidth == 414 ? 7 : 4;
    NSMutableAttributedString *string = [NSMutableAttributedString attributedStringWithString:article.title Font:[UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleCellTitleFontSize] lineSpacing:lineSpacing];
    _descLabel.height = [string boundingHeightWithSize:CGSizeMake(kSWidth - 20, 0) font:[UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleCellTitleFontSize] lineSpacing:lineSpacing maxLines:2];
    _descLabel.attributedText = string;
    
    if (hideBottom) {
        _typeLabel.hidden = YES;
        _followLabel.hidden = YES;
        _askLabel.hidden = YES;
        _relationButton.hidden = YES;
        return;
    } else {
        _typeLabel.hidden = NO;
        _followLabel.hidden = NO;
        _askLabel.hidden = NO;
        _relationButton.hidden = NO;
    }
    
    _typeLabel.y = CGRectGetMaxY(_descLabel.frame)+10;
    if ([article.tag isKindOfClass:[NSString class]]) {
        _typeLabel.text = article.tag;
        [_typeLabel sizeToFit];
    }
    
    _followLabel.frame = CGRectMake(CGRectGetMaxX(_typeLabel.frame)+10, CGRectGetMinY(_typeLabel.frame), 0, 12);
    if (!_typeLabel.text.length) {
        _followLabel.x = 10;
    }
    
    NSString *followString = NSLocalizedString(@"人关注", nil);
    _followLabel.text = [NSString stringWithFormat:@"%lld%@", article.interestCount.longLongValue, followString];
    [_followLabel sizeToFit];

    _askLabel.frame = CGRectMake(CGRectGetMaxX(_followLabel.frame)+10, CGRectGetMinY(_typeLabel.frame), 0, 12);
    NSString *askString = NSLocalizedString(@"个提问", nil);
    _askLabel.text = [NSString stringWithFormat:@"%lld%@", article.askCount.longLongValue, askString];
    [_askLabel sizeToFit];
    
    if (article.isFollow && [Global userId].length) {
        _relationButton.layer.borderColor = colorWithHexString(@"13b7f6").CGColor;
        [_relationButton setTitle:NSLocalizedString(@"已关注", nil) forState:UIControlStateNormal];
        [_relationButton setTitleColor:colorWithHexString(@"13b7f6") forState:UIControlStateNormal];
        _relationButton.titleLabel.font = [UIFont systemFontOfSize:12];
    } else {
        _relationButton.layer.borderColor = colorWithHexString(@"13b7f6").CGColor;
        [_relationButton setTitle:NSLocalizedString(@"关注", nil) forState:UIControlStateNormal];
        [_relationButton setTitleColor:colorWithHexString(@"13b7f6") forState:UIControlStateNormal];
        _relationButton.titleLabel.font = [UIFont systemFontOfSize:12];
    }
    _relationButton.centerY = _askLabel.centerY;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
