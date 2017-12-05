//
//  CacheManager.h
//  FounderReader-2.5
//
//  Created by chenfei on 5/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

// 先在命令行下执行
// sqlite3 xy_reader_new16.db < make-tables-script
// 将生成的数据库文件拖到工程中

#import <Foundation/Foundation.h>
#import "DataLib/DataLib.h"
#import "SeeViewmodel.h"

@class Column;
@class Article;

@interface CacheManager : NSObject {
    FMDatabase *_db;
}

@property(nonatomic, retain) FMDatabase *db;

+ (CacheManager *)sharedCacheManager;

// 更新版本号表
- (void)updateOrInsert:(int)columnId columnsVersion:(int)columnsVersion;
- (void)updateOrInsert:(int)columnId articlesVersion:(int)articlesVersion;

// 查询版本号
- (int)columnsVersion:(int)columnId;
- (int)articlesVersion:(int)columnId;

// 更新栏目表
- (void)updateColumns:(NSArray *)columns parentColumnId:(int)parentColumnId;

// 查询栏目
- (NSArray *)columns:(int)parentColumnId;

// 更新稿件表
- (void)insertArticles:(NSArray *)articles columnId:(int)columnId;
- (void)updateAritcles:(NSArray *)articles columnId:(int)columnId;

// 查询稿件
- (NSArray *)articles:(int)columnId rowNumber:(int)rowNumber count:(int)count;
- (NSArray *)article:(int)articleId rowNumber:(int)rowNumber count:(int)count;

// 更新 has_more 表
- (void)updateOrInsertHasMore:(int)columnId rowNumber:(int)rowNumber hasMore:(BOOL)flag;
- (BOOL)hasMore:(int)columnId rowNumber:(int)rowNumber;

// 收藏
- (BOOL)collect:(Article *)article;
- (void)unCollect:(int)articleId;
- (BOOL)isCollect:(int)articleId;
- (NSArray *)favoriteArticles;
//推荐新闻
- (void)insertRecommendList:(NSString *)list columnId:(int)columnId timestamp:(NSString *)timetamp;
//获取上一页
- (NSDictionary *)getRecommendListWithTime:(NSString *)timestamp;
// 清缓存
- (void)clearCache;
//遍历文件夹获得文件夹大小，返回多少M
+ (float ) folderSizeAtPath:(NSString*) folderPath;
@end
