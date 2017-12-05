//
//  NewsPageController.m
//  FounderReader-2.5
//
//  Created by chenfei on 4/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NewsPageController.h"
#import "Column.h"
#import "Article.h"
#import "MiddleCell.h"
#import "MoreCell.h"
#import "NewsListConfig.h"
#import "NSString+Helper.h"
#import "TemplateDetailPageController.h"
#import "AppStartInfo.h"
#import "HeaderNewsWidget.h"
#import "ImageDetailPageController.h"
#import "UIDevice-Reachability.h"
#import <MediaPlayer/MediaPlayer.h>
#import "DataLib/DataLib.h"
#import "GroupImage_MiddleCell.h"
#import "SpecialNewsPageController.h"
#import "GroupImageConfig.h"
#import "CDRTranslucentSideBar.h"
#import "UIImage+Helper.h"
#import "PersonalCenterViewController.h"
#import "UIView+Extention.h"
#import "NJEventRequest.h"
#import "SeeRootViewController.h"
#import "TemplateNewDetailViewController.h"
#import "FounderEventRequest.h"
#import "FounderIntegralRequest.h"
#import "ColumnRequest.h"
#import "SearchPageController.h"
#import "ColumnBarConfig.h"
#import "NewsCellUtil.h"
#import "GrayScale.h"
#import "XYAVPlayer.h"
#import "UIPlayerView.h"
#import "ColorStyleConfig.h"
#import "VersionUpdateView.h"
#import "ColumnBarConfig.h"
#import "VideoCell.h"


@interface NewsPageController () <HeaderNewsWidgetDelegate, CDRTranslucentSideBarDelegate,ScrollPlayVideoCellDelegate>
{
    UIView *_columnLabel;
    UIView *_headWhiteView;
    UIPlayerView *_listenView;
    NSString *_backFileID;
}
@property (nonatomic, retain) NSMutableDictionary *saveIsRedDic;
@property (nonatomic, retain) NSArray *groupImageConfigs;
@property (nonatomic, retain) NSArray *subColumns;


@property (nonatomic,assign) NSInteger lastOrCurrentPlayIndex;
@property (nonatomic,assign) NSInteger lastOrCurrentLightIndex;
//记录偏移值,用于判断上滑还是下滑
@property (nonatomic,assign) CGFloat lastScrollViewContentOffsetY;

@end

@implementation NewsPageController
@synthesize groupImageConfigs,subColumns,saveIsRedDic, listTableView;

#pragma mark - Private Methods
- (void)willRemoveSubview:(UIView *)subview
{
    [self removeVideoPlay];
}

- (void)removeVideoPlay
{
    UITableViewCell *cell1 = [self.listTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.lastOrCurrentPlayIndex inSection:0]];
    if([cell1 isKindOfClass:[VideoCell class]]){
        VideoCell *cell = (VideoCell *)cell1;
        [cell.player stop];
        cell.player = nil;
        self.lastOrCurrentPlayIndex = -1;
    }
}

- (void)playButtonClick:(UIButton *)sender
{
    NSInteger row = sender.tag-788;
    //if (row!=self.lastOrCurrentPlayIndex) {
        if(self.lastOrCurrentPlayIndex!=-1){
        [self stopVideoWithShouldToStopIndex:self.lastOrCurrentPlayIndex];
        }
        self.lastOrCurrentPlayIndex = row;
        [self playVideoWithShouldToPlayIndex:self.lastOrCurrentPlayIndex];
        
//    }else{
//        
//    }
}

- (void)stopVideoWithShouldToStopIndex:(NSInteger)shouldToStopIndex
{
    VideoCell *cell = [self.listTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:shouldToStopIndex inSection:0]];
//    cell.topblackView.hidden = NO;
    [cell.player stop];
    cell.player = nil;
}

- (void)playVideoWithShouldToPlayIndex:(NSInteger)shouldToPlayIndex
{
    VideoCell *cell = [self.listTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:shouldToPlayIndex inSection:0]];
    [cell shouldToPlay];
    self.lastOrCurrentPlayIndex = cell.row;
}

- (void)playerCloseAction
{
   self.lastOrCurrentPlayIndex = -1;
}

