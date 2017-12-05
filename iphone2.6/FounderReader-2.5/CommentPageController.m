//
//  CommentPageController.m
//  FounderReader-2.5
//
//  Created by chenfei on 5/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CommentPageController.h"
#import "Article.h"
#import "Comment.h"
#import "CommentCell.h"
#import "CommentRequest.h"
#import "DataLib/DataLib.h"
#import "NewsListConfig.h"
#import "CommentViewControllerGuo.h"
#import "CommentConfig.h"
#import "UIDevice-Reachability.h"
#import "AppStartInfo.h"
#import "UIView+Extention.h"
#import "AppConfig.h"
#import "YXLoginViewController.h"
#import "CommentViewControllerGuo.h"

@interface CommentPageController ()<UIScrollViewDelegate,UIGestureRecognizerDelegate>
{
    UIButton *commentButton;
    CommentViewControllerGuo *commentController;
}

@property(nonatomic, retain) NSMutableArray *comments;
@property(nonatomic, retain) CommentViewControllerGuo *commentController;

//当前页码
@property (nonatomic, assign) NSInteger currentIndex;

@end

@implementation CommentPageController
{
    int _sourceType;
}

@synthesize fullColumn,showWrite;
@synthesize article;
@synthesize comments,listMoreCount,commentID;
@synthesize commentsHot;
@synthesize commentController;

-(void)updateCommentListAndCount
{
    [self loadComments:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    listMoreCount = 10;
    
    //评论类型sourceType :0是稿件，1是直播，2是评论的评论(暂时不用)，3是数字报]
    if (self.isPdfComment) {
        _sourceType = 3;
    }else{
        if (article.articleType == ArticleType_LIVESHOW) {
            _sourceType = 1;
        }
    }
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,20, kSWidth, self.view.bounds.size.height -64) style:UITableViewStylePlain];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorColor = [UIColor lightGrayColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    
    if (_refreshHeaderView == nil) {
        _refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - _tableView.bounds.size.height, self.view.frame.size.width, _tableView.bounds.size.height)];
        _refreshHeaderView.delegate = self;
        [_tableView addSubview:_refreshHeaderView];
    }
    [_refreshHeaderView refreshLastUpdatedDate];
    
    // 底部评论view
    [self addFootView];
    
    UISwipeGestureRecognizer *rightRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(goBackIOS6)];
    rightRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:rightRecognizer];
    
    [self reloadTableViewDataSource];
    
    if (_isFromDetailPage) {
        [self writeComment];
    }
    
    self.commentImages = [[NSMutableArray alloc] init];
    self.commentHotImages = [[NSMutableArray alloc] init];
}

- (void)addFootView{
    footView = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.bounds.size.height-45, kSWidth, 45)];
    footView.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1];
    
    UIView *topview = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kSWidth, 0.4)];
    if (IS_IPHONE_6P) {
        topview.frame = CGRectMake(0, 0, kSWidth, 0.6);
    }
    topview.alpha = 0.6;
    topview.backgroundColor = [UIColor grayColor];
    [footView addSubview:topview];
    
    UIButton *backBtn = [[UIButton alloc]initWithFrame:CGRectMake(5, 10, 23, 23)];
    [backBtn setImage:[UIImage imageNamed:@"btn-comment-back"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(goBackIOS6) forControlEvents:UIControlEventTouchUpInside];
    [footView addSubview:backBtn];
    UIButton *bg = [UIButton buttonWithType:UIButtonTypeCustom];
    [bg setImage:[UIImage imageNamed:@"commentBtn"] forState:UIControlStateNormal];
    if (IS_IPHONE_6)
    {
        backBtn.frame = CGRectMake(5, 12, 23, 23);
        bg.frame = CGRectMake(32, 8, 330, 30);
        [bg setImage:[UIImage imageNamed:@"ditect_write6"] forState:UIControlStateNormal];
    }else if (IS_IPHONE_6P)
    {
        backBtn.frame = CGRectMake(5, 12, 23, 23);
        bg.frame = CGRectMake(34, 9, 370, 30);
        [bg setImage:[UIImage imageNamed:@"ditect_write6p"] forState:UIControlStateNormal];
    }else
    {
        backBtn.frame = CGRectMake(5, 12, 23, 23);
        bg.frame = CGRectMake(30, 8, 280, 30);
    }
    backBtn.centerY = footView.height*0.5;
    bg.centerY = backBtn.centerY;
    [bg addTarget:self action:@selector(commentItemClicked:) forControlEvents:UIControlEventTouchUpInside];
    [footView addSubview:bg];
    [self.view addSubview:footView];
    
}

