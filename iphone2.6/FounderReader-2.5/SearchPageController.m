//
//  SearchPageController.m
//  FounderReader-2.5
//
//  Created by sa on 15-1-21.
//
//

#import "SearchPageController.h"
#import "Column.h"
#import "ColumnBarConfig.h"
#import "ArticleRequest.h"
#import "DataLib/DataLib.h"
#import "Article.h"
#import "NewsListConfig.h"
#import "CacheManager.h"
#import "NSString+Helper.h"
#import "ImageDetailPageController.h"
#import "UIDevice-Reachability.h"
#import <MediaPlayer/MediaPlayer.h>
#import "MoreCell.h"
#import "UIView+Extention.h"
#import "SpecialNewsPageController.h"
#import "MiddleCell.h"
#import "TemplateNewDetailViewController.h"
#import "UIAlertView+Helper.h"
#import "SeeRootViewController.h"
#import "TemplateDetailPageController.h"
#import "NewsCellUtil.h"

@interface SearchPageController ()
@end

@implementation SearchPageController
@synthesize articles;
@synthesize lastSelectedIndex;
@synthesize listTableView;
@synthesize searchText;
@synthesize column_id;
@synthesize isSearchChild;
@synthesize img,label,btn;

#define topHeight 37
#define rightWidth 64.5
#define leftWidth 28
#define fieldHeight 28
#define fieldWidth 180
#define MARGIN 10

- (void)viewWillAppear:(BOOL)animated
{
//    [self.navigationController.navigationBar setShadowImage:[UIImage createImageWithColor:[UIColor grayColor]]];
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem.customView.hidden = YES;
    self.navigationController.navigationBarHidden = NO;
    [self rightPageNavTopButtons];
    
    [super viewWillAppear:animated];
    
    [self titleLableWithTitle:NSLocalizedString(@"搜索",nil)];
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    
    UISearchBar *searchBar = [[UISearchBar alloc]init];
    searchBar.frame = CGRectMake(0, MARGIN+2, kSWidth , 28*proportion);
    searchBar.tag = 333;
    searchBar.backgroundColor = [UIColor clearColor];
    searchBar.showsCancelButton = NO;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
    {
        searchBar.searchBarStyle = UISearchBarStyleMinimal;
    }
    searchBar.delegate = self;
    [searchBar becomeFirstResponder];
    [self.view addSubview:searchBar];
   

    
    if (listTableView == nil) {
        listTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        listTableView.frame = CGRectMake(0, 10+topHeight, kSWidth,kSHeight-topHeight-74);
        self.listTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [listTableView setTableFooterView:[[UIView alloc] init]];
        listTableView.delegate = self;
        listTableView.dataSource = self;
    }
    [self.view addSubview:self.listTableView];
    
}
- (void)goRightPageBack{
    UISearchBar *searchBar = (UISearchBar *)[self.view viewWithTag:333];
    [searchBar resignFirstResponder];
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

-(void) searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    
    self.searchText = [searchBar.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if(self.searchText.length == 0){
        [UIAlertView showAlert:NSLocalizedString(@"请输入关键词...",nil)];
        return;
    }
    [self loadArticlesWithSearch:searchBar.text lastFileId:0 rowNumber:0 columnId:column_id];
    [searchBar resignFirstResponder];
}

- (void)refreshList
{
    [self.listTableView setContentOffset:CGPointMake(0, -66) animated:YES];
    [self performSelector:@selector(scrollViewDidEndDragging:willDecelerate:) withObject:self.listTableView afterDelay:1];
}

- (void)stopRefresh
{
    [self.listTableView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
    [_refreshHeaderView setState:EGOOPullRefreshNormal];
    _reloading = NO;
}

#pragma mark - load articles
- (void)loadArticlesWithSearch:(NSString*)value lastFileId:(int)lastFileId rowNumber:(int)rowNumber columnId:(int)columnId
{
    _reloading = YES;
    [Global showTipAlways:NSLocalizedString(@"正在搜索...",nil)];
    ArticleRequest *request = [ArticleRequest articleRequestWithSearch:value lastFileId:lastFileId count:[NewsListConfig sharedListConfig].count rowNumber:rowNumber columnId:columnId];

    [request setCompletionBlock:^(NSArray *array) {
        CacheManager *manager = [CacheManager sharedCacheManager];
        hasMore = [manager hasMore:0 rowNumber:rowNumber];
        self.articles = array;
        self.isSearch = YES;
        [self loadArticlesFinished];
        [Global showTip:NSLocalizedString(@"搜索完成",nil)];
    }];
    [request setFailedBlock:^(NSError *error) {
        XYLog(@"load articles failed: %@", error);
        self.isSearch = YES;
        self.articles = [NSArray array];
        hasMore = NO;
        [self loadArticlesFailed];
        [Global showTipNoNetWork];
        
    }];
    [request startAsynchronous];
}

-(void)searchButton:(UIButton *)sender{

}
- (void)loadArticlesFinished
{
    _reloading = NO;
    _success = YES;
    
    [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:0.01];
    
    [self.listTableView reloadData];
}

- (void)loadArticlesFailed
{
    _reloading = NO;
    
    [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:0.01];
     [self.listTableView reloadData];
}

#pragma mark - load more articles

- (void)loadMoreArticlesWithSearch:(NSString*)value lastFileId:(int)lastFileId rowNumber:(int)rowNumber columnId:columnId
{
    _reloading = YES;
    
    [Global showTipAlways:NSLocalizedString(@"正在加载...",nil)];
    ArticleRequest *request = [ArticleRequest articleRequestWithSearch:value lastFileId:lastFileId count:[NewsListConfig sharedListConfig].count rowNumber:rowNumber columnId:(int)columnId];
    [request setCompletionBlock:^(NSArray *array) {
        CacheManager *manager = [CacheManager sharedCacheManager];
        hasMore = [manager hasMore:-1 rowNumber:rowNumber];
        NSMutableArray *tmpArray = [NSMutableArray arrayWithArray:self.articles];
        [tmpArray addObjectsFromArray:array];
        self.articles = tmpArray;
        [self loadMoreArticlesFinished];
        [Global showTip:NSLocalizedString(@"加载完成",nil)];
    }];
    [request setFailedBlock:^(NSError *error) {
        [self loadMoreArticlesFailed];
        [Global showTipNoNetWork];
    }];
    [request startAsynchronous];
}

- (void)loadMoreArticlesFinished
{
    _reloading = NO;
    
    [self.listTableView reloadData];
}

- (void)loadMoreArticlesFailed
{
    _reloading = NO;
    
    MoreCell *cell = (MoreCell *)[self.listTableView viewWithTag:200];
    if (cell)
        [cell hideIndicator];
}

- (void)playVideo:(NSString *)urlString
{
    MPMoviePlayerViewController *playerController = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:urlString]];
    
    playerController.moviePlayer.movieSourceType = MPMovieSourceTypeFile;
    [playerController.moviePlayer prepareToPlay];
    [playerController.moviePlayer play];
    
    [self presentMoviePlayerViewControllerAnimated:playerController];
}

