//
//  TemplateDetailPageController.m
//  FounderReader-2.5
//
//  Created by chenfei on 5/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TemplateDetailPageController.h"
#import "FileRequest.h"
#import "Article.h"
#import "DataLib/DataLib.h"
#import "UIDevice-Reachability.h"
#import "ArticleRequest.h"
#import "AppStartInfo.h"
#import "GreatestCommentPageController.h"
#import "UserAccountDefine.h"
#import "ImageDetailPageController.h"
#import "ColumnRequest.h"
#import "Author.h"
#import "YXLoginViewController.h"
#import "ColumnBarConfig.h"
#import "AdNewDetailViewController.h"
#import "TemplateNewDetailViewController.h"
#import "RNCachingURLProtocol.h"
#import "NewsListConfig.h"
#import "TXTexttoSpeechTTS.h"
#import "NSString+Helper.h"
#import "XYAVPlayer.h"
#import "UIPlayerView.h"
#import "NewsCellUtil.h"
#import "UIWebView+ShareURLCheck.h"

@interface TemplateDetailPageController ()<ProgressDelegate, UIDocumentInteractionControllerDelegate>
{
    //一级链接稿件加载完成(可能捕捉不完全)
    BOOL _isLinkDidLoad;
    //播报按钮
    UIButton *_speakView;
    
    //播报manager
    TXTexttoSpeechTTS *_speakManager;
    
    //段落集
    NSArray *_pTextArray;
    
    //将读段落
    NSInteger _pIndex;
    
    //记录滚动次数
    NSInteger _scrollCount;
    
    // 正在播放的fileID
    NSInteger _backFileID;
    
    __block TemplateDetailPageController *blockSelf;
    
}
@property(nonatomic,retain) Author *author;
@property (assign, nonatomic) NSInteger viewControllersCount;
@end

@implementation TemplateDetailPageController
@synthesize webView;
@synthesize imageArray;
@synthesize author;

- (void)viewDidDisappear:(BOOL)animated {
    if (self.navigationController.viewControllers.count < _viewControllersCount) {
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
    }
}

- (void)parseContent:(NSDictionary *)contentDict
{
    self.contentShareUrl = [contentDict objectForKey:@"shareUrl"];
    self.contentShareImageUrl = [contentDict objectForKey:@"imageUrl"];
    //关闭评论
    isDiscussClose = [[contentDict objectForKey:@"discussClosed"] boolValue];
    
    Article *article = [articles objectAtIndex:currentIndex];
    if(article.title.length == 0)
        article.title = [contentDict objectForKey:@"title"];
    if(article.imageUrl.length == 0)
        article.imageUrl = [contentDict objectForKey:@"imageUrl"];
    if(article.attAbstract.length == 0)
        article.attAbstract = [contentDict objectForKey:@"attAbstract"];
    
    if([[contentDict objectForKey:@"音频文件"] length] > 0){
        article.audioUrl = [contentDict objectForKey:@"音频文件"];
    }
    else{
        article.audioUrl = @"";
    }
    
    [self updateToolbar];
}

//本地文章模板路径
- (NSString *)templatePath
{
    return [cacheDirPath() stringByAppendingPathComponent:[NSString stringWithFormat:@"news_detail.html"]];
}


- (void)loadUrl:(NSString *)urlString
{
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *filePath = [cacheDirPath() stringByAppendingPathComponent:@"www/html/article.html"];
    NSURL *url = [NSURL URLWithString:filePath];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [webView loadRequest:request];
}

- (void)showHudView
{
    self.hudView.hidden = NO;
}


- (void)secondLoadWebview2
{
    self.hudView.hidden = YES;
    self.bringView.hidden = YES;
    [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"onceFontHint"];
}

#pragma mark - 下载模板
- (void)reload
{
    webView.hidden = YES;
    
    NSString *path = [self templatePath];
    if (!isFileExists(path)) {
        [Global showTip:NSLocalizedString(@"正在下载模板，请稍等！",nil)];
        [appDelegate() loadHTMLTemplate:^(NSNumber *success){
            if([success boolValue])
                [self loadContent];
            else{
                [Global showWebErrorView:self];
            }
        }];
    }
    else{
        [self loadContent];
    }
}

#pragma mark 下载文章内容
- (void)loadContent
{
    if (0 == articles.count) {
        return ;
    }
    Article *article = [articles objectAtIndex:currentIndex];
    
    // 获取CDN加速接口
    if (article.contentUrl && article.contentUrl.length > 0) {
        [self loadArticleContent:article];
    }
    else
    {
       NSString *url = [NSString stringWithFormat:@"%@/api/getArticle?&sid=%@&aid=%d&cid=%d",[AppConfig sharedAppConfig].serverIf, [AppConfig sharedAppConfig].sid, article.fileId, self.column.columnId];
        //测试
        //url = @"http://116.62.154.230:8080/api/getArticle?aid=1675588&sid=10060";
        HttpRequest *request = [HttpRequest requestWithURL:[NSURL URLWithString:url]];
        [request setCompletionBlock:^(NSData *data) {
            
            if (!data) {
                [Global showWebErrorView:self];
                return;
            }
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers  error:nil];
            article.contentUrl = [dic objectForKey:@"contentUrl"];
            //测试后面修改
            article.contentUrl = url;
            //测试
            //article.contentUrl = @"http://116.62.154.230:8080/api/getArticle?aid=1675588&sid=10060";
            [self loadArticleContent:article];
        }];
        [request setFailedBlock:^(NSError *error) {
            [Global showWebErrorView:self];
            return;
        }];
        [request startAsynchronous];
    }
}

