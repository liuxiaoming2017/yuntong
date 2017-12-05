//
//  CommentRequest.h
//  FounderReader-2.5
//
//  Created by chenfei on 5/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FileRequest.h"

@interface CommentRequest : FileRequest
{
    int _rowNumber;
}

//最热评论
- (id)initWithArticleId:(int)articleId lastCommentId:(NSInteger)lastCommentId count:(int)count rowNumber:(int)rowNumber isGreate:(BOOL)isGreate moreCount:(int)moreCount sourceType:(int)sourceType;
+ (id)commentRequestWithArticleId:(int)articleId lastCommentId:(NSInteger)lastCommentId count:(int)count rowNumber:(int)rowNumber isGreate:(BOOL)isGreate moreCount:(int)moreCount sourceType:(int)sourceType;

//最新评论
- (id)initNewWithArticleId:(int)articleId lastCommentId:(NSInteger)lastCommentId count:(int)count rowNumber:(int)rowNumber isGreate:(BOOL)isGreate moreCount:(int)moreCount sourceType:(int)sourceType;
+ (id)commentNewRequestWithArticleId:(int)articleId lastCommentId:(NSInteger)lastCommentId count:(int)count rowNumber:(int)rowNumber isGreate:(BOOL)isGreate moreCount:(int)moreCount sourceType:(int)sourceType;

@end
