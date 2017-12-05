//
//  NJEventRequest.m
//  FounderReader-2.5
//
//  Created by lihuiguo on 15/11/24.
//
//

#import "NJEventRequest.h"
#import "UIDevice-Reachability.h"
#import "FCReader_OpenUDID.h"
#import "AppConfig.h"

@implementation NJEventRequest

+ (void)clickEventWithArticleId:(int)id type:(int)type eventType:(int)eventType
{
    if (![UIDevice networkAvailable]) {
        return;
    }
    NSString *userid = [Global userId];
    
    NSString *content = [NSString stringWithFormat:@"id=%d&type=%d&eventType=%d&userID=%@&userOtherID=%@",  id, type, eventType, userid, [FCReader_OpenUDID value]];
    
    if (!userid.length)
        content = [NSString stringWithFormat:@"id=%d&type=%d&eventType=%d&userID=%@&userOtherID=%@",  id, type, eventType, @"-1", [FCReader_OpenUDID value]];
    NSString *urlString = [NSString stringWithFormat:@"%@/event", [AppConfig sharedAppConfig].serverIf];
    HttpRequest *request = [HttpRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    [request setHTTPMethod:@"POST"];
    
    NSData *infoData = [content dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:infoData];
    
    [request setCompletionBlock:^(NSData *data) {
//        NSLog(@"event事件成功");
    }];
    [request setFailedBlock:^(NSError *error) {
//        NSLog(@"event事件失败: %@", error);
    }];
    [request startAsynchronous];
}

@end
