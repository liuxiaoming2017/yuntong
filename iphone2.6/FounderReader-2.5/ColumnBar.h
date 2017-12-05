//
//  ColumnBar.h
//  ColumnBarDemo
//
//  Created by chenfei on 4/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ColumnBarDataSource;
@protocol ColumnBarDelegate;

#import "BUPOViewController.h"
#import "Column.h"
@interface ColumnBar : UIImageView <UIScrollViewDelegate> {
    UIScrollView    *scrollView;
    UIImageView     *leftCap;
    UIImageView     *rightCap;
    UIImageView     *moreCap;
    int             selectedIndex;
    int             lastSelectIndex;
    
    id<ColumnBarDataSource> dataSource;
    id<ColumnBarDelegate>   delegate;
}

@property(nonatomic, retain) UIScrollView               *scrollView;

@property(nonatomic, assign) int                        selectedIndex;

@property(nonatomic, retain) id<ColumnBarDataSource>    dataSource;
@property(nonatomic, retain) id<ColumnBarDelegate>      delegate;

@property(nonatomic, assign) BOOL enabled;
@property(nonatomic, retain) NSString *columnName;
@property(nonatomic, retain) UIImageView *bottomTag;

- (id)initWithFrame:(CGRect)frame withIsFirstNewsVC:(BOOL)isFirstNewsVC ViewControllerType:(FDViewControllerType)viewControllerType;
- (void)reloadData:(Column *)parentColumn;
- (void)selectTabAtIndex:(int)index;
-(void)setColumnBarY:(CGFloat)y;
@end

@protocol ColumnBarDataSource <NSObject>

- (Column *)columnBar:(ColumnBar *)columnBar titleForTabAtIndex:(int)index;

@optional
- (int)numberOfTabsInColumnBar:(ColumnBar *)columnBar;
- (int)parentIdOfTabsInColumnBar;
- (int)IdOfTabsInColumnBar:(int)index;
- (Column*)ColumnOfTabsInColumnBar:(int)index;
- (void)UpdateTabsInColumnBar:(NSMutableArray*)msArray;


@end

@protocol ColumnBarDelegate <NSObject>

- (void)columnBar:(ColumnBar *)columnBar didSelectedTabAtIndex:(int)index;

@optional
- (void)moreClick;

@end
