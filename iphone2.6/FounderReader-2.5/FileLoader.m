//
//  FileLoader.m
//  FounderReader-2.5
//
//  Created by chenfei on 7/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FileLoader.h"

@implementation FileLoader

+ (id)fileLoaderWithUrl:(NSString *)url
{ 
    return [[FileLoader alloc] initWithURL:url];
}

+ (id)fileLoaderWithUrl:(NSString *)url checkJSON:(BOOL)checkJSON
{
    return [[FileLoader alloc] initWithURL:url];
}

- (void)startAsynchronous
{

    [self loadFile:NO];
}

- (void)startSynchronous
{

    [self loadFile:YES];
}


@end