#pragma mark - 视频cell的下滑操作
- (void)testScrollView:(UIScrollView *)scrollview
{
    if (self.lastOrCurrentPlayIndex!=-1) {
        UITableViewCell *cell1 = [self.listTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.lastOrCurrentPlayIndex inSection:0]];
        if([cell1 isKindOfClass:[VideoCell class]]){
            VideoCell *cell=(VideoCell *)cell1;
            CGRect rectInTableView = [self.listTableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:self.lastOrCurrentPlayIndex inSection:0]];
            CGRect rect = [self.listTableView convertRect:rectInTableView toView:[self.listTableView superview]];
            CGFloat topSpacing = rect.origin.y;
            CGFloat bottomSpacing = self.view.frame.size.height-rect.origin.y-rect.size.height;
            NSLog(@"****rect=%@,****bottomSpacing:%f",NSStringFromCGRect(rect),bottomSpacing);
        //当视频播放部分移除可见区域的时候暂停
        if (topSpacing<-rect.size.height/3||bottomSpacing<-rect.size.height/3) {
            [cell.player stop];
            cell.player = nil;
            self.lastOrCurrentPlayIndex  = -1;
           }
        }
    }
}

-(void)fullScreenBtnClick:(NSNotification *)notice
{
    UIButton *fullScreenBtn = (UIButton *)[notice object];
    if(fullScreenBtn.isSelected){//全屏显示
        [self toFullScreenWithInterfaceOrientation:UIInterfaceOrientationLandscapeLeft];
    }else{
        [self backToCell];
    }
    
}
#pragma mark - 视频全屏播放
-(void)toFullScreenWithInterfaceOrientation:(UIInterfaceOrientation )interfaceOrientation
{
   [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:NO];
    UITableViewCell *cell1 = [self.listTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.lastOrCurrentPlayIndex inSection:0]];
    if([cell1 isKindOfClass:[VideoCell class]]){
       VideoCell *cell=(VideoCell *)cell1;
        [cell.player removeFromSuperview];
        cell.player.transform = CGAffineTransformIdentity;
        if (interfaceOrientation==UIInterfaceOrientationLandscapeLeft) {
            cell.player.transform = CGAffineTransformMakeRotation(-M_PI_2);
        }else if(interfaceOrientation==UIInterfaceOrientationLandscapeRight){
            cell.player.transform = CGAffineTransformMakeRotation(M_PI_2);
        }
        cell.player.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        cell.player.controlView.isFullScreen=YES;
        cell.player.playerLayer.frame =  CGRectMake(0,0, [UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height);
        [[UIApplication sharedApplication].keyWindow addSubview:cell.player];
        
    }
}

- (void)backToCell
{
    UITableViewCell *cell1 = [self.listTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.lastOrCurrentPlayIndex inSection:0]];
    if([cell1 isKindOfClass:[VideoCell class]]){
        VideoCell *cell=(VideoCell *)cell1;
        [cell.player removeFromSuperview];
        [UIView animateWithDuration:0.3 animations:^{
            cell.player.transform = CGAffineTransformIdentity;
            cell.player.controlView.isFullScreen=NO;
            cell.player.frame=cell.videoBackView.bounds;
            [cell.videoBackView addSubview:cell.player];
        } completion:^(BOOL finished) {
           [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
        }];
    }
}

