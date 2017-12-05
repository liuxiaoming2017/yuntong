//
//  FounderEventRequest.h
//  FounderReader-2.5
//
//  Created by yan.bf on 15/5/18.
//
//

#import "HttpRequest.h"
#import "Article.h"
#import "Column.h"

@interface FounderEventRequest : NSObject {}
// 点击-阅读
+ (void)founderEventClickAppinit:(Article *)Article;
// 分享
+ (void)founderEventShareAppinit:(int)articleID;
+ (void)founderBDataInit:(NSString *)appID withUrlString:(NSString *)appUrl;
//启动APP事件
+(void)appinitDateAnaly;
//关闭APP事件
+(void)appcloseDateAnaly;
//栏目点击事件
+(void)columnclickDateAnaly:(NSString *)columnName;
//文章点击事件
+(void)articleclickDateAnaly:(int)articleID column:(NSString *)columnName bid:(NSString *)bid;
//文章浏览事件
+(void)articleviewDateAnaly:(int)articleID column:(NSString *)columnName;
//文章评论事件
+(void)articlecommentDateAnaly:(int)articleID column:(NSString *)columnName;
//文章分享事件
+(void)shareDateAnaly:(int)articleID column:(NSString *)columnName;
//文章收藏事件
+(void)articlefavoriteDateAnaly:(int)articleID column:(NSString *)columnName;
//文章返回事件
+(void)articlereturnDateAnaly:(int)articleID column:(NSString *)columnName;
//推荐展示事件
+(void)reczsDateAnaly:(NSString *)articleID column:(NSString *)columnName bid:(NSString *)bid row:(int)row;
@end
