//
//  HeaderNewsWidget.m
//  FounderReader-2.5
//
//  Created by guo.lh on 13-4-10.
//
//
#import "UIImageView+WebCache.h"
#import "HeaderNewsWidget.h"
#import "NewsListConfig.h"
#import "ImageViewCf.h"
#import "AppConfig.h"
#import "ColumnBarConfig.h"
#import "UIView+Extention.h"
#import "FLAnimatedImage.h"
#define normalHeight 180
//#define headerScale (500/720.0)
//#define headerScale (540/720.0)
@interface HeaderNewsWidget()
{
    float _heightFirst;
    BOOL _isAutoScroll;
    double _timerInterval;
    CGRect _pageFooterFrame;
    int nImageShowMode;
    NSTimer *_autoScrollTimer;
    int curPage;
    int totalPage;
    int isFirst;
    NSArray *_imageArray;
    NSMutableArray *_AllheaderArticles;
    CGFloat headerScale;
}
@property (nonatomic, retain) NSTimer *autoScrollTimer;
@property(nonatomic,retain) UIImageView *titleBgView;
@property(nonatomic,retain) UIImageView *imgView;
@property(nonatomic,retain) StyledPageControl *stylePageControl;
@property(nonatomic,retain) UIView *blankView;
@property(nonatomic,retain) UILabel *pageControllerLabel;

@end

@implementation HeaderNewsWidget
@synthesize delegate        = _delegate;
@synthesize scrollView = _scrollView;
@synthesize pageFooter = _pageFooter;
@synthesize headerArticles = _headerArticles;
@synthesize arrayMiddles = _arrayMiddles;
@synthesize autoScrollTimer = _autoScrollTimer;
@synthesize isDotStyle;
@synthesize titleBgView;
@synthesize blankView,pageControllerLabel,topicon,imgView;

@synthesize stylePageControl = _stylePageControl;


-(id)initWithConfigDic:(NSDictionary *)dicInfo
{
    if (!dicInfo.count)
        return nil;
    headerScale = 1/[ColumnBarConfig sharedColumnBarConfig].columnHeaderScale;
    _isAutoScroll = [[dicInfo objectForKey:@"is_autoScroll"] boolValue];
    _timerInterval = [[dicInfo objectForKey:@"timer_interval"] doubleValue];
    NSString *pageFooterFrameStr = [dicInfo objectForKey:@"pageFooter_frame"];
    _pageFooterFrame = CGRectFromString(pageFooterFrameStr);
    self.isDotStyle = [[dicInfo objectForKey:@"is_dotPageFooter"] intValue];
    
    nImageShowMode = [[dicInfo objectForKey:@"image_show_mode"] intValue];
    
    CGRect frame = CGRectMake(0, 0, kSWidth, kSWidth*headerScale);
    return [self initWithFrame:frame];
}
-(id)initWithConfigDic:(NSDictionary *)dicInfo withIsLife:(int)isLife
{
    self.isLife = isLife;
    if (!dicInfo.count)
        return nil;
    headerScale = 1/[ColumnBarConfig sharedColumnBarConfig].columnHeaderScale;
    _isAutoScroll = [[dicInfo objectForKey:@"is_autoScroll"] boolValue];
    _timerInterval = [[dicInfo objectForKey:@"timer_interval"] doubleValue];
    NSString *pageFooterFrameStr = [dicInfo objectForKey:@"pageFooter_frame"];
    _pageFooterFrame = CGRectFromString(pageFooterFrameStr);
    self.isDotStyle = [[dicInfo objectForKey:@"is_dotPageFooter"] intValue];
    
    nImageShowMode = [[dicInfo objectForKey:@"image_show_mode"] intValue];
    
    CGRect frame = CGRectZero;
    if (self.isLife == 1)
    {
        frame = CGRectMake(0, 0, kSWidth, kSWidth*headerScale + kSWidth/4);
    }
    return [self initWithFrame:frame];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self){
        
    }
    return self;
}

-(void)loadData
{
    [self addHeaderScrollView];
    [self addTapGestureReconginzer];
    [self addTitleAndPageControl];
    [self startTimer];
}

