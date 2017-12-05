//
//  ImageDetailPageController.m
//  FounderReader-2.5
//
//  Created by chenfei on 5/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ImageDetailPageController.h"
#import "FileRequest.h"
#import "DataLib/DataLib.h"
#import "Article.h"
#import "Attachment.h"
#import "ImagePagingViewCell.h"
#import "AppStartInfo.h"
#import "NewsDetailPageController.h"
#import <UMMobClick/MobClick.h>
#import "OperateDefines.h"
#import "FCReader_OpenUDID.h"
#import "UIApplication+NetworkActivity.m"
#import "NJEventRequest.h"
#import "ColumnBarConfig.h"
#import "AppConfig.h"
#import "FounderEventRequest.h"

@interface ImageDetailPageController ()

@property(nonatomic, retain) NSArray *pictures;

@end

@implementation ImageDetailPageController

@synthesize pictures,openFirstIndex;


- (id)init
{
    self = [super init];
    if (self) {
        isSummaryViewShow = YES;
        openFirstIndex = [NSNumber numberWithInt:0];
    }
    return self;
}


- (void)pagingViewDidScroll:(ATPagingView *)sender
{
    UIScrollView *scroll = sender.scrollView;
    if(scroll.contentOffset.x < -2){
        //左滑到底返回首页
        scroll.scrollEnabled = NO;
        [self backItemClicked:nil];
    }else if(scroll.contentOffset.x > ([pictures count]-1)*(20+kSWidth)){
        //右滑到底弹出评论
        scroll.scrollEnabled = NO;
        [self showGreatComment];
    }else{
        scroll.scrollEnabled = YES;
    }
}

/**
 *  图片描述文字显示与隐藏
 */
- (void)descItemClicked:(id)sender
{
    UIBarButtonItem *descItem = [[toolbar items] objectAtIndex:0];
    if (isSummaryViewShow) {
        [descItem setImage:[UIImage imageNamed:@"toolbar_open"]];
        [UIView animateWithDuration:UINavigationControllerHideShowBarDuration animations:^(void) {
            summaryView.alpha = 0;
            summaryViewFen.alpha = 0.8;
        }];
    } else {
        [descItem setImage:[UIImage imageNamed:@"toolbar_close"]];
        [UIView animateWithDuration:UINavigationControllerHideShowBarDuration animations:^(void) {
            summaryView.alpha = 0.8;
            summaryViewFen.alpha = 0;
        }];
    }
    isSummaryViewShow = !isSummaryViewShow;
}
/*
- (NSString *)newsTitle
{
    NSString *text = @"";
    Article *article = [articles objectAtIndex:currentIndex];
    if (article.title.length)
        text = article.title;
    
    return text;
}

- (UIImage *)newsImage
{
    ImagePagingViewCell *currentCell = (ImagePagingViewCell *)[pagingView viewForPageAtIndex:pagingView.currentPageIndex];
    return currentCell.image;
}

- (NSString *)newsAbstract
{
    Attachment *attachment = [pictures objectAtIndex:pagingView.currentPageIndex];
    NSString *text = attachment.description;
    if (![attachment.description isKindOfClass:[NSString class]])
          text = @"";
      return text;
}
*/

- (UIImage *)currentImage
{
    ImagePagingViewCell *currentCell = (ImagePagingViewCell *)[pagingView viewForPageAtIndex:pagingView.currentPageIndex];
    return currentCell.image;
}

- (void)saveItemClicked:(id)sender
{
    if ([Global isWanNetWorking])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"您正处于3G/4G模式下，下载图片将产生一定的流量，是否继续下载？"
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:NSLocalizedString(@"确定",nil),NSLocalizedString(@"取消",nil), nil];
        [alert show];

    }
    else{
       UIImageWriteToSavedPhotosAlbum([self currentImage], self, @selector(image:didFinishSavingWithError:contextInfo:), 0);
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0){
    //下载图片
        UIImageWriteToSavedPhotosAlbum([self currentImage], self, @selector(image:didFinishSavingWithError:contextInfo:), 0);
    }
    
}
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error)
        [Global showTip:NSLocalizedString(@"保存失败",nil)];
    else
        [Global showTip:NSLocalizedString(@"保存成功",nil)];
}

