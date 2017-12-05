//
//  CommentPageController.h
//  FounderReader-2.5
//
//  Created by chenfei on 5/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"

@class Article;

@interface CommentPageController : UIViewController <
    UITableViewDelegate,
    UITableViewDataSource,
    EGORefreshTableHeaderDelegate,
    UIScrollViewDelegate
> {

    Article *article;
    NSMutableArray *comments;
    BOOL hasMore;
    UIView *footView;
    int listMoreCount;
}
@property (nonatomic, assign) BOOL reloading;
@property (nonatomic, assign) BOOL isHaveNewComment;
@property(nonatomic, retain) EGORefreshTableHeaderView *refreshHeaderView;
@property(nonatomic, retain) UITableView *tableView;
@property(nonatomic, retain) NSString *fullColumn;
@property(nonatomic, retain) Article *article;
@property(nonatomic,assign)int listMoreCount;
@property(nonatomic,assign)NSInteger commentID;
@property (nonatomic,assign)BOOL showWrite;
@property(nonatomic, retain) NSMutableArray *commentsHot;

@property(nonatomic, retain)NSMutableArray *commentImages;
@property(nonatomic, retain)NSMutableArray *commentHotImages;
//是否是报纸文章的评论
@property(nonatomic,assign) BOOL isPdfComment;
//是否在详情内容页评论
@property(nonatomic, assign)BOOL isFromDetailPage;
- (void)loadMoreComments;
// 最新评论
- (void)loadComments:(BOOL)isGreat;
-(void)commentCountButton;

// 热门评论
- (void)getCommentHot:(BOOL)isGreat;

// 开始评论
- (void)writeComment;
@end
