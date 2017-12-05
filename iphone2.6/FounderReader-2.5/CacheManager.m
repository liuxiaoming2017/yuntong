//
//  CacheManager.m
//  FounderReader-2.5
//
//  Created by chenfei on 5/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CacheManager.h"
#import "Column.h"
#import "Article.h"
#import "Attachment.h"
#import "AppConfig.h"
#import "ColumnRequest.h"
#import "ArticleRequest.h"
#import "NewsListConfig.h"
#import "DataLib/DataLib.h"
#import "UIApplication+NetworkActivity.h"
#import "NSString+Helper.h"
#import "AppStartInfo.h"
#import "attactmentmodel.h"
#import "SDWebImage/SDImageCache.h"
static CacheManager *__cacheManager = nil;

@implementation CacheManager

@synthesize db = _db;

- (void)dealloc
{
    [self.db close];
    self.db = nil;
    
//    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self) {
        self.db = [FMDatabase databaseWithPath:dbPath()];
        [self.db open];
    }
    return self;
}

+ (CacheManager *)sharedCacheManager
{
    if (__cacheManager == nil)
        __cacheManager = [[self alloc] init];
    return __cacheManager;
}
//MARK: ----Recommend
//推荐新闻
- (void)insertRecommendList:(NSString *)list columnId:(int)columnId timestamp:(NSString *)timestamp{
    FMResultSet * set = [_db executeQuery:@"select count(time) as countNum from recommends"];
    if ([set next]) {
        int count = [set intForColumn:@"countNum"];
        if (count >= 10) {
            count = count - 9;
            [_db executeUpdate:@"delete from recommends where time in (select time from recommends order by time asc limit ?)",[NSNumber numberWithInt:count]];
        }
    }
    [_db executeUpdate:@"insert into recommends (content,column_id,time) values (?,?,?)",list,[NSNumber numberWithInt:columnId],timestamp];
}

//获取上一页
- (NSDictionary *)getRecommendListWithTime:(NSString *)timestamp{
    FMResultSet * set = [_db executeQuery:@"select content,time from recommends where time < ?   order by time desc limit 1",timestamp];
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    if ([set next]) {
        dict[@"list"] = [set stringForColumn:@"content"];
        dict[@"timesTamp"] = [set stringForColumn:@"time"];
    }
    [set close];
    return dict;
}

#pragma mark - versions

- (void)updateOrInsert:(int)columnId columnsVersion:(int)columnsVersion
{
    FMResultSet *set = [_db executeQuery:@"select column_id from versions where column_id = ?", [NSNumber numberWithInteger:columnId]];
    if ([set next])
        [_db executeUpdate:@"update versions set columns_version = ? where column_id = ?", [NSNumber numberWithInt:columnsVersion], [NSNumber numberWithInt:columnId]];
    else
        [_db executeUpdate:@"insert into versions (column_id, columns_version, articles_version) values (?, ?, ?)",
         [NSNumber numberWithInt:columnId], [NSNumber numberWithInt:columnsVersion], [NSNumber numberWithInt:0]];
    [set close];
}

- (void)updateOrInsert:(int)columnId articlesVersion:(int)articlesVersion
{
    FMResultSet *set = [_db executeQuery:@"select column_id from versions where column_id = ?", [NSNumber numberWithInteger:columnId]];
    if ([set next])
        [_db executeUpdate:@"update versions set articles_version = ? where column_id = ?", [NSNumber numberWithInt:articlesVersion], [NSNumber numberWithInt:columnId]];
    else
        [_db executeUpdate:@"insert into versions (column_id, columns_version, articles_version) values (?, ?, ?)",
         [NSNumber numberWithInt:columnId], [NSNumber numberWithInt:0], [NSNumber numberWithInt:articlesVersion]];
    [set close];
}

- (void)deleteVersions
{
    [_db executeUpdate:@"delete from versions"];
}