-(void)goBackIOS6
{
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 *  评论数点击
 */
-(void)commentCountButton
{
    return;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)showLoginPage
{
    YXLoginViewController *controller = [[YXLoginViewController alloc]init];
    [controller rightPageNavTopButtons];
    [self presentViewController:[Global controllerToNav:controller] animated:YES completion:^{
    }];
}

/**
 *  评论按钮点击
 */
- (void)commentItemClicked:(id)sender
{
    [self writeComment];
}
#pragma mark - 写评论
- (void)writeComment
{
    if (![UIDevice networkAvailable]) {
        [Global showTipNoNetWork];
        return;
    }
    
    __weak __typeof(self)weakSelf = self;
    if(![NSString isNilOrEmpty:[Global userId]])
        [self writtingComment];
    else
        [self toLoginWithBlock:^{
            [weakSelf writtingComment];
        }];
}

- (void)writtingComment
{
    commentController = [[CommentViewControllerGuo alloc] init];
    commentController.fullColumn = self.fullColumn;
    if(article.articleType == ArticleType_LIVESHOW)
        commentController.rootID = article.linkID;
    else
        commentController.rootID = article.fileId;
    commentController.article = article;
    commentController.urlStr = [NSString stringWithFormat:@"%@/api/submitComment",[AppConfig sharedAppConfig].serverIf];
    commentController.current = self.currentIndex;
    commentController.commentID = commentID;
    commentController.isPDF = self.isPdfComment;
    [appDelegate().window addSubview:commentController.view];
}

- (void)toLoginWithBlock:(void (^)(void))block
{
    YXLoginViewController *controller = [[YXLoginViewController alloc] init];
    [controller rightPageNavTopButtons];
    controller.loginSuccessBlock = ^(){
            if (block) block();
    };
    [self presentViewController:[Global controllerToNav:controller] animated:YES completion:nil];
}

#pragma mark - load comments

#pragma mark - 获取评论数据
- (void)loadComments:(BOOL)isGreat
{
    _reloading = YES;
    int rootID = article.fileId;
    if(article.articleType == ArticleType_LIVESHOW)
        rootID = article.linkID;
    
    CommentRequest *request = [CommentRequest commentNewRequestWithArticleId:rootID lastCommentId:0 count:[NewsListConfig sharedListConfig].count rowNumber:0 isGreate:isGreat moreCount:0 sourceType:_sourceType];
    [request setCompletionBlock:^(NSData *data) {
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers  error:nil];
        NSArray *array =  [dict valueForKey:@"list"];
        hasMore = YES;
        self.comments = [Comment commentsFromArray:array];
        if (self.comments.count) {
            self.isHaveNewComment = YES;
        }
        [_tableView reloadData];
        [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:0.01];
        _reloading = NO;
    }];
    [request setFailedBlock:^(NSError *error) {
        [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:0.01];
        _reloading = NO;
    }];
    [request startAsynchronous];
}

/**
 *  获取热门评论
 */
- (void)getCommentHot:(BOOL)isGreat{
    _reloading = YES;
    int rootID = article.fileId;
    if(article.articleType == ArticleType_LIVESHOW)
        rootID = article.linkID;
    CommentRequest *request = [CommentRequest commentRequestWithArticleId:rootID lastCommentId:0 count:[NewsListConfig sharedListConfig].count rowNumber:0 isGreate:isGreat moreCount:0 sourceType:_sourceType];
    [request setCompletionBlock:^(NSData *data) {
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers  error:nil];
        NSArray *array =  [dict valueForKey:@"list"];
        hasMore = YES;
        self.commentsHot = [Comment commentsFromArray:array];
        [_tableView reloadData];
        [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:0.01];
        _reloading = NO;
    }];
    [request setFailedBlock:^(NSError *error) {
        [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:0.01];
        _reloading = NO;
    }];
    [request startAsynchronous];
}

/**
 *  加载更多评论
 */
