//
//  ArticleRequest.m
//  FounderReader-2.5
//
//  Created by chenfei on 4/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ArticleRequest.h"
#import "DataLib/DataLib.h"
#import "CacheManager.h"
#import "Article.h"
#import "NewsListConfig.h"
#import "AppConfig.h"
#import "NSString+Helper.h"
#import "NSString+MD5Addition.h"
#import "UserAccountDefine.h"


#import "AppStartInfo.h"
#import "Defines.h"

@implementation ArticleRequest

- (id)initWithGovAffairWithSid:(NSString *)str
{
    NSString * url = [NSString stringWithFormat:@"%@/api/%@?&sid=%@", [AppConfig sharedAppConfig].serverIf,str, [AppConfig sharedAppConfig].sid];
    self = [super initWithURL:url];
    return self;
}

- (id)initWithColumnId:(int)columnId lastFileId:(int)lastFileId count:(int)count rowNumber:(int)rowNumber
{
    NSString * url = [NSString stringWithFormat:@"%@/api/getArticles?&sid=%@&cid=%d&lastFileID=%d&count=%d&rowNumber=%d", [AppConfig sharedAppConfig].serverIf, [AppConfig sharedAppConfig].sid, columnId, lastFileId, count, rowNumber];

    self = [super initWithURL:url];
    if (self) {
        _columnId = columnId;
        _rowNumber = rowNumber;
    }
    return self;
}

- (id)initForInteractionPlusWithColumnId:(int)columnId LastFileId:(int)lastId rowNumber:(int)rowNumber {
    NSMutableString * url = [NSMutableString stringWithFormat:@"%@/api/getAskBarPlusList?&sid=%@&lastID=%d&rowNumber=%d", [AppConfig sharedAppConfig].serverIf, [AppConfig sharedAppConfig].sid, lastId, rowNumber];
    if ([Global userId].length) {
        [url appendString:[NSString stringWithFormat:@"&uid=%@", [Global userId]]];
    }
    
    self = [super initWithURL:url];
    if (self) {
        _columnId = columnId;
        _rowNumber = rowNumber;
    }
    return self;
}

- (id)initForTopicListWithColumnId:(int)columnId LastFileId:(int)lastId rowNumber:(int)rowNumber {
    NSMutableString * url = [NSMutableString stringWithFormat:@"%@/topicApi/getTopicList?&sid=%@&lastID=%d&rowNumber=%d", [AppConfig sharedAppConfig].serverIf, [AppConfig sharedAppConfig].sid, lastId, rowNumber];
    if ([Global userId].length) {
        [url appendString:[NSString stringWithFormat:@"&uid=%@", [Global userId]]];
    }
    
    self = [super initWithURL:url];
    if (self) {
        _columnId = columnId;
        _rowNumber = rowNumber;
    }
    return self;
}

- (id)initWithColumnSearch:(NSString*)value lastFileId:(int)lastFileId count:(int)count rowNumber:(int)rowNumber columnId:(int)columnId
{
    NSString *url = [NSString stringWithFormat:@"%@/api/searchAll?sid=%@&keyword=%@&rowNumber=%d", [AppConfig sharedAppConfig].serverIf, [AppConfig sharedAppConfig].sid, value, rowNumber];
    NSString * newUrl = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    self = [super initWithURL:newUrl];
    if (self) {
        _columnId = 0;
        _rowNumber = rowNumber;
    }
    return self;
}

- (id)initHotWithColumnId:(int)siteID lastFileId:(int)lastFileId rowNumber:(int)rowNumber type:(int)type columnId:(int)columnId
{
    NSString * url = [NSString stringWithFormat:@"%@/articleHot?siteID=%d&lastFileId=%d&rowNumber=%d&type=%d", [AppConfig sharedAppConfig].serverIf, siteID, lastFileId, rowNumber, type];
    
    self = [super initWithURL:url];
    
    if (self) {
        _columnId = columnId;
    }

    return self;
}

+ (id)articleInteractionPlusRequestWithColumnId:(int)columnId LastId:(int)lastId rowNumber:(int)rowNumber {
    return [[self alloc] initForInteractionPlusWithColumnId:(int)columnId LastFileId:lastId rowNumber:rowNumber];
}

