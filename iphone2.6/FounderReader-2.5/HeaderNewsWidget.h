//
//  HeaderNewsWidget.h
//  FounderReader-2.5
//
//  Created by guo.lh on 13-4-10.
//
//

#import <UIKit/UIKit.h>
#import "LinePageController.h"
#import "Article.h"
#import "Label.h"
#import "StyledPageControl.h"
#import "Column.h"
@class HeaderNewsWidget;

@protocol HeaderNewsWidgetDelegate <NSObject>

- (void)headerNewsWidget:(HeaderNewsWidget *)view didSelectAtIndex:(int)index;

@end

@interface HeaderNewsWidget : UIView <UIScrollViewDelegate>
{
    Label *titleLabel;
    Label *readLabel;
    Label *pubTimeLabel;
    
    UIScrollView *_scrollView;
    LinePageController *_pageFooter;
    StyledPageControl *_stylePageControl;
    NSArray *_headerArticles;
    NSArray *_arrayMiddles;//普通新闻列表
}
@property(nonatomic, assign) id<HeaderNewsWidgetDelegate> delegate;

@property(nonatomic,retain) UIScrollView *scrollView;
@property(nonatomic,retain) LinePageController *pageFooter;
@property(nonatomic,retain) NSArray *headerArticles;
@property(nonatomic,retain) NSArray *arrayMiddles;
@property(nonatomic,retain) UILabel *tagLabel;
@property(nonatomic,retain) Column *column;
@property(nonatomic,retain) UILabel *topicon;
@property(nonatomic,assign) int isDotStyle;
@property(nonatomic,assign) int isLife;

-(id)initWithConfigDic:(NSDictionary *)dicInfo IsHideColumnReadCount:(BOOL)isHideColumnReadCount;
-(id)initWithConfigDic:(NSDictionary *)dicInfo withIsLife:(int)isLife IsHideColumnReadCount:(BOOL)isHideColumnReadCount;
-(void)loadData;

-(void)setTitleLabelFrame:(CGRect)frame;
-(void)setPageFooterBackgroundViewHiden:(BOOL)hiden;

-(void)hidenTitleLabel;

@end
