//
//  SpecialNewsPageController.m
//  FounderReader-2.5
//
//  Created by ld on 14-7-31.
//
//专题

#import "SpecialNewsPageController.h"
#import "ImageViewCf.h"
#import "ArticleRequest.h"
#import "CacheManager.h"
#import "TableViewCell.h"
#import "MiddleCell.h"
#import "GroupImage_MiddleCell.h"
#import "Article.h"
#import "Column.h"
#import "NewsListConfig.h"
#import "MFSideMenu.h"
#import "UIAlertView+Helper.h"
#import "AppStartInfo.h"
#import "SeeMethod.h"
#import "ImageDetailPageController.h"
#import "TemplateDetailPageController.h"
#import "FileLoader.h"
#import "SeeRootViewController.h"
#import "TemplateNewDetailViewController.h"
#import "shareCustomView.h"
#import "UIDevice-Reachability.h"
#import "MJRefresh.h"
#import "NewsCellUtil.h"
#import "ColumnBarConfig.h"


#define maxHeightForTitle 70

@interface SpecialNewsPageController () <UITableViewDataSource,UITableViewDelegate>{
    NSInteger columnIndex;
    
}
@property (nonatomic, retain) NSMutableArray *columnArticlesArry;
@property (nonatomic, retain) NSMutableArray *columnArticlesArryDB;

@property (nonatomic, retain) NSMutableArray *columnArrays;
@property (nonatomic, retain) UITableView *specialTableView;
@property (nonatomic, retain) UIView *topView;
@property (nonatomic, retain) UIView *buttonView;
@property (nonatomic, retain) Column *specialColumn;
@property (nonatomic, retain) NSMutableDictionary *saveSpecialIsRead;
@property (nonatomic, retain) UIView *statusBarView;

@property (nonatomic, retain) NSArray *arts;
@end

@implementation SpecialNewsPageController
@synthesize columnArticlesArry,columnArticlesArryDB;
@synthesize specialTableView, column;
@synthesize topView,specialColumn,buttonView;
@synthesize saveSpecialIsRead,statusBarView;

//获取字符串高度
- (CGFloat)getZSCTextHight:(NSString *)textStr andWidth:(CGFloat)width andAttribute:(NSDictionary *)attribute
{
    CGSize size = CGSizeZero;
    size = [textStr boundingRectWithSize:CGSizeMake(width, 1000) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
    
    return size.height;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [Global showTipAlways:NSLocalizedString(@"正在加载...",nil)];
    
    //设置底部工具栏返回按钮
    [self configBottomBackView];
    
    self.columnArrays = [[NSMutableArray alloc] init];
    self.view.backgroundColor = [UIColor whiteColor];
    specialColumn = [[Column alloc] init];

    self.specialTableView = [[UITableView alloc] initWithFrame:
                             CGRectMake(0,20,kSWidth, self.view.bounds.size.height-45-20)
                                                         style:UITableViewStylePlain];
    
    self.specialTableView.delegate = self;
    self.specialTableView.dataSource = self;
    self.specialTableView.scrollsToTop = YES;
    self.specialTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.specialTableView.backgroundColor = [UIColor colorWithRed:0xED/255.0 green:0xED/255.0 blue:0xED/255.0 alpha:1];
    
    [self.view addSubview:self.specialTableView];
    [self creatTopView];
    _reloading = NO;
    if (_refreshHeaderView == nil)
    {
        _refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.specialTableView.bounds.size.height, self.view.bounds.size.width, self.specialTableView.bounds.size.height)];
        _refreshHeaderView.delegate = self;
        [self.specialTableView addSubview:_refreshHeaderView];
        [_refreshHeaderView refreshLastUpdatedDate];
        
    }
    
    columnArticlesArry = [[NSMutableArray alloc]init];
    columnArticlesArryDB = [[NSMutableArray alloc]init];
    self.allArrays = [[NSMutableArray alloc] init];
    
    
    //已经读过的稿件
    self.saveSpecialIsRead = [NSMutableDictionary dictionaryWithContentsOfFile:[cacheDirPath() stringByAppendingString:kSaveSpecialIsReadFileName]];
    if (!self.saveSpecialIsRead) {
        saveSpecialIsRead = [[NSMutableDictionary alloc] init];
    }
    
    UISwipeGestureRecognizer *rightRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(goBackIOS6)];
    rightRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:rightRecognizer];
    
    [self loadTopArticlesWithColumnId];
    [self loadBottomArticlesWithColumnId:parentColumn];
}

