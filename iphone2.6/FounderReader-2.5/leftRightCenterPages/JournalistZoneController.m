//
//  JournalistZoneController.m
//  FounderReader-2.5
//
//  Created by xhby on 15/10/21.
//
//

#import "JournalistZoneController.h"
#import "NewsListConfig.h"
#import "MiddleCell.h"
#import "UIView+Extention.h"
#import "AppConfig.h"
#import <ShareSDK/ShareSDK.h>
#import "HttpRequest.h"
#import "UserAccountDefine.h"
#import "FileLoader.h"
#import "Article.h"
#import "CommentConfig.h"
#import "SpecialNewsPageController.h"
#import "ImageDetailPageController.h"
#import "TemplateDetailPageController.h"
#import "AppStartInfo.h"
#import "YXLoginViewController.h"
#import "TableViewCell.h"
#import "MoreCell.h"
#import "UIDevice-Reachability.h"

#define FORUM_NUM 20
@interface JournalistZoneController ()<UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate>
@property (nonatomic,retain)UITableView *tableView;

@property (nonatomic,retain)UIButton *imgright;
@property (nonatomic,assign)BOOL hasMore;
@property (nonatomic,retain)NSArray *articles;

@end

@implementation JournalistZoneController
@synthesize userPhoto,userName,articleNum,job,fansNum,imgright,author,articles;

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    [self addTopView];
    [self addBody];
    [self getNetstats];
    [self getlist];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
    {
        [self addGesture];
    }

}
- (void)addTopView{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kSWidth, 64)];
    view.backgroundColor = [UIColor whiteColor];
    
    UILabel *titleLable = [[UILabel alloc]initWithFrame:CGRectMake(kSWidth * 0.5 - 40, 28, 80, 30)];
    titleLable.font = [UIFont boldSystemFontOfSize:18];
    titleLable.text = @"记者空间";
    titleLable.textAlignment = NSTextAlignmentCenter;
    titleLable.textColor = [UIColor blackColor];
    [view addSubview:titleLable];
    
    
    UIImage *leftImage = [UIImage imageNamed:@"Policebackpress"];
    UIButton *backBtn = [[UIButton alloc]init];
    backBtn.frame =CGRectMake(15, 22, 40, 40);
    backBtn.centerY = titleLable.centerY;
    [backBtn setImage:leftImage forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(zonebackClick:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:backBtn];

    
    UIView *top = [[UIView alloc]initWithFrame:CGRectMake(0, 63.4, kSWidth, 0.6)];
    top.backgroundColor = [UIColor grayColor];
    [view addSubview:top];
    [self.view addSubview:view];

}
- (void)addBody{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,64, kSWidth, self.view.bounds.size.height - 64) style:UITableViewStylePlain];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor colorWithRed:0xED/255.0 green:0xED/255.0 blue:0xED/255.0 alpha:1];
    _tableView.separatorColor = [UIColor lightGrayColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    [self addHeaderView];
}
- (void)addHeaderView{
   
    UIView *headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kSWidth, 140*proportion)];
