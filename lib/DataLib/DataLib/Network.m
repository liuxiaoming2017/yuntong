//
//  Network.m
//  PluginLib
//
//  Created by chenfei on 3/27/13.
//  Copyright (c) 2013 chenfei. All rights reserved.
//

#import "Network.h"

void downloadData(NSString *urlString, BOOL useCache, void (^b)(NSData *data))
{
    NSURL *url = [NSURL URLWithString:urlString];
    dispatch_queue_t download_queue = dispatch_queue_create(NULL, NULL);
    dispatch_async(download_queue, ^(void) {                    // 在子线程中执行
        NSData *data = nil;
        if (useCache) {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
            NSString *cacheDirPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"JournalCaches"];
            if (![[NSFileManager defaultManager] fileExistsAtPath:cacheDirPath])
                [[NSFileManager defaultManager] createDirectoryAtPath:cacheDirPath withIntermediateDirectories:YES attributes:nil error:0];
            NSString *fileName = [urlString lastPathComponent];
            NSString *filePath = [cacheDirPath stringByAppendingPathComponent:fileName];
            if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
                data = [NSData dataWithContentsOfFile:filePath];
            } else {
                data = [NSData dataWithContentsOfURL:url];
                [data writeToFile:filePath atomically:YES];
            }
        } else {
            data = [NSData dataWithContentsOfURL:url];
        }
        dispatch_async(dispatch_get_main_queue(), ^(void) {     // 在主线程中执行
            if (b)
                b(data);
        });
    });
    dispatch_release(download_queue);
}

void downloadDataOrFromCache(NSString *urlString, void (^b)(NSData *data))
{
    NSURL *url = [NSURL URLWithString:urlString];
    NSLog(@"%@", urlString);
    dispatch_queue_t download_queue = dispatch_queue_create(NULL, NULL);
    dispatch_async(download_queue, ^(void) {                    // 在子线程中执行
        NSData *data = [NSData dataWithContentsOfURL:url];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *cacheDirPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"JournalCaches"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:cacheDirPath])
            [[NSFileManager defaultManager] createDirectoryAtPath:cacheDirPath withIntermediateDirectories:YES attributes:nil error:0];
        NSString *fileName = [urlString lastPathComponent];
        NSString *filePath = [cacheDirPath stringByAppendingPathComponent:fileName];
        if (data == nil) {
            if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
                data = [NSData dataWithContentsOfFile:filePath];
        } else {
            [data writeToFile:filePath atomically:YES];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {     // 在主线程中执行
            if (b)
                b(data);
        });
    });
    dispatch_release(download_queue);
}
