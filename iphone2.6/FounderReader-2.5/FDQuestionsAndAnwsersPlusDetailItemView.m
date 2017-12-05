//
//  FDQuestionsAndAnwsersPlusDetailItemView.m
//  FounderReader-2.5
//
//  Created by Julian on 2017/3/19.
//
//

#import "FDQuestionsAndAnwsersPlusDetailItemView.h"

@interface FDQuestionsAndAnwsersPlusDetailItemView()

@property (strong, nonatomic) UIImageView *avaterImageView;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) UILabel *praiseLabel;
@property (strong, nonatomic) UILabel *commentLabel;
@property (strong, nonatomic) UILabel *contentLabel;
@property (strong, nonatomic) UIButton *moreBtn;

@end

@implementation FDQuestionsAndAnwsersPlusDetailItemView

- (instancetype)init
{
    if (self = [super init]) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI
{
    self.userInteractionEnabled = YES;
    
    [self addSubview:self.avaterImageView];
    [self addSubview:self.nameLabel];
    [self addSubview:self.timeLabel];
    [self addSubview:self.praiseLabel];
    [self addSubview:self.commentLabel];
    [self addSubview:self.moreBtn];
}

- (void)setDetailItemModel:(FDAskModel *)detailItemModel
{
    
}

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

- (UILabel *)timeLabel
{
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
    }
    return _timeLabel;
}

- (UILabel *)praiseLabel
{
    if (!_praiseLabel) {
        _praiseLabel = [[UILabel alloc] init];
    }
    return _praiseLabel;
}

- (UILabel *)commentLabel
{
    if (!_commentLabel) {
        _commentLabel = [[UILabel alloc] init];
    }
    return _commentLabel;
}

- (UIButton *)moreBtn
{
    if (!_moreBtn) {
        _moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    return _moreBtn;
}


@end