- (void)seeAll:(id)sender
{
    Article *article = [articles objectAtIndex:currentIndex];
    
    ArrayPageController *controller = [[ArrayPageController alloc] init];
    controller.columnId = article.columnId;
    controller.delegate = self;
    controller.pictures = pictures;
    self.title = NSLocalizedString(@"返回",nil);
    [self.navigationController pushViewController:controller animated:YES];
}

-(void)loadArticleContent{
   Article *article = [articles objectAtIndex:currentIndex];
    if(article.contentUrl && article.contentUrl.length > 0){
        [self loadAttachment];
    }
    else{
        NSString *url = [NSString stringWithFormat:@"%@/api/getArticle?&sid=%@&aid=%d",[AppConfig sharedAppConfig].serverIf, [AppConfig sharedAppConfig].sid, article.fileId];
        HttpRequest *request = [HttpRequest requestWithURL:[NSURL URLWithString:url]];
        [request setCompletionBlock:^(NSData *data) {
            
            if (!data) {
                [Global showTipNoNetWork];
                return;
            }
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers  error:nil];
            article.contentUrl = [dic objectForKey:@"contentUrl"];
            [self loadAttachment];
        }];
        [request setFailedBlock:^(NSError *error) {
            [Global showWebErrorView:self];
            return;
        }];
        [request startAsynchronous];
    }
}

