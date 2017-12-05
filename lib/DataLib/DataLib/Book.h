//
//  Book.h
//  DataLib
//
//  Created by chenfei on 4/2/13.
//  Copyright (c) 2013 chenfei. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    kBookStatusTypePurchace = 0,
    kBookStatusTypeDownloading = 1,
    kBookStatusTypeSuspending = 2,
    kBookStatusTypeRead = 3,
} BookStatusType;

@interface Book : NSObject
@property(nonatomic, retain) NSString *coverPath_Medium;
@property(nonatomic, assign) NSUInteger dataPackageSize;
@property(nonatomic, retain) NSString *dataPackageURL;
@property(nonatomic, assign) int issueID;
@property(nonatomic, assign) int journalID;
@property(nonatomic, retain) NSString *issueName;
@property(nonatomic, assign) long long publishedDate;
@property(nonatomic, assign) BookStatusType status;

+ (NSArray *)booksFromArray:(NSArray *)array;

@end
