//
//  MyCommentModel.m
//  FounderReader-2.5
//
//  Created by 袁野 on 15/9/16.
//
//

#import "MyCommentModel.h"

@implementation MyCommentModel
-(instancetype)initWithDict:(NSDictionary *)dict{
    if (self = [super init]) {
        self.commentID =[dict[@"id"] intValue];
        self.title = dict[@"topic"];
        self.content = dict[@"content"];
        self.topicID = [dict[@"articleID"] intValue];
        self.source = [dict[@"source"] intValue];
        self.created = dict [@"createTime"];
        self.articleType = [dict[@"articleType"] intValue];
    }
    return self;
}
+ (instancetype)forumWithDict:(NSDictionary *)dict{
    return [[self alloc] initWithDict:dict];
}
@end
