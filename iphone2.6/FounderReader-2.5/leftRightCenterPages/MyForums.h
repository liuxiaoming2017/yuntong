//
//  MyForums.h
//  FounderReader-2.5
//
//  Created by 袁野 on 15/9/15.
//
//

#import <Foundation/Foundation.h>
#define MARGIN 10
#define SYS_FONT(x)  [UIFont systemFontOfSize:x]
@interface MyForums : NSObject
//内容
@property (nonatomic,retain)NSString *content;
//时间
@property (nonatomic,retain)NSString *created;
//ID
@property (nonatomic,assign)int commentID;
//标题
@property (nonatomic,retain)NSString *title;
//ID
@property (nonatomic,assign)int topicID;
//类型
//0我发布的，1我评论的，2回复我的
@property (nonatomic,assign)int type;
+ (instancetype)forumWithDict:(NSDictionary *)dict;
@end