- (int)columnsVersion:(int)columnId
{
    FMResultSet *set = [_db executeQuery:@"select columns_version from versions where column_id = ?", [NSNumber numberWithInteger:columnId]];
    if ([set next]) {
        int columnsVersion = [set intForColumn:@"columns_version"];
        [set close];
        return columnsVersion;
    } else {
        [_db executeUpdate:@"insert into versions (column_id, columns_version, articles_version) values (?, ?, ?)",
         [NSNumber numberWithInt:columnId], [NSNumber numberWithInt:0], [NSNumber numberWithInt:0]];
        [set close];
        return 0;
    }
}

- (int)articlesVersion:(int)columnId
{
    FMResultSet *set = [_db executeQuery:@"select articles_version from versions where column_id = ?", [NSNumber numberWithInteger:columnId]];
    if ([set next]) {
        int articlesVersion = [set intForColumn:@"articles_version"];
        [set close];
        return articlesVersion;
    } else {
        [_db executeUpdate:@"insert into versions (column_id, columns_version, articles_version) values (?, ?, ?)",
         [NSNumber numberWithInt:columnId], [NSNumber numberWithInt:0], [NSNumber numberWithInt:0]];
        [set close];
        return 0;
    }
}

#pragma mark - columns

- (void)insertColumn:(Column *)column parentColumnId:(int)parentColumnId displayOrder:(int)order
{
    [_db executeUpdate:@"insert into columns (column_id,column_topArticleNum ,column_name,column_type,column_style,column_value,column_linkUrl,column_show, phone_icon_url, phone_retina_icon_url, parent_column_id, display_order) values (?, ?,?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
     [NSNumber numberWithInt:column.columnId],[NSNumber numberWithInt:column.topArticleNum], column.columnName, column.columnType, column.columnStyle, column.columnvalue,column.linkUrl,[NSNumber numberWithBool:column.showcolumn], column.iconUrl, @"", [NSNumber numberWithInt:parentColumnId], [NSNumber numberWithInt:order]];
}

- (void)updateColumns:(NSArray *)columns parentColumnId:(int)parentColumnId
{
    [_db executeUpdate:@"delete from columns where parent_column_id = ?", [NSNumber numberWithInt:parentColumnId]];
    
    int i = 0;
    for (Column *column in columns) {
        [self insertColumn:column parentColumnId:parentColumnId displayOrder:i];
        ++i;
    }
}

- (NSArray *)columns:(int)parentColumnId
{
    NSMutableArray *columns = [[NSMutableArray alloc] init];
    FMResultSet *set = [_db executeQuery:@"select column_id, column_topArticleNum, column_name,column_type,column_style,column_value,column_linkUrl,column_show, phone_icon_url, phone_retina_icon_url from columns where parent_column_id = ? order by display_order", [NSNumber numberWithInteger:parentColumnId]];
    while ([set next]) {
        Column *column = [[Column alloc] init];
        column.columnId = [set intForColumn:@"column_id"];
        column.topArticleNum = [set intForColumn:@"column_topArticleNum"];
        column.columnName = [set stringForColumn:@"column_name"];
        column.columnType = [set stringForColumn:@"column_type"];
        column.columnStyle = [set stringForColumn:@"column_style"];
        column.columnvalue = [set stringForColumn:@"column_value"];
        column.linkUrl = [set stringForColumn:@"column_linkUrl"];
        column.showcolumn = [set boolForColumn:@"column_show"];
        column.iconUrl = [set stringForColumn:@"phone_icon_url"];
        [columns addObject:column];
       
    }
    [set close];
    return columns;
}

#pragma mark - articles

