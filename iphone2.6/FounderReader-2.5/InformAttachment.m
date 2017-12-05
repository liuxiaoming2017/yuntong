//
//  InformAttachment.m
//  FounderReader-2.5
//
//  Created by chenfei on 4/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "InformAttachment.h"

#define kDataKey  @"dataKey"
#define kFileName @"kFileNameKey"
#define kMovieStr @"kMovieStrKey"

@implementation InformAttachment

@synthesize data, fileName, movieStr, type, flagShow;

- (id)init{
    flagShow = YES;
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        data = [aDecoder decodeObjectForKey:kDataKey];
        fileName = [aDecoder decodeObjectForKey:kFileName];
        movieStr = [aDecoder decodeObjectForKey:kMovieStr];
    }
    return self;
}
@end