//    headView.backgroundColor = UIColorFromString(@"19,175,253");
    UIImageView *bgimage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, kSWidth, headView.frame.size.height)];
    bgimage.image = [UIImage imageNamed:@"bg_banner"];
    [headView addSubview:bgimage];

    
    _tableView.tableHeaderView = headView;
    //头像
    userPhoto = [[ImageViewCf alloc]initWithFrame:CGRectMake(29*proportion, 23*proportion, 58*proportion, 58*proportion)];
    userPhoto.layer.cornerRadius = 58*proportion*0.5;
    userPhoto.layer.borderWidth = 1.5;
    userPhoto.layer.borderColor = [UIColor whiteColor].CGColor;
    
    userPhoto.layer.masksToBounds = YES;
    [userPhoto setDefaultImage:[UIImage imageNamed:@"icon-user"]];
    [userPhoto setUrlString:author.authorImageUrl];

    [headView addSubview:userPhoto];
    //左侧图片
    UIImage *img = [UIImage imageNamed:@"journalistLeft"];
    UIImageView *imgleft = [[UIImageView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(userPhoto.frame)+10, 30, 20)];

    imgleft.image = img;
    imgleft.contentMode = UIViewContentModeScaleAspectFit;
    [headView addSubview:imgleft];

    //右上图片
    imgright = [[UIButton alloc]initWithFrame:CGRectMake(kSWidth - 65*proportion , 10, 65*proportion, 18*proportion)];
    [imgright setBackgroundImage:[UIImage imageNamed:@"bg_journalist"] forState:UIControlStateNormal];
    imgright.userInteractionEnabled = YES;
    if (self.author.isAttention) {
        imgright.selected = NO;
    }else
    {
        imgright.selected = YES;
    }
    [imgright setTitle:@"取消关注" forState:UIControlStateNormal];
    [imgright setTitle:@"添加关注" forState:UIControlStateSelected];

    [imgright setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, -5)];
    [imgright setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [imgright addTarget:self action:@selector(attentionButton:) forControlEvents:UIControlEventTouchUpInside];
    imgright.titleLabel.font = [UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleCellDateFontSize+1];
    
    [headView addSubview:imgright];
    //右下图片
    UIImageView *imgrightdown = [[UIImageView alloc]initWithFrame:CGRectMake(kSWidth - 50 , headView.frame.size.height - 30, 50, 20)];
    imgrightdown.image = [UIImage imageNamed:@"journalistRight"];
    imgrightdown.contentMode = UIViewContentModeScaleAspectFit;
    [headView addSubview:imgrightdown];

    //右下文字
    UILabel *rightdown = [[UILabel alloc]initWithFrame:CGRectMake(kSWidth - 245*proportion ,imgrightdown.frame.origin.y, 190*proportion, 20)];
    rightdown.centerY = imgrightdown.centerY;
    rightdown.font = [UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleActiveCellDateFontSize+1];
    rightdown.textColor = [UIColor whiteColor];
    rightdown.text = author.authorDescription;
    rightdown.textAlignment = NSTextAlignmentRight;
    [headView addSubview:rightdown];

    //用户名
    userName = [[UILabel alloc]initWithFrame:CGRectMake(userPhoto.frame.origin.x ,CGRectGetMaxY(userPhoto.frame) +10, 80, 20)];
    userName.centerX = userPhoto.centerX;
    userName.font = [UIFont systemFontOfSize:[NewsListConfig sharedListConfig].leftUserNameFontSize];
    userName.textColor = [UIColor whiteColor];
    userName.text = author.authorName;
    userName.textAlignment = NSTextAlignmentCenter;
    [headView addSubview:userName];
    //职位
    job = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(userName.frame)+7 ,userName.frame.origin.y, 180*proportion, 18)];
    job.centerY = userName.centerY;
    job.font = [UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleActiveCellDateFontSize+1];
    job.textAlignment = NSTextAlignmentLeft;
    job.textColor = UIColorFromString(@"255,243,50");
    job.text = author.authorDuty;
    [headView addSubview:job];
    //文章数
    articleNum = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(userPhoto.frame)+29*proportion, userPhoto.frame.origin.y +10*proportion, 60, 20)];
    articleNum.font = [UIFont systemFontOfSize:[NewsListConfig sharedListConfig].leftUserNameFontSize];
    articleNum.textColor = [UIColor whiteColor];
    articleNum.text = @"0";
    articleNum.textAlignment = NSTextAlignmentCenter;
    [headView addSubview:articleNum];
    UILabel *temp = [[UILabel alloc]initWithFrame:CGRectMake(articleNum.frame.origin.x, CGRectGetMaxY(articleNum.frame)+7*proportion, articleNum.frame.size.width, 18)];
    temp.font = [UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleActiveCellDateFontSize+1];
    temp.textColor = [UIColor whiteColor];
    temp.text = @"文章";
    temp.textAlignment = NSTextAlignmentCenter;
    [headView addSubview:temp];

    //分割线
    UIView *seq = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(articleNum.frame)+ 10, articleNum.frame.origin.y, 1, 25*proportion)];
    seq.centerY = userPhoto.centerY;
    seq.backgroundColor = [UIColor whiteColor];
    [headView addSubview:seq];
    
    //粉丝数
    fansNum = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(seq.frame)+10, articleNum.frame.origin.y, articleNum.frame.size.width, articleNum.frame.size.height)];
    fansNum.font = [UIFont systemFontOfSize:[NewsListConfig sharedListConfig].leftUserNameFontSize];
    fansNum.textColor = [UIColor whiteColor];
    fansNum.text = @"0";
    fansNum.textAlignment = NSTextAlignmentCenter;
    [headView addSubview:fansNum];
    UILabel *fanstemp = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(articleNum.frame), CGRectGetMaxY(articleNum.frame)+7*proportion, articleNum.frame.size.width, 18)];
    fanstemp.font = [UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleActiveCellDateFontSize+1];
    fanstemp.centerX = fansNum.centerX;
    fanstemp.textColor = [UIColor whiteColor];
    fanstemp.text = @"粉丝";
    fanstemp.textAlignment = NSTextAlignmentCenter;
    [headView addSubview:fanstemp];

}
- (void)zonebackClick:(UIButton *)btn{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)attentionButton:(UIButton *)sender{
    NSString *userid = [Global userId];
    if (!userid.length) {
        [self showLoginPage];
        return;
    }
    sender.selected = !sender.isSelected;
//    if (self.author.isAttention) {
        if (sender.selected) {
        [self cancelAttention];
    }else
        [self postAttention];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == articles.count) {
        return [NewsListConfig sharedListConfig].moreCellHeight;
    }
    Article *article = [articles objectAtIndex:indexPath.row];
    if (article.isBigPic == 1)
    {
        return 248*proportion;
    }
    return [NewsListConfig sharedListConfig].middleCellHeight;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return articles.count + self.hasMore;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
     TableViewCell *cell = nil;
    if (indexPath.row == articles.count ) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"MoreCell"];
        if (cell == nil)

        cell = [[MoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MoreCell"];

        cell.tag = 200;
        [cell configWithTitle:@"" summary:@"" date:@"" thumbnailUrl:@"" columnId:0];
        
    }
    else{
        if (articles.count>0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"listCell"];
            if (cell == nil)

            cell = [[MiddleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"listCell"];

    
            Article *article = [articles objectAtIndex:indexPath.row];
       
            if (article.isBigPic == 1)
            {//大图
                cell = [tableView dequeueReusableCellWithIdentifier:@"BigPicMiddleCell"];
                
                if (cell == nil)

                cell = [[MiddleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"BigPicMiddleCell"];


                [cell configBigimageWithArticle:article];
            }else
                [cell configMiddleCellWithArticle:article];

            cell.backgroundColor = [UIColor clearColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
        }
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row == articles.count) {
        return;
    }
    Article *currentArticle = [articles objectAtIndex:indexPath.row];
    if(currentArticle.articleType == ArticleType_IMAGE){
        ImageDetailPageController *controller = [[ImageDetailPageController alloc] init];
        controller.articles = articles;
        controller.isNavGoback = YES;
        controller.currentIndex = (int)indexPath.row;
        [self.navigationController pushViewController:controller animated:YES];

    }
    else{
        
        TemplateDetailPageController *controller = [[TemplateDetailPageController alloc] init];
        controller.articles =  [NSArray arrayWithObject:currentArticle];
        controller.isNavGoback = YES;
        controller.currentIndex = 0;
        [self.navigationController pushViewController:controller animated:YES];

    }
}
- (void)getNetstats
{
    NSString *myCommentUrl = [NSString stringWithFormat:@"%@/authorCount?id=%ld",[AppConfig sharedAppConfig].serverIf,(long)self.author.authorId];
    FileLoader *request = [FileLoader fileLoaderWithUrl:[myCommentUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    request.ifCache = YES;
    [request setCompletionBlock:^(NSData *data) {
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:nil error:nil];
        articleNum.text = [NSString stringWithFormat:@"%@",[dic valueForKey:@"countArticle"]];
        fansNum.text = [NSString stringWithFormat:@"%@",[dic valueForKey:@"countFan"]];
    }];
    
    [request setFailedBlock:^(NSError *error) {
        
    }];
    
    [request startAsynchronous];
}
- (void)cancelAttention
{
     NSString *userid = [Global userId];
    //myAuthorCancel(请求方式post)
    NSString *myCommentUrl = [NSString stringWithFormat:@"%@/myAuthorCancel",[AppConfig sharedAppConfig].serverIf];
    NSString *bodyString = [NSString stringWithFormat:@"siteID=%d&userID=%@&authorID=%zd",[AppStartInfo sharedAppStartInfo].siteId,userid,self.author.authorId];
    
    HttpRequest *request = [HttpRequest requestWithURL:[NSURL URLWithString:[myCommentUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[bodyString dataUsingEncoding:NSUTF8StringEncoding]];
    [request setCompletionBlock:^(NSData *data) {
        
        [self getNetstats];
    }];
    
    [request setFailedBlock:^(NSError *error) {
        
    }];
    [request startAsynchronous];
}

- (void)postAttention
{
     NSString *userid = [Global userId];
    if (userid == 0) {
        [self showLoginPage];
        return;
    }
    
    NSString *myCommentUrl = [NSString stringWithFormat:@"%@/myAuthor",[AppConfig sharedAppConfig].serverIf];
    NSString *bodyString = [NSString stringWithFormat:@"siteID=%d&userID=%@&authorID=%zd&userName=test&authorName=%@",[AppStartInfo sharedAppStartInfo].siteId,userid,self.author.authorId,self.author.authorName];
    
    HttpRequest *request = [HttpRequest requestWithURL:[NSURL URLWithString:[myCommentUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[bodyString dataUsingEncoding:NSUTF8StringEncoding]];
    [request setCompletionBlock:^(NSData *data) {
        [self getNetstats];
    }];
    
    [request setFailedBlock:^(NSError *error) {
        
    }];
    [request startAsynchronous];
}


- (void)getlist
{
    NSString *myCommentUrl = [NSString stringWithFormat:@"%@/authorArticles?id=%ld&start=%d&count=%d&lastFileId=0",[AppConfig sharedAppConfig].serverIf,(long)self.author.authorId,0,FORUM_NUM];
    FileLoader *request = [FileLoader fileLoaderWithUrl:[myCommentUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    request.ifCache = YES;
    [request setCompletionBlock:^(NSData *data) {
        
        NSArray *dic = [NSJSONSerialization JSONObjectWithData:data options:nil error:nil];
        if (dic.count > 0) {
            self.hasMore = YES;
        }else
            self.hasMore = NO;
        articles = [Article articlesFromArray:dic];

        [_tableView reloadData];
    }];
    [request setFailedBlock:^(NSError *error) {
        
    }];
    [request startAsynchronous];
}
- (void)loadMorelist:(NSInteger)startCount
{
   Article *article = [articles lastObject];
    NSString *myCommentUrl = [NSString stringWithFormat:@"%@/authorArticles?id=%ld&start=%zd&count=%d&lastFileId=%d",[AppConfig sharedAppConfig].serverIf,(long)self.author.authorId,startCount,FORUM_NUM,article.fileId];
    FileLoader *request = [FileLoader fileLoaderWithUrl:[myCommentUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    [request setCompletionBlock:^(NSData *data) {
        
        NSArray *arr = [NSJSONSerialization JSONObjectWithData:data options:nil error:nil];
        if (arr.count >0) {
            self.hasMore = YES;
        }else
        {
            self.hasMore = NO;
        }
        NSArray *temparr = [Article articlesFromArray:arr];
        
        NSMutableArray *tmpArray = [[NSMutableArray alloc]initWithArray:articles];
        [tmpArray addObjectsFromArray:temparr];
        articles = tmpArray;
        [self.tableView reloadData];
    }];
    
    [request setFailedBlock:^(NSError *error) {
        NSLog(@"%@",error);
    }];
    
    [request startAsynchronous];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (cell.tag == 200) {
        
        if (![UIDevice networkAvailable]) {
            return;
        }
        if ([cell respondsToSelector:@selector(showIndicator)]) {
            [(MoreCell *)cell showIndicator];
        }
        [self loadMorelist:self.articles.count];
    }
}

-(void)showLoginPage
{
    YXLoginViewController *controller = [[YXLoginViewController alloc]init];
    [controller leftNavBackButton];
    controller.isNavBack = YES;
    [self.navigationController pushViewController:controller animated:YES];

}

- (void)addGesture{

    id target = self.navigationController.interactivePopGestureRecognizer.delegate;
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:target action:@selector(handleNavigationTransition:)];
    pan.delegate = self;
    [self.view addGestureRecognizer:pan];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (self.childViewControllers.count == 1) {
        return NO;
    }
    return YES;
}

@end
