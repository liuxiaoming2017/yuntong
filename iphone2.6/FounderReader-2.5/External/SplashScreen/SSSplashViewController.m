//
//  SSSplashViewController.m
//  SplashScreen
//
//  Created by chenfei on 4/22/13.
//  Copyright (c) 2013 chenfei. All rights reserved.
//
#import "SSPageCF.h"
#import <MediaPlayer/MediaPlayer.h>
#import "SvGifView/SvGifView.h"
#import <AVFoundation/AVFoundation.h>
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@interface SSSplashViewController ()<UIWebViewDelegate>
@property (nonatomic, retain) UIImageView *bgImageView;
@property (nonatomic, retain) UIActivityIndicatorView *indicator;
@property (nonatomic, retain) ASINetworkQueue *queue;
@property (nonatomic, retain) MPMoviePlayerViewController *_player;
@property (nonatomic, retain) SSPageCF *page;
@end

@implementation SSSplashViewController
{
    BOOL _skipped;
    NSTimeInterval playbackTime;
}

@synthesize pages, titleText;
@synthesize pagesUrlString;
@synthesize delegate;
@synthesize bgImageView;
@synthesize indicator;
@synthesize queue;
@synthesize _player;
@synthesize startPages;

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)loadPagesConfig
{
    self.pages = [NSMutableArray arrayWithCapacity:self.startPages.count];
    for (NSDictionary *pageDict in self.startPages)
    {
        SSPageCF *page = [[SSPageCF alloc] init];
        page.pid = [[pageDict objectForKey:@"advID"] intValue];
        page.name = [pageDict objectForKey:@"title"];
        page.style = [[pageDict objectForKey:@"style"] intValue];
        page.type = [[pageDict objectForKey:@"type"] intValue];
        page.startTime = [pageDict objectForKey:@"startTime"];
        page.endTime = [pageDict objectForKey:@"endTime"];
        page.residenceTime = [[pageDict objectForKey:@"pageTime"] intValue];
        page.webUrl = [pageDict objectForKey:@"contentUrl"];
        
        
        page.fileSDUrlVertical = [pageDict objectForKey:@"imgUrl"];
        page.fileSDUrlHorizontal = [pageDict objectForKey:@"imgUrl"];//1136
        page.fileHDUrlVertical = [pageDict objectForKey:@"imgUrl"];
        page.fileHDUrlHorizontal = [pageDict objectForKey:@"imgUrl"];//960
        page.fileRetinaUrlVertical = [pageDict objectForKey:@"imgUrl"];
        
        page.middlePic = [pageDict objectForKey:@"imgUrl"];//1136
        page.smallPic = [pageDict objectForKey:@"imgUrl"];//960;
        page.bigPic = [pageDict objectForKey:@"imgUrl"];//1134
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
        [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
        NSDate *dataStart = [formatter dateFromString:page.startTime];
        NSTimeInterval timeStart = [dataStart timeIntervalSince1970];
        
        NSDate *dataEnd = [formatter dateFromString:page.endTime];
        NSTimeInterval timeEnd = [dataEnd timeIntervalSince1970];
        
        NSTimeInterval timeNow = [[NSDate date] timeIntervalSince1970];
        if (timeStart < timeNow && timeNow < timeEnd) {
            [self.pages addObject:page];
        }
    }
    if (self.pages.count) {
        int i = arc4random()%(self.pages.count);
        _page = self.pages[i];
    }
    
    [self loadPagesResources];
    [self.indicator startAnimating];
    
}

- (NSString *)fileUrlStringFromUrlString:(NSString *)urlString
{
#ifdef SPLASH_LOCAL
    NSString *fileName = [[urlString componentsSeparatedByString:@"."] objectAtIndex:0];
    NSString *extension =[urlString pathExtension];
    return [[NSBundle mainBundle] pathForResource:fileName ofType:extension];
#else
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = [paths objectAtIndex:0];
    NSString *startPageResourcesDirPath = [cachePath stringByAppendingPathComponent:@"StartPages"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:startPageResourcesDirPath])
        [[NSFileManager defaultManager] createDirectoryAtPath:startPageResourcesDirPath withIntermediateDirectories:YES attributes:nil error:0];
    NSString *resourcePath = nil;
    if ([urlString containsString:@"gif"]) {
        resourcePath = [startPageResourcesDirPath stringByAppendingPathComponent:@"first.gif"];
        return resourcePath;
    }
    else
    {
        resourcePath = [startPageResourcesDirPath stringByAppendingPathComponent:@"first.png"];
    }
    return resourcePath;
#endif
}