#pragma mark - View implementation
- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.lastOrCurrentPlayIndex = -1;
    //注册点击全屏通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fullScreenBtnClick:) name:@"fullScreenBtnClickNotice" object:nil];
    
    _headWhiteView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSWidth, self.listTableViewY - 5)];
    if (self.columnHeaderHeight) {
        UIImage *backImage = [UIImage imageNamed:@"column_bar_header"];
        CGFloat backWidth = self.columnHeaderHeight * backImage.size.width/backImage.size.height;
        UIImageView *backView = [[UIImageView alloc] initWithFrame:CGRectMake((kSWidth-backWidth)/2.0f, kStatusBarHeight, backWidth, self.columnHeaderHeight)];
        backView.image = backImage;
        backView.userInteractionEnabled = YES;
        [_headWhiteView addSubview:backView];
    }
    
    if (self.isFirstNewsVC) {
        _headWhiteView.backgroundColor = [ColumnBarConfig sharedColumnBarConfig].columnBKColor;
    } else {
        _headWhiteView.backgroundColor = [ColorStyleConfig sharedColorStyleConfig].nav_bar_color;
    }
    [self.view addSubview:_headWhiteView];
    
    [self addTopColumnBar];
    
    self.groupImageConfigs = [GroupImageConfig groupImageConfigs];
    //已经读过的稿件
    saveIsRedDic = [[NSMutableDictionary alloc] initWithContentsOfFile:[cacheDirPath() stringByAppendingString:kSaveIsReadFileName]];
    if (!self.saveIsRedDic) {
        saveIsRedDic = [[NSMutableDictionary alloc] init];
    }
    self.listTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    leftController = [[PersonalCenterViewController alloc] init];
    self.leftController.view.frame = CGRectMake(0, 0, 240, self.view.bounds.size.height+64);
    
    sideBar = [[CDRTranslucentSideBar alloc] init];
    self.sideBar.delegate = self;
    self.sideBar.sideBarWidth = self.view.bounds.size.width * 0.5;
    self.sideBar.view.frame = CGRectMake(0, 0,self.view.bounds.size.width * 0.5, self.view.bounds.size.height);
    [self.sideBar setContentViewInSideBar:self.leftController.view];
    self.leftController.sideBar = self.sideBar;
    
    // Add PanGesture to Show SideBar by PanGesture
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    
    panGestureRecognizer.delegate = self;
    if (![AppStartInfo sharedAppStartInfo].ucTabisShow && self.viewControllerType == FDViewControllerForTabbarVC) {
        [self.view addGestureRecognizer:panGestureRecognizer];
    }
    
    //注册并接收监听，通知的名字要与发送的通知的名字一样
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openLiveDetailVC:) name:kOpenLiveDetailNotificationName object:nil];
}