- (void)configBottomBackView
{
    UIView *backView = [[UIView alloc]initWithFrame:CGRectMake(0, kSHeight-45, kSWidth, 45)];
    backView.backgroundColor = [UIColor clearColor];
    UILabel *lineLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, -0.25, kSWidth, .5)];
    lineLabel.backgroundColor = [Global navigationLineColor];;
    [backView addSubview:lineLabel];
    
    UIButton *backButton=[[UIButton alloc] initWithFrame:CGRectMake(10, 3, 40, 40)];
    [backButton setBackgroundImage:[UIImage imageNamed:@"Policebacknomal"] forState:UIControlStateNormal];
    [backButton setBackgroundImage:[UIImage imageNamed:@"Policebackpress"] forState:UIControlStateSelected];
    [backButton addTarget:self action:@selector(goBackIOS6) forControlEvents:UIControlEventTouchUpInside];
    [backView addSubview:backButton];
    [self.view addSubview:backView];
    [self.view bringSubviewToFront:backView];
    
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goBackIOS6)];
    [backView addGestureRecognizer:recognizer];
    UIButton *shareBtn = [SeeMethod newButtonWithFrame:CGRectMake(kSWidth-43, 8, 32, 32) type:UIButtonTypeSystem title:nil target:self UIImage:@"toolbar_share_new" andAction:@selector(shareClick)];
    [backView addSubview:shareBtn];
    
}

/**
 *  上拉加载更多
 */
- (void)loadMoreData
{
    NSDictionary *dict = self.allArrays[0];
    NSDictionary *firstColumn = dict[@"column"];
    NSArray *firstColumnArticles = dict[@"list"];
    NSString * url = [NSString stringWithFormat:@"%@/api/getArticles?&sid=%@&cid=%@&lastFileID=%@&count=%d&rowNumber=%lu", [AppConfig sharedAppConfig].serverIf, [AppConfig sharedAppConfig].sid, firstColumn[@"columnID"], [firstColumnArticles lastObject][@"fileID"], 50, (unsigned long)firstColumnArticles.count];

    HttpRequest *request = [HttpRequest requestWithURL:[NSURL URLWithString:url]];
    [request setCompletionBlock:^(NSData *data) {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers  error:nil];
        NSArray *newFirstColumnArticles = [dic objectForKey:@"list"];
        if (newFirstColumnArticles.count) {
            NSMutableArray *NSMufirstColumnArticles = [NSMutableArray arrayWithArray:firstColumnArticles];
            [NSMufirstColumnArticles addObjectsFromArray:newFirstColumnArticles];
            NSMutableDictionary *NSMuDict = [NSMutableDictionary dictionaryWithDictionary:dict];
            [NSMuDict setObject:NSMufirstColumnArticles forKey:@"list"];
            self.allArrays[0] = NSMuDict;
        }
        [self.specialTableView.mj_footer endRefreshing];
        [self.specialTableView reloadData];
        
    }];
    [request setFailedBlock:^(NSError *error) {
    }];
    [request startAsynchronous];
}


/**
 *  创建顶部视图
 */
