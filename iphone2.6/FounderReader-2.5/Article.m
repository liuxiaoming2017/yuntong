//
//  Article.m
//  FounderReader-2.5
//
//  Created by chenfei on 4/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Article.h"
#import "Defines.h"
#import "DataLib/DataLib.h"
#import "NSString+Helper.h"
static BOOL isPaper;
@implementation Article


+ (NSArray *)articlesFromArray:(NSArray *)array
{
    if ([array isKindOfClass:[NSNull class]])
    {
        return [NSArray array];
    }
    NSMutableArray *articles = [[NSMutableArray alloc] initWithCapacity:[array count]];
    for (NSDictionary *dict in array)
    {
        if ([dict isKindOfClass:[NSNull class]])
        {
            continue;
        }
        // 新-普通稿件字段
        Article *article = [[Article alloc] init];
        
        if (isPaper) {//报纸文章id
            article.fileId = [[dict objectForKey:@"id"] intValue];
            article.contentUrl = [dict objectForKey:@"curl"];
        }
        else
        {//普通文章id
            
            article.contentUrl = [dict objectForKey:@"contentUrl"];
            if ([[dict objectForKey:@"fileID"] intValue] == 0)
            {
                article.fileId = [[dict objectForKey:@"fileID"] intValue];
            }
            else
            {
                article.fileId = [[dict objectForKey:@"fileID"] intValue];
            }
        }
        article.sizeScale = [[dict objectForKey:@"sizeScale"] intValue];
        article.articleType = [[dict objectForKey:@"articleType"] intValue];
        article.title = [dict objectForKey:@"title"];
        article.attAbstract = [dict objectForKey:@"abstract"];
        if(![[dict objectForKey:@"publishTime"] isKindOfClass:[NSNull class]]){
            article.publishTime = [dict objectForKey:@"publishTime"];
        }else{
            article.publishTime = @"";
        }
        article.linkID = [[dict objectForKey:@"linkID"] intValue];
        article.imageUrlBig = [dict objectForKey:@"pic1"];
        article.isBigPic = [[dict objectForKey:@"bigPic"] intValue];
        if([NSString isNilOrEmpty:article.imageUrlBig]){
            article.isBigPic = NO;
        }
        if ([[dict objectForKey:@"beginTime"] length] > 0 && [[dict objectForKey:@"beginTime"] containsString:@"-"]) {
            
            article.questionDescription = [dict objectForKey:@"description"];
            if ([article.questionDescription isKindOfClass:[NSNull class]])
                article.questionDescription = @"";
            article.beginTime = dict[@"beginTime"];
            if ([article.beginTime isKindOfClass:[NSNull class]])
                article.beginTime = @"";
            article.interestCount = dict[@"interestCount"];
            if ([article.interestCount isKindOfClass:[NSNull class]])
                article.interestCount = @0;
            article.isFollow = [dict[@"isFollow"] boolValue];
            
            if ([[dict allKeys] containsObject:@"topicID"]) {
                // 话题+
                article.fileId = [dict[@"topicID"] intValue];
                if ([dict[@"topicID"] isKindOfClass:[NSNull class]])
                    article.fileId = 0;
                else
                    article.fileId = [dict[@"topicID"] intValue];
                
                article.topicID = dict[@"topicID"];
                if ([article.topicID isKindOfClass:[NSNull class]])
                    article.topicID = @0;
                article.imgUrl = dict[@"imgUrl"];
                if ([article.imgUrl isKindOfClass:[NSNull class]])
                    article.imgUrl = @"";
                article.topicCount = dict[@"topicCount"];
                if ([article.topicCount isKindOfClass:[NSNull class]])
                    article.topicCount = @0;
                article.isBigPic = [[dict objectForKey:@"isBigPic"] intValue];
                
                //extproperty扩展字段，用于存入数据库中没有的字段
                article.extproperty = [NSString stringWithFormat:@"topic,%lld,%@,%@,%@,%lld,%lld,%zd", article.topicID.longLongValue, article.questionDescription, article.imgUrl, article.beginTime, article.interestCount.longLongValue, article.topicCount.longLongValue, article.isFollow];
            } else {
                // 问答+
                article.fileId = [dict[@"aid"] intValue];
                if ([dict[@"aid"] isKindOfClass:[NSNull class]])
                    article.fileId = 0;
                else
                    article.fileId = [dict[@"aid"] intValue];
                
                article.imgUrl = [NSString stringWithFormat:@"%@@!md31" ,dict[@"imgUrl"]];
                if ([article.imgUrl isKindOfClass:[NSNull class]])
                    article.imgUrl = @"";
                article.authorTitle = dict[@"authorTitle"];
                if ([article.authorTitle isKindOfClass:[NSNull class]])
                    article.authorTitle = @"";
                article.authorFace = dict[@"authorFace"];
                if ([article.authorFace isKindOfClass:[NSNull class]])
                    article.authorFace = @"";
                article.createTime = dict[@"createtime"];
                if ([article.createTime isKindOfClass:[NSNull class]])
                    article.createTime = @"";
                article.authorID = dict[@"authorID"];
                if ([article.authorID isKindOfClass:[NSNull class]])
                    article.authorID = @0;
                article.authorName = dict[@"authorName"];
                if ([article.authorName isKindOfClass:[NSNull class]])
                    article.authorName = @"";
                article.authorDesc = dict[@"authorDesc"];
                if ([article.authorDesc isKindOfClass:[NSNull class]])
                    article.authorDesc = @"";
                article.lastID = dict[@"aid"];
                if ([article.lastID isKindOfClass:[NSNull class]])
                    article.lastID = @0;
                article.askCount = dict[@"askCount"];
                if ([article.askCount isKindOfClass:[NSNull class]])
                    article.askCount = @0;
                article.askTime = dict[@"asktime"];
                if ([article.askTime isKindOfClass:[NSNull class]])
                    article.askTime = @"";
                
                //extproperty扩展字段，用于存入数据库中没有的字段
                article.extproperty = [NSString stringWithFormat:@"questionsAndAnswers,%@,%@,%@,%@,%lld,%@,%@,%@,%lld,%@,%lld,%lld,%@,%zd", article.questionDescription, article.authorTitle, article.authorFace, article.createTime, article.authorID.longLongValue, article.authorName, article.imgUrl, article.authorDesc, article.lastID.longLongValue, article.beginTime, article.interestCount.longLongValue, article.askCount.longLongValue, article.askTime, article.isFollow];
            }
        } else {
            article.questionDescription = [dict objectForKey:@"description"];
            article.authorTitle = @"";
            article.authorFace = @"";
            article.createTime = @"";
            article.authorID = @0;
            article.authorName = @"";
            article.imgUrl = @"";
            article.authorDesc = @"";
            article.lastID = @0;
            article.beginTime = @"";
            article.interestCount = @0;
            article.askCount = @0;
            article.askTime = @"";
            article.extproperty = @"";
            article.topicID = @0;
            article.topicCount = @0;
        }
        
        if([[dict objectForKey:@"直播开始时间"] length] > 0 && [[dict objectForKey:@"直播开始时间"] containsString:@"-"]){
            article.liveStartTime = [dict objectForKey:@"直播开始时间"];
            article.liveEndTime = [dict objectForKey:@"直播结束时间"];
            //extproperty扩展字段，用于存入数据库中没有的字段
            article.extproperty = [NSString stringWithFormat:@"liveTime,%@,%@", article.liveStartTime, article.liveEndTime];
        }
        else{
            article.liveStartTime = @"";
            article.liveEndTime = @"";
        }
        
        if([[dict objectForKey:@"活动开始时间"] length] > 0 && [[dict objectForKey:@"活动开始时间"] containsString:@"-"]){
            article.activityStartTime = [dict objectForKey:@"活动开始时间"];
            article.activityEndTime = [dict objectForKey:@"活动结束时间"];
            //extproperty扩展字段，用于存入数据库中没有的字段
            article.extproperty = [NSString stringWithFormat:@"%@&&activityTime,%@,%@", article.extproperty, article.activityStartTime, article.activityEndTime];
        }
        else{
            article.activityStartTime = @"";
            article.activityEndTime = @"";
        }
        
        if([[dict objectForKey:@"投票开始时间"] length] > 0 && [[dict objectForKey:@"投票开始时间"] containsString:@"-"]){
            article.voteStartTime = [dict objectForKey:@"投票开始时间"];
            article.voteEndTime = [dict objectForKey:@"投票结束时间"];
            //extproperty扩展字段，用于存入数据库中没有的字段
            article.extproperty = [NSString stringWithFormat:@"%@&&voteTime,%@,%@", article.extproperty, article.voteStartTime, article.voteEndTime];
        }
        else{
            article.voteStartTime = @"";
            article.voteEndTime = @"";
        }
        
        if([[dict objectForKey:@"提问开始时间"] length] > 0 && [[dict objectForKey:@"提问开始时间"] containsString:@"-"]){
            article.askStartTime = [dict objectForKey:@"提问开始时间"];
            article.askEndTime = [dict objectForKey:@"提问结束时间"];
            //extproperty扩展字段，用于存入数据库中没有的字段
            article.extproperty = [NSString stringWithFormat:@"%@&&askTime,%@,%@", article.extproperty, article.askStartTime, article.askEndTime];
        }
        else{
            article.askStartTime = @"";
            article.askEndTime = @"";
        }
        if([[dict objectForKey:@"音频文件"] length] > 0 && [[dict objectForKey:@"音频文件"] containsString:@"mp3"]){
            article.audioUrl = [dict objectForKey:@"音频文件"];
            article.extproperty = [NSString stringWithFormat:@"%@&&audioUrl,%@", article.extproperty, article.audioUrl];
        }
        else{
            article.audioUrl = @"";
        }
        if([[dict objectForKey:@"音频标题"] length] > 0 ){
            article.audioTitle = [dict objectForKey:@"音频标题"];
        }
        else{
            article.audioTitle = @"";
        }
        
        // 新-广告
        article.advID = [[dict objectForKey:@"advID"] intValue];
        article.style = [[dict objectForKey:@"style"] intValue];
        article.type = [[dict objectForKey:@"type"] intValue];
        article.position = [[dict objectForKey:@"position"] intValue];
        article.adOrder = [[dict objectForKey:@"adOrder"] intValue];
        article.imgAdvUrl = [dict objectForKey:@"imgUrl"];//广告标题图
        article.startTime = [dict objectForKey:@"startTime"];
        article.endTime = [dict objectForKey:@"endTime"];
        article.pageTime = [[dict objectForKey:@"pageTime"] intValue];
        
        if([dict objectForKey:@"pic1"] && [[dict objectForKey:@"pic1"] length] > 0)
        {
            if (article.isBigPic) {
                article.imageUrl = [NSString stringWithFormat:@"%@@!md169", [dict objectForKey:@"pic1"]];
            }
            else{
                article.imageUrl = [NSString stringWithFormat:@"%@@!sm43", [dict objectForKey:@"pic1"]];
            }
        }
        else{
            article.imageUrl = @"";
        }
        
        //如果是广告
        if (article.type != 0)
        {   //广告类型图片处理
            article.imageUrl = article.imgAdvUrl;
            //广告稿件不自带articleType，需要我们赋值
            article.articleType = ArticleType_ADV;//8
        }
        
        if (article.articleType != ArticleType_IMAGE)
        {
            NSString *pic1 = [dict objectForKey:@"pic1"];
            NSString *pic2 = [dict objectForKey:@"pic2"];
            NSString *pic3 = [dict objectForKey:@"pic3"];
            if (![NSString isNilOrEmpty:pic1] && ![NSString isNilOrEmpty:pic2] && ![NSString isNilOrEmpty:pic3]) {
                article.groupImageUrl = [NSString stringWithFormat:@"%@,%@,%@",[NSString stringFromNil:[dict objectForKey:@"pic1"]],[NSString stringFromNil:[dict objectForKey:@"pic2"]],[NSString stringFromNil:[dict objectForKey:@"pic3"]]];
            }
        }
        else
        {
            //如果是组图，把组图和标题图存到组图url中，前三张为组图前三张图，后三张为标题大中小图
            article.groupImageUrl = [NSString stringWithFormat:@"%@,%@,%@,%@,%@,%@", [dict objectForKey:@"pic1"],[dict objectForKey:@"pic2"],[dict objectForKey:@"pic3"],[NSString stringFromNil:[dict objectForKey:@"pic3"]],[NSString stringFromNil:[dict objectForKey:@"pic2"]],[NSString stringFromNil:[dict objectForKey:@"pic1"]]];
        }
        
    if(![[dict objectForKey:@"countClick"] isKindOfClass:[NSNull class]]){
        if ([[dict objectForKey:@"countClick"] isKindOfClass:[NSString class]])
        {
            article.readCount = [dict objectForKey:@"countClick"];
        }
        else
        {
            article.readCount = [[dict objectForKey:@"countClick"] stringValue];
        }
    }
        if ([[dict objectForKey:@"countDiscuss"] isKindOfClass:[NSString class]])
        {
            article.commentCount = [dict objectForKey:@"countDiscuss"];
        }
        else
        {
            article.commentCount = [[dict objectForKey:@"countDiscuss"] stringValue];
        }
        
        if ([[dict objectForKey:@"countPraise"] isKindOfClass:[NSString class]])
        {
            article.greatCount = [dict objectForKey:@"countPraise"];
        }
        else
        {
            article.greatCount = [[dict objectForKey:@"countPraise"] stringValue];
        }
        
        if ([[dict objectForKey:@"picCount"] isKindOfClass:[NSString class]])
        {
            article.picCount = [dict objectForKey:@"picCount"];
        }
        else
        {
            article.picCount = [[dict objectForKey:@"picCount"] stringValue];
        }
        article.shareCount = [dict objectForKey:@"countShare"];
        article.countShareClick = [dict objectForKey:@"countShareClick"];
        article.tag = [dict objectForKey:@"tag"];
        article.version = [dict objectForKey:@"version"];
        
        // 旧字段
        article.shareUrl = [dict objectForKey:@"shareUrl"];
        article.videoUrl = [dict objectForKey:@"videoUrl"];
        if ([[dict objectForKey:@"tag"] isKindOfClass:[NSString class]])
        {
            article.category = [dict objectForKey:@"tag"];
        }
        if ([[dict objectForKey:@"keyWord"] isKindOfClass:[NSString class]])
        {
            article.keyWord = [dict objectForKey:@"keyWord"];
        }
        article.imageSize = [dict objectForKey:@"imageSize"];//300*170
        article.columnName = [dict objectForKey:@"colName"];
        article.discussClosed = [[dict objectForKey:@"discussClosed"] boolValue];
        
        [articles addObject:article];
    }
    
    return articles;
}

