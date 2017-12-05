//
//  Article.h
//  FounderReader-2.5
//
//  Created by chenfei on 4/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MJExtension/MJExtension.h>

@interface Article : NSObject {
    
    
}

// 新空云字段
@property (nonatomic, assign) int fileId;                //稿件ID：10063
@property (nonatomic, assign) int articleType;           //稿件类型：（0：文章；1：图集；2：视频；3：专题；4：链接；5：没用；6：直播；7：活动；8：广告;101：问答；102:话题；）
@property (nonatomic, retain) NSString *title;           //稿件标题："准备直播|习大大直播“
@property (nonatomic, retain) NSString *version;         //稿件版本号：1459836367
@property (nonatomic, retain) NSString *attAbstract;     //稿件摘要
@property (nonatomic, retain) NSString *publishTime;     //稿件发布时间："2016-04-05 14:06:07"
@property (nonatomic, assign) int linkID;                //专题链接ID或直播主题ID：10001
@property (nonatomic, retain) NSString *readCount;       //稿件阅读数
@property (nonatomic, retain) NSString *commentCount;    //稿件评论数
@property (nonatomic, retain) NSString *greatCount;      //稿件点赞数
@property (nonatomic, retain) NSString *shareCount;      //稿件分享数
@property (nonatomic, retain) NSString *countShareClick; //稿件分享点击数
@property (nonatomic, retain) NSString *picSmall;        //标题图1
@property (nonatomic, retain) NSString *picMiddle;       //标题图2
@property (nonatomic, retain) NSString *picBig;          //标题图3
@property (nonatomic, assign) BOOL bigPic;               //是否大图稿件：0
@property (nonatomic, retain) NSString *tag;             //稿件标签
@property (nonatomic, retain) NSString *contentUrl;      //内容链接
@property (nonatomic, assign) BOOL discussClosed;        //是否可评论
@property (nonatomic, copy) NSString *audioUrl;          //音频地址
@property (nonatomic, strong) NSMutableArray *audioDictM;//音频和标题的字典
@property (nonatomic, strong) NSString *audioTitle;          //音频标题

// 直播
@property (nonatomic, copy) NSString *liveStartTime;   //直播开始时间
@property (nonatomic, copy) NSString *liveEndTime;     //直播结束时间

// 活动
@property (nonatomic, copy) NSString *activityStartTime;   //活动开始时间
@property (nonatomic, copy) NSString *activityEndTime;     //活动结束时间

// 投票
@property (nonatomic, copy) NSString *voteStartTime;   //投票开始时间
@property (nonatomic, copy) NSString *voteEndTime;     //投票结束时间

// 有答
@property (nonatomic, copy) NSString *askStartTime;   //提问开始时间
@property (nonatomic, copy) NSString *askEndTime;     //提问结束时间

// 广告
@property (nonatomic, assign) int advID;                 //广告id
@property (nonatomic, assign) int style;                 //广告形式：（0=图片,1=图片+链接）
@property (nonatomic, assign) int type;                  //广告类型：（0=启动广告；1=轮播图广告,2=列表广告,3=文章广告,4=图集广告）
@property (nonatomic, assign) int sizeScale;             //广告尺寸：（0=1:3;  1=3:4;  2=1:2;  3=1:3;  4=1:4;  5=9:16）
@property (nonatomic, assign) int position;              //广告在稿件列表位置：3(对于栏目页表示广告所在的稿件列表位置, 启动广告忽略此项)
@property (nonatomic, assign) int adOrder;               //广告在稿件列表位置：3(对于栏目页表示广告所在的稿件列表位置,其他广告位没有)
@property (nonatomic, retain) NSString *imgAdvUrl;       //广告标题图
@property (nonatomic, retain) NSString *startTime;       //广告开始时间：（“2016-01-01 00:00:00”）
@property (nonatomic, retain) NSString *endTime;         //广告结束时间：（“2016-01-03 23:59:59”）
@property (nonatomic, assign) int pageTime;              //页面停留时间:3（启动页有效）

// 互动+
//description
@property (copy, nonatomic) NSString *questionDescription;
/**
 头衔
 */
@property (copy, nonatomic) NSString *authorTitle;
@property (copy, nonatomic) NSString *authorFace;
@property (copy, nonatomic) NSString *createTime;
@property (strong, nonatomic) NSNumber *authorID;
@property (copy, nonatomic) NSString *authorName;
@property (copy, nonatomic) NSString *imgUrl;
@property (copy, nonatomic) NSString *authorDesc;
@property (strong, nonatomic) NSNumber *lastID;
@property (copy, nonatomic) NSString *beginTime;
@property (strong, nonatomic) NSNumber *interestCount;
@property (strong, nonatomic) NSNumber *askCount;
@property (copy, nonatomic) NSString *askTime;
@property (assign, nonatomic) BOOL isFollow;
@property (assign, nonatomic) BOOL isHideReadCount;

// 话题+
@property (copy, nonatomic) NSNumber *topicID;
@property (copy, nonatomic) NSNumber *topicCount;


// 旧字段--不可删除
@property(nonatomic, retain) NSString *imageUrl;
@property(nonatomic, retain) NSString *imageUrlBig;
@property(nonatomic, retain) NSString *groupImageUrl;
@property(nonatomic, retain) NSString *videoUrl;
@property(nonatomic, retain) NSString *shareUrl;
@property(nonatomic, retain) NSString *imageSize;
@property(nonatomic, assign) BOOL isRead;
@property(nonatomic, retain) NSAttributedString *attributetitle;
@property(nonatomic) int columnId;
@property(nonatomic, retain) NSString *extproperty;
@property(nonatomic, retain) NSString *keyWord;
@property(nonatomic, retain) NSString *category;
@property(nonatomic, retain) NSString *comments;
@property(nonatomic, retain) NSString *picCount;//图片稿件
@property(nonatomic) int isBigPic;//大图 1点击进普通稿件 2点击进图片稿件
@property(nonatomic, retain) NSString * columnName; //关联稿件tag


+ (NSArray *)articlesFromArray:(NSArray *)array;
+ (Article *)articleFromDict:(NSDictionary *)dict;
+ (void)changePagerFlag;

@end
