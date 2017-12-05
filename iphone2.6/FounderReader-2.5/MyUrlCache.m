//
//  MyUrlCache.m
//  com.lcst.miniBrowser
//
//  Created by lein on 14-11-5.
//  Copyright (c) 2014年 lein. All rights reserved.
//

#import "MyUrlCache.h"
#import <zlib.h>

@implementation MyUrlCache
#define WILL_BE_CACHED_EXTS ".jpg.png.gif.bmp.ico"
#define DEBUGP
NSString * spath;
NSFileManager *fileManager;
NSString* dirName=@"httpCache";
NSInteger dirType = 0;
- (instancetype)initWithMemoryCapacity:(NSUInteger)memoryCapacity diskCapacity:(NSUInteger)diskCapacity diskPath:(nullable NSString *)path{
    
    return [super initWithMemoryCapacity:memoryCapacity diskCapacity:diskCapacity diskPath:path];
}

-(void) initilize{
    fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains((dirType==0?NSDocumentDirectory:(dirType==1?NSLibraryDirectory:NSCachesDirectory)), NSUserDomainMask, YES);
    
    spath =[paths objectAtIndex:0];
    [fileManager changeCurrentDirectoryPath:spath];
    spath = [spath stringByAppendingPathComponent:dirName];
    [fileManager changeCurrentDirectoryPath:spath];
}

+(void)removeCaches{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains((dirType==0?NSDocumentDirectory:(dirType==1?NSLibraryDirectory:NSCachesDirectory)), NSUserDomainMask, YES);
    NSString *spath =[paths objectAtIndex:0];
    [fileManager changeCurrentDirectoryPath:spath];
    spath = [spath stringByAppendingPathComponent:dirName];
    [fileManager removeItemAtPath:spath error:nil];
}

- (void)removeAllCachedResponses{
    //这里不能执行doRemoveAllCachedResponses，否则每次就会删除你写入的
}
- (void) doRemoveAllCachedResponses{
    if (spath!=nil) {
        [fileManager removeItemAtPath:spath error:nil];
    }
}
- (NSString *)getMineType:(NSURLRequest *)request{
    NSString *ext = [[request URL] absoluteString].pathExtension;
    if(ext!=nil){
        NSString* str;
        if([ext compare:@"htm"]||[ext compare:@"html"])
            str = @"text/html";
        else
            str = [NSString stringWithFormat:@"image/%@", ext];
        return str;
    }
    return @"";
}
- (NSCachedURLResponse *)cachedResponseForRequest:(NSURLRequest *)request {
    NSString* filename = [self getCachedFileName:request];
    if(spath!=nil && filename.length>0){
        filename = [spath stringByAppendingPathComponent:filename];
        if([fileManager fileExistsAtPath:filename]){

            NSData* data = [NSData dataWithContentsOfFile:filename];
            NSURLResponse *response = [[NSURLResponse alloc] initWithURL:request.URL MIMEType:[self getMineType:request] expectedContentLength:data.length textEncodingName:nil];
            NSCachedURLResponse* cachedResponse = [[NSCachedURLResponse alloc] initWithResponse:response data:data];
            
            return cachedResponse;
        }
    }
    
    return nil;
    
}

- (void)storeCachedResponse:(NSCachedURLResponse *)cachedResponse forRequest:(NSURLRequest *)request {
    
    NSString* filename = [self getCachedFileName:request];
    if(spath!=nil && filename.length>0){
        if(![fileManager fileExistsAtPath:filename]){
            filename = [Utils writeFileToDirWithDirType:dirName dirType:dirType fileName:filename DATA:cachedResponse.data];
        }
    }
}

- (NSString*) getCachedFileName:(NSURLRequest *) request{
    NSString *urlfile = [[request URL] absoluteString];
    if(urlfile!=nil && urlfile.length > 0){
        NSArray *arrayExt = [NSArray arrayWithObjects:@".jpg", @".png", @".js", @".css", @".bmp", @".tif", @".gif", @".woff", nil];
        BOOL isFind = NO;
        for(int i = 0; i < arrayExt.count; i++){
            if([urlfile.lowercaseString rangeOfString:arrayExt[i]].location != NSNotFound){
                isFind = YES;
                break;
            }
        }
        if(isFind){
            return [NSString stringWithFormat:@"%@.cache", [Utils md5:[[request URL] absoluteString]]];
        }
    }
    return @"";
}
@end



