//
//  NJSquarePageController.m
//  FounderReader-2.5
//
//  Created by lihuiguo on 15/8/31.
//
//
//#import "DataSigner.h"
#import "PoliticalAboutController.h"
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
#import "PoliticalAboutCell.h"
#import "FounderDetailPackage.h"
#import "ColumnBarConfig.h"
#import "TemplateDetailPageController.h"
#import "ImageDetailPageController.h"
#import "SpecialNewsPageController.h"
#import "TemplateNewDetailViewController.h"
#import "SeeRootViewController.h"
#import "FounderIntegralRequest.h"
#import "NewsCellUtil.h"
#import "MJRefresh.h"

@interface PoliticalAboutController ()<CDRTranslucentSideBarDelegate, UIWebViewDelegate>
{
    NSUInteger columnIndex;
}

@end

@implementation PoliticalAboutController

- (id)initWithColumn:(Column *)column withIsMain:(int)isMain
{
    self = [super init];
    if (self) {
        self.parentColumn = column;
        self.isMain = isMain;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self loadData];
    
    [self loadTopView];
    
    [self loadBackView];
}
- (void)loadData
{
    self.topArticles = [[NSMutableArray alloc] init];
    
    [self loadArticlesWithColumnId:parentColumn.columnId lastFileId:0 rowNumber:0];
}
- (void)loadTopView
{
    self.topView = [[UIView alloc]initWithFrame:CGRectMake(0, 20, kSWidth, 0.3*kSHeight)];
    self.topView.userInteractionEnabled = YES;
    
    int h = 100*kSWidth/320 - 10*2;
    int w = h * 3/4.0f;
    _topImageView = [[ImageViewCf alloc] initWithFrame:CGRectMake(10, 10, w, h)];
    _topImageView.tag = 777;
    [_topImageView setDefaultImage:[UIImage imageNamed:@"political_head"]];
    [_topImageView setUrlString:parentColumn.iconUrl];
    [self.topView addSubview:_topImageView];
    // 姓名
    UILabel *titleName = [[UILabel alloc] init];
    titleName.frame = CGRectMake(_topImageView.bounds.size.width+20, 10, (kSWidth-_topImageView.bounds.size.width+20)-20, 20);
    titleName.text = parentColumn.columnName;
    titleName.textAlignment = NSTextAlignmentLeft;
    titleName.font = [UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleCellTitleFontSize+3];
    [self.topView addSubview:titleName];
    
    // 分割线
    UILabel *line = [[UILabel alloc] init];
    line.frame = CGRectMake(0, (_topImageView.bounds.size.height+_topImageView.bounds.origin.y+0.3*kSHeight)/2, kSWidth, 1);
    line.backgroundColor = UIColorFromString(@"221,221,221");
    [self.topView addSubview:line];
    
    // 职位
    UILabel *position = [[UILabel alloc] init];
    position.frame = CGRectMake(10, ((_topImageView.bounds.size.height+_topImageView.bounds.origin.y+0.3*kSHeight)/2+_topImageView.bounds.size.height+_topImageView.bounds.origin.y)/2-5, kSWidth-20, 20);
    position.text = parentColumn.description;
    position.textAlignment = NSTextAlignmentLeft;
    position.font = [UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleCellTitleFontSize-1];
    [self.topView addSubview:position];
    
    // 简介
    _introduction = [[UILabel alloc] init];
    _introduction.frame = CGRectMake(_topImageView.bounds.size.width+20, 10+30, kSWidth-_topImageView.bounds.size.width-30, _topImageView.bounds.size.height-30);
    _introduction.numberOfLines = 0;
    _introduction.textAlignment = NSTextAlignmentLeft;
    _introduction.textColor = [UIColor grayColor];
    _introduction.font = [UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleCellTitleFontSize-3];
    [self.topView addSubview:_introduction];
    
    // 相关新闻
    _aboutNew = [[UIButton alloc] init];
    _aboutNew.frame = CGRectMake(10, ((_topImageView.bounds.size.height+_topImageView.bounds.origin.y+0.3*kSHeight)/2+0.3*kSHeight)/2-15, (kSWidth-30)/2, 30);
    [_aboutNew setTitle:NSLocalizedString(@"相关新闻",nil) forState:UIControlStateNormal];
    [_aboutNew setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _aboutNew.backgroundColor = [ColumnBarConfig sharedColumnBarConfig].column_all_color;
    _aboutNew.layer.cornerRadius = 5;
    [_aboutNew addTarget:self action:@selector(aboutNewAction) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:_aboutNew];
    // 履历介绍
    _detailNew = [[UIButton alloc] init];
    _detailNew.frame = CGRectMake(10+(kSWidth-30)/2+10, ((_topImageView.bounds.size.height+_topImageView.bounds.origin.y+0.3*kSHeight)/2+0.3*kSHeight)/2-15, (kSWidth-30)/2, 30);
    [_detailNew setTitle:NSLocalizedString(@"履历介绍",nil) forState:UIControlStateNormal];
    [_detailNew setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _detailNew.backgroundColor = [UIColor whiteColor];
    
    _detailNew.layer.borderWidth = 0.5;
    _detailNew.layer.borderColor = [UIColor grayColor].CGColor;
    _detailNew.layer.cornerRadius = 5;
    [_detailNew addTarget:self action:@selector(detailNewAction) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:_detailNew];
    
    if(parentColumn.iconUrl.length == 0){
        titleName.frame = CGRectMake(10, 20, kSWidth-20, 25);
        _introduction.frame = CGRectMake(10, 50, kSWidth-20, 50);
        position.frame = CGRectMake(10, 105, kSWidth-20, 20);
        line.frame = CGRectMake(0, 128, kSWidth, 1);
        _aboutNew.frame = CGRectMake(10, 136, (kSWidth-30)/2, 30);
        _detailNew.frame = CGRectMake(10+(kSWidth-30)/2+10, 136, (kSWidth-30)/2, 30);
        self.topView.frame = CGRectMake(0, 0, kSWidth, 160);
        _topImageView.hidden = YES;
    }
    
    [self.view addSubview:self.topView];
}
- (void)aboutNewAction
{
    [_aboutNew setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _aboutNew.backgroundColor = [ColumnBarConfig sharedColumnBarConfig].column_all_color;
    _aboutNew.layer.borderWidth = 0;
    
    [_detailNew setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _detailNew.backgroundColor = [UIColor whiteColor];
    _detailNew.layer.borderWidth = 0.5;
    _detailNew.layer.borderColor = [UIColor grayColor].CGColor;
    
    tableView.hidden = NO;
    _webView.hidden = YES;
    
}
- (void)detailNewAction
{
    [_aboutNew setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _aboutNew.backgroundColor = [UIColor whiteColor];
    _aboutNew.layer.borderWidth = 0.5;
    _aboutNew.layer.borderColor = [UIColor grayColor].CGColor;
    
    [_detailNew setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _detailNew.backgroundColor = [ColumnBarConfig sharedColumnBarConfig].column_all_color;
    _detailNew.layer.borderWidth = 0;
    
    tableView.hidden = YES;
    _webView.hidden = NO;
}

- (void)loadDetialView
{
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, self.topView.frame.size.height+20, kSWidth, kSHeight-(self.topView.frame.size.height+20+45))];
    _webView.hidden = YES;
    _webView.delegate = self;
    _webView.scrollView.bounces = NO;
    UILabel *line = [[UILabel alloc] init];
    line.frame = CGRectMake(0, 0, kSWidth, 1);
    line.backgroundColor = UIColorFromString(@"221,221,221");
    [_webView addSubview:line];
    [self.view addSubview:_webView];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"detial" ofType:@"html"];
    NSString *htmlString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    //拼接数据
    NSString *html = [NSString stringWithFormat:htmlString,self.content];
    
    NSURL *baseURL = [NSBundle mainBundle].resourceURL;
    [_webView loadHTMLString:html baseURL:baseURL];
    
}

#pragma mark - webviewdelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    // 清除链接
    NSMutableString *js = [NSMutableString string];
    [js appendString:@"var contentElement = document.getElementsByClassName('whiteContent')[0];"];
    [js appendString:@"var contentHTML = contentElement.innerHTML;"];
    //将<a>标签去掉只保留它的值
    [js appendString:@"contentElement.innerHTML = contentHTML.replace(/(<\\/?a.*?>)|(<\\/?span.*?>)/g, '');"];
    [_webView stringByEvaluatingJavaScriptFromString: js];
}

- (void)loadTableView
{
    tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.topView.frame.size.height+20, kSWidth, kSHeight-(self.topView.frame.size.height+20+45)) style:UITableViewStylePlain];
    
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.hidden = NO;
    UILabel *line = [[UILabel alloc] init];
    line.frame = CGRectMake(0, 0, kSWidth, 1);
    line.backgroundColor = UIColorFromString(@"221,221,221");
    [tableView addSubview:line];
    [self.view addSubview:tableView];
    
    tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self.topArticles removeAllObjects];
        [self loadArticlesWithColumnId:parentColumn.columnId lastFileId:0 rowNumber:0];
    }];
    tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        Article *lastArticle = [self.topArticles lastObject];
        [self loadArticlesWithColumnId:parentColumn.columnId lastFileId:lastArticle.fileId rowNumber:(int)self.topArticles.count];
    }];
}

