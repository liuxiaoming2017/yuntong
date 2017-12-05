//
//  BUPOViewController.h
//  ZakerLike
//
//  Created by bupo Jung on 12-5-15.
//  Copyright (c) 2012年 Wuxi Smart Sencing Star. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "BJGridItem.h"
@protocol BUPOViewDelegate;
@interface BUPOViewController : UIViewController<UIScrollViewDelegate,BJGridItemDelegate,UIGestureRecognizerDelegate>{
    NSMutableArray *gridItems;
    BJGridItem *addbutton;
    
    BOOL backItem;
    int page;
    float preX;
    BOOL isMoving;
    CGRect preFrame;
    BOOL isEditing;
    UITapGestureRecognizer *singletap;
    NSMutableArray *selectItems;
    NSMutableArray *selectedItems;
    
    UIScrollView *selectedView;
    UIScrollView *selectView;
    
    UIView *moreColumnsView;
    UIView *myColumnsView;
    
    UIImageView *backgoundImage;
    UIScrollView *scrollview;
    
    UILabel *headerLabel;
    CGRect itemframe;
    float rowHeight;
    float space;
    int j;
    int _parentID;
    int _currentID;
    id<BUPOViewDelegate>  _delegate;
//    CGRect MovingToFrame;
//    CGRect MovingFromFrame;
//    NSInteger MovingToIndex;
//    NSInteger MovingFromIndex;
    BOOL isDelete;
    BOOL isChang;

}
- (void)Addbutton:(int) index;
- (void)Editbutton:(int) index;
- (int) GetArrIdByIndex:(NSMutableArray*)items atIndex:(int)index;
- (void)RemoveObject:(NSMutableArray*)items atIndex:(int)index;
- (void)SortItems:(NSMutableArray*) items;
- (BJGridItem*) GetItematIndex:(NSMutableArray*)items atIndex:(NSInteger)index;
- (void)exchangeObjectAtIndex:(NSMutableArray*)items oldIndex:(int)oldindex newIndex:(int)newindex;
- (void)initWithColumns:(NSArray*) allColumns parentcolumnid:(int) parentcolumnid;
- (int)GetItemPosAtIndex:(NSMutableArray*)items atIndex:(int)index;

@property(nonatomic, assign) id<BUPOViewDelegate>      delegate;
@property(nonatomic, retain) UILabel* headerLabel;
//@property(nonatomic, assign) int currentID;
@property(nonatomic, retain) NSString *currentName;
@property(nonatomic, retain) NSArray *selectedArray;
@end

@protocol BUPOViewDelegate <NSObject>
@optional
- (void)refreshcolumnbar:(int) columnID;
- (void)refreshcolumnbarNoMoreColumn:(int) columnID;

@end
