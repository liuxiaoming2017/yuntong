//
//  FDAskCommentViewController.m
//  FounderReader-2.5
//
//  Created by snitsky on 2017/3/14.
//
//

#import "FDAskCommentViewController.h"
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
#import "FDQuestionsAndAnwsersPlusDetailCell.h"
#import "UIImage+Extension.h"
#import "AESCrypt.h"
#import "HttpRequest.h"

@interface FDAskCommentViewController () <UITableViewDelegate, UITableViewDataSource, CommentViewDelegate>

@property (strong, nonatomic) FDAskModel *askModel;
@property (strong, nonatomic) UIView *footView;
@property (strong, nonatomic) CommentViewControllerGuo *commentController;
@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *hottestCommentArray;
@property (strong, nonatomic) NSMutableArray *newestCommentArray;

@property (strong, nonatomic) UIView *hudView;
@property (strong, nonatomic) UIImageView *hudImageView;
@property (strong, nonatomic) UILabel *hudLabel;

@property (strong, nonatomic)FDQuestionsAndAnwsersPlusDetailCell *headerCell;

@property (assign, nonatomic) BOOL isLoading;
@property (nonatomic,strong) HttpRequest * detialRequest;
@property (nonatomic,strong) UIView *header;
@property (nonatomic,assign) struct ItemShowStatus itemShowStatus;
@property (nonatomic,strong) UILabel *titleLabel;
@end

static NSString *CommentCellReuseIdentifier = @"CommentCellReuseIdentifier";
#define SUMNumber 0
#define freeW 10

@implementation FDAskCommentViewController
-(struct ItemShowStatus)itemShowStatus{
    
    _itemShowStatus.askShow = YES;
    _itemShowStatus.answerShow = YES;
    return _itemShowStatus;
}
- (instancetype)initWithAskModel:(FDAskModel *)model {
    if (self = [super init]) {
        model.isShowAllMore = YES;
        self.askModel = model;
    }
    return self;
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
}


