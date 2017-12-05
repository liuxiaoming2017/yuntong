//
//  Label.m
//  FounderReader-2.5
//
//  Created by chenfei on 5/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Label.h"

@implementation Label

@synthesize edgeInsets;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        edgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    return self;
}

- (void)drawTextInRect:(CGRect)rect
{
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, edgeInsets)];
}


@end
