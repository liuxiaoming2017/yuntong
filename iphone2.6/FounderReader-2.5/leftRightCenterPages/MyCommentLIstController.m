//
//  MyCommentLIstController.m
//  FounderReader-2.5
//
//  Created by ld on 15-2-5.
//
//

#import "MyCommentLIstController.h"
#import "Comment.h"
#import "MoreCell.h"
#import "UIDevice-Reachability.h"
#import "TemplateDetailPageController.h"
#import "TemplateNewDetailViewController.h"
#import "NewsListConfig.h"
#import "AppStartInfo.h"
#import "UIView+Extention.h"
#import "HttpRequest.h"
#import "CommentConfig.h"
#import "MyCommentCell.h"
#import "MyCommentModel.h"
#import "MyForums.h"
#import "AppConfig.h"
#import "SeeRootViewController.h"
#import "NewsDetailPageController.h"
#import "ImageDetailPageController.h"
#import "ColumnBarConfig.h"
#import "ArticleRequest.h"
#import "NewsCellUtil.h"
#import "ColorStyleConfig.h"
#import "FDAskCommentViewController.h"
#import "FDTopicContentDetailViewController.h"
#import "Enum.h"
#import "FDAskModel.h"

#define FORUM_NUM 20

@interface MyCommentLIstController ()<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate,UIGestureRecognizerDelegate>
@property (nonatomic,retain)NSMutableArray *dataArray;
@property (nonatomic,retain)UITableView *tableView;
@property (nonatomic,assign)BOOL hasMore;


@end

@implementation MyCommentLIstController
@synthesize dataArray,tableView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addBodyView];
    [self getCommentList];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupNav];
    dataArray = [[NSMutableArray alloc] init];
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}
-(void)setupNav
{
    self.title = NSLocalizedString(@"我的评论",nil);
    // 设置导航默认标题的颜色及字体大小
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[ColorStyleConfig sharedColorStyleConfig].navbar_titlecolor_didselect,
                                                                    NSFontAttributeName : [UIFont boldSystemFontOfSize:18]};
    
    UIButton *preBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    preBtn.tag = 111;
    [preBtn setImage:[UIImage imageNamed:@"nav_bar_back"] forState:UIControlStateNormal];
    [preBtn sizeToFit];
    preBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    preBtn.contentEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
    [preBtn addTarget:self action:@selector(goBackPageBack) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:preBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
}
/**
 *  添加主体控件
 */
-(void)addBodyView{
    
    tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kSWidth, kSHeight) style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorColor = [UIColor lightGrayColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor whiteColor];
    [self.tableView setTableFooterView:[[UIView alloc] init]];
    [self.view addSubview:self.tableView];
}

- (void)goBackPageBack
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == self.dataArray.count) {
        return [NewsListConfig sharedListConfig].moreCellHeight;
    }
    
    MyForums *model = self.dataArray[indexPath.row];
    NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:17*kScale], NSFontAttributeName,nil];
    CGSize size = [model.content boundingRectWithSize:CGSizeMake(kSWidth-60, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading attributes:tdic context:nil].size;
    CGFloat cellHight = size.height + 100;
    return cellHight ;
    
}

- (void)tableView:(UITableView *)sender didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (self.dataArray.count > indexPath.row) {
        MyCommentModel *content = self.dataArray[indexPath.row];
        if (content.articleType == ArticleType_QAAPLUS ) {
            FDAskModel *model = [[FDAskModel alloc]init];
            model.qid = @(content.topicID);
            FDAskCommentViewController * askVC = [[FDAskCommentViewController alloc] initWithAskModel:model];
            [self.navigationController pushViewController:askVC animated:YES];
        }else if(content.articleType == ArticleType_TOPICPLUS){
            FDTopicContentDetailViewController * topicDetailVC = [[FDTopicContentDetailViewController alloc]initWithDiscussID:@(content.topicID) IsFromTopicDetailColumn:NO];
            [self.navigationController pushViewController:topicDetailVC animated:YES];
         }else{
            
        }
//        [NewsCellUtil clickNewsCell:article column:[[Column alloc] init] in:self];
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.dataArray.count == 0) {
        return 0;
    }
    return self.dataArray.count+self.hasMore;
}

