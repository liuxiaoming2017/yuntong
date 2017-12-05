//
//  FDQuestionAndAnswerListViewController.m
//  FounderReader-2.5
//
//  Created by snitsky on 2016/12/6.
//
//

#import "FDQuestionsAndAnswersPageController.h"
#import "MiddleCell.h"
#import "ColumnBarConfig.h"
#import "ArticleRequest.h"
#import "CacheManager.h"
#import "MoreCell.h"
#import "NewsListConfig.h"
#import "NewsCellUtil.h"
#import "UIDevice-Reachability.h"

@interface FDQuestionsAndAnswersPageController () <CDRTranslucentSideBarDelegate>

@property (strong, nonatomic) NSNumber *rowNumber;
@property (strong, nonatomic) NSNumber *lastId;

@property (strong, nonatomic) NSMutableDictionary *saveIsRedDic;

@end

@implementation FDQuestionsAndAnswersPageController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupLeftView];
    [self titleLableWithTitle:parentColumn.columnName];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.isMain) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    } else {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
    self.navigationItem.rightBarButtonItem = nil;
    [self.tabBarController.tabBar setHidden:NO];
    [self.navigationController.navigationBar setTranslucent:YES];
    self.edgesForExtendedLayout = UIRectEdgeTop;
    
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    [self.tabBarController.tabBar setHidden:NO];
}

- (void)loadColumnsArray {
    [self loadColumnsFinished];
}

- (void)loadColumnsFinished
{
    [super loadColumnsFinished];
    
    [self loadQAndAsListWithRowNumber:0 LastId:0];
    [self refreshList];
}

- (void)reloadTableViewDataSource {
    
    [self loadQAndAsListWithRowNumber:0 LastId:0];
    
}

- (void)loadQAndAsListWithRowNumber:(int)rowNumber LastId:(int)lastId {
    columnBar.enabled = NO;
    _reloading = YES;
    ArticleRequest *request = [ArticleRequest articleQuestionsAndAnswersRequestWithColumnId:parentColumn.columnId LastId:lastId rowNumber:rowNumber];
    [request setCompletionBlock:^(NSArray *array) {
        CacheManager *manager = [CacheManager sharedCacheManager];
        hasMore = [manager hasMore:parentColumn.columnId rowNumber:rowNumber];
        self.articles = array;
        
        [self loadHeaderWidget];
        [self loadArticlesFinished];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:[NSDate date] forKey:[NSString stringWithFormat:@"%@%d", kLastColumn_RefreshTime, parentColumn.columnId]];
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
    else if (indexPath.row == articles.count) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"MoreCell"];
        if (!cell){
            cell = [[MoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MoreCell"];
            cell.tag = 200;
            [cell configWithTitle:@"" summary:@"" date:@"" thumbnailUrl:@"" columnId:0];
        }
    }
    else{
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
        
        cell = [NewsCellUtil getNewsCell:article in:tableView];
    }
    
    return cell;
}

#pragma mark - table view data source

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == [self.articles count]) {
        return;
    }
    else
    {
        Article *currentAricle = nil;
        if (self.articles.count > indexPath.row) {
            currentAricle = [self.articles objectAtIndex:indexPath.row];
        }
        Column *column = self.parentColumn;
        [NewsCellUtil clickNewsCell:currentAricle column:column in:self];
        
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


//重载该方法，调整tabelview的位置
-(void)initTableViewFrame{
    
    scrollViewbg.contentSize = CGSizeMake(kSWidth *columns.count, kSHeight);
    
    if(self.isMain){
        self.listTableView.frame = CGRectMake(self.listTableView.frame.origin.x, [ColumnBarConfig sharedColumnBarConfig].columnBarHeight+kStatusBarHeight-kNavBarHeight, kSWidth, kSHeight-[ColumnBarConfig sharedColumnBarConfig].columnBarHeight-kTabBarHeight-kStatusBarHeight);
    }
    else{
        self.listTableView.frame = CGRectMake(self.listTableView.frame.origin.x, kNavBarHeight, kSWidth, kSHeight-kNavBarHeight-kTabBarHeight);
    }
}

- (void)setupLeftView {
    UIPanGestureRecognizer *panGestureRecognizer = nil;
    if (!self.isMain) {
        leftController = [[PersonalCenterViewController alloc] init];
        self.leftController.view.frame = CGRectMake(0, 0, 240, self.view.bounds.size.height+kNavBarHeight);
        
        sideBar = [[CDRTranslucentSideBar alloc] init];
        self.sideBar.sideBarWidth = self.view.bounds.size.width * 0.5;
        self.sideBar.view.frame = CGRectMake(0, 0,self.view.bounds.size.width * 0.5, self.view.bounds.size.height);
        [self.sideBar setContentViewInSideBar:self.leftController.view];
        self.sideBar.delegate = self;
        self.leftController.sideBar = self.sideBar;
        panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        [self.view addGestureRecognizer:panGestureRecognizer];
    }

}

- (void)handlePanGesture:(UIPanGestureRecognizer *)recognizer {
    
    // if you have left and right sidebar, you can control the pan gesture by start point.
    CGPoint translatedPoint = [recognizer translationInView:self.view];
    if (translatedPoint.x > 0){
        if (recognizer.state == UIGestureRecognizerStateBegan) {
            CGPoint startPoint = [recognizer locationInView:self.view];
            if (startPoint.x < kSWidth/3.0)
            {
                self.sideBar.isCurrentPanGestureTarget = YES;
            }
        }
        
        [self.sideBar handlePanGestureToShow:recognizer inView:self.view];
    }
}

- (NSMutableDictionary *)saveIsRedDic {
    if (_saveIsRedDic == nil) {
        _saveIsRedDic = [NSMutableDictionary dictionary];
    }
    return _saveIsRedDic;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