-(void)creatTopView
{
    topImageScale = [ColumnBarConfig sharedColumnBarConfig].specialImageScale;
    topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kSWidth, kSWidth/topImageScale+40)];
    self.topView.backgroundColor = [UIColor whiteColor];
    self.topView.userInteractionEnabled = YES;
    ImageViewCf *topImageView = [[ImageViewCf alloc] initWithFrame:CGRectMake(0, 0, kSWidth, kSWidth/topImageScale)];
    topImageView.tag = 777;
    if(topImageScale >3.5 && topImageScale <= 4){
        [topImageView setDefaultImage:[Global getBgImage41]];
    }
    else if(topImageScale >2.5 && topImageScale <= 3.5){
        [topImageView setDefaultImage:[Global getBgImage31]];
    }
    else if(topImageScale >1.5 && topImageScale <= 2.5){
        [topImageView setDefaultImage:[Global getBgImage21]];
    }
    else if(topImageScale > 1 && topImageScale <= 1.5){
        [topImageView setDefaultImage:[Global getBgImage43]];
    }
    else{
      [topImageView setDefaultImage:[Global getBgImage31]];
    }
    UILabel *topSummaryLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, kSWidth/topImageScale+8, kSWidth-20, 32)];
    topSummaryLabel.tag = 888;
    topSummaryLabel.font = [UIFont fontWithName:[Global fontName] size:13];
    topSummaryLabel.textColor = [UIColor colorWithRed:0x66/255.0 green:0x66/255.0 blue:0x66/255.0 alpha:1];
    topSummaryLabel.numberOfLines = 0;
    [self.topView addSubview:topImageView];
    [self.topView addSubview:topSummaryLabel];
    
    self.specialTableView.tableHeaderView = self.topView;
}

- (void)shareClick{
    
    [self shareButtonClickHandler:nil];
    
}
- (void)shareButtonClickHandler:(UIButton *)sender
{
    if (![UIDevice networkAvailable]) {
        [Global showTipNoNetWork];
        return;
    }
   
    [shareCustomView shareWithContent:[self newsAbstract] image:[self newsImage] title:[self newsTitle] url:[self newsLink] type:0 completion:^(NSString *resoultJson){
        
//        [FounderEventRequest founderEventShareAppinit:self.speArticle.fileId];
//        //专题分享事件
//        [FounderEventRequest shareDateAnaly:self.speArticle.fileId column:self.column.fullColumn];
    }];
}
- (NSString *)newsTitle
{
    NSString *text = self.speArticle.title;
    if (![self.speArticle.title isKindOfClass:[NSString class]])
        text = @"";
    return text;
}
- (NSString *)newsLink
{
    NSString *text = self.speArticle.contentUrl;
    if (![self.speArticle.contentUrl isKindOfClass:[NSString class]])
        text = @"";
    return text;
}
- (NSString *)newsAbstract
{
    
    NSString *text = self.speArticle.attAbstract;
    if (![self.speArticle.attAbstract isKindOfClass:[NSString class]])
        text = @"";
    return text;
}

