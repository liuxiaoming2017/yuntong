//
//  NewsPageController.m
//  FounderReader-2.5
//
//  Created by chenfei on 4/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NormalPageController.h"
#import "Column.h"
#import "Article.h"
#import "MiddleCell.h"
#import "MoreCell.h"
#import "NewsListConfig.h"
#import "NSString+Helper.h"
#import "TemplateDetailPageController.h"
#import "AppStartInfo.h"
#import "HeaderNewsWidget.h"
#import "ImageDetailPageController.h"
#import "UIDevice-Reachability.h"
#import <MediaPlayer/MediaPlayer.h>
#import "DataLib/DataLib.h"
#import "GroupImage_MiddleCell.h"
#import "SpecialNewsPageController.h"
#import "GroupImageConfig.h"
#import "CDRTranslucentSideBar.h"
#import "UIImage+Helper.h"
#import "PersonalCenterViewController.h"
#import "UIView+Extention.h"
#import "NJEventRequest.h"
#import "SeeRootViewController.h"
#import "AppStartInfo.h"
#import "TemplateNewDetailViewController.h"
#import "NewsListConfig.h"
#import "ArticleRequest.h"
#import "NewsCellUtil.h"
#import "ColumnBarConfig.h"
#import "ColorStyleConfig.h"

@interface NormalPageController () <HeaderNewsWidgetDelegate, CDRTranslucentSideBarDelegate>
{
    UIView *_columnLabel;
    UIView *_headWhiteLable;
}

@property (nonatomic, retain) NSMutableDictionary *saveIsRedDic;
@property (nonatomic, retain) NSArray *groupImageConfigs;
@property (nonatomic, retain) NSArray *subColumns;
@property (nonatomic, retain) UIView *toolBarView;
@end

@implementation NormalPageController
@synthesize groupImageConfigs,subColumns,saveIsRedDic;
- (void)dealloc{

    self.groupImageConfigs = nil;
    self.subColumns = nil;
    self.saveIsRedDic = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _headWhiteLable = [[UIView alloc] initWithFrame:CGRectMake(0,0 ,[UIScreen mainScreen].bounds.size.width, kNavBarHeight)];
    _headWhiteLable.backgroundColor = [UIColor clearColor];
    _headWhiteLable.alpha = 1;
    [self.view addSubview:_headWhiteLable];
    
    self.groupImageConfigs = [GroupImageConfig groupImageConfigs];
    self.view.backgroundColor = [UIColor whiteColor];
     //已经读过的稿件
    
    saveIsRedDic = [[NSMutableDictionary alloc] initWithContentsOfFile:[cacheDirPath() stringByAppendingString:kSaveIsReadFileName]];
    if (!self.saveIsRedDic) {
        saveIsRedDic = [[NSMutableDictionary alloc] init];
    }
    self.listTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    leftController = [[PersonalCenterViewController alloc] init];
    self.leftController.view.frame = CGRectMake(0, 0, 240, self.view.bounds.size.height+kNavBarHeight);
    
    sideBar = [[CDRTranslucentSideBar alloc] init];
    self.sideBar.delegate = self;
    self.sideBar.sideBarWidth = self.view.bounds.size.width * 0.5;
    self.sideBar.view.frame = CGRectMake(0, 0,self.view.bounds.size.width * 0.5, self.view.bounds.size.height);
    [self.sideBar setContentViewInSideBar:self.leftController.view];
    self.leftController.sideBar = self.sideBar;
    
    UISwipeGestureRecognizer *rightRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(goBackIOS6)];
    rightRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    
    if (self.viewControllerType == FDViewControllerForDetailVC) {
        self.listTableView.frame = CGRectMake(0, 0, kSWidth, kSHeight-kNavBarHeight);
    }else{
        [self.view addGestureRecognizer:rightRecognizer];
        [self configWebViewToolBar];
    }
}
-(void)goRightPageBack{
    if (self.viewControllerType == FDViewControllerForDetailVC) {
        if (self.isFromLife) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }else{
            [self.navigationController popViewControllerAnimated:YES];
        }
    }else{
        [super goRightPageBack];
    }
}

