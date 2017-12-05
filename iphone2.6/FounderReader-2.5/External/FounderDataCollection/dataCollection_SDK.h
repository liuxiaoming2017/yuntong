//
//  dataCollection_SDK.h
//  dataCollection_SDK
//
//  Created by 袁野 on 16/5/26.
//  Copyright © 2016年 yuanye. All rights reserved.
//

typedef void (^keywords)(NSDictionary *str);
#import <Foundation/Foundation.h>

@interface dataCollection_SDK : NSObject
//属性appid
@property NSString * appid;
@property (nonatomic,copy) keywords block;
//是否打印日志
@property BOOL isLog;
@property (nonatomic,strong)NSString *URLString;
//构造方法 设置时间  
- (id)initWithTimespan: (NSString *)timespan withUrlString: (NSString *)url;
//发送参数app启动
- (void)appinitDateAnaly: (NSString *)uid v:(NSString *)v mainVersion:(NSString *)mainVersion;
//发送参数app关闭
- (void)appcloseDateAnaly: (NSString *)uid;
//发送参数app栏目点击事件
- (void)columnclickDateAnaly: (NSString *)uid cname: (NSString *)cname separator:(NSString *)separator;
//发送参数app文章点击事件
- (void)articleclickDateAnaly: (NSString *)uid cname:(NSString *)cname aid:(NSString *)aid bid:(NSString *)bid rt:(NSString *)rt separator:(NSString *)separator;
//发送参数app文章浏览事件
- (void)articleviewDateAnaly: (NSString *)uid cname:(NSString *)cname aid:(NSString *)aid separator:(NSString *)separator;
//发送参数app评论事件
- (void)articlecommentDateAnaly: (NSString *)uid cname:(NSString *)cname aid:(NSString *)aid separator:(NSString *)separator;
//发送参数app文章分享事件
- (void)shareDateAnaly: (NSString *)uid cname:(NSString *)cname aid:(NSString *)aid separator:(NSString *)separator;
//发送参数app收藏articlereturn
- (void)articlefavoriteDateAnaly: (NSString *)uid cname:(NSString *)cname aid:(NSString *)aid separator:(NSString *)separator;
//发送参数app文章返回
- (void)articlereturnDateAnaly: (NSString *)uid cname:(NSString *)cname aid:(NSString *)aid separator:(NSString *)separator;

//不喜欢文章事件
- (void)nofavaticleAnaly: (NSString *)uid aid:(NSString *)aid keywords:(NSDictionary *)keywords;
//获取文章关键词
- (void)getkeywords: (NSString *)bid aid:(NSString *)aid debug:(BOOL)debug;

//推荐请求事件
- (void)recDateAnaly: (NSString *)uid cname:(NSString *)cname aid:(NSString *)aid bid:(NSString *)bid rule_view:(NSString *)rule_view param_view:(NSString *)param_view row:(NSString *)row rule:(NSString *)rule attrs:(NSString *)attrs separator:(NSString *)separator;
//推荐展示事件
- (void)reczsDateAnaly: (NSString *)uid cname:(NSString *)cname aid:(NSString *)aid bid:(NSString *)bid row:(NSString *)row rtype:(NSString *)rtype separator:(NSString *)separator;
//手工推荐事件
- (void)articleDateAnaly: (NSString *)aid bid:(NSString *)bid etime:(NSString *)etime;

@end
