//
//  GovSubscribeCell.m
//  FounderReader-2.5
//
//  Created by 黄柳姣 on 2017/12/4.
//

#import "GovSubscribeCell.h"
#import "Article.h"
#import "UIImageView+WebCache.h"
#import "Column.h"
@implementation GovSubscribeCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.subscribeBtn setImage:[UIImage imageNamed:@"order"] forState:UIControlStateNormal];
    [self.subscribeBtn setImage:[UIImage imageNamed:@"ordered"] forState:UIControlStateSelected];
}

- (IBAction)subscribtAction:(UIButton *)sender {
    
   // sender.selected=!sender.selected;
    
    if([self.delegate respondsToSelector:@selector(buttonClickCell:withBool:)]){
        [self.delegate buttonClickCell:self withBool:sender.selected];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

- (void)initWithCell:(Column *)column
{
    [self.iconImage sd_setImageWithURL:[NSURL URLWithString:column.iconUrl] placeholderImage:[Global getBgImage43]];
    self.titleLabel.text=column.columnName;
    self.subscribeCountLabel.text=[NSString stringWithFormat:@"%d订阅",column.columnId];
    
}

@end
