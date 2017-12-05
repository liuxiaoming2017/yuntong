//
//  PeopleDailyPDFPageController.m
//  FounderReader-2.5
//
//  Created by ld on 14-3-10.
//
//

#import "PeopleDailyPDFPageController.h"
#import "FMPDImageView.h"
#import "NewsPageController.h"
#import <DataLib/DataLib.h>
#import "FMPDImageView.h"
#import "PDFHotAreaDataModel.h"
#import "PDFPageDataModel.h"
#import "CGPathOverView.h"
#import "Article.h"
#import "TemplateDetailPageController.h"
#import "UIDevice-Reachability.h"
#import "ColumnBarConfig.h"
#import "Column.h"
#import "AppStartInfo.h"
#import "FileRequest.h"
#import "MFSideMenu.h"
#import "FileLoader.h"
#import "PDFpaper.h"
#import "PersonalCenterViewController.h"
#import "CDRTranslucentSideBar.h"
#import "TemplateNewDetailViewController.h"
#import "ATPagingView.h"

@interface PeopleDailyPDFPageController ()<CDRTranslucentSideBarDelegate,UIScrollViewDelegate,ATPagingViewDelegate,UIGestureRecognizerDelegate>
{
    CGSize currentPageSize;
    CGMutablePathRef pathRef;
    CGRect viewFrame;
    BOOL noCache;
}
#define PDFPAGESCALE 1259/2009
@property(nonatomic,retain) ATPagingView *pagingView;
@property(nonatomic, retain) CGPathOverView *overView;
@property(nonatomic, retain) PDFPageDataModel *currentPageInfo;
@property(nonatomic,retain)  PersonalCenterViewController *leftController;
@property (nonatomic, retain) CDRTranslucentSideBar *sideBar;
@end

@implementation PeopleDailyPDFPageController
@synthesize pagingView, pdfTimeLabel;
@synthesize overView;
@synthesize currentPageInfo;
@synthesize sideBar,leftController;

- (id)initWithFrame:(CGRect)rect isMain:(int)isMain
{
    self = [super init];
    if (self) {
        self.isMain = isMain;
        //viewFrame = rect;
    }
    return self;
}

- (void)setPagingViewFrame:(CGRect)rect{
    self.pagingView.frame = rect;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    viewFrame = self.view.bounds;
    if (self.isMain){
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:pathForMainBundleResource(@"column_bar_config.plist")];
        
        self.pdfTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 44, kSWidth-10, 32)];
        [self.view addSubview:self.pdfTimeLabel];
        CGFloat pagingViewH = kSHeight - kNavBarHeight - kTabBarHeight - kNavBarHeight - [[dict objectForKey:@"column_head_height"] floatValue] - 5;
        CGFloat scale = kSWidth/pagingViewH;
        pagingView = [[ATPagingView alloc] init];
        if (scale > PDFPAGESCALE) {//以高为准
            pagingView.frame = CGRectMake(0, 44+32, pagingViewH*PDFPAGESCALE,pagingViewH);
            pagingView.center = CGPointMake(kSWidth*0.5, pagingView.center.y);
        }else{
            pagingView.frame = CGRectMake(0, 44+32, kSWidth,kSWidth*PDFPAGESCALE);
        }
        self.pagingView.horizontal = NO;
    }
    else{
        self.pdfTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, kNavBarHeight, kSWidth-10, 32)];
        [self.view addSubview:self.pdfTimeLabel];
        CGFloat pagingViewH = kSHeight - kNavBarHeight - kTabBarHeight - 32 - 5;
        CGFloat scale = kSWidth/pagingViewH;
        pagingView = [[ATPagingView alloc] init];
        if (scale > PDFPAGESCALE) {//以高为准
            pagingView.frame = CGRectMake(0, kNavBarHeight+32, pagingViewH*PDFPAGESCALE,pagingViewH);
            pagingView.center = CGPointMake(kSWidth*0.5, pagingView.center.y);
        }else{
            pagingView.frame = CGRectMake(0,kNavBarHeight+32, kSWidth,kSWidth/PDFPAGESCALE);
        }
        self.pagingView.horizontal = ![AppConfig sharedAppConfig].isPaperVertical;
    }
    
    pagingView.scrollView.scrollsToTop = YES;
    self.pagingView.autoresizingMask = UIViewAutoresizingFlexibleWidth & UIViewAutoresizingFlexibleHeight;
    self.pagingView.delegate = self;
    
    [self.view addSubview:self.pagingView];
    
    // 左侧个人中心
    leftController = [[PersonalCenterViewController alloc] init];
    self.leftController.view.frame = CGRectMake(0, 0, 240, self.view.bounds.size.height+64);
    
    sideBar = [[CDRTranslucentSideBar alloc] init];
    self.sideBar.sideBarWidth = self.view.bounds.size.width * 0.5;
    self.sideBar.view.frame = CGRectMake(0, 0,self.view.bounds.size.width * 0.5, self.view.bounds.size.height);
    [self.sideBar setContentViewInSideBar:self.leftController.view];
    self.leftController.sideBar = self.sideBar;
}

