//
//  FDTopicContentDetailViewController.m
//  FounderReader-2.5
//
//  Created by julian on 2017/6/28.
//
//

#import "FDTopicContentDetailViewController.h"

#import "UIImageView+WebCache.h"
#import "UIView + BlurBackgroud.h"
#import "ForumDetailFootView.h"
#import "UIView+Extention.m"
#import "UIDevice-Reachability.h"
#import "CommentViewControllerGuo.h"
#import "ColumnBarConfig.h"
#import "FDRefreshHeader.h"
#import "FDRefreshFooter.h"
#import "GreatestCommentCell.h"
#import "CommentRequest.h"
#import "NewsListConfig.h"
#import "UIButton+Block.h"
#import "YXLoginViewController.h"
#import "FDTopicPlusDetailCell.h"
#import "UIImage+Extension.h"
#import "AESCrypt.h"
#import "FDTopicDetailListModel.h"
#import "shareCustomView.h"

@interface FDTopicContentDetailViewController () <UITableViewDelegate, UITableViewDataSource, CommentViewDelegate>

@property (strong, nonatomic) NSNumber *discussID;

@property (strong, nonatomic) FDTopicDetailListModel *contentDetailModel;

@property (strong, nonatomic) UIView *footView;
@property (strong, nonatomic) CommentViewControllerGuo *commentController;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UIView *contentDetailHeader;

@property (strong, nonatomic) NSMutableArray *hottestCommentArray;
@property (strong, nonatomic) NSMutableArray *newestCommentArray;

@property (strong, nonatomic) UIView *hudView;
@property (strong, nonatomic) UIImageView *hudImageView;
@property (strong, nonatomic) UILabel *hudLabel;

@property (strong, nonatomic)UIImageView *navImageView;
@property (strong, nonatomic)UILabel *navTitleLabel;

@property (strong, nonatomic)FDTopicPlusDetailCell *headerCell;
@property (strong, nonatomic)UIButton *headerPraiseBtn;
@property (strong, nonatomic)UILabel *headerPraiseLabel;
@property (strong, nonatomic)UIView *separatorView;

@property (strong, nonatomic)UIButton *footCommentBtn;
@property (strong, nonatomic)UIButton *shareBtn;

@property (assign, nonatomic) BOOL isLoading;

@property (nonatomic, strong) HttpRequest *contentDetailRequest;
@property (nonatomic, strong) HttpRequest *detailCommentRequest;

@property (assign, nonatomic) BOOL isFromTopicDetailColumn;//是否来自我的话题详情栏目

@end

static NSString *CommentCellReuseIdentifier = @"CommentCellReuseIdentifier";
#define SUMNumber 0
#define freeW 10

@implementation FDTopicContentDetailViewController

- (instancetype)initWithDiscussID:(NSNumber *)discussID IsFromTopicDetailColumn:(BOOL)isFromTopicDetailColumn
{
    if (self = [super init]) {
        _discussID = discussID;
        _isFromTopicDetailColumn = isFromTopicDetailColumn;
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KchangeUserInfoNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self setupNav];
    [self addFootView];
    [self setupTableView];
    [self createRefreshHeader];
    [self createRefreshFooter];
    [self createTableViewHeader];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changeUserInfo)
                                                 name:KchangeUserInfoNotification
                                               object:nil];
}

- (void)setupNav
{
    _navImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kSWidth, kNavBarHeight)];
    _navImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:_navImageView];
    
    _navTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, kSWidth - 40, 44)];
    _navTitleLabel.textColor = [UIColor whiteColor];
    _navTitleLabel.font = [UIFont systemFontOfSize:19];
    _navTitleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_navTitleLabel];
    
    if (_isFromTopicDetailColumn) {
        _navImageView.backgroundColor = [ColumnBarConfig sharedColumnBarConfig].column_all_color;
        _navTitleLabel.text = @"详情";
    }else {
        [_navImageView addBlurBackgroudWithStyle:UIBlurEffectStyleDark atIndex:1 alpha:0.1];
        _navTitleLabel.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        _navTitleLabel.shadowOffset = CGSizeMake(.5, .5);
    }
}

