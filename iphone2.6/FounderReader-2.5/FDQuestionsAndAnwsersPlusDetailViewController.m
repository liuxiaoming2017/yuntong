//
//  WordsInCellFoldVC.m
//  FoldCellDemo
//
//  Created by 罗金 on 16/4/7.
//  Copyright © 2016年 EasyFlower. All rights reserved.
//

#import "FDQuestionsAndAnwsersPlusDetailViewController.h"
#import "FDQuestionsAndAnwsersPlusDetailCell.h"
#import "FDQuestionsAndAnwsersPlusDetailModel.h"
#import "AppConfig.h"
#import "HttpRequest.h"
#import "MJRefresh.h"
#import "FDAskModel.h"
#import "FDRefreshHeader.h"
#import "FDRefreshFooter.h"
#import "Article.h"
#import "FDQuestionsAndAnwsersPlusDetailTopView.h"
#import "UIView+Extention.h"
#import "UIButton+Block.h"
#import "CommentViewControllerGuo.h"
#import "YXLoginViewController.h"
#import "AESCrypt.h"
#import "FDAskCommentViewController.h"
#import "UIImageView+WebCache.h"
#import "FDQuestionsAndAnwsersPlusDetailHeaderView.h"
#import "UIView + BlurBackgroud.h"
#import "NSString+TimeStringHandler.h"
#import "UIDevice-Reachability.h"
#import "shareCustomView.h"
#import "UIImage+vImage.h"

#define KTopImgVH kSWidth/2.0f
#define KTopMainVH kSWidth/2.0f-kNavBarHeight

static NSString *FDQuestionsAndAnwsersPlusDetailCellId  = @"FDQuestionsAndAnwsersPlusDetailCellId";

@interface FDQuestionsAndAnwsersPlusDetailViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *detailTableView;
@property (nonatomic, strong) FDQuestionsAndAnwsersPlusDetailTopView *topMainView;
@property (nonatomic, strong) UIImageView *topImageView;
@property (nonatomic, strong) UIView *blankView;
@property (nonatomic, strong) UILabel *topTitleBarLabel;
@property (nonatomic, strong) FDQuestionsAndAnwsersPlusDetailHeaderView *headerView;
@property (nonatomic, strong) CommentViewControllerGuo *commentController;
@property (nonatomic, strong) UIView *sectionHeaderView;

@property (nonatomic, strong) NSMutableDictionary *cellShowStatusDict; //存放cell视图展开状态的字典
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, assign) NSInteger pageNumer;
@property (nonatomic, strong) HttpRequest *detailRequest;
@property (nonatomic, strong) HttpRequest *detailListRequest;
@property (nonatomic, strong) FDQuestionsAndAnwsersPlusDetailModel *detailModel;

@property (nonatomic, assign) BOOL isFromAsking; //是否是因为提问而默认关注

@end

@implementation FDQuestionsAndAnwsersPlusDetailViewController

- (void)dealloc
{
    XYLog(@"delloc");
}

- (id)init
{
    if (self = [super init]) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    
    [self downLoadData];
}

#pragma mark - 重写右滑出现评论手势方法 - 去掉右滑手势
-(void)showGreatComment
{
    XYLog(@"去掉右滑出现评论手势");
}

