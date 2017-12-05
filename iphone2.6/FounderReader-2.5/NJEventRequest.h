//
//  NJEventRequest.h
//  FounderReader-2.5
//
//  Created by lihuiguo on 15/11/24.
//
//

#import "HttpRequest.h"

@interface NJEventRequest : HttpRequest
+ (void)clickEventWithArticleId:(int)id type:(int)type eventType:(int)eventType;
@end
