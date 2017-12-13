//
//  ColumnScrollView.m
//  FounderReader-2.5
//
//  Created by ld on 14-6-18.
//
//

#import "ColumnScrollView.h"
#import "ColumnButton.h"

@implementation ColumnScrollView

@synthesize scrollViewbg;
@synthesize columns;
@synthesize stylePageControl;

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame withPageCount:(int)pageCount
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.rect = frame;
        cellWidth = kSWidth/4;
        cellHeight = kSWidth/4;
        cellMargin = kSWidth/14;
        
        cellNum_Row = 1;
        cellNum_col = 4;
        cellNums_page = cellNum_Row * cellNum_col;
        
        scrollViewbg = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.scrollViewbg.bounces = YES;
        self.scrollViewbg.pagingEnabled = YES;
        self.scrollViewbg.delegate = self;
        self.scrollViewbg.userInteractionEnabled = YES;
        self.scrollViewbg.showsHorizontalScrollIndicator = NO;
        self.scrollViewbg.showsVerticalScrollIndicator = NO;
        [self addSubview:self.scrollViewbg];
        
        //页面指示器
        stylePageControl = [[StyledPageControl alloc] init];
        self.stylePageControl.hidesForSinglePage = YES;
        self.stylePageControl.userInteractionEnabled = NO;
        self.stylePageControl.pageControlStyle = PageControlStyleDefault;
        self.stylePageControl.coreNormalColor = [UIColor grayColor];
        self.stylePageControl.numberOfPages = [self pagesNumber];
        self.stylePageControl.currentPage = 0;
        [self addSubview:self.stylePageControl];
       
        [self bringSubviewToFront:self.stylePageControl];
        
        self.userInteractionEnabled = YES;
    }
    return self;
}

-(void)reloadData
{
    if (!self.columns.count)
        return;
    
    self.stylePageControl.numberOfPages = [self pagesNumber];
    if (IS_IPHONE_4 || IS_IPHONE_5) {
        self.stylePageControl.frame = CGRectMake((kSWidth-8*[self pagesNumber])/2, self.rect.size.height-12, 12*[self pagesNumber], 12);
    }
    else
    {
        self.stylePageControl.frame = CGRectMake((kSWidth-8*[self pagesNumber])/2, self.rect.size.height-15, 12*[self pagesNumber], 12);
    }
    
    
    if(self.scrollViewbg.subviews && self.scrollViewbg.subviews.count > 0)
		[self.scrollViewbg.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];

    int row = 0;
    int col = 0;
    
    NSInteger pagesNumber = [self pagesNumber];
    
    for (int p = 0; p < pagesNumber; p++)
    {
        for (int idx = p * cellNums_page; idx < MIN((p + 1) * cellNums_page, self.columns.count); ++idx)
        {
            row = (idx - p * cellNums_page) / cellNum_col;
            col = (idx - p * cellNums_page) % cellNum_col;
            
            Column *oneColumn = [self.columns objectAtIndex:idx];
            ColumnButton *button = [[ColumnButton alloc] initWithFrame:CGRectMake(kSWidth * p + col * cellWidth + cellMargin, row * cellHeight + cellMargin*0.5, cellWidth-2*cellMargin, cellHeight-2*cellMargin)];
            button.index = idx;
            [button.thumbnail setUrlString:oneColumn.iconUrl];
            button.thumbnail.contentMode = UIViewContentModeScaleToFill;
            [button addTarget:self action:@selector(columnButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            scrollViewbg.userInteractionEnabled = YES;
            [scrollViewbg addSubview:button];
            
            UILabel *lbl = [[UILabel alloc] init];
            lbl.frame = CGRectMake(kSWidth * p + col * cellWidth, row * cellHeight + cellHeight-1.5*cellMargin, cellWidth, cellMargin);
            lbl.text = oneColumn.columnName;
            
            lbl.font = [UIFont systemFontOfSize:14];
            lbl.textAlignment = NSTextAlignmentCenter;
            [scrollViewbg addSubview:lbl];  
        }
    }
     self.scrollViewbg.contentSize = CGSizeMake(scrollViewbg.frame.size.width * [self pagesNumber], scrollViewbg.frame.size.height);
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.stylePageControl.currentPage = [self currentPageIndex];
}

- (int)currentPageIndex
{
    CGFloat pageWidth = self.scrollViewbg.frame.size.width;
    int page = floor((self.scrollViewbg.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    if (page > [self pagesNumber]) {
        return [self pagesNumber] - 1;
    }
    return page;
}

-(int)pagesNumber
{
    if (!cellNums_page) {
        return 0;
    }
    int pagesNumber = (int)(self.columns.count / cellNums_page);
    if (self.columns.count%cellNums_page)
        ++pagesNumber;
    
    return pagesNumber;
}

-(void)columnButtonClicked:(ColumnButton *)sender
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(columnScrollView:didSelectedButtonAtIndex:)])
		[self.delegate columnScrollView:self didSelectedButtonAtIndex:(int)(sender.index)];
}

@end
