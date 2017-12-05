//
//  PeopleDailyColumnListPageController.m
//  FounderReader-2.5
//
//  Created by ld on 14-3-5.
//
//

#import "PeopleDailyColumnListPageController.h"
#import "Article.h"
#import "NewsListConfig.h"
#import "ColumnBarConfig.h"
#import "TemplateDetailPageController.h"
#import "PDFColumnListMiddleCell.h"
#import "PDFpaper.h"
#import "PDFdailyColumns.h"
#import "FileLoader.h"
#import "PDFPageDataModel.h"
#import "PDFdailyColumns.h"
#import "TemplateNewDetailViewController.h"
#import "AppConfig.h"
#import "FDPresentSelectionView.h"

@interface PeopleDailyColumnListPageController () <FDPresentSelectionViewDelegate, FDPresentSelectionViewDataSource>
{
}
@property (nonatomic, retain) NSMutableDictionary *saveIsRedDic;
@property(nonatomic,retain) NSMutableArray *articlesForpage;
@property (strong, nonatomic) UIButton *currentNavButton;
@property (strong, nonatomic) FDPresentSelectionView *selectionView;
@property (assign, nonatomic) BOOL isMain;

@end

@implementation PeopleDailyColumnListPageController
@synthesize pdfTableView, selectedDate;
@synthesize pagesWithArticle;

- (instancetype)initWithMain:(BOOL)isMain {
    if (self = [super init]) {
        self.isMain = isMain;
    }
    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    //已经读过的稿件
    
    _saveIsRedDic = [[NSMutableDictionary alloc] initWithContentsOfFile:[cacheDirPath() stringByAppendingString:kSaveIsReadFileName]];
    if (!self.saveIsRedDic) {
        _saveIsRedDic = [[NSMutableDictionary alloc] init];
    }
    
    if (!self.pdfTableView) {
        [self setupPDFTableView];
    }

    self.pagesWithArticle = [[NSMutableArray alloc] init];
}

