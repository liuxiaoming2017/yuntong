//
//  HttpRequest.h
//  BlockTest
//
//  Created by chenfei on 4/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OperateDefines.h"

typedef void (^DataBlock)(id data);
typedef void (^ErrorBlock)(NSError *error);

@interface HttpRequest : NSObject {
@private
    NSMutableURLRequest *request;
    DataBlock completionBlock;
    ErrorBlock failureBlock;
    NSMutableData *_data;
}

- (id)initWithURL:(NSURL *)url;
+ (id)requestWithURL:(NSURL *)url;

- (id)initWithURLCache:(NSURL *)url;
+ (id)requestWithURLCache:(NSURL *)url;

- (id)initWithURL2S:(NSURL *)url;
+ (id)requestWithURL2S:(NSURL *)url;

- (void)setHTTPMethod:(NSString *)method;
- (void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)field;
- (void)setHTTPBody:(NSData *)data;

- (void)setCompletionBlock:(DataBlock)aCompletionBlock;
- (void)setFailedBlock:(ErrorBlock)aFailedBlock;

- (void)startSynchronous;
- (void)startAsynchronous;

- (void)cancel;

@end