#pragma mark - 加载启动页广告数据
- (void)loadPagesResources
{
    if ([self.pages count] == 0) {
        [self.indicator stopAnimating];
        [self showStartPagesFrom:[NSNumber numberWithInt:-1]];
        return;
    }
    
    queue = [[ASINetworkQueue alloc] init];
    [queue setShouldCancelAllRequestsOnFailure:YES];
    queue.delegate = self;
    queue.queueDidFinishSelector = @selector(queueDidFinish:);
    
    NSString *urlString = nil;
    if (IS_IPHONE_5)
        urlString = _page.fileRetinaUrlVertical;    // 待修改
    else if (IS_IPHONE_4)
        urlString = _page.fileHDUrlVertical;
    else
        urlString = _page.fileSDUrlVertical;
    
    if (_page.style == SSPageStyleImage)
    {
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:urlString]];
        NSString *resourcePath = [self fileUrlStringFromUrlString:urlString];
        [request setTemporaryFileDownloadPath:[NSString stringWithFormat:@"%@.tmp", resourcePath]];
        [request setDownloadDestinationPath:resourcePath];
        [request setAllowResumeForFileDownloads:NO];
        [queue addOperation:request];
    }
    else
    {
        XYLog(@"===========skip1");
        [self skip:nil];
    }

    [queue go];
}

- (void)queueDidFinish:(ASINetworkQueue *)queue1
{
    [self.indicator stopAnimating];
    [[self.view viewWithTag:999] setHidden:NO];
    [self showStartPagesFrom:[NSNumber numberWithInt:0]];
    // 图片展示后才计时
    if (self.pages.count > 0) {
        XYLog(@"===========skip2");
        [self performSelector:@selector(skip:) withObject:NULL afterDelay:_page.residenceTime];
    }
}

- (int)videoDuration:(NSURL *)movieURL
{
    NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:movieURL options:opts];  // 初始化视频媒体文件
    int second = (int)(urlAsset.duration.value / urlAsset.duration.timescale); // 获取视频总时长,单位秒
    return second;
}