- (void)insertArticle:(Article *)article
{
    FMResultSet *set = [_db executeQuery:@"select article_id from articles where article_id = ?", [NSNumber numberWithInteger:article.fileId]];
    if (![set next])
        [_db executeUpdate:@"insert into articles (article_id,article_type, title, summary, publish_time, image_url, groupImage_url, video_url, content_url, share_url, extproperty, category, readCount, commentCount,imageSize,greatCount,linkID,imageUrl_Big,is_Relative,column_Name,is_BigPic,type,position,adOrder,startTime,endTime,pageTime,advID,imgAdvUrl,discussClosed,tag,sizeScale,audioTitle) values (?,?, ?, ?, ?, ?, ?, ?, ?,?,?, ?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
         [NSNumber numberWithInt:article.fileId],[NSNumber numberWithInt:article.articleType], article.title, article.attAbstract, article.publishTime, article.imageUrl, article.groupImageUrl,article.videoUrl, article.contentUrl, article.shareUrl,article.extproperty, article.category, article.readCount, article.commentCount,article.imageSize, article.greatCount,[NSNumber numberWithInt:article.linkID],article.imageUrlBig,[NSNumber numberWithInt:0],article.columnName,[NSNumber numberWithInt:article.isBigPic],[NSNumber numberWithInt:article.type],[NSNumber numberWithInt:article.position],[NSNumber numberWithInt:article.adOrder],article.startTime,article.endTime,[NSNumber numberWithInt:article.pageTime],[NSNumber numberWithInt:article.advID],article.imgAdvUrl,[NSNumber numberWithBool:article.discussClosed],article.tag,[NSNumber numberWithInt:article.sizeScale],article.audioTitle ? article.audioTitle : @""];
}

- (void)insertArticles:(NSArray *)articles columnId:(int)columnId
{
    for (Article *article in articles) {
        [self insertArticle:article];
    }
    
    [self insert:columnId articles:articles];
}

- (void)updateAritcles:(NSArray *)articles columnId:(int)columnId
{
    [_db executeUpdate:@"delete from articles where article_id in (select article_id from column_article where column_id = ? and article_id not in (select article_id from column_article where column_id = ? group by article_id HAVING count(article_id) >= 2))",
     [NSNumber numberWithInt:columnId], [NSNumber numberWithInt:columnId]];
    
    [self deleteColumnArticles:columnId];
    [self deleteColumnHasMore:columnId];
    [self  insertArticles:articles columnId:columnId];
}