-(void)configWebViewToolBar
{
    _toolBarView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kSWidth, 64)];
    self.toolBarView.backgroundColor=[UIColor colorWithPatternImage:[Global navigationImage]];
    self.toolBarView.userInteractionEnabled = YES;
    [self.view addSubview:self.toolBarView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 20, kSWidth-80, 44)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    titleLabel.textAlignment = 1;
    titleLabel.textColor = [ColorStyleConfig sharedColorStyleConfig].navbar_titlecolor_selected;
    titleLabel.text = self.parentColumn.columnName;
    titleLabel.tag = 222;
    [self.toolBarView addSubview:titleLabel];
    
    
    UIButton *preBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 27, 30, 30)];
    preBtn.tag = 111;
    [preBtn addTarget:self action:@selector(goBackIOS6) forControlEvents:UIControlEventTouchUpInside];
    [preBtn setBackgroundImage:[UIImage imageNamed:@"btn_return"] forState:UIControlStateNormal];
    [self.toolBarView addSubview:preBtn];
    
    UILabel *lineLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 63, kSWidth, 1)];
    lineLabel.backgroundColor = [Global navigationLineColor];
    [self.toolBarView addSubview:lineLabel];

}

-(void)goBackIOS6
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - load columns
- (void)loadColumnsArray
{
    self.allcolumns = [[NSMutableArray alloc] initWithObjects:parentColumn, nil];
    self.columns = [[NSMutableArray alloc] initWithObjects:parentColumn, nil];
    [self loadColumnsFinished];
}


- (void)loadColumnsFinished
{
    [super loadColumnsFinished];
//    self.listTableView.frame = CGRectMake(0, kNavBarHeight, kSWidth, kSHeight-kNavBarHeight);
    //[self loadArticlesWithColumnId:parentColumn.columnId lastFileId:0 rowNumber:0];
}

#pragma mark - Gesture Handler
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if (self.scrollViewbg.contentOffset.x < 100) {
        return YES;
    }
    return NO;
}
- (void)handlePanGesture:(UIPanGestureRecognizer *)recognizer {
    
    //侧滑手势
    if (self.scrollViewbg.contentOffset.x>0)
        return;
    
    // if you have left and right sidebar, you can control the pan gesture by start point.
    CGPoint translatedPoint = [recognizer translationInView:self.view];
    if (translatedPoint.x > 0){
        if (recognizer.state == UIGestureRecognizerStateBegan) {
            
            CGPoint startPoint = [recognizer locationInView:self.view];
            if (startPoint.y<-self.listTableView.contentOffset.y + self.listTableView.tableHeaderView.frame.size.height+kSWidth*0.19375)
                return;
            
            if (startPoint.x < kSWidth/5.0)
                self.sideBar.isCurrentPanGestureTarget = YES;
        }
        self.sideBar.isCurrentPanGestureTarget = YES;
        [self.sideBar handlePanGestureToShow:recognizer inView:self.view];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.viewControllerType != FDViewControllerForDetailVC) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        [self.navigationController.navigationBar setTranslucent:YES];
        self.edgesForExtendedLayout = UIRectEdgeTop;
    }else{
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        [self rightPageNavTopButtons];
    }
    [self.tabBarController.tabBar setHidden:YES];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
- (void)loadArticlesWithColumnId:(int)columnId lastFileId:(int)lastFileId rowNumber:(int)rowNumber
{
    columnBar.enabled = NO;
    _reloading = YES;
    ArticleRequest *request = [ArticleRequest articleRequestWithColumnId:parentColumn.columnId lastFileId:lastFileId count:[NewsListConfig sharedListConfig].count rowNumber:rowNumber];
    [request setCompletionBlock:^(NSArray *array) {
        CacheManager *manager = [CacheManager sharedCacheManager];
        hasMore = [manager hasMore:columnId rowNumber:rowNumber];
        {
            self.articles = array;
        }
        [self loadHeaderWidget];
        [self loadArticlesFinished];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:[NSDate date] forKey:[NSString stringWithFormat:@"%@%d", kLastColumn_RefreshTime, columnId]];
    }];
    [request setFailedBlock:^(NSError *error) {
        XYLog(@"load articles failed: %@", error);
        self.articles = [NSArray array];
        hasMore = NO;
        [self loadArticlesFailed];
        [Global showTipNoNetWork];
    }];
    [request startAsynchronous];
}

