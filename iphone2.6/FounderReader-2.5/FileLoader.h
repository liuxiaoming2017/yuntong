//
//  FileLoader.h
//  FounderReader-2.5
//
//  Created by chenfei on 7/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//  每次先从网络取，然后缓存到本地，如访问网络失败，从本地缓存获取数据

#import "FileRequest.h"

@interface FileLoader : FileRequest

+ (id)fileLoaderWithUrl:(NSString *)url;
+ (id)fileLoaderWithUrl:(NSString *)url checkJSON:(BOOL)checkJSON;
@end