- (void)updateNavView
{
    [_navImageView sd_setImageWithURL:[NSURL URLWithString:self.contentDetailModel.imgUrl] placeholderImage:[UIImage imageWithColor:colorWithHexString(@"f0f0f0")]];
    _navTitleLabel.text = self.contentDetailModel.title.length ? self.contentDetailModel.title : NSLocalizedString(@"评论详情", nil);
}

- (void)addFootView{
    _footView = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.bounds.size.height-45, kSWidth, 45)];
    _footView.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1];
    
    UIView *topview = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kSWidth, 0.4)];
    if (IS_IPHONE_6P) {
        topview.frame = CGRectMake(0, 0, kSWidth, 0.6);
    }
    topview.alpha = 0.6;
    topview.backgroundColor = [UIColor grayColor];
    [_footView addSubview:topview];
    
    UIButton *backBtn = [[UIButton alloc]initWithFrame:CGRectMake(5, 10, 23, 23)];
    [backBtn setImage:[UIImage imageNamed:@"btn-comment-back"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(goBackIOS6) forControlEvents:UIControlEventTouchUpInside];
    [_footView addSubview:backBtn];
    
    _shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _shareBtn.tag = 1003;
    _shareBtn.frame = CGRectMake(kSWidth - 10 - 30, 8, 30, 30);
    [_shareBtn setImage:[UIImage imageNamed:@"toolbar_share_normal"] forState:UIControlStateNormal];
    [_shareBtn setImage:[UIImage imageNamed:@"toolbar_share_press"] forState:UIControlStateHighlighted];
    [_shareBtn addTarget:self action:@selector(shareClick) forControlEvents:UIControlEventTouchUpInside];
    [_footView addSubview:_shareBtn];
    
    _footCommentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_footCommentBtn setImage:[UIImage imageNamed:@"commentBtn"] forState:UIControlStateNormal];
    if (IS_IPHONE_6)
    {
        backBtn.frame = CGRectMake(5, 12, 23, 23);
        _footCommentBtn.frame = CGRectMake(32, 8, 285, 30);
        [_footCommentBtn setImage:[UIImage imageNamed:@"ditect_write6"] forState:UIControlStateNormal];
    }else if (IS_IPHONE_6P)
    {
        backBtn.frame = CGRectMake(5, 12, 23, 23);
        _footCommentBtn.frame = CGRectMake(34, 9, 325, 30);
        [_footCommentBtn setImage:[UIImage imageNamed:@"ditect_write6p"] forState:UIControlStateNormal];
    }else
    {
        backBtn.frame = CGRectMake(5, 12, 23, 23);
        _footCommentBtn.frame = CGRectMake(30, 8, 235, 30);
    }
    backBtn.centerY = _footView.height*0.5;
    _footCommentBtn.centerY = backBtn.centerY;
    [_footCommentBtn addTarget:self action:@selector(commentItemClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_footView addSubview:_footCommentBtn];
    [self.view addSubview:_footView];
}

- (void)shareClick
{
    if (![UIDevice networkAvailable]) {
        [Global showTipNoNetWork];
        return;
    }
    NSString *shareUrl = [NSString stringWithFormat:@"%@/topicColumn/%@/%ld",[AppConfig sharedAppConfig].serverIf, [AppConfig sharedAppConfig].sid, _detailModel.topicID.integerValue];
    [shareCustomView shareWithContent:_detailModel.topicPlusDescription image:[NSString stringWithFormat:@"%@@!md169", _detailModel.imgUrl] title:_detailModel.title url:shareUrl type:0 completion:^(NSString *resultJson){
//        [FounderEventRequest founderEventShareAppinit:_detailModel.topicID.intValue];
//        //文章分享事件
//        [FounderEventRequest shareDateAnaly:_detailModel.topicID.intValue column:nil];
    }];
}

-(void)goBackIOS6
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)commentItemClicked:(id)sender
{
    [self writeCommentWithIndexPath:nil];
}

- (void)setupTableView {
    [self.view addSubview:self.tableView];
    [self.tableView registerClass:[GreatestCommentCell class] forCellReuseIdentifier:CommentCellReuseIdentifier];
}

- (void)createRefreshHeader {
    FDRefreshHeader *header = [FDRefreshHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshHeader)];
    self.tableView.mj_header = header;
    [header beginRefreshing];
}