#pragma mark 加载文章到模板
-(void)loadArticleContent:(Article *)article{
    
    // 从CDN加速获取稿件详情json
    HttpRequest *request = [HttpRequest requestWithURL:[NSURL URLWithString:article.contentUrl]];
    [request setCompletionBlock:^(NSData *data) {
        if (!data) {
            [Global showWebErrorView:self];
            return;
        }
        //将得到的json数据写入articleJson.js中去
        NSString *jsonStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers  error:nil];
        
        NSString *contentStr = [dic objectForKey:@"content"];
        self.contentStr = contentStr;
        
        
        NSLog(@"jsonStr###:%@",jsonStr);
        [self saveAndParseContentJson:jsonStr];
    }];
    [request setFailedBlock:^(NSError *error) {
        
//        [Global showWebErrorView:self];
        // 从CDN网路节点获取不了稿件详情json，如新疆，香港地区，就不从CDN获取
        [self loadArticleContentByNotCDN:article];
        
        return;
    }];
    [request startAsynchronous];
}

- (void)loadArticleContentByNotCDN:(Article *)article
{
    NSString *url = [NSString stringWithFormat:@"%@/api/getOSSArticle?&sid=%@&aid=%d",[AppConfig sharedAppConfig].serverIf, [AppConfig sharedAppConfig].sid, article.fileId];
    HttpRequest *request = [HttpRequest requestWithURL:[NSURL URLWithString:url]];
    [request setCompletionBlock:^(NSData *data) {
        if (!data) {
            [Global showWebErrorView:self];
            return;
        }
        //将得到的json数据写入articleJson.js中去
        NSString *jsonStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        [self saveAndParseContentJson:jsonStr];
    }];
    [request setFailedBlock:^(NSError *error) {
        [Global showWebErrorView:self];
        return;
    }];
    [request startAsynchronous];
}

- (void)saveAndParseContentJson:(NSString *)jsonStr
{
    if (!jsonStr || [jsonStr isEqualToString:@"null"]) {
        [Global showWebErrorView:self];
        return;
    }
    
    //【完成内容进入模板准备】内容写入缓存文件夹的article.js文件中，加载本地模板时，HTML文件调用该js文件内容进入模板
    //测试后面修改
    NSString *str22 = @"var gArticleJson = ";
    jsonStr = [str22 stringByAppendingString:jsonStr];
    //测试后期处理,解决后台传null字符
    NSString *testStr =
    [NSString stringWithFormat:@"\"\""];
    //jsonStr = [jsonStr stringByReplacingOccurrencesOfString:@"null" withString:testStr];
    [jsonStr writeToFile:[cacheDirPath() stringByAppendingPathComponent:@"article.js"] atomically:YES encoding:NSUTF8StringEncoding error:0];
    
    if ([NSString isNilOrEmpty:jsonStr]) {
        [Global showWebErrorView:self];
        return;
    }
    
    NSLog(@"str########:%@",[cacheDirPath() stringByAppendingPathComponent:@"article.js"]);
    
    //去掉内容前面的 var articleJSON = 的定义
    NSString *str = [jsonStr substringFromIndex:19];
    //测试后面修改
    //str = jsonStr;
    //
    NSData *dataDic = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:dataDic options:NSJSONReadingMutableContainers error:nil];
    
    [self parseContent:dic];
    
    int showvoice = [AppConfig sharedAppConfig].isOpenSpeech? 1: 0;
    NSString *netStatus = [UIDevice activeWLAN] ? @"WIFI":@"4G";
    // 加载本地模板
    [self loadUrl:[NSString stringWithFormat:@"%@?uid=%@&uname=%@&showvoice=%d&sid=%@&netStatus=%@&cid=%d",[self templatePath],[Global userId], [Global userName], showvoice, [AppConfig sharedAppConfig].sid, netStatus, self.column.columnId]];
    

    //文章阅读事件
    Article *article = [articles objectAtIndex:currentIndex];
    //[FounderEventRequest articleviewDateAnaly:article.fileId column:self.column.fullColumn];
}

-(void)onWebError:(id)sender{
    [self reload];
    [Global hideWebErrorView:self];
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)recognizer {
    return;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _viewControllersCount = self.navigationController.viewControllers.count;
    _firstClick = 0;
    webView.scalesPageToFit = YES;
    self.isFirstUrl = YES;
    NSArray *arr = self.view.subviews;
    UIImageView *img = arr[0];
    img.backgroundColor = [UIColor whiteColor];
    
    imageArray = [[NSMutableArray alloc] init];
    UIView *red = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kSWidth, 20)];
    red.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:red];
    
    // 设置一个监听,查看云播报是否自动播报结束,当播报结束后自动隐藏listenView
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeListenView:) name:@"isCloseView" object:nil];

    // 监听播放结束
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeAudioViewCilck:) name:kCloseAudioViewNotificationName object:nil];
    
    blockSelf = self;
}

// 播放结束
- (void)closeAudioViewCilck:(NSNotification *)notic {
    NSDictionary *dict = notic.userInfo;
    if ([[dict objectForKey:@"isClose"] isEqualToString:@"yes"]) {
        [UIPlayerView shareInstance].hidden = YES;
    }
    Article *playArticle = [[UIPlayerView shareInstance] getCurrentArticle];
    Article *curArticle = [self.articles objectAtIndex:currentIndex];
    if(curArticle && playArticle && curArticle.fileId == playArticle.fileId){
        [self sendAudioStatusToWebWithTime:@"0" andFlag:1 andIsCurPkaying:false];
    }
}

