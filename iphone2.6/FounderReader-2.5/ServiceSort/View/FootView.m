//
//  FootView.m
//  FounderReader-2.5
//
//  Created by mac on 2017/7/11.
//
//

#import "FootView.h"
@interface FootView ()
@property (nonatomic,strong) UIView * lineView;
@end
@implementation FootView
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 4*kHScale, kSWidth, 0.5)];
        self.lineView.backgroundColor = UIColorFromString(@"214,218,221");
//        self.backgroundColor = [UIColor orangeColor];
        self.clipsToBounds = YES;
        [self addSubview:self.lineView];
    }
    return self;
}
@end
