//
//  NewsDetailPageController.m
//  FounderReader-2.5
//
//  Created by chenfei on 5/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NewsDetailPageController.h"
#import "Article.h"
#import <MediaPlayer/MediaPlayer.h>
#import "CacheManager.h"
#import "HttpRequest.h"
#import "DataLib/DataLib.h"
#import "UIAlertView+Helper.h"
#import <UMMobClick/MobClick.h>
#import "UIDevice-Reachability.h"
#import "DataLib/DataLib.h"
#import "CommentConfig.h"
#import "UserAccountDefine.h"
#import "AppStartInfo.h"
#import "YXLoginViewController.h"
#import "TemplateDetailPageController.h"
#import "OperateDefines.h"
#import "FCReader_OpenUDID.h"
#import "UIView+Extention.h"
#import "GreatestCommentPageController.h"
#import "ColumnBarConfig.h"

@interface NewsDetailPageController ()<YXLoginViewControllerDelegate>

@end

@implementation NewsDetailPageController
@synthesize sharedImage;
@synthesize sharedImageUrl;
@synthesize attAbstract;
@synthesize isAudioPlay;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UIMoviePlayerControllerDidEnterFullscreenNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UIMoviePlayerControllerDidExitFullscreenNotification" object:nil];

}
- (void)addWebView{
}

- (void)reload{
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    bgImageView.backgroundColor = [UIColor colorWithRed:226/255.0 green:226/255.0 blue:226/255.0 alpha:1];
    
    [self addWebView];
    
    // 放大缩小字体手势
    UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(adjustFontSize:)];
    [self.view addGestureRecognizer:pinchRecognizer];
    
    // 加载数据
    [self reload];
}

- (void)btnSelectClick:(UIButton *)button
{
    if (button.tag == 200) {
        button.selected = YES;
        ((UIButton *)[self.view viewWithTag:201]).selected = NO;
        ((UIButton *)[self.view viewWithTag:202]).selected = NO;
        ((UIButton *)[self.view viewWithTag:203]).selected = NO;
        _lableFont.font = [UIFont fontWithName:[Global fontName] size:10];
    }
    else if (button.tag == 201) {
        button.selected = YES;
        ((UIButton *)[self.view viewWithTag:200]).selected = NO;
        ((UIButton *)[self.view viewWithTag:202]).selected = NO;
        ((UIButton *)[self.view viewWithTag:203]).selected = NO;
        _lableFont.font = [UIFont fontWithName:[Global fontName] size:12];
    }
    else if (button.tag == 202) {
        button.selected = YES;
        ((UIButton *)[self.view viewWithTag:201]).selected = NO;
        ((UIButton *)[self.view viewWithTag:200]).selected = NO;
        ((UIButton *)[self.view viewWithTag:203]).selected = NO;
        _lableFont.font = [UIFont fontWithName:[Global fontName] size:14];
    }
    else if (button.tag == 203) {
        button.selected = YES;
        ((UIButton *)[self.view viewWithTag:201]).selected = NO;
        ((UIButton *)[self.view viewWithTag:202]).selected = NO;
        ((UIButton *)[self.view viewWithTag:200]).selected = NO;
        _lableFont.font = [UIFont fontWithName:[Global fontName] size:16];
    }
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateFavoriteIcon];
    
    self.navigationController.navigationBarHidden = YES;

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    //iOS6下旋屏方法
    return UIInterfaceOrientationMaskPortrait;
}
//收藏
- (void)collect:(Article *)article
{
    CacheManager *manager = [CacheManager sharedCacheManager];
    [manager collect:article];
    //[FounderEventRequest articlefavoriteDateAnaly:article.fileId column:self.column.fullColumn];
	[Global showTip:NSLocalizedString(@"收藏成功",nil)];
}
//取消收藏
- (void)unCollect:(int)articleId
{
    CacheManager *manager = [CacheManager sharedCacheManager];
    [manager unCollect:articleId];
    [Global showTip:NSLocalizedString(@"取消收藏",nil)];
}

/**
 *  收藏按钮点击
 *
 *  @param sender 点击的button
 */
- (void)collectItemClicked:(id)sender
{
    Article *article = [articles objectAtIndex:currentIndex];
    CacheManager *manager = [CacheManager sharedCacheManager];
    if ([manager isCollect:article.fileId]){
        [self unCollect:article.fileId];
    } else {
        [self collect:article];
    }

    [self updateFavoriteIcon];
    
}
- (void)quadCurveMenu:(QuadCurveMenu *)menu didSelectIndex:(NSInteger)idx
{

    if (idx == 0)
    {
        isNight = !isNight;
        if (appDelegate().window.alpha==1.0) {
            appDelegate().window.alpha = .6;
        }
        else
        {
            appDelegate().window.alpha = 1.0;
        }
        
    }
    else if (idx == 1)
    {
        [self collectItemClicked:nil];
    }
    else if (idx == 2)
    {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:.5];
        _viewFont.frame = CGRectMake(0, kSHeight-200, kSWidth, 200);
        [UIView commitAnimations];
    }
}

- (void)backItemClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
/**
 *  点赞
 *
 *  @param sender 点击的button
 */
