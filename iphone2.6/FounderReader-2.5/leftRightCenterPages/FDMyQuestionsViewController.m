//
//  FDMyQuestionsViewController.m
//  FounderReader-2.5
//
//  Created by snitsky on 2017/3/9.
//
//

#import "FDMyQuestionsViewController.h"
#import "AppConfig.h"
#import "HttpRequest.h"
#import "Article.h"
#import "ColorStyleConfig.h"
#import "FDQuestionsAndAnwsersPlusCell.h"
#import "NewsListConfig.h"
#import "ArticleRequest.h"
#import "UIButton+Block.h"
#import "AESCrypt.h"
#import "YXLoginViewController.h"
#import "FDMyAskCell.h"
#import "FDMyAskSegmentButton.h"
#import "FDRefreshHeader.h"
#import "FDRefreshFooter.h"
#import "FDAskModel.h"
#import "FDAskCommentViewController.h"
#import "FDQuestionsAndAnwsersPlusDetailViewController.h"
#import "NSMutableAttributedString + Extension.h"

typedef NS_ENUM(NSUInteger, FDMYQASegmentType) {
    FDMYQASegmentTypeAsks,
    FDMYQASegmentTypeQestions,
};

@interface FDMyQuestionsViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSMutableArray *followedArray;
@property (strong, nonatomic) NSMutableArray *myAsksArray;

@property (strong, nonatomic) UITableView *followedTableView;
@property (strong, nonatomic) UITableView *myAsksTableView;

@property (assign, nonatomic) BOOL showSegmentView;
@property (assign, nonatomic) FDMYQASegmentType type;
@property (strong, nonatomic) UIView *segmentView;

@property (assign, nonatomic) NSUInteger myAsksPage;
@property (assign, nonatomic) NSUInteger followedPage;

@property (strong, nonatomic) HttpRequest *myAsksRequest;
@property (strong, nonatomic) HttpRequest *followedRequest;

@end

static NSString *FDQuestionsAndAnwsersPlusCellIdentifier = @"FDQuestionsAndAnwsersPlusCellIdentifier";
static NSString *FDMyAsksCellIdentifier = @"FDMyAsksCellIdentifier";
static CGFloat segmentViewHeight = 40;

@implementation FDMyQuestionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self setupNav];
    [Global showMessage:NSLocalizedString(@"正在加载...",nil) duration:60 onView:self.view];
    /* 无关注无提问才展示问答推荐页面 */
    [self loadFollowedArticles:YES isFirstLoad:YES];
    self.myAsksPage = -1;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)createRefreshHeader {
    FDRefreshHeader *header = [FDRefreshHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshHeader)];
    self.myAsksTableView.mj_header = header;
    [header beginRefreshing];
}

- (void)refreshHeader {
    if (_type == FDMYQASegmentTypeAsks) {
        [self loadMyAskArticles:YES isFirstLoad:NO];
    } else {
        [self loadFollowedArticles:YES isFirstLoad:NO];
    }
}

- (void)createRefreshFooter {
    FDRefreshFooter *footer = [FDRefreshFooter footerWithRefreshingTarget:self refreshingAction:@selector(refreshFooter)];
    self.myAsksTableView.mj_footer = footer;
}

- (void)refreshFooter {
    if (_type == FDMYQASegmentTypeAsks) {
        [self loadMyAskArticles:NO isFirstLoad:NO];
    } else {
        [self loadFollowedArticles:NO isFirstLoad:NO];
    }
}

- (void)setupMyAskTableView {
    [self.view addSubview:self.segmentView];
    [self.view addSubview:self.myAsksTableView];
    [self.myAsksTableView registerClass:[FDMyAskCell class] forCellReuseIdentifier:FDMyAsksCellIdentifier];
    [self.myAsksTableView registerClass:[FDQuestionsAndAnwsersPlusCell class] forCellReuseIdentifier:FDQuestionsAndAnwsersPlusCellIdentifier];
    [self createRefreshHeader];
    [self createRefreshFooter];
}

- (void)setupNoFollowedTableView {
    [self.view addSubview:self.followedTableView];
    
    [self.followedTableView registerClass:[FDQuestionsAndAnwsersPlusCell class] forCellReuseIdentifier:FDQuestionsAndAnwsersPlusCellIdentifier];
    [self updateRecommendArticles];
}

