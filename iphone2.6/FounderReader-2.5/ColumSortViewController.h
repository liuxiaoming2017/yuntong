//
//  ColumSortViewController.h
//  FounderReader-2.5
//
//  Created by jiangnan on 15/9/22.
//
//

#import "InformPageController.h"
#import "Column.h"


@interface ColumSortViewController : ChannelPageController<UIScrollViewDelegate>
{
    UIScrollView *_topScrollView;
    UIScrollView *_bottomScrollView;
    
    NSMutableArray *_zjArray;
    NSMutableArray *_zjBottomArray;

    UIView *moreColumnsView;
    
    //拖动按钮的起始位置
    CGPoint _dragFromPoint;
    
    //移动到的位置中心
    CGPoint _dragToPoint;
    
    //移动到的最后的位置
    CGRect _dragToFrame;
    BOOL _isDragTileContainedInOtherTile;
    
    NSMutableArray *_moreArray;
    
}

@property (nonatomic,retain) NSMutableArray *topColumArray;
@property (nonatomic,retain) NSMutableArray *bottomColumArray;
@property (nonatomic,retain) Column *subscribe;

@end

@interface ToolClass : NSObject

/**
 *  动画完成回调
 *
 *  @param AnimateFinish 动画完成回调Block
 */
typedef void (^AnimateFinish)(UIView*);


/**
 *  点击View移动动画
 *
 *  @param sender     手势对象
 *  @param vc         当前控制器
 *  @param height     TopScrollview高
 *  @param array      View数组
 *  @param laseViewx  最后一个view的坐标
 *  @param viewWidth  view宽度
 *  @param viewHeight view高度
 *  @param istop      是否点击TopView
 *  @param finish     完成动画回调
 */
+(void)tapViewMoveAnimate:(UITapGestureRecognizer *)sender VC:(UIViewController*)vc TopVCHeight:(CGFloat)height BottomArray:(NSMutableArray*)array LastViewX:(CGFloat)laseViewx ViewWidth:(CGFloat)viewWidth ViewHeight:(CGFloat)viewHeight isTop:(BOOL)istop AnimateFinish:(AnimateFinish)finish;
@end