+ (Article *)articleFromDict:(NSDictionary *)dict
{
    Article *article = [[Article alloc] init];
    article.fileId = [[dict objectForKey:@"fileID"] intValue];
    article.articleType = [[dict objectForKey:@"articleType"] intValue];
    article.title = [dict objectForKey:@"title"];
    article.attAbstract = [dict objectForKey:@"abstract"];
    if(![[dict objectForKey:@"publishTime"] isKindOfClass:[NSNull class]]){
    article.publishTime = [dict objectForKey:@"publishTime"];
    }else{
        article.publishTime = @"";
    }
    article.linkID = [[dict objectForKey:@"linkID"] intValue];
    article.imageUrlBig = [dict objectForKey:@"picBig"];
    article.isBigPic = [[dict objectForKey:@"bigPic"] intValue];
    article.audioUrl = [dict objectForKey:@"音频文件"];
    article.audioTitle = [dict objectForKey:@"音频标题"];
    if (ArticleType_SPECIAL == article.articleType)
    {
        //专题稿件类型优先选用中图
        if([dict objectForKey:@"picMiddle"] != nil)
        {
            article.imageUrl = [dict objectForKey:@"picMiddle"];
        }
        else
        {
            article.imageUrl = [dict objectForKey:@"picSmall"];
        }
    }
    else
    {
        if (article.isBigPic)
        {
            //大图模式的稿件类型优先选用中图
            if([dict objectForKey:@"picMiddle"] != nil)
            {
                article.imageUrl = [dict objectForKey:@"picMiddle"];
            }
            else
            {
                article.imageUrl = [dict objectForKey:@"picSmall"];
            }
        }
        else
        {
            if([dict objectForKey:@"picSmall"] != nil)
            {
                article.imageUrl = [dict objectForKey:@"picSmall"];
            }
            else
            {
                article.imageUrl = [dict objectForKey:@"picMiddle"];
            }
        }
    }
    
    
    if (article.articleType != ArticleType_IMAGE)
    {
        article.groupImageUrl = [NSString stringWithFormat:@"%@,%@,%@",[NSString stringFromNil:[dict objectForKey:@"picBig"]],[NSString stringFromNil:[dict objectForKey:@"picMiddle"]],[NSString stringFromNil:[dict objectForKey:@"picSmall"]]];
    }
    else
    {
        //如果是组图，把组图和标题图存到组图url中，前三张为组图前三张图，后三张为标题大中小图
        article.groupImageUrl = [NSString stringWithFormat:@"%@,%@,%@,%@,%@,%@", [dict objectForKey:@"pic0"],[dict objectForKey:@"pic1"],[dict objectForKey:@"pic2"],[NSString stringFromNil:[dict objectForKey:@"picBig"]],[NSString stringFromNil:[dict objectForKey:@"picMiddle"]],[NSString stringFromNil:[dict objectForKey:@"picSmall"]]];
    }
    if ([[dict objectForKey:@"countClick"] isKindOfClass:[NSString class]])
    {
        article.readCount = [dict objectForKey:@"countClick"];
    }
    else
    {
        article.readCount = [[dict objectForKey:@"countClick"] stringValue];
    }
    
    if ([[dict objectForKey:@"countDiscuss"] isKindOfClass:[NSString class]])
    {
        article.commentCount = [dict objectForKey:@"countDiscuss"];
    }
    else
    {
        article.commentCount = [[dict objectForKey:@"countDiscuss"] stringValue];
    }
    
    if ([[dict objectForKey:@"countPraise"] isKindOfClass:[NSString class]])
    {
        article.greatCount = [dict objectForKey:@"countPraise"];
    }
    else
    {
        article.greatCount = [[dict objectForKey:@"countPraise"] stringValue];
    }
    
    
    if ([[dict objectForKey:@"picCount"] isKindOfClass:[NSString class]])
    {
        article.picCount = [dict objectForKey:@"picCount"];
    }
    else
    {
        article.picCount = [[dict objectForKey:@"picCount"] stringValue];
    }
    article.shareCount = [dict objectForKey:@"countShare"];
    article.countShareClick = [dict objectForKey:@"countShareClick"];
    article.tag = [dict objectForKey:@"tag"];
    article.version = [dict objectForKey:@"version"];
    
    
    article.videoUrl = [dict objectForKey:@"videoUrl"];
    article.contentUrl = [dict objectForKey:@"contentUrl"];
    NSRange range = [article.contentUrl rangeOfString:@"getArticleContent"];
    
    if (range.location != NSNotFound)
    {
        NSString *version = [dict objectForKey:@"version"];
        if (version == nil)
        {
            version = @"0";
        }
        article.contentUrl = [NSString stringWithFormat:@"%@&version=%@", [dict objectForKey:@"contentUrl"], version];
    }
    
    article.shareUrl = [dict objectForKey:@"shareUrl"];
    
    if ([[dict objectForKey:@"tag"] isKindOfClass:[NSString class]])
    {
        article.category = [dict objectForKey:@"tag"];
    }
    if ([[dict objectForKey:@"keyWord"] isKindOfClass:[NSString class]])
    {
        article.keyWord = [dict objectForKey:@"keyWord"];
    }
    article.imageSize = [dict objectForKey:@"imageSize"];//300*170
    article.columnName = [dict objectForKey:@"colName"];
    return article;
}

+ (void)changePagerFlag
{
    isPaper = !isPaper;
}
-(NSString *)description{
    return [NSString stringWithFormat:@"articleType:%zd,isBigPic:%zd,bigPic:%@",self.articleType,self.isBigPic,self.bigPic?@"Yes":@"no"];
}
@end