- (void)loadFollowedArticles:(BOOL)isRefresh isFirstLoad:(BOOL)isFirstLoad {
    if (![Global userId].length) {
        return;
    }
    if (isRefresh) {
        _followedPage = 0;
    }
    NSString *sign = [AESCrypt encrypt:[NSString stringWithFormat:@"%@%@", [AppConfig sharedAppConfig].sid, [Global userId]] password:key];
    NSString *requestString = [NSString stringWithFormat:@"%@/api/getMyAskBarPlusFollows?sid=%@&pageNum=%zd&uid=%@&sign=%@", [AppConfig sharedAppConfig].serverIf, [AppConfig sharedAppConfig].sid, _followedPage, [Global userId], sign];
    self.followedRequest = [[HttpRequest alloc] initWithURL:[NSURL URLWithString:requestString]];
    [self.followedRequest setValue:@"newaircloud.com" forHTTPHeaderField:@"Referer"];
    __weak __typeof (self)weakSelf = self;
    [self.followedRequest setCompletionBlock:^(id data) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers  error:nil];
        NSArray *listArray = [Article articlesFromArray:dict[@"list"]];
        if (listArray.count) {
            weakSelf.followedPage++;
        }
        if (isRefresh) {
            weakSelf.followedArray = nil;
        }
        [weakSelf.followedArray addObjectsFromArray:listArray.mutableCopy];
        if (isFirstLoad) {
            /* 无关注无提问才展示问答推荐页面 */
            if (listArray.count) {
                //有关注
                weakSelf.showSegmentView = YES;
                [weakSelf setupMyAskTableView];
            } else {
                //无关注
                [weakSelf loadMyAskArticles:YES isFirstLoad:YES];
            }
        } else {
            [weakSelf.myAsksTableView reloadData];
            if (!listArray.count) {
                [weakSelf.myAsksTableView.mj_footer endRefreshingWithNoMoreData];
            } else {
                [weakSelf.myAsksTableView.mj_footer endRefreshing];
            }
            [weakSelf.myAsksTableView.mj_header endRefreshing];
        }
    }];
    [self.followedRequest setFailedBlock:^(NSError *error) {
        XYLog(@"load articles failed: %@", error);
        [Global showTipNoNetWork];
        if (!isFirstLoad) {
            [weakSelf.myAsksTableView.mj_header endRefreshing];
            [weakSelf.myAsksTableView.mj_footer endRefreshing];
        }
    }];
    [self.followedRequest startAsynchronous];
}

- (void)loadMyAskArticles:(BOOL)isRefresh isFirstLoad:(BOOL)isFirstLoad{
    [Global hideTip];
    if (isRefresh) {
        _myAsksPage = 0;
    }
    NSString *sign = [AESCrypt encrypt:[NSString stringWithFormat:@"%@%@", [AppConfig sharedAppConfig].sid, [Global userId]] password:key];
    NSString *requestString = [NSString stringWithFormat:@"%@/api/getMyAskPlusQuestionList?sid=%@&pageNum=%zd&uid=%@&sign=%@", [AppConfig sharedAppConfig].serverIf, [AppConfig sharedAppConfig].sid, _myAsksPage, [Global userId], sign];
    self.myAsksRequest = [[HttpRequest alloc] initWithURL:[NSURL URLWithString:requestString]];
    [self.myAsksRequest setValue:@"newaircloud.com" forHTTPHeaderField:@"Referer"];
    __weak __typeof (self)weakSelf = self;
    [self.myAsksRequest setCompletionBlock:^(id data) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers  error:nil];
        NSMutableArray *listArray = [FDAskModel mj_objectArrayWithKeyValuesArray:dict[@"list"]];
        if (isFirstLoad) {
            if (listArray.count) {
                //有提问
                weakSelf.showSegmentView = YES;
                [weakSelf setupMyAskTableView];
            } else {
                //无提问
                weakSelf.showSegmentView = NO;
                [weakSelf setupNoFollowedTableView];
            }
        }else {
            if (listArray.count) {
                weakSelf.myAsksPage++;
                [weakSelf.myAsksTableView.mj_footer endRefreshing];
            } else {
                [weakSelf.myAsksTableView.mj_footer endRefreshingWithNoMoreData];
            }
            for (FDAskModel *model in listArray.reverseObjectEnumerator) {
                if (model.askStatus == FDAskStatusDeleted) {
                    [listArray removeObject:model];
                }
            }
            if (isRefresh) {
                weakSelf.myAsksArray = nil;
            }
            [weakSelf.myAsksArray addObjectsFromArray:listArray.mutableCopy];
            
            [weakSelf.myAsksTableView reloadData];
            [weakSelf.myAsksTableView.mj_header endRefreshing];
        }
    }];
    [self.myAsksRequest setFailedBlock:^(NSError *error) {
        XYLog(@"load articles failed: %@", error);
        [weakSelf.myAsksTableView.mj_header endRefreshing];
        [weakSelf.myAsksTableView.mj_footer endRefreshing];
        [Global showTipNoNetWork];
        
    }];
    [self.myAsksRequest startAsynchronous];
}

