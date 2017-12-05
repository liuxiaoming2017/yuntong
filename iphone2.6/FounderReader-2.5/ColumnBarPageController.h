//
//  ColumnBarPageController.h
//  FounderReader-2.5
//
//  Created by chenfei on 4/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DataChannelPageController.h"
#import "ColumnBar.h"
#import "EGORefreshTableHeaderView.h"
#import "HeaderNewsWidget.h"
#import "AdPageController.h"
#import "CreditMenuViewController.h"
#import "SearchToolBarView.h"
#import "PoliticalPageController.h"
#import "FDInteractionPlusViewController.h"
#import "FDTopicListViewController.h"
#import "FDServiceSortController.h"
#import "FDRecommendViewController.h"
#import "FDTopicPlusDetailViewController.h"
@class TinyMallViewController;
@interface ColumnBarPageController : DataChannelPageController <
ColumnBarDelegate,
ColumnBarDataSource,
EGORefreshTableHeaderDelegate,
BUPOViewDelegate,
HeaderNewsWidgetDelegate,
UIScrollViewDelegate,
UITableViewDelegate,
UITableViewDataSource,
UIWebViewDelegate> {
    NSArray *articles;
    BOOL    hasMore;
    
    ColumnBar *columnBar;
    BOOL _reloading;
    BOOL _success;
    NSArray *adArticles;
    
    EGORefreshTableHeaderView *_refreshHeaderView;
    SearchToolBarView *_searchView;
    
    BOOL isScrollDrag;//区分用手拖动和二级栏目跳转，手拖动为yes，二级栏目跳转为no
    ///////////////
    NSMutableSet *recycledPages;
    NSMutableSet *visiblePages;
    //BOOL isRefresh;
    UIScrollView *scrollViewbg;
    BOOL isFirstLoadArticle;
}
@property (nonatomic, retain) NSArray *arrayForHeadView;
@property (nonatomic, retain) NSArray *articles;
@property (nonatomic, assign) int lastSelectedIndex;
@property (nonatomic, strong) UITableView *listTableView;
@property (nonatomic, retain) UIScrollView *scrollViewbg;
@property (nonatomic, retain) UIWebView *webView;
@property (nonatomic, strong) NSMutableArray *c;

@property (nonatomic, retain) ChannelPageController *pdfViewControlle;     //数字报栏目
@property (nonatomic, retain) ChannelPageController *dishViewController;   //报料栏目
@property (nonatomic, retain) ChannelPageController *localController;      //本地栏目
@property (nonatomic, retain) NSMutableSet *serverControllers;             //服务栏目集合
@property (nonatomic, retain) NSMutableSet *adViewControllers;             //外链栏目集合
@property (nonatomic, retain) NSMutableSet *lifeControllers;               //生活栏目集合
@property (nonatomic, retain) NSMutableSet *politicalControllers;  //政情栏目集合
@property (nonatomic, retain) CreditMenuViewController *creditWebController; //积分商城栏目
@property (nonatomic, retain) FDInteractionPlusViewController *interactionPlusViewController;  //互动栏目集合
@property (nonatomic, retain) FDTopicListViewController *topicListViewController;  //话题+栏目集合
@property (nonatomic, retain) FDTopicPlusDetailViewController *topicDetailViewController;  //话题详情栏目集合
@property (nonatomic, retain) TinyMallViewController *mallVC;
@property (nonatomic, assign) int firstIndex;
@property (nonatomic, assign) int lastIndex;
@property (nonatomic, retain) UIImageView *localView;
@property (nonatomic, assign) BOOL isFirstNewsVC;// 是否是第一个一级栏目(tab)新闻
@property (nonatomic, assign) BOOL isNotOneLevelNewsVC;// 是否是第一个一级栏目(tab)新闻
@property (nonatomic, assign) BOOL isNotTabNewsVC;// 是否是没有tabbar的新闻频道
@property (nonatomic, assign) CGFloat listTableViewY;
@property (nonatomic, assign) CGFloat columnHeaderHeight;
@property (nonatomic, assign) NSUInteger adCount;//列表广告个数
@property (nonatomic,strong) FDServiceSortController * serviceSort;
@property (nonatomic,assign) BOOL isFromLife;
@property (nonatomic,strong) FDRecommendViewController * recommendVC;
- (int)currentColumnIndex;

- (void)loadArticlesWithColumnId:(int)columnId lastFileId:(int)lastFileId rowNumber:(int)rowNumber;
- (void)loadMoreArticlesWithColumnId:(int)columnId lastFileId:(int)lastFileId rowNumber:(int)rowNumber;

- (void)loadMoreHotArticlesWithColumnId:(int)siteID lastFileId:(int)lastFileId rowNumber:(int)rowNumber type:(int)type columnId:(int)columnId;

// virtual
- (void)loadArticlesFinished;

// virtual
- (void)loadArticlesFailed;

// virtual
- (void)loadMoreArticlesFinished;

// virtual
- (void)loadMoreArticlesFailed;

- (void)loadHeaderWidget;


- (void)stopRefresh;

- (void)initTableViewFrame;
- (void)addColumnBar;
- (void)listTVPages;
- (void)refreshList;

@end
