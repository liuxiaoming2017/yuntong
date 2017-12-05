//
//  AppStartInfo.h
//  FounderReader-2.5
//
//  Created by ld on 15-7-15.
//
//

#import <Foundation/Foundation.h>

@class Article;

@interface AppStartInfo : NSObject

// 新-配置字段
@property (nonatomic, retain) NSArray *startPages;              //广告信息
@property (nonatomic, retain) NSString *mallUrl;                //积分商城访问地址
@property (nonatomic, retain) NSString *configUrl;              //关于、服务条款地址
@property (nonatomic, retain) NSString *iOSDes;                 //app升级描述
@property (nonatomic, retain) NSString *appVersion;             //app版本
@property (nonatomic, retain) NSString *appDownloadUrl;         //app升级跳转地址
@property (nonatomic, retain) NSString *appName;                //app名字
@property (nonatomic, assign) int forceUpdate;                  //是否强制升级（默认为：0，不强制）
@property (nonatomic, strong) NSString *founderBDAppID;         //方正大数据APPID
@property (nonatomic, strong) NSString *founderBDUrl;           //方正大数据APPUrl
@property (nonatomic, strong) NSString *webUrl;                 //分享Url
@property (nonatomic, assign) BOOL ucTabisShow;                 //是否展示个人中心
@property (nonatomic, assign) NSInteger ucTabPosition;          //个人中心位置,表示在第几个后面
@property (nonatomic, copy) NSString *ucTabString;            //个人中心名称
@property (nonatomic, copy) NSString *ucTabIcon;              //个人中心图标
@property (nonatomic, copy) NSString * officialIcon;          //官方回复头像链接
// 旧字段-不可删除
@property(nonatomic, assign) int siteId;

@property(nonatomic, retain) NSString *contentTemplate;
@property (retain, nonatomic) NSDictionary *columnsPlistDic;

@property(nonatomic, retain) Article *adArticle;

+ (AppStartInfo *)sharedAppStartInfo;
- (void)configWithDictionary:(NSDictionary *)dict;

@end
