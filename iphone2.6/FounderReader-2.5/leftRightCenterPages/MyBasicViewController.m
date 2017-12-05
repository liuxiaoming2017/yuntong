//
//  MyBasicViewController.m
//  FounderReader-2.5
//
//  Created by ld on 15-2-4.
//
//

#import "MyBasicViewController.h"
#import "UIDevice-Reachability.h"
#import "MoreCell.h"


@interface MyBasicViewController ()<UITableViewDataSource,UITableViewDelegate>

@end

@implementation MyBasicViewController
@synthesize bgImageView;
@synthesize noDataLabel;
@synthesize basicTableView;
@synthesize dataArray;

- (void)viewDidLoad
{
    [super viewDidLoad];
    hasMore = NO;
    
    bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"face_bg"]];
    self.bgImageView.center = CGPointMake(self.view.bounds.size.width/2, 100);
    
    [self.view addSubview:self.bgImageView];
    
    
    noDataLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 200, self.view.bounds.size.width, 20)];
    self.noDataLabel.center = CGPointMake(self.view.bounds.size.width/2, 200);
    self.noDataLabel.textAlignment = 1;
    self.noDataLabel.userInteractionEnabled = NO;
    [self.view addSubview:self.noDataLabel];
    
    basicTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-44)
                                                       style:UITableViewStylePlain];
    if (IS_IPHONE_5)
        self.basicTableView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-64);
    
    self.basicTableView.dataSource = self;
    self.basicTableView.delegate = self;
//    self.basicTableView.allowsSelection = NO;
    [self.view addSubview:self.basicTableView];
    
    [self downLoadData];
    
    if (!_refreshHeaderView) {
        _refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.basicTableView.bounds.size.height, self.view.bounds.size.width, self.basicTableView.bounds.size.height)];
        _refreshHeaderView.delegate = self;
//        _refreshHeaderView.refreshViewTag = @"MyBasicViewController";
        
    }
    if (_refreshHeaderView.superview) {
        [_refreshHeaderView removeFromSuperview];
    }
    [self.basicTableView addSubview:_refreshHeaderView];
    
    [_refreshHeaderView refreshLastUpdatedDate];
	
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
   
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}

#pragma mark - table view delegate
- (CGFloat)tableView:(UITableView *)sender heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}
#pragma mark - table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (hasMore) {
        return self.dataArray.count+1;
    }
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

-(void)showNoDataPage
{
    if (!self.bgImageView.superview)
    {
        [self.view addSubview:self.bgImageView];
    }
    if (!self.noDataLabel.superview)
    {
        [self.view addSubview:self.noDataLabel];
    }
    if (self.basicTableView.superview)
    {
        [self.basicTableView removeFromSuperview];
    }
}

-(void)showListPage
{
    if (self.bgImageView.superview)
    {
        [self.bgImageView removeFromSuperview];
    }
    if (self.noDataLabel.superview)
    {
        [self.noDataLabel removeFromSuperview];
    }
    
    if (!self.basicTableView.superview)
    {
         [self.view addSubview:self.basicTableView];
    }
    [self.basicTableView reloadData];
   
}

- (void)downLoadData
{
     _reloading = YES;
}

-(void)downLoadDataFinished
{
    _reloading = NO;
    [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:0.01];
     [self configPageShow];
    
    if (![UIDevice networkAvailable]) {
        hasMore = NO;
    }
    [self.basicTableView reloadData];
   
}
-(void)downLoadDataFail
{
    _reloading = NO;
    [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:0.01];
    [self configPageShow];
    [self.basicTableView reloadData];
    
}

- (void)downLoadMoreData
{
    _reloading = YES;
}

-(void)downLoadMoreDataFinished
{
    _reloading = NO;
    [self.basicTableView reloadData];
}

-(void)downLoadMoreDataFail
{
    _reloading = NO;
    [self.basicTableView reloadData];
}

-(void)configPageShow
{
    if (self.dataArray.count) {
        [self showListPage];
    }else
    {
        [self showNoDataPage];
        
    }
}
#pragma mark - EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{
	[self reloadTableViewDataSource];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
{
	return _reloading; // should return if data source model is reloading
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view
{
	return [NSDate date]; // should return date data source was last changed
    //[(FMArticlesListTableView*)view setLastupdatetime:[NSDate date]];
}

#pragma mark - Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource
{
    [self downLoadData];
}

- (void)doneLoadingTableViewData
{
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.basicTableView];
}

@end