#pragma mark - tableView Delegate && DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    struct ItemShowStatus itemShowStatus;
    NSDictionary *dic = [self.cellShowStatusDict objectForKey:[NSString stringWithFormat:@"%ld", indexPath.row]];
    itemShowStatus.askShow = [dic[@"ask"] boolValue];
    itemShowStatus.answerShow = [dic[@"answer"] boolValue];
    FDAskModel *itemModel = self.dataSource[indexPath.row];
    return [itemModel cellHeight:itemShowStatus];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FDQuestionsAndAnwsersPlusDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:FDQuestionsAndAnwsersPlusDetailCellId];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    FDAskModel *itemModel = self.dataSource[indexPath.row];
    struct ItemShowStatus itemShowStatus;
    NSDictionary *dic = [self.cellShowStatusDict objectForKey:[NSString stringWithFormat:@"%ld", indexPath.row]];
    itemShowStatus.askShow = [dic[@"ask"] boolValue];
    itemShowStatus.answerShow = [dic[@"answer"] boolValue];
    __weak __typeof(self)weakSelf = self;
    
    [cell layoutCellUI:itemModel ShowStatus:itemShowStatus IndexPath:indexPath EventBlock:^(NSDictionary *dic) {
        
        NSString *event = [dic objectForKey:@"event"];
        if ([event isEqualToString:@"show"]) {
            [weakSelf.cellShowStatusDict setObject:[dic objectForKey:@"showStatus"] forKey:[NSString stringWithFormat:@"%@",[dic objectForKey:@"row"]]];
            [_detailTableView reloadData];
        } else if ([event isEqualToString:@"praise"]) {
            UIButton *btn = (UIButton *)[dic objectForKey:@"eventView"];
            NSIndexPath *indexPath = (NSIndexPath *)[dic objectForKey:@"indexPath"];
            if(![NSString isNilOrEmpty:[Global userId]])
                [weakSelf toPraiseAnswer:btn IndexPath:indexPath];
            else
                [weakSelf toLoginWithBlock:^{
                    [weakSelf toPraiseAnswer:btn IndexPath:indexPath];
                }];
        }
    }];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FDAskModel *itemModel = self.dataSource[indexPath.row];
    FDAskModel *itemModelNew = [itemModel mutableCopy];
    itemModelNew.isShowAllMore = YES;
    itemModelNew.title = self.detailModel.title;
    itemModelNew.askbarTopImg = [NSString stringWithFormat:@"%@@!md169", _detailModel.imgUrl];
    itemModelNew.authorID = self.detailModel.authorID;
    FDAskCommentViewController *askCommentVC = [[FDAskCommentViewController alloc] initWithAskModel:itemModelNew];
    askCommentVC.hasPraiseBlock = ^(NSNumber *praiseCount){
        FDQuestionsAndAnwsersPlusDetailCell *cell = (FDQuestionsAndAnwsersPlusDetailCell *)[self.detailTableView cellForRowAtIndexPath:indexPath];
        cell.answerPraiseBtn.selected = YES;
        [cell updatePraiseCount:[praiseCount stringValue]];
        cell.askModel.praiseCount = praiseCount;
    };
    if ([NSString isNilOrEmpty:itemModel.answerTime]) return;
    [self.navigationController pushViewController:askCommentVC animated:YES];
}

- (void)setupUI
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupTopImgV];
    
    [self setupTopTitleBarV];
    
    [self setupTableV];
    
    [self setupTopHeaderView];
    
    [self setupTopMainV];
}

#pragma mark - 布局子控件
- (void)setupTopImgV
{
    UIImageView *topImageView = [[UIImageView alloc] init];
    topImageView.frame = CGRectMake(0, -kNavHeight, kSWidth, KTopImgVH+kNavHeight);
    [self.view addSubview:topImageView];
    //iOS8以上加毛玻璃
    [topImageView addBlurBackgroudWithStyle:UIBlurEffectStyleLight atIndex:0 alpha:0.2];
    self.topImageView = topImageView;
    [self.view sendSubviewToBack:topImageView];
}

- (void)setupTopTitleBarV
{
    UILabel *topTitleBarLabel = [[UILabel alloc] init];
    topTitleBarLabel.frame = CGRectMake(kSWidth*1/4.0f/2.0f, kStatusBarHeight, kSWidth*3/4.0f, kNavHeight);
    topTitleBarLabel.textAlignment = NSTextAlignmentCenter;
    topTitleBarLabel.textColor = [UIColor whiteColor];
    topTitleBarLabel.font = [UIFont systemFontOfSize:19];
    topTitleBarLabel.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    topTitleBarLabel.shadowOffset = CGSizeMake(0.5, 0.5);
    topTitleBarLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.topTitleBarLabel = topTitleBarLabel;
    [self.view addSubview:topTitleBarLabel];
}

