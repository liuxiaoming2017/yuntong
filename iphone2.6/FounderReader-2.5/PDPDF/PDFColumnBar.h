//
//  PDFColumnBar.h
//  PDFColumnBarDemo
//
//  Created by chenfei on 4/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PDFColumnBarDataSource;
@protocol PDFColumnBarDelegate;

#import "Column.h"
@interface PDFColumnBar : UIImageView <UIScrollViewDelegate> {
    UIScrollView    *scrollView;
    UIImageView     *leftCap;
    UIImageView     *rightCap;
    UIImageView     *mover;
    UIImageView     *moreCap;
    int             selectedIndex;
    int             lastSelectIndex;
    
    id<PDFColumnBarDataSource> dataSource;
    id<PDFColumnBarDelegate>   delegate;
}

@property(nonatomic, retain) UIScrollView               *scrollView;

@property(nonatomic, assign) int                        selectedIndex;

@property(nonatomic, retain) id<PDFColumnBarDataSource>    dataSource;
@property(nonatomic, retain) id<PDFColumnBarDelegate>      delegate;

@property(nonatomic, assign) BOOL enabled;
@property(nonatomic, assign) BOOL isPDF;

@property(nonatomic, retain) NSString *columnName;
@property(nonatomic, retain) UIImageView *bottomTag;
@property(nonatomic, retain) UIButton *button;
- (void)reloadData;
- (void)selectTabAtIndex:(int)index;

@end

@protocol PDFColumnBarDataSource <NSObject>

- (Column *)columnBar:(PDFColumnBar *)columnBar titleForTabAtIndex:(int)index;

@optional
- (int)numberOfTabsInColumnBar:(PDFColumnBar *)columnBar;
- (int)parentIdOfTabsInColumnBar;
- (int)IdOfTabsInColumnBar:(int)index;
- (Column*)ColumnOfTabsInColumnBar:(int)index;
- (void)UpdateTabsInColumnBar:(NSMutableArray*)msArray;
@end

@protocol PDFColumnBarDelegate <NSObject>

- (void)columnBar:(PDFColumnBar *)columnBar didSelectedTabAtIndex:(int)index;

@optional
- (void)moreClick;

@end