- (id)newsImage{
    
    NSString *imageUrl = @"";
    Article *article = nil;
    article = self.speArticle;
    {
        imageUrl = article.imageUrl;
        
    }
    if (imageUrl == nil || [imageUrl isEqualToString:@""]) {
        imageUrl = self.speUrl;
    }
    if (imageUrl == nil || [imageUrl isEqualToString:@""]) {
        return [Global getAppIcon];
    }
    else{
        return imageUrl;
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
    self.navigationController.navigationBar.hidden = YES;
}


-(void)viewWillDisappear:(BOOL)animated
{
    //已经读过的稿件
    [self.saveSpecialIsRead writeToFile:[cacheDirPath() stringByAppendingString:kSaveSpecialIsReadFileName] atomically:YES];
    [Global hideTip];
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

-(void)pressbutton:(UIButton*)lbbutton {
    
    NSUInteger section = lbbutton.tag -300;
    if (section < 1) {
        return;
    }

    NSArray *array = [NSArray arrayWithArray:[[self.allArrays objectAtIndex:section] objectForKey:@"list"]];
    NSArray *articles = [Article articlesFromArray:array];
    NSUInteger articleCount = articles.count;
    
    if (articleCount>0) {
        NSArray *array = [NSArray arrayWithArray:[[self.allArrays objectAtIndex:section-1] objectForKey:@"list"]];
        NSArray *articles = [Article articlesFromArray:array];
        
        NSInteger preCount = articles.count;
        if (preCount) {
            preCount--;
        }
        
        [self.specialTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}


-(void)loadColumnsFinished
{
    [self.columnArticlesArry removeAllObjects];
    columnIndex = 0;
}
// 上面的栏目列表
-(void)createCloumView
{
    UIView *columnsScrollView = [self.topView viewWithTag:666];
    for (UIView *view in columnsScrollView.subviews) {
        NSLog(@"subview_class1 = %@", [view class]);
        if ([view isKindOfClass:[UIButton class]]) {
            [view removeFromSuperview];
        }
    }
    if (!columnsScrollView) {
        UIScrollView *columnsScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(15, 100, kSWidth, 80)];
        columnsScrollView.tag = 666;
        [self.topView addSubview:columnsScrollView];
    }
    
    NSUInteger col = 3;
    NSUInteger row = ceil(self.columnArrays.count /3.0);
    
    float buttonWith = kSWidth*(86/320.0);
    float buttonHeght = kSWidth*(22/320.0);
    float col_gap = kSWidth*(14/320.0);
    float row_gap = 10;
    
    for (int i = 0; i < row; i++)
    {
        for (int j = 0; j < col; j++)
        {
            NSUInteger idx = i *col +j;
            if (idx < self.columnArrays.count) {
                Column *oneColumn = [self.columnArrays objectAtIndex:idx];
                UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                button.frame = CGRectMake((buttonWith+col_gap)*j, (buttonHeght+row_gap)*i, buttonWith, buttonHeght);
                [button setTitle:oneColumn.columnName forState:UIControlStateNormal];
                [button setTitleColor:[UIColor colorWithRed:0x33/255.0 green:0x33/255.0 blue:0x33/255.0 alpha:1] forState:UIControlStateNormal];
                button.titleLabel.font = [UIFont fontWithName:[Global fontName] size:kSWidth*(12/320.0)];
                button.layer.cornerRadius = 11;
                button.layer.borderColor = [[UIColor colorWithRed:0xdd/255.0 green:0xdd/255.0 blue:0xdd/255.0 alpha:1] CGColor];
                button.layer.borderWidth = .5f;
                [button addTarget:self action:@selector(pressbutton:) forControlEvents:UIControlEventTouchUpInside];
                button.tag=300+idx;
                [button setBackgroundColor:[UIColor whiteColor]];
                [columnsScrollView addSubview:button];
            }
        }
    }
    
    columnsScrollView.frame = CGRectMake(17, 100, kSWidth-34, row*(buttonHeght+row_gap));
    
    [self configTopViewFrame];
}

- (void)loadBottomArticlesWithColumnId:(Column *)column
{
    NSString *strUrl = [NSString stringWithFormat:@"%@/api/getSubColumns?&sid=%@&cid=%d&type=3",[AppConfig sharedAppConfig].serverIf,[AppConfig sharedAppConfig].sid, column.columnId];
    HttpRequest *request = [HttpRequest requestWithURL:[NSURL URLWithString:strUrl]];
    [request setCompletionBlock:^(NSData *data) {
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers  error:nil];
        if([dic objectForKey:@"success"]){
            [Global showTipNoNetWork];
            return;
        }
        self.allArrays = [dic objectForKey:@"list"];
        Column *column1 = [Column columnsFromDic:[dic objectForKey:@"column"]];
        self.speUrl = column1.iconUrl;
        self.parentColumn = column1;
        NSArray *arrays = [NSArray arrayWithArray:self.allArrays];
        NSMutableArray *allMuArr = [[NSMutableArray alloc] init];
        for (int i = 0; i < arrays.count; i++) {
            NSArray *array = [NSArray arrayWithArray:[[arrays objectAtIndex:i] objectForKey:@"list"]];
            if (array.count != 0) {
                [allMuArr addObject:[arrays objectAtIndex:i]];
            }
        }
        self.allArrays = allMuArr;
        [self.columnArrays removeAllObjects];
        for (int i = 0; i < self.allArrays.count; i++)
        {
            NSArray *array = [NSArray arrayWithArray:[[self.allArrays objectAtIndex:i] objectForKey:@"list"]];
            if (array.count)
            {
                Column *column1 = [Column columnsFromDic:[[self.allArrays objectAtIndex:i] objectForKey:@"column"]];
                [self.columnArrays addObject:column1];
            }
        }
        if (self.columnArrays.count == 1) {
            self.columnArrays = nil;
        }
        //只有一个子栏目允许上拉加载更多
        if (self.allArrays && self.allArrays.count > 0) {
            NSArray *firstColumnArticle = [self.allArrays[0] objectForKey:@"list"];
            if (self.allArrays.count == 1 && firstColumnArticle.count > 5) {
                //数据太少时@"上拉加载更多"会紧连载最后cell的下面，这里让第一次的文章数大于5个才显示footerView
                __unsafe_unretained __typeof(self) weakSelf = self;
                if (!self.specialTableView.mj_footer) {
                    self.specialTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
                        [weakSelf loadMoreData];
                    }];
                }
            }
        }
        
        [Global hideTip];
        [self createCloumView];
        [self.specialTableView reloadData];
        
    }];
    [request setFailedBlock:^(NSError *error) {
        [Global hideTip];
        [Global showTipNoNetWork];
        return;
    }];
    [request startAsynchronous];
}