- (void)dealloc {
    // 销毁通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 语音播报视图操作
- (void)closeListenView:(NSNotification *)notic{
    
    NSDictionary *dict = (NSDictionary *)notic.userInfo;
    if ([[dict objectForKey:@"isCloseVoice"] isEqualToString: @"yes"]) {
        [UIPlayerView shareInstance].voiceStatus = 0;
        [UIPlayerView shareInstance].hidden = YES;
    }
}

// 弹出播放窗口
- (void)loadAudioView {
    
    Article *curArticle = [self.articles objectAtIndex:currentIndex];
    [[UIPlayerView shareInstance] unLoadBlock];
    [[UIPlayerView shareInstance] loadPlayerView:self.webView frame:CGRectMake(0, self.webView.bounds.size.height-40, kSWidth, 40)];
    //播放关闭按钮事件
    [UIPlayerView shareInstance].closeBtnClick = ^(UIPlayerView* playerView){
        
        if (playerView.isVoicePlaying) {
            // 关闭语音播报
            [blockSelf->_speakManager pauseVoice];
            [blockSelf->_speakManager closeReading:nil];
            // 清除选中文字
            [blockSelf clearAllTextBackgroundColor];
            return;
        }
        if (playerView.isAudioPlaying) {
            
            [blockSelf sendAudioStatusToWebWithTime:[playerView getCurrentAudioDuration] andFlag:1 andIsCurPkaying:false];
            return;
        }
    };
    //播放操作按钮操作
    [UIPlayerView shareInstance].operationBtnClick = ^(UIPlayerView* playerView){
        if (playerView.isVoicePlaying) { //云播播放时的喇叭操作
            if (playerView.voiceStatus == 1){
                [blockSelf->_speakManager pauseVoice];
            }
            else if (playerView.voiceStatus == 2){
                [blockSelf->_speakManager resumeVoice];
            }
        }
        
        if (playerView.isAudioPlaying) { //音频播放时的喇叭操作
            
            if (playerView.audioStatus == 1) {
                [blockSelf sendAudioStatusToWebWithTime:[playerView getCurrentAudioDuration] andFlag:1 andIsCurPkaying:false];
            }
            else if (playerView.audioStatus == 2) {
                [blockSelf sendAudioStatusToWebWithTime:[playerView getCurrentAudioDuration] andFlag:1 andIsCurPkaying:true];
            }
        }
    };
    //点击文章语音播报开始
    [UIPlayerView shareInstance].voiceClickBegin = ^(UIPlayerView* playerView){
        
        playerView.isVoicePlaying = YES;
        playerView.isAudioPlaying = NO;
        if(playerView.voiceStatus == 0){
            [self toSpeakVoice];
            playerView.voiceStatus = 1;
        }
        else if (playerView.voiceStatus == 1){
            [blockSelf->_speakManager pauseVoice];
            playerView.voiceStatus = 2;
        }
        else if (playerView.voiceStatus == 2){
            [blockSelf->_speakManager resumeVoice];
            playerView.voiceStatus = 1;
        }
        
        [blockSelf sendAudioStatusToWebWithTime:@"0" andFlag:1 andIsCurPkaying:false];
    };
    //点击文章语音播报结束
    [UIPlayerView shareInstance].voiceClickFinish = ^(UIPlayerView* playerView){
    
    };
    //音频播放进度通知
    [UIPlayerView shareInstance].loadAudioProgress = ^(UIPlayerView* playerView){
        
        if(![playerView isCurrentView:self.webView]){
            return;
        }
        Article *article = [playerView getCurrentArticle];
        if(article && article.fileId == curArticle.fileId){
            
            if (playerView.isAudioPlaying) {
                
                if (playerView.audioStatus == 1) {
                    [blockSelf sendAudioStatusToWebWithTime:[playerView getCurrentAudioDuration] andFlag:1 andIsCurPkaying:false];
                }
                else if (playerView.audioStatus == 2) {
                    [blockSelf sendAudioStatusToWebWithTime:[playerView getCurrentAudioDuration] andFlag:1 andIsCurPkaying:true];
                }
                else if(playerView.audioStatus == 0){
                  [blockSelf sendAudioStatusToWebWithTime:@"0" andFlag:1 andIsCurPkaying:false];
                }
            }
            else{
                [blockSelf sendAudioStatusToWebWithTime:@"0" andFlag:1 andIsCurPkaying:false];
            }
        }
        else{
            [blockSelf sendAudioStatusToWebWithTime:@"0" andFlag:1 andIsCurPkaying:false];
        }
    };
    //点击文章的音频播放
    [UIPlayerView shareInstance].mp3ClickFinish = ^(UIPlayerView* playerView){
        if (playerView.isVoicePlaying) {
            [blockSelf->_speakManager pauseVoice];
            playerView.isVoicePlaying = NO;
            playerView.voiceStatus = 2;
        }
        playerView.isAudioPlaying = YES;
        if (playerView.audioStatus == 1) {
            [blockSelf sendAudioStatusToWebWithTime:[playerView getCurrentAudioDuration] andFlag:1 andIsCurPkaying:false];
        }
        else if (playerView.audioStatus == 2) {
            [blockSelf sendAudioStatusToWebWithTime:[playerView getCurrentAudioDuration] andFlag:1 andIsCurPkaying:true];
        }
    };
    
    //点击播放标题
    [UIPlayerView shareInstance].titleClick = ^(UIPlayerView* playerView){
        if(![playerView isCurrentView:self.webView]){
            return;
        }
        Article *article = [playerView getCurrentArticle];
        if(article && article.fileId != curArticle.fileId){

            [NewsCellUtil clickNewsCell:article column:blockSelf.column in:blockSelf];
        }
    };
}
/**
 *  到评论页
 */
-(void)goCommentPage
{
    GreatestCommentPageController *controller = [[GreatestCommentPageController alloc] init];
    Article *article = [articles objectAtIndex:currentIndex];
    controller.article = article;
    self.navigationController.navigationBarHidden = YES;
    [self.navigationController pushViewController:controller animated:NO];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    self.tabBarController.tabBar.hidden = YES;
    [self loadAudioView];
    [self videoFinished:nil];
}

- (void)videoFinished:(NSNotification *)notification {//完成播放
    appDelegate().isAllOrientation = NO;
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val = UIInterfaceOrientationPortrait;
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [webView stringByEvaluatingJavaScriptFromString:@"showPlay(0)"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"firstClick"];
    [Global hideTip];
    //关闭朗读
    //if (_speakManager) {
    //    [_speakManager pauseVoice];
    //}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    //iOS6下旋屏方法
    return UIInterfaceOrientationMaskPortrait;
}
- (void)setBgImage
{
    bgImageView.backgroundColor = [UIColor colorWithRed:226/255.0 green:226/255.0 blue:226/255.0 alpha:1];
};
#pragma mark -

- (NSString *)documentTitle
{
    NSString *jsString = [NSString stringWithFormat:@"document.getElementById('title').innerHTML;"];
    return [webView stringByEvaluatingJavaScriptFromString:jsString];
}

- (void)showImage:(NSString *)imageUrl withY:(CGFloat)y
{
    //图片
    ImageDetailPageController *controller = [[ImageDetailPageController alloc] init];
    controller.openFirstIndex = [NSNumber numberWithInt:y];
    controller.articles = articles;
    controller.currentIndex = currentIndex;
    [self.navigationController pushViewController:controller animated:YES];
}

-(NSString *)buildImageUrl:(NSString *)originalUrl
{
    return originalUrl;
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    
    if (![UIWebView checkShareURLWithRequest:request navigationType:navigationType WebView:self.webView]) {
        return NO;
    }
    if (!_firstClick) {
        return YES;
    }
    //    [_audioPlayer openAudioWithUrl:self.audioUrlStr];
    NSURL *url = [request URL];
    
    NSString *urlString = [url absoluteString];
    XYLog(@"-----%@  ",urlString);
    
    urlString = [[urlString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] substringFromIndex:8];
    
    id jsonValue = [NSJSONSerialization JSONObjectWithData:[urlString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    
    NSDictionary *dic  = (NSDictionary *)jsonValue;
    
    NSString *operate = [dic objectForKey:@"operate"];
    
    if ([operate isEqualToString:@"phone"])
    {
        NSString* strPhone = @"tel://";
        strPhone = [strPhone stringByAppendingString: [dic objectForKey:@"numbers"]];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:strPhone]];
        return YES;
    }
    
    
    urlString = [url absoluteString];
    if ([urlString hasPrefix:@"video:///"]) {
        // 视频
        NSArray *components = [urlString componentsSeparatedByString:@"///"];
        
        if(components.count < 2)
            return NO;
        if ([UIDevice networkAvailable]) {
            NSString *videoURL = [components objectAtIndex:1];
            videoURL = [videoURL substringFromIndex:4];
            [self playVideo:videoURL];
        }
        else
        {
            [Global showTipNoNetWork];
        }
        return NO;
    }
    
    else if([urlString containsString:@"news_detail?"]){ //相关新闻
        NSRange range = [urlString rangeOfString:@"?"];
        urlString = [urlString substringFromIndex:range.location+1];
        NSArray *array = [urlString componentsSeparatedByString:@"&"];
        if (array.count<2) {
            return NO;
        }
        NSString *aidF = [NSString stringWithFormat:@"%@",[array objectAtIndex:0]];
        NSArray *arrFile = [aidF componentsSeparatedByString:@"="];
        if (arrFile.count < 2) {
            return NO;
        }
        int aid = [[arrFile objectAtIndex:1] intValue];
        
        NSString *url = [NSString stringWithFormat:@"%@/api/getArticle?&sid=%@&aid=%d&cid=%d",[AppConfig sharedAppConfig].serverIf,[AppConfig sharedAppConfig].sid,aid, self.column.columnId];
        HttpRequest *request = [HttpRequest requestWithURL:[NSURL URLWithString:url]];
        [request setCompletionBlock:^(NSData *data) {
            if (!data) {
                return ;
            }
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers  error:nil];
            Article *article = [Article articleFromDict:dic];
            [NewsCellUtil clickNewsCell:article column:self.column in:self];
        }];
        [request setFailedBlock:^(NSError *error) {
            
        }];
        [request startSynchronous];
        return NO;
    }
    else if([urlString containsString:@"adv_detail?"]){ //推广
        NSString *contentUrl = urlString;
        //获取id
        NSRange rangeID = [urlString rangeOfString:@"?"];
        urlString = [urlString substringFromIndex:rangeID.location+1];
        NSArray *array = [urlString componentsSeparatedByString:@"&"];
        if (array.count<4) {
            return NO;
        }
        NSString *aidF = [NSString stringWithFormat:@"%@",[array objectAtIndex:0]];
        NSArray *arrFile = [aidF componentsSeparatedByString:@"="];
        if (arrFile.count < 2) {
            return NO;
        }
        int aid = [[arrFile objectAtIndex:1] intValue];
        //获取title
        NSString *titleF = [NSString stringWithFormat:@"%@",[array objectAtIndex:2]];
        NSArray *arrTitle = [titleF componentsSeparatedByString:@"="];
        if (arrTitle.count < 2) {
            return NO;
        }
        NSString *aTitle = [arrTitle objectAtIndex:1];
        NSString *aEndTitle = [aTitle stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        //获取标题图
        NSString *imageUrlF = [NSString stringWithFormat:@"%@",[array objectAtIndex:3]];
        NSArray *arrImageUrl = [imageUrlF componentsSeparatedByString:@"="];
        if (arrImageUrl.count < 2) {
            return NO;
        }
        NSString *aImageUrl = [arrImageUrl objectAtIndex:1];
        if (_isLinkDidLoad && navigationType == UIWebViewNavigationTypeLinkClicked) {
            
            TemplateNewDetailViewController *controller = [[TemplateNewDetailViewController alloc] init];
            Article *article = [[Article alloc] init];
            article.fileId = aid;
            article.contentUrl = contentUrl;
            article.title = aEndTitle;
            article.imageUrl = aImageUrl;
            article.attAbstract = self.adArticle.attAbstract;
            article.type = ArticleType_ADV_List;
            controller.adArticle = article;
            controller.articles = [NSArray arrayWithObject:article];
            controller.isMore = YES;
            [self.navigationController pushViewController:controller animated:YES];
        }
        return NO;
    }
    else if ([urlString hasPrefix:@"http"])
    {
        if (navigationType == UIWebViewNavigationTypeOther) {
            return YES;
        }
        self.isFirstUrl = NO;
        AdNewDetailViewController *controller = [[AdNewDetailViewController alloc] init];
        Article *article = [[Article alloc] init];
        article.fileId = self.adArticle.fileId;
        article.contentUrl = urlString;
        article.title = self.adArticle.title;
        article.imageUrl = self.adArticle.imageUrl;
        article.attAbstract = self.adArticle.attAbstract;
        
        controller.adArticle = article;
        controller.isMore = YES;
        [self presentViewController:controller animated:YES completion:nil];
        return NO;
    }
    //注：else if不能和上面分支的} 在一行，否则debug不走下面这个else if
    else if ([[urlString lowercaseString] containsString:@"checkuserlogin"]) {       // 用户点击活动报名
        //是否登录
        if (![Global userId].length) {
            [self showLoginPage];
            return NO;
        }else{
            NSString * fullname = [[NSUserDefaults standardUserDefaults] objectForKey:KuserAccountFullName];
            if ([NSString isNilOrEmpty:fullname]) {
                fullname = @"";
            }
            NSString *jsMethod = [NSString stringWithFormat:@"clientCallHtml('%@','%@','%@');", fullname, [Global userInfoByKey:KuserAccountPhone], [Global userId]];
            
            [self.webView stringByEvaluatingJavaScriptFromString:jsMethod];
            
            NSString *postUserInfo = [NSString stringWithFormat:@"postUserInfo('%@');", [Global userInfoStr]];
            [self.webView stringByEvaluatingJavaScriptFromString:postUserInfo];
        }
    }
    else if ([urlString containsString:@"submitActivitySignUp:///"]) {       // 用户点击活动报名
       
        NSString *boolStr = [urlString substringFromIndex:[@"submitActivitySignUp:///url=" length]];
        
        if ([boolStr isEqualToString:@"true"]) {
            [Global showTip:NSLocalizedString(@"报名成功！",nil)];
        }else {
            [Global showTip:NSLocalizedString(@"报名失败！",nil)];
        }
    }
    else if ([[urlString lowercaseString] containsString:@"showcommentpage"]){ // 用户点击查看评论
        
        [self goCommentPage];
        return YES;
    }
    else if ([urlString hasPrefix:@"image:///"]) {// 用户点击图片触发请求
        // 图片
        if (!self.isFirstUrl) {
            return NO;
        }
        NSArray *components = [urlString componentsSeparatedByString:@"///"];
        if(components.count < 2)
            return NO;
        CGFloat y = [[((NSString *)[components objectAtIndex:1]) substringFromIndex:6] floatValue];
        [self showImage:@"" withY:y];
        return NO;
    }
    else if ([urlString containsString:@"sendText"]) {
        NSString *pTextString = [urlString  substringFromIndex:25];
        NSString *transString = [NSString stringWithString:[pTextString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        transString = [transString stringByReplacingOccurrencesOfString:@"" withString:@" "];
        _pTextArray = [transString componentsSeparatedByString:@"&&"];
        
        //第一次播报
        _pIndex = 1;//从第1行开始除去日期
        _scrollCount = 1;
        if(_pIndex < _pTextArray.count){
            [_speakManager playVoice:[_pTextArray objectAtIndex:_pIndex]];
        }
        
    }else if([urlString containsString:@"scrolled"]){
        _scrollCount++;
    }
    else if ([urlString containsString:@"downfile"]) {//附件
        NSArray *components = [urlString componentsSeparatedByString:@"///"];
        
        if(components.count < 2)
            return NO;
        NSString *annexURL = [components objectAtIndex:1];
        XYLog(@"附件的URL:%@",annexURL);
        // 用safari打开附件
        NSURL *url = [NSURL URLWithString:annexURL];
        [[UIApplication sharedApplication] openURL:url];
    }
    else if ([[urlString lowercaseString] containsString:@"clientplayvoice"]) {
        //语音播报
        if ([AppConfig sharedAppConfig].isOpenSpeech)
            [[UIPlayerView shareInstance] voiceClick:[self.articles objectAtIndex:currentIndex]];
    }
    else if ([[urlString lowercaseString] containsString:@"clientplayaudio"]) {
        //音频播放
        [[UIPlayerView shareInstance] mp3Click:[self.articles objectAtIndex:currentIndex]];
//        [[XYAVPlayer shareInstance] addPlayList:self.articles];
    }
    return YES;
}

// 向页面发送音频信息
- (void)sendAudioStatusToWebWithTime:(NSString *)time andFlag:(int)flag andIsCurPkaying:(bool)isCurPlaying {
    
    if(time == nil){ time = @""; }
    NSString *jsonStr = [NSString stringWithFormat:@"{\"duration\":\"%@\", \"flag\":\"%d\", \"isCurPlaying\":\"%d\"}",time, flag, isCurPlaying];
    [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"audioContrl('%@')", jsonStr]];
}

#pragma mark - 显示网页
- (void)showWebView
{
    webView.hidden = NO;
}
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [Global showTipAlways:NSLocalizedString(@"正在加载...",nil)];
}
- (void)webViewDidFinishLoad:(UIWebView *)sender
{
    [Global hideTip];
    
    NSString *currentURL= self.webView.request.URL.absoluteString;
    //一级链接稿件加载完毕
    if (![currentURL containsString:@"newaircloud"]) {
        _isLinkDidLoad = YES;
    }
    
    //    NSString *urlstr = self.adArticle.contentUrl;
    
    [self zoomSize];
    [self performSelector:@selector(showWebView) withObject:nil afterDelay:0.1];
    [self fontHint];
    _firstClick = 1;
    
    //播报 放在这里是为了避免网太慢网页还没出来，播报按钮先出来
    if ([AppConfig sharedAppConfig].isOpenSpeech) {
        [self addSpeakView];
    }
    
   // NSString *headerStr = @"document.getElementsByTagName('p')[0].innerText = '测试文字';";
    //NSString *str1 = [NSString stringWithFormat:@"document.getElementsByTagName('p')[0].innerText = '%@';",self.contentStr];
    NSString *str1 = [NSString stringWithFormat:@"document.body.innerText = '%@';",self.contentStr];
    [webView stringByEvaluatingJavaScriptFromString:str1];
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [Global hideTip];
}

- (void)fontHint
{
    NSInteger onceFontHint = [[[NSUserDefaults standardUserDefaults] objectForKey:@"onceFontHint"] integerValue];
    if (onceFontHint) {
        return;
    }
    if(self.hudView == nil){
        self.hudView = [[UIView alloc] init];
        self.hudView.frame = CGRectMake((kSWidth-240)/2, (kSHeight-160-49+20)/2, 240, 160);
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fontHint"]];
        self.hudView.backgroundColor = [UIColor blackColor];
        self.hudView.layer.cornerRadius = 10;
        self.hudView.alpha = .8;
        self.hudView.hidden = YES;
        imageView.frame = CGRectMake((240-70)/2, 30, 70, 70);
        UILabel *labelT = [[UILabel alloc] init];
        labelT.frame = CGRectMake(0, 100, 240, 50);
        labelT.text = NSLocalizedString(@"手势调整字号大小",nil);
        labelT.textColor = [UIColor whiteColor];
        labelT.textAlignment = NSTextAlignmentCenter;
        labelT.font = [UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleCellTitleFontSize+3];
        [self.hudView addSubview:labelT];
        [self.hudView addSubview:imageView];
    }
    if(self.bringView == nil){
        self.bringView = [[UIView alloc] init];
        self.bringView.frame = CGRectMake(0, 0, kSWidth, kSHeight);
        self.bringView.backgroundColor = [UIColor clearColor];
        self.bringView.hidden = NO;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(secondLoadWebview2)];
        [self.bringView addGestureRecognizer:tap];
    }
    
    [self.view addSubview:self.hudView];
    [self.view addSubview:self.bringView];
    [self performSelector:@selector(showHudView) withObject:nil afterDelay:0];
}

