//
//  Thumbnail.m
//  FounderReader-2.5
//
//  Created by chenfei on 5/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Thumbnail.h"

@implementation Thumbnail

- (id)init
{
    self = [super init];
    if (self)
        self.userInteractionEnabled = YES;
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


- (void)addTarget:(id)target action:(SEL)action
{
    _target = target;
    _action = action;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([_target respondsToSelector:_action])
        [_target performSelector:_action withObject:self];
}

@end