-(void)setupPDFTableView
{
    pdfTableView = [[UITableView alloc]initWithFrame:self.view.frame style:UITableViewStylePlain];
    if (self.isMain) {
        pdfTableView.frame = CGRectMake(0, 32, kSWidth, self.view.bounds.size.height - kNavBarHeight - kTabBarHeight-32-[ColumnBarConfig sharedColumnBarConfig].columnHeaderHeight);
    }else{
        pdfTableView.frame = CGRectMake(0, 32, kSWidth, self.view.bounds.size.height - kNavBarHeight - kTabBarHeight-32);
    }
    self.pdfTableView.dataSource = self;
    self.pdfTableView.delegate = self;
    _headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, kSWidth-10, 32)];
    //绘制cell分界线占满整个cell宽度 无效
    self.pdfTableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    //剔除tableview出数据之前现满屏空白cell
    [self.pdfTableView setTableFooterView:[[UIView alloc] init]];
    [self.view addSubview:_headerLabel];
    [self.view addSubview:self.pdfTableView];
    [self.view addSubview:self.currentNavButton];
    [self.view addSubview:self.selectionView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

#pragma mark - table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [NewsListConfig sharedListConfig].middleCellHeight;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.pagesWithArticle.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    PDFPageDataModel *columns = [self.pagesWithArticle objectAtIndex:section];
    return columns.articlesList.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return @"自定义Section需要调用此方法";
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,pdfcontentWidth , 25)];
    headerView.backgroundColor = [UIColor colorWithRed:0xED/255.0 green:0xED/255.0 blue:0xED/255.0 alpha:1];
    
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(hgap, 5.5, 2, 18)];
    label1.backgroundColor = [ColumnBarConfig sharedColumnBarConfig].column_all_color;
    [headerView addSubview:label1];

    UILabel *title = [[UILabel alloc]initWithFrame:CGRectMake(hgap+10, 5, pdfcontentWidth-hgap-10, 20)];
    title.textColor = [ColumnBarConfig sharedColumnBarConfig].column_all_color;
    title.font = [UIFont systemFontOfSize:16];
    title.backgroundColor = [UIColor clearColor];
    
    PDFPageDataModel *page = [self.pagesWithArticle objectAtIndex:section];
    title.text = page.pageTitle;
    
    [headerView addSubview:title];
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   
    PDFColumnListMiddleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PDFColumnListMiddleCell"];
    if (!cell)
        cell = [[PDFColumnListMiddleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PDFColumnListMiddleCell"];
    
    PDFPageDataModel *columns = [self.pagesWithArticle objectAtIndex:indexPath.section];
    Article *article = [columns.articlesList objectAtIndex:indexPath.row];
    article.isRead = [[self.saveIsRedDic valueForKey:[NSString stringWithFormat:@"%d",article.fileId]] boolValue];
    [cell configPDFmiddleCell:article];
    
    cell.backgroundColor = [UIColor clearColor];
    
    UIImageView *selectedImageView = [[UIImageView alloc] initWithFrame:cell.bounds];
    selectedImageView.backgroundColor = [UIColor colorWithRed:0xe8/255.0 green:0xe8/255.0 blue:0xe8/255.0 alpha:1];
    cell.selectedBackgroundView = selectedImageView;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    PDFPageDataModel *page = [self.pagesWithArticle objectAtIndex:indexPath.section];
    Article *article = [page.articlesList objectAtIndex:indexPath.row];
    article.attAbstract = [NSString stringWithFormat:@"分享:%@",article.title];
    
    article.isRead = YES;
    [self.saveIsRedDic setObject:[NSNumber numberWithBool:YES] forKey:[NSString stringWithFormat:@"%d",article.fileId]];
    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
    TemplateDetailPageController *controller = [[TemplateDetailPageController alloc] init];
    controller.articles = [NSArray arrayWithObject:article];
    controller.currentIndex = 0;
    controller.isPDF = YES;
    article.shareUrl = [NSString stringWithFormat:@"%@/epaper_detail?aid=%d&sc=%@&app=1",[AppConfig sharedAppConfig].serverIf,article.fileId, [AppConfig sharedAppConfig].sid];
    NSString *str = [NSString stringWithFormat:@"%@",article.contentUrl];
    if (str != nil && ![str isEqualToString:@""] && ![str isEqualToString:@"<null>"] && ![str isEqualToString:@"(null)"]) {
        controller.adArticle = article;
        controller.articles = [NSArray arrayWithObject:article];
        controller.isPDF = YES;
        [self.navigationController pushViewController:controller animated:YES];
    }
    
    return;
}

//绘制cell分割线占满整个屏幕宽度的代码 依然无效
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //绘制cell分割线占满整个屏幕宽度的代码
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

//绘制cell分割线占满整个屏幕宽度的代码 有效
-(void)viewDidLayoutSubviews
{
    if ([self.pdfTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.pdfTableView setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
    }
    
    if ([self.pdfTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.pdfTableView setLayoutMargins:UIEdgeInsetsMake(0,0,0,0)];
    }
}

-(void)reloadPage{
    [self.pdfTableView reloadData];
    _headerLabel.text = self.selectedDate;
    [self.selectionView reloadData];
}

- (UIButton *)currentNavButton {
    if (_currentNavButton == nil) {
        _currentNavButton = [[UIButton alloc] initWithFrame:CGRectMake(kSWidth-90, 0, 90, 32)];
        
        [_currentNavButton setTitle:NSLocalizedString(@"目录导航",nil) forState:UIControlStateNormal];
        _currentNavButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_currentNavButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_currentNavButton addTarget:self action:@selector(showSelectionView) forControlEvents:UIControlEventTouchUpInside];
    }
    return _currentNavButton;
}

- (void)showSelectionView {
    self.selectionView.hidden = !self.selectionView.isHidden;
}

#pragma mark - FDPresentSelectionView

- (FDPresentSelectionView *)selectionView {
    if (_selectionView == nil) {
        CGFloat height = self.view.frame.size.height - kNavBarHeight - kTabBarHeight - 20 - 20;
        if (self.isMain) {
            height -= 44;
        }
        _selectionView = [[FDPresentSelectionView alloc] initWithPresentTableViewFrame:CGRectMake(kSWidth - 200, 40, 190    , height)];
        _selectionView.delegate = self;
        _selectionView.dataSource = self;
        _selectionView.tableView.backgroundColor = [UIColor colorWithRed:0xED/255.0 green:0xED/255.0 blue:0xED/255.0 alpha:1];
    }
    return _selectionView;
}

- (NSInteger)selectionView:(FDPresentSelectionView *)selectionView numberOfRowsInSection:(NSInteger)section {
    return self.pagesWithArticle.count;
}

- (UITableViewCell *)selectionView:(FDPresentSelectionView *)selectionView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [selectionView.tableView dequeueReusableCellWithIdentifier:@"SelectionViewCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SelectionViewCell"];
        cell.backgroundColor = [UIColor clearColor];
    }
    PDFPageDataModel *page = [self.pagesWithArticle objectAtIndex:indexPath.row];
    cell.textLabel.text = page.pageTitle;
    return cell;
}

- (void)selectionView:(FDPresentSelectionView *)selectionView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [selectionView.tableView deselectRowAtIndexPath:indexPath animated:YES];
    selectionView.hidden = YES;
    [self.pdfTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:indexPath.row] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}


@end
