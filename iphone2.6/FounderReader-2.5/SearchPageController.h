//
//  SearchPageController.h
//  FounderReader-2.5
//
//  Created by sa on 15-1-21.
//
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"
#import "ChannelPageController.h"

@interface SearchPageController : ChannelPageController
<
UITableViewDelegate,
UITableViewDataSource,
UITextFieldDelegate,
UISearchBarDelegate
>
{
    NSArray *articles;
    BOOL    hasMore;
    BOOL _reloading;
    BOOL _success;
    
    EGORefreshTableHeaderView *_refreshHeaderView;
    int column_id;
    BOOL isSearchChild;
    //UILabel *navTitleLabel;
}

@property (nonatomic, retain) NSArray *articles;
@property (nonatomic, assign) int lastSelectedIndex;
@property (nonatomic, assign) BOOL isSearchChild;
@property (nonatomic, assign) BOOL isSearch;
@property (nonatomic, assign) int column_id;
////////
@property (nonatomic, retain) UITableView *listTableView;
@property (nonatomic, retain) NSString *searchText;

@property (nonatomic, retain) UIImageView *img;
@property (nonatomic, retain) UILabel *label;
@property (nonatomic, retain) UIButton *btn;
@property (nonatomic, retain) UIView *hudView;
- (void)loadArticlesWithSearch:(NSString*)value lastFileId:(int)lastFileId rowNumber:(int)rowNumber columnId:(int)columnId;
- (void)loadMoreArticlesWithSearch:(NSString*)value lastFileId:(int)lastFileId rowNumber:(int)rowNumber columnId:columnId;
// virtual
- (void)loadArticlesFinished;

// virtual
- (void)loadArticlesFailed;

// virtual
- (void)loadMoreArticlesFinished;

// virtual
- (void)loadMoreArticlesFailed;

- (void)playVideo:(NSString *)urlString;

@end
