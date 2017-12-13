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
#import "UserAccountDefine.h"

@implementation ColumnRequest

- (id)initWithParentColumnId:(int)columnId
{
    NSString *url = [NSString stringWithFormat:@"%@/api/getColumns?sid=%@&cid=%d", [AppConfig sharedAppConfig].serverIf, [AppConfig sharedAppConfig].sid, columnId];
    self = [super initWithURL:url];
    if (self) {
        parentColumnId = columnId;
        isUseCache = YES;
        isGovAffair = NO;
    }
    return self;
}

+ (id)columnRequestWithParentColumnId:(int)parentColumnId
{
    return [[self alloc] initWithParentColumnId:parentColumnId];
}

//获取所有订阅
- (id)initWithGovAffairWithSid:(NSString *)str
{
    NSString * url = [NSString stringWithFormat:@"%@/api/%@?&sid=%@", [AppConfig sharedAppConfig].serverIf,str, [AppConfig sharedAppConfig].sid];
    self = [super initWithURL:url];
    if(self){
        isGovAffair = YES;
    }
    return self;
}


+ (id)govAffairRequestWithSid:(NSString *)str
{
    return [[self alloc] initWithGovAffairWithSid:str];
}

//获取我的订阅
- (id)initWithGovAffairWithUid:(NSString *)str
{
    NSString * url = [NSString stringWithFormat:@"%@/api/%@?&uid=%d", [AppConfig sharedAppConfig].serverIf,str, [[[NSUserDefaults standardUserDefaults] objectForKey:KuserAccountUserId] intValue]];
    self = [super initWithURL:url];
    if(self){
        isGovAffair = YES;
    }
    return self;
}

+ (id)govAffairRequestWithuid:(NSString *)str
{
    return [[self alloc] initWithGovAffairWithUid:str];
}


- (id)initWithGovSubscribeWithCid:(int)cid uid:(NSString *)uid withStr:(NSString *)str
{
    NSString *url = [NSString stringWithFormat:@"%@/api/%@?&cid=%d&uid=%d", [AppConfig sharedAppConfig].serverIf,str, cid,[[[NSUserDefaults standardUserDefaults] objectForKey:KuserAccountUserId] intValue]];
    self = [super initWithURL:url];
    if(self){
        isGovAffair = YES;
    }
    return self;
}

+ (id)govAffairRequestSubscribeWithCid:(int)cid uid:(NSString *)uid withStr:(NSString *)str
{
    return [[self alloc] initWithGovSubscribeWithCid:cid uid:uid withStr:str];
}

- (id)businessData:(NSData *)data
{
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers  error:nil];
    NSArray *columns = [[NSArray alloc] init];
    if(isGovAffair){
        return dict;
        //columns = [Column columnsFromArray:[dict objectForKey:@"list"]];
    }else{
        columns = [Column columnsFromArray:[dict objectForKey:@"columns"]];
    }
   
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