-(void)configTopViewFrame
{
    ImageViewCf *topImageView = (ImageViewCf*)[self.topView viewWithTag:777];
    [topImageView setUrlString:self.specialColumn.padIcon];
    UILabel *topSummaryLabel =(UILabel *)[self.topView viewWithTag:888];
    topSummaryLabel.text = self.specialColumn.description;
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    if (kSWidth == 375) {
        paragraphStyle.lineSpacing = 4;
    }else if (kSWidth == 414) {
        paragraphStyle.lineSpacing = 4;
    }else
        paragraphStyle.lineSpacing = 3;
    NSDictionary *attributes = @{
                                 NSFontAttributeName:[UIFont fontWithName:[Global fontName] size:13],
                                 NSParagraphStyleAttributeName:paragraphStyle
                                 };
    if (!topSummaryLabel.text) {
        topSummaryLabel.text = @"";
    }
    
    NSMutableAttributedString *atrStr = [[NSMutableAttributedString alloc] initWithString:topSummaryLabel.text attributes:attributes];
     [atrStr addAttribute:NSFontAttributeName value:[UIFont fontWithName:[Global fontName] size:(13/320.0)*kSWidth] range:NSMakeRange(0, atrStr.length)];
    CGFloat height=[self getZSCTextHight:topSummaryLabel.text andWidth:kSWidth-20 andAttribute:attributes];
    topSummaryLabel.attributedText = atrStr;
    topSummaryLabel.font = [UIFont fontWithName:[Global fontName] size:(13/320.0)*kSWidth];
    if ([self.specialColumn.description isEqualToString:@""] ||  self.specialColumn.description == nil) {
        topSummaryLabel.frame = CGRectMake(10, kSWidth/topImageScale+8, kSWidth-16, 0);
    }
    else
    {
        topSummaryLabel.frame = CGRectMake(10, kSWidth/topImageScale+8, kSWidth-16, height);
    }
    UIView *columnsScrollView = [self.topView viewWithTag:666];
    columnsScrollView.frame = CGRectMake(columnsScrollView.frame.origin.x, topSummaryLabel.frame.origin.y +topSummaryLabel.frame.size.height+6, columnsScrollView.frame.size.width, columnsScrollView.frame.size.height);
    if (([self.specialColumn.description isEqualToString:@""] ||  self.specialColumn.description == nil) && self.columnArrays.count < 2)
    {
        topView.frame = CGRectMake(0, 0, kSWidth, topImageView.bounds.size.height);
    }
    else
    {
        topView.frame = CGRectMake(0, 0, kSWidth, columnsScrollView.frame.origin.y+columnsScrollView.frame.size.height+3);
    }
    
    self.specialTableView.tableHeaderView = nil;
    self.specialTableView.tableHeaderView = self.topView;
    [self.specialTableView reloadData];
    [self.view setNeedsDisplay];
    
}

