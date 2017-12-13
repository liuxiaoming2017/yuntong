//
//  DetailPageController.m
//  FounderReader-2.5
//
//  Created by chenfei on 4/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
//#define UIColorHex(_hex_)   [UIColor colorWithHexString:((__bridge NSString *)CFSTR(#_hex_))]

#import "DetailPageController.h"
#import "Article.h"
#import "CacheManager.h"
#import "NSString+Helper.h"
#import "CommentViewControllerGuo.h"
#import "UIDevice-Reachability.h"
#import "AppStartInfo.h"
#import "GreatestCommentPageController.h"
#import "MFSideMenu.h"
#import "shareCustomView.h"
#import "FCReader_OpenUDID.h"
#import "Global.h"
#import "NJEventRequest.h"
#import "ImageDetailPageController.h"
#import "SeeRootViewController.h"
#import "TemplateDetailPageController.h"
#import "SpecialNewsPageController.h"
#import "ColumnBarConfig.h"
#import "YXLoginViewController.h"

@interface DetailPageController ()

@end

@implementation DetailPageController

@synthesize columnName, column;
@synthesize articles;
@synthesize currentIndex;
@synthesize isPDF;
@synthesize voteColumnId;
@synthesize isNavGoback;
@synthesize contentShareUrl,contentShareImageUrl;



- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.hidesBottomBarWhenPushed = YES;
        self.isPDF = NO;
        self.isNavGoback = NO;
    }
    return self;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    return;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    bgImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    bgImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:bgImageView];

    self.rightRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(goBothBack)];
    self.rightRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:self.rightRecognizer];

    [self setupToolbar];
}

/**
 *  跳转到评论页
 *
 *  @param sender 点击按钮
 */
- (void)goNextPage:(id)sender
{
    [self gotoCommentList];
    
}
/**
 *  返回上一页
 */
- (void)goPrePage:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
    
}


- (void)viewDidUnload
{
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - 
/**
 *  跳转到评论页面
 */
-(void)showGreatComment
{
    GreatestCommentPageController *comment = [[GreatestCommentPageController alloc]init];
    Article *article = [articles objectAtIndex:currentIndex];
    comment.article = article;
    self.navigationController.navigationBarHidden = YES;
    [self.navigationController pushViewController:comment animated:YES];
}

- (void)setBgImage
{

}

#pragma mark -设置底部工具栏
- (void)setupToolbar
{
    // 获取工具条数据
    [self loadToolData];
 }

- (void)setupToolUI
{
    self.footview = [[ForumDetailFootView alloc] initWithCount:6 commentClose:NO greatClose:NO];
    
    _footview.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1];
    _footview.extCount = 0;
    _footview.delegate = self;
    [self.view addSubview:_footview];
    [self.view bringSubviewToFront:_footview];
    UIView *topview = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kSWidth, 0.4)];
    if (IS_IPHONE_6P) {
        topview.frame = CGRectMake(0, 0, kSWidth, 0.6);
    }
    topview.alpha = 0.6;
    topview.backgroundColor = [UIColor grayColor];
    [_footview addSubview:topview];
    
    [self updateFavoriteIcon];
    
    [self updateToolbarNew];
}

/* // 获取工具条数据 */
- (void)loadToolData
{
    __block Article *article = [articles objectAtIndex:currentIndex];
    NSString *requestString = [NSString stringWithFormat:@"%@/api/getArticleStat?sid=%@&aid=%d", [AppConfig sharedAppConfig].serverIf, [AppConfig sharedAppConfig].sid, article.fileId];
    HttpRequest *request = [[HttpRequest alloc] initWithURL:[NSURL URLWithString:requestString]];
    [request setValue:@"newaircloud.com" forHTTPHeaderField:@"Referer"];
    
    __weak __typeof (self)weakSelf = self;
    [request setCompletionBlock:^(id data) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers  error:nil];
        id commentCount = dict[@"countDiscuss"];
        id greatCount = dict[@"countPraise"];
        if([commentCount isKindOfClass:[NSString class]]){
            article.commentCount = commentCount;
        }else{
            article.commentCount = [commentCount stringValue];
        }
        if([greatCount isKindOfClass:[NSString class]]){
            article.greatCount = greatCount;
        }else{
            article.greatCount = [greatCount stringValue];
        }
        
        //[weakSelf setupToolUI];
    }];
    [request setFailedBlock:^(NSError *error) {
        [Global showTip:NSLocalizedString(@"加载失败，请检查网络",nil)];
        
    }];
    [self setupToolUI];
    [request startAsynchronous];
}

- (void)updateToolbar
{
    
}