- (void)addTitleAndPageControl
{
    _tagLabel = [[UILabel alloc] init];
    _tagLabel.textAlignment = NSTextAlignmentLeft;
    _tagLabel.font = [UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleCellDateFontSize+1];
    _tagLabel.textColor = [ColumnBarConfig sharedColumnBarConfig].column_all_color;

    topicon = [[UILabel alloc]initWithFrame:CGRectMake(5, kSWidth*0.5+1, 50, 16*proportion)];
    topicon.backgroundColor = [UIColor clearColor];
    self.topicon.textAlignment = NSTextAlignmentLeft;
    topicon.font = [UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleCellDateFontSize +1];
    topicon.textColor = [UIColor whiteColor];
    imgView =  [[UIImageView alloc]initWithFrame:CGRectMake(0, kSWidth*0.5, topicon.frame.size.width + 15, 16*proportion)];
    imgView.image = [UIImage imageNamed:@"icon_title"];
    imgView.hidden = YES;
    [self addSubview:imgView];
    
    [self addSubview:topicon];
    
    titleBgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, kSWidth*(headerScale-0.15), kSWidth, kSWidth*0.15)];
    self.titleBgView.backgroundColor = [UIColor blackColor];
    self.titleBgView.alpha = 0.75;
    [self addSubview:self.titleBgView];
    
    if (titleLabel) {
        [titleLabel removeFromSuperview];
    }
    titleLabel = [[Label alloc] initWithFrame:CGRectMake(8, kSWidth*headerScale-55, kSWidth-16, 40)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.edgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.numberOfLines = 1;
    titleLabel.font = [UIFont fontWithName:[Global fontName] size:[NewsListConfig sharedListConfig].headCellTitleFontSize];
    titleLabel.textColor = [UIColor whiteColor];//[NewsListConfig sharedListConfig].headCellTitleTextColor;
    
    if (readLabel) {
        [readLabel removeFromSuperview];
    }
    readLabel = [[Label alloc] init];
    readLabel.backgroundColor = [UIColor clearColor];
    readLabel.edgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
    readLabel.textAlignment = NSTextAlignmentLeft;
    readLabel.numberOfLines = 0;
    readLabel.font = [UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleCellDateFontSize+1];
    readLabel.textColor = [UIColor whiteColor];//[NewsListConfig sharedListConfig].headCellTitleTextColor;
    //是否隐藏阅读数
    readLabel.hidden = NO;//![AppConfig sharedAppConfig].isAppearReadCount;
    
    if (pubTimeLabel) {
        [pubTimeLabel removeFromSuperview];
    }
    pubTimeLabel = [[Label alloc] init];
    pubTimeLabel.backgroundColor = [UIColor clearColor];
    pubTimeLabel.edgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
    pubTimeLabel.textAlignment = NSTextAlignmentLeft;
    pubTimeLabel.numberOfLines = 0;
    pubTimeLabel.font = [UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleCellDateFontSize+1];
    pubTimeLabel.textColor = [UIColor whiteColor];
    
    Article *article = [_imageArray objectAtIndex:0];
    if (_imageArray.count > 1)
    {
        titleLabel.text = [(Article *)[_imageArray objectAtIndex:0] title];
        
        NSString *tagRelative = [[article.columnName componentsSeparatedByString:@"~"] lastObject];
        if (![tagRelative isEqualToString:self.column.columnName]) {
            article.category = tagRelative;
        }
        
        if (article.category.length>0) {
            
            NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleCellDateFontSize + 1], NSFontAttributeName,nil];
            CGSize size = [article.category boundingRectWithSize:CGSizeMake(320, 30) options:NSStringDrawingUsesLineFragmentOrigin attributes:tdic context:nil].size;
            
            CGRect frame = topicon.frame;
            frame.origin.y  = kSWidth * 0.5;
            frame.size = size;
            topicon.frame = frame;
            CGRect imgframe = imgView.frame;
            imgframe.size.width = frame.size.width+15;
            imgView.frame = imgframe;
            imgView.hidden = NO;
            topicon.text = article.category;
            
        }else{
            imgView.hidden = YES;
        }
        if (article.advID == 0) {
            readLabel.text = [NSString stringWithFormat:@"%@%@", [(Article *)[_imageArray objectAtIndex:0] readCount], NSLocalizedString(@"人阅读",nil)];
            readLabel.textColor = [UIColor whiteColor];
        }
        else
        {
            readLabel.text = NSLocalizedString(@"推广",nil);
            readLabel.textColor = [ColumnBarConfig sharedColumnBarConfig].column_all_color;
        }
        
        CGSize size = [self contentWidthWithText:readLabel.text Font:[UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleCellDateFontSize+1]];
        if (article.tag != nil && ![article.tag isEqualToString:@""]) {
            CGSize sizeTag = [self contentWidthWithText:article.tag Font:[UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleCellDateFontSize+1]];
            _tagLabel.text = article.tag;
            _tagLabel.hidden = NO;
            _tagLabel.frame = CGRectMake(15, kSWidth*headerScale-22, sizeTag.width, 20);
            readLabel.frame = CGRectMake(sizeTag.width+30, kSWidth*headerScale-22, kSWidth*0.6, 20);
            if (readLabel.hidden) {
                pubTimeLabel.frame = CGRectMake(sizeTag.width+30, kSWidth*headerScale-22, kSWidth-16, 20);
            }else{
                pubTimeLabel.frame = CGRectMake(size.width + 0.085*kSWidth+sizeTag.width+20, kSWidth*headerScale-22, kSWidth-16, 20);
            }
        }
        else
        {
            _tagLabel.hidden = YES;
            readLabel.frame = CGRectMake(10, kSWidth*headerScale-22, kSWidth*0.6, 20);
            if (readLabel.hidden) {
                pubTimeLabel.frame = CGRectMake(10, kSWidth*headerScale-22, kSWidth-16, 20);
            }else{
                pubTimeLabel.frame = CGRectMake(size.width + 0.085*kSWidth, kSWidth*headerScale-22, kSWidth-16, 20);
            }
        }
        
        pubTimeLabel.text = intervalSinceNow(article.publishTime);
        blankView = [[UIView alloc] initWithFrame:CGRectMake(7, 4, 27, 17)];
        self.blankView.layer.borderWidth = 1;
        self.blankView.layer.borderColor = [UIColor colorWithRed:85/255.0 green:115/255.0  blue:166/255.0  alpha:1].CGColor;
        pageControllerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 7, 27, 17)];
        self.pageControllerLabel.backgroundColor = [UIColor colorWithRed:85/255.0 green:115/255.0  blue:166/255.0  alpha:1];
    }
    else{
        titleLabel.text = [(Article *)[_imageArray objectAtIndex:0] title];
        readLabel.text = [(Article *)[_imageArray objectAtIndex:0] readCount];
        if (((Article *)[_imageArray objectAtIndex:0]).advID == 0) {
            readLabel.text = [NSString stringWithFormat:@"%@%@",readLabel.text, NSLocalizedString(@"人阅读",nil)];
            readLabel.textColor = [UIColor whiteColor];
        }
        else{
            readLabel.text = NSLocalizedString(@"推广", nil);
            readLabel.textColor = [ColumnBarConfig sharedColumnBarConfig].column_all_color;
        }
        pubTimeLabel.text = intervalSinceNow([(Article *)[_imageArray objectAtIndex:0] publishTime]);

        Article *article = [_imageArray objectAtIndex:0];
        NSString *tagRelative = [[article.columnName componentsSeparatedByString:@"~"] lastObject];
        if (![tagRelative isEqualToString:self.column.columnName]) {
            article.category = tagRelative;
        }
        
        if (article.category.length>0) {
            
            NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleCellDateFontSize + 1], NSFontAttributeName,nil];
            CGSize size = [article.category boundingRectWithSize:CGSizeMake(320, 30) options:NSStringDrawingUsesLineFragmentOrigin attributes:tdic context:nil].size;
            
            CGRect frame = topicon.frame;
            frame.origin.y  = kSWidth * 0.5;
            frame.size = size;
            topicon.frame = frame;
            CGRect imgframe = imgView.frame;
            imgframe.size.width = frame.size.width+15;
            imgView.frame = imgframe;
            imgView.hidden = NO;
            topicon.text = article.category;
        }else{
            imgView.hidden = YES;
        }
    }
    
    CGSize size = [self contentWidthWithText:readLabel.text Font:[UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleCellDateFontSize+1]];
    if (article.tag != nil && ![article.tag isEqualToString:@""]) {
        CGSize sizeTag = [self contentWidthWithText:article.tag Font:[UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleCellDateFontSize+1]];
        _tagLabel.text = article.tag;
        _tagLabel.hidden = NO;
        _tagLabel.frame = CGRectMake(15, kSWidth*headerScale-22, sizeTag.width, 20);
        readLabel.frame = CGRectMake(sizeTag.width+30, kSWidth*headerScale-22, kSWidth*0.6, 20);
        if (readLabel.hidden) {
            pubTimeLabel.frame = CGRectMake(sizeTag.width+30, kSWidth*headerScale-22, kSWidth-16, 20);
        }else{
            pubTimeLabel.frame = CGRectMake(size.width + 0.085*kSWidth+sizeTag.width+20, kSWidth*headerScale-22, kSWidth-16, 20);
        }
    }
    else{
        _tagLabel.hidden = YES;
        readLabel.frame = CGRectMake(10,kSWidth*headerScale-22, kSWidth*0.6, 20);
        if (readLabel.hidden) {
            pubTimeLabel.frame = CGRectMake(10, kSWidth*headerScale-22, kSWidth-16, 20);
        }else{
            pubTimeLabel.frame = CGRectMake(size.width + 0.085*kSWidth, kSWidth*headerScale-22, kSWidth-16, 20);
        }
    }
    
    [self addSubview:titleLabel];
    [self addSubview:_tagLabel];
    [self addSubview:readLabel];
    [self addSubview:pubTimeLabel];
    
    //页面指示器
    if (self.pageFooter) {
        [self.pageFooter removeFromSuperview];
    }
    
    if (self.stylePageControl) {
        [self.stylePageControl removeFromSuperview];
    }
    
    if (self.isDotStyle == 0) {
        if (_imageArray.count >1 )
        {
            _pageFooter = [[LinePageController alloc] initWithFrame:CGRectMake(0, 30, kSWidth, 2) andTotalNumber:[_imageArray count]];
            self.pageFooter.userInteractionEnabled = NO;
            
            [self bringSubviewToFront:self.pageFooter];
            [self.pageFooter updateSubView];
        }
    }
    else{
        _stylePageControl = [[StyledPageControl alloc] initWithFrame:CGRectMake((kSWidth-8*_imageArray.count-5), kSWidth*headerScale-12, 8*_imageArray.count*proportion, 8)];
        self.stylePageControl.hidesForSinglePage = YES;
        self.stylePageControl.userInteractionEnabled = NO;
        self.stylePageControl.coreNormalColor = [UIColor whiteColor];
        self.stylePageControl.coreSelectedColor = UIColorFromString(@"19,175,253");
        self.stylePageControl.thumbImage = [UIImage imageNamed:@"lb_normal_6+"];
        self.stylePageControl.selectedThumbImage = [UIImage imageNamed:@"lb_pressed_6+"];
        [self.stylePageControl setPageControlStyle:PageControlStyleThumb];
        self.stylePageControl.numberOfPages = (int)_imageArray.count;
        self.stylePageControl.currentPage = 0;
        [self addSubview:self.stylePageControl];
        [self bringSubviewToFront:self.stylePageControl];
    }
}

