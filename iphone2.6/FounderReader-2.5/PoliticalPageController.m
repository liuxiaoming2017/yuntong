//
//  NJSquarePageController.m
//  FounderReader-2.5
//
//  Created by lihuiguo on 15/8/31.
//
//
//#import "DataSigner.h"
#import "PoliticalPageController.h"
#import "ColumnRequest.h"
#import "ColumnButton.h"
#import "NSString+Helper.h"
#import "MFSideMenu.h"
#import "UIImageView+WebCache.h"
#import <UMMobClick/MobClick.h>
#import "UIView+Extention.h"
#import "FLAnimatedImage.h"
#import "ArticleRequest.h"
#import "NewsListConfig.h"
#import "PoliticalCell.h"
#import "PoliticalCollectionCell.h"
#import "TableViewCell.h"
#import "ColumnBarConfig.h"
#import "PoliticalLocalController.h"
#import "AppStartInfo.h"

@interface PoliticalPageController ()<CDRTranslucentSideBarDelegate>
{
    NSUInteger columnIndex;
}

@end

@implementation PoliticalPageController

- (id)initWithColumn:(Column *)column withIsMain:(int)isMain
{
    self = [super init];
    if (self) {
        self.parentColumn = column;
        self.isMain = isMain;
    }
    return self;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
//    CGFloat columnHeaderHeight = self.isMain ? [ColumnBarConfig sharedColumnBarConfig].columnHeaderHeight : 0;
    tableView = [[UITableView alloc] init];
    NSInteger onlyOne = [[[NSUserDefaults standardUserDefaults] objectForKey:@"onlyOne"] integerValue];
    if (self.viewControllerType == FDViewControllerForCloumnVC) {
        if (onlyOne == 2 && ![AppStartInfo sharedAppStartInfo].ucTabisShow) {
            tableView.frame = CGRectMake(0, 0, kSWidth, self.view.bounds.size.height-kNavBarHeight-[ColumnBarConfig sharedColumnBarConfig].columnHeaderHeight);
        }else{
            tableView.frame = CGRectMake(0, 0, kSWidth, self.view.bounds.size.height-kNavBarHeight-kTabBarHeight-[ColumnBarConfig sharedColumnBarConfig].columnHeaderHeight);
        }
    }else if (self.viewControllerType == FDViewControllerForTabbarVC){
    tableView.frame = CGRectMake(0, 0, kSWidth, kSHeight-kNavBarHeight-kTabBarHeight);
    }else{
    tableView.frame = CGRectMake(0, 0, kSWidth, kSHeight-kNavBarHeight);
    }
    tableView.bounces = NO;
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:tableView];
    
    UIPanGestureRecognizer *panGestureRecognizer = nil;
    if (!self.isMain) {
        leftController = [[PersonalCenterViewController alloc] init];
        self.leftController.view.frame = CGRectMake(0, 0, 240, self.view.bounds.size.height+64);
        
        sideBar = [[CDRTranslucentSideBar alloc] init];
        self.sideBar.sideBarWidth = self.view.bounds.size.width * 0.5;
        self.sideBar.view.frame = CGRectMake(0, 0,self.view.bounds.size.width * 0.5, self.view.bounds.size.height);
        [self.sideBar setContentViewInSideBar:self.leftController.view];
        self.sideBar.delegate = self;
        self.leftController.sideBar = self.sideBar;
        
        panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        if (![AppStartInfo sharedAppStartInfo].ucTabisShow && self.viewControllerType == FDViewControllerForTabbarVC) {
            [self.view addGestureRecognizer:panGestureRecognizer];
        }
    }
    
    [self loadTopImageView];
    
    //地方政情
    UIButton *localPoliticalBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    if (onlyOne == 2 && ![AppStartInfo sharedAppStartInfo].ucTabisShow) {
        localPoliticalBtn.frame = CGRectMake(kSWidth - 90, kSHeight - 126+[ColumnBarConfig sharedColumnBarConfig].columnHeaderHeight, 90, 36);
    }else{
        localPoliticalBtn.frame = CGRectMake(kSWidth - 90, kSHeight - 170+[ColumnBarConfig sharedColumnBarConfig].columnHeaderHeight, 90, 36);
    }
    localPoliticalBtn.backgroundColor = [ColumnBarConfig sharedColumnBarConfig].column_all_color;
    [localPoliticalBtn setTitle:NSLocalizedString(@"地方政情",nil) forState:UIControlStateNormal];
    [localPoliticalBtn.titleLabel setFont:[UIFont systemFontOfSize:15.5]];
    localPoliticalBtn.alpha = 0.8;
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:localPoliticalBtn.bounds byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerTopLeft cornerRadii:CGSizeMake(18, 18)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = localPoliticalBtn.bounds;
    maskLayer.path = maskPath.CGPath;
    localPoliticalBtn.layer.mask = maskLayer;

    [localPoliticalBtn addTarget:self action:@selector(localPoliticalClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:localPoliticalBtn];
    localPoliticalBtn.hidden = self.isFromLocalPolitical;
    localPoliticalBtn.hidden = self.parentColumn.keyword[@"areaColumnID"] == nil ? YES : NO;
    
    [self refreshSquareData];
}