- (void)setupTableV
{
    UITableView *detailTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kNavBarHeight, kSWidth, kSHeight-kNavBarHeight-self.footview.height-45) style:UITableViewStylePlain];
    detailTableView.dataSource = self;
    detailTableView.delegate = self;
    detailTableView.contentInset = UIEdgeInsetsMake(KTopMainVH, 0, 0, 0);
    detailTableView.backgroundColor = [UIColor clearColor];
    detailTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    detailTableView.tableFooterView = [[UIView alloc] init];
    [self.view addSubview:detailTableView];
    self.detailTableView = detailTableView;
    [self.view insertSubview:self.detailTableView atIndex:1];
    
    [self.detailTableView registerClass:[FDQuestionsAndAnwsersPlusDetailCell class] forCellReuseIdentifier:FDQuestionsAndAnwsersPlusDetailCellId];
    
    __weak __typeof(self)weakSelf = self;
    FDRefreshHeader *header = [FDRefreshHeader headerWithRefreshingBlock:^{
        [weakSelf loadDetailData];
        [weakSelf loadDetailListData:NO];
    }];
    self.detailTableView.mj_header = header;
    // 下拉控件隐藏
    self.detailTableView.mj_header.hidden = YES;
//    [header beginRefreshing];
    
    FDRefreshFooter *footer = [FDRefreshFooter footerWithRefreshingBlock:^{
        if (self.dataSource.count)//避免网络慢时刚进去就加载更多出现数据+本身已经加载的最新数据=重复数据了
            [weakSelf loadDetailListData:YES];
    }];
    self.detailTableView.mj_footer = footer;
}

- (void)setupTopHeaderView
{
    self.headerView = [[FDQuestionsAndAnwsersPlusDetailHeaderView alloc] init];
    __weak __typeof(self)weakSelf = self;
    self.headerView.headerMoreBlock = ^(){
        // 须重新赋值给tableview
        [weakSelf refreshHeaderView];
    };
}

- (void)refreshHeaderView
{
    self.detailTableView.tableHeaderView = self.headerView;
    self.headerView = self.headerView;
}

- (void)setupTopMainV
{
    FDQuestionsAndAnwsersPlusDetailTopView *topMainView = [[FDQuestionsAndAnwsersPlusDetailTopView alloc] init];
    topMainView.frame = CGRectMake(0, kNavBarHeight, kSWidth, KTopMainVH);
    __weak __typeof(self)weakSelf = self;
    topMainView.attentionBlock = ^(UIButton *btn){
        if(![NSString isNilOrEmpty:[Global userId]])
            [weakSelf toAttention:btn];
        else
            [weakSelf toLoginWithBlock:^{
                [weakSelf toAttention:btn];
            }];
    };
    [self.view addSubview:topMainView];
    self.topMainView = topMainView;
}

- (void)setupFootV
{
    self.footview.commentBtn.hidden = YES;
    self.footview.commentLabel.hidden = YES;
    self.footview.greetBtn.hidden = YES;
    self.footview.greetLabel.hidden = YES;
    self.footview.collectBtn.hidden = YES;
    self.footview.shareBtn.x = kSWidth - 10 - self.footview.shareBtn.width;
    [self.view bringSubviewToFront:self.footview];
    
    if ([_detailModel.beginTime isLaterThanNowWithDateFormat:TimeToSeconds] || ![_detailModel.endTime isLaterThanNowWithDateFormat:TimeToSeconds]) {
        return;
    }
    
    UIImage *commentImage = [UIImage imageNamed:@"ditect_write6p"];
    UIButton *commentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat commentBtnX = CGRectGetMaxX(self.footview.backBtn.frame)+10;
    CGFloat commentBtnW = (self.footview.shareBtn.x-10)-commentBtnX;
    commentBtn.frame = CGRectMake(commentBtnX, (self.footview.height-30)/2.0f, commentBtnW, 30);
    [commentBtn setImage:commentImage forState:UIControlStateNormal];
    __weak __typeof(self)weakSelf = self;
    [commentBtn addAction:^(UIButton *btn) {
        [weakSelf toWriteComment];
    }];
    [self.footview addSubview:commentBtn];
}

- (void)setupBlankView
{
    [self.view addSubview:self.blankView];
    [self.view insertSubview:self.blankView belowSubview:self.detailTableView];
}

#pragma mark - 重写footerview的回调
- (void)goBothBack
{
    [self.detailRequest cancel];
    [self.detailListRequest cancel];
    [Global hideTip];
    if (self.navigationController.viewControllers.count > 1) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
}

