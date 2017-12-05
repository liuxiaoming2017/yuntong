//
//  VersioningRequest.m
//  FounderReader-2.5
//
//  Created by chenfei on 5/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VersioningRequest.h"

@implementation VersioningRequest

- (void)startAsynchronous
{
    [self loadFile:NO];
}

- (void)startSynchronous
{
    [self loadFile:YES];
}

@end