- (void)loadTopImageView
{
    self.topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kSWidth, kSWidth*2/5.0f)];
    self.topView.backgroundColor = [UIColor whiteColor];
    self.topView.userInteractionEnabled = YES;
    
    ImageViewCf *topImageView = [[ImageViewCf alloc] initWithFrame:self.topView.frame];
    topImageView.tag = 777;
    [topImageView setDefaultImage:[Global getBgImage52]];
    [self.topView addSubview:topImageView];
    
    tableView.tableHeaderView = self.topView;
}

- (void)refreshSquareData
{
    ColumnRequest *request = [ColumnRequest columnRequestWithParentColumnId:parentColumn.columnId];
    [request setCompletionBlock:^(NSArray *array) {
        
        NSMutableArray *muArray = [[NSMutableArray alloc] initWithArray:array];
        if (array.count != 0) {
            for (int i = 0; i < array.count; i++) {
                Column *column = [array objectAtIndex:i];
                //是否显示该栏目
                if (column.showcolumn) {
                    [muArray removeObject:column];
                }
            }
        }
        NSArray *arrayLast = [[NSArray alloc] initWithArray:muArray];
        columns = [[NSMutableArray alloc] initWithArray:arrayLast];
        [tableView reloadData];
    }];
    
    [request setFailedBlock:^(NSError *error) {
        [Global showTipNoNetWork];
    }];
    [request startAsynchronous];
}