- (void)loadAttachment
{
    Article *article = [articles objectAtIndex:currentIndex];
    //加载工具栏
    isDiscussClose = article.discussClosed;
    [self updateToolbar];
    NSString *url = [NSString stringWithFormat:@"%@/api/getArticle?&sid=%@&aid=%d&cid=%d",[AppConfig sharedAppConfig].serverIf, [AppConfig sharedAppConfig].sid, article.fileId, self.column.columnId];
    //测试后期修改
    FileRequest *request = [[FileRequest alloc] initWithURLNoCache:url];
    [request setCompletionBlock:^(NSData *data) {
        //guo 2013/2/5 缓存不更新
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers  error:nil];
        
        if (article.articleType == ArticleType_IMAGE) {
            article.attAbstract = [dict objectForKey:@"abstract"];
            article.imageUrl = [dict objectForKey:@"pic1"];//article对象地址还是指向的articles里唯一的article
            article.title = [dict objectForKey:@"title"];
        }else {
            // 图片展示类其他应用场景，如新闻详情h5页面点击图片
            article.attAbstract = [dict objectForKey:@"attAbstract"];
            article.imageUrl = [dict objectForKey:@"imageUrl"];
        }
        article.title = [dict objectForKey:@"title"];
        NSArray *imageArry = [dict objectForKey:@"images"];
        NSArray *imageAdv = [dict objectForKey:@"adv"];
        NSMutableArray *allArray = [NSMutableArray arrayWithArray:imageArry];
        NSMutableArray *mutAdvs = [[NSMutableArray alloc] init];
        
        if (imageAdv.count) {
            // 排除失效广告
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateStyle:NSDateFormatterMediumStyle];
            [formatter setTimeStyle:NSDateFormatterShortStyle];
            [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
            
            for (int i = 0; i < imageAdv.count; i++) {
                NSDictionary *dic = imageAdv[i];
                
                NSDate *dataStart = [formatter dateFromString:[dic objectForKey:@"startTime"]];
                NSTimeInterval timeStart = [dataStart timeIntervalSince1970];
                
                NSDate *dataEnd = [formatter dateFromString:[dic objectForKey:@"endTime"]];
                NSTimeInterval timeEnd = [dataEnd timeIntervalSince1970];
                
                NSTimeInterval timeNow = [[NSDate date] timeIntervalSince1970];
                if (timeStart < timeNow && timeNow < timeEnd) {
                    [mutAdvs addObject:dic];
                }
            }
            // 如果有效的广告有两条或多于两条时
            if (mutAdvs.count >= 2) {
                // 查询并储存最新一条
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateStyle:NSDateFormatterMediumStyle];
                [formatter setTimeStyle:NSDateFormatterShortStyle];
                [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
                float newStart = 0.0;
                NSMutableArray *newAdvs = [[NSMutableArray alloc] init];
                for (int i = 0; i < mutAdvs.count; i++) {
                    NSDictionary *dic = mutAdvs[i];
                    NSDate *dataStart = [formatter dateFromString:[dic objectForKey:@"startTime"]];
                    NSTimeInterval timeStart = [dataStart timeIntervalSince1970];
                    if (timeStart > newStart) {
                        newStart = timeStart;
                        if (!newAdvs.count) {
                            [newAdvs addObject:dic];
                        }
                        else
                        {
                            [newAdvs removeObjectAtIndex:0];
                            [newAdvs addObject:dic];
                        }
                    }
                }
                [allArray addObjectsFromArray:newAdvs];
            }
            else
            {
                [allArray addObjectsFromArray:mutAdvs];
            }
        }
        self.pictures = [Attachment attachmentsFromArray:allArray];
        [Global hideTip];
        [pagingView reloadData];
        pagingView.currentPageIndex = [openFirstIndex intValue];
        
        self.contentShareUrl = [dict objectForKey:@"shareUrl"];
        
        Attachment *pic = [self.pictures firstObject];
        self.contentShareImageUrl = pic.imageUrl;
        //[FounderEventRequest articleviewDateAnaly:article.fileId column:self.column.fullColumn];
    }];
    
    [request setFailedBlock:^(NSError *error) {
        [Global hideTip];
        [Global showTipNoNetWork];
    }];
    
    [request startAsynchronous];
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    _lab = [[UILabel alloc] init];
    
    pagingView = [[ATPagingView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-100)];
    pagingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    pagingView.delegate = self;
    pagingView.horizontal = YES;
    
    [self.view addSubview:pagingView];

    _btnDownLoad = [[UIButton alloc] init];
    _btnDownLoad.hidden = YES;
    _btnDownLoad.frame = CGRectMake(kSWidth-50, kSHeight-50, 32, 32);
    [_btnDownLoad setImage:[UIImage imageNamed:@"toolbar_save_nor"] forState:UIControlStateNormal];
    [_btnDownLoad setImage:[UIImage imageNamed:@"toolbar_save_pre"] forState:UIControlStateHighlighted];
    [_btnDownLoad addTarget:self action:@selector(saveItemClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btnDownLoad];
    
    
    summaryView = [[SummaryView alloc] initWithFrame:CGRectMake(0, kSHeight-180, kSWidth, 130)];
    summaryView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:summaryView];

    
    //图集上方的分页表示1/4
    summaryViewFen = [[SummaryView alloc] initWithFrame:CGRectMake(-kSWidth/2.0 + 32, kSHeight - 65, self.view.frame.size.width, 30)];
    summaryViewFen.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    summaryViewFen.hidden = YES;
    [self.view addSubview:summaryViewFen];
    
    _summaryViewFenTop = [[SummaryView alloc] initWithFrame:CGRectMake(0, 0, kSWidth, 30)];
    _summaryViewFenTop.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    _summaryViewFenTop.hidden = NO;
    [self.view addSubview:_summaryViewFenTop];
    //加载图片数据
    [self loadAttachment];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressHandler:)];
    longPress.minimumPressDuration = 1.f;
    [self.view addGestureRecognizer:longPress];
    
}