- (NSArray *)articles:(int)columnId rowNumber:(int)rowNumber count:(int)count
{
    NSMutableArray *articles = [[NSMutableArray alloc] init];
    FMResultSet *set = [_db executeQuery:@"select * from articles inner join column_article on articles.article_id = column_article.article_id where column_article.column_id = ? limit ? offset ?",
                        [NSNumber numberWithInt:columnId], [NSNumber numberWithInteger:count], [NSNumber numberWithInt:rowNumber]];
    while ([set next]) {
        Article *article = [[Article alloc] init];
        article.fileId = [set intForColumn:@"article_id"];
        article.articleType = [set intForColumn:@"article_type"];
        article.title = [set stringForColumn:@"title"];
        article.attAbstract = [set stringForColumn:@"summary"];
        article.publishTime = [set stringForColumn:@"publish_time"];
        article.imageUrl = [set stringForColumn:@"image_url"];
        article.groupImageUrl = [set stringForColumn:@"groupImage_url"];
        article.videoUrl = [set stringForColumn:@"video_url"];
        article.contentUrl = [set stringForColumn:@"content_url"];
        article.shareUrl = [set stringForColumn:@"share_url"];
        article.extproperty = [set stringForColumn:@"extproperty"];
        article.audioTitle = [set stringForColumn:@"audioTitle"];
        if(article.extproperty.length > 0){
            NSArray *extArray = [article.extproperty componentsSeparatedByString:@"&&"];
            for (NSString *subExtproperty in extArray) {
                NSArray *subExtArray = [subExtproperty componentsSeparatedByString:@","];
                if(subExtArray.count == 3 && [[subExtArray objectAtIndex:0] compare:@"liveTime"] == NSOrderedSame){
                    article.liveStartTime = [subExtArray objectAtIndex:1];
                    article.liveEndTime = [subExtArray objectAtIndex:2];
                }else if(subExtArray.count == 3 && [[subExtArray objectAtIndex:0] compare:@"activityTime"] == NSOrderedSame){
                    article.activityStartTime = [subExtArray objectAtIndex:1];
                    article.activityEndTime = [subExtArray objectAtIndex:2];
                }
                else if(subExtArray.count == 3 && [[subExtArray objectAtIndex:0] compare:@"voteTime"] == NSOrderedSame){
                    article.voteStartTime = [subExtArray objectAtIndex:1];
                    article.voteEndTime = [subExtArray objectAtIndex:2];
                }
                else if(subExtArray.count == 3 && [[subExtArray objectAtIndex:0] compare:@"askTime"] == NSOrderedSame){
                    article.askStartTime = [subExtArray objectAtIndex:1];
                    article.askEndTime = [subExtArray objectAtIndex:2];
                }
                else if(subExtArray.count == 2 && [[subExtArray objectAtIndex:0] compare:@"audioUrl"] == NSOrderedSame){
                    article.audioUrl = [subExtArray objectAtIndex:1];
                } else if (subExtArray.count == 15 && [[subExtArray objectAtIndex:0] compare:@"questionsAndAnswers"] == NSOrderedSame) {
                    article.questionDescription = [subExtArray objectAtIndex:1];
                    article.authorTitle = [subExtArray objectAtIndex:2];
                    article.authorFace = [subExtArray objectAtIndex:3];
                    article.createTime = [subExtArray objectAtIndex:4];
                    article.authorID = [subExtArray objectAtIndex:5];
                    article.authorName = [subExtArray objectAtIndex:6];
                    article.imgUrl = [subExtArray objectAtIndex:7];
                    article.authorDesc = [subExtArray objectAtIndex:8];
                    article.lastID = [subExtArray objectAtIndex:9];
                    article.beginTime = [subExtArray objectAtIndex:10];
                    article.interestCount = [subExtArray objectAtIndex:11];
                    article.askCount = [subExtArray objectAtIndex:12];
                    article.askTime = [subExtArray objectAtIndex:13];
                    article.isFollow = [subExtArray objectAtIndex:14];
                } else if (subExtArray.count == 8 && [[subExtArray objectAtIndex:0] compare:@"topic"] == NSOrderedSame){
                    article.extproperty = [NSString stringWithFormat:@"topic,%lld,%@,%@,%@,%lld,%lld,%zd", article.topicID.longLongValue, article.questionDescription, article.imgUrl, article.beginTime, article.interestCount.longLongValue, article.topicCount.longLongValue, article.isFollow];
                    article.topicID = [subExtArray objectAtIndex:1];
                    article.questionDescription = [subExtArray objectAtIndex:2];
                    article.imgUrl = [subExtArray objectAtIndex:3];
                    article.beginTime = [subExtArray objectAtIndex:4];
                    article.interestCount = [subExtArray objectAtIndex:5];
                    article.topicCount = [subExtArray objectAtIndex:6];
                    article.isFollow = [subExtArray objectAtIndex:7];
                }
            }
        }
        article.category = [set stringForColumn:@"category"];
        article.readCount = [set stringForColumn:@"readCount"];
        article.commentCount = [set stringForColumn:@"commentCount"];
        article.columnId = columnId;
        article.isRead = [set boolForColumn:@"isRead"];
        article.imageSize = [set stringForColumn:@"imageSize"];
        article.comments = [set stringForColumn:@"comments"];
        article.greatCount = [set stringForColumn:@"greatCount"];
        article.linkID = [set intForColumn:@"linkID"];
        article.imageUrlBig = [set stringForColumn:@"imageUrl_Big"];
        article.columnName = [set stringForColumn:@"column_Name"];
        article.isBigPic = [set intForColumn:@"is_BigPic"];
        
        article.type =  [set intForColumn:@"type"];
        article.position =  [set intForColumn:@"position"];
        article.adOrder =  [set intForColumn:@"adOrder"];
        article.pageTime =  [set intForColumn:@"pageTime"];
        article.startTime =  [set stringForColumn:@"startTime"];
        article.endTime =  [set stringForColumn:@"endTime"];
        article.advID = [set intForColumn:@"advID"];
        article.imgAdvUrl = [set stringForColumn:@"imgAdvUrl"];
        article.discussClosed = [set boolForColumn:@"discussClosed"];
        article.tag = [set stringForColumn:@"tag"];
        article.sizeScale = [set intForColumn:@"sizeScale"];
        [articles addObject:article];
//        DELETE(article);
    }
    [set close];
    return articles;
}