- (void)loadMoreComments
{
    _reloading = YES;
    
    Comment *lastComment = [comments lastObject];
    int rootID = article.fileId;
    if(article.articleType == ArticleType_LIVESHOW)
        rootID = article.linkID;
    CommentRequest *request = [CommentRequest commentNewRequestWithArticleId:rootID lastCommentId:lastComment.ID count:[NewsListConfig sharedListConfig].count rowNumber:(int)[comments count] isGreate:NO moreCount:listMoreCount sourceType:_sourceType];
    [request setCompletionBlock:^(NSData *data) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers  error:nil];
        NSArray *arr = [dict objectForKey:@"list"];
        if (!arr.count) {
            hasMore = NO;
        }else{
            listMoreCount += arr.count;
            hasMore = YES;
        }
        NSMutableArray *tmpArray = [Comment commentsFromArray:arr];
        for (Comment *com in tmpArray) {
            NSArray *arr = nil;
            if (com.topDiscuss.count > 0) {
                arr = [com.topDiscuss valueForKey:@"list"];
                com.topDiscuss = [Comment commentsFromArray:arr];
            }
        }
        if (tmpArray.count) {
            [self.comments addObjectsFromArray:tmpArray];
        }
        [_tableView reloadData];
        _reloading = NO;
    }];
    [request setFailedBlock:^(NSError *error) {
        _reloading = NO;
    }];
    [request startAsynchronous];
}

#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

#pragma mark - EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{
    listMoreCount = 10;
    [self reloadTableViewDataSource];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
{
    
    return _reloading; // should return if data source model is reloading
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view
{
    return [NSDate date]; // should return date data source was last changed
}


#pragma mark - Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource
{
    // 获取最热评论
    [self getCommentHot:YES];
    // 获取最新评论
    [self loadComments:YES];
    // 获取评论的回复评论
    //    [self loadReplyComments:YES];
}


- (void)doneLoadingTableViewData
{
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_tableView];
    
}


#pragma mark - table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 10;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!comments.count)
    {
        return;
    }
}

#pragma mark - table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (!comments.count) {
        
        UITableViewCell *promptCell = [tableView dequeueReusableCellWithIdentifier:@"promptCell"];
        if (!promptCell)
            promptCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"promptCell"] ;
        promptCell.textLabel.textAlignment = NSTextAlignmentCenter;
        promptCell.textLabel.text = NSLocalizedString(@"暂无评论",nil);
        
        promptCell.textLabel.textColor = [UIColor darkGrayColor];
        promptCell.textLabel.font = [UIFont boldSystemFontOfSize:12];
        return promptCell;
    }
    if (indexPath.row == [comments count]) {
        UITableViewCell *moreCell = [tableView dequeueReusableCellWithIdentifier:@"MoreCell"];
        if (moreCell == nil)
            moreCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MoreCell"];
        moreCell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@""]];
        moreCell.textLabel.textAlignment = NSTextAlignmentCenter;
        moreCell.textLabel.text = [CommentConfig sharedCommentConfig].moreCellTitle;
        moreCell.textLabel.textColor = [CommentConfig sharedCommentConfig].moreCellTitleColor;
        moreCell.textLabel.font = [UIFont boldSystemFontOfSize:[CommentConfig sharedCommentConfig].moreCellTitleFontSize];
        return moreCell;
    }
    
    CommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommentCell"];
    if (cell == nil)
        cell = [[CommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CommentCell"];
    
    // config cell
    Comment *comment = [comments objectAtIndex:indexPath.row];
    cell.userNameLabel.text = comment.userName.length == 0 ? [CommentConfig sharedCommentConfig].defaultNickName : comment.userName;
    NSString *timeStr = [comment.commentTime substringWithRange:NSMakeRange(5, 11)];
    cell.timeLabel.text = timeStr;
    cell.contentLabel.text = comment.content;
    NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:13], NSFontAttributeName,nil];
    CGSize size = [comment.content boundingRectWithSize:CGSizeMake(self.view.frame.size.width - 85,MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:tdic context:nil].size;
    
    cell.contentLabel.frame = (CGRect){{70, 61},size};
    cell.contentLabel.backgroundColor = [UIColor redColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.row) {
        UIImageView *sep = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"newsList_separator"]];
        sep.frame = CGRectMake(0, 0, kSWidth, 1);
        [cell.contentView addSubview:sep];
    }
    
    return cell;
    
}

- (void)gotoCommentList:(id)sender
{
    if (![UIDevice networkAvailable]) {
        
        [Global showTipNoNetWork];
        return;
    }
    CommentPageController *controller = [[CommentPageController alloc] init];
    controller.fullColumn = fullColumn;
    controller.article = article;
    [self.navigationController pushViewController:controller animated:YES];
    
}

@end