- (void)refreshHeader {
    [self loadHeaderInfo];
    [self loadHottestComment];
}

- (void)createRefreshFooter {
    FDRefreshFooter *footer = [FDRefreshFooter footerWithRefreshingTarget:self refreshingAction:@selector(refreshFooter)];
    self.tableView.mj_footer = footer;
}

- (void)refreshFooter {
    if (_isLoading) {
        return;
    }
    [self loadNewestComment:NO];
}

- (void)createTableViewHeader {
    _contentDetailHeader = [[UIView alloc] init];
    
    _headerCell = [[FDTopicPlusDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"HeaderViewIdentifier"];
    [_contentDetailHeader addSubview:_headerCell];
    
    _headerPraiseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_headerPraiseBtn setImage:[UIImage imageNamed:@"topic_contentDetail_normal"] forState:UIControlStateNormal];
    [_headerPraiseBtn setImage:[UIImage imageNamed:@"topic_contentDetail_press"] forState:UIControlStateSelected];
    NSString *prasieKey = [NSString stringWithFormat:@"Topic_Praise_%ld", _discussID.integerValue];
    NSNumber * ispras = [[NSUserDefaults standardUserDefaults] valueForKey:prasieKey];
    if (ispras.integerValue) {
        _headerPraiseBtn.selected = YES;
    }
    [_headerPraiseBtn sizeToFit];
    __weak __typeof (self)weakSelf = self;
    [_headerPraiseBtn addAction:^(UIButton *btn) {
        [weakSelf toPraiseAnswer:btn];
    }];
    [_contentDetailHeader addSubview:_headerPraiseBtn];
    
    _headerPraiseLabel = [[UILabel alloc] init];
    _headerPraiseLabel.textColor = colorWithHexString(@"999999");
    _headerPraiseLabel.font = [UIFont systemFontOfSize:13];
    
    [_contentDetailHeader addSubview:_headerPraiseLabel];
    
    _separatorView = [[UIView alloc] init];
    _separatorView.backgroundColor = [UIColor colorWithRed:237/255.f green:237/255.f blue:237/255.f alpha:1];
    _separatorView.size = CGSizeMake(kSWidth, 5);
    [_contentDetailHeader addSubview:_separatorView];
    _contentDetailHeader.hidden = YES;
    self.tableView.tableHeaderView = _contentDetailHeader;
}

- (void)toUpdateDetailHeaderView
{
    //当图片只有一张时，按比例展示图片
    if (self.contentDetailModel.pics.count == 1)
        [self getImageSizeFromAli];
    else
        [self udateDetailHeaderView];
}

- (void)udateDetailHeaderView
{
    self.contentDetailModel.isHeader = YES;
    _contentDetailHeader.hidden = NO;
    _headerCell.frame = CGRectMake(0, 0, kSWidth, [self.contentDetailModel cellHeight]);
    [_headerCell layoutCell:self.contentDetailModel IsHeader:YES];
    
    _headerPraiseBtn.centerX = _headerCell.centerX;
    _headerPraiseBtn.y = CGRectGetMaxY(_headerCell.frame)-3;
    __weak __typeof (self)weakSelf = self;
    [_headerPraiseBtn addAction:^(UIButton *btn) {
        [weakSelf toPraiseAnswer:btn];
    }];
    
    _headerPraiseLabel.text = self.contentDetailModel.praiseCount.stringValue;
    NSString *prasieKey = [NSString stringWithFormat:@"Topic_Praise_%ld", _discussID.integerValue];
    NSNumber * ispras = [[NSUserDefaults standardUserDefaults] valueForKey:prasieKey];
    _headerPraiseLabel.text = self.contentDetailModel.praiseCount.stringValue;
    if (ispras.integerValue && [self.contentDetailModel.praiseCount.stringValue isEqualToString:@"0"]) {
        _headerPraiseLabel.text = @"1";
    }
    [_headerPraiseLabel sizeToFit];
    _headerPraiseLabel.centerY = _headerPraiseBtn.centerY;
    _headerPraiseLabel.x = CGRectGetMaxX(_headerPraiseBtn.frame)+5;
    
    _separatorView.origin = CGPointMake(0, CGRectGetMaxY(_headerPraiseBtn.frame)+10);
    
    _contentDetailHeader.frame = CGRectMake(0, 0, kSWidth, CGRectGetMaxY(_separatorView.frame));
    
    [self reloadData];
}