- (NSArray *)article:(int)articleId rowNumber:(int)rowNumber count:(int)count
{
    NSMutableArray *articles = [[NSMutableArray alloc] init];
    FMResultSet *set = [_db executeQuery:@"select * from articles where article_id = ? limit ? offset ?",
                        [NSNumber numberWithInt:articleId], [NSNumber numberWithInteger:count], [NSNumber numberWithInt:rowNumber]];
    while ([set next]) {
        Article *article = [[Article alloc] init];
        article.fileId = [set intForColumn:@"article_id"];
        article.articleType = [set intForColumn:@"article_type"];
        article.title = [set stringForColumn:@"title"];
        article.attAbstract = [set stringForColumn:@"summary"];
        article.publishTime = [set stringForColumn:@"publish_time"];
        article.imageUrl = [set stringForColumn:@"image_url"];
        article.groupImageUrl = [set stringForColumn:@"groupImage_url"];
        article.videoUrl = [set stringForColumn:@"video_url"];
        article.contentUrl = [set stringForColumn:@"content_url"];
        article.shareUrl = [set stringForColumn:@"share_url"];
        article.extproperty = [set stringForColumn:@"extproperty"];
        article.category = [set stringForColumn:@"category"];
        article.readCount = [set stringForColumn:@"readCount"];
        article.commentCount = [set stringForColumn:@"commentCount"];
        article.columnId = 0;
        article.isRead = [set boolForColumn:@"isRead"];
        article.imageSize = [set stringForColumn:@"imageSize"];
        article.comments = [set stringForColumn:@"comments"];
        article.greatCount = [set stringForColumn:@"greatCount"];
        article.linkID = [[set stringForColumn:@"linkID"] intValue];
        article.imageUrlBig = [set stringForColumn:@"imageUrl_Big"];
        article.columnName = [set stringForColumn:@"column_Name"];
        article.isBigPic = [set intForColumn:@"is_BigPic"];
        article.audioTitle = [set stringForColumn:@"audioTitle"];
        article.type =  [set intForColumn:@"type"];
        article.position =  [set intForColumn:@"position"];
        article.adOrder =  [set intForColumn:@"adOrder"];
        article.pageTime =  [set intForColumn:@"pageTime"];
        article.startTime =  [set stringForColumn:@"startTime"];
        article.endTime =  [set stringForColumn:@"endTime"];
        article.advID = [set intForColumn:@"advID"];
        article.imgAdvUrl = [set stringForColumn:@"imgAdvUrl"];
        article.discussClosed = [set boolForColumn:@"discussClosed"];
        article.tag = [set stringForColumn:@"tag"];
        article.sizeScale = [set intForColumn:@"sizeScale"];
        [articles addObject:article];
//        DELETE(article);
    }
    [set close];
    return articles;
}

