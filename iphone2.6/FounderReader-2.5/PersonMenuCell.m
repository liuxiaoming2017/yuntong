//
//  PersonMenuCell.m
//  FounderReader-2.5
//
//  Created by mac on 2017/6/19.
//
//

#import "PersonMenuCell.h"
static NSString * const KPersonMenuCell = @"PersonMenuCell";
@implementation PersonMenuCell
-(void)setMenu:(PersonMenu *)menu{
    _menu = menu;
    self.nameLabel.text = _menu.name;
    self.headIV.image = [UIImage imageNamed:_menu.image];
}
+(instancetype)creatPersonalMenuCellWithTableView:(UITableView *)tableView{
    PersonMenuCell * cell = [tableView dequeueReusableCellWithIdentifier:KPersonMenuCell];
    if (cell == nil) {
        cell = [[PersonMenuCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:KPersonMenuCell];
    }
    return cell;
}
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.headIV = [[UIImageView alloc]init];
        [self.contentView addSubview:self.headIV];
        self.nameLabel = [[UILabel alloc]init];
        self.nameLabel.font =[UIFont systemFontOfSize:15];
        self.nameLabel.textAlignment = NSTextAlignmentLeft;
        self.nameLabel.textColor = colorWithHexString(@"#333333");
        [self.contentView addSubview:self.nameLabel];
        self.moreIV = [[UIImageView alloc]init];
        self.moreIV.image = [UIImage imageNamed:@"setRight"];
        [self.contentView addSubview:self.moreIV];
        self.lineView = [[UIView alloc]init];
        self.lineView.backgroundColor = colorWithHexString(@"#dddddd");
        [self.contentView addSubview:self.lineView];
    }
    return self;
}
-(void)layoutSubviews{
    [super layoutSubviews];
    self.headIV.frame = CGRectMake(19*kScale, 14.5*kHScale, 20*kScale, 20*kHScale);
    self.nameLabel.frame = CGRectMake(CGRectGetMaxX(self.headIV.frame) + 17*kScale,0,180, 49*kHScale);
    self.moreIV.frame = CGRectMake(kSWidth-15-26, self.headIV.center.y-13*kHScale, 26*kScale, 26*kHScale);
    self.lineView.frame = CGRectMake(15*kScale, self.frame.size.height-0.5, kSWidth, 0.5);
}

@end