- (void)longPressHandler:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        UIAlertController *actionSheet =
        [UIAlertController alertControllerWithTitle:nil
                                             message:nil
                                      preferredStyle:UIAlertControllerStyleActionSheet];
        [actionSheet addAction:
        [UIAlertAction actionWithTitle:@"保存图片"
                                 style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * _Nonnull action) {
                                   [self saveItemClicked:nil];
                               }]];
        [actionSheet addAction:
         [UIAlertAction actionWithTitle:@"取消"
                                  style:UIAlertActionStyleCancel
                                handler:NULL]];
        [self presentViewController:actionSheet
                           animated:YES
                         completion:NULL];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 获取收藏数
    [self updateFavoriteIcon];
    
    // 更新顶部索引
    [self updateIndex];
    
    self.navigationController.navigationBarHidden = YES;
    if (self.isFirst)
    {
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
        self.isFirst = 0;
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"statusBar"];
    }
    else
    {
        NSInteger isHiddenBar = [[[NSUserDefaults standardUserDefaults] objectForKey:@"statusBar"] integerValue];
        [[UIApplication sharedApplication] setStatusBarHidden:isHiddenBar withAnimation:UIStatusBarAnimationNone];
    }
    self.tabBarController.tabBar.hidden = YES;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [Global hideTip];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    self.navigationController.navigationBarHidden = NO;
    [[UIApplication sharedApplication] hideNetworkActivityIndicator];

}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        if (![UIApplication sharedApplication].statusBarHidden)
            [self cellClicked:nil];
    }
    
    ImagePagingViewCell *cell = (ImagePagingViewCell *)[pagingView viewForPageAtIndex:pagingView.currentPageIndex];
    [cell setZoomScale:1 animated:YES];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [pagingView willAnimateRotation];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if (UIInterfaceOrientationIsLandscape(fromInterfaceOrientation))
        [self cellClicked:nil];
    
    [pagingView didRotate];
    
    ImagePagingViewCell *cell = (ImagePagingViewCell *)[pagingView viewForPageAtIndex:pagingView.currentPageIndex];
    [cell setZoomScale:1 animated:YES];
}

- (void)updateIndex
{
    int currIdx = [pictures count] ? (int)pagingView.currentPageIndex+1 : 0;

    {
        self.title = [NSString stringWithFormat:@"%d / %ld", currIdx, (unsigned long)[pictures count]];
    }
}

#pragma mark - paging view delegate

- (NSInteger)numberOfPagesInPagingView:(ATPagingView *)pagingView
{
    return [pictures count];
}

- (UIView *)viewForPageInPagingView:(ATPagingView *)sender atIndex:(NSInteger)index
{
    ImagePagingViewCell *cell = (ImagePagingViewCell *)[pagingView dequeueReusablePage];
    if (cell == nil) {
        cell = [[ImagePagingViewCell alloc] init];
    }
    
    Attachment *attachment = [pictures objectAtIndex:index];
    [cell setImageUrl:attachment.imageUrl];
    [cell addTarget:self action:@selector(cellClicked:)];
    return cell;
    
}
- (void)btnClick:(UIButton *)button
{

}
- (void)currentPageDidChangeInPagingView:(ATPagingView *)sender
{

}