#pragma mark - leftPage delegate

- (void)sideBar:(CDRTranslucentSideBar *)sideBar1 willAppear:(BOOL)animated {
   
    [self.leftController updateUserInfo];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    UIScrollView *scrollView = self.pagingView.scrollView;
    scrollView.tag = 1000;
    if (scrollView.contentOffset.x < 100) {
        return YES;
    }
    return NO;
}


- (void)handlePanGesture:(UIPanGestureRecognizer *)recognizer {
    
    if (self.allPages.count >1) {
        
        CGPoint translatedPoint = [recognizer translationInView:self.view];
        if (translatedPoint.x > 0){
            if (recognizer.state == UIGestureRecognizerStateBegan) {
                self.sideBar.isCurrentPanGestureTarget = YES;
            }
            
            [self.sideBar handlePanGestureToShow:recognizer inView:self.view];
        }
    }
}

- (void)tapBegin:(NSValue *)value
{
    currentPageInfo = [self.allPages objectAtIndex:pagingView.currentPageIndex];
    CGPoint point =[value CGPointValue];
    
    for (PDFHotAreaDataModel *hotInfo in self.currentPageInfo.hotAreaList) {
        
        if ([self createCGPath:hotInfo.hotArea hitPoint:point]) {
            UIView *view = [self.pagingView.scrollView viewWithTag:self.pagingView.currentPageIndex];
            [self showOverViewWithFrame:view.bounds addOnView:view];
            return;
        }
    }
}

-(void)tapEnd:(NSValue *)value
{
    [self removeOverviewFromSuperView];
    CGPoint point =[value CGPointValue];
    
    for (PDFHotAreaDataModel *hotInfo in self.currentPageInfo.hotAreaList) {
        
        if ([self createCGPath:hotInfo.hotArea hitPoint:point]) {
            //检查热区稿件是否在稿件列表中存在
            for(int j = 0; j < self.allPages.count; j++){
                PDFPageDataModel *page = [self.allPages objectAtIndex:j];
                BOOL isBreak = NO;
                for (int i = 0; i < page.articlesList.count; i++) {
                    Article *article = page.articlesList[i];
                    if (article.fileId == [hotInfo.articleID intValue]) {
                        hotInfo.contentUrl = article.contentUrl;
                        hotInfo.articleTitle = article.title;
                        isBreak = YES;
                        break;
                    }
                }
                if(isBreak){
                    break;
                }
            }
            
            if ([hotInfo.contentUrl isKindOfClass:[NSString class]] && hotInfo.contentUrl.length > 0) {
                
                [self showDetaillArticle:hotInfo];
            }
            return;
        }
    }
}

-(CGPoint)buildZoomPagePointAtIndex:(NSInteger)pointIndex pointsArry:(NSArray *)pointsArry
{
    CGPoint onePoint = CGPointMake(0, 0);
    NSArray *onePointAry = [[pointsArry objectAtIndex:pointIndex] componentsSeparatedByString:@","];
    if (onePointAry.count > 1) {
        //相对pdf页面的相对坐标
        NSString *str = [onePointAry objectAtIndex:0];
        onePoint.x = [[str substringToIndex:str.length-1] floatValue]/100.0;
        NSString *str1 = [onePointAry objectAtIndex:1];
        onePoint.y = [[str1 substringToIndex:str1.length-1] floatValue]/100.0;
        
        //相对与pdf页面的绝对坐标
        onePoint.x = onePoint.x *pagingView.bounds.size.width;
        onePoint.y = onePoint.y *pagingView.bounds.size.height;
        //相对与设备的绝对坐标
    }
    return onePoint;
}