+ (id)articleTopicListRequestWithColumnId:(int)columnId LastId:(int)lastId rowNumber:(int)rowNumber {
    return [[self alloc] initForTopicListWithColumnId:(int)columnId LastFileId:lastId rowNumber:rowNumber];
}

+ (id)articleHotRequestWithColumnId:(int)siteID lastFileId:(int)lastFileId rowNumber:(int)rowNumber type:(int)type columnId:(int)columnId
{
    return [[self alloc] initHotWithColumnId:siteID lastFileId:lastFileId rowNumber:rowNumber type:type columnId:columnId];
}

+ (id)articleRequestWithColumnId:(int)columnId lastFileId:(int)lastFileId count:(int)count rowNumber:(int)rowNumber
{
    return [[self alloc] initWithColumnId:columnId lastFileId:lastFileId count:count rowNumber:rowNumber];
}

+ (id)articleRequestWithSearch:(NSString*)value lastFileId:(int)lastFileId count:(int)count rowNumber:(int)rowNumber columnId:(int)columnId
{
    return [[self alloc] initWithColumnSearch:value lastFileId:lastFileId count:count rowNumber:rowNumber columnId:columnId];
}

- (id)businessData:(NSData *)data
{
    NSMutableArray *mutableArray = nil;
    NSArray *array = nil;
    NSArray *adArray = nil;
    
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers  error:nil];
    
    if ([dict isKindOfClass:[NSDictionary class]])
    {
        array = [dict objectForKey:@"list"];
        adArray = [dict objectForKey:@"adv"];
    }
    
    if (adArray.count) {
        mutableArray = [NSMutableArray arrayWithArray:adArray];
        
    }
    else{
        mutableArray = [[NSMutableArray alloc] init];
    }
    
    [mutableArray addObjectsFromArray:array];
    
    NSArray *articles = nil;
    if (mutableArray.count) {
        articles = [Article articlesFromArray:mutableArray];
        for (int i = 0; i < articles.count; i++) {
            Article *article = articles[i];
            if (article.fileId == 0 && article.advID != 0) {
                article.fileId = article.advID;
            }
        }
        
        for (Article *article in articles) {
            article.columnId = _columnId;
        }
    }
    
    //话题+
    if ([[dict allKeys] containsObject:@"config"]) {
        [self loadTopicConfig:dict];
    }
    
    return articles;
}

