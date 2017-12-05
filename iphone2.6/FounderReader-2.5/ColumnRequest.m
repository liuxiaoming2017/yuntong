//
//  ColumnRequest.m
//  FounderReader-2.5
//
//  Created by chenfei on 4/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ColumnRequest.h"
#import "DataLib/DataLib.h"
#import "CacheManager.h"
#import "Column.h"
#import "AppStartInfo.h"
#import "AppConfig.h"


@implementation ColumnRequest

- (id)initWithParentColumnId:(int)columnId
{
    NSString *url = [NSString stringWithFormat:@"%@/api/getColumns?sid=%@&cid=%d", [AppConfig sharedAppConfig].serverIf, [AppConfig sharedAppConfig].sid, columnId];
    self = [super initWithURL:url];
    if (self) {
        parentColumnId = columnId;
        isUseCache = YES;
    }
    return self;
}

+ (id)columnRequestWithParentColumnId:(int)parentColumnId
{
    return [[self alloc] initWithParentColumnId:parentColumnId];
}

- (id)businessData:(NSData *)data
{
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers  error:nil];
    NSArray *columns = [Column columnsFromArray:[dict objectForKey:@"columns"]];
    
    return columns;
}

- (id)cacheData
{
    NSData *data = [super cacheData];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers  error:nil];
    NSArray *columns = [Column columnsFromArray:[dict objectForKey:@"columns"]];
    return columns;
}

- (void)startAsynchronous
{
    if(isUseCache && [self hasCache]){
        completionBlock([self cacheData]);
        [self loadFileSaveCache:NO];
    }
    else{
        [self loadFile:NO];
    }
}

- (void)startSynchronous
{
    if(isUseCache && [self hasCache]){
        completionBlock([self cacheData]);
        [self loadFileSaveCache:YES];
    }
    else{
        [self loadFile:YES];
    }
}

@end