#pragma mark - load data

- (void)getImageSizeFromAli
{
    NSDictionary *imageDict = [self.contentDetailModel.pics objectAtIndex:0];
    NSString *imageUrl = [imageDict objectForKey:@"url"];
    
    NSString *requestString = [NSString stringWithFormat:@"%@@infoexif", imageUrl];
    HttpRequest *request = [[HttpRequest alloc] initWithURL:[NSURL URLWithString:requestString]];
    
    __weak __typeof (self)weakSelf = self;
    [request setCompletionBlock:^(NSData *data) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers  error:nil];
        NSDictionary *heightDict = [dict objectForKey:@"ImageHeight"];
        NSString *heightStr = [heightDict objectForKey:@"value"];
        NSDictionary *widthDict = [dict objectForKey:@"ImageWidth"];
        NSString *widthStr = [widthDict objectForKey:@"value"];
        weakSelf.contentDetailModel.imagesSizeByOne = CGSizeMake(widthStr.integerValue, heightStr.integerValue);
        [self udateDetailHeaderView];
    }];
    [request setFailedBlock:^(NSError *error) {
        [Global showTip:NSLocalizedString(@"加载失败，请检查网络",nil)];
    }];
    [request startAsynchronous];
}

- (void)loadHeaderInfo {
    NSString *requestString = [NSString stringWithFormat:@"%@/topicApi/getTopicDiscussContent?sid=%@&discussID=%ld", [AppConfig sharedAppConfig].serverIf, [AppConfig sharedAppConfig].sid, self.discussID.integerValue];
    self.contentDetailRequest = [[HttpRequest alloc] initWithURL:[NSURL URLWithString:requestString]];
    
    __weak __typeof (self)weakSelf = self;
    [self.contentDetailRequest setCompletionBlock:^(NSData *data) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers  error:nil];
        weakSelf.contentDetailModel = [FDTopicDetailListModel mj_objectWithKeyValues:dict];
        // 刷新NavView
        if (!weakSelf.isFromTopicDetailColumn)
            [weakSelf updateNavView];
        // 刷新headerView
        [weakSelf toUpdateDetailHeaderView];
        // 刷新话题首列表页信息
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateTopicArticleByDetail"
                                                            object:weakSelf.contentDetailModel];
    }];
    [self.contentDetailRequest setFailedBlock:^(NSError *error) {
        [Global showTip:NSLocalizedString(@"加载失败，请检查网络",nil)];
    }];
    [self.contentDetailRequest startAsynchronous];
}

- (void)toPraiseAnswer:(UIButton *)praiseBtn
{
    if (praiseBtn.selected) {
        [Global showTip:NSLocalizedString(@"你已经点过赞了！",nil)];
        return;
    }
    praiseBtn.selected = YES;
    NSString *prasieKey = [NSString stringWithFormat:@"Topic_Praise_%ld", _discussID.integerValue];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:prasieKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSString *sign = [AESCrypt encrypt:[NSString stringWithFormat:@"%@%zd", [AppConfig sharedAppConfig].sid, _discussID.integerValue] password:key];
    NSString *urlString = [NSString stringWithFormat:@"%@/topicApi/discussPraise", [AppConfig sharedAppConfig].serverIf];
    HttpRequest *praiseRequest = [HttpRequest requestWithURL:[NSURL URLWithString:urlString]];
    [praiseRequest setValue:@"newaircloud.com" forHTTPHeaderField:@"Referer"];
    [praiseRequest setHTTPMethod:@"POST"];
    NSString *bodyString = [NSString stringWithFormat:@"sid=%@&discussID=%ld&sign=%@",[AppConfig sharedAppConfig].sid, _discussID.integerValue, sign];
    [praiseRequest setHTTPBody:[bodyString dataUsingEncoding:NSUTF8StringEncoding]];
    __weak __typeof (self)weakSelf = self;
    [praiseRequest setCompletionBlock:^(NSData *data) {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers  error:nil];
        NSString *alertStr = NSLocalizedString(@"点赞",nil);
        NSNumber *praiseCount = [dic objectForKey:@"praiseCount"];
        if (praiseCount && ![praiseCount isEqualToNumber:@0]){
            _headerPraiseLabel.text = [praiseCount stringValue];
            [_headerPraiseLabel sizeToFit];
            [weakSelf.headerCell updatePraiseCount:[praiseCount stringValue]];
            if (weakSelf.hasPraiseBlock) {
                weakSelf.hasPraiseBlock(praiseCount);
            }
        }else {
            [Global showTip:[NSString stringWithFormat:@"%@%@",alertStr, NSLocalizedString(@"失败, 请重新尝试",nil)]];
            praiseBtn.selected = NO;
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:prasieKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
    }];
    [praiseRequest setFailedBlock:^(NSError *error) {
        [Global showTipNoNetWork];
    }];
    [praiseRequest startAsynchronous];
}