- (void)setupNav {
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kSWidth, kNavBarHeight)];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [imageView sd_setImageWithURL:[NSURL URLWithString:self.askModel.askbarTopImg] placeholderImage:[UIImage imageWithColor:colorWithHexString(@"f0f0f0")]];
    [imageView addBlurBackgroudWithStyle:UIBlurEffectStyleLight atIndex:1 alpha:1];
    [self.view addSubview:imageView];
    self.titleLabel= [[UILabel alloc] initWithFrame:CGRectMake(20, 20, kSWidth - 40, 44)];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.text = self.askModel.title.length ? self.askModel.title : NSLocalizedString(@"评论详情", nil);
    self.titleLabel.font = [UIFont systemFontOfSize:19];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    self.titleLabel.shadowOffset = CGSizeMake(.5, .5);
    [self.view addSubview:self.titleLabel];
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
    UIButton *bg = [UIButton buttonWithType:UIButtonTypeCustom];
    [bg setImage:[UIImage imageNamed:@"commentBtn"] forState:UIControlStateNormal];
    if (IS_IPHONE_6)
    {
        backBtn.frame = CGRectMake(5, 12, 23, 23);
        bg.frame = CGRectMake(32, 8, 330, 30);
        [bg setImage:[UIImage imageNamed:@"ditect_write6"] forState:UIControlStateNormal];
    }else if (IS_IPHONE_6P)
    {
        backBtn.frame = CGRectMake(5, 12, 23, 23);
        bg.frame = CGRectMake(34, 9, 370, 30);
        [bg setImage:[UIImage imageNamed:@"ditect_write6p"] forState:UIControlStateNormal];
    }else
    {
        backBtn.frame = CGRectMake(5, 12, 23, 23);
        bg.frame = CGRectMake(30, 8, 280, 30);
    }
    backBtn.centerY = _footView.height*0.5;
    bg.centerY = backBtn.centerY;
    [bg addTarget:self action:@selector(commentItemClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_footView addSubview:bg];
    [self.view addSubview:_footView];
    
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
    [self loadHottestComment];
    [self loadData];
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
    self.header = [[UIView alloc] init];
    _headerCell = [[FDQuestionsAndAnwsersPlusDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"HeaderIdentifier"];
    [self.header addSubview:_headerCell];

    UIView *separatorView = [[UIView alloc] init];
    separatorView.backgroundColor = [UIColor colorWithRed:237/255.f green:237/255.f blue:237/255.f alpha:1];
    //[header addSubview:separatorView];
    self.tableView.tableHeaderView = self.header;
}

- (void)toPraiseAnswer:(UIButton *)praiseBtn
{

    if (praiseBtn.selected) {
        return;
    }
    praiseBtn.selected = YES;
    NSString *prasieKey = [NSString stringWithFormat:@"isPraise_%ld", self.headerCell.askModel.qid.integerValue];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:prasieKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/api/submitAskPlusQuestionEvent", [AppConfig sharedAppConfig].serverIf];
    HttpRequest *praiseRequest = [HttpRequest requestWithURL:[NSURL URLWithString:urlString]];
    [praiseRequest setValue:@"newaircloud.com" forHTTPHeaderField:@"Referer"];
    [praiseRequest setHTTPMethod:@"POST"];
    NSString *sign = [AESCrypt encrypt:[NSString stringWithFormat:@"%@%zd", [AppConfig sharedAppConfig].sid, _headerCell.askModel.qid.integerValue] password:key];
    NSString *bodyString = [NSString stringWithFormat:@"sid=%@&qid=%ld&sign=%@",[AppConfig sharedAppConfig].sid, _headerCell.askModel.qid.integerValue, sign];
    [praiseRequest setHTTPBody:[bodyString dataUsingEncoding:NSUTF8StringEncoding]];
    __weak __typeof (self)weakSelf = self;
    [praiseRequest setCompletionBlock:^(NSData *data) {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers  error:nil];
        NSString *alertStr = NSLocalizedString(@"点赞",nil);
        NSNumber *praiseCount = [dic objectForKey:@"praiseCount"];
        if (praiseCount && ![praiseCount isEqualToNumber:@0]){
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

- (CGFloat)calculateFDQAAPCellHeight {
    struct ItemShowStatus itemShowStatus;
    itemShowStatus.askShow = YES;
    itemShowStatus.answerShow = YES;
    return [self.askModel cellHeight:itemShowStatus];
}


- (void)loadHottestComment {
    int rootID = self.askModel.qid.intValue;
    CommentRequest *request = [CommentRequest commentRequestWithArticleId:rootID lastCommentId:0 count:[NewsListConfig sharedListConfig].count rowNumber:0 isGreate:YES moreCount:0 sourceType:4];
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
-(void)loadData{
    NSURL * url = [NSURL URLWithString: [NSString stringWithFormat:@"%@/api/getAskBarPlusQuestionDetail?sid=%@&qid=%@", [AppConfig sharedAppConfig].serverIf,[AppConfig sharedAppConfig].sid,[self.askModel.qid stringValue]]];
    self.detialRequest = [HttpRequest requestWithURL:url];
    __weak typeof(self) weakSelf = self;
    [self.detialRequest setCompletionBlock:^(id data) {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers  error:nil];
        weakSelf.askModel = [FDAskModel mj_objectWithKeyValues:dic];
        weakSelf.askModel.isShowAllMore = YES;
        [weakSelf reloadHeaderUI];
        
    }];
    [self.detialRequest setFailedBlock:^(NSError *error) {
        NSLog(@"%@",error);
    }];
    [self.detialRequest startSynchronous];
}
-(void)reloadHeaderUI{
    
    [self.askModel cellHeight:self.itemShowStatus];
    self.header.frame =CGRectMake(0, 0, kSWidth, [self calculateFDQAAPCellHeight]);
    _headerCell.frame =  _headerCell.frame = CGRectMake(0, 0, kSWidth, [self calculateFDQAAPCellHeight]);
    [_headerCell layoutCellUI:self.askModel ShowStatus:self.itemShowStatus IndexPath:nil EventBlock:NULL];
    __weak __typeof (self)weakSelf = self;
    [_headerCell.answerPraiseBtn addAction:^(UIButton *btn) {
        [weakSelf toPraiseAnswer:btn];
    }];
    self.titleLabel.text = self.askModel.title.length ? self.askModel.title : NSLocalizedString(@"评论详情", nil);
    
}
- (void)loadNewestComment:(BOOL)isRefresh {
    _isLoading = YES;
    NSInteger lastCommentId = 0;
    if (!isRefresh) {
        Comment *lastComment = [self.newestCommentArray lastObject];
        lastCommentId = lastComment.ID;
    }
    
    int rootID = self.askModel.qid.intValue;
    CommentRequest *request = [CommentRequest commentNewRequestWithArticleId:rootID lastCommentId:lastCommentId count:[NewsListConfig sharedListConfig].count rowNumber:isRefresh ? 0 : (int)self.newestCommentArray.count isGreate:NO moreCount:0 sourceType:4];
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
    _commentController.rootID = self.askModel.qid.integerValue;
    Article *article = [[Article alloc] init];
    article.articleType = 101;
    article.title = self.askModel.title;
    _commentController.article = article;
    _commentController.urlStr = [NSString stringWithFormat:@"%@/api/submitComment",[AppConfig sharedAppConfig].serverIf];
    _commentController.sourceType = 4;
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
    [cell updateWithModel:comment authorID:self.askModel.authorID articleType:ArticleType_QAAPLUS];
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
    NSIndexPath * index = nil;
    if (indexPath.section == 0 && self.hottestCommentArray.count) {
        for (int i =0; i <self.newestCommentArray.count; i++) {
            Comment * newsComment = self.newestCommentArray[i];
            if (newsComment.ID == comment.ID) {
                index = [NSIndexPath indexPathForRow:i inSection:1];
                CommentCell *otherCell = (CommentCell *)[self.tableView cellForRowAtIndexPath:index];
                NSString * otherStr = otherCell.greatCountLabel.text;
                otherCell.greatCountLabel.text = [NSString stringWithFormat:@"%d",(int)[otherStr integerValue]+1];
                otherCell.handIconImageView.image = [UIImage imageNamed:@"btn_comment_press"];
                break;
            }
        }
    } else {
        for (int i =0; i <self.hottestCommentArray.count; i++) {
            Comment * newsComment = self.hottestCommentArray[i];
            if (newsComment.ID == comment.ID) {
                index = [NSIndexPath indexPathForRow:i inSection:0];
                CommentCell *otherCell = (CommentCell *)[self.tableView cellForRowAtIndexPath:index];
                NSString * otherStr = otherCell.greatCountLabel.text;
                otherCell.greatCountLabel.text = [NSString stringWithFormat:@"%d",(int)[otherStr integerValue]+1];
                otherCell.handIconImageView.image = [UIImage imageNamed:@"btn_comment_press"];
                break;
            }
        }
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
        _hudImageView.frame = CGRectMake((kSWidth-50)/2, 200, 50, 50);
        [self.hudView addSubview:_hudImageView];
    }
    return _hudImageView;
}
- (UILabel *)hudLabel {
    if (!_hudLabel) {
        _hudLabel = [[UILabel alloc] init];
        
        _hudLabel.frame = CGRectMake(0, 245, kSWidth, 50);
        _hudLabel.text = NSLocalizedString(@"暂时还没有任何评论哦！",nil);
        _hudLabel.textColor = [UIColor grayColor];
        _hudLabel.textAlignment = NSTextAlignmentCenter;
        _hudLabel.font = [UIFont systemFontOfSize:14];
        
    }
    return _hudLabel;
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