- (NSArray *)allArticles
{
    NSMutableArray *articles = [[NSMutableArray alloc] init];
    FMResultSet *set = [_db executeQuery:@"select * from articles"];
                        
    while ([set next]) {
        Article *article = [[Article alloc] init];
        article.fileId = [set intForColumn:@"article_id"];
        article.articleType = [set intForColumn:@"article_type"];
        article.title = [set stringForColumn:@"title"];
        article.attAbstract = [set stringForColumn:@"summary"];
        article.publishTime = [set stringForColumn:@"publish_time"];
        article.imageUrl = [set stringForColumn:@"image_url"];
        article.groupImageUrl = [set stringForColumn:@"groupImage_url"];
        article.videoUrl = [set stringForColumn:@"video_url"];
        article.contentUrl = [set stringForColumn:@"content_url"];
        article.shareUrl = [set stringForColumn:@"share_url"];
        article.extproperty = [set stringForColumn:@"extproperty"];
        article.isRead = [set boolForColumn:@"isRead"];
        article.imageSize = [set stringForColumn:@"imageSize"];
        article.comments = [set stringForColumn:@"comments"];
        article.greatCount = [set stringForColumn:@"greatCount"];
        article.linkID = [[set stringForColumn:@"linkID"] intValue];
        article.imageUrlBig = [set stringForColumn:@"imageUrl_Big"];
        article.columnName = [set stringForColumn:@"column_Name"];
        article.isBigPic = [set intForColumn:@"is_BigPic"];
        
        article.type =  [set intForColumn:@"type"];
        article.position =  [set intForColumn:@"position"];
        article.adOrder =  [set intForColumn:@"adOrder"];
        article.pageTime =  [set intForColumn:@"pageTime"];
        article.startTime =  [set stringForColumn:@"startTime"];
        article.endTime =  [set stringForColumn:@"endTime"];
        article.advID = [set intForColumn:@"advID"];
        article.imgAdvUrl = [set stringForColumn:@"imgAdvUrl"];
        article.discussClosed = [set boolForColumn:@"discussClosed"];
        article.tag = [set stringForColumn:@"tag"];
        article.sizeScale = [set intForColumn:@"sizeScale"];
        [articles addObject:article];
//        DELETE(article);
    }
    [set close];
    return articles;
}

- (void)deleteArticles
{
    [_db executeUpdate:@"delete from articles"];
}

- (NSArray *)unCollectArticles
{
    NSMutableArray *articleIds = [[NSMutableArray alloc] init];
    FMResultSet *set = [_db executeQuery:@"select article_id from articles where article_id not in (select article_id from favorites)"];
    
    while ([set next]) {
        int articleId = [set intForColumn:@"article_id"];
        [articleIds addObject:[NSNumber numberWithInt:articleId]];
    }
    [set close];
    return articleIds;
}

#pragma mark - has_more

- (void)updateOrInsertHasMore:(int)columnId rowNumber:(int)rowNumber hasMore:(BOOL)flag
{
    FMResultSet *set = [_db executeQuery:@"select column_id from has_more where column_id = ? and row_number = ?", [NSNumber numberWithInteger:columnId], [NSNumber numberWithInt:rowNumber]];
    if ([set next])
        [_db executeUpdate:@"update has_more set row_number = ?, has_more = ? where column_id = ? and row_number = ?",
         [NSNumber numberWithInt:rowNumber], [NSNumber numberWithInt:flag], [NSNumber numberWithInt:columnId], [NSNumber numberWithInt:rowNumber]];
    else
        [_db executeUpdate:@"insert into has_more (column_id, row_number, has_more) values (?, ?, ?)",
         [NSNumber numberWithInt:columnId], [NSNumber numberWithInt:rowNumber], [NSNumber numberWithInt:flag]];
    [set close];
}

- (BOOL)hasMore:(int)columnId rowNumber:(int)rowNumber
{
    FMResultSet *set = [_db executeQuery:@"select has_more from has_more where column_id = ? and row_number = ?", [NSNumber numberWithInteger:columnId], [NSNumber numberWithInt:rowNumber]];
    if ([set next])
        return [set intForColumn:@"has_more"];
    return NO;
}