- (void)updateRecommendArticles {
    [Global showMessage:NSLocalizedString(@"正在加载...",nil) duration:60 onView:self.view];
    ArticleRequest *request = [ArticleRequest articleInteractionPlusRequestWithColumnId:0 LastId:0 rowNumber:0];
    __weak __typeof (self)weakSelf = self;
    [request setCompletionBlock:^(NSArray *array) {

        weakSelf.followedArray = array.mutableCopy;
        
        [weakSelf.followedTableView reloadData];
        [Global hideTip];
    }];
    [request setFailedBlock:^(NSError *error) {
        XYLog(@"load articles failed: %@", error);
        [Global showTipNoNetWork];
        
    }];
    [request startAsynchronous];
}

#pragma mark - tableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.followedTableView && !self.showSegmentView) {
        return MIN(self.followedArray.count, 5);
    }
    if (_type == FDMYQASegmentTypeAsks) {
        return self.myAsksArray.count;
    } else {
        return self.followedArray.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (tableView == self.followedTableView && !self.showSegmentView) {
        return kSWidth/3.f + 19;
    }
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (self.showSegmentView && self.type == FDMYQASegmentTypeAsks && !self.myAsksArray.count && self.myAsksPage == 0) {
        return kSHeight - kNavBarHeight - 30;
    }
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (tableView == self.followedTableView && !self.showSegmentView) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSWidth, kSWidth/3.f + 25)];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kSWidth, kSWidth/3.f)];
        imageView.image = [UIImage imageNamed:@"my_qa_banner"];
        [view addSubview:imageView];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, kSWidth/3.f, kSWidth, 25)];
        label.font = [UIFont systemFontOfSize:12];
        label.text = NSLocalizedString(@" 向您推荐:", nil);
        label.textColor = colorWithHexString(@"666666");
        [view addSubview:label];
        return view;
        
    }
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (self.showSegmentView && self.type == FDMYQASegmentTypeAsks && !self.myAsksArray.count && self.myAsksPage == 0) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSWidth, kSHeight - kNavBarHeight - 30)];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(kSWidth/2.f - 47, 90, 94, 100)];
        imageView.image = [UIImage imageNamed:@"icon_no_ask"];
        [view addSubview:imageView];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(imageView.frame) + 18, kSWidth, 14)];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = NSLocalizedString(@"您还没有进行任何提问哦~", nil);
        label.font = [UIFont systemFontOfSize:14];
        label.textColor = colorWithHexString(@"999999");
        [view addSubview:label];
        return view;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.type == FDMYQASegmentTypeAsks && self.showSegmentView == YES) {
        //我的提问
        return 164;
    } else {
        Article *article = self.followedArray[indexPath.row];
        CGFloat lineSpacing = kSWidth == 375 ||kSWidth == 414 ? 7 : 4;
        NSMutableAttributedString *string = [NSMutableAttributedString attributedStringWithString:article.title Font:[UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleCellTitleFontSize] lineSpacing:lineSpacing];
        CGFloat height = [string boundingHeightWithSize:CGSizeMake(kSWidth - 20, 0) font:[UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleCellTitleFontSize] lineSpacing:lineSpacing maxLines:2];
        if (self.showSegmentView) {
            //我的关注 隐藏下部
            return 65 + height + kSWidth/3.f;
        } else {
            //推荐
            return 90 + height + kSWidth/3.f;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.type == FDMYQASegmentTypeAsks && self.showSegmentView == YES) {
        //我的提问
        FDMyAskCell *cell = [tableView dequeueReusableCellWithIdentifier:FDMyAsksCellIdentifier];
        FDAskModel *model = self.myAsksArray[indexPath.row];
        [cell updateWithModel:model];
        return cell;
    } else {
        Article *article = [self.followedArray objectAtIndex:indexPath.row];
        FDQuestionsAndAnwsersPlusCell *cell = [tableView dequeueReusableCellWithIdentifier:FDQuestionsAndAnwsersPlusCellIdentifier];
        [cell updateCellWithArticle:article hideBottom:self.showSegmentView];
        __weak __typeof (self)weakSelf = self;
        [cell.relationButton addAction:^(UIButton *btn) {
            [weakSelf relationButtonClickForIndexPath:indexPath];
        }];
        return cell;
    }
}

