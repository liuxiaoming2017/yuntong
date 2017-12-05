//
//  ColumnScrollView.h
//  FounderReader-2.5
//
//  Created by ld on 14-6-18.
//
//

#import <UIKit/UIKit.h>
#import "Column.h"
#import "StyledPageControl.h"

@protocol ColumnScrollViewDelegate;

@interface ColumnScrollView : UIImageView <UIScrollViewDelegate>
{
    CGRect scrollViewFrame;
    CGRect pageFooterFrame;
    
    float cellWidth;//宽
    float cellHeight;//高
    CGFloat cellMargin;//左右边距
    
    int cellNum_Row;//每页行数
    int cellNum_col;//每页列数
    int cellNums_page;//每页栏目数
}

@property(nonatomic, assign) CGRect rect;
@property(nonatomic, retain) NSArray * columns;
@property(nonatomic,retain) StyledPageControl *stylePageControl;
@property(nonatomic, retain) UIScrollView *scrollViewbg;
@property(nonatomic, assign) id<ColumnScrollViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame withPageCount:(int)pageCount;
-(void)reloadData;

@end

@protocol ColumnScrollViewDelegate <NSObject>
@optional
- (void)columnScrollView:(ColumnScrollView *)columnScrollView didSelectedButtonAtIndex:(int)index;
-(int)pagesNumber;
@end