- (void)pagesDidChangeInPagingView:(ATPagingView *)sender
{
    if ([pictures count] == 0)
        return;
    
    [self updateIndex];
    Attachment *attachment = nil;
    if (pagingView.currentPageIndex == pictures.count) {
        attachment = [pictures objectAtIndex:pagingView.currentPageIndex-1];
    }
    else
        attachment = [pictures objectAtIndex:pagingView.currentPageIndex];
    Article *article = [articles objectAtIndex:currentIndex];
    NSString *description = [attachment.description isKindOfClass:[NSString class]] ? attachment.description : @"";
    if (pagingView.currentPageIndex == pictures.count) {
        summaryView.summaryLabel.text = @"";
    }
    else{
        //    textview 改变字体的行间距
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = 5;// 字体的行间距
        paragraphStyle.headIndent = 5;
        
        NSDictionary *attributes = @{
                                     NSFontAttributeName:[UIFont systemFontOfSize:13],
                                     NSParagraphStyleAttributeName:paragraphStyle,
                                     NSForegroundColorAttributeName:[UIColor whiteColor]
                                     };
       
        summaryView.summaryLabel.attributedText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n  %@", description] attributes:attributes];
    }
    
    if (attachment.picType == ArticleType_ADV_Set) {
        _lab.frame = CGRectMake(20, 20, 30, 20);
        _lab.textAlignment = NSTextAlignmentCenter;
        _lab.text = NSLocalizedString(NSLocalizedString(@"推广",nil), nil);
        _lab.hidden = NO;
        _lab.font = [UIFont fontWithName:@"Helvetica-Bold" size:14];
        _lab.textColor = [ColumnBarConfig sharedColumnBarConfig].column_all_color;
        [summaryView addSubview:_lab];
        summaryView.titleLabel.frame = CGRectMake(50, 0, kSWidth-50, 20);
        summaryView.titleLabel.text =  attachment.title;
    }
    else
    {
        _lab.hidden = YES;
        summaryView.titleLabel.frame = CGRectMake(4, 0, kSWidth-4, 20);
        summaryView.titleLabel.text =  article.title;
    }
    
    summaryView.summaryLabel.delegate = self;
    
    summaryViewFen.summaryLabel.text = @"";
    summaryViewFen.summaryLabel.text = [NSString stringWithFormat:@"%ld/%ld", pagingView.currentPageIndex+1, (unsigned long)[pictures count]];
    summaryViewFen.summaryLabel.frame = CGRectMake((kSWidth-100)/2, 20, 100, 30);
    summaryViewFen.summaryLabel.textAlignment = NSTextAlignmentCenter;
    summaryViewFen.summaryLabel.font = [UIFont systemFontOfSize:18];
    summaryViewFen.summaryLabel.delegate = self;
    
    _summaryViewFenTop.summaryLabel.text = @"";
    _summaryViewFenTop.summaryLabel.text = [NSString stringWithFormat:@"%ld/%ld", pagingView.currentPageIndex+1, (unsigned long)[pictures count]];
    _summaryViewFenTop.summaryLabel.frame = CGRectMake((kSWidth-100)/2, 20, 100, 30);
    _summaryViewFenTop.summaryLabel.textAlignment = NSTextAlignmentCenter;
    _summaryViewFenTop.summaryLabel.font = [UIFont systemFontOfSize:18];
    _summaryViewFenTop.summaryLabel.delegate = self;
    
}

// a good place to start and stop background processing
- (void)pagingViewWillBeginMoving:(ATPagingView *)sender
{
    if (pagingView.currentPageIndex == [pictures count])
    {
    }
    else
    {
        ImagePagingViewCell *cell = (ImagePagingViewCell *)[pagingView viewForPageAtIndex:pagingView.currentPageIndex];
        [cell setZoomScale:1 animated:YES];
    }
}

- (void)pagingViewDidEndMoving:(ATPagingView *)sender
{
    if (pagingView.currentPageIndex == [pictures count])
    {

    }
    else
    {
        ImagePagingViewCell *cell = (ImagePagingViewCell *)[pagingView viewForPageAtIndex:pagingView.currentPageIndex];
        [cell setZoomScale:1 animated:YES];
    }
}

#pragma mark -
/**
 *  点击大图， 工具栏隐藏，描述隐藏，下载按钮显示...
 *
 *  @param sender 
 */
