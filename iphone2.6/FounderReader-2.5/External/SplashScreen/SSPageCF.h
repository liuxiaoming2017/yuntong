//
//  SSPage.h
//  SplashScreen
//
//  Created by chenfei on 4/22/13.
//  Copyright (c) 2013 chenfei. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    SSPageTypeStart = 0,
    SSPageTypeCarousel  = 1,
    SSPageTypeList = 2,
    SSPageTypeEssay = 3,
    SSPageTypeAtlas = 4,
    
} SSPageType;

typedef enum
{
    SSPageStyleImage = 0,
    SSPageStyleImageWeb = 1,
    
} SSPageStyle;

@interface SSPageCF : NSObject

// 新-广告字段
@property (nonatomic, assign) int pid;                          //广告id
@property (nonatomic, retain) NSString *name;                   //广告标题
@property (nonatomic, assign) SSPageType type;                  //广告类型（0：启动广告；1=轮播图广告,2=列表广告,3=文章广告,4=图集广告）,
@property (nonatomic, assign) SSPageStyle style;                //广告形式（0=图片,1=图片+链接）
@property (nonatomic, assign) int residenceTime;                //页面停留时间（启动页有效）
@property (nonatomic, retain) NSString *startTime;              //广告起始时间：2016-01-01 00:00:00
@property (nonatomic, retain) NSString *endTime;                //广告停止时间：2016-01-03 23:59:59
@property (nonatomic, assign) int position;                     //广告在稿件列表位置：(对于栏目页表示广告所在的稿件列表位置, ，启动广告忽略此项)
@property (nonatomic, retain) NSString *webUrl;                 //广告链接


// 旧-字段不可删除
@property(nonatomic, assign) int displayOrder;
@property(nonatomic, retain) NSString *fileSDUrlVertical;
@property(nonatomic, retain) NSString *fileSDUrlHorizontal;
@property(nonatomic, retain) NSString *fileHDUrlVertical;
@property(nonatomic, retain) NSString *fileHDUrlHorizontal;
@property(nonatomic, retain) NSString *fileRetinaUrlVertical;
@property(nonatomic, retain) NSString *fileArticleId;
@property(nonatomic, retain) NSString *middlePic;
@property(nonatomic, retain) NSString *smallPic;
@property(nonatomic, retain) NSString *bigPic;
@end
