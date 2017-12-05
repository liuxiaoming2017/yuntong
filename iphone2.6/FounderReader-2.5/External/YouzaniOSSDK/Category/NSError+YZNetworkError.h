//
//  NSError+YZNetworkError.h
//  YouzaniOSSDK
//
//  Created by 益达 on 15/11/26.
//  Copyright (c) 2015年 张伟. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSError (YZNetworkError)
+ (NSError*)errorWithResponse:(NSDictionary*)response;
+ (NSError*)errorWithCode:(NSUInteger)errorCode message:(NSString*)errorMsg;
@end

