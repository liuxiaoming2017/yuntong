//
//  FDMyAskCell.m
//  FounderReader-2.5
//
//  Created by snitsky on 2017/3/9.
//
//

#import "FDMyAskCell.h"
#import "NSString+TimeStringHandler.h"
#import "UIView+Extention.h"
#import "NSMutableAttributedString + Extension.h"
#import "ColumnBarConfig.h"

@interface FDMyAskCell ()

@property (strong, nonatomic) UIView *separateView;
@property (strong, nonatomic) UILabel *yourAskLabel;
@property (strong, nonatomic) UILabel *askStatusLabel1;
@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) UILabel *contentLabel;
@property (strong, nonatomic) UILabel *askStatusLabel2;
@property (strong, nonatomic) UIImageView *maskImageView;
@property (strong, nonatomic) UIView *contentBackgroundView;

@end

@implementation FDMyAskCell

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
    [self.contentView addSubview:self.separateView];
    [self.contentView addSubview:self.yourAskLabel];
    [self.contentView addSubview:self.askStatusLabel1];
    [self.contentView addSubview:self.timeLabel];
    [self.contentView addSubview:self.contentBackgroundView];
    [self.contentView addSubview:self.contentLabel];
    [self.contentView addSubview:self.askStatusLabel2];
    [self.contentView addSubview:self.maskImageView];
}

- (void)updateWithModel:(FDAskModel *)model {
    
    NSMutableAttributedString *string = [NSMutableAttributedString attributedStringWithString:model.content Font:[UIFont systemFontOfSize:14] lineSpacing:5];
    _contentLabel.height = [string boundingHeightWithSize:CGSizeMake(kSWidth-20, 0) font:[UIFont systemFontOfSize:14] lineSpacing:5 maxLines:3];
    _contentLabel.attributedText = string;
    
    if (model.answerTime.length) {
        //已答复
        _yourAskLabel.text = @"您的提问";
        _askStatusLabel1.text = @"";
        _askStatusLabel2.text = @"";
        _maskImageView.hidden = NO;
        _timeLabel.text = [NSString stringWithFormat:@"最后更新时间: %@", model.answerTime];
        return;
    } else {
        _yourAskLabel.text = @"您的提问:";
        _maskImageView.hidden = YES;
    }
    if (model.askStatus == FDAskStatusWaitingForReview) {
        //等待审核
        _askStatusLabel1.text = @"新提问";
        _askStatusLabel2.text = @"已经成功提交, 等待答复";
    } else if (model.askStatus == FDAskStatusRelease) {
        _askStatusLabel1.text = @"新发布";
        _askStatusLabel2.text = @"已经成功发布啦, 等待答复";
    }
    _timeLabel.text = [NSString stringWithFormat:@"提问时间: %@", model.createTime];
}

- (UIView *)separateView {
    if (!_separateView) {
        _separateView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSWidth, 6)];
        _separateView.backgroundColor = colorWithHexString(@"ededed");
    }
    return _separateView;
}

- (UILabel *)yourAskLabel {
    if (!_yourAskLabel) {
        _yourAskLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 16 + CGRectGetMaxY(self.separateView.frame), 60, 12)];
        _yourAskLabel.textColor = colorWithHexString(@"999999");
        _yourAskLabel.font = [UIFont systemFontOfSize:12];
    }
    return _yourAskLabel;
}

- (UILabel *)askStatusLabel1 {
    if (!_askStatusLabel1) {
        _askStatusLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.yourAskLabel.frame), 16 + CGRectGetMaxY(self.separateView.frame), 80, 12)];
        _askStatusLabel1.textColor = colorWithHexString(@"13b7f6");
        _askStatusLabel1.font = [UIFont systemFontOfSize:12];
    }
    return _askStatusLabel1;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 16 + CGRectGetMaxY(self.separateView.frame), kSWidth - 10, 12)];
        _timeLabel.textColor = colorWithHexString(@"999999");
        _timeLabel.font = [UIFont systemFontOfSize:12];
        _timeLabel.textAlignment = NSTextAlignmentRight;
    }
    return _timeLabel;
}

- (UIView *)contentBackgroundView {
    if (!_contentBackgroundView) {
        _contentBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(10, 38 + CGRectGetMaxY(self.separateView.frame), kSWidth - 20, 82)];
        _contentBackgroundView.backgroundColor = colorWithHexString(@"ededed");
        _contentBackgroundView.layer.masksToBounds = YES;
        _contentBackgroundView.layer.cornerRadius = 3;
    }
    return _contentBackgroundView;
}

- (UILabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.contentBackgroundView.frame)+10, CGRectGetMinY(self.contentBackgroundView.frame)+10, CGRectGetWidth(self.contentBackgroundView.frame) - 20, CGRectGetHeight(self.contentBackgroundView.frame) - 20)];
        _contentLabel.textColor = colorWithHexString(@"333333");
        _contentLabel.font = [UIFont systemFontOfSize:14];
        _contentLabel.numberOfLines = 3;
    }
    return _contentLabel;
}

- (UILabel *)askStatusLabel2 {
    if (!_askStatusLabel2) {
        _askStatusLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.contentBackgroundView.frame)+10, kSWidth - 10, 12)];
        _askStatusLabel2.textColor = [ColumnBarConfig sharedColumnBarConfig].column_all_color;
        _askStatusLabel2.font = [UIFont systemFontOfSize:12];
        _askStatusLabel2.textAlignment = NSTextAlignmentRight;
    }
    return _askStatusLabel2;
}

- (UIImageView *)maskImageView {
    if (!_maskImageView) {
        _maskImageView = [[UIImageView alloc] init];
        CGRect frame = _maskImageView.frame;
        frame.size.height = 76;
        frame.size.width = 80;
        _maskImageView.frame = frame;
        CGPoint center = _maskImageView.center;
        center.x = self.contentBackgroundView.center.x;
        center.y = self.contentBackgroundView.center.y;
        _maskImageView.center = center;
        _maskImageView.image = [UIImage imageNamed:@"icon_has_anwser"];
    }
    return _maskImageView;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