- (void)localPoliticalClick
{
    PoliticalLocalController *politicalLocalVC = [[PoliticalLocalController alloc] init];
    politicalLocalVC.parentColumn = self.parentColumn;
    politicalLocalVC.isFromColumnBar = NO;
    [self.navigationController pushViewController:politicalLocalVC animated:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self settingNav];
    [self titleLableWithTitle:parentColumn.columnName];
    [self loadArticlesWithColumnId:parentColumn.columnId lastFileId:0 rowNumber:0];
    self.tabBarController.tabBar.hidden = self.isFromLocalPolitical;
    self.navigationItem.rightBarButtonItem = nil;
    NSInteger onlyOne = [[[NSUserDefaults standardUserDefaults] objectForKey:@"onlyOne"] integerValue];
    if (self.viewControllerType == FDViewControllerForCloumnVC) {
        if (onlyOne == 2 && ![AppStartInfo sharedAppStartInfo].ucTabisShow) {
            self.tabBarController.tabBar.hidden = YES;
        }
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
    else
    {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)settingNav
{
    if (self.isFromLocalPolitical) {
        [self setNavButtonItem];
    }else{
        [self leftAndRightButton];
    }
}

- (void)setNavButtonItem
{
    //左边返回按钮
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftButton setImage:[UIImage imageNamed:@"nav_bar_back"] forState:UIControlStateNormal];
    leftButton.frame = CGRectMake(17, 20+(44-23)/2.0, 23, 23);
    leftButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    leftButton.contentEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
    [leftButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
}

- (void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)loadArticlesWithColumnId:(int)columnId lastFileId:(int)lastFileId rowNumber:(int)rowNumber
{
    ArticleRequest *request = [ArticleRequest articleRequestWithColumnId:parentColumn.columnId lastFileId:lastFileId count:[NewsListConfig sharedListConfig].count rowNumber:rowNumber];
    [request setCompletionBlock:^(NSArray *array) {
        if (!array.count) {
            tableView.tableHeaderView = nil;
            return;
        }
        Article *article = [array objectAtIndex:0];
        ImageViewCf *topImageView = (ImageViewCf*)[self.topView viewWithTag:777];
        if ([article.imageUrl containsString:@"@!"]) {
            NSRange range = [article.imageUrl rangeOfString:@"@"];
            NSInteger loc = range.location;
            article.imageUrl = [article.imageUrl substringToIndex:loc];
        }
        if (![NSString isNilOrEmpty:article.imageUrl]) {
            [topImageView setUrlString:[NSString stringWithFormat:@"%@@!md52", article.imageUrl]];
        }else{
            tableView.tableHeaderView = nil;
        }
        
    }];
    [request setFailedBlock:^(NSError *error) {
        [Global showTipNoNetWork];
    }];
    [request startAsynchronous];
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


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.columns.count > section) {
        return self.columns.count;
    }
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)sender cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Column *column = [self.columns objectAtIndex:indexPath.row];
    if(column.keyword[@"showSubPolicy"]){
        PoliticalCollectionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PoliticalCollectionCell"];
        if (cell == nil){
            cell = [[PoliticalCollectionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PoliticalCollectionCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        [cell configPoliticalWithColumn:column];
        return cell;
    }
    else{
        PoliticalCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PoliticalCell"];
        if (cell == nil){
            cell = [[PoliticalCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PoliticalCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        [cell configPoliticalWithColumn:column];
        return cell;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Column *column = [self.columns objectAtIndex:indexPath.row];
    if(column.keyword[@"showSubPolicy"]){
        return kSWidth/3;
    }
    else{
        if (column.iconUrl.length >0) {
            return 100*kSWidth/320;
        }
        return 100*kSWidth/320*3/4;
    }
}
- (void)tableView:(UITableView *)tableView1 didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView1 deselectRowAtIndexPath:indexPath animated:YES];
    Column *column = [self.columns objectAtIndex:indexPath.row];
    if(column.keyword[@"showSubPolicy"]){
        
        PoliticalPageController *politicalController = [[PoliticalPageController alloc] initWithColumn:column withIsMain:0];
        politicalController.isFromLocalPolitical = YES;
        politicalController.isFromColumnBar = NO;
        [self.navigationController pushViewController:politicalController animated:YES];
    }
    else{
        
        column.className = @"PoliticalAboutController";
        ChannelPageController *pageController = [[NSClassFromString(column.className) alloc] init];
        pageController.parentColumn = column;
        [self.navigationController pushViewController:pageController animated:YES];
    }
}

#pragma uitableview
- (void)loadColumnsArray
{
    ColumnRequest *request = [ColumnRequest columnRequestWithParentColumnId:parentColumn.columnId];
    
    [request setCompletionBlock:^(NSArray *array) {
        
        
        NSMutableArray *muArray = [[NSMutableArray alloc] initWithArray:array];
        if (array.count != 0) {
            for (int i = 0; i < array.count; i++) {
                Column *column = [array objectAtIndex:i];
                if (column.showcolumn) {
                    [muArray removeObject:column];
                }
            }
        }
        self.columns = [NSMutableArray arrayWithArray:muArray];
        
        [self loadColumnsFinished];
    }];
    
    [request setFailedBlock:^(NSError *error) {
        XYLog(@"load Columns failed: %@", error);
        [self loadColumnsFailed];
    }];
    [request startAsynchronous];
}

- (void)sideBar:(CDRTranslucentSideBar *)sideBar1 willAppear:(BOOL)animated {
    [self.leftController updateUserInfo];
}
@end
