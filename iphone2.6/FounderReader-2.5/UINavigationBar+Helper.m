//
//  UINavigationBar+Helper.m
//  FounderReader-2.5
//
//  Created by chenfei on 5/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UINavigationBar+Helper.h"

@implementation UINavigationBar (Helper)

- (void)drawRect:(CGRect)rect
{
    if (SYSTEM_VERSION_LESS_THAN(@"5.0")) {
        UIImage *image = [Global navigationImage];
        [image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    }
}

@end
