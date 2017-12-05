//
//  BlankMiddleCell.m
//  FounderReader-2.5
//
//  Created by founder on 14-7-17.
//
//

#import "BlankMiddleCell.h"
#import "NewsListConfig.h"
#import "NSString+Helper.h"

@implementation BlankMiddleCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 0, 200, 15)];
        titleLabel.text = @"下面活动都已经结束啦";
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.font = [UIFont systemFontOfSize:13];
        titleLabel.numberOfLines = 0;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        titleLabel.textColor = UIColorFromString(@"85,85,85");
        
        tagImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"blank"]];
        tagImageView.frame = CGRectMake(0, 0, kSWidth, 15);
        [tagImageView setContentMode:UIViewContentModeScaleToFill];
        [tagImageView addSubview:titleLabel];
        [self addSubview:tagImageView];
        
        self.backgroundColor = UIColorFromString(@"238,239,238");
        
//        DELETE(titleLabel);
//        DELETE(tagImageView);
    }
    return self;
}

@end