-(BOOL)createCGPath:(NSArray *)pointsArry hitPoint:(CGPoint)hitPoint
{
    if (!pointsArry.count)
        return NO;
    pathRef = CGPathCreateMutable();
    CGPoint startPoint = [self buildZoomPagePointAtIndex:0 pointsArry:pointsArry];
    CGPathMoveToPoint(pathRef, NULL, startPoint.x, startPoint.y);
    
    for(int i =1; i< pointsArry.count; i++){
        
        CGPoint nextPoint = [self buildZoomPagePointAtIndex:i pointsArry:pointsArry];
        CGPathAddLineToPoint(pathRef, NULL, nextPoint.x, nextPoint.y);
    }
    CGPathCloseSubpath(pathRef);
    
    if (CGPathContainsPoint(pathRef, NULL, hitPoint, NO)) {
        return YES;
    }
    CFRelease(pathRef);
    return NO;
}

#pragma mark - scrollView delegate
// 视图滑动的过程调用
- (void)pagingViewDidScroll:(ATPagingView *)pagingView1;//2-3
{
}


#pragma mark - show hotArea view

-(void)showDetaillArticle:(PDFHotAreaDataModel *)hotInfo
{
    Article *article = [[Article alloc]init];
    article.fileId = [hotInfo.articleID intValue];
    article.title = hotInfo.articleTitle;
    article.contentUrl = hotInfo.contentUrl;
    article.attAbstract = [NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"分享",nil), article.title];
    article.shareUrl = [NSString stringWithFormat:@"%@/epaper_detail?newsid=%@_%@&app=1",[AppConfig sharedAppConfig].serverIf,hotInfo.articleID, [AppConfig sharedAppConfig].sid];

    //模板网页
    TemplateDetailPageController *controller = [[TemplateDetailPageController alloc] init];
    controller.articles = [NSArray arrayWithObject:article];
    controller.currentIndex = 0;
    controller.isPDF = YES;
    controller.adArticle = article;
    controller.articles = [NSArray arrayWithObject:article];
    [self.navigationController pushViewController:controller animated:YES];
}

-(void)showOverViewWithFrame:(CGRect)frame addOnView:(UIView *)view
{
    overView = [[CGPathOverView alloc]initWithFrame:frame];
    self.overView.pathRef = pathRef;
    if ([AppConfig sharedAppConfig].isNewspaperApperCover) {
      [view addSubview:self.overView];
    }
}

-(void)removeOverviewFromSuperView
{
    [self.overView removeFromSuperview];
}

-(void)reloadPage
{
    self.pagingView.currentPageIndex = 0;
    self.pdfTimeLabel.text = self.selectedDate;
    [self.pagingView reloadData];
}

-(void)loadAllPagesFinishedForOnePaper
{
    self.pagingView.currentPageIndex = 0;
    self.pdfTimeLabel.text = self.selectedDate;
    [self.pagingView reloadData];
}

#pragma mark - paging view delegate

- (NSInteger)numberOfPagesInPagingView:(ATPagingView *)pagingView
{
    return self.allPages.count;    
}

- (UIView *)viewForPageInPagingView:(ATPagingView *)sender atIndex:(NSInteger)index
{
    [self removeOverviewFromSuperView];
    FMPDImageView *cell = (FMPDImageView *)[pagingView dequeueReusablePage];
    if (cell == nil) {
        cell = [[FMPDImageView alloc] initWithFrame:CGRectMake(0, 0, pagingView.frame.size.width, pagingView.frame.size.height)];
    }
    
    cell.tag = 300+index;
    [cell addTarget:self actionB:@selector(tapBegin:) actionE:@selector(tapEnd:)];
    //修改显示版面图大图
    PDFPageDataModel *page = [self.allPages objectAtIndex:index];
    NSString *picUrl = [page.pagePic stringByAppendingString:@"@!lg"];
    [cell.imageView setDefaultImage:[Global getBgImage169]];
    [cell.imageView setUrlString:picUrl];
    
    return cell;
}

- (void)cellDidSelectedAtIndex:(int)index
{
    pagingView.currentPageIndex = index;
}
@end