#pragma mark - 加载启动页广告UI
- (void)showStartPagesFrom:(NSNumber *)idx
{
    
    XYLog(@"~~~~~~~inter0");
    if (_skipped)
        return;
    XYLog(@"~~~~~~~inter0.1");
    __block int index = [idx intValue];
    
    if (index < 0 || index >= [self.pages count]) {
        
        if ([self.delegate respondsToSelector:@selector(splashDidfinished:)])
            [self.delegate performSelector:@selector(splashDidfinished:) withObject:self];
        return;
    }
    XYLog(@"~~~~~~~inter0.2");
    [UIView animateWithDuration:0 animations:^(void) {
        if (self.bgImageView.subviews) {
            [self.bgImageView.subviews makeObjectsPerformSelector:@selector(setAlpha:) withObject:0];
        }
    } completion:^(BOOL finished) {
        
        XYLog(@"~~~~~~~inter1");
        if (self.bgImageView.subviews) {
            [self.bgImageView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        }
        
        if (self._player) {
            [_player.moviePlayer stop];
        }
        
        if (index < 0 || index >= [self.pages count]) {
            return;
        }
        __block SSPageCF *page = [self.pages objectAtIndex:index];
        NSString *urlString;
        if (IS_IPHONE_5)
            urlString = page.fileRetinaUrlVertical;
        else if (IS_IPHONE_4)
            urlString = page.fileHDUrlVertical;
        else
            urlString = page.fileSDUrlVertical;
        
        self.pid = page.pid;
        self.webUrl = page.webUrl;
        self.titleText = page.name;
        self.startTime = page.startTime;
        [UIView animateWithDuration:0 animations:^(void) {
            if (page.style == SSPageStyleImage && self.webUrl.length == 0) {
                UIImageView *splashImageView = [[UIImageView alloc] initWithFrame:self.bgImageView.bounds];
                splashImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                if ([urlString containsString:@".gif"])
                {
                    NSData *gifData = [NSData dataWithContentsOfFile:[self fileUrlStringFromUrlString:urlString]];
                    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
                    webView.scalesPageToFit = YES;
                    webView.userInteractionEnabled = NO;//用户不可交互
                    [webView loadData:gifData MIMEType:@"image/gif" textEncodingName:@"" baseURL:[NSURL URLWithString:@""]];
                    [self.bgImageView addSubview:webView];
                    
                }
                else
                {
                    XYLog(@"~~~~~~~inter2");
                    splashImageView.image = [UIImage imageWithContentsOfFile:[self fileUrlStringFromUrlString:urlString]];
                    splashImageView.userInteractionEnabled = YES;
                    self.bgImageView.userInteractionEnabled = YES;
                    [UIView beginAnimations:@"ToggleViews" context:nil];
                    [UIView setAnimationDuration:1.0];
                    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
                    splashImageView.alpha = 0;
                    [self.bgImageView addSubview:splashImageView];
                    splashImageView.alpha = 1;
                    [UIView commitAnimations];
                }
            }
            else if (page.style == SSPageStyleImage && self.webUrl.length != 0)
            {
                UIImageView *splashImageView = [[UIImageView alloc] initWithFrame:self.bgImageView.bounds];
                splashImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                self.bgImageView.userInteractionEnabled = YES;
                
                if ([urlString containsString:@".gif"]){
                    CGRect frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
                    NSData *gifData = [NSData dataWithContentsOfFile:[self fileUrlStringFromUrlString:urlString]];
                    UIWebView *webView = [[UIWebView alloc] initWithFrame:frame];
                    webView.scalesPageToFit = YES;
                    webView.userInteractionEnabled = YES;//用户不可交互
                    [webView loadData:gifData MIMEType:@"image/gif" textEncodingName:@"" baseURL:[NSURL URLWithString:@""]];
                    
                    [self.bgImageView addSubview:webView];
                    UIView *frontView = [[UIView alloc] initWithFrame:frame];
                    frontView.backgroundColor = [UIColor clearColor];
                    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showStartPageDetailPage:)];
                    [frontView addGestureRecognizer:recognizer];
                    [self.bgImageView addSubview:frontView];
                }
                else
                {
                    
                    XYLog(@"~~~~~~~inter3");
                    splashImageView.image = [UIImage imageWithContentsOfFile:[self fileUrlStringFromUrlString:urlString]];
                    splashImageView.userInteractionEnabled = YES;
                    self.bgImageView.userInteractionEnabled = YES;
                    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showStartPageDetailPage:)];
                    [splashImageView addGestureRecognizer:recognizer];
                    [UIView beginAnimations:@"ToggleViews22" context:nil];
                    [UIView setAnimationDuration:1.0];
                    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
                    
                    splashImageView.alpha = 0;
                    [self.bgImageView addSubview:splashImageView];
                    splashImageView.alpha = 1;
                    [UIView commitAnimations];
                }
            }
        } completion:^(BOOL finished) {
            XYLog(@"branch1");
            [self performSelector:@selector(showStartPagesFrom:) withObject:[NSNumber numberWithInt:++index] afterDelay:page.residenceTime];
        }];
    }];
}

- (void)enterBackground:(NSNotification *)notice
{
    [_player.moviePlayer pause];
    playbackTime = _player.moviePlayer.currentPlaybackTime;
    
    XYLog(@"background:%f",playbackTime);
}