- (void)loadBackView
{
    UIView *backView = [[UIView alloc]initWithFrame:CGRectMake(0, kSHeight-45, kSWidth, 45)];
    backView.backgroundColor=[UIColor clearColor];
    UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, -0.25, kSWidth, .5)];
    lineLabel.backgroundColor = UIColorFromString(@"150,150,150");
    [backView addSubview:lineLabel];
    
    UIButton *backButton=[[UIButton alloc]initWithFrame:CGRectMake(10, 3, 40, 40)];
    [backButton setBackgroundImage:[UIImage imageNamed:@"Policebacknomal"] forState:UIControlStateNormal];
    [backButton setBackgroundImage:[UIImage imageNamed:@"Policebackpress"] forState:UIControlStateSelected];
    [backButton addTarget:self action:@selector(goBackIOS6) forControlEvents:UIControlEventTouchUpInside];
    [backView addSubview:backButton];
    [self.view addSubview:backView];
    [self.view bringSubviewToFront:backView];
    
    UISwipeGestureRecognizer *rightRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(goBackIOS6)];
    rightRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    rightRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:rightRecognizer];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}


#pragma mark - loadArticles

- (void)loadArticlesWithColumnId:(int)columnId lastFileId:(int)lastFileId rowNumber:(int)rowNumber
{
    ArticleRequest *request = [ArticleRequest articleRequestWithColumnId:parentColumn.columnId lastFileId:lastFileId count:[NewsListConfig sharedListConfig].count rowNumber:rowNumber];
    [request setCompletionBlock:^(NSArray *array) {
        [tableView.mj_header endRefreshing];
        [tableView.mj_footer endRefreshing];
        if (!array.count) {
            return;
        }
        NSMutableArray *muArr = [NSMutableArray arrayWithArray:array];
        //加载顶部数据
        if (lastFileId == 0 && rowNumber==0) {
            self.aboutArticle = [muArr objectAtIndex:0];
            [self loadArticleContent];
            [muArr removeObjectAtIndex:0];
        }
        
        _introduction.text = self.aboutArticle.attAbstract;
        //float h = [FounderDetailPackage HeightWithText:_introduction.text Font:[UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleCellTitleFontSize-3] width:(kSWidth-_topImageView.bounds.size.width-30)];
        //if (h > _topImageView.bounds.size.height-30) {
        //    h = _topImageView.bounds.size.height-30;
        //}
        //_introduction.frame = CGRectMake(_topImageView.bounds.size.width+20, 10+30, kSWidth-_topImageView.bounds.size.width-30, h);
        [self.topArticles addObjectsFromArray:muArr];
        if (!tableView) {
             [self loadTableView];
        }
        [tableView reloadData];

        return;
        
    }];
    [request setFailedBlock:^(NSError *error) {
        [Global showTipNoNetWork];
    }];
    [request startAsynchronous];
}


