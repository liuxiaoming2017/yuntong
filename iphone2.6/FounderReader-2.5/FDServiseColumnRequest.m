//
//  FDServiseColumnRequest.m
//  FounderReader-2.5
//
//  Created by snitsky on 2016/11/25.
//
//

#import "FDServiseColumnRequest.h"
#import "DataLib/DataLib.h"
#import "CacheManager.h"
#import "Column.h"
#import "AppStartInfo.h"
#import "AppConfig.h"


@implementation FDServiseColumnRequest

- (id)initWithParentColumnId:(int)columnId {
    NSString *url = [NSString stringWithFormat:@"%@/api/getColumns?sid=%@&cid=%d", [AppConfig sharedAppConfig].serverIf, [AppConfig sharedAppConfig].sid, columnId];
    self = [super initWithURL:url];
    if (self) {
        parentColumnId = columnId;
        isUseCache = YES;
    }
    return self;
}

+ (id)columnRequestWithParentColumnId:(int)parentColumnId {
    return [[self alloc] initWithParentColumnId:parentColumnId];
}

- (id)businessData:(NSData *)data {
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers  error:nil];
    
    return dict;
}

- (id)cacheData {
    NSData *data = [super cacheData];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers  error:nil];
    
    return dict;
}

- (void)startAsynchronous {
    if (isUseCache && [self hasCache]) {
        completionBlock([self cacheData]);
        [self loadFileSaveCache:NO];
    } else {
        [self loadFile:NO];
    }
}

- (void)startSynchronous {
    if (isUseCache && [self hasCache]){
        completionBlock([self cacheData]);
        [self loadFileSaveCache:YES];
    } else {
        [self loadFile:YES];
    }
}

@end