- (void)goBothBack{
    
    if ([webView canGoBack]){
        [webView  goBack];
    }
    else{
        if(self.navigationController && self.navigationController.viewControllers[0] != self){
            [self.navigationController popViewControllerAnimated:YES];
        }
        else{
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        //文章返回事件
        Article *article = [articles objectAtIndex:currentIndex];
       // [FounderEventRequest articlereturnDateAnaly:article.fileId column:self.column.fullColumn];
    }
    //关闭朗读
    if (_speakManager) {
        [_speakManager pauseVoice];
    }
}

#pragma mark - hooks
- (void)addWebView
{
    //调整webview的高度
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
    {
        webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, kStatusBarHeight, kSWidth, kSHeight-49-20)];
    }else
    {
        webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, kStatusBarHeight, kSWidth, kSHeight-49-20)];
    }
    webView.scrollView.backgroundColor = [UIColor whiteColor];
    webView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    webView.mediaPlaybackRequiresUserAction = NO;
    webView.delegate = self;
    webView.hidden = YES;
    webView.dataDetectorTypes = UIDataDetectorTypeNone;
    [self.view addSubview:webView];
    
}
- (void)zoomSize
{
    NSString *jsString1 = [NSString stringWithFormat:@"zoomFont('%@')",[Global fontSize]];
    [webView stringByEvaluatingJavaScriptFromString:jsString1];
}
- (void)zoomInOut:(NSString *)size
{
    NSString *jsString1 = [NSString stringWithFormat:@"zoomFont('%@')",size];
    [webView stringByEvaluatingJavaScriptFromString:jsString1];
    
    _fontHudView = [[UIView alloc] init];
    _fontHudView.frame = CGRectMake((kSWidth-180)/2, (kSHeight-40-49-20), 180, 40);
    _fontHudView.layer.cornerRadius = 20;
    _fontHudView.backgroundColor = [UIColor blackColor];
    _fontHudView.alpha = 0;
    UILabel *labelT = [[UILabel alloc] init];
    labelT.frame = CGRectMake(0, 0, 180, 40);
    if ([size isEqualToString:@"sm"]) {
        size = NSLocalizedString(@"小",nil);
    }
    else if ([size isEqualToString:@"md"])
    {
        size = NSLocalizedString(@"中",nil);
    }
    else if ([size isEqualToString:@"lg"])
    {
        size = NSLocalizedString(@"大",nil);
    }
    else if ([size isEqualToString:@"hg"])
    {
        size = NSLocalizedString(@"超大",nil);
    }
    labelT.text = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"当前字体为",nil),size];
    labelT.textColor = [UIColor whiteColor];
    labelT.textAlignment = NSTextAlignmentCenter;
    labelT.font = [UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleCellTitleFontSize];
    [_fontHudView addSubview:labelT];
    [self.view addSubview:_fontHudView];
    [UIView beginAnimations:@"123" context:nil];
    [UIView setAnimationDuration:1];
    _fontHudView.alpha = .8;
    [UIView commitAnimations];
    [self performSelector:@selector(hideHUD) withObject:nil afterDelay:0];
}
- (void)zoomInOut:(NSString *)size withIS:(int)top
{
    NSString *jsString1 = [NSString stringWithFormat:@"zoomFont('%@')",size];
    [webView stringByEvaluatingJavaScriptFromString:jsString1];
    
    _fontHudView = [[UIView alloc] init];
    _fontHudView.frame = CGRectMake((kSWidth-180)/2, (kSHeight-40-49-20), 180, 40);
    _fontHudView.layer.cornerRadius = 20;
    _fontHudView.backgroundColor = [UIColor blackColor];
    _fontHudView.alpha = 0;
    UILabel *labelT = [[UILabel alloc] init];
    labelT.frame = CGRectMake(0, 0, 180, 40);
    if(top == 1)
    {
        labelT.text = [NSString stringWithFormat:NSLocalizedString(@"当前字体已经为小",nil)];
    }
    else if(top == 2)
    {
        labelT.text = [NSString stringWithFormat:NSLocalizedString(@"当前字体已经为超大",nil)];
    }
    labelT.textColor = [UIColor whiteColor];
    labelT.textAlignment = NSTextAlignmentCenter;
    labelT.font = [UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleCellTitleFontSize];
    [_fontHudView addSubview:labelT];
    [self.view addSubview:_fontHudView];
    [UIView beginAnimations:@"123" context:nil];
    [UIView setAnimationDuration:1];
    _fontHudView.alpha = .8;
    [UIView commitAnimations];
    [self performSelector:@selector(hideHUD) withObject:nil afterDelay:0];
}
- (void)hideHUD
{
    [UIView beginAnimations:@"123" context:nil];
    [UIView setAnimationDuration:1];
    _fontHudView.alpha = 0;
    [UIView commitAnimations];
}