- (void)loadTopArticlesWithColumnId
{
    NSString *url = [NSString stringWithFormat:@"%@/api/getColumn?sid=%@&cid=%d",[AppConfig sharedAppConfig].serverIf,[AppConfig sharedAppConfig].sid, parentColumn.columnId];
    
    FileLoader *request = [FileLoader fileLoaderWithUrl:url];
    [request setCompletionBlock:^(NSData *data) {
        
        ImageViewCf *topImageView = (ImageViewCf*)[self.topView viewWithTag:777];
        UILabel *topSummaryLabel =(UILabel *)[self.topView viewWithTag:888];
        
        NSDictionary *topDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers  error:nil];
        self.specialColumn.padIcon = [topDict objectForKey:@"imgUrl"];
        if(self.specialColumn.padIcon.length > 0){
            if(topImageScale >3.5 && topImageScale <= 4){
                self.specialColumn.padIcon = [self.specialColumn.padIcon stringByAppendingString:@"@!md41"];
            }
            else if(topImageScale >2.5 && topImageScale <= 3.5){
                self.specialColumn.padIcon = [self.specialColumn.padIcon stringByAppendingString:@"@!md31"];
            }
            else if(topImageScale >1.5 && topImageScale <= 2.5){
               self.specialColumn.padIcon = [self.specialColumn.padIcon stringByAppendingString:@"@!md21"];
            }
            else if(topImageScale > 1 && topImageScale <= 1.5){
                self.specialColumn.padIcon = [self.specialColumn.padIcon stringByAppendingString:@"@!md43"];
            }
            else{
                self.specialColumn.padIcon = [self.specialColumn.padIcon stringByAppendingString:@"@!md31"];
            }
            
        }
        [topImageView setUrlString:self.specialColumn.padIcon];
        if ([NSString isNilOrEmpty:[topDict objectForKey:@"description"]]) {
            topSummaryLabel.text = @"";
            self.specialColumn.description = @"";
        }else {
            topSummaryLabel.text = [topDict objectForKey:@"description"];
            self.specialColumn.description = [topDict objectForKey:@"description"];
        }
        [self createCloumView];
         //[FounderEventRequest articleviewDateAnaly:self.speArticle.fileId column:self.column.fullColumn];
    }];
    [request setFailedBlock:^(NSError *error) {
        
        XYLog(@"load articles failed: %@", error);
        [Global showTipNoNetWork];
    }];
    [request startAsynchronous];
    
}
#pragma mark - table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.allArrays.count) {
        return 0;
    }
    
    Article *article = nil;
    NSArray *array = [NSArray arrayWithArray:[[self.allArrays objectAtIndex:indexPath.section] objectForKey:@"list"]];
    NSArray *articles = [Article articlesFromArray:array];
    if (articles.count >indexPath.row) {
        article = [articles objectAtIndex:indexPath.row];
    }
    return [NewsCellUtil getNewsCellHeight:article];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSArray *array = [NSArray arrayWithArray:[[self.allArrays objectAtIndex:indexPath.section] objectForKey:@"list"]];
    NSArray *articles = [Article articlesFromArray:array];
    if (indexPath.row == [articles count]) {
        return;
    }
    else
    {
        Article *currentAricle = nil;
        if (articles.count > indexPath.row) {
            currentAricle = [articles objectAtIndex:indexPath.row];
        }
        if (currentAricle.articleType == ArticleType_SPECIAL_NUll) {
            return;
        }
        
        [NewsCellUtil clickNewsCell:currentAricle column:self.parentColumn in:self];
        //存储已读信息
        currentAricle.isRead = YES;
        [self.saveSpecialIsRead setObject:[NSNumber numberWithBool:YES] forKey:[NSString stringWithFormat:@"%d",currentAricle.fileId]];
        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark - table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    NSInteger sub = 0;
    for (int i = 0; i < self.allArrays.count; i++)
    {
        sub++;
    }
    return sub;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"自定义Section需要调用此方法";
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(self.allArrays.count) {
        NSArray *array = [NSArray arrayWithArray:[[self.allArrays objectAtIndex:section] objectForKey:@"list"]];
        if (array.count)
            return 28;
        else
            return 0;
    }
    else{
        return 0;
    }
    return 28;
}

