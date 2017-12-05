//
//  FDVerticalCollectionCell.m
//  FounderReader-2.5
//
//  Created by mac on 2017/7/11.
//
//
#import "ImageViewCf.h"
#import "FDVerticalCollectionCell.h"
@interface FDVerticalCollectionCell ()
@property (nonatomic,strong)ImageViewCf * iconIV;
@property (nonatomic,strong)UILabel * titleLabel;
@property (nonatomic,strong)UIView * coverView;
@end
@implementation FDVerticalCollectionCell
-(instancetype)initWithFrame:(CGRect)frame{
    if (self == [super initWithFrame:frame]) {
        self.iconIV = [[ImageViewCf alloc]init];
        [self.contentView addSubview:self.iconIV];
        self.coverView = [[UIView alloc]init];
        [self.contentView addSubview:self.coverView];
        self.titleLabel = [[UILabel alloc]init];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.backgroundColor = [UIColor whiteColor];
        self.coverView.backgroundColor = [UIColor blackColor];
        self.coverView.alpha = 0.5;
        self.coverView.hidden = YES;
        [self.contentView addSubview:self.titleLabel];
    }
    return self;
}
-(void)setColumn:(Column *)column{
    _column = column;
    if (self.showType == SHOWTYPE_TWO) {
        self.titleLabel.alpha = 1.0;
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.text = [NSString stringWithFormat:@" %@",_column.columnName];
        [self.iconIV setUrlString:_column.iconUrl placeholderImage:@"bgicon43"];
        self.coverView.hidden = NO;
        self.iconIV.layer.cornerRadius = 5;
        self.iconIV.clipsToBounds = YES;
    }else{
        self.titleLabel.text = _column.columnName;
        self.titleLabel.textColor = colorWithHexString(@"#333333");
        self.titleLabel.backgroundColor = [UIColor whiteColor];
        self.titleLabel.alpha = 1.0;
        [self.iconIV setUrlString:_column.iconUrl placeholderImage:@"bgicon11"];
        self.coverView.hidden = YES;
        self.iconIV.layer.cornerRadius = self.frame.size.width*0.5;
        self.iconIV.clipsToBounds = NO;
    }
    self.iconIV.layer.masksToBounds = YES;
    self.titleLabel.font = [UIFont systemFontOfSize:14];
}
-(void)layoutSubviews{
    [super layoutSubviews];
    
    if (self.showType == SHOWTYPE_TWO) {
        self.iconIV.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height-15*kHScale);
        self.titleLabel.frame = CGRectMake(0, CGRectGetMaxY(self.iconIV.frame)- 29*kHScale, self.frame.size.width, 29*kHScale);
        self.coverView.frame = self.titleLabel.frame;
        [self.iconIV addSubview:self.coverView];
        [self.iconIV addSubview:self.titleLabel];
    }else{
        self.iconIV.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.width);
        self.titleLabel.frame = CGRectMake(-10, CGRectGetMaxY(self.iconIV.frame) + 7*kHScale, self.frame.size.width+20, 14*kHScale);
        self.coverView.frame = self.titleLabel.frame;
        [self.contentView addSubview:self.coverView];
        [self.contentView addSubview:self.titleLabel];
    }
}
@end