-(void)addHeaderScrollView
{
    _AllheaderArticles = [[NSMutableArray alloc] init];
    _imageArray = [[NSArray alloc] initWithArray:self.headerArticles];
    curPage = 1;
    totalPage = (int)_imageArray.count;
    
    if (_scrollView) {
        [_scrollView removeFromSuperview];
    }
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kSWidth, kSWidth*headerScale)];
    self.scrollView.delegate = self;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.bounces = NO;
    self.scrollView.alwaysBounceHorizontal = YES;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.backgroundColor = [UIColor clearColor];
    if (_imageArray.count > 1) {
        self.scrollView.contentSize = CGSizeMake(3*self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    }
    else
    {
        self.scrollView.scrollEnabled = NO;
    }
    self.scrollView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.scrollView];
    [self refreshScrollView];
}
- (void)refreshScrollView {
    
    NSArray *subViews = [self.scrollView subviews];
    if([subViews count] != 0) {
        [subViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    [self getDisplayImagesWithCurpage:curPage];
    
    for (int i = 0; i < _AllheaderArticles.count; i++)
    {
        Article *article = nil;
        article = _AllheaderArticles[i];
        
        if (article.category.length>0) {
            
            NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleCellDateFontSize + 1], NSFontAttributeName,nil];
            CGSize size = [article.category boundingRectWithSize:CGSizeMake(320, 30) options:NSStringDrawingUsesLineFragmentOrigin attributes:tdic context:nil].size;
            CGRect frame = topicon.frame;
            frame.size = size;
            topicon.frame = frame;
            CGRect imgframe = imgView.frame;
            imgframe.size.width = frame.size.width+15;
            imgView.frame = imgframe;
            topicon.hidden = NO;
            imgView.hidden = NO;
            topicon.text = article.category;
        }else{
            imgView.hidden = YES;
            topicon.hidden = YES;
        }
        titleLabel.text = article.title;
        if (article.advID == 0) {
            readLabel.text = [NSString stringWithFormat:@"%@%@", article.readCount, NSLocalizedString(@"人阅读",nil)];
            readLabel.textColor = [UIColor whiteColor];
        }
        else{
            readLabel.text = NSLocalizedString(@"推广", nil);
            readLabel.textColor = [ColumnBarConfig sharedColumnBarConfig].column_all_color;
        }

        pubTimeLabel.text = intervalSinceNow(article.publishTime);
        
        CGSize size = [self contentWidthWithText:readLabel.text Font:[UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleCellDateFontSize+1]];
        if (article.tag != nil && ![article.tag isEqualToString:@""]) {
            CGSize sizeTag = [self contentWidthWithText:article.tag Font:[UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleCellDateFontSize+1]];
            _tagLabel.text = article.tag;
            _tagLabel.hidden = NO;
            _tagLabel.frame = CGRectMake(15, kSWidth*headerScale-22, sizeTag.width, 20);
            readLabel.frame = CGRectMake(sizeTag.width+30, kSWidth*headerScale-22, kSWidth*0.6, 20);
            if (readLabel.hidden) {
                pubTimeLabel.frame = CGRectMake(sizeTag.width+30, kSWidth*headerScale-22, kSWidth-16, 20);
            }else{
                pubTimeLabel.frame = CGRectMake(size.width + 0.085*kSWidth+sizeTag.width+20, kSWidth*headerScale-40, kSWidth-16, 20);
            }
        }
        else{
            _tagLabel.hidden = YES;
            readLabel.frame = CGRectMake(10,kSWidth*headerScale-22, kSWidth*0.6, 20);
            if (readLabel.hidden) {
                pubTimeLabel.frame = CGRectMake(10, kSWidth*headerScale-22, kSWidth-16, 20);
            }else{
                pubTimeLabel.frame = CGRectMake(size.width + 0.085*kSWidth, kSWidth*headerScale-22, kSWidth-16, 20);
            }
        }
        
        ImageViewCf *bigImageView =[[ImageViewCf alloc] initWithFrame:self.bounds];
        bigImageView.contentMode = UIViewContentModeScaleAspectFill;//不变形居中显示，会有部分裁剪
        bigImageView.clipsToBounds  = YES;//超出边界部分裁剪
        
        bigImageView.frame = CGRectMake(i*self.scrollView.frame.size.width,
                                        0,
                                        self.scrollView.frame.size.width,
                                        self.scrollView.frame.size.height);
        //顶部新闻图片背景设置与新闻列表背景一致
        bigImageView.backgroundColor = [NewsListConfig sharedListConfig].cellBackgroundColor;
        
        NSString *imageurl = nil;
        //轮播图 @!md43
        if (article.advID != 0){//推广
            if ([article.imgAdvUrl containsString:@".gif"]) {
                bigImageView.image = [Global getBgImage43];
                FLAnimatedImageView *imageView = [[FLAnimatedImageView alloc] initWithFrame:bigImageView.frame];
                [self loadAnimatedImageWithURL:[NSURL URLWithString:article.imgAdvUrl] completion:^(FLAnimatedImage *animatedImage) {
                    [imageView setAnimatedImage:animatedImage];
                }];
                [self.scrollView addSubview:imageView];
            }
            else{
                imageurl = [NSString stringWithFormat:@"%@@!md43", article.imgAdvUrl];
                [bigImageView sd_setImageWithURL:[NSURL URLWithString:imageurl] placeholderImage:[Global getBgImage43]];
                [self.scrollView addSubview:bigImageView];
            }
        }
        else{ // 普通
            imageurl = [article.imageUrl stringByReplacingOccurrencesOfString:@"sm43" withString:@"md43"];
            [bigImageView sd_setImageWithURL:[NSURL URLWithString:imageurl] placeholderImage:[Global getBgImage43]];
            [self.scrollView addSubview:bigImageView];
        }
    }

    float b =self.scrollView.contentOffset.x;
    int a = self.scrollView.contentOffset.x  / kSWidth;
    float c = a*kSWidth - b;
    [self.scrollView setContentOffset:CGPointMake(kSWidth-c, 0)];
}