/**
 *  加载数据结束
 */
- (void)loadArticlesFinished
{
    [super loadArticlesFinished];
    [self.listTableView reloadData];
}

/**
 *  加载更多数据失败
 */
- (void)loadMoreArticlesFailed
{
    [super loadMoreArticlesFailed];
    
    MoreCell *cell = (MoreCell *)[self.listTableView viewWithTag:200];
    if (cell)
        [cell hideIndicator];
}


#pragma mark - table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == [self.articles count]){
        
        return  [NewsListConfig sharedListConfig].moreCellHeight;
    }
    
    Article *article = nil;
    if (self.articles.count > indexPath.row) {
        article = [self.articles objectAtIndex:indexPath.row];
    }
    
    return [NewsCellUtil getNewsCellHeight:article];
}

#pragma mark - table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.articles.count>0) {
        if (hasMore) {
            return self.articles.count+1;
        }
        return self.articles.count;
    }
    else{
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TableViewCell *cell = nil;
    if (0 == articles.count) {
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"zeroCell"];
        if (!cell){
            cell = [[TableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"zeroCell"];
        }
    }
    else if (indexPath.row == articles.count)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"MoreCell"];
        if (!cell){
            cell = [[MoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MoreCell"];
            cell.tag = 200;
            [cell configWithTitle:@"" summary:@"" date:@"" thumbnailUrl:@"" columnId:0];
        }
    }
    else
    {
        Article *article = nil;
        if (self.articles.count >indexPath.row){
            article = [self.articles objectAtIndex:indexPath.row];
            article.isRead = [[self.saveIsRedDic valueForKey:[NSString stringWithFormat:@"%d",article.fileId]] boolValue];
        }
        else{
            cell = [tableView dequeueReusableCellWithIdentifier:@"zeroCell"];
            if (!cell)
                cell = [[TableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"zeroCell"] ;
            
            return cell;
        }
        BOOL isHideReadCount = [self.parentColumn.keyword[@"hideReadCount"] boolValue];
        article.isHideReadCount = isHideReadCount;
        cell.article = article;
        cell = [NewsCellUtil getNewsCell:article in:tableView];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == [self.articles count]) {
        return;
    }
    else{
        Article *currentAricle = nil;
        if (self.articles.count > indexPath.row) {
            currentAricle = [self.articles objectAtIndex:indexPath.row];
        }
        [NewsCellUtil clickNewsCell:currentAricle column:self.parentColumn in:self];
        //存储已读信息
        currentAricle.isRead = YES;
        [self.saveIsRedDic setObject:[NSNumber numberWithBool:YES] forKey:[NSString stringWithFormat:@"%d",currentAricle.fileId]];
        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark - table view delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (cell.tag == 200) {
        if (![UIDevice networkAvailable]) {
            [Global showTipNoNetWork];
            return;
        }
        if ([cell respondsToSelector:@selector(showIndicator)]) {
            [(MoreCell *)cell showIndicator];
        }
        
        Article *lastArticle = [self.articles lastObject];
        [self loadMoreArticlesWithColumnId:parentColumn.columnId
                                    lastFileId:lastArticle.fileId 
                                     rowNumber:(int)[self.articles count]+parentColumn.topArticleNum];
    }
}

- (void)sideBar:(CDRTranslucentSideBar *)sideBar1 willAppear:(BOOL)animated {
    [self.leftController updateUserInfo];
}
@end
