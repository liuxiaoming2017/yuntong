//
//  Enum.h
//  FounderReader-2.5
//
//  Created by Julian on 2017/4/25.
//
//

#ifndef Enum_h
#define Enum_h

/* 字体缩放类型 */
typedef enum {
    FontScaleNormal,
    FontScaleZoom,
    FontScaleReduce,
    
} FontScaleType;


/* 新闻类型 */
typedef enum {
    ArticleType_PLAIN = 0,            //普通
    ArticleType_IMAGE = 1,            //组图
    ArticleType_VIDEO = 2,            //视频
    ArticleType_SPECIAL = 3,          //专题
    ArticleType_LINK = 4,             //链接
    ArticleType_LIVESHOW = 6,         //直播
    ArticleType_ACTIVITY = 7,         //活动
    ArticleType_ADV = 8,              //推广
    ArticleType_QAAPLUS = 101,        //问答+
    ArticleType_TOPICPLUS = 102,        //话题+
    ArticleType_SPECIAL_NUll = 11111, //专题空稿件
} ArticleType;

typedef enum {
    ArticleSizeScale_1_1 = 0,       //1:3
    ArticleSizeScale_3_4 = 1,       //3:4
    ArticleSizeScale_1_2 = 2,       //1:2
    ArticleSizeScale_1_3 = 3,       //1:3
    ArticleSizeScale_1_4 = 4,       //1:4
    ArticleSizeScale_9_16 = 5,      //9:16
}sizeScale;

typedef enum {
    ArticleType_ADV_First = 0,      //启动广告
    ArticleType_ADV_Top = 1,        //轮播广告
    ArticleType_ADV_List = 2,       //列表广告
    ArticleType_ADV_Essay = 3,      //文章广告
    ArticleType_ADV_Set = 4,        //图集广告
}type;

typedef enum {
    CellType_Middle = 1,      //普通cell
    CellType_GroupImage,      //组图cell
    CellType_Big,             //大图cell
    CellType_Special,         //专题cell
    CellType_Interact,        //互动cell:活动稿件&&投票稿件&&问吧
    CellType_QA               //问答cell:问答
}CellType;


/* 积分类型 */
typedef enum {
    uType_NULL = 0,
    UTYPE_REGISTER,    //注册
    UTYPE_LOGIN,       //登陆
    UTYPE_COMMENT,     //评论
    UTYPE_SHARE,       //分享
    UTYPE_READ         //阅读
}uType;

/* 直播时间类型 */
typedef enum {
    DayType_TodayOnTime,     //在今天正在进行中
    DayType_TodayNextTime,  // 在今天还未开始
    DayType_Tomorrow,       //在明天
    DayType_AfterTomorrow,  //在后天
    DayType_Future          //在未来(不含今天，明天)
} DayType;

/* 直播时间类型 */
typedef enum{
    AskAndAnswerItemShowStatus_AllClose,     //问答都关闭
    AskAndAnswerItemShowStatus_AskShow,      //问展开
    AskAndAnswerItemShowStatus_AnswerShow,   //答展开
    AskAndAnswerItemShowStatus_AllShow       //问答都展开
}AskAndAnswerItemShowStatus;

/* 页面位置类型 */
typedef NS_ENUM(NSUInteger, FDViewControllerType) {
    FDViewControllerForTabbarVC, //来自一级栏目即频道
    FDViewControllerForCloumnVC, //来自二级栏目即栏目条
    FDViewControllerForUserCenterVC, //来自个人中心一级栏目
    FDViewControllerForDetailVC,  //来自具体页面如服务分类
    FDViewControllerForItemVC  //来自具体条目如cell
};

struct ItemShowStatus {
    BOOL askShow;
    BOOL answerShow;
};

typedef NS_ENUM(NSUInteger, FDMyTopicType) {
    FDMyJoinedTopicType,
    FDMyFollowedTopicType,
};

#endif /* Enum_h */