- (void)loadHottestComment {
    int rootID = self.discussID.intValue;
    CommentRequest *request = [CommentRequest commentRequestWithArticleId:rootID lastCommentId:0 count:[NewsListConfig sharedListConfig].count rowNumber:0 isGreate:YES moreCount:0 sourceType:5];
    __weak __typeof (self)weakSelf = self;
    [request setCompletionBlock:^(NSData *data) {
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers  error:nil];
        NSArray *array =  [dict valueForKey:@"list"];
        weakSelf.hottestCommentArray = [Comment commentsFromArray:array];
        [weakSelf loadNewestComment:YES];
    }];
    [request setFailedBlock:^(NSError *error) {
        [weakSelf loadNewestComment:YES];
        [weakSelf reloadData];
    }];
    [request startAsynchronous];
}

- (void)loadNewestComment:(BOOL)isRefresh {
    _isLoading = YES;
    NSInteger lastCommentId = 0;
    if (!isRefresh) {
        Comment *lastComment = [self.newestCommentArray lastObject];
        lastCommentId = lastComment.ID;
    }
    
    int rootID = self.discussID.intValue;
    CommentRequest *request = [CommentRequest commentNewRequestWithArticleId:rootID lastCommentId:lastCommentId count:[NewsListConfig sharedListConfig].count rowNumber:isRefresh ? 0 : (int)self.newestCommentArray.count isGreate:NO moreCount:0 sourceType:5];
    __weak __typeof (self)weakSelf = self;
    [request setCompletionBlock:^(NSData *data) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers  error:nil];
        NSArray *array = [dict objectForKey:@"list"];
        NSMutableArray *tmpArray = [Comment commentsFromArray:array];
        if (isRefresh) {
            weakSelf.newestCommentArray = nil;
        }
        if (tmpArray.count) {
            for (Comment *comment in tmpArray) {
                NSArray *arr = nil;
                if (comment.topDiscuss.count > 0) {
                    arr = [comment.topDiscuss valueForKey:@"list"];
                    comment.topDiscuss = [Comment commentsFromArray:arr];
                }
            }
            [weakSelf.newestCommentArray addObjectsFromArray:tmpArray];
            [weakSelf.tableView.mj_footer endRefreshing];
        } else {
            [weakSelf.tableView.mj_footer endRefreshingWithNoMoreData];
        }
        [weakSelf.tableView.mj_header endRefreshing];
        [weakSelf reloadData];
        weakSelf.isLoading = NO;
    }];
    [request setFailedBlock:^(NSError *error) {
        weakSelf.isLoading = NO;
    }];
    [request startAsynchronous];
    
}

- (void)reloadData {
    self.hudView.hidden = self.hottestCommentArray.count || self.newestCommentArray.count;
    [self.tableView reloadData];
    self.tableView.tableHeaderView = _contentDetailHeader;
}

#pragma mark - 写评论
- (void)writeCommentWithIndexPath:(NSIndexPath *)indexPath {
    if (![UIDevice networkAvailable]) {
        
        [Global showTipNoNetWork];
        return;
    }
    if (![Global userId].length) {
        [self showLoginPage];
        return;
    }
    _commentController = [[CommentViewControllerGuo alloc] init];
    _commentController.delegate = self;
    _commentController.rootID = self.discussID.integerValue;
    Article *article = [[Article alloc] init];
    article.articleType = 102;
    article.title = self.contentDetailModel.title;
    _commentController.article = article;
    _commentController.urlStr = [NSString stringWithFormat:@"%@/api/submitComment",[AppConfig sharedAppConfig].serverIf];
    _commentController.sourceType = 5;
    __weak __typeof (self)weakSelf = self;
    _commentController.successCommentBlock = ^(){
        if (weakSelf.hasCommentBlock)
            weakSelf.hasCommentBlock();
    };
    
    if (indexPath) {
        Comment *comment;
        if (indexPath.section == 0 && self.hottestCommentArray.count) {
            comment = self.hottestCommentArray[indexPath.row];
        } else {
            comment = self.newestCommentArray[indexPath.row];
        }
        _commentController.commentID = (int)comment.ID;
    }
    [appDelegate().window addSubview:_commentController.view];
}