-(void)showLoginPage
{
    YXLoginViewController *controller = [[YXLoginViewController alloc]init];
    controller.loginSuccessBlock = ^(){
        NSString *jsMethod = [NSString stringWithFormat:@"clientCallHtml('%@','%@','%@');", [Global userName], [Global userPhone], [Global userId]];
        [self.webView stringByEvaluatingJavaScriptFromString:jsMethod];
        NSString *postUserInfo = [NSString stringWithFormat:@"postUserInfo('%@');", [Global userInfoStr]];
        [self.webView stringByEvaluatingJavaScriptFromString:postUserInfo];
    };
    [controller rightPageNavTopButtons];
    [appDelegate().window.rootViewController presentViewController:[Global controllerToNav:controller] animated:YES completion:nil];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    
    if (self.childViewControllers.count == 1) {
        // 表示用户在根控制器界面，就不需要触发滑动手势，
        return NO;
    }
    return YES;
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    XYLog(@"Gesturing");
    return YES;
}

#pragma mark - 语音播报-method
/**
 *  @brief 添加播报按钮
 */
- (void)addSpeakView
{
    _speakView = [[UIButton alloc] initWithFrame:CGRectMake(kSWidth - 50, kSHeight - 100, 45, 45)];
    _speakView.backgroundColor = [ColumnBarConfig sharedColumnBarConfig].column_all_color;
    // 将播报隐藏,但是功能还在,在 听新闻 中直接使用播报功能
    _speakView.hidden = YES;
    
    [_speakView setTitle:@"播报" forState:UIControlStateNormal];
    [_speakView.titleLabel setFont:[UIFont systemFontOfSize:14]];
    //用layer属性取控制图形的显示
    _speakView.layer.cornerRadius = _speakView.frame.size.width/2.0f;
    [_speakView addTarget:self action:@selector(toSpeakVoice) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_speakView];
    [self.view bringSubviewToFront: _speakView];
}

