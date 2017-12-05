//
//  FDMyAskSegmentButton.m
//  FounderReader-2.5
//
//  Created by snitsky on 2017/3/9.
//
//

#import "FDMyAskSegmentButton.h"
#import "UIView+Extention.h"
#import "ColumnBarConfig.h"

@interface FDMyAskSegmentButton ()

@property (strong, nonatomic) UIView *lineView;

@end

@implementation FDMyAskSegmentButton

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setTitleColor:[ColumnBarConfig sharedColumnBarConfig].column_all_color forState:UIControlStateSelected];
        [self setTitleColor:colorWithHexString(@"666666") forState:UIControlStateNormal];
        self.titleLabel.font = [UIFont systemFontOfSize:15];
        UIView *separateView = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height - .5, frame.size.width, .5f)];
        separateView.backgroundColor = colorWithHexString(@"d5d5d5");
        [self addSubview:separateView];
        [self addSubview:self.lineView];
        self.lineView.frame = CGRectMake(0, frame.size.height - 1, frame.size.width, 1);
    }
    return self;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    self.lineView.hidden = !selected;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.hidden = YES;
        _lineView.backgroundColor = [ColumnBarConfig sharedColumnBarConfig].column_all_color;
    }
    return _lineView;
}

@end
