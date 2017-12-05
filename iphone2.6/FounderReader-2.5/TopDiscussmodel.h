//
//  TopDiscussmodel.h
//  FounderReader-2.5
//
//  Created by 周志扬 on 15/9/2.
//
//

#import <Foundation/Foundation.h>

@interface TopDiscussmodel : NSObject
//跟帖稿件的附件
//@property (nonatomic ,retain) NSArray *attachments;
@property (nonatomic ,strong) NSDictionary *attachments;
//跟帖的内容
@property (nonatomic ,retain) NSString *content;
//跟帖的点赞数
//@property (nonatomic ,assign) int countPraise;
//评论用户 的 用户id
//@property (nonatomic ,assign) int userID;
//直播跟帖的用户名
@property (nonatomic ,retain) NSString *userName;
//跟帖的时间
@property (nonatomic ,retain) NSString *publishTime;
//跟帖人的头像
@property (nonatomic ,retain) NSString *userIcon;
//跟帖人的id
@property (nonatomic ,assign) int fileID;
//稿件附件的url
//@property (nonatomic ,retain) NSString *atturl;
/**评论的标题*/
@property (nonatomic,retain ) NSString *title;
/**附件的类型*/
//@property(nonatomic ,assign) int type;

//@property(nonatomic,retain)NSDictionary *topDiscuss;

//@property(nonatomic ,assign)int countDiscuss;

@property (nonatomic, strong) NSString *msg; // 稿件没有数据的时候返回
@property (nonatomic, strong) NSString *msgTitle;// 没有数据时,使用外部的标题

//顶部直播图
@property(nonatomic ,retain)NSString *picImage;

@property(nonatomic, strong)NSArray *pics;

@property(nonatomic, strong)NSArray *videos;

@property(nonatomic, strong)NSArray *videoPics;

@property(nonatomic, assign)int userType;

@property(nonatomic, assign)int liveStatus;



+(NSArray *)liveFromArray:(NSArray *)liveArray;
//+(NSDictionary *)liveFromdic:(NSDictionary *)liveArray;

- (instancetype)initWithDict:(NSDictionary *)dict;
+ (instancetype)seeWithDict:(NSDictionary *)dict;

+ (instancetype)topSeeDirectFromDiction:(NSDictionary *)dict;
- (instancetype)initTopWithDict:(NSDictionary *)dict;
@end