// 加载音频播放窗口
- (void)loadAudioView {
    [[UIPlayerView shareInstance] unLoadBlock];
    NSInteger onlyOne = [[[NSUserDefaults standardUserDefaults] objectForKey:@"onlyOne"] integerValue];
    CGFloat playerViewY = onlyOne == 2 ? self.view.bounds.size.height-40 : self.view.bounds.size.height-40;
    [[UIPlayerView shareInstance] loadPlayerView:self.view frame:CGRectMake(0, playerViewY, kSWidth, 40)];
    //播放关闭按钮事件
    [UIPlayerView shareInstance].closeBtnClick = ^(UIPlayerView* playerView){
        return;
    };
    //播放操作按钮操作
    [UIPlayerView shareInstance].operationBtnClick = ^(UIPlayerView* playerView){
        return;
    };
    
    [UIPlayerView shareInstance].titleClick = ^(UIPlayerView* playerView){
        
        if(![playerView isCurrentView:self.view]){
            return;
        }
        Article *article = [playerView getCurrentArticle];
        if(article){
            Column *column = [columns objectAtIndex:columnBar.selectedIndex];
            [NewsCellUtil clickNewsCell:article column:column in:self];
        }
    };
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
        [self.navigationController setNavigationBarHidden:YES];
        self.edgesForExtendedLayout = UIRectEdgeTop;
    
        if (self.isNotOneLevelNewsVC) {
            [self.tabBarController.tabBar setHidden:YES];
        }else {
            NSInteger onlyOne = [[[NSUserDefaults standardUserDefaults] objectForKey:@"onlyOne"] integerValue];
            if (onlyOne == 2 && ![AppStartInfo sharedAppStartInfo].ucTabisShow)
            {
                self.edgesForExtendedLayout = UIRectEdgeAll;
                [self.tabBarController.tabBar setHidden:YES];
            }
            else
            {
                [self.tabBarController.tabBar setHidden:NO];
            }
        }
    if (self.viewControllerType == FDViewControllerForDetailVC) {
        self.tabBarController.tabBar.hidden = YES;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSInteger onlyOne = [[[NSUserDefaults standardUserDefaults] objectForKey:@"onlyOne"] integerValue];
        if (onlyOne == 2)
        {
            [self.tabBarController.tabBar setHidden:YES];
        }
        else
        {
            [self.tabBarController.tabBar setHidden:NO];
        }
    if(self.lastOrCurrentPlayIndex!=-1){
    [self removeVideoPlay];
    }
    [[UIPlayerView shareInstance] unLoadBlock];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    int forceUpdate = [AppStartInfo sharedAppStartInfo].forceUpdate;
    if ([self appUpdateHasNewVersion] && (forceUpdate == 0 || forceUpdate == 1)){
        [Global addMaskViewWithBlock:^{}];
        VersionUpdateView *updateView = [VersionUpdateView versionUpdateViewWithContent:[AppStartInfo sharedAppStartInfo].iOSDes];
        __weak __typeof(updateView)wupdateView = updateView;
        updateView.versionUpdateBlock = ^(BOOL isUpdate){
            // 非强制更新
            if (updateView.tag == 111) {
                if (isUpdate){
                    //点击转到下载页
                    NSURL *url = [NSURL URLWithString:[AppStartInfo sharedAppStartInfo].appDownloadUrl];
                    if (url) {
                        [[UIApplication sharedApplication] openURL:url];
                    }
                }else{
                    // 记住忽略的版本
                    [[NSUserDefaults standardUserDefaults] setObject:[AppStartInfo sharedAppStartInfo].appVersion forKey:appUpdateVersion];
                }
            }
            // 强制更新
            else if (updateView.tag == 110){
                if (isUpdate){
                    //点击转到下载页
                    NSURL *url = [NSURL URLWithString:[AppStartInfo sharedAppStartInfo].appDownloadUrl];
                    if (url) {
                        [[UIApplication sharedApplication] openURL:url];
                    }
                }else {
                    [self exitApplication];
                }
            }
            [Global removeMaskViewWithBlock:^{}];
            [wupdateView removeFromSuperview];
        };
        updateView.tag = forceUpdate == 1 ? 110 : 111;
        [[UIApplication sharedApplication].keyWindow addSubview:updateView];
    }
    [self loadAudioView];
}

// 动画退出App
- (void)exitApplication {
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UIWindow *window = app.window;
    
    [UIView animateWithDuration:1.0f animations:^{
        window.alpha = 0;
        window.frame = CGRectMake(0, window.bounds.size.width, 0, 0);
    } completion:^(BOOL finished) {
        exit(0);
    }];
}

-(void)leftAndRightButton{
    //此方法不做处理，由addTopColumnBar方法实现
    return;
}

//添加栏目导航条到导航栏下方
- (void)addTopColumnBar {
    
    UIView *userView = [[UIView alloc] initWithFrame:CGRectMake(0, kStatusBarHeight, 35, 40)];
    UITapGestureRecognizer *recognizer = nil;
    if (!self.isFirstNewsVC) {
        if (self.viewControllerType == FDViewControllerForTabbarVC) {
            recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(left)];
        }else{
            recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(returnBack)];
        }
    }else {
        if (self.viewControllerType == FDViewControllerForDetailVC) {
            recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(returnBack)];
        }else{
            recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(left)];
        }
    }
    
    userView.userInteractionEnabled = YES;
    userView.backgroundColor = [UIColor clearColor];
    [userView addGestureRecognizer:recognizer];
    UIImageView *imageviewLeft = [[UIImageView alloc] initWithFrame:CGRectMake(10, 11, 22, 22)];
    imageviewLeft.center = CGPointMake(userView.frame.size.width*0.5, userView.frame.size.height*0.5);
    imageviewLeft.contentMode = UIViewContentModeScaleToFill;
    [userView addSubview:imageviewLeft];
    
    UIView *moreView = [[UIView alloc] initWithFrame:CGRectMake(kSWidth-40, kStatusBarHeight, 35, 40)];
    moreView.userInteractionEnabled = YES;
    moreView.backgroundColor = [UIColor clearColor];
    UITapGestureRecognizer *recognizerRight = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(moreClick)];
    [moreView addGestureRecognizer:recognizerRight];
    imageviewRight = [[UIImageView alloc] initWithFrame:CGRectMake(12, 12, 16, 16)];
    imageviewRight.center = CGPointMake(moreView.frame.size.width*0.5, moreView.frame.size.height*0.5);
    imageviewRight.contentMode = UIViewContentModeScaleToFill;
    [moreView addSubview:imageviewRight];
    
    columnBar.enabled = YES;
    [_headWhiteView addSubview:columnBar];
    [_headWhiteView addSubview:userView];
    [_headWhiteView addSubview:moreView];
    
    
    UIView *searchView = [[UIView alloc] initWithFrame:CGRectMake(kSWidth-40, kStatusBarHeight, 35, 40)];
    searchView.userInteractionEnabled = YES;
    searchView.backgroundColor = [UIColor clearColor];
    UITapGestureRecognizer *recognizerSearch = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(searchClick)];
    [searchView addGestureRecognizer:recognizerSearch];
    UIImageView *imageviewSearch = [[UIImageView alloc] initWithFrame:CGRectMake(8, 10, 22, 22)];
    imageviewSearch.center = CGPointMake(searchView.frame.size.width*0.5, searchView.frame.size.height*0.5);
    imageviewSearch.contentMode = UIViewContentModeScaleToFill;
    imageviewSearch.image = [UIImage imageNamed:@"icon-nav-search"];
    [searchView addSubview:imageviewSearch];
    searchView.hidden = YES;
    [_headWhiteView addSubview:searchView];
    if (self.isFirstNewsVC) {
        if(self.columnHeaderHeight > 0){
            //顶部有导航栏情况
            imageviewLeft.image = [UIImage imageNamed:@"icon-head-high"];
            imageviewRight.image = [UIImage imageNamed:@"icon-edit-high"];
            if([AppConfig sharedAppConfig].isNavigationAddSearch){
                //顶部有导航栏＋搜索的情况
                moreView.center = CGPointMake(moreView.center.x, columnBar.center.y);
                moreView.backgroundColor = [ColumnBarConfig sharedColumnBarConfig].column_edit_backgroundColor;
                searchView.hidden = NO;
            }
            if ([AppStartInfo sharedAppStartInfo].ucTabisShow) {
                if ([AppConfig sharedAppConfig].isColumnEidtInRight) {
                    moreView.center = CGPointMake(moreView.center.x, columnBar.center.y);
                    moreView.backgroundColor = [ColumnBarConfig sharedColumnBarConfig].column_edit_backgroundColor;
                }
                if ([AppConfig sharedAppConfig].isChangeSearchAtUser) {
                    searchView.center = userView.center;
                    searchView.hidden = NO;
                }
                userView.hidden = YES;
            }
        }
        else{
            //顶部无导航栏情况
            if ([AppStartInfo sharedAppStartInfo].ucTabisShow) {
                if ([AppConfig sharedAppConfig].isChangeSearchAtUser) {
                    searchView.center = userView.center;
                    searchView.hidden = NO;
                }
                userView.hidden = YES;
#warning                后期加上去的
                imageviewRight.image = [UIImage imageNamed:@"icon-edit"];
            }else{
                moreView.backgroundColor = [ColumnBarConfig sharedColumnBarConfig].column_edit_backgroundColor;
                imageviewLeft.image = [UIImage imageNamed:@"icon-head"];
                imageviewRight.image = [UIImage imageNamed:@"icon-edit"];
            }
        }
    }else{
        imageviewRight.image = [UIImage imageNamed:@"icon-edit"];
        if ([AppStartInfo sharedAppStartInfo].ucTabisShow) {
            if (self.viewControllerType == FDViewControllerForTabbarVC) {
            imageviewLeft.image = [UIImage imageNamed:@"icon-head"];
            userView.hidden = YES;
            }else{
            imageviewLeft.image = [UIImage imageNamed:@"nav_bar_back"];
            }
        }else{
            if (self.viewControllerType == FDViewControllerForTabbarVC) {
                imageviewLeft.image = [UIImage imageNamed:@"icon-head"];
                userView.hidden = NO;
            }else{
                imageviewLeft.image = [UIImage imageNamed:@"nav_bar_back"];
            }
        }
        
    }
    moreView.hidden = NO;
    if(self.columns.count < 4){
        imageviewRight.superview.hidden = YES;
    }
    else{
        imageviewRight.superview.hidden = NO;
    }

    [self.view bringSubviewToFront:_headWhiteView];
}

