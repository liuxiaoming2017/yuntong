//
//  FileRequest.h
//  FounderReader-2.5
//
//  Created by chenfei on 4/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//  如果有缓存则取缓存，不需要访问网络

#import <Foundation/Foundation.h>
#import "HttpRequest.h"

@interface FileRequest : NSObject {
    NSString *urlString;
    DataBlock completionBlock;
    ErrorBlock failureBlock;
    
    BOOL ifCache;
    BOOL isNotCheckJSON;
}

@property(nonatomic) BOOL ifCache;

- (id)initWithURL:(NSString *)url;
- (id)initWithURLNoCache:(NSString *)url;
- (id)initWithFileURL:(NSString *)url;
+ (id)fileRequestWithURL:(NSString *)url;
+ (id)fileRequestWithURLNoCache:(NSString *)url;

- (void)setCompletionBlock:(DataBlock)aCompletionBlock;
- (void)setFailedBlock:(ErrorBlock)aFailedBlock;

- (void)startSynchronous;
- (void)startAsynchronous;

- (void)loadFile:(BOOL)sync;
//保存请求的数据到缓存，以便下次使用
- (void)loadFileSaveCache:(BOOL)sync;
// virtual
- (BOOL)hasCache;

// virtual
- (id)businessData:(NSData *)data;

// virtual
- (id)cacheData;

// virtual
- (void)store:(NSData *)data;

@end
