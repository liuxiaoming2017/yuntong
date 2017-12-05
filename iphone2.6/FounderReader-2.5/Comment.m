//
//  Comment.m
//  FounderReader
//
//  Created by he jinbo on 11-6-21.
//  Copyright 2011年 founder. All rights reserved.
//

#import "Comment.h"


@implementation Comment

@synthesize ID;
@synthesize content;
@synthesize userName;
@synthesize commentTime;
@synthesize greatCount;
@synthesize articleId;
@synthesize articleTitle;
@synthesize articleType;
@synthesize topDiscuss;
@synthesize imgUrl;
@synthesize userIcon;
-(void)dealloc 
{	
	self.content = nil;
    self.userName = nil;
    self.commentTime = nil;
	self.articleId = nil;
    self.articleTitle = nil;
    self.articleType = nil;
    self.topDiscuss = nil;
    self.imgUrl = nil;
}

+ (NSMutableArray *)commentsFromArray:(NSArray *)array
{
    NSMutableArray *comments = [[NSMutableArray alloc] initWithCapacity:[array count]];
    for (NSDictionary *dict in array) {
        
        Comment *comment = [[Comment alloc] init];
        comment.ID = [[dict objectForKey:@"commentID"] intValue];
        comment.greatCount = [[dict objectForKey:@"countPraise"] intValue];
        comment.content = [dict objectForKey:@"content"];
        
        if ([dict objectForKey:@"userName"] == nil || [[dict objectForKey:@"userName"] isEqual:[NSNull null]]) {
            comment.userName = NSLocalizedString(@"手机用户", nil);
        }else{
            comment.userName = [dict objectForKey:@"userName"];
        }
        
        comment.commentTime = [dict objectForKey:@"createTime"];
        comment.ueserID = [[dict objectForKey:@"userID"] integerValue];
        comment.parentID = [[dict objectForKey:@"parentID"] integerValue];

        if ([dict objectForKey:@"parentUserName"] == nil || [[dict objectForKey:@"parentUserName"] isEqual:[NSNull null]] ) {
            comment.parentUserName = NSLocalizedString(@"手机用户",nil);
        }
        else{
            comment.parentUserName = [dict objectForKey:@"parentUserName"];
        }
        if ([dict objectForKey:@"parentContent"] == nil || [[dict objectForKey:@"parentContent"] isEqual:[NSNull null]]) {
            comment.parentContent = @"";
        }
        else
        {
            comment.parentContent = [dict objectForKey:@"parentContent"];
        }
        if ([dict objectForKey:@"parentUserID"] == nil || [[dict objectForKey:@"parentUserID"] isEqual:[NSNull null]]) {
            comment.parentUserID = 0;
        }
        else
        {
            comment.parentUserID = [[dict objectForKey:@"parentUserID"] integerValue];
        }
        
        
        
        
        comment.articleType = [dict objectForKey:@"attr"];
        comment.articleTitle = [dict objectForKey:@"articleTitle"];
        comment.articleId = [dict objectForKey:@"articleId"];
        comment.topDiscuss = [dict objectForKey:@"topDiscuss"];
        comment.imgUrl =[dict objectForKey:@"imgUrl"];
        NSString *userIconStr = [dict objectForKey:@"faceUrl"];
        if ([userIconStr containsString:@"newaircloud"]) {
            comment.userIcon = [NSString stringWithFormat:@"%@@!sm", userIconStr];
        }else{
            comment.userIcon = userIconStr;
        }
        [comments addObject:comment];
    }
    return comments;
}

@end