- (void)relationButtonClickForIndexPath:(NSIndexPath *)indexPath {
    if ([Global userId].length) {
        //已登录
        
        Article *article = self.followedArray[indexPath.row];
        
        NSString *urlString = [NSString stringWithFormat:@"%@/api/submitAskBarPlusFollow", [AppConfig sharedAppConfig].serverIf];
        NSURL *url = [NSURL URLWithString:urlString];
        HttpRequest *request = [HttpRequest requestWithURL:url];
        [request setHTTPMethod:@"POST"];
        NSString *sign = [AESCrypt encrypt:[NSString stringWithFormat:@"%@%@%@", [AppConfig sharedAppConfig].sid, [Global userId], article.lastID] password:key];
        NSString *informString = [NSString stringWithFormat:@"sid=%@&aid=%zd&uid=%@&sign=%@&type=%d&authorID=%zd", [AppConfig sharedAppConfig].sid,article.lastID.integerValue, [Global userId],sign, !article.isFollow, article.authorID.integerValue];
        informString = [informString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSData *informData = [informString dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPBody:informData];
        __weak __typeof (self)weakSelf = self;
        [request setCompletionBlock:^(id data) {
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers  error:nil];
            if ([[dic objectForKey:@"success"] boolValue]) {
                article.isFollow = !article.isFollow;
                [weakSelf.followedTableView reloadData];
            }
        }];
        [request setFailedBlock:^(NSError *error) {
            XYLog(@"load articles failed: %@", error);
            [Global showTip:NSLocalizedString(@"修改失败",nil)];
        }];
        [request startAsynchronous];
    } else {
        //未登陆
        YXLoginViewController *controller = [[YXLoginViewController alloc]init];
        [controller rightPageNavTopButtons];
        [self presentViewController:[Global controllerToNav:controller] animated:YES completion:NULL];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.type == FDMYQASegmentTypeAsks && self.showSegmentView == YES) {
        FDAskModel *model = self.myAsksArray[indexPath.row];
        if (model.answerTime.length) {
            FDAskCommentViewController *vc = [[FDAskCommentViewController alloc] initWithAskModel:model];
            vc.hasPraiseBlock = ^(NSNumber *praiseCount) {
                model.praiseCount = praiseCount;
            };
            [self.navigationController pushViewController:vc animated:YES];
        } else {
            FDQuestionsAndAnwsersPlusDetailViewController *vc = [[FDQuestionsAndAnwsersPlusDetailViewController alloc] init];
            Article *article = [[Article alloc] init];
            article.lastID = model.aid;
            vc.article = article;
            [self.navigationController pushViewController:vc animated:YES];
        }
    } else {
        Article *article = [self.followedArray objectAtIndex:indexPath.row];
        FDQuestionsAndAnwsersPlusDetailViewController *vc = [[FDQuestionsAndAnwsersPlusDetailViewController alloc] init];
        vc.article = article;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (UIView *)segmentView {
    if (!_segmentView) {
        _segmentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSWidth, segmentViewHeight)];
        FDMyAskSegmentButton *leftBtn = [[FDMyAskSegmentButton alloc] initWithFrame:CGRectMake(0, 0, kSWidth/2.f, segmentViewHeight)];
        leftBtn.selected = YES;
        [leftBtn setTitle:NSLocalizedString(@"我的提问", nil) forState:UIControlStateNormal];
        leftBtn.tag = 10001;
        [_segmentView addSubview:leftBtn];
        [leftBtn addTarget:self action:@selector(segmentButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        FDMyAskSegmentButton *rightBtn = [[FDMyAskSegmentButton alloc] initWithFrame:CGRectMake(kSWidth/2.f, 0, kSWidth/2.f, segmentViewHeight)];
        [rightBtn setTitle:NSLocalizedString(@"我的关注", nil) forState:UIControlStateNormal];
        rightBtn.tag = 10002;
        [rightBtn addTarget:self action:@selector(segmentButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_segmentView addSubview:rightBtn];
        
    }
    return _segmentView;
}

- (void)segmentButtonAction:(UIButton *)sender {
    if (sender.selected) {
        return;
    }
    if (sender.tag == 10001) {
        //我的提问
        UIButton *rightBtn = [self.segmentView viewWithTag:10002];
        sender.selected = YES;
        rightBtn.selected = NO;
        self.type = FDMYQASegmentTypeAsks;
        [self.followedRequest cancel];
    } else {
        //我的关注
        UIButton *rightBtn = [self.segmentView viewWithTag:10001];
        sender.selected = YES;
        rightBtn.selected = NO;
        self.type = FDMYQASegmentTypeQestions;
        [self.myAsksRequest cancel];
    }
    [self.myAsksTableView.mj_header endRefreshing];
    [self.myAsksTableView reloadData];
}

- (NSMutableArray *)followedArray {
    if (!_followedArray) {
        _followedArray = [NSMutableArray array];
    }
    return _followedArray;
}


- (NSMutableArray *)myAsksArray {
    if (!_myAsksArray) {
        _myAsksArray = [NSMutableArray array];
    }
    return _myAsksArray;
}

- (UITableView *)followedTableView {
    if (!_followedTableView) {
        _followedTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kSWidth, kSHeight - kNavBarHeight) style:UITableViewStyleGrouped];
        _followedTableView.delegate = self;
        _followedTableView.dataSource = self;
        _followedTableView.tableFooterView = [[UIView alloc] init];
        _followedTableView.backgroundColor = [UIColor colorWithRed:237/255.f green:237/255.f blue:237/255.f alpha:1];
        _followedTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _followedTableView;
}

- (UITableView *)myAsksTableView {
    if (!_myAsksTableView) {
        _myAsksTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, segmentViewHeight, kSWidth, kSHeight - kNavBarHeight - segmentViewHeight) style:UITableViewStylePlain];
        _myAsksTableView.delegate = self;
        _myAsksTableView.dataSource = self;
        _myAsksTableView.tableFooterView = [[UIView alloc] init];
        _myAsksTableView.backgroundColor = [UIColor colorWithRed:237/255.f green:237/255.f blue:237/255.f alpha:1];
        _myAsksTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _myAsksTableView;
}

- (void)setupNav {
    self.title = NSLocalizedString(@"我的问答", nil);
    // 设置导航默认标题的颜色及字体大小
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [ColorStyleConfig sharedColorStyleConfig].navbar_titlecolor_didselect,NSFontAttributeName : [UIFont boldSystemFontOfSize:18]};
    
    UIButton *preBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    preBtn.tag = 111;
    [preBtn setImage:[UIImage imageNamed:@"nav_bar_back"] forState:UIControlStateNormal];
    [preBtn sizeToFit];
    preBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    preBtn.contentEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
    [preBtn addTarget:self action:@selector(goPrePage) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:preBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    // leftBarButtonItem点击范围太大，点击“我的提问”容易触碰leftBarButtonItem返回
    UIView *view = [[UIView alloc] init];
    view.frame = CGRectMake(20 + preBtn.frame.size.width, 0, 60, 44);
    [self.navigationController.navigationBar addSubview:view];
}

- (void)goPrePage {
    [self dismissViewControllerAnimated:YES completion:nil];
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