#pragma mark - tableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return MAX(1, (self.newestCommentArray.count > 0) + (self.hottestCommentArray.count > 0));
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0 && self.hottestCommentArray.count) {
        return self.hottestCommentArray.count;
    } else {
        return self.newestCommentArray.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    int hight = 0;
    Comment *comment;
    if (indexPath.section == 0 && self.hottestCommentArray.count) {
        comment = self.hottestCommentArray[indexPath.row];
    } else {
        comment = self.newestCommentArray[indexPath.row];
    }
    
    if (IS_IPHONE_6P) {
        CGFloat comHeight=[self getAttributeTextHight:comment.content andWidth:325-freeW];
        CGFloat comParent=[self getAttributeTextHight:comment.parentContent andWidth:325-freeW];
        float height = comHeight + 18 + 35+ 15+5;
        if (comment.parentID != -1 && comment.parentID != 0) {
            return height+hight+20 +comParent + 10 + 3*freeW;
        }
        else
        {
            return height + hight;
        }
    }
    else if (IS_IPHONE_6)
    {
        CGFloat comHeight=[self getAttributeTextHight:comment.content andWidth:280-freeW];
        CGFloat comParent=[self getAttributeTextHight:comment.parentContent andWidth:280-freeW];
        float height = comHeight + 18 + 35+ 15+5;
        if (comment.parentID != -1 && comment.parentID != 0) {
            return height+hight+20 +comParent + 10 + 3*freeW;
        }
        else
        {
            return height + hight;
        }
    }else
    {
        CGFloat comHeight=[self getAttributeTextHight:comment.content andWidth:230-freeW];
        CGFloat comParent=[self getAttributeTextHight:comment.parentContent andWidth:230-freeW];
        float height = comHeight + 18 + 35+ 15+5;
        if (comment.parentID != -1 && comment.parentID != 0) {
            return height+hight+20 +comParent + 10 + 3*freeW;
        }
        else
        {
            return height + hight;
        }
    }
    return 100;
}

