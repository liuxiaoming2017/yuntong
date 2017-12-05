//
//  Book.m
//  DataLib
//
//  Created by chenfei on 4/2/13.
//  Copyright (c) 2013 chenfei. All rights reserved.
//

#import "Book.h"

@implementation Book
@synthesize coverPath_Medium;
@synthesize dataPackageSize;
@synthesize dataPackageURL;
@synthesize issueID;
@synthesize journalID;
@synthesize issueName;
@synthesize publishedDate;
@synthesize status;

- (void)dealloc
{
    [coverPath_Medium release];
    [dataPackageURL release];
    [issueName release];
    
    [super dealloc];
}

+ (id)booksFromArray:(NSArray *)array
{
    NSMutableArray *books = [NSMutableArray arrayWithCapacity:[array count]];
    for (NSDictionary *dict in array) {
        Book *book = [[Book alloc] init];
        book.coverPath_Medium = [dict objectForKey:@"coverPath_Medium"];
        book.dataPackageSize = [[dict objectForKey:@"dataPackageSize"] unsignedIntegerValue];
        book.dataPackageURL = [dict objectForKey:@"dataPackageURL"];
        book.issueID = [[dict objectForKey:@"issueID"] intValue];
        book.issueName = [dict objectForKey:@"issueName"];
        book.publishedDate = [[dict objectForKey:@"publishedDate"] longLongValue];
        book.status = 1;
        [books addObject:book];
        [book release];
    }
    return books;
}

@end
