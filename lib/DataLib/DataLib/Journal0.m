//
//  Journal.m
//  DataLib
//
//  Created by chenfei on 4/10/13.
//  Copyright (c) 2013 chenfei. All rights reserved.
//

#import "Journal0.h"

@implementation Journal0
@synthesize journalID;
@synthesize journalName;

- (void)dealloc
{
    [journalName release];
    
    [super dealloc];
}

+ (NSArray *)journalsFromArray:(NSArray *)array
{
    NSMutableArray *journals = [NSMutableArray arrayWithCapacity:[array count]];
    for (NSDictionary *dict in array) {
        Journal0 *journal = [[Journal0 alloc] init];
        journal.journalID = [[dict objectForKey:@"journalID"] intValue];
        journal.journalName = [dict objectForKey:@"journalName"];
        [journals addObject:journal];
        [journal release];
    }
    return journals;
}

@end