// 删除 has_more 表中某栏目对应的所有纪录
- (void)deleteColumnHasMore:(int)columnId
{
    [_db executeUpdate:@"delete from has_more where column_id = ?", [NSNumber numberWithInt:columnId]];
}

- (void)deleteHasMore
{
    [_db executeUpdate:@"delete from has_more"];
}

#pragma mark -

- (void)insert:(int)columnId articleId:(int)articleId
{
    FMResultSet *set = [_db executeQuery:@"select column_id, article_id from column_article where column_id = ? and article_id = ?",
                        [NSNumber numberWithInteger:columnId], [NSNumber numberWithInt:articleId]];
    if (![set next])
        [_db executeUpdate:@"insert into column_article (column_id, article_id) values (?, ?)", [NSNumber numberWithInt:columnId], [NSNumber numberWithInt:articleId]];
    [set close];
}

// 更新栏目稿件关联表
- (void)insert:(int)columnId articles:(NSArray *)articles
{
    for (Article *article in articles) {
        [self insert:columnId articleId:article.fileId];
    }
}

// 删除关联表中某栏目对应的所有稿件
- (void)deleteColumnArticles:(int)columnId
{
    [_db executeUpdate:@"delete from column_article where column_id = ?", [NSNumber numberWithInt:columnId]];
}

// 删除关联纪录
- (void)deleteColumnArticles
{
    [_db executeUpdate:@"delete from column_article"];
}

#pragma mark - collect

- (BOOL)collect:(Article *)article
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    NSInteger collectTime = (NSInteger)time;
    return [_db executeUpdate:@"insert into favorites (article_id,article_type, title, summary, publish_time, image_url, groupImage_url, video_url, content_url, share_url, extproperty, column_id, collectTime,type) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
            [NSNumber numberWithInt:article.fileId], [NSNumber numberWithInt:article.articleType],article.title, article.attAbstract, article.publishTime, article.imageUrl, article.groupImageUrl, article.videoUrl, article.contentUrl, article.shareUrl, article.extproperty, [NSNumber numberWithInt:article.columnId], [NSNumber numberWithInteger:collectTime], [NSNumber numberWithInt:article.type]];
}

- (void)unCollect:(int)articleId
{
    [_db executeUpdate:@"delete from favorites where article_id = ?", [NSNumber numberWithInt:articleId]];
}

- (BOOL)isCollect:(int)articleId
{
    FMResultSet *set = [_db executeQuery:@"select article_id from favorites where article_id = ?", [NSNumber numberWithInt:articleId]];
    return [set next];
}

- (NSArray *)favoriteArticles
{
    NSMutableArray *articles = [[NSMutableArray alloc] init];
    FMResultSet *set = [_db executeQuery:@"select * from favorites order by collectTime desc"];
    while ([set next]) {
        Article *article = [[Article alloc] init];
        article.fileId = [set intForColumn:@"article_id"];
        article.articleType = [set intForColumn:@"article_type"];
        article.title = [set stringForColumn:@"title"];
        article.attAbstract = [set stringForColumn:@"summary"];
        article.publishTime = [set stringForColumn:@"publish_time"];
        article.imageUrl = [set stringForColumn:@"image_url"];
        article.groupImageUrl = [set stringForColumn:@"groupImage_url"];
        article.videoUrl = [set stringForColumn:@"video_url"];
        article.contentUrl = [set stringForColumn:@"content_url"];
        article.shareUrl = [set stringForColumn:@"share_url"];
        article.columnId = [set intForColumn:@"column_id"];
        article.extproperty = [set stringForColumn:@"extproperty"];
        article.type = [set intForColumn:@"type"];
        [articles addObject:article];
    }
    [set close];
    return articles;
}

#pragma mark - clear cache

