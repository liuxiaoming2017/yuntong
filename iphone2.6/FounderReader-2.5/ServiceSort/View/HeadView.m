//
//  HeadView.m
//  FounderReader-2.5
//
//  Created by mac on 2017/7/10.
//
//

#import "HeadView.h"
#import "ColumnBarConfig.h"
@interface HeadView ()
@property (nonatomic,strong)UILabel * titleLabel;
@end
@implementation HeadView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self == [super initWithFrame:frame]) {
        self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(25*kScale, 17.5*kHScale, kSWidth -25*kScale, 15*kHScale)];
        self.titleLabel.font = [UIFont systemFontOfSize:14];
        self.titleLabel.textColor = colorWithHexString(@"#666666");
        [self addSubview:self.titleLabel];
        UIView * view = [[UIView alloc]initWithFrame:CGRectMake(15*kScale, 17.5*kHScale, 4*kScale, 15*kHScale)];
        view.backgroundColor = [ColumnBarConfig sharedColumnBarConfig].column_all_color;
        [self addSubview:view];
    }
    return self;
}
-(void)setTitle:(NSString *)title{
    _title = title;
    self.titleLabel.text = _title;
}
@end
