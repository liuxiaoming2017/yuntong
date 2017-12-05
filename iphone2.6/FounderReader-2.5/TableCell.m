//
//  TableCell.m
//  FounderReader-2.5
//
//  Created by  on 13-4-26.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import "TableCell.h"

@implementation TableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 13, 60, 20)];
        _nameLabel.backgroundColor=[UIColor clearColor];
        _nameLabel.font=[UIFont systemFontOfSize:14];
        _nameLabel.textColor=[UIColor colorWithRed:141/255.0 green:141/255.0 blue:141/255.0 alpha:1];
        _nameLabel.textAlignment=NSTextAlignmentRight;
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(76, 13, 0, 0)];
        _contentLabel.backgroundColor=[UIColor clearColor];
        _contentLabel.numberOfLines = 0;
        _contentLabel.textColor=[UIColor colorWithRed:141/255.0 green:141/255.0 blue:141/255.0 alpha:1];
        _contentLabel.font=[UIFont systemFontOfSize:14];
        _contentLabel.textAlignment=NSTextAlignmentLeft;
        [self.contentView addSubview:_nameLabel];
        [self.contentView addSubview:_contentLabel];
 
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