#pragma mark - loadArticleDetial

- (void)loadArticleContent
{
    NSString *artContentUrl = [NSString stringWithFormat:@"%@",self.aboutArticle.contentUrl];
    __block NSString *str = @"";
    if (artContentUrl != nil && ![artContentUrl isEqualToString:@""] && ![artContentUrl isEqualToString:@"<null>"] && ![artContentUrl isEqualToString:@"(null)"]) {
        self.aboutArticle.contentUrl = artContentUrl;
        str = self.aboutArticle.contentUrl;
        HttpRequest *request = [HttpRequest requestWithURL:[NSURL URLWithString:str]];
        [request setCompletionBlock:^(NSData *data) {
            //将得到的json数据写入articleJson.js中去
            if (!data) {
                return ;
            }
            NSString *jsonStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
            if (!jsonStr || [jsonStr isEqualToString:@"null"]) {
                return;
            }
            NSString *str = [jsonStr substringFromIndex:19];
            NSData *dataDic = [str dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:dataDic options:NSJSONReadingMutableContainers error:nil];
            self.content = [dic objectForKey:@"content"];
            [self loadDetialView];
        }];
        [request setFailedBlock:^(NSError *error) {
            
        }];
        [request startAsynchronous];
        
    }
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.topArticles.count) {
        return self.topArticles.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)sender cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PoliticalAboutCell *cell = nil;
    cell = [tableView dequeueReusableCellWithIdentifier:@"PoliticalAboutCell"];
    Article *article = [self.topArticles objectAtIndex:indexPath.row];
    if (cell == nil)
    {
        cell = [[PoliticalAboutCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PoliticalAboutCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    BOOL hideReadCount = [self.parentColumn.keyword[@"hideReadCount"] boolValue];
    cell.hideReadCount = hideReadCount;
    [cell configPoliticalAboutWithArticle:article];
    return cell;
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == [self.topArticles count]) {
        return 80*kSWidth/320;
    }else {
        Article *article = [self.topArticles objectAtIndex:indexPath.row];
        if (article.isBigPic == 1) {
            return 238*proportion;
        }else if (article.isBigPic ==2){
            return 169*proportion;
        }else{
            return 80*kSWidth/320;
        }
    }
}

- (void)tableView:(UITableView *)tableView1 didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView1 deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == [self.topArticles count]) {
        return;
    }
    else {
        Article *article = [self.topArticles objectAtIndex:indexPath.row];
        [NewsCellUtil clickNewsCell:article column:self.parentColumn in:self];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{// Header念粘位置
    scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
}
@end
