//
//  SeeViewmodel.h
//  FounderReader-2.5
//
//  Created by 周志扬 on 15/8/25.
//
//

#import <Foundation/Foundation.h>
#import "attactmentmodel.h"
@interface SeeViewmodel : NSObject<NSCopying>
//发布稿件的内容
@property(nonatomic,retain)NSString *content;
//稿件的id（帖子的id）
@property(nonatomic)int fileld;
//创建的时间
@property(nonatomic,retain)NSString *publishtime;
//稿件的标题
@property(nonatomic,retain)NSString *title;
//用户名
@property(nonatomic,retain)NSString *user;
/**主贴发表的附件  （视频  图片）*/
@property(nonatomic,retain)attactmentmodel *attmodel;
//用户的ID
@property(nonatomic,assign)int userID;
/**评论数 跟帖数*/
@property(nonatomic,assign)int countDiscuss;
//点赞数
@property (nonatomic,assign)int countPraise;
//头像的地址
@property (nonatomic,retain)NSString *userIcon;
//图片个数的链接
@property (nonatomic,retain)NSArray *attachments;
/** 定位的地址*/
@property (nonatomic ,retain)NSString *location;
/**事件发生的距离*/
@property (nonatomic ,assign)int distance;


+(NSMutableArray *)seeFromArray:(NSArray *)dataArray;

//- (instancetype)initWithDict1:(NSDictionary *)dict;
//+ (instancetype)seeFromDict:(NSDictionary *)dict;
@end
