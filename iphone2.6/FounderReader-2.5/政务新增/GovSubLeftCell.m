//
//  GovSubLeftCell.m
//  FounderReader-2.5
//
//  Created by 黄柳姣 on 2017/12/4.
//

#import "GovSubLeftCell.h"

@implementation GovSubLeftCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        [self setupUI];
    }
    return self;
}

- (void)setupUI
{
    NSLog(@"wid:%f",self.frame.size.width);
    self.contentLabel=[[UILabel alloc] initWithFrame:CGRectMake(10, 5, 60, 20)];
    self.contentLabel.textAlignment=NSTextAlignmentCenter;
    self.contentLabel.font=[UIFont systemFontOfSize:16.0];
    self.contentLabel.textColor=[UIColor blackColor];
    self.contentLabel.backgroundColor=[UIColor clearColor];
    self.contentLabel.text=@"水利局";
    [self addSubview:self.contentLabel];
    
    self.selectLine=[[UIImageView alloc] initWithFrame:CGRectMake(self.contentLabel.frame.size.width/2+10-7.5, CGRectGetMaxY(self.contentLabel.frame)+3, 15, 2)];
    self.selectLine.backgroundColor=[UIColor redColor];
    self.selectLine.hidden=YES;
    [self addSubview:self.selectLine];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