- (void)returnBack
{
    if (self.viewControllerType == FDViewControllerForDetailVC) {
        self.navigationController.navigationBarHidden = NO;
    }
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)searchClick {
    //点击搜索
    SearchPageController *controller = [[SearchPageController alloc] init];
    controller.hidesBottomBarWhenPushed = YES;
    [appDelegate().window.rootViewController presentViewController:[Global controllerToNav:controller] animated:YES completion:nil];
}

// update版本更新
- (BOOL)appUpdateHasNewVersion {
    BOOL hasAppNewVersion = NO;
    NSString *lastestVersion = [AppStartInfo sharedAppStartInfo].appVersion;
    NSString *nowVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    
    NSString *localVersion = [[NSUserDefaults standardUserDefaults] stringForKey:appUpdateVersion];
    if (localVersion.length){
        hasAppNewVersion = [localVersion compare:lastestVersion options:NSNumericSearch] == NSOrderedDescending;
    }else{
        hasAppNewVersion = [lastestVersion compare:nowVersion options:NSNumericSearch] == NSOrderedDescending;
    }
    
    return hasAppNewVersion;
}

#pragma mark - 数据加载
- (void)loadColumnsFinished {
    [super loadColumnsFinished];
    
    imageviewRight.superview.hidden = self.columns.count < 4;
}