/**
 *  @brief 处理播报事件
 */
- (void)toSpeakVoice
{
    if (![UIDevice networkAvailable]) {
        [Global showTipNoNetWork];
        return;
    }
    
    NSString *buttonText = _speakView.titleLabel.text;
    if ([buttonText isEqualToString:NSLocalizedString(@"播报",nil)]) {
        //重播页面滚动到顶部
        if ([self.webView subviews]) {
            UIScrollView* scrollView = [[self.webView subviews] objectAtIndex:0];
            [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        }
        [self changeSpeakViewTitle:NSLocalizedString(@"暂停",nil)];
        [self loadContentFromWebView];
    }else if([buttonText isEqualToString:NSLocalizedString(@"暂停",nil)]){
        [self changeSpeakViewTitle:NSLocalizedString(@"继续",nil)];
        [_speakManager pauseVoice];
    }else if([buttonText isEqualToString:NSLocalizedString(@"继续",nil)]){
        [self changeSpeakViewTitle:NSLocalizedString(@"暂停",nil)];
        [_speakManager resumeVoice];
    }else if([buttonText isEqualToString:NSLocalizedString(@"重试",nil)]){
        [self changeSpeakViewTitle:NSLocalizedString(@"暂停",nil)];
        [self loadContentFromWebView];
    }
}

/**
 *  @brief 从网页加载播报内容
 */
- (void)loadContentFromWebView
{
    //实例化播报工具
    _speakManager=[TXTexttoSpeechTTS shareManager];
    _speakManager.delegate = self;
    
    NSMutableString *js = [NSMutableString string];
    
    [js appendString:@"var pTextArr = new Array();"];
    [js appendString:@"var paras = document.getElementsByTagName('p');"];
    [js appendString:@"for (var i=0; i< paras.length; i++) {"];
    [js appendString:@"var pText = paras[i].innerText;"];
    [js appendString:@"if (pText != null) {"];
    
    [js appendString:@"pTextArr.push(pText);}}"];
    [js appendString:@"window.location.href = 'objc://sendText?pTextArr=' + pTextArr.join('&&')"];
    
    [self.webView stringByEvaluatingJavaScriptFromString:js];
    
}

/**
 *  @brief 判断一个字符串是否为nil、空、空格
 *
 *  @param string 检验的字符串
 *
 *  @return 判断结果
 */
- (BOOL) isBlankString:(NSString *)string {
    if (string == nil || string == NULL) {
        return YES;
    }
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0) {
        return YES;
    }
    return NO;
}

