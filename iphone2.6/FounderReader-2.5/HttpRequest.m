//
//  HttpRequest.m
//  BlockTest
//
//  Created by chenfei on 4/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HttpRequest.h"
#import "UIApplication+NetworkActivity.h"
#import "NSString+Helper.h"

#define  KuserLogin_sessionId @"userLogin_sessionId"

@interface HttpRequest ()

@property (strong, nonatomic) NSURLConnection *URLConnection;

@end

@implementation HttpRequest

- (id)initWithURL:(NSURL *)url
{
    self = [super init];
    if (self)
    {
        NSLog(@"request url: %@", [url absoluteString]);
        request = [NSMutableURLRequest requestWithURL:url];
        [request setTimeoutInterval:30];
    }
    return self;
}

+ (id)requestWithURL:(NSURL *)url
{
    return [[HttpRequest alloc] initWithURL:url];
}

- (id)initWithURLCache:(NSURL *)url
{
    self = [super init];
    if (self)
    {
        request = [NSMutableURLRequest requestWithURL:url];
        [request setTimeoutInterval:10];
        [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    }
    return self;
}

+ (id)requestWithURLCache:(NSURL *)url
{
    return [[HttpRequest alloc] initWithURLCache:url];
}

- (id)initWithURL2S:(NSURL *)url
{
    self = [super init];
    if (self)
    {
        request = [NSMutableURLRequest requestWithURL:url];
        [request setTimeoutInterval:2];
    }
    return self;
}

+ (id)requestWithURL2S:(NSURL *)url
{
    return [[HttpRequest alloc] initWithURL2S:url];
}
- (void)setHTTPMethod:(NSString *)method
{
    [request setHTTPMethod:method];
}

- (void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)field
{
//    [request setValue:value forHTTPHeaderField:field];
    [request addValue:value forHTTPHeaderField:field];
}

- (void)setHTTPBody:(NSData *)data
{
    [request setHTTPBody:data];
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
    self.URLConnection = [NSURLConnection connectionWithRequest:request delegate:self];
    
    [[UIApplication sharedApplication] showNetworkActivityIndicator];
}

- (void)startSynchronous
{
    [[UIApplication sharedApplication] showNetworkActivityIndicator];
    
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if (error)
        failureBlock(error);
    else
        completionBlock(data);
    
    [[UIApplication sharedApplication] hideNetworkActivityIndicator];
}

- (void)cancel
{
    [self.URLConnection cancel];
    [[UIApplication sharedApplication] hideNetworkActivityIndicator];
}

//guo userLogin
-(void)userLoginInfo:(NSString *)userlogin_cookie
{
    NSString *sessionId = [[userlogin_cookie componentsSeparatedByString:@"="] lastObject];;
    if (![NSString isNilOrEmpty:sessionId] && ![sessionId isEqualToString:@"-1"]) {
        [[NSUserDefaults standardUserDefaults] setObject:sessionId forKey:KuserLogin_sessionId];
    }
}

#pragma delegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response
{
    _data = [[NSMutableData alloc] init];
    
    NSDictionary* headers = [response allHeaderFields];
    NSString *userlogin_cookie = [headers objectForKey:@"Set-Cookie"];
    if (![NSString isNilOrEmpty:userlogin_cookie]) {
        [self userLoginInfo:userlogin_cookie];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_data appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    completionBlock(_data);
    
    [[UIApplication sharedApplication] hideNetworkActivityIndicator];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    failureBlock(error);
    
    [[UIApplication sharedApplication] hideNetworkActivityIndicator];
}

@end