/**
 *  加载数据结束
 */
- (void)loadArticlesFinished {
    [super loadArticlesFinished];
    [self.listTableView reloadData];
}

/**
 *  加载更多数据失败
 */
- (void)loadMoreArticlesFailed
{
    [super loadMoreArticlesFailed];
    
    MoreCell *cell = (MoreCell *)[self.listTableView viewWithTag:200];
    if (cell)
        [cell hideIndicator];
}

#pragma mark - Gesture Handler
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if (self.scrollViewbg.contentOffset.x < 100) {
        return YES;
    }
    return NO;
}
- (void)handlePanGesture:(UIPanGestureRecognizer *)recognizer {
    
    //侧滑手势
    if (self.scrollViewbg.contentOffset.x>0)
        return;
    
    // if you have left and right sidebar, you can control the pan gesture by start point.
    CGPoint translatedPoint = [recognizer translationInView:self.view];
    if (translatedPoint.x > 0){
        if (recognizer.state == UIGestureRecognizerStateBegan) {
            
            CGPoint startPoint = [recognizer locationInView:self.view];
            if (startPoint.y<-self.listTableView.contentOffset.y + self.listTableView.tableHeaderView.frame.size.height+kSWidth*0.19375)
            {
                return;
            }
            
            if (startPoint.x < kSWidth/3.0)
            {
                self.sideBar.isCurrentPanGestureTarget = YES;
            }
        }
        
        [self.sideBar handlePanGestureToShow:recognizer inView:self.view];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == [self.articles count]){
        
        return  [NewsListConfig sharedListConfig].moreCellHeight;
    }
    
    Article *article = nil;
    if (self.articles.count > indexPath.row) {
        article = [self.articles objectAtIndex:indexPath.row];
    }
    
    return [NewsCellUtil getNewsCellHeight:article];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.articles.count>0) {
        if (hasMore) {
            return self.articles.count+1;
        }
        return self.articles.count;
    }
    
    else{
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    XYLog(@"articles:%@",articles);
    TableViewCell *cell = nil;
    if (0 == articles.count) {
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"zeroCell"];
        if (!cell){
            cell = [[TableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"zeroCell"];
        }
    }
    else if (indexPath.row == articles.count){\
        cell = [tableView dequeueReusableCellWithIdentifier:@"MoreCell"];
        if (!cell){
            cell = [[MoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MoreCell"];
            cell.tag = 200;
            [cell configWithTitle:@"" summary:@"" date:@"" thumbnailUrl:@"" columnId:0];
            
            
        }
    }
    else{
        Article *article = nil;
        if (self.articles.count >indexPath.row){
            
            article = [self.articles objectAtIndex:indexPath.row];
            article.isRead = [[self.saveIsRedDic valueForKey:[NSString stringWithFormat:@"%d",article.fileId]] boolValue];
        }
        else{
            cell = [tableView dequeueReusableCellWithIdentifier:@"zeroCell"];
            if (!cell)
                cell = [[TableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"zeroCell"] ;
            
            return cell;
        }
        Column *column = [columns objectAtIndex:columnBar.selectedIndex];
        BOOL isHideReadCount = [column.keyword[@"hideReadCount"] boolValue];
        article.isHideReadCount = isHideReadCount;
        cell = [NewsCellUtil getNewsCell:article in:tableView];
        if([cell isKindOfClass:[VideoCell class]]){
            VideoCell *cell2 = (VideoCell *)cell;
            cell2.row=indexPath.row;
            cell2.delegate=self;
        }
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == [self.articles count]) {
        return;
    }
    else
    {
        Article *currentAricle = nil;
        if (self.articles.count > indexPath.row) {
            currentAricle = [self.articles objectAtIndex:indexPath.row];
        }
        Column *column = [columns objectAtIndex:columnBar.selectedIndex];
        if (self.viewControllerType == FDViewControllerForDetailVC) {
            [NewsCellUtil clickNewsCell:currentAricle column:column in:self];
        }else{
            [NewsCellUtil clickNewsCell:currentAricle column:column in:self];
        }
        
        //存储已读信息
        currentAricle.isRead = YES;
        [self.saveIsRedDic setObject:[NSNumber numberWithBool:YES] forKey:[NSString stringWithFormat:@"%d",currentAricle.fileId]];
        [self.listTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (cell.tag == 200) {
        if (![UIDevice networkAvailable]) {
            [Global showTipNoNetWork];
            return;
        }
        if ([cell respondsToSelector:@selector(showIndicator)]) {
            [(MoreCell *)cell showIndicator];
        }
        
        Column *column = [columns objectAtIndex:columnBar.selectedIndex];
        // 获取实际最后一个文章
        /*
        Article *lastArticle = nil;
        for (NSInteger i = [self.articles count]-1; i >= 0; i++) {
            Article *article = self.articles[i];
            if (article.advID == 0) {
                lastArticle = article;
                break;(int)self.adCount
            }
        }
         */
        XYLog(@"==================== %d",(int)[self.articles count]+column.topArticleNum);
        Article *lastArticle = [self.articles lastObject];
        
        // 去掉广告的个数，使得rownumber都是20的倍数，方才能从接口获取正常的数据
#warning 不知道为什么加上这个先注释//
        [self loadMoreArticlesWithColumnId:column.columnId
                                lastFileId:lastArticle.fileId
                                 rowNumber:(int)([self.articles count]+column.topArticleNum-self.adCount)];
        }
}

- (void)sideBar:(CDRTranslucentSideBar *)sideBar1 willAppear:(BOOL)animated {
    [self.leftController updateUserInfo];
}

- (void)openLiveDetailVC:(NSNotification *)notify
{
    Article *article = [Article articleFromDict:notify.userInfo];
    //直播稿件
    SeeRootViewController *seeDetailController = [[SeeRootViewController alloc] init];
    seeDetailController.seeArticle = article;
    [self.navigationController pushViewController:seeDetailController animated:YES];
    //上传点击数
   // [FounderEventRequest founderEventClickAppinit:article];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)addHomeSearchView
{
    //增加首页搜索框
    if (!_searchView || (_searchView && !_searchView.superview)) {
        _searchView = [[SearchToolBarView alloc] initWithFrame:CGRectMake(0, 0, kSWidth, 40)];
        _searchView.alpha = 1.0;
        if([AppConfig sharedAppConfig].isHomeAddSearch && self.isMain && [ColumnBarConfig sharedColumnBarConfig].columnHeaderScale < 1.4){
            [self.listTableView addSubview:_searchView];
        }
    }
}


@end