@implementation Utils
+(void) writeFile:(NSString *) filePath data:(NSString *) _data{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* fileName = [[paths objectAtIndex:0] stringByAppendingPathComponent:filePath];

    // 用这个方法来判断当前的文件是否存在，如果不存在，就创建一个文件
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ( ![fileManager fileExistsAtPath:fileName]) {

        [fileManager createFileAtPath:fileName contents:nil attributes:nil];
    }
    

    [_data writeToFile:fileName atomically:YES encoding:NSUTF8StringEncoding error:nil];
}
+(NSString *) replaceStringBetween:(NSString *) startStr EndString:(NSString *) endString Str:(NSString *) str{
    NSRange range1 = [str rangeOfString:startStr];
    NSUInteger len = str.length - range1.location - range1.length;
    
    NSRange range2 = [str rangeOfString:endString options:NSCaseInsensitiveSearch range:NSMakeRange(range1.location+range1.length, len)];
    
    NSUInteger start =range1.length+range1.location;
    len = range2.location-(range1.length+range1.location);
    NSString* toReplace = [str substringWithRange:NSMakeRange(start, len)];
    return [str stringByReplacingOccurrencesOfString:toReplace withString:@""];
}

+(NSString *) readFile:(NSString *) filePath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* fileName = [[paths objectAtIndex:0]stringByAppendingPathComponent:filePath];
    NSString* myString = [NSString stringWithContentsOfFile:fileName usedEncoding:NULL error:NULL];
    return myString;
}

//md5 32位 加密 （小写）
+ (NSString *)md5:(NSString *)srcString {
    const char *cStr = [srcString UTF8String ];
    
    unsigned char digest[ CC_MD5_DIGEST_LENGTH ];
    
    CC_MD5 ( cStr, (CC_LONG) strlen (cStr), digest );
    
    NSMutableString *result = [ NSMutableString stringWithCapacity : CC_MD5_DIGEST_LENGTH * 2 ];
    
    for ( int i = 0 ; i < CC_MD5_DIGEST_LENGTH ; i++)
        
        [result appendFormat : @"%02x" , digest[i]];
    
    return result;
}

+ (NSInteger)getTs{
    NSDate *date = [NSDate date];
    NSTimeInterval timestamp = [date timeIntervalSince1970];
    
    return (NSInteger) timestamp;
}
+(NSData *)uncompressZippedData:(NSData *)compressedData{
    if ([compressedData length] == 0) return compressedData;
    NSUInteger full_length = [compressedData length];
    NSUInteger half_length = [compressedData length] / 2;
    NSMutableData *decompressed = [NSMutableData dataWithLength: full_length + half_length];
    BOOL done = NO;
    int status;
    z_stream strm;
    strm.next_in = (Bytef *)[compressedData bytes];
    strm.avail_in = (uInt)[compressedData length];
    strm.total_out = 0;
    strm.zalloc = Z_NULL;
    strm.zfree = Z_NULL;
    if (inflateInit2(&strm, (15+32)) != Z_OK) return nil;
    while (!done) {
        // Make sure we have enough room and reset the lengths.
        if (strm.total_out >= [decompressed length]) {
            [decompressed increaseLengthBy: half_length];
        }
        strm.next_out = [decompressed mutableBytes] + strm.total_out;
        strm.avail_out = (uInt)[decompressed length] - (uInt)strm.total_out;
        // Inflate another chunk.
        status = inflate (&strm, Z_SYNC_FLUSH);
        if (status == Z_STREAM_END) {
            done = YES;
        } else if (status != Z_OK) {
            break;
        }
    }
    if (inflateEnd (&strm) != Z_OK) return nil;
    // Set real length.
    if (done) {
        [decompressed setLength: strm.total_out];
        return [NSData dataWithData: decompressed];
    } else {
        return nil;
    }
}

+(NSString*) writeFileToDirWithDirType:(NSString*) dirname dirType:(NSInteger) type fileName:(NSString*) filename DATA:(NSData *) data{
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains((type==0?NSDocumentDirectory:(type==1?NSLibraryDirectory:NSCachesDirectory)), NSUserDomainMask, YES);
    NSString* spath =[paths objectAtIndex:0];
    [fileManager changeCurrentDirectoryPath:spath];
    if(dirname.length>0){
        [fileManager createDirectoryAtPath:dirname withIntermediateDirectories:YES attributes:nil error:nil];
        spath = [NSString stringWithFormat:@"%@/%@/%@", spath, dirname, filename];
    }else
        spath = [NSString stringWithFormat:@"%@/%@", spath, filename];
    
    [fileManager createFileAtPath:spath contents:data attributes:nil];
    return spath;
}

+(NSData*) readFileFromDirWithDirType:(NSString*) dirname dirType:(NSInteger) type fileName:(NSString*) filename{
    NSArray *paths = NSSearchPathForDirectoriesInDomains((type==0?NSDocumentDirectory:(type==1?NSLibraryDirectory:NSCachesDirectory)), NSUserDomainMask, YES);
    NSString* spath =[paths objectAtIndex:0];
    
    if(dirname.length>0)
        spath = [NSString stringWithFormat:@"%@/%@/%@", spath, dirname, filename];
    else
        spath = [NSString stringWithFormat:@"%@/%@", spath, filename];
    
    return [[NSData alloc] initWithContentsOfFile:spath];
}
@end