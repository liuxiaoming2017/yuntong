//
//  FileRequest.m
//  FounderReader-2.5
//
//  Created by chenfei on 4/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FileRequest.h"
#import "NSString+Helper.h"

@implementation FileRequest

@synthesize ifCache;

#pragma mark - cache

- (BOOL)hasCache
{
    if (!ifCache)
        return NO;
    NSString *filePath = cachePathFromURL(urlString);
    if (isFileExists(filePath))
        return YES;
    return NO;
}

- (id)businessData:(NSData *)data
{
    return data;
}

- (id)cacheData
{
    return [NSData dataWithContentsOfFile:cachePathFromURL(urlString)];
}

- (void)store:(NSData *)data
{
    NSString *path = cachePathFromURL(urlString);
    [data writeToFile:path atomically:YES];
}

- (void)loadFile:(BOOL)sync
{
    HttpRequest *request = [HttpRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    [request setCompletionBlock:^(NSData *data) {
   
        //如果请求是去下载组图文稿的contentUrl即去下载组图的json文件，解析出json结果为实际返回数据data
        if(!isNotCheckJSON && [urlString rangeOfString:@"newaircloud"].location != NSNotFound){
            NSString *json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSString *jsonmark = @"";
            if(json != nil && json.length > 0){
                if ([urlString containsString:@"json"]) {
                    json = [json substringFromIndex:19];
                    data = [json dataUsingEncoding:NSUTF8StringEncoding];
                }
                jsonmark = [json substringToIndex:1];
            }
            if (([jsonmark compare:@"{"] != NSOrderedSame && [jsonmark compare:@"["] != NSOrderedSame)
                || [jsonmark isEqualToString:@"[]"] || [jsonmark isEqualToString:@"{}"]) {
                NSError *error = [NSError errorWithDomain:@"SDWebImageErrorDomain" code:-1 userInfo:@{NSLocalizedDescriptionKey : @"网络不给力"}];
                failureBlock(error);
                if ([self hasCache]){
                    completionBlock([self cacheData]);
                }
                return;
            }
        }
        
        id tmpData = nil;
        
        if ([data length]) {
            //下载若有数据
            //1.缓存到数据库
            if (ifCache){
                [self store:data];
            }
            //2.使用
            tmpData = [self businessData:data];
        } else {//下载若无数据用缓存
            tmpData = [self cacheData];
        }
        
        //回调到下载的地方
        completionBlock(tmpData);
    }];
    
    [request setFailedBlock:^(NSError *error) {
        failureBlock(error);
        if ([self hasCache])
            completionBlock([self cacheData]);
            
    }];
    
    if (sync)
        [request startSynchronous];
    else
        [request startAsynchronous];
}


- (void)loadFileSaveCache:(BOOL)sync
{
    HttpRequest *request = [HttpRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    [request setCompletionBlock:^(NSData *data) {
        
        //如果请求是去下载组图文稿的contentUrl即去下载组图的json文件，解析出json结果为实际返回数据data
        if(!isNotCheckJSON && [urlString rangeOfString:@"newaircloud"].location != NSNotFound){
            NSString *json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSString *jsonmark = @"";
            if(json != nil && json.length > 0){
                if ([urlString containsString:@"json"]) {
                    json = [json substringFromIndex:19];
                    data = [json dataUsingEncoding:NSUTF8StringEncoding];
                }
                jsonmark = [json substringToIndex:1];
            }
            if (([jsonmark compare:@"{"] != NSOrderedSame && [jsonmark compare:@"["] != NSOrderedSame)
                || [jsonmark isEqualToString:@"[]"] || [jsonmark isEqualToString:@"{}"]) {
                NSError *error = [NSError errorWithDomain:@"SDWebImageErrorDomain" code:-1 userInfo:@{NSLocalizedDescriptionKey : @"网络不给力"}];
                XYLog(@"%@", [error description]);
                return;
            }
        }
        
        if ([data length]) {

            [self store:data];
        }
    }];
    
    [request setFailedBlock:^(NSError *error) {
    }];
    
    if (sync)
        [request startSynchronous];
    else
        [request startAsynchronous];
}

- (id)initWithURL:(NSString *)url
{
    self = [super init];
    if (self) {
        urlString = url;
        ifCache = YES;
    }
    XYLog(@"request url:%@", url);
    return self;
}

- (id)initWithFileURL:(NSString *)url
{
    self = [super init];
    if (self) {
        urlString = url;
        ifCache = YES;
        isNotCheckJSON = YES;
    }
    XYLog(@"request url:%@", url);
    return self;
}

- (id)initWithURLNoCache:(NSString *)url
{
    self = [super init];
    if (self) {
        urlString = url;
        ifCache = NO;
    }
    XYLog(@"request url:%@", url);
    return self;
}
+ (id)fileRequestWithURL:(NSString *)url
{
    return [[FileRequest alloc] initWithURL:url];
}
+ (id)fileRequestWithURLNoCache:(NSString *)url
{
    return [[FileRequest alloc] initWithURLNoCache:url];
}
- (void)setCompletionBlock:(DataBlock)aCompletionBlock
{
    completionBlock = [aCompletionBlock copy];
}

- (void)setFailedBlock:(ErrorBlock)aFailedBlock
{ 
    failureBlock = [aFailedBlock copy];
}

- (void)startAsynchronous
{
    if ([self hasCache])
        completionBlock([self cacheData]);
    else
        [self loadFile:NO];
}

- (void)startSynchronous
{
    if ([self  hasCache])
        completionBlock([self cacheData]);
    else
        [self loadFile:YES];
}

@end
