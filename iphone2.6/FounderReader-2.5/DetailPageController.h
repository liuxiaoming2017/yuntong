//
//  DetailPageController.h
//  FounderReader-2.5
//
//  Created by chenfei on 4/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "ForumDetailFootView.h"
#import "ChannelPageController.h"

@class Article;
@class Column;

@interface DetailPageController : ChannelPageController <UIActionSheetDelegate, UINavigationControllerDelegate, MFMailComposeViewControllerDelegate,FootViewDelegate> {
    UIImageView *bgImageView;
    UIToolbar *toolbar;
    
    NSString *columnName;
    NSArray *articles;
    int currentIndex;
    
    UIButton *commentButton;
    UIButton *writeCommentButton;
    UIButton *subCommentButton;
    
    UILabel *greatLabel;
    UILabel *commentLabel;
    
    BOOL isDiscussClose;
    BOOL isGreatClose;
}
@property(nonatomic, retain) UISwipeGestureRecognizer *rightRecognizer;
@property(nonatomic, retain) UISwipeGestureRecognizer *showCommentRecognizer;
@property(nonatomic, retain) ForumDetailFootView *footview;
@property(nonatomic, assign) int subComment;
@property(nonatomic, retain) NSString *columnName;
@property(nonatomic, retain) NSArray *articles;
@property(nonatomic,retain) Article *article;
@property(nonatomic, retain) Article *adArticle;
@property(nonatomic, assign) int currentIndex;
@property(nonatomic, assign) BOOL isPDF;
@property(nonatomic, assign) BOOL isNavGoback;
@property(nonatomic,retain) Column *column;
@property(nonatomic, assign) NSInteger voteColumnId;
@property(nonatomic,retain) NSString *contentShareUrl;//推送分享
@property(nonatomic,retain) NSString *contentShareImageUrl;//推送分享

// virtual
- (void)setBgImage;
- (void)setupToolbar;
- (void)updateToolbar;
// public:
- (void)writeComment;

- (void)updateIndex;

// virtual
- (NSString *)newsTitle;
- (NSString *)newsLink;
- (UIImage *)newsImage;
- (NSString *)newsAbstract;

- (void)gotoCommentList;

- (void)zoomInOut:(int)size;

- (void)updateFavoriteIcon;

- (void)collect:(Article *)article;

- (void)unCollect:(int)articleId;

- (void)greatItemClicked:(id)sender;

- (void)goBothBack;

-(void)showGreatComment;

//点赞
-(void)saveGread:(Article *)article;
-(BOOL)isGreaded:(Article *)article;

@end