- (void)loadAnimatedImageWithURL:(NSURL *const)url completion:(void (^)(FLAnimatedImage *animatedImage))completion
{
    NSString *const filename = url.lastPathComponent;
    NSString *const diskPath = [NSHomeDirectory() stringByAppendingPathComponent:filename];
    
    NSData * __block animatedImageData = [[NSFileManager defaultManager] contentsAtPath:diskPath];
    FLAnimatedImage * __block animatedImage = [[FLAnimatedImage alloc] initWithAnimatedGIFData:animatedImageData];
    
    if (animatedImage) {
        if (completion) {
            completion(animatedImage);
        }
    } else {
        [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            animatedImageData = data;
            animatedImage = [[FLAnimatedImage alloc] initWithAnimatedGIFData:animatedImageData];
            if (animatedImage) {
                if (completion) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(animatedImage);
                    });
                }
                [data writeToFile:diskPath atomically:YES];
            }
        }] resume];
    }
}


- (NSArray *)getDisplayImagesWithCurpage:(NSInteger)page {
    
    NSInteger pre = [self validPageValue:curPage-1];
    NSInteger last = [self validPageValue:curPage+1];
    
    if([_AllheaderArticles count] != 0)
    {
        [_AllheaderArticles removeAllObjects];
    }
    
    [_AllheaderArticles addObject:[_imageArray objectAtIndex:pre-1]];
    [_AllheaderArticles addObject:[_imageArray  objectAtIndex:curPage-1]];
    [_AllheaderArticles addObject:[_imageArray  objectAtIndex:last-1]];
    return _AllheaderArticles;
}
- (int)validPageValue:(int)value {
    
    if(value == 0) value = totalPage;
    // value＝1为第一张，value = 0为前面一张
    if(value == totalPage + 1) value = 1;
    return value;
}

