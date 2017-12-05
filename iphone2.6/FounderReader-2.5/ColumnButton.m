//
//  ColumnButton.m
//  FounderReader-2.5
//
//  Created by chenfei on 4/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ColumnButton.h"

@implementation ColumnButton

@synthesize thumbnail, nameLabel, index;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
       
        thumbnail = [[ImageViewCf alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self addSubview:thumbnail];
        
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.size.height, frame.size.width, 20)];
        nameLabel.textAlignment = NSTextAlignmentCenter;
        if (IS_IPHONE_6P) {
          nameLabel.font = [UIFont boldSystemFontOfSize:16];
        }
        else if (IS_IPHONE_6)
        {
        nameLabel.font = [UIFont boldSystemFontOfSize:14];
        }
        else
        {
        nameLabel.font = [UIFont boldSystemFontOfSize:14];
        }
        nameLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:nameLabel];
    }
    return self;
}


@end