- (UITableViewCell *)tableView:(UITableView *)sender cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TableViewCell *cell = nil;
    if (indexPath.row == self.dataArray.count)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"MoreCell"];
        if (cell == nil)
            cell = [[MoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MoreCell"] ;
        cell.tag = 200;
        [cell configWithTitle:@"" summary:@"" date:@"" thumbnailUrl:@"" columnId:0];
        return cell;
    }
    else
    {
        MyCommentCell* cell = [tableView dequeueReusableCellWithIdentifier:@"mycommentCell"];
        if (self.dataArray.count > 0) {
            MyCommentModel *model = self.dataArray[indexPath.row];
            cell = [[MyCommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"mycommentCell" Forum:model] ;
            cell.backgroundColor = [UIColor clearColor];
        }
        UIImageView *selectedImageView = [[UIImageView alloc] initWithFrame:cell.bounds];
        selectedImageView.backgroundColor = [UIColor colorWithRed:0xe8/255.0 green:0xe8/255.0 blue:0xe8/255.0 alpha:1];
        cell.selectedBackgroundView = selectedImageView ;
        return cell;
        
    }
}

/**
 *  获取网络数据
 */
- (void)getCommentList
{
    NSString *myCommentUrl = [NSString stringWithFormat:@"%@/api/getMyComment?sid=%@&userID=%@&rowNumber=0",[AppConfig sharedAppConfig].serverIf,[AppConfig sharedAppConfig].sid,[Global userId]];
    FileLoader *request = [FileLoader fileLoaderWithUrl:[myCommentUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [request setCompletionBlock:^(NSData *data) {
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers  error:nil];
        NSArray *list = [dic objectForKey:@"list"];
        if (list.count >0) {
            self.hasMore = YES;
        }else
            self.hasMore = NO;
        
        for (NSDictionary *dict in list) {
            MyCommentModel *news = [MyCommentModel forumWithDict:dict];
            [self.dataArray addObject:news];
        }
        
        if (self.dataArray.count == 0) {
            [self noDataShow];
        }
        [self.tableView reloadData];
    }];
    
    [request setFailedBlock:^(NSError *error) {
        [self noDataShow];
        [self.tableView reloadData];
        
    }];
    
    [request startAsynchronous];
}

/**
 *  加载更多
 *
 *  @param count 从哪一条开始
 */
- (void)loadMoreComment:(NSInteger)count
{
    NSString *myCommentUrl = [NSString stringWithFormat:@"%@/api/getMyComment?sid=%@&userID=%@&rowNumber=%lu",[AppConfig sharedAppConfig].serverIf,[AppConfig sharedAppConfig].sid,[Global userId], (unsigned long)self.dataArray.count];
    FileLoader *request = [FileLoader fileLoaderWithUrl:[myCommentUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    [request setCompletionBlock:^(NSData *data) {
        
        NSArray *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers  error:nil];
        NSArray *list = [dic valueForKey:@"list"];
        
        if (list.count >0) {
            self.hasMore = YES;
        }else
        {
            self.hasMore = NO;
        }
        
        for (NSDictionary *dict in list) {
            MyCommentModel *news = [MyCommentModel forumWithDict:dict];
            [self.dataArray addObject:news];
        }
        [self.tableView reloadData];
    }];
    [request setFailedBlock:^(NSError *error) {
    }];
    [request startAsynchronous];
}
/**
 *  没数据时显示
 */
-(void)noDataShow
{
    UIImageView *img = [[UIImageView alloc]init];
    img.frame = CGRectMake(kSWidth * 0.5, 160, 50*proportion, 50*proportion);
    CGPoint poin = CGPointMake(kSWidth * 0.5, 160*proportion + 64);
    img.center = poin;
    img.image = [UIImage imageNamed:@"holdIMG"];
    [self.view addSubview:img];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(img.frame) + 20, kSWidth, 20)];
    label.font = [UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleCellTitleFontSize];
    label.text = NSLocalizedString(@"您还没有任何评论哦!",nil);
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor grayColor];
    [self.view addSubview:label];
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (200 == cell.tag){
        if (![UIDevice networkAvailable]) {
            return;
        }
        if ([cell respondsToSelector:@selector(showIndicator)]) {
            [(MoreCell *)cell showIndicator];
        }
        [self loadMoreComment:self.dataArray.count];
    }
}

@end
