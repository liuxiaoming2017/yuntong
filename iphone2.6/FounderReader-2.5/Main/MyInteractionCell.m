//
//  MyInteractionCell.m
//  FounderReader-2.5
//
//  Created by yanbf on 16/8/17.
//
//

#import "MyInteractionCell.h"
#import "MyInteractionModel.h"
#import "UserAccountDefine.h"

@interface MyInteractionCell ()

@property (nonatomic, weak) UIImageView *iconView;
@property (nonatomic, weak) UILabel *nameLabel;
@property (nonatomic, copy) NSString *controllerClass;

@property (nonatomic, strong) UIView *rightLineView;
@property (nonatomic, strong) UIView *bottomLineView;

@property (nonatomic, strong) UIView *dotView;

@end

@implementation MyInteractionCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.userInteractionEnabled = YES;
        
        UIImageView *iconView = [[UIImageView alloc] init];
        [self.contentView addSubview:iconView];
        self.iconView = iconView;
        
        UILabel *nameLabel = [[UILabel alloc] init];
        nameLabel.textAlignment = NSTextAlignmentCenter;
        nameLabel.font = [UIFont systemFontOfSize:15.0];
        nameLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
        [self.contentView addSubview:nameLabel];
        
        
        self.rightLineView = [[UIView alloc] init];
        [self.contentView addSubview:self.rightLineView];
        
        self.bottomLineView = [[UIView alloc] init];
        [self.contentView addSubview:self.bottomLineView];
        
        self.nameLabel = nameLabel;
        
        self.dotView = [[UIView alloc] init];
        [self.contentView addSubview:self.dotView];
        self.dotView.hidden = YES;
    }
    return self;
}

- (void)setInteraction:(MyInteractionModel *)interaction {
    _interaction = interaction;
    self.iconView.image = [UIImage imageNamed:interaction.icon];
    self.nameLabel.text = interaction.name;
    self.controllerClass = interaction.controllerClass;
    self.dotView.hidden = !([interaction.name isEqualToString:@"我的提问"] && [[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"%@%@",[Global userId],KuserAccountAskDotViewShow]]);
}


- (void)layoutSubviews {
    [super layoutSubviews];
    // 设置图片的frame
    CGFloat iconW = 34;
    CGFloat iconH = iconW;
    CGFloat iconX = (self.bounds.size.width - iconW) * 0.5;
    CGFloat iconY = 34;
    self.iconView.frame = CGRectMake(iconX, iconY, iconW, iconH);
    // 设置昵称Label的frame
    self.nameLabel.frame = CGRectMake(0, CGRectGetMaxY(self.iconView.frame) + 16, self.bounds.size.width, 25);
    
    //添两边线
    self.rightLineView.frame = CGRectMake(self.contentView.bounds.size.width-1, 0, 1, self.contentView.bounds.size.height);
    self.rightLineView.backgroundColor = [UIColor colorWithRed:211/255.0 green:211/255.0 blue:211/255.0 alpha:1];
    [self.contentView addSubview:self.rightLineView];
    
    self.bottomLineView.frame = CGRectMake(0, self.contentView.bounds.size.height-1, self.contentView.bounds.size.width, 1);
    self.bottomLineView.backgroundColor = [UIColor colorWithRed:211/255.0 green:211/255.0 blue:211/255.0 alpha:1];
    [self.contentView addSubview:self.bottomLineView];
    
    //小红点
    CGFloat diameter = 5;
    CGFloat x = CGRectGetMidX(self.nameLabel.frame) - 40.5;
    CGFloat y = CGRectGetMidY(self.nameLabel.frame) - diameter/2.f;
    _dotView.frame = CGRectMake(x, y, diameter, diameter);
    _dotView.clipsToBounds = YES;
    _dotView.layer.cornerRadius = diameter/2.f;
    _dotView.backgroundColor = [UIColor redColor];
    
}


@end
