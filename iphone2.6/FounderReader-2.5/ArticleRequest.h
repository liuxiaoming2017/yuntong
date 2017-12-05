//
//  ArticleRequest.h
//  FounderReader-2.5
//
//  Created by chenfei on 4/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VersioningRequest.h"

@interface ArticleRequest : VersioningRequest {
    int _columnId;
    int _rowNumber;
}

- (id)initWithColumnId:(int)columnId lastFileId:(int)lastFileId count:(int)count rowNumber:(int)rowNumber;
+ (id)articleRequestWithColumnId:(int)columnId lastFileId:(int)lastFileId count:(int)count rowNumber:(int)rowNumber;

- (id)initForInteractionPlusWithColumnId:(int)columnId LastFileId:(int)lastId rowNumber:(int)rowNumber;

+ (id)articleInteractionPlusRequestWithColumnId:(int)columnId LastId:(int)lastId rowNumber:(int)rowNumber;
+ (id)articleTopicListRequestWithColumnId:(int)columnId LastId:(int)lastId rowNumber:(int)rowNumber;

+ (id)articleRequestWithSearch:(NSString*)value lastFileId:(int)lastFileId count:(int)count rowNumber:(int)rowNumber columnId:(int)columnId;
+ (NSArray *)getCacheArticlesWithColumnId:(int)columnId rowNumber:(int)rowNumber;
+ (NSArray *)getCacheArticlesWithColumnId:(int)columnId rowNumber:(int)rowNumber count:(int)count;

+ (id)articleHotRequestWithColumnId:(int)siteID lastFileId:(int)lastFileId rowNumber:(int)rowNumber type:(int)type columnId:(int)columnId;
- (id)initHotWithColumnId:(int)siteID lastFileId:(int)lastFileId rowNumber:(int)rowNumber type:(int)type columnId:(int)columnId;

@end