#pragma mark - table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.articles.count) {
         return [NewsListConfig sharedListConfig].moreCellHeight;
    }
    else if(!self.articles.count && self.isSearch == YES)
    {
        return kSHeight;
    }
    return [NewsListConfig sharedListConfig].middleCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == [self.articles count]) {
        return;
    }
    else {
        Article *article = [self.articles objectAtIndex:indexPath.row];
        Column *column = [[Column alloc] init];
        [NewsCellUtil clickNewsCell:article column:column in:self];
    }
}

#pragma mark - Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource
{
    //[self loadArticlesWithSearch:searchField.text lastFileId:0 rowNumber:0];
}

- (void)doneLoadingTableViewData
{
}

#pragma mark - table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.articles.count) {
        return [self.articles count]+ hasMore;
    }
    else if (!self.articles.count && self.isSearch == YES)
    {
        return 1;
    }
    else{
        return 0;
    }
}

- (void)showHudView
{
    _hudView.hidden = NO;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([articles count] == 0 && self.isSearch == YES) {
        UITableViewCell *promptCell = [tableView dequeueReusableCellWithIdentifier:@"searchCell"];
        if (!promptCell)
            
            promptCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"searchCell"];
    
        {
            _hudView = [[UIView alloc] init];
            _hudView.frame = CGRectMake(0, (kSHeight-100-49-64)/2, kSWidth, 120);
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"holdIMG"]];
            _hudView.hidden = YES;
            imageView.frame = CGRectMake((kSWidth-50)/2, 0, 50, 50);
            UILabel *labelT = [[UILabel alloc] init];
            labelT.frame = CGRectMake(0, 60, kSWidth, 50);
            labelT.text = NSLocalizedString(@"没有找到相关结果！",nil);
            labelT.textColor = [UIColor grayColor];
            labelT.textAlignment = NSTextAlignmentCenter;
            labelT.font = [UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleCellTitleFontSize];
            [_hudView addSubview:labelT];
            [_hudView addSubview:imageView];
            [self.view addSubview:_hudView];
            
            [self performSelector:@selector(showHudView) withObject:nil afterDelay:1];
        }
        return promptCell;
    }
    if(self.articles.count > 0) {
        _hudView.hidden = YES;
    }
    Article *article = nil;
    if (indexPath.row != [self.articles count] && [self.articles count] >=indexPath.row)
        article = [self.articles objectAtIndex:indexPath.row];
    
    TableViewCell *cell = nil;
    
    if (article.title != nil)
    {
        NSMutableAttributedString *title =[[NSMutableAttributedString alloc] initWithString:article.title];
        NSString *strtitle = article.title;
        NSString *strsearch = self.searchText ;
        NSString *pattern = @"[\u4e00-\u9fa5\\w]+";
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];
        NSArray *matches = [regex matchesInString:strsearch options:0 range:NSMakeRange(0, strsearch.length)];
        
        for (NSTextCheckingResult* match in matches){
            NSString *searchText1 = [strsearch substringWithRange:match.range];
            
            NSRange range = [strtitle rangeOfString:searchText1 options:NSRegularExpressionSearch];
            NSRange range2 =[strtitle rangeOfString:article.title options:NSRegularExpressionSearch];
            if (range.location != NSNotFound) {
                NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
                if (kSWidth == 375) {
                    paragraphStyle.lineSpacing = 7;
                }else if (kSWidth == 414) {
                    paragraphStyle.lineSpacing = 7;
                }else
                    paragraphStyle.lineSpacing = 4;
                NSDictionary *attributes = @{
                                            
                                             NSParagraphStyleAttributeName:paragraphStyle,
//                                             NSForegroundColorAttributeName :UIColorFromString(@"19,175,253")
                                             };
                [title addAttribute:NSForegroundColorAttributeName value:UIColorFromString(@"19,175,253") range:range];
                [title addAttributes:attributes range:range2];
 

            }
        }
        
        article.attributetitle = title;
 
    }
    
    if (indexPath.row == [articles count])
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"MoreCell"];
        if (cell == nil)
            cell = [[MoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MoreCell"];
        cell.tag = 200;
        [cell configWithTitle:@"" summary:@"" date:@"" thumbnailUrl:@"" columnId:0];
        return cell;
    }

    BOOL isImageCell = NO;
    
    if (!isImageCell)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"SearchMiddleCell"];
        
        if (cell == nil){
            cell = [[MiddleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SearchMiddleCell"];
    
        }
        [cell configSearchMiddleCellWithArticle:article];
    }

    UIImageView *selectedImageView = [[UIImageView alloc] initWithFrame:cell.bounds];
    selectedImageView.backgroundColor = [UIColor colorWithRed:0xe8/255.0 green:0xe8/255.0 blue:0xe8/255.0 alpha:1];
    selectedImageView.backgroundColor = [UIColor clearColor];
    cell.selectedBackgroundView = selectedImageView;
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (200 == cell.tag){
        if (![UIDevice networkAvailable]) {
            return;
        }
        if ([cell respondsToSelector:@selector(showIndicator)]) {
            [(MoreCell *)cell showIndicator];
        }
        Article *lastArticle = [self.articles lastObject];
        [self loadMoreArticlesWithSearch:self.searchText lastFileId:lastArticle.fileId rowNumber:(int)self.articles.count columnId:0];
    }
}


-(void)configFoodCell:(TableViewCell *)cell withArticle:(Article *)oneArticle
{
}

-(void)viewDidLayoutSubviews
{
    if ([listTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [listTableView setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
    }
    
    if ([listTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [listTableView setLayoutMargins:UIEdgeInsetsMake(0,0,0,0)];
    }
}

@end