- (void)removeFile:(int)articleId
{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSArray *allItems = [manager subpathsAtPath:cacheDirPath()];
    
    for (NSString *item in allItems) {
        @autoreleasepool {
            NSRange range = [item rangeOfString:[NSString stringWithFormat:@"%d", articleId]];
            if (range.location != NSNotFound)
                [manager removeItemAtPath:[cacheDirPath() stringByAppendingPathComponent:item] error:NULL];
        }
    }
}

- (void)removeConfigFile
{
    NSFileManager *manager = [NSFileManager defaultManager];
    
    // server if
    NSString *serverIfConfigFilePath = cachePathFromURL([AppConfig sharedAppConfig].serverIf);
    [manager removeItemAtPath:serverIfConfigFilePath error:NULL];
    
    // tmp.html
    NSString *tmpHtmlPath = [cacheDirPath() stringByAppendingPathComponent:@"tmp.html"];
    [manager removeItemAtPath:tmpHtmlPath error:NULL];
}

- (void)doClear
{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSArray *allItems = [manager subpathsAtPath:cacheDirPath()];
    NSMutableArray *items = [NSMutableArray arrayWithArray:allItems];
    
    [items removeObject:kDBName];
    [items removeObject:kTemplateName];
    [items removeObject:@"interfaceServer.cfg"];
    NSString *appConfigFileName = [NSString stringWithFormat:@"getConfig?sid=%@&appId=%d", [AppConfig sharedAppConfig].sid,[AppConfig sharedAppConfig].appId];
    [items removeObject:appConfigFileName];
    [items removeObject:[[AppStartInfo sharedAppStartInfo].contentTemplate lastPathComponent]];
    
    
    for (int i = 0; i < [[self columns:0] count]; ++i) {
        [items removeObject:[NSString stringWithFormat:@"%d@2x.png", i]];
    }
    //
    NSArray *favoriteArticles = [self favoriteArticles];
    
    for (NSString *item in items) {
        int i = 0;
        for (; i < [favoriteArticles count]; ++i) {
            Article *article = [favoriteArticles objectAtIndex:i];
            NSRange range = [item rangeOfString:[NSString stringWithFormat:@"%d", article.fileId]];
            if (range.location != NSNotFound)
                break;
        }
        if (i == [favoriteArticles count]) // delete item
        {
            if (![item hasPrefix:@"menuIcon"]) {
                [manager removeItemAtPath:[cacheDirPath() stringByAppendingPathComponent:item] error:NULL];
            }
            
        }
    }
    NSString *path = [cacheDirPath() stringByAppendingPathComponent:[[AppStartInfo sharedAppStartInfo].contentTemplate lastPathComponent]];
    unzipTemplateFile(path);
}

- (void)clearCache
{
    [self doClear];
}

//单个文件的大小
+ (long long) fileSizeAtPath:(NSString*) filePath{
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}
//遍历文件夹获得文件夹大小，返回多少M
+ (float ) folderSizeAtPath:(NSString*) folderPath{
    NSFileManager* manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:folderPath])
    {
        return 0;
    }
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];
    NSString *fileName = nil;
    long long folderSize = 0;
    while ((fileName = [childFilesEnumerator nextObject]) != nil)
    {
        NSRange range0 = [fileName rangeOfString:@"c793cf1b-19ea-43f7-90f7-65aecb188e60"];
        NSRange range1 = [fileName rangeOfString:@"image?"];
        NSRange range2 = [fileName rangeOfString:@"getArticleContent?"];
        NSRange range3 = [fileName rangeOfString:@"png"];
        NSRange range4 = [fileName rangeOfString:@"jpg"];
        if(range0.length == 0 && range1.length == 0 && range2.length == 0 && range3.length == 0 && range4.length == 0)
        {
            continue;
        }
        NSString *fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        folderSize += [self fileSizeAtPath:fileAbsolutePath];
    }
    folderSize +=[[SDImageCache sharedImageCache] getSize];
    
    return folderSize/(1024.0*1024.0);
}
@end