- (void)cellClicked:(ImagePagingViewCell *)sender
{
    self.footview.hidden = !self.footview.hidden;
    
    //if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
    //    return;
    summaryViewFen.hidden = !summaryViewFen.hidden;
    [UIApplication sharedApplication].statusBarHidden = ![UIApplication sharedApplication].statusBarHidden;
    int isHiddenBar = 0;
    if ([UIApplication sharedApplication].statusBarHidden) {
        isHiddenBar = 1;
    }
    else
    {
        isHiddenBar = 0;
    }
    [[NSUserDefaults standardUserDefaults] setInteger:isHiddenBar forKey:@"statusBar"];
    // summary view
    [self descItemClicked:nil];
    // status bar
    
    // toolbar
    CGRect newFrame = toolbar.frame;
    _summaryViewFenTop.hidden = !_summaryViewFenTop.hidden;
    _btnDownLoad.hidden = !_btnDownLoad.hidden;
    if (toolbar.frame.origin.y == self.view.frame.size.height)
    {
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
             newFrame.origin.y = self.view.frame.size.height - 44;
        }
        else
        {
             newFrame.origin.y = self.view.frame.size.height - 44 -20;
        }
    }
    else
        newFrame.origin.y = self.view.frame.size.height;
  
    if (pagingView.currentPageIndex == pictures.count)
    {
        
    }
    else
    {
        [UIView animateWithDuration:UINavigationControllerHideShowBarDuration animations:^(void) {
            toolbar.frame = newFrame;
        }];
    }
}

#pragma mark - ArrayPageControllerDelegate

- (void)cellDidSelectedAtIndex:(int)index
{
    pagingView.currentPageIndex = index;
}


- (void)backItemClicked:(id)sender
{
    if(self.navigationController){
        [self.navigationController popViewControllerAnimated:YES];
    }
    else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    Article *article = [articles objectAtIndex:currentIndex];
   // [FounderEventRequest articlereturnDateAnaly:article.fileId column:self.column.fullColumn];
}
- (void)greatItemClicked:(id)sender
{
    [self.footview.greetBtn setImage:[UIImage imageNamed:@"toolbar_love_press"] forState:UIControlStateNormal];
    self.footview.greetLabel.textColor = [ColumnBarConfig sharedColumnBarConfig].column_all_color;;
    self.footview.greetLabel.hidden = NO;
    Article *article = [articles objectAtIndex:currentIndex];
    BOOL bestId = [[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"%ld",(long)article.fileId]];
    if (bestId == 0)
    {
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[NSString stringWithFormat:@"%ld",(long)article.fileId]];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

    if ([self isGreaded:article])
        return;

    NSString *urlStr = [NSString stringWithFormat:@"%@/api/event",[AppConfig sharedAppConfig].serverIf];
    NSString *bodyString = [NSString stringWithFormat:@"sid=%@&id=%d&type=0&eventType=2",[AppConfig sharedAppConfig].sid,article.fileId];
    NSData *data = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    HttpRequest *request = [HttpRequest requestWithURL:[NSURL URLWithString:urlStr]];
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
                    self.footview.greetLabel.text = [NSString stringWithFormat:@"%d%@+", ([article.greatCount intValue]+1)/10000, NSLocalizedString(@"万",nil)];
                else
                    self.footview.greetLabel.text = [NSString stringWithFormat:@"%d", [article.greatCount intValue]+1];
                
//                article.greatCount = [NSString stringWithFormat:@"%d", [article.greatCount intValue]+1];
            }
            //保存该稿件已经点赞过状态
            [self saveGread:article];
        }

    }];
    
    [request setFailedBlock:^(NSError *error) {
        
    }];
    
    [request startAsynchronous];
}

- (void)collectItemClicked:(id)sender
{

}
/**
 *  收藏
 */
- (void)collect:(Article *)article
{
    CacheManager *manager = [CacheManager sharedCacheManager];
    [manager collect:article];
    [Global showTip:NSLocalizedString(@"收藏成功",nil)];
   // [FounderEventRequest articlefavoriteDateAnaly:article.fileId column:self.column.fullColumn];
}

- (void)unCollect:(int)articleId
{
    CacheManager *manager = [CacheManager sharedCacheManager];
    [manager unCollect:articleId];
    [Global showTip:NSLocalizedString(@"取消收藏",nil)];
}


- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    
    return NO;
}

- (void)goBothBack
{
    [super goBothBack];
    //文章返回事件
    Article *article = [articles objectAtIndex:currentIndex];
   // [FounderEventRequest articlereturnDateAnaly:article.fileId column:self.column.fullColumn];
}
@end
