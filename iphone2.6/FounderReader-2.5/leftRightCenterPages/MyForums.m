//
//  MyForums.m
//  FounderReader-2.5
//
//  Created by 袁野 on 15/9/15.
//
//

#import "MyForums.h"

@implementation MyForums
-(instancetype)initWithDict:(NSDictionary *)dict{
    if (self = [super init]) {
        self.commentID =[dict[@"id"] intValue];
        self.title = dict[@"topic"];
        self.content = dict[@"content"];
        self.topicID = [dict[@"topicID"] intValue];
        self.type = [dict[@"type"] intValue];
        self.created = dict [@"created"];
    }
    return self;
}
+ (instancetype)forumWithDict:(NSDictionary *)dict{
    return [[self alloc] initWithDict:dict];
}
@end
