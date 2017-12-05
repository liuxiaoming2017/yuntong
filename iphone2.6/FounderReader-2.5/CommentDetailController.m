//
//  CommentDetailController.m
//  FounderReader-2.5
//
//  Created by 袁野 on 15/9/4.
//
//

#import "CommentDetailController.h"
#import "CommentConfig.h"
#import "GreatestCommentCell.h"
#import "UserAccountDefine.h"
#import "GreatestCommentPageController.h"
#import "AppConfig.h"
#import "HttpRequest.h"
#import "FCReader_OpenUDID.h"
#import "YXLoginViewController.h"
#define iOSVersion [[[UIDevice currentDevice] systemVersion] floatValue]
@interface CommentDetailController ()<UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate>
@property (nonatomic,retain)UITableView *table;
@property (nonatomic,assign)NSInteger startCount;
@end

@implementation CommentDetailController
@synthesize comment,comments,RootComments,comment2Index;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.startCount = 10;
    [self getNetstatusHot];
    UITableView *table = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, kSWidth, kSHeight - 64)];
    self.table = table;
    table.delegate = self;
    table.dataSource = self;
    table.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self addHeadView];
    [self.view addSubview:table];
    
    [self addFootView];
    
    }
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == [comments count]) {
        [self loadMoreComments];
        UITableViewCell *moreCell = [tableView dequeueReusableCellWithIdentifier:@"MoreCell"];
        if (moreCell == nil)
            moreCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MoreCell"];
        moreCell.backgroundColor = [UIColor clearColor];
        moreCell.textLabel.textAlignment = NSTextAlignmentCenter;
        moreCell.textLabel.text =  @"加载更多";
        moreCell.textLabel.textColor = [CommentConfig sharedCommentConfig].moreCellTitleColor;
        moreCell.textLabel.font = [UIFont boldSystemFontOfSize:[CommentConfig sharedCommentConfig].moreCellTitleFontSize];
        UIActivityIndicatorView *little = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(100, 15, 30, 20)];
        little.color = [UIColor grayColor];
        [little startAnimating];
        [moreCell.contentView addSubview:little];
        return moreCell;
    }

    NSString *reuseId = @"ID";
    //  查找空闲的cell
//    GreatestCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
//    if (cell == nil)
       GreatestCommentCell *cell = [[GreatestCommentCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseId];
    
    comment = self.comments[indexPath.row];
    cell.userNameLabel.text = comment.userName;
    NSString *timeStr = [comment.commentTime substringWithRange:NSMakeRange(5, 11)];
    cell.timeLabel.text = timeStr;
    cell.contentLabel.text = comment.content;
    cell.contentLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
    NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:13], NSFontAttributeName,nil];
    CGSize size = [comment.content boundingRectWithSize:CGSizeMake(220, 300) options:NSStringDrawingUsesLineFragmentOrigin attributes:tdic context:nil].size;
    
    CGFloat contentY = CGRectGetMaxY(cell.timeLabel.frame) + 10;
    CGRect rect = CGRectMake(71, contentY, size.width, size.height);
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.contentLabel.frame = rect;
    
    cell.greatButton.hidden = YES;
    cell.greatCountLabel.hidden = YES;
    cell.handIconImageView.hidden = YES;
    
    
    if (indexPath.row != 0) {
        UIView *footview =  [[UIView alloc]initWithFrame:CGRectMake(10, 0, kSWidth - 20, 1)];
        [footview setBackgroundColor:[UIColor colorWithRed:221/255.0 green:221/255.0 blue:221/255.0 alpha:1.0]];
        [cell addSubview:footview];
    }

    return cell;
}
//
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == [self.comments count])
        return 50;
    
    CommentConfig *config = [CommentConfig sharedCommentConfig];
    comment = [self.comments objectAtIndex:indexPath.row];
    NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:config.contentFontSize], NSFontAttributeName,nil];
    CGSize size = [comment.content boundingRectWithSize:CGSizeMake(self.view.frame.size.width-config.cellEdge.left-config.cellEdge.right, 10000000) options:NSStringDrawingUsesLineFragmentOrigin attributes:tdic context:nil].size;
    

    float height = size.height + 18 + 34+ 27;
    return height;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.comments.count + hasMore ;

}
/**
 *  添加头部视图
 */
- (void)addHeadView{
    UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kSWidth,64)];
    bgView.backgroundColor = [UIColor whiteColor];
    UIView *red = [[UIView alloc]initWithFrame:CGRectMake(0, 63, kSWidth, 0.7)];
    red.alpha = 0.6;
    red.backgroundColor = [UIColor redColor];
    [bgView addSubview:red];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(kSWidth *0.5-50, 26, 100, 24)];
    label.text = @"追问";
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:13];
    [label setTextColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0]];
    [bgView addSubview:label];
    [self.view addSubview:bgView];

}

/**
 *  添加底部返回按钮
 */
- (void )addFootView{
    UIButton *back = [[UIButton alloc]initWithFrame:CGRectMake(10, kSHeight - 45, 35, 35)];
    [back setImage:[UIImage imageNamed:@"btn-comment-back"] forState:UIControlStateNormal];
    [back addTarget:self action:@selector(commentbackClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:back];
}
/**
 *  返回按钮点击
 *
 *  @param btn 点击button
 */
- (void)commentbackClick:(UIButton *)btn{
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 *  请求网络数据
 */
- (void)getNetstatusHot{
    Comment *temp = [RootComments objectAtIndex:comment2Index];
    NSString *urlString = [NSString stringWithFormat:@"%@/discussReply?id=%zd&start=0&type=1&count=10",[AppConfig sharedAppConfig].serverIf,temp.ID];

    HttpRequest *request = [HttpRequest requestWithURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"GET"];
    [request setCompletionBlock:^(NSData *data) {
        NSArray *dic1 = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers  error:nil];
        hasMore = [[dic1 valueForKey:@"hasMore"] boolValue];
        NSArray *dic = [dic1 valueForKey:@"list"];
        comments = [Comment commentsFromArray:dic];
        [self.table reloadData];
    }];
    [request setFailedBlock:^(NSError *error) {
        NSLog(@"获取评论数失败: %@", error);
    }];
    
    [request startAsynchronous];
}
/**
 *  加载更多评论
 */
- (void)loadMoreComments
{
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    // 注意：只有非根控制器才有滑动返回功能，根控制器没有。
    // 判断导航控制器是否只有一个子控制器，如果只有一个子控制器，肯定是根控制器
    if (self.childViewControllers.count == 1) {
        // 表示用户在根控制器界面，就不需要触发滑动手势，
        return NO;
    }
    return YES;
}
@end