- (void)shareClick
{
    if (![UIDevice networkAvailable]) {
        [Global showTipNoNetWork];
        return;
    }
    NSString *shareUrl = [NSString stringWithFormat:@"%@/askPlusColumn?newsid=%lld_%@",[AppConfig sharedAppConfig].serverIf,self.article.lastID.longLongValue, [AppConfig sharedAppConfig].sid];
    [shareCustomView shareWithContent:_detailModel.questionDescription image:[NSString stringWithFormat:@"%@@!md169", _detailModel.imgUrl] title:_detailModel.title url:shareUrl type:0 completion:^(NSString *resultJson){
       // [FounderEventRequest founderEventShareAppinit:self.article.fileId];
        //文章分享事件
       // [FounderEventRequest shareDateAnaly:self.article.fileId column:self.column.fullColumn];
    }];
}

#pragma mark - 刷新所有topUI
- (void)refreshAllTopViews
{
    // 加遮挡层，比系统自带毛玻璃效果好
    [self.topImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@@!md169", _detailModel.imgUrl]] placeholderImage:[Global getBgImage169] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//        self.topImageView.image = [UIImage boxblurImage:image withBlurNumber:0.2];
    }];
    
    
    self.topTitleBarLabel.text = _detailModel.title;
    
    self.topMainView.detailModel = self.detailModel;
    
    self.headerView.detailModel = self.detailModel;
    // 须重新赋值给tableview
    [self refreshHeaderView];
    
    [self setupFootV];
    // tableview背景颜色设为的透明，避免cell没有或少量时硬往上滚动导致顶部图片显示在tableview透明里
    [self setupBlankView];
}

#pragma mark - 写提问
- (void)toWriteComment
{
    __weak __typeof(self)weakSelf = self;
    if(![NSString isNilOrEmpty:[Global userId]])
        [self writeQuestion];
    else
        [self toLoginWithBlock:^{
            [weakSelf writeQuestion];
        }];
}

- (void)writeQuestion
{
    _commentController = [[CommentViewControllerGuo alloc] init];
    [appDelegate().window addSubview:_commentController.view];
    NSString *subTitle = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"当前问答:   ",nil),_detailModel.title];
    __weak __typeof(self)weakSelf = self;
    [_commentController setupCommentViewWith:NSLocalizedString(@"我要提问",nil) SubTitle:subTitle IsTopic:NO HandleBlock:^(NSString *askStr, NSArray *photos) {
        [weakSelf addAskQuestion:askStr];
    }];
}

#pragma mark - DataSource

- (void)downLoadData
{
    [Global showTipAlways:NSLocalizedString(@"正在加载...",nil)];
    
    [self loadDetailData];
    
    [self loadDetailListData:NO];
}

- (void)loadDetailData
{
    NSString *requestString = [NSString stringWithFormat:@"%@/api/getAskBarPlusDetail?sid=%@&aid=%ld&uid=%@", [AppConfig sharedAppConfig].serverIf, [AppConfig sharedAppConfig].sid, self.article.lastID.integerValue  ,[Global userId]];
    self.detailRequest = [[HttpRequest alloc] initWithURL:[NSURL URLWithString:requestString]];
    [self.detailRequest setValue:@"newaircloud.com" forHTTPHeaderField:@"Referer"];
    
    __weak __typeof (self)weakSelf = self;
    [self.detailRequest setCompletionBlock:^(id data) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers  error:nil];
        if ([[dict objectForKey:@"success"] boolValue]) {
            weakSelf.detailModel = [FDQuestionsAndAnwsersPlusDetailModel mj_objectWithKeyValues:dict[@"model"]];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"updateQAAArticleWithNoti"
                                                                object:weakSelf.detailModel];
            [weakSelf refreshAllTopViews];
        }
    }];
    [self.detailRequest setFailedBlock:^(NSError *error) {
        [Global showTip:NSLocalizedString(@"加载失败，请检查网络",nil)];
    }];
    [self.detailRequest startAsynchronous];
}