-(void)addTapGestureReconginzer
{
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellDidSelect:)];
    [self.scrollView addGestureRecognizer:recognizer];
    
}

- (void)cellDidSelect:(UITapGestureRecognizer *)sender
{
    if ([self.delegate respondsToSelector:@selector(headerNewsWidget:didSelectAtIndex:)])
        [self.delegate headerNewsWidget:self didSelectAtIndex:[self currentPageIndex]-1];
}


#pragma mark - UIScrollViewDelegate

- (int)currentPageIndex
{
    int x = self.scrollView.contentOffset.x;
    // 往后翻一张
    if(x >= (2*self.scrollView.frame.size.width)) {
        curPage = [self validPageValue:curPage+1];
    }
    // 往前翻一张
    if(x <= 0) {
        curPage = [self validPageValue:curPage-1];
    }
    return curPage;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    int x = scrollView.contentOffset.x;
    // 往后翻一张
    if(x >= (2*self.scrollView.frame.size.width)) {
        curPage = [self validPageValue:curPage+1];
        [self refreshScrollView];
        if (_imageArray.count > [self currentPageIndex]-1 && _imageArray.count > 1)
        {
            Article *article = [_imageArray objectAtIndex:[self currentPageIndex] - 1];
            NSString *tagRelative = [[article.columnName componentsSeparatedByString:@"~"] lastObject];
            if (![tagRelative isEqualToString:self.column.columnName]) {
                article.category = tagRelative;
            }
            if (article.category.length>0) {
                
                NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleCellDateFontSize + 1], NSFontAttributeName,nil];
                CGSize size = [article.category boundingRectWithSize:CGSizeMake(320, 30) options:NSStringDrawingUsesLineFragmentOrigin attributes:tdic context:nil].size;
                CGRect frame = topicon.frame;
                frame.size = size;
                topicon.frame = frame;
                CGRect imgframe = imgView.frame;
                imgframe.size.width = frame.size.width+15;
                imgView.frame = imgframe;
                topicon.hidden = NO;
                imgView.hidden = NO;
                topicon.text = article.category;
            }else{
                imgView.hidden = YES;
                topicon.hidden = YES;
            }
            
            titleLabel.text = [(Article *)[_imageArray objectAtIndex:[self currentPageIndex]-1] title];
            titleLabel.text = [NSString stringWithFormat:@"%@",titleLabel.text];
            
            readLabel.text = [(Article *)[_imageArray objectAtIndex:[self currentPageIndex]-1] readCount];
            if ([(Article *)[_imageArray objectAtIndex:[self currentPageIndex]-1] advID] == 0) {
                readLabel.text = [NSString stringWithFormat:@"%@%@",readLabel.text, NSLocalizedString(@"人阅读",nil)];
                readLabel.textColor = [UIColor whiteColor];
            }
            else
            {
                readLabel.text = NSLocalizedString(@"推广", nil);
                readLabel.textColor = [ColumnBarConfig sharedColumnBarConfig].column_all_color;
            }
            
            
            pubTimeLabel.text = intervalSinceNow([(Article *)[_imageArray objectAtIndex:[self currentPageIndex]-1] publishTime]);
            
            CGSize size = [self contentWidthWithText:readLabel.text Font:[UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleCellDateFontSize+1]];
            if (article.tag != nil && ![article.tag isEqualToString:@""]) {
                CGSize sizeTag = [self contentWidthWithText:article.tag Font:[UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleCellDateFontSize+1]];
                _tagLabel.text = article.tag;
                _tagLabel.hidden = NO;
                _tagLabel.frame = CGRectMake(15, kSWidth*headerScale-22, sizeTag.width, 20);
                readLabel.frame = CGRectMake(sizeTag.width+30, kSWidth*headerScale-22, kSWidth*0.6, 20);
                if (readLabel.hidden) {
                    pubTimeLabel.frame = CGRectMake(15+sizeTag.width+15, kSWidth*headerScale-22, kSWidth-16, 20);
                }else{
                    pubTimeLabel.frame = CGRectMake(15+size.width+ 5+sizeTag.width+15, kSWidth*headerScale-22, kSWidth-16, 20);
                }
                
            }
            else
            {
                _tagLabel.hidden = YES;
                readLabel.frame = CGRectMake(10,kSWidth*headerScale-22, kSWidth*0.6, 20);
                if (readLabel.hidden) {
                    pubTimeLabel.frame = CGRectMake(10, kSWidth*headerScale-22, kSWidth-16, 20);
                }else{
                    pubTimeLabel.frame = CGRectMake(size.width + 0.085*kSWidth, kSWidth*headerScale-22, kSWidth-16, 20);
                }
                
            }

            self.stylePageControl.currentPage = curPage-1;
            self.pageFooter.currentIndex = curPage-1;
            [self.pageFooter updateSubView];
        }
        
    }
    // 往前翻一张
    if(x <= 0) {
        curPage = [self validPageValue:curPage-1];
        [self refreshScrollView];
        if (_imageArray.count > [self currentPageIndex]-1 && _imageArray.count > 1)
        {
            Article *article = [_imageArray objectAtIndex:[self currentPageIndex] - 1];
            NSString *tagRelative = [[article.columnName componentsSeparatedByString:@"~"] lastObject];
            if (![tagRelative isEqualToString:self.column.columnName]) {
                article.category = tagRelative;
            }
            
            if (article.category.length>0) {
                
                NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleCellDateFontSize + 1], NSFontAttributeName,nil];
                CGSize size = [article.category boundingRectWithSize:CGSizeMake(320, 30) options:NSStringDrawingUsesLineFragmentOrigin attributes:tdic context:nil].size;
                CGRect frame = topicon.frame;
                frame.size = size;
                topicon.frame = frame;
                CGRect imgframe = imgView.frame;
                imgframe.size.width = frame.size.width+15;
                imgView.frame = imgframe;
                imgView.hidden = NO;
                topicon.hidden = NO;
                topicon.text = article.category;
            }else{
                imgView.hidden = YES;
                topicon.hidden = YES;
            }
            
            titleLabel.text = [(Article *)[_imageArray objectAtIndex:[self currentPageIndex]-1] title];
            titleLabel.text = [NSString stringWithFormat:@"%@",titleLabel.text];
            
            
            readLabel.text = [(Article *)[_imageArray objectAtIndex:[self currentPageIndex]-1] readCount];
            if ([(Article *)[_imageArray objectAtIndex:[self currentPageIndex]-1] advID] == 0) {
                readLabel.text = [NSString stringWithFormat:@"%@%@",readLabel.text, NSLocalizedString(@"人阅读",nil)];
                readLabel.textColor = [UIColor whiteColor];
            }
            else
            {
                readLabel.text = NSLocalizedString(@"推广", nil);
                readLabel.textColor = [ColumnBarConfig sharedColumnBarConfig].column_all_color;
            }
            
            pubTimeLabel.text = intervalSinceNow([(Article *)[_imageArray objectAtIndex:[self currentPageIndex]-1] publishTime]);
            
            CGSize size = [self contentWidthWithText:readLabel.text Font:[UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleCellDateFontSize+1]];
            if (article.tag != nil && ![article.tag isEqualToString:@""]) {
                CGSize sizeTag = [self contentWidthWithText:article.tag Font:[UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleCellDateFontSize+1]];
                _tagLabel.text = article.tag;
                _tagLabel.hidden = NO;
                _tagLabel.frame = CGRectMake(15, kSWidth*headerScale-22, sizeTag.width, 20);
                readLabel.frame = CGRectMake(sizeTag.width+30, kSWidth*headerScale-22, kSWidth*0.6, 20);
                if (readLabel.hidden) {
                    pubTimeLabel.frame = CGRectMake(sizeTag.width+30, kSWidth*headerScale-22, kSWidth-16, 20);
                }else{
                    pubTimeLabel.frame = CGRectMake(size.width + 0.085*kSWidth+sizeTag.width+20, kSWidth*headerScale-22, kSWidth-16, 20);
                }
                
            }
            else
            {
                _tagLabel.hidden = YES;
                readLabel.frame = CGRectMake(10, kSWidth*headerScale-22, kSWidth*0.6, 20);
                if (readLabel.hidden) {
                    pubTimeLabel.frame = CGRectMake(10, kSWidth*headerScale-22, kSWidth-16, 20);
                }else{
                    pubTimeLabel.frame = CGRectMake(size.width + 0.085*kSWidth, kSWidth*headerScale-22, kSWidth-16, 20);
                }
                
            }

            self.stylePageControl.currentPage = curPage-1;
            self.pageFooter.currentIndex = curPage-1;
            [self.pageFooter updateSubView];
        }
        
    }
}