#pragma mark - 语音播报-delegate
/**
 *  当前播报加上背景色以及自动滑动
 *
 *  @param rang 当前播报位置
 */
- (void)addReadingTextBackgroundColor:(NSRange)rang
{
    /*webview滚动
     if ([self.webView subviews]) {
     UIScrollView* scrollView = [[self.webView subviews] objectAtIndex:0];
     [scrollView setContentOffset:CGPointMake(0, 100) animated:YES];
     }
     html滚动
     NSMutableString *js = [NSMutableString string];
     [js appendString:@"$('html, body').animate({"];
     [js appendString:@"scrollTop: $('p:eq(6)').offset().top"];
     [js appendString:@" },1000);"];
     [self.webView stringByEvaluatingJavaScriptFromString:js];
     */
    
    NSMutableString *js = [NSMutableString string];
    [js appendString:[NSString stringWithFormat:@"var textEle = document.getElementsByTagName('p')[%ld];", (long)_pIndex]];
    [js appendString:@"var text = textEle.innerText;"];
    [js appendString:[NSString stringWithFormat:@"var befText = text.substring(%lu, %lu);", (unsigned long)rang.location, (unsigned long)rang.location+rang.length]];
    [js appendString:@"var aftText ='<span id=\"speakingSpan\" style = \"background:#8ef6ea;\">'+befText+'</span>';"];
    [js appendString:@"textEle.innerHTML = text.replace(befText, aftText);"];
    
    //打印内容
    //    [js appendString:@"alert(document.getElementsByTagName('span')[0].innerText);"];
    //    [js appendString:@"alert(document.getElementById('doc-content-div').innerHTML);"];
    
    [js appendString:[NSString stringWithFormat:@"if ($('#speakingSpan') && $('#speakingSpan').offset().top > %f) {", 500 *(kSHeight/667)*_scrollCount]];
    //    [js appendString:@"alert($('speakingSpan').offset().top);"];
    [js appendString:@"window.location.href = 'objc://scrolled';"];
    [js appendString:@"$('html, body').animate({"];
    [js appendString:@"scrollTop: $('#speakingSpan').offset().top - 30"];
    //    每到一个段落滑到顶部
    //    [js appendString: [NSString stringWithFormat:@"scrollTop: $('p:eq(%ld)').offset().top - 30", _pIndex]];
    [js appendString:@" },1000);"];
    
    [js appendString:@"}"];
    
    [self.webView stringByEvaluatingJavaScriptFromString:js];
    
}
/**
 *  清除所有播报背景
 */