- (void)greatItemClicked:(id)sender
{
    [self.footview.greetBtn setImage:[UIImage imageNamed:@"toolbar_love_press"] forState:UIControlStateNormal];
    self.footview.greetLabel.textColor = [ColumnBarConfig sharedColumnBarConfig].column_all_color;
    self.footview.greetLabel.hidden = NO;
    Article *article = [articles objectAtIndex:currentIndex];
    BOOL bestId = [[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"%ld",(long)article.fileId]];
    if (bestId == 0)
    {
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[NSString stringWithFormat:@"%ld",(long)article.fileId]];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }
    if ([self isGreaded:article]){
        [Global showTip:NSLocalizedString(@"您已经点过赞了。",nil)];
        return;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@/api/event", [AppConfig sharedAppConfig].serverIf];
    NSString *bodyString = [NSString stringWithFormat:@"sid=%@&id=%d&type=0&eventType=2",[AppConfig sharedAppConfig].sid,article.fileId];
    NSData *data = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    
    HttpRequest *request = [HttpRequest requestWithURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:data];
    
    [request setCompletionBlock:^(NSData *data) {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers  error:nil];
        NSString *str = [NSString stringWithFormat:@"%d",[[dic objectForKey:@"countPraise"] intValue]];
        if (str != nil && ![str isEqualToString:@""])
        {
                if (![self isGreaded:article])
                {
                    if ([article.greatCount intValue]/10000)
                        self.footview.greetLabel.text = [NSString stringWithFormat:@"%d%@+", ([article.greatCount intValue] + 1)/10000, NSLocalizedString(@"万", nil)];
                    else
                        self.footview.greetLabel.text = [NSString stringWithFormat:@"%d", [article.greatCount intValue] + 1];

                }
            [self saveGread:article];
           
        }
    }];
    
    [request setFailedBlock:^(NSError *error) {
        
    }];
    
    [request startAsynchronous];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{

    if (alertView.tag == 222) {
        if (buttonIndex == 0)
        {
            YXLoginViewController *controller = [[YXLoginViewController alloc]init];
            controller.isNavBack = YES;
            [self.navigationController pushViewController:controller animated:YES];
        }
    }
    else
    {
        if (buttonIndex == 0)
        {
            YXLoginViewController *controller = [[YXLoginViewController alloc]init];
            controller.delegate = self;
            [controller goBackIOS6Button:controller];
            [self.navigationController pushViewController:controller animated:YES];
        }
    }
    
}

- (void)updateIndex
{
}

#pragma mark - WebWidgetDelegate
/**
 *  播放视频
 *
 *  @param urlString 视频url
 */
- (void)playVideo:(NSString *)urlString
{
    appDelegate().isAllOrientation = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoStarted:)name:@"UIMoviePlayerControllerDidEnterFullscreenNotification"object:nil];// 播放器即将播放通知
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoFinished:)name:@"UIMoviePlayerControllerDidExitFullscreenNotification"object:nil];// 播放器即将退出通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoStarted:) name:UIWindowDidBecomeVisibleNotification object:nil];//进入全屏
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoFinished:) name:UIWindowDidBecomeHiddenNotification object:nil];//退出全屏
    MPMoviePlayerViewController *playerController = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:urlString]];
    playerController.moviePlayer.movieSourceType = MPMovieSourceTypeFile;
    [playerController.moviePlayer prepareToPlay];
    [playerController.moviePlayer play];
    
    [self presentMoviePlayerViewControllerAnimated:playerController];
}

- (void)videoImageClicked:(NSString *)urlString
{
    [self playVideo:urlString];
}

- (void)videoStarted:(NSNotification *)notification {
    // 开始播放
    
    appDelegate().isAllOrientation = YES;
}

- (void)videoFinished:(NSNotification *)notification {
    //完成播放
    
    appDelegate().isAllOrientation = NO;
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val =UIInterfaceOrientationPortrait;
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}
#pragma mark  scale font

- (void)adjustFontSize:(UIPinchGestureRecognizer *)sender
{
    self.hudView.hidden = YES;
    self.bringView.hidden = YES;
    [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"onceFontHint"];
    //开始时scale这个值是1，即缩放率为1
    if (sender.state == UIGestureRecognizerStateEnded) {
        if (sender.scale < 1)
            [self zoomOut];
        else
            [self zoomIn];
    }
}

- (void)zoomInOut:(NSString *)size
{
}
- (void)zoomInOut:(NSString *)size withIS:(int)top
{
    return;
}
- (void)zoomIn
{
    NSString *size = [Global fontSize];
    if ([size isEqualToString:@"hg"])
    {
        [self zoomInOut:@"hg" withIS:2];
    }
    else if([size isEqualToString:@"lg"])
    {
        [Global setFontSize:@"hg"];
        [self zoomInOut:@"hg"];
    }
    else if([size isEqualToString:@"md"])
    {
        [Global setFontSize:@"lg"];
        [self zoomInOut:@"lg"];
    }
    else if([size isEqualToString:@"sm"])
    {
        [Global setFontSize:@"md"];
        [self zoomInOut:@"md"];
    }
    
}

- (void)zoomOut
{
    NSString *size = [Global fontSize];
    if ([size isEqualToString:@"sm"])
    {
        [self zoomInOut:@"sm" withIS:1];
    }
    else if([size isEqualToString:@"md"])
    {
        [Global setFontSize:@"sm"];
        [self zoomInOut:@"sm"];
    }
    else if([size isEqualToString:@"lg"])
    {
        [Global setFontSize:@"md"];
        [self zoomInOut:@"md"];
    }
    else if([size isEqualToString:@"hg"])
    {
        [Global setFontSize:@"lg"];
        [self zoomInOut:@"lg"];
    }
}

#pragma mark -

/**
 *  回到上一页
 */
- (void)goPrePage:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
    return;
    
}

/**
 *  去下一页
 */
- (void)goNextPage:(id)sender
{
    [self gotoCommentList];
    return;
}

-(void)goBackIOS6
{
    [self.navigationController popViewControllerAnimated:YES];
}


@end
