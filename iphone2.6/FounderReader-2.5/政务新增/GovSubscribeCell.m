//
//  GovSubscribeCell.m
//  FounderReader-2.5
//
//  Created by 黄柳姣 on 2017/12/4.
//

#import "GovSubscribeCell.h"

@implementation GovSubscribeCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.subscribeBtn setImage:[UIImage imageNamed:@"login_country"] forState:UIControlStateNormal];
    [self.subscribeBtn setImage:[UIImage imageNamed:@"login_user"] forState:UIControlStateSelected];
}

- (IBAction)subscribtAction:(UIButton *)sender {
    
    sender.selected=!sender.selected;
    
    if([self.delegate respondsToSelector:@selector(buttonClickCell:withBool:)]){
        [self.delegate buttonClickCell:self withBool:sender.selected];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

@end