/**
 * @brief 自定义section标题视图
 *
 */
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIImageView *bgView = [[UIImageView alloc]init];
    UILabel *titleLabel = [[UILabel alloc]init];
    titleLabel.font = [UIFont fontWithName:[Global fontName] size:12];
    bgView.frame = CGRectMake(0, 0, kSWidth, 28);
    bgView.backgroundColor = UIColorFromString(@"238,241,246");
    titleLabel.frame = CGRectMake(10, 0, kSWidth, 28);
    NSString *title = @"";
    if(self.allArrays.count) {
        NSArray *array = [NSArray arrayWithArray:[[self.allArrays objectAtIndex:section] objectForKey:@"list"]];
        if (array.count)
        {
            Column *column = [Column columnsFromDic:[[self.allArrays objectAtIndex:section] objectForKey:@"column"]];
            title = column.columnName;
        }
        else
        {
            bgView.frame = CGRectMake(0, 0, kSWidth, 2);
        }
    }
    else{
        title = @"";
    }
    
    titleLabel.text = title;
    [bgView addSubview:titleLabel];
    return bgView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.allArrays.count) {
        NSArray *array = [NSArray arrayWithArray:[[self.allArrays objectAtIndex:section] objectForKey:@"list"]];
        NSArray *articles = [Article articlesFromArray:array];
        return articles.count;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Article *article = nil;
    if (self.allArrays.count) {
        NSArray *array = [NSArray arrayWithArray:[[self.allArrays objectAtIndex:indexPath.section] objectForKey:@"list"]];
        if (array.count) {
            NSArray *articles = [Article articlesFromArray:array];
            if (articles.count >indexPath.row) {
                article = [articles objectAtIndex:indexPath.row];
                article.isRead = [[self.saveSpecialIsRead objectForKey:[NSString stringWithFormat:@"%d",article.fileId]] boolValue];
            }
        }
    }
    BOOL isHideReadCount = [self.parentColumn.keyword[@"hideReadCount"] boolValue];
    article.isHideReadCount = isHideReadCount;
    TableViewCell *cell = [NewsCellUtil getNewsCell:article in:tableView];
    return cell;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
}

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
    [self reloadTableViewDataSource];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
{
    return _reloading; // should return if data source model is reloading
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view
{
    return [NSDate date]; // should return date data source was last changed
    //[(FMArticlesListTableView*)view setLastupdatetime:[NSDate date]];
}


#pragma mark - Data Source Loading / Reloading Methods
// 刷新加载稿件数据
- (void)reloadTableViewDataSource
{
    _reloading = YES;
    
    [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:0.01];
    [self loadBottomArticlesWithColumnId:parentColumn];
}

- (void)doneLoadingTableViewData
{
    _reloading = NO;
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.specialTableView];
    
}

- (void)goBackIOS6{
    [super goBackIOS6];
    //[FounderEventRequest articlereturnDateAnaly:self.speArticle.fileId column:self.column.fullColumn];
}
@end
