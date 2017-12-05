//
//  MyUrlCache.h
//  com.lcst.miniBrowser
//
//  Created by lein on 14-11-5.
//  Copyright (c) 2014年 lein. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>

@interface MyUrlCache : NSURLCache{
    
}

- (NSCachedURLResponse *)cachedResponseForRequest:(NSURLRequest *)request;
- (void) storeCachedResponse:(NSCachedURLResponse *)cachedResponse forRequest:(NSURLRequest *)request;
- (void) initilize;
- (void) doRemoveAllCachedResponses;
+ (void)removeCaches;
@end

@interface Utils : NSObject
+(void) writeFile:(NSString *) filePath data:(NSString *) _data;
+(NSString *) readFile:(NSString *) filePath;
+(NSString *) md5:(NSString *)str;
+(NSString *) replaceStringBetween:(NSString *) startStr EndString:(NSString *) endString Str:(NSString *) str;
+(NSInteger)getTs;
+(NSData *)uncompressZippedData:(NSData *)compressedData;
+(NSString*) writeFileToDirWithDirType:(NSString*) dirname dirType:(NSInteger) type fileName:(NSString*) filename DATA:(NSData *) data;
+(NSData*) readFileFromDirWithDirType:(NSString*) dirname dirType:(NSInteger) type fileName:(NSString*) filename;
@end