- (void)startTimer {

    if (!_isAutoScroll)
        return;
    [self stopTimer];
    self.autoScrollTimer = [NSTimer timerWithTimeInterval:_timerInterval
                                                   target:self
                                                 selector:@selector(timerRefreshed:)
                                                 userInfo:nil
                                                  repeats:YES];
    
    [[NSRunLoop currentRunLoop] addTimer:self.autoScrollTimer forMode:NSDefaultRunLoopMode];
}

-(void)setPageFooterFrame:(CGRect)frame
{
    [self.stylePageControl removeFromSuperview];
    self.stylePageControl.frame = frame;
    
    [self addSubview:self.stylePageControl];
}

- (void)stopTimer {
    
    if (self.autoScrollTimer) {
        [self.autoScrollTimer invalidate];
        self.autoScrollTimer = nil;
    }
}

- (void)timerRefreshed:(id)sender {
    if (_imageArray.count > 1) {
        float offset = self.scrollView.frame.size.width;
        int a = (self.scrollView.contentOffset.x + 100) / kSWidth;
        CGPoint targetPoint = CGPointMake(a*kSWidth + offset, 0.0f);
        BOOL animated = YES;
        if (targetPoint.x >= self.scrollView.contentSize.width) {
            targetPoint = CGPointMake(0.0f, 0.0f);
            animated = NO;
        }
        [self.pageFooter updateSubView];
        [self.scrollView setContentOffset:targetPoint animated:animated];
    }
}

#pragma mark -
#pragma mark TTScrollViewDelegate methods

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    [self stopTimer];
}

// 滚动停止时调用该函数
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    [self startTimer];
    
}

// 拖动停止时调用该函数
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    if (!decelerate) {
        [self startTimer];
    }
}


-(void)setTitleLabelFrame:(CGRect)frame
{
    titleLabel.frame = frame;
}

-(void)setPageFooterBackgroundViewHiden:(BOOL)hiden
{
    self.titleBgView.hidden = hiden;
}

-(void)hidenTitleLabel
{
    return;
}

- (CGSize)contentWidthWithText:(NSString*)text Font:(UIFont*)font
{
    //设置字体
    CGSize size = CGSizeMake(kSWidth-20, 1000);//注：这个宽：300 是你要显示的宽度既固定的宽度，高度可以依照自己的需求而定
    NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName,nil];
    size =[text boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:tdic context:nil].size;
    
    return size;
}

@end