- (void)loadDetailListData:(BOOL)isMore
{
    if (!isMore) {
        _pageNumer = 0;
    }
    
    NSString *requestString = [NSString stringWithFormat:@"%@/api/getAskPlusQuestionList?sid=%@&askID=%ld&pageNum=%ld", [AppConfig sharedAppConfig].serverIf, [AppConfig sharedAppConfig].sid, self.article.lastID.integerValue,_pageNumer];
    self.detailListRequest = [[HttpRequest alloc] initWithURL:[NSURL URLWithString:requestString]];
    [self.detailListRequest setValue:@"newaircloud.com" forHTTPHeaderField:@"Referer"];
    
    __weak __typeof (self)weakSelf = self;
    [self.detailListRequest setCompletionBlock:^(id data) {
        NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers  error:nil];
        if ([[dataDict objectForKey:@"success"] boolValue]) {
            NSArray *list = [dataDict valueForKey:@"list"];
            NSMutableArray *listArray = [FDAskModel mj_objectArrayWithKeyValuesArray:list];
            if (listArray.count) {
                weakSelf.pageNumer++;
                [weakSelf.detailTableView.mj_footer endRefreshing];
            } else {
                [weakSelf.detailTableView.mj_footer endRefreshingWithNoMoreData];
            }
            [weakSelf.detailTableView.mj_header endRefreshing];
            if (!isMore)
                [weakSelf.dataSource removeAllObjects];
            [weakSelf.dataSource addObjectsFromArray:listArray.mutableCopy];
            
            [Global hideTip];
            [weakSelf.detailTableView reloadData];
        }else {
            if ([[dataDict objectForKey:@"msg"] isEqualToString:@"没有相关信息"])
                //表示没有数据，不是错误
                [Global hideTip];
            else
                [Global showTip:NSLocalizedString(@"加载失败",nil)];
            [weakSelf.detailTableView.mj_header endRefreshing];
            [weakSelf.detailTableView.mj_footer endRefreshing];
        }
    }];
    [self.detailListRequest setFailedBlock:^(NSError *error) {
        [Global showTip:NSLocalizedString(@"加载失败，请检查网络",nil)];
        [weakSelf.detailTableView.mj_header endRefreshing];
        [weakSelf.detailTableView.mj_footer endRefreshing];
    }];
    [self.detailListRequest startAsynchronous];
}

#pragma mark - 网络

- (void)toLoginWithBlock:(void (^)(void))block
{
    YXLoginViewController *controller = [[YXLoginViewController alloc] init];
    [controller rightPageNavTopButtons];
    controller.loginSuccessBlock = ^(){
            if (block) block();
    };
    [self presentViewController:[Global controllerToNav:controller] animated:YES completion:nil];
}

- (void)addAskQuestion:(NSString *)askStr
{
    // 若提问，默认关注此问答
    NSString *urlString = [NSString stringWithFormat:@"%@/api/addAskBarPlusQuestion", [AppConfig sharedAppConfig].serverIf];
    HttpRequest *addAskRequest = [HttpRequest requestWithURL:[NSURL URLWithString:urlString]];
    [addAskRequest setValue:@"newaircloud.com" forHTTPHeaderField:@"Referer"];
    [addAskRequest setHTTPMethod:@"POST"];
    // 评论页面中已被转义，加密时需要字符解码[askStr stringByRemovingPercentEncoding]
    NSString *sign = [AESCrypt encrypt:[NSString stringWithFormat:@"%@%@%@%@", [AppConfig sharedAppConfig].sid, [Global userId], self.detailModel.aid, [askStr stringByRemovingPercentEncoding]] password:key];
    
    NSString *bodyString = [NSString stringWithFormat:@"sid=%@&uid=%@&content=%@&askStatus=%@&aid=%ld&sign=%@",[AppConfig sharedAppConfig].sid, [Global userId], askStr, _detailModel.publishStatus, _detailModel.aid.integerValue, sign];
    [addAskRequest setHTTPBody:[bodyString dataUsingEncoding:NSUTF8StringEncoding]];
    __weak __typeof (self)weakSelf = self;
    [addAskRequest setCompletionBlock:^(NSData *data) {
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers  error:nil];
        if ([[dic objectForKey:@"success"] boolValue]) {
            if ([[dic objectForKey:@"questionStatus"] boolValue]) {
                [Global showTip:NSLocalizedString(@"您的提问提交成功",nil)];
                [weakSelf loadDetailListData:NO];
            }else {
                [Global showTip:NSLocalizedString(@"您的提问提交成功,请等待审核",nil)];
            }
            [_commentController.view removeFromSuperview];
            
        }else{
            [Global showTip:[NSString stringWithFormat:@"%@%@", NSLocalizedString(@"提问失败",nil),[dic objectForKey:@"msg"]]];
        }
    }];
    [addAskRequest setFailedBlock:^(NSError *error) {
        [Global showTipNoNetWork];
    }];
    [addAskRequest startAsynchronous];
    
    // 若提问，默认关注此问答
    _isFromAsking = YES;
    [self toAttention:_topMainView.attentionBtn];
}