- (void)enterForeground:(NSNotification *)notice
{
    _player.moviePlayer.currentPlaybackRate = 1.0;
    _player.moviePlayer.currentPlaybackTime = playbackTime;
    
    [_player.moviePlayer play];
    
    XYLog(@"Foreground:%f",playbackTime);
}

- (void)setDefaultPlaybackTime:(NSNotification *)notification
{
    int reason = [[[notification userInfo] valueForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];
    if (reason == MPMovieFinishReasonUserExited) {
        NSUserDefaults *defalts= [NSUserDefaults standardUserDefaults];
        NSTimeInterval time = _player.moviePlayer.currentPlaybackTime;
        [defalts setDouble:time forKey:@"PLAYBACKTIME"];
        [defalts synchronize];
        
        [[NSNotificationCenter defaultCenter] removeObserver:_player name:MPMoviePlayerPlaybackDidFinishNotification object:_player.moviePlayer];
        //        [self dismissViewControllerAnimated:YES completion:NULL];
    }
}

- (void)skip:(id)sender
{
    XYLog(@"===========skip_method");
    XYLog(@"branch2");
    _skipped = YES;
    if (self.queue) {
        [self.queue cancelAllOperations];
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    if (self.bgImageView.superview) {
        [self.bgImageView removeFromSuperview];
    }
    
    if (_player.view)
    {
        [_player.moviePlayer stop];
        [_player.view removeFromSuperview];
    }
    
    if ([self.delegate respondsToSelector:@selector(splashDidfinished:)])
    {
        [self.delegate performSelector:@selector(splashDidfinished:) withObject:self];
    }
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    self.bgImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    
    self.bgImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    CGSize viewSize = [UIScreen mainScreen].bounds.size;
    NSString *viewOrientation = @"Portrait";    //横屏请设置成 @"Landscape"
    NSString *launchImage = nil;
    
    NSArray* imagesDict = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"UILaunchImages"];
    for (NSDictionary* dict in imagesDict)
    {
        CGSize imageSize = CGSizeFromString(dict[@"UILaunchImageSize"]);
        
        if (CGSizeEqualToSize(imageSize, viewSize) && [viewOrientation isEqualToString:dict[@"UILaunchImageOrientation"]])
        {
            launchImage = dict[@"UILaunchImageName"];
        }
    }
    self.bgImageView.image = [UIImage imageNamed:launchImage];
    self.bgImageView.contentMode = UIViewContentModeScaleToFill;

    self.bgImageView.backgroundColor = [UIColor colorWithPatternImage:self.bgImageView.image];
    [self.view addSubview:self.bgImageView];
    
    self.skipButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.skipButton.backgroundColor = [UIColor darkGrayColor];
    self.skipButton.alpha = .5;
    //跳过按钮在屏幕下方中间
    self.skipButton.frame = CGRectMake(self.view.bounds.size.width-70, 30, 50, 30);
    //跳过按钮在屏幕右上角
    //    skipButton.frame = CGRectMake(self.view.bounds.size.width-60, 30, 80, 30);
    self.skipButton.titleLabel.font = [UIFont systemFontOfSize:14];
    self.skipButton.layer.cornerRadius = 3;
    self.skipButton.layer.masksToBounds = YES;
    self.skipButton.tag = 999;
    [self.skipButton setTitle:NSLocalizedString(@"跳过",nil) forState:UIControlStateNormal];
    [self.skipButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.skipButton addTarget:self action:@selector(skip:) forControlEvents:UIControlEventTouchUpInside];
    [self.skipButton setHidden:YES];
    [self.view addSubview:self.skipButton];
    
    indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    indicator.center = self.view.center;
    indicator.hidesWhenStopped = YES;
    [self.view addSubview:indicator];

    [self loadPagesConfig];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

-(void)showStartPageDetailPage:(SSSplashViewController *)splashController;
{
    if ([self.delegate respondsToSelector:@selector(showStartPageDetailPage:)])
    {
        XYLog(@"===========skip3");
        [self skip:nil];
        [self.delegate performSelector:@selector(showStartPageDetailPage:) withObject:self];
    }
}

@end
