//
//  FounderEventRequest.m
//  FounderReader-2.5
//
//  Created by yan.bf on 15/5/18.
//
//
#import "FounderEventRequest.h"
#import "UserAccountDefine.h"
#import "DataChannelPageController.h"
#import "dataCollection_SDK.h"

static NSString *FounderDBAppID = @"";
static NSString *FounderDBTimespan = @"0";//单位毫秒
static dataCollection_SDK *fDataCollection = nil;

@implementation FounderEventRequest
// 点击-阅读
+ (void)founderEventClickAppinit:(Article *)Article
{
    if(Article.fileId <= 0)
        return;

    NSString *urlStr = [NSString stringWithFormat:@"%@/api/event",[AppConfig sharedAppConfig].serverIf];
    NSString *bodyString = [NSString stringWithFormat:@"sid=%@&id=%d&type=0&eventType=0",[AppConfig sharedAppConfig].sid,Article.fileId];
    NSData *data = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    
    HttpRequest *request = [HttpRequest requestWithURL:[NSURL URLWithString:urlStr]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:data];
    
    [request setCompletionBlock:^(id data)
     {
         NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers  error:nil];
         NSString *str = [NSString stringWithFormat:@"%d",[[dic objectForKey:@"countClick"] intValue]];
         if (str != nil && ![str isEqualToString:@""])
         {
             XYLog(@"success!");
         }
         
     }];
    [request setFailedBlock:^(NSError *error) {
        XYLog(@"参数传递不正确: %@", error);
    }];
    [request startAsynchronous];
}
// 分享点击事件
+ (void)founderEventShareAppinit:(int)articleID{
    
    if(articleID <= 0)
        return;
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/api/event",[AppConfig sharedAppConfig].serverIf];
    NSString *bodyString = [NSString stringWithFormat:@"sid=%@&id=%d&type=0&eventType=3",[AppConfig sharedAppConfig].sid, articleID];
    NSData *data = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    
    HttpRequest *request = [HttpRequest requestWithURL:[NSURL URLWithString:urlStr]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:data];
    
    [request setCompletionBlock:^(id data){
        
     }];
    [request setFailedBlock:^(NSError *error) {
        XYLog(@"参数传递不正确: %@", error);
    }];
    [request startAsynchronous];
}
#pragma 方正大数据行为采集
+(void)founderBDataInit:(NSString *)appID withUrlString:(NSString *)appUrl{
    if(appID.length == 0 || appUrl.length == 0){
        NSLog(@"未设置方正大数据行为采集AppID，无法使用该功能。");
        return;
    }
    if(fDataCollection == nil){
        FounderDBAppID = appID;
//        fDataCollection = [[dataCollection_SDK alloc] initWithTimespan:FounderDBTimespan withUrlString:appUrl];
//        fDataCollection.appid = appID;
    }
}
//启动APP事件
+(void)appinitDateAnaly{
    if(!fDataCollection)
        return;
    NSString *v = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];//app版本号
   // [fDataCollection appinitDateAnaly:[Global userId] v:v mainVersion:v];
}
//关闭APP事件
+(void)appcloseDateAnaly{
    if(!fDataCollection)
        return;
   // [fDataCollection appcloseDateAnaly:[Global userId]];
}
//栏目点击事件
+(void)columnclickDateAnaly:(NSString *)columnName{
    if(!fDataCollection || [NSString isNilOrEmpty:columnName])
        return;
   // [fDataCollection columnclickDateAnaly:[Global userId] cname:columnName separator:@"~"];
}
//文章点击事件
+(void)articleclickDateAnaly:(int)articleID column:(NSString *)columnName bid:(NSString *)bid{
    if(!fDataCollection || articleID <= 0 || [NSString isNilOrEmpty:columnName])
        return;
    NSString *rt = @"online";	//取值范围online,testa,testb,一般取online即可
   // [fDataCollection articleclickDateAnaly:[Global userId] cname:columnName aid:[NSString stringWithFormat:@"%d", articleID] bid:bid rt: rt separator:@"~"];
}
//文章浏览事件
+(void)articleviewDateAnaly:(int)articleID column:(NSString *)columnName{
    if(!fDataCollection || articleID <= 0 || [NSString isNilOrEmpty:columnName])
        return;
    //[fDataCollection articleviewDateAnaly:[Global userId] cname:columnName aid:[NSString stringWithFormat:@"%d", articleID] separator:@"~"];
}
//文章评论事件
+(void)articlecommentDateAnaly:(int)articleID column:(NSString *)columnName{
    if(!fDataCollection || articleID <= 0 || [NSString isNilOrEmpty:columnName])
        return;
   // [fDataCollection articlecommentDateAnaly:[Global userId] cname:columnName aid:[NSString stringWithFormat:@"%d", articleID] separator:@"~"];
}
//文章分享事件
+(void)shareDateAnaly:(int)articleID column:(NSString *)columnName{
    if(!fDataCollection || articleID <= 0 || [NSString isNilOrEmpty:columnName])
        return;
   // [fDataCollection shareDateAnaly:[Global userId] cname:columnName aid:[NSString stringWithFormat:@"%d", articleID] separator:@"~"];
}
//文章收藏事件
+(void)articlefavoriteDateAnaly:(int)articleID column:(NSString *)columnName{
    if(!fDataCollection || articleID <= 0 || [NSString isNilOrEmpty:columnName])
        return;
    //[fDataCollection articlefavoriteDateAnaly:[Global userId] cname:columnName aid:[NSString stringWithFormat:@"%d", articleID] separator:@"~"];
}
//文章返回事件
+(void)articlereturnDateAnaly:(int)articleID column:(NSString *)columnName{
    if(!fDataCollection || articleID <= 0 || [NSString isNilOrEmpty:columnName])
        return;
   // [fDataCollection articlereturnDateAnaly:[Global userId] cname:columnName aid:[NSString stringWithFormat:@"%d", articleID] separator:@"~"];
}
//推荐展示事件
+(void)reczsDateAnaly:(NSString *)articleID column:(NSString *)columnName bid:(NSString *)bid row:(int)row{
    if(!fDataCollection)
        return;
    NSString *rt = @"online";	//取值范围online,testa,testb,一般取online即可
    NSString *rowStr = [NSString stringWithFormat:@"%d", row];
   // [fDataCollection reczsDateAnaly:[Global userId] cname:columnName aid:articleID bid:bid row:rowStr rtype:rt separator:@"~"];
}
@end
