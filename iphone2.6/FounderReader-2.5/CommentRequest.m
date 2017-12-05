//
//  CommentRequest.m
//  FounderReader-2.5
//
//  Created by chenfei on 5/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CommentRequest.h"
#import "DataLib/DataLib.h"
#import "AppStartInfo.h"
#import "Comment.h"
#import "CacheManager.h"
#import "CacheManager.h"
#import "Article.h"
#import "Comment.h"
#import "AppConfig.h"
@implementation CommentRequest
//最热评论
- (id)initWithArticleId:(int)articleId lastCommentId:(NSInteger)lastCommentId count:(int)count rowNumber:(int)rowNumber isGreate:(BOOL)isGreate moreCount:(int)moreCount sourceType:(int)sourceType
{
    _rowNumber = rowNumber;
    NSString *url = [NSString stringWithFormat:@"%@/api/getHotComments?sid=%@&rootID=%d&sourceType=%d",[AppConfig sharedAppConfig].serverIf,[AppConfig sharedAppConfig].sid,articleId,sourceType];
    self = [super initWithURL:url];
    if (self) {
        ifCache = NO;
    }
    return self;
}

+ (id)commentRequestWithArticleId:(int)articleId lastCommentId:(NSInteger)lastCommentId count:(int)count rowNumber:(int)rowNumber isGreate:(BOOL)isGreate moreCount:(int)moreCount sourceType:(int)sourceType
{
     return [[self alloc] initWithArticleId:articleId lastCommentId:lastCommentId count:count rowNumber:rowNumber isGreate:isGreate moreCount:(int)moreCount sourceType:sourceType];
}


//最新评论
- (id)initNewWithArticleId:(int)articleId lastCommentId:(NSInteger)lastCommentId count:(int)count rowNumber:(int)rowNumber isGreate:(BOOL)isGreate moreCount:(int)moreCount sourceType:(int)sourceType
{
    _rowNumber = rowNumber;
    
    NSString *url = [NSString stringWithFormat:@"%@/api/getComments?sid=%@&rootID=%d&sourceType=%d&lastFileID=%ld&rowNumber=%d",[AppConfig sharedAppConfig].serverIf,[AppConfig sharedAppConfig].sid,articleId,sourceType,(long)lastCommentId,rowNumber];
    self = [super initWithURL:url];
    if (self) {
        ifCache = NO;
    }
    return self;
}
+ (id)commentNewRequestWithArticleId:(int)articleId lastCommentId:(NSInteger)lastCommentId count:(int)count rowNumber:(int)rowNumber isGreate:(BOOL)isGreate moreCount:(int)moreCount sourceType:(int)sourceType
{
    return [[self alloc] initNewWithArticleId:articleId lastCommentId:lastCommentId count:count rowNumber:rowNumber isGreate:isGreate moreCount:(int)moreCount sourceType:sourceType];
}
- (id)cacheData
{
    return nil;
}

- (BOOL)hasCache
{
    NSArray *array = [self cacheData];
    if (array && [array count])
        return YES;
    return NO;
}


@end