- (CGFloat)getAttributeTextHight:(NSString *)textStr andWidth:(CGFloat)width
{
    if (textStr == nil || [textStr isEqual:[NSNull null]]) {
        textStr = @" ";
        
    }
    UILabel *label = [[UILabel alloc]init];
    label.numberOfLines = 0;
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc]init];
    [style setLineSpacing:4.0f];
    NSInteger leng = width;
    
    if (IS_IPHONE_6P) {
        NSDictionary *attrsDictionary = @{NSFontAttributeName: [UIFont fontWithName:[Global fontName] size:17]};
        NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc]initWithString:textStr attributes:attrsDictionary];
        if (attStr.length < leng) {
            leng = attStr.length;
        }
        CGSize size = CGSizeMake(325, 900);
        [attStr addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, leng)];
        label.attributedText = attStr;
        CGSize labelSize = [label sizeThatFits:size];
        
        return labelSize.height;
        
    }else if (IS_IPHONE_6) {
        
        NSDictionary *attrsDictionary = @{NSFontAttributeName: [UIFont fontWithName:[Global fontName] size:17]};
        NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc]initWithString:textStr attributes:attrsDictionary];
        if (attStr.length < leng) {
            leng = attStr.length;
        }
        CGSize size = CGSizeMake(280, 900);
        [attStr addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, leng)];
        label.attributedText = attStr;
        CGSize labelSize = [label sizeThatFits:size];
        
        return labelSize.height;
        
    }else {
        NSDictionary *attrsDictionary = @{NSFontAttributeName: [UIFont fontWithName:[Global fontName] size:13]};
        NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc]initWithString:textStr attributes:attrsDictionary];
        if (attStr.length < leng) {
            leng = attStr.length;
        }
        CGSize size = CGSizeMake(230, 900);
        [attStr addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, leng)];
        label.attributedText = attStr;
        CGSize labelSize = [label sizeThatFits:size];
        
        return labelSize.height;
        
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (!self.hottestCommentArray.count && !self.newestCommentArray.count) {
        return 0;
    }
    return 43;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (!self.hottestCommentArray.count && !self.newestCommentArray.count) {
        return nil;
    }
    if (section == 0 && self.hottestCommentArray.count) {
        return [self headerWithTitle:NSLocalizedString(@"热门评论", nil)];
    } else {
        return [self headerWithTitle:NSLocalizedString(@"最新评论", nil)];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (!self.newestCommentArray.count && !self.hottestCommentArray.count) {
        return kSHeight - kNavBarHeight - 45;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (!self.newestCommentArray.count && !self.hottestCommentArray.count) {
        return self.hudView;
    }
    return nil;
}

- (UIView *)headerWithTitle:(NSString *)title {
    UIView *headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kSWidth, 40)];
    headView.backgroundColor = [UIColor whiteColor];
    UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(10, 15, 80*kScale, 24)];
    bgView.backgroundColor = [ColumnBarConfig sharedColumnBarConfig].column_all_color;
    bgView.layer.cornerRadius = 12;
    bgView.layer.masksToBounds = YES;
    [headView addSubview:bgView];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(12*kScale, 2, 60*kScale, 20)];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont systemFontOfSize:14*kScale];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.text = title;
    [bgView addSubview:titleLabel];
    
    UIImageView *lineView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"newsList_separator"]];
    lineView.frame = CGRectMake(CGRectGetMaxX(bgView.frame), bgView.centerY-0.4, kSWidth-CGRectGetMaxX(bgView.frame)+3, 0.5);
    [headView addSubview:lineView];
    return headView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GreatestCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:CommentCellReuseIdentifier];
    Comment *comment;
    if (indexPath.section == 0 && self.hottestCommentArray.count) {
        comment = self.hottestCommentArray[indexPath.row];
    } else {
        comment = self.newestCommentArray[indexPath.row];
    }
    [cell updateWithModel:comment authorID:@0 articleType:ArticleType_TOPICPLUS];
    if (indexPath.row==0) {
        cell.sep.hidden = YES;
    }else
        cell.sep.hidden = NO;
    cell.greatButton.tag = indexPath.row;
    __weak __typeof (self)weakSelf = self;
    [cell.greatButton addAction:^(UIButton *btn) {
        [weakSelf commentPraiseForIndexPath:indexPath];
    }];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self writeCommentWithIndexPath:indexPath];
}

#pragma mark - cell中button点击事件

-(void)commentPraiseForIndexPath:(NSIndexPath *)indexPath {
    Comment *comment;
    if (indexPath.section == 0 && self.hottestCommentArray.count) {
        comment = self.hottestCommentArray[indexPath.row];
    } else {
        comment = self.newestCommentArray[indexPath.row];
    }
    
    BOOL bestId = [[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"%ld",(long)comment.ID]];
    if (bestId) {
        return;
    }
    [self greatAnimate:indexPath];
    [self updateGreatCount:comment indexPath:indexPath];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[NSString stringWithFormat:@"%ld",(long)comment.ID]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)showLoginPage
{
    YXLoginViewController *controller = [[YXLoginViewController alloc]init];
    controller.isNavBack = YES;
    [controller rightPageNavTopButtons];
    [self presentViewController:[Global controllerToNav:controller] animated:YES completion:nil];
}

