//
//  MyCommentModel.h
//  FounderReader-2.5
//
//  Created by 袁野 on 15/9/16.
//
//

#import <Foundation/Foundation.h>

@interface MyCommentModel : NSObject
//内容
@property (nonatomic,retain)NSString *content;
//时间
@property (nonatomic,retain)NSString *created;
//评论ID
@property (nonatomic,assign)int commentID;
//标题
@property (nonatomic,retain)NSString *title;
//稿件ID
@property (nonatomic,assign)int topicID;

//稿件类型
@property (nonatomic,assign)int articleType;

//0:对稿件的评论，1:对直播话题评论
@property (nonatomic,assign)int source;

+ (instancetype)forumWithDict:(NSDictionary *)dict;
@end