- (void)loadTopicConfig:(NSDictionary *)dict
{
    NSDictionary *configDict = [dict objectForKey:@"config"];
    if ([configDict isKindOfClass:[NSDictionary class]]) {
        
        NSString *followWord =  [NSString isNilOrEmpty:[configDict objectForKey:@"attention"]] ? @"关注" : [configDict objectForKey:@"attention"];
        NSString *followedWord =  [NSString isNilOrEmpty:[configDict objectForKey:@"hasAttention"]] ? @"已关注" : [configDict objectForKey:@"hasAttention"];
        NSString *joinWord =  [NSString isNilOrEmpty:[configDict objectForKey:@"participate"]] ? @"参与" : [configDict objectForKey:@"participate"];
        NSString *discussWord =  [NSString isNilOrEmpty:[configDict objectForKey:@"talkAbout"]] ? @"我也说一说" : [configDict objectForKey:@"talkAbout"];
        NSString *myTopicTitileWord =  [NSString isNilOrEmpty:[configDict objectForKey:@"myTopic"]] ? @"我的话题" : [configDict objectForKey:@"myTopic"];
        NSString *myFollowWord = [NSString isNilOrEmpty:[configDict objectForKey:@"myAttention"]] ? @"参与的话题" : [configDict objectForKey:@"myAttention"];
        NSString *myJoinWord = [NSString isNilOrEmpty:[configDict objectForKey:@"myParticipate"]] ? @"关注的话题" : [configDict objectForKey:@"myParticipate"];
        NSString *govName = [NSString isNilOrEmpty:[configDict objectForKey:@"govName"]] ? @"官方回复" : [configDict objectForKey:@"govName"];
        NSString *govImage = [NSString isNilOrEmpty:[configDict objectForKey:@"govImage"]] ? @"" : [configDict objectForKey:@"govImage"];
        
        NSArray *topicConfigValues = [NSArray arrayWithObjects:followWord, followedWord, joinWord, discussWord, myTopicTitileWord, myFollowWord, myJoinWord, govName, govImage, nil];
        NSArray *topicConfigKeys = [NSArray arrayWithObjects:FDTopicFollowWordKey, FDTopicFollowedWordKey, FDTopicJoinWordKey, FDTopicDiscussWordKey, FDTopicMyTopicTitileWordKey, FDTopicMyFollowWordKey, FDTopicMyJoinWordKey, FDTopicGovNameWordKey, FDTopicGovImageWordKey,nil];
        NSDictionary *topicConfigDict = [NSDictionary dictionaryWithObjects:topicConfigValues forKeys:topicConfigKeys];
        [[NSUserDefaults standardUserDefaults] setObject:topicConfigDict forKey:FDTopicConfigsNameKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (id)cacheData
{
    CacheManager *manager = [CacheManager sharedCacheManager];
    NSArray *articles = [manager articles:_columnId rowNumber:_rowNumber count:[NewsListConfig sharedListConfig].count];
    return articles;
}

- (BOOL)hasCache
{
    NSArray *array = [self cacheData];
    if (array && [array count])
        return YES;
    return NO;
}

- (void)store:(NSData *)data
{
    BOOL hasMore = NO;
    NSMutableArray *mutableArray = nil;
    NSArray *array = nil;
    NSArray *adArray = nil;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers  error:nil];
    if ([dict isKindOfClass:[NSDictionary class]]){
        array = [dict objectForKey:@"list"];
        adArray = [dict objectForKey:@"adv"];
    }
    
    if (adArray.count) {
        mutableArray = [NSMutableArray arrayWithArray:adArray];
    }else{
        mutableArray = [[NSMutableArray alloc] init];
    }
    
    [mutableArray addObjectsFromArray:array];
    
    if (mutableArray.count)
    {
        int version = [[(NSDictionary *)mutableArray[0] objectForKey:@"version"] intValue];
        
        XYLog(@"--------version:%d-----columnId:%d",version,_columnId);
        // 更新版本
        CacheManager *manager = [CacheManager sharedCacheManager];
        [manager updateOrInsert:_columnId articlesVersion:version];
        
        // 更新稿件
        NSArray *articles = [Article articlesFromArray:mutableArray];
        
        for (int i = 0; i < articles.count; i++) {
            Article *article = articles[i];
            if (article.fileId == 0 && article.advID != 0) {
                article.fileId = article.advID;
            }
        }
        
        if (_rowNumber)
        {
            [manager insertArticles:articles columnId:_columnId];
        }
        else
            [manager updateAritcles:articles columnId:_columnId];
        
        // 更新栏目表中has_more字段
        hasMore = mutableArray.count > 0 ? YES : NO;
        [manager updateOrInsertHasMore:_columnId rowNumber:_rowNumber hasMore:hasMore];
    }
}

+ (NSArray *)getCacheArticlesWithColumnId:(int)columnId rowNumber:(int)rowNumber
{
    if(columnId <= 0)
        return [NSArray array];
    
    CacheManager *manager = [CacheManager sharedCacheManager];
    NSArray *articles = [manager articles:columnId rowNumber:rowNumber count:[NewsListConfig sharedListConfig].cache_count];
    return articles;
}

+ (NSArray *)getCacheArticlesWithColumnId:(int)columnId rowNumber:(int)rowNumber count:(int)count
{
    if(columnId <= 0)
        return [NSArray array];
    
    CacheManager *manager = [CacheManager sharedCacheManager];
    NSArray *articles = [manager articles:columnId rowNumber:rowNumber count:count];
    return articles;
}

+ (id)govAffairRequestWithSid:(NSString *)str
{
    return [[self alloc] initWithGovAffairWithSid:str];
}
@end
