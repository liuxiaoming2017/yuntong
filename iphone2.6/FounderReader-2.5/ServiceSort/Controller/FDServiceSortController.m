//
//  FDServiceSortController.m
//  FounderReader-2.5
//
//  Created by mac on 2017/7/10.
//
//

#import "FDServiceSortController.h"
#import "HttpRequest.h"
#import "Column.h"
#import "HeadView.h"
#import "FDServiceClassFlowLayout.h"
#import "FootView.h"
#import "FDVerticalCollectionCell.h"
#import "SpecialNewsPageController.h"
#import "PeopleDailyPageController.h"
#import "DishViewController.h"
#import "NJSquarePageController.h"
#import "LocalPageController.h"
#import "LifePageController.h"
#import "PoliticalPageController.h"
#import "AdPageController.h"
#import "NewsPageController.h"
#import "ScenePageController.h"
#import "NormalPageController.h"
#import "FDRefreshHeader.h"
#import "FDTopicListViewController.h"
#import "AppStartInfo.h"
#import "ColumnBarConfig.h"

@interface FDServiceSortController ()<
    CDRTranslucentSideBarDelegate
    ,UIGestureRecognizerDelegate
    ,UICollectionViewDelegate
    ,UICollectionViewDataSource>

@property (nonatomic,strong)NSMutableArray * sessions;
@property (nonatomic,strong) HttpRequest * serviceRequest;
@property (nonatomic,strong) Column * totalColumn;
@property (nonatomic,assign) SHOWTYPE showType;
@property (nonatomic,strong) UICollectionView * columnListView;
@property (nonatomic,strong) FDRefreshHeader *header;
@property (nonatomic,strong) FDServiceClassFlowLayout * layout;
@end
static NSString * const KCollectionViewCell = @"KCollectionViewCell";
static NSString * const KCollectionViewHead = @"KCollectionViewHead";
static NSString * const KCollectionViewFoot = @"KCollectionViewFoot";
@implementation FDServiceSortController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self titleLableWithTitle:self.parentColumn.columnName];
    [self setUpUI];
    [self loadData];
}
-(void)loadData{
    NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/getSunColumnsX?sid=%@&cid=%d",[AppConfig sharedAppConfig].serverIf,[AppConfig sharedAppConfig].sid,self.parentColumn.columnId]];
    self.serviceRequest = [[HttpRequest alloc]initWithURL:url];
    __weak typeof(self) weakSelf = self;
    [self.serviceRequest setCompletionBlock:^(id data) {
        NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        weakSelf.totalColumn = [Column columnsFromDic:dict[@"column"]];
        weakSelf.showType = [[weakSelf.totalColumn.keyword objectForKey:@"showCols"] integerValue] ? [[weakSelf.totalColumn.keyword objectForKey:@"showCols"] integerValue] : SHOWTYPE_FOUR;
        NSArray * groups =[Column columnsFromArray:dict[@"columns"]];
        for (Column * group in groups) {
            BOOL isShow = NO;
            NSArray * groupColumns = [Column columnsFromArray:group.columns];
            for (Column * column in groupColumns) {
                if (!column.showcolumn) {
                    isShow = YES;
                    break;
                }
            }
            if (!group.showcolumn && isShow) {
                [weakSelf.sessions addObject:group];
            }
        }
        [weakSelf.columnListView reloadData];
        //[weakSelf addRefreshHeader];
       // [weakSelf.columnListView.mj_header endRefreshing];

    }];
    [self.serviceRequest setFailedBlock:^(NSError *error) {
        __strong typeof(weakSelf) self = weakSelf;
        [Global showTipNoNetWork];
        //[weakSelf addRefreshHeader];
        if (!self.sessions.count) {
            [Global showWebErrorView:self];
            NSLog(@"-=======%@",self.view.subviews);
        }
        //[weakSelf.columnListView.mj_header endRefreshing];
    }];
     [self.serviceRequest startAsynchronous];
}
- (void)onWebError:(id)sender{
    [self loadData];
    [Global hideWebErrorView:self];
}
-(void)refreshHeader{
    [self loadData];
}
-(void)addRefreshHeader{
    if (self.header == nil) {
        self.header = [FDRefreshHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshHeader)];
        self.columnListView.mj_header = self.header;
    }
}
-(void)setUpUI{
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self leftAndRightButton];
    self.navigationItem.rightBarButtonItem = nil;
    leftController = [[PersonalCenterViewController alloc] init];
    self.leftController.view.frame = CGRectMake(0, 0, 240, self.view.bounds.size.height+kNavBarHeight);
    
    sideBar = [[CDRTranslucentSideBar alloc] init];
    self.sideBar.delegate = self;
    self.sideBar.sideBarWidth = self.view.bounds.size.width * 0.5;
    self.sideBar.view.frame = CGRectMake(0, 0,self.view.bounds.size.width * 0.5, self.view.bounds.size.height);
    [self.sideBar setContentViewInSideBar:self.leftController.view];
    self.leftController.sideBar = self.sideBar;
    
    // Add PanGesture to Show SideBar by PanGesture
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    
    panGestureRecognizer.delegate = self;
    if (![AppStartInfo sharedAppStartInfo].ucTabisShow && self.viewControllerType == FDViewControllerForTabbarVC) {
         [self.view addGestureRecognizer:panGestureRecognizer];
    }
}
//MARK:--UICollectionViewDelegate
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    FDVerticalCollectionCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:KCollectionViewCell forIndexPath:indexPath];
    cell.showType = self.showType;
    Column * sectionColunm = self.sessions[indexPath.section];
    NSArray * columnArry = [Column columnsFromArray:sectionColunm.columns];
    NSMutableArray * showColumns = [NSMutableArray array];
    for (Column * cloumn in columnArry) {
        if (!cloumn.showcolumn) {
            [showColumns addObject:cloumn];
        }
    }
    Column * column = showColumns[indexPath.row];
    cell.column = column;
    return cell;
}
-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        HeadView * view = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:KCollectionViewHead forIndexPath:indexPath];
        Column * column = self.sessions[indexPath.section];
        view.title = column.columnName;
        return view;
    }else{
        FootView * view = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:KCollectionViewFoot forIndexPath:indexPath];
        return view;
    }
    
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    Column * sectionColunm = self.sessions[indexPath.section];
    NSArray * columnArry = [Column columnsFromArray:sectionColunm.columns];
    NSMutableArray * showColumns = [NSMutableArray array];
    for (Column * cloumn in columnArry) {
        if (!cloumn.showcolumn) {
            [showColumns addObject:cloumn];
        }
    }
    Column * column = showColumns[indexPath.row];
    // 数字报栏目
    if ([column.columnStyle isEqualToString:@"读报"]) {
         PeopleDailyPageController* pdfViewControlle = [[PeopleDailyPageController alloc] initWithColumn:nil viewControllerType:FDViewControllerForDetailVC];
        pdfViewControlle.hidesBottomBarWhenPushed = YES;
        pdfViewControlle.navStyle = 1;
        [self.navigationController pushViewController:pdfViewControlle animated:YES];
//        [self presentViewController:[Global controllerToNav:pdfViewControlle] animated:YES completion:nil];
    }
    // 外链栏目
    else if ([column.columnStyle isEqualToString:@"外链"]) {
        AdPageController * adVC = [[AdPageController alloc] initWithColumn:column viewControllerType:FDViewControllerForDetailVC];
        adVC.adColumn = column;
        adVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:adVC animated:YES];
        
    }// 积分商城栏目
    else if ([column.columnStyle isEqualToString:@"积分商城"]) {
        
        CreditMenuViewController*  creditWebController = [[CreditMenuViewController alloc] init];
        creditWebController.viewControllerType = FDViewControllerForDetailVC;
        creditWebController.hidesBottomBarWhenPushed = YES;
        creditWebController.title = @"积分商城";
        [self.navigationController pushViewController:creditWebController animated:YES];
    }
    // 报料栏目
    else if ([column.columnStyle isEqualToString:@"报料"]) {
    
        DishViewController * dishViewController = [[DishViewController alloc] initWithColumn:column viewControllerType:FDViewControllerForDetailVC];
        dishViewController.isMain = NO;
        dishViewController.hidesBottomBarWhenPushed = YES;
        dishViewController.navStyle = 1;
        [self.navigationController pushViewController:dishViewController animated:YES];
    }
    // 服务栏目
    else if([column.columnStyle isEqualToString:@"服务"])
    {
        NJSquarePageController * viewController = [[NJSquarePageController alloc] init];
        viewController.hidesBottomBarWhenPushed = YES;
        viewController.parentColumn = column;
        [self.navigationController pushViewController:viewController animated:YES];

    }
    // 本地栏目
    else if([column.columnStyle isEqualToString:@"本地"])
    {
        LocalPageController * localController = [[LocalPageController alloc] initWithColumn:column withIsMain:1];
        localController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:localController animated:YES];
    }
    // 生活栏目
    else if([column.columnStyle isEqualToString:@"生活"])
    {
       LifePageController * viewController = [[LifePageController alloc] initWithColumn:column viewControllerType:FDViewControllerForDetailVC];
        viewController.hidesBottomBarWhenPushed = YES;
        viewController.isMain = NO;
        viewController.parentColumn = column;
        [self.navigationController pushViewController:viewController animated:YES];
    }
    //政情PoliticalPageController
    else if([column.columnStyle isEqualToString:@"政情"])
    {
        PoliticalPageController * viewController = [[PoliticalPageController alloc] initWithColumn:column withIsMain:NO];
        viewController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:viewController animated:YES];

    } else if ([column.columnStyle isEqualToString:@"问答+"]) {
        FDInteractionPlusViewController  *interactionPlusViewController = [[FDInteractionPlusViewController alloc] initWithColumn:column viewControllerType:FDViewControllerForDetailVC];
        interactionPlusViewController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:interactionPlusViewController animated:YES];
    }
    else if ([column.columnStyle isEqualToString:@"新闻"]) {
        ChannelPageController * newsVC = nil;
        if (column.hasSubColumn) {
            newsVC = [[NewsPageController alloc]init];
        }else{
            newsVC = [[NormalPageController alloc] init];
        }
            newsVC.hidesBottomBarWhenPushed = YES;
            newsVC.parentColumn = column;
            newsVC.viewControllerType = FDViewControllerForDetailVC;
            [self.navigationController pushViewController:newsVC animated:YES];

    }else if ([column.columnStyle isEqualToString:@"直播"]) {
        ScenePageController *sceneVC = [[ScenePageController alloc] initWithColumn:column viewControllerType:FDViewControllerForDetailVC];
        sceneVC.hidesBottomBarWhenPushed = YES;
        sceneVC.parentColumn = column;
        sceneVC.columnName = column.columnName;
        sceneVC.columnId = column.columnId;
        [self.navigationController pushViewController:sceneVC animated:YES];
    }else if ([column.columnStyle isEqualToString:@"话题+"]){
        FDTopicListViewController * topVC = [[FDTopicListViewController alloc]initWithColumn:column viewControllerType:FDViewControllerForDetailVC];
        topVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:topVC animated:YES];
    }
}
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return self.sessions.count ?self.sessions.count:0;
}
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self.columnListView.collectionViewLayout invalidateLayout];
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (!self.sessions) {
        return 0;
    }
    Column * session = self.sessions[section];
    NSArray * sessionColumns = [Column columnsFromArray:session.columns];
    NSMutableArray * showColumns = [NSMutableArray array];
    for (Column * cloumn in sessionColumns) {
        if (!cloumn.showcolumn) {
            [showColumns addObject:cloumn];
        }
    }
    return showColumns.count;
}
#pragma mark - Gesture Handler
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if (self.view.frame.origin.x < 100) {
        return YES;
    }
    return NO;
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
- (void)sideBar:(CDRTranslucentSideBar *)sideBar1 willAppear:(BOOL)animated {
    [self.leftController updateUserInfo];
}
-(void)left{
    [self.sideBar show];
}
-(void)setShowType:(SHOWTYPE)showType{
    _showType = showType;
    switch (_showType) {
        case SHOWTYPE_TWO:
        {
            CGFloat itemW = (kSWidth- 3*15*kScale)/2.0;
            self.layout.itemSize = CGSizeMake(itemW, 109.5*kHScale);
            self.layout.leftRightMargin = 15*kScale;
            self.layout.rowMargin =2.5*kHScale;
            self.layout.columnMargin = 15*kScale;
            self.layout.columsCount = 2;
            self.layout.topMargin = 17.5*kHScale;
            
        }
            break;
        case SHOWTYPE_THREE:
        {
            CGFloat itemW = (kSWidth- 4*(63.5+40)*kScale)/3.0;
            //self.layout.itemSize = CGSizeMake(50*kScale, 90*kHScale);
            self.layout.itemSize = CGSizeMake(itemW, 92*kHScale);
            //self.layout.leftRightMargin = 40*kScale;
            self.layout.leftRightMargin = 40*kScale;
            self.layout.rowMargin =2.5*kHScale;
            //self.layout.columnMargin = 63.5*kScale;
            self.layout.columnMargin = 63.5*kScale;
            self.layout.columsCount = 3;
            self.layout.topMargin = 17.5*kHScale;
        }
            break;
        case SHOWTYPE_FOUR:
        {
            CGFloat itemW = (kSWidth- (2*25 +3*37)*kScale)/4.0;
            //self.layout.itemSize = CGSizeMake(47.5*kScale, 90*kHScale);
            self.layout.itemSize = CGSizeMake(itemW, 92*kHScale);
            self.layout.leftRightMargin = 25*kScale;
            self.layout.rowMargin =2.5*kHScale;
            //self.layout.columnMargin = 37*kScale;
            self.layout.columnMargin = 37*kScale;
            self.layout.columsCount = 4;
            self.layout.topMargin = 17.5*kHScale;
        }
            break;
        default:
            break;
    }
    self.columnListView.collectionViewLayout = self.layout;
}
-(UICollectionView *)columnListView{
    
    if (_columnListView==nil) {
        self.layout= [[FDServiceClassFlowLayout alloc]init];
        switch (_showType) {
            case SHOWTYPE_TWO:
            {
                CGFloat itemW = (kSWidth- 3*15*kScale)/2.0;
                self.layout.itemSize = CGSizeMake(itemW, 109.5*kHScale);
                self.layout.leftRightMargin = 15*kScale;
                self.layout.rowMargin =2.5*kHScale;
                self.layout.columnMargin = 15*kScale;
                self.layout.columsCount = 2;
                self.layout.topMargin = 17.5*kHScale;
                
            }
                break;
            case SHOWTYPE_THREE:
            {
                CGFloat itemW = (kSWidth- 2*(63.5+40)*kScale)/3.0;
                //self.layout.itemSize = CGSizeMake(50*kScale, 90*kHScale);
                self.layout.itemSize = CGSizeMake(itemW, 92*kHScale);
                self.layout.leftRightMargin = 40*kScale;
                self.layout.rowMargin =2.5*kHScale;
//                self.layout.columnMargin = 63.5*kScale;
                self.layout.columnMargin = 63.5*kScale;
                self.layout.columsCount = 3;
                self.layout.topMargin = 17.5*kHScale;
            }
                break;
            case SHOWTYPE_FOUR:
            {
                CGFloat itemW = (kSWidth- (2*25 +3*37)*kScale)/4.0;
                //self.layout.itemSize = CGSizeMake(47.5*kScale, 90*kHScale);
                self.layout.itemSize = CGSizeMake(itemW, 92*kHScale);
                self.layout.leftRightMargin = 25*kScale;
                self.layout.rowMargin =2.5*kHScale;
                //self.layout.columnMargin = 37*kScale;
                self.layout.columnMargin = 37*kScale;
                self.layout.columsCount = 4;
                self.layout.topMargin = 17.5*kHScale;
            }
                break;
            default:
                break;
        }
        self.layout.scrollDirection =UICollectionViewScrollDirectionVertical;
        NSInteger onlyOne = [[[NSUserDefaults standardUserDefaults] objectForKey:@"onlyOne"] integerValue];
        if (onlyOne == 2 && ![AppStartInfo sharedAppStartInfo].ucTabisShow) {
        _columnListView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, kSWidth, kSHeight-kNavBarHeight-[ColumnBarConfig sharedColumnBarConfig].columnHeaderHeight) collectionViewLayout:self.layout];
        }else{
        _columnListView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, kSWidth, kSHeight-kTabBarHeight-kNavBarHeight-[ColumnBarConfig sharedColumnBarConfig].columnHeaderHeight) collectionViewLayout:self.layout];
        }
        _columnListView.contentInset = UIEdgeInsetsMake(0, 0, 20, 0);
        [_columnListView registerClass:[FDVerticalCollectionCell class] forCellWithReuseIdentifier:KCollectionViewCell];
        [_columnListView registerClass:[HeadView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:KCollectionViewHead];
        [_columnListView registerClass:[FootView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:KCollectionViewFoot];
        _columnListView.dataSource = self;
        _columnListView.delegate = self;
        _columnListView.backgroundColor = [UIColor whiteColor];
        if ([_columnListView respondsToSelector:@selector(setPrefetchingEnabled:)]) {
            _columnListView.prefetchingEnabled = false;
        }
        [self.view addSubview:_columnListView];
    }
    return _columnListView;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSInteger onlyOne = [[[NSUserDefaults standardUserDefaults] objectForKey:@"onlyOne"] integerValue];
    if (onlyOne == 2 && ![AppStartInfo sharedAppStartInfo].ucTabisShow){
        self.tabBarController.tabBar.hidden = YES;
    }
    if (self.viewControllerType == FDViewControllerForCloumnVC) {
        self.navigationController.navigationBar.hidden = YES;
    }
}
-(NSMutableArray *)sessions{
    if (_sessions == nil) {
        _sessions = [NSMutableArray array];
    }
    return _sessions;
}
@end