-(void)greatAnimate:(NSIndexPath *)indexPath
{
    
    CGRect rect = CGRectMake(kSWidth-50, 10, 23, 23);
    
    GreatestCommentCell *cell = (GreatestCommentCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    
    UILabel *label_great = [[UILabel alloc]initWithFrame:rect];
    label_great.font = [UIFont boldSystemFontOfSize:16];
    label_great.textColor = [UIColor colorWithRed:0x13/255.0 green:0xAF/255.0 blue:0xFD/255.0 alpha:1];
    label_great.text = @"+1";
    label_great.alpha = 1;
    [cell addSubview:label_great];
    
    [UIView beginAnimations:@"great" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:1];
    
    label_great.frame = CGRectMake(rect.origin.x
                                   , rect.origin.y-30,
                                   rect.size.width,
                                   rect.size.height);
    label_great.alpha = 0;
    [UIView commitAnimations];
}


/**
 *  更新点赞数
 *
 *  @param comment   被点赞的评论
 *  @param indexPath 该评论的索引
 */
- (void)updateGreatCount:(Comment *)comment indexPath:(NSIndexPath *)indexPath
{
    if (![UIDevice networkAvailable]) {
        
        [Global showTipNoNetWork];
        return;
    }
    CommentCell *cell = (CommentCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    NSString *str = cell.greatCountLabel.text;
    cell.greatCountLabel.text = [NSString stringWithFormat:@"%d",(int)[str integerValue]+1];
    cell.handIconImageView.image = [UIImage imageNamed:@"btn_comment_press"];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/api/event", [AppConfig sharedAppConfig].serverIf];
    NSString *bodyString = [NSString stringWithFormat:@"sid=%@&id=%ld&type=1&eventType=2",[AppConfig sharedAppConfig].sid,(long)comment.ID];
    NSData *data = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    
    HttpRequest *request = [HttpRequest requestWithURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:data];
    [request setCompletionBlock:^(NSData *data)
     {
         NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers  error:nil];
         NSString *str = [NSString stringWithFormat:@"%d",[[dic objectForKey:@"countPraise"] intValue]];
         if (str != nil && ![str isEqualToString:@""])
         {
             [self updateGreatCountLabel:indexPath];
         }
         
     }];
    [request setFailedBlock:^(NSError *error) {
        XYLog(@"点赞失败: %@", error);
    }];
    [request startAsynchronous];
}
-(void)updateGreatCountLabel:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && self.hottestCommentArray.count) {
        Comment *comment = self.hottestCommentArray[indexPath.row];
        comment.greatCount++;
        [self.hottestCommentArray replaceObjectAtIndex:indexPath.row withObject:comment];
    } else {
        Comment *comment = self.newestCommentArray[indexPath.row];
        comment.greatCount++;
        [self.newestCommentArray replaceObjectAtIndex:indexPath.row withObject:comment];
    }
}

- (void)reloadTableView {
    [self.tableView.mj_header beginRefreshing];
}

#pragma mark - getter

- (NSMutableArray *)newestCommentArray {
    if (!_newestCommentArray) {
        _newestCommentArray = [NSMutableArray array];
    }
    return _newestCommentArray;
}

- (NSMutableArray *)hottestCommentArray {
    if (!_hottestCommentArray) {
        _hottestCommentArray = [NSMutableArray array];
    }
    return _hottestCommentArray;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kNavBarHeight, kSWidth, kSHeight - 45 - kNavBarHeight) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.tableFooterView = [[UIView alloc] init];
    }
    return _tableView;
}

- (UIView *)hudView {
    if (!_hudView) {
        _hudView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSWidth, kSHeight - kNavBarHeight - 45)];
        [_hudView addSubview:self.hudImageView];
        [_hudView addSubview:self.hudLabel];
        _hudView.hidden = YES;
    }
    return _hudView;
}
- (UIImageView *)hudImageView {
    if (!_hudImageView) {
        _hudImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"holdIMG"]];
        _hudImageView.frame = CGRectMake((kSWidth-50)/2, 15, 40, 40);
        [self.hudView addSubview:_hudImageView];
    }
    return _hudImageView;
}
- (UILabel *)hudLabel {
    if (!_hudLabel) {
        _hudLabel = [[UILabel alloc] init];
        _hudLabel.frame = CGRectMake(0, 50, kSWidth, 50);
        _hudLabel.text = NSLocalizedString(@"暂时还没有任何评论哦！",nil);
        _hudLabel.textColor = [UIColor grayColor];
        _hudLabel.textAlignment = NSTextAlignmentCenter;
        _hudLabel.font = [UIFont systemFontOfSize:14];
        
    }
    return _hudLabel;
}

#pragma mark - 通知处理
- (void)changeUserInfo
{
    [self loadHottestComment];
    [self loadNewestComment:YES];
}

@end