- (void)toAttention:(UIButton *)attentionBtn
{
    // 先本地更新关注，网络请求结果后再实际更新关注
    attentionBtn.selected = !attentionBtn.selected;
    NSString *urlString = [NSString stringWithFormat:@"%@/api/submitAskBarPlusFollow", [AppConfig sharedAppConfig].serverIf];
    HttpRequest *addAskRequest = [HttpRequest requestWithURL:[NSURL URLWithString:urlString]];
    [addAskRequest setValue:@"newaircloud.com" forHTTPHeaderField:@"Referer"];
    [addAskRequest setHTTPMethod:@"POST"];
    NSString *sign = [AESCrypt encrypt:[NSString stringWithFormat:@"%@%@%@", [AppConfig sharedAppConfig].sid, [Global userId], self.detailModel.aid] password:key];
    NSString *bodyString = [NSString stringWithFormat:@"sid=%@&aid=%ld&uid=%@&sign=%@&type=%d",[AppConfig sharedAppConfig].sid, self.article.lastID.integerValue, [Global userId], sign, attentionBtn.selected];
    [addAskRequest setHTTPBody:[bodyString dataUsingEncoding:NSUTF8StringEncoding]];
    [addAskRequest setCompletionBlock:^(NSData *data) {
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers  error:nil];
        NSString *alertStr = attentionBtn.selected ? NSLocalizedString(@"关注",nil) : NSLocalizedString(@"取关",nil);
        if ([[dic objectForKey:@"success"] boolValue]) {
            if (_isFromAsking) {
                _isFromAsking = NO;
            }else {
                [Global showTip:[NSString stringWithFormat:@"%@%@",alertStr, NSLocalizedString(@"成功",nil)]];
            }
            // 先本地更新关注，网络请求结果后再实际更新关注
            [self loadDetailData];
        }else{
            if (_isFromAsking) {
                _isFromAsking = NO;
            }else {
                [Global showTip:[NSString stringWithFormat:@"%@%@",alertStr, NSLocalizedString(@"失败, 请重新尝试",nil)]];
            }
            [self updateAttentionBtn:attentionBtn isAttention:NO];
        }
        
    }];
    [addAskRequest setFailedBlock:^(NSError *error) {
        [Global showTipNoNetWork];
        [self updateAttentionBtn:attentionBtn isAttention:NO];
    }];
    [addAskRequest startAsynchronous];
}

- (void)updateAttentionBtn:(UIButton *)attentionBtn isAttention:(BOOL)isAttention
{
    attentionBtn.selected = isAttention;
    attentionBtn.width = 65;
}