- (void)clearAllTextBackgroundColor
{
    NSMutableString *js = [NSMutableString string];
    [js appendString:[NSString stringWithFormat:@"var contentElement = document.getElementById('doc-content-div');"]];
    
    [js appendString:@"var contentHTML = contentElement.innerHTML;"];
    
    //js正则表达式.replace(/<\/?span[^>]*>/gi,'')找到所有的<>标签并替换成''，\在OC中不能识别，用\\表示
    [js appendString:@"contentElement.innerHTML = contentHTML.replace(/<\\/?span[^>]*>/gi,'');"];
    
    [self.webView stringByEvaluatingJavaScriptFromString:js];
}

/**
 *  @brief 加载新段落
 *
 */
- (NSString *)loadNewText
{
    if ((_pIndex+1) < _pTextArray.count) {
        
        for (NSInteger i = ++_pIndex; i < _pTextArray.count; i++) {
            NSString *newText = _pTextArray[i];
            if (![self isBlankString:newText]) {
                _pIndex = i;
                return newText;
            }
        }
    }
    return nil;
}

/**
 * 变更播报按钮
 */
- (void)changeSpeakViewTitle:(NSString *)title
{
    [_speakView setTitle:title forState:UIControlStateNormal];
    _scrollCount = 1;
}

- (void)returnShareResultToWebView:(NSString *)resultJson
{
    [self.webView performSelectorOnMainThread:@selector(giveResultWithWebView:) withObject:@{@"webView":self.webView, @"resultJson":resultJson} waitUntilDone:NO];
}

@end