//更新工具栏状态
- (void)updateToolbarNew
{
    if (isDiscussClose)
    {
        [self.footview hideCommentButton];
    }
    else{
        _showCommentRecognizer= [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(showGreatComment)];
        [_showCommentRecognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
        [self.view addGestureRecognizer:_showCommentRecognizer];
    }
    if(isGreatClose){
        [self.footview hidePraiseButton];
    }
    
    Article *article = [articles objectAtIndex:currentIndex];
    
    if([article.greatCount integerValue] == 0)
        _footview.greetLabel.hidden = YES;
    else if ([article.greatCount intValue]/10000)
        _footview.greetLabel.text = [NSString stringWithFormat:@"%d%@+", ([article.greatCount intValue])/10000, NSLocalizedString(@"万",nil)];
    else
        _footview.greetLabel.text = [NSString stringWithFormat:@"%d", [article.greatCount intValue]];
    
    if([article.commentCount integerValue] == 0)
        _footview.commentLabel.hidden = YES;
    else if ([article.commentCount intValue]/10000)
        _footview.commentLabel.text = [NSString stringWithFormat:@"%d%@+", ([article.commentCount intValue])/10000, NSLocalizedString(@"万",nil)];
    else
        _footview.commentLabel.text = [NSString stringWithFormat:@"%d", [article.commentCount intValue]];
    
    BOOL bestId = [[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"%ld",(long) article.fileId]];
    _footview.greetBtn.enabled = YES;
    if (bestId == 0)
    {
        _footview.greetBtn.enabled = YES;
        [_footview.greetBtn setImage:[UIImage imageNamed:@"toolbar_love_normal"] forState:UIControlStateNormal];
        
    }else
    {
        [_footview.greetBtn setImage:[UIImage imageNamed:@"toolbar_love_press"] forState:UIControlStateNormal];
        _footview.greetBtn.enabled = NO;
        _footview.greetLabel.textColor = [ColumnBarConfig sharedColumnBarConfig].column_all_color;
        /*
        if ([article.greatCount intValue]/10000)
            _footview.greetLabel.text = [NSString stringWithFormat:@"%d%@+", ([article.greatCount intValue] + 1)/10000, NSLocalizedString(@"万",nil)];
        else
            _footview.greetLabel.text = [NSString stringWithFormat:@"%d", [article.greatCount intValue] + 1];
         */
    }
    
    return;
}

- (void)closeComment{

}

- (void)shareAllButtonClickHandler:(UIButton *)sender
{
    if (![UIDevice networkAvailable]) {
        [Global showTipNoNetWork];
        return;
    }
    Article *article = [articles objectAtIndex:currentIndex];
    [shareCustomView shareWithContent:[self newsAbstract] image:[self newsImage] title:[self newsTitle] url:[self newsLink] type:0 completion:^(NSString *resultJson){
        // 返回分享结果到网页
        [self returnShareResultToWebView:resultJson];
//        [FounderEventRequest founderEventShareAppinit:article.fileId];
//        //文章分享事件
//        [FounderEventRequest shareDateAnaly:article.fileId column:self.column.fullColumn];
    }];
}

- (void)returnShareResultToWebView:(NSString *)resultJson
{
    //过渡到子类
}

- (NSString *)newsTitle
{
    Article *article = [articles objectAtIndex:currentIndex];
    NSString *text = article.title;
    if (![article.title isKindOfClass:[NSString class]])
        text = @"";
    return text;
}

- (NSString *)newsLink
{
    Article *article = [articles objectAtIndex:currentIndex];
    NSString *text = article.shareUrl;
    return text;
}

- (id)newsImage
{
    NSString *imageUrl = @"";
    Article *article = [articles objectAtIndex:currentIndex];
    imageUrl = article.imageUrl;
    if ([NSString isNilOrEmpty:imageUrl]) {
        return [Global getAppIcon];
    }
    else{
        return article.imageUrl;
    }
}

- (NSString *)newsAbstract
{
    
    Article *article = [articles objectAtIndex:currentIndex];
    NSString *text = article.attAbstract;
    if (![article.attAbstract isKindOfClass:[NSString class]])
        text = @"";
    return text;
}

//发评论
- (void)writeComment
{
    if (![UIDevice networkAvailable]) {
        
        [Global showTipNoNetWork];
        return;
    }
    CommentViewControllerGuo *commentController = [[CommentViewControllerGuo alloc] init];
    commentController.fullColumn = columnName;
    commentController.article = [self.articles objectAtIndex:self.currentIndex];
    commentController.rootID = commentController.article.fileId;
    [appDelegate().window addSubview:commentController.view];
}

- (void)gotoCommentList
{
    if (![UIDevice networkAvailable]) {
        
        [Global showTipNoNetWork];
        return;
    }
    Article *article = [articles objectAtIndex:currentIndex];
    GreatestCommentPageController *controller = [[GreatestCommentPageController alloc] init];
    controller.fullColumn = self.column.fullColumn;
    controller.article = article;
    [self.navigationController pushViewController:controller animated:NO];
    self.navigationController.navigationBarHidden = YES;
}

#pragma mark  FootViewDelegate底部工具栏点击方法
// 返回
- (void)goBothBack
{
    // 首页(无nav)present到第一条推送(有nav)，第一条推送(有nav)push到第二条推送(nav)，返回也需要这样，第N条返回第一条用pop，但第一条返回到首页用dismiss，判断本稿件是否是导航栏控制器的rootviewcontroller，若是则为第一条推送
    if(self.navigationController && self.navigationController.viewControllers[0] != self){
        [self.navigationController popViewControllerAnimated:YES];
    }
    else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
//收藏
-(void)collectItemClick
{
    Article *article = [articles objectAtIndex:currentIndex];
    CacheManager *manager = [CacheManager sharedCacheManager];
    if ([manager isCollect:article.fileId]) {
        [self unCollect:article.fileId];
    } else {
        [self collect:article];
    }
    
    [self updateFavoriteIcon];
}
//点赞
-(void)greetItemClick
{
    [self greatItemClicked:nil];
}
/* 权威评论 */
-(void)commentItemClick
{
    /*先进入评论页再在评论页弹出评论框*/
    __weak __typeof(self)weakSelf = self;
    if(![NSString isNilOrEmpty:[Global userId]])
        [self toWriteComment];
    else
        [self toLoginWithBlock:^{
            [weakSelf toWriteComment];
        }];
}

- (void)toWriteComment
{
    GreatestCommentPageController *comment = [[GreatestCommentPageController alloc] init];
    Article *article = [articles objectAtIndex:currentIndex];
    comment.article = article;
    comment.showWrite = YES;
    comment.isFromDetailPage = YES;
    comment.isPdfComment = self.isPDF;
    comment.fullColumn = self.column.fullColumn;
    self.navigationController.navigationBarHidden = YES;
    [self.navigationController pushViewController:comment animated:NO];
}

//进入评论页
-(void)commentReadClick
{
    // 等待评论
    GreatestCommentPageController *comment = [[GreatestCommentPageController alloc] init];
    Article *article = [articles objectAtIndex:currentIndex];
    comment.article = article;
    comment.showWrite = YES;
    self.navigationController.navigationBarHidden = YES;
    [self.navigationController pushViewController:comment animated:NO];
    
}
// 分享
-(void)shareClick
{
    [self shareAllButtonClickHandler:nil];
    
}
// 更新收藏按钮
- (void)updateFavoriteIcon
{
    [_footview.collectBtn setImage:[UIImage imageNamed:@"toolbar_collect_press"] forState:UIControlStateNormal];
    //return;
    Article *article = [self.articles objectAtIndex:self.currentIndex];
    CacheManager *manager = [CacheManager sharedCacheManager];
    if ([manager isCollect:article.fileId])
        [_footview.collectBtn setImage:[UIImage imageNamed:@"toolbar_collect_press"] forState:UIControlStateNormal];
    else
        [_footview.collectBtn setImage:[UIImage imageNamed:@"toolbar_collect_normal"] forState:UIControlStateNormal];
    
    
    [self updateIndex];
}

// 点赞
-(void)saveGread:(Article *)article
{
    NSMutableDictionary *saveIsAgreeDic = [[NSMutableDictionary alloc] initWithContentsOfFile:[cacheDirPath()
                                                                         stringByAppendingString:kSaveIsAgreeFileName]];
    if (!saveIsAgreeDic) {
        saveIsAgreeDic = [[NSMutableDictionary alloc] init];
    }
    [saveIsAgreeDic setObject:[NSNumber numberWithBool:YES]
                       forKey:[NSString stringWithFormat:@"%d",article.fileId]];
    [saveIsAgreeDic writeToFile:[cacheDirPath()
                                 stringByAppendingString:kSaveIsAgreeFileName]
                     atomically:YES];
    
}

-(BOOL)isGreaded:(Article *)article
{
    //已经点赞的稿件
    NSDictionary *saveIsAgreeDic = [NSMutableDictionary dictionaryWithContentsOfFile:[cacheDirPath()
                                                                                      stringByAppendingString:kSaveIsAgreeFileName]];
    if (saveIsAgreeDic) {
        if ([[saveIsAgreeDic objectForKey:[NSString stringWithFormat:@"%d",article.fileId]] boolValue])
            return YES;
    }
    return NO;
}

- (void)toLoginWithBlock:(void (^)(void))block
{
    YXLoginViewController *controller = [[YXLoginViewController alloc] init];
    [controller rightPageNavTopButtons];
    controller.loginSuccessBlock = ^(){
            if (block) block();
    };
    [self presentViewController:[Global controllerToNav:controller] animated:YES completion:nil];
}

- (void)updateIndex{
    return;
}

- (void)zoomInOut:(int)size{
    return;
}
- (void)collect:(Article *)article{
    return;
}

- (void)unCollect:(int)articleId{
    return;
}
- (void)greatItemClicked:(id)sender{
    return;
}
@end