- (void)toPraiseAnswer:(UIButton *)praiseBtn IndexPath:(NSIndexPath *)indexPath
{
    /* 点赞功能分两部分
     1.更新用户对该问答条目是否点赞(接口没有属性，本地记录)
     2.更新该问答条目点赞数目(接口有数据)
     */
    praiseBtn.selected = YES;
    FDQuestionsAndAnwsersPlusDetailCell *cell = (FDQuestionsAndAnwsersPlusDetailCell *)[self.detailTableView cellForRowAtIndexPath:indexPath];
    NSString *prasieKey = [NSString stringWithFormat:@"isPraise_%ld", cell.askModel.qid.integerValue];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:prasieKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSString *sign = [AESCrypt encrypt:[NSString stringWithFormat:@"%@%zd", [AppConfig sharedAppConfig].sid, cell.askModel.qid.integerValue] password:key];
    NSString *urlString = [NSString stringWithFormat:@"%@/api/submitAskPlusQuestionEvent", [AppConfig sharedAppConfig].serverIf];
    HttpRequest *praiseRequest = [HttpRequest requestWithURL:[NSURL URLWithString:urlString]];
    [praiseRequest setValue:@"newaircloud.com" forHTTPHeaderField:@"Referer"];
    [praiseRequest setHTTPMethod:@"POST"];
    NSString *bodyString = [NSString stringWithFormat:@"sid=%@&qid=%ld&sign=%@",[AppConfig sharedAppConfig].sid, cell.askModel.qid.integerValue, sign];
    [praiseRequest setHTTPBody:[bodyString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [praiseRequest setCompletionBlock:^(NSData *data) {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers  error:nil];
        NSString *alertStr = NSLocalizedString(@"点赞",nil);
        NSNumber *praiseCount = [dic objectForKey:@"praiseCount"];
        if (praiseCount && ![praiseCount isEqualToNumber:@0]){
            [cell updatePraiseCount:[praiseCount stringValue]];
//            cell.askModel.praiseCount = praiseCount;// 不需要
            FDAskModel *askModel = self.dataSource[indexPath.row];
            askModel.praiseCount = praiseCount;
            [self.detailTableView reloadData];
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

#pragma mark - LAyout 

- (UITableView *)detailTableView
{
    if (!_detailTableView) {
        _detailTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kNavBarHeight, kSWidth, kSHeight-kNavBarHeight) style:UITableViewStylePlain];
    }
    return _detailTableView;
}

- (UIView *)blankView
{
    if (!_blankView) {
        _blankView = [[UIView alloc] init];
        _blankView.frame = CGRectMake(0, KTopImgVH, kSWidth, self.detailTableView.height);
        _blankView.backgroundColor = [UIColor whiteColor];
    }
    return _blankView;
}

- (NSMutableArray *)dataSource
{
    if (!_dataSource) {
        _dataSource = [[NSMutableArray alloc] init];
    }
    return _dataSource;
}

- (NSMutableDictionary *)cellShowStatusDict
{
    if (!_cellShowStatusDict) {
        _cellShowStatusDict = [NSMutableDictionary dictionary];
    }
    return _cellShowStatusDict;
}

#pragma mark - UIScrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    XYLog(@"@@@contentOffset=%f",scrollView.contentOffset.y);
    
    // 取消下拉控件隐藏
    self.detailTableView.mj_header.hidden = NO;
    
    CGFloat navBarMaxH = 64;
//    CGFloat navBarH = 44;
    CGFloat topMainVH = self.view.width/2.0f - navBarMaxH;
    
    //tableview向上
    // 计算topMainView的偏移位置
    if (scrollView.contentOffset.y >= -topMainVH) {
        self.topMainView.frame = CGRectMake(0, navBarMaxH-topMainVH-scrollView.contentOffset.y, kSWidth, topMainVH);
        XYLog(@"@@@topMainView=%f",self.topMainView.y);
        if (scrollView.contentOffset.y>0) return;
        // 顶部图片下移
        /*!这句话 用【宏和变量】都有问题，计算不准确*/
        if (kSWidth == 320) {
            self.topImageView.frame = CGRectMake(0, -44+(scrollView.contentOffset.y+99)/99*44, kSWidth, self.topImageView.height);
        } else if (kSWidth == 375) {
            self.topImageView.frame = CGRectMake(0, -44+(scrollView.contentOffset.y+123.5)/123.5*44, kSWidth, self.topImageView.height);
        } if (kSWidth == 414) {
            self.topImageView.frame = CGRectMake(0, -44+(scrollView.contentOffset.y+143)/143*44, kSWidth, self.topImageView.height);
        }
        
        XYLog(@"@@@topImageView=%f",self.topImageView.y);
        // 下拉控件隐藏
        self.detailTableView.mj_header.hidden = YES;
        self.blankView.y = -scrollView.contentOffset.y + kNavBarHeight;
        XYLog(@"========blankView=%f",self.blankView.y);
    }else {
        //tableview向下直接定值各UI、避免向下滚动太快打腾腾
        self.topImageView.y = -kNavHeight;
        self.topMainView.frame = CGRectMake(0, kNavBarHeight, kSWidth, topMainVH);
        self.blankView.y = KTopImgVH;
        XYLog(@"----------blankView=%f",self.blankView.y);
    }
    // 改变topMainView的透明度
    self.topMainView.titleLable.alpha = 1 - (scrollView.contentOffset.y+topMainVH)/60.0;
    self.topMainView.alpha = 1 - (scrollView.contentOffset.y+topMainVH)/100.0;
    
    // 改变顶部文字的透明度
    self.topTitleBarLabel.alpha = (scrollView.contentOffset.y+topMainVH)/100;
    
}

@end
