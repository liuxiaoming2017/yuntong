//
//  LiveArticleInfoModel.m
//  FounderReader-2.5
//
//  Created by yanbf on 2016/10/26.
//
//

#import "LiveArticleInfoModel.h"

@implementation LiveArticleInfoModel
+ (instancetype)articleInfoFromeDiction:(NSDictionary *)dict {
    return [[self alloc] initArticleInfoWithDict:dict];
}

- (instancetype)initArticleInfoWithDict:(NSDictionary *)dict {
    if (self == [super init]) {
        
        if (![dict isKindOfClass:[NSNull class]]) {
            self.liveTitle = [dict objectForKey:@"title"];
            self.liveStartTime = [dict objectForKey:@"直播开始时间"];
            self.liveEndTime  = [dict objectForKey:@"直播结束时间"];
            self.countClick  = [[dict objectForKey:@"countClick"] integerValue];
        }
        
    }
    return self;
}



- (void)setValue:(id)value forUndefinedKey:(NSString *)key{}
@end
