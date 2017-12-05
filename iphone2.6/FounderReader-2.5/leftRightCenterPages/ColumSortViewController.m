//
//  ColumSortViewController.m
//  FounderReader-2.5
//
//  Created by jiangnan on 15/9/22.
//
//

#import "ColumSortViewController.h"


#define LastObjectX ((UIView*)[array lastObject]).frame.origin.x

#define LaseObjectY ((UIView*)[array lastObject]).frame.origin.y

#define NewViewWidth sender.view.frame.size.width

#define NewViewHeight sender.view.frame.size.height

@implementation ToolClass


+(void)tapViewMoveAnimate:(UITapGestureRecognizer *)sender VC:(UIViewController*)vc TopVCHeight:(CGFloat)height BottomArray:(NSMutableArray*)array LastViewX:(CGFloat)laseViewx ViewWidth:(CGFloat)viewWidth ViewHeight:(CGFloat)viewHeight isTop:(BOOL)istop AnimateFinish:(AnimateFinish)finish {
    UIView *newView = [self customSnapshoFromView:sender.view];
    
    sender.view.hidden = YES;
    
    CGFloat newViewHeight = istop == YES ? 10 : height;
    
    newView.frame = CGRectMake(sender.view.frame.origin.x,  newViewHeight + 5 + sender.view.frame.origin.y, NewViewWidth, NewViewHeight);
    
    [vc.view addSubview:newView];
    
    CGFloat newViweX = LastObjectX == laseViewx ? 10 : array.count == 0 ? 10 : LastObjectX + 10 + viewWidth;
    
    CGFloat newViewY = LastObjectX == laseViewx ? istop == YES ? height + LaseObjectY + viewHeight + 5 : LaseObjectY + viewHeight + 5 : istop == YES ? height + LaseObjectY : LaseObjectY;
    
    [UIView animateWithDuration:0.5 animations:^{
        
        if (sender.view.tag >99) {
            newView.frame = CGRectMake(newViweX, newViewY+100,NewViewWidth , NewViewHeight);
        }else {
            newView.frame = CGRectMake(newViweX, newViewY+50,NewViewWidth , NewViewHeight);
        }
        
        
    } completion:^(BOOL finished) {
        
        finish(newView);
    }];
    
}


+ (UIView *)customSnapshoFromView:(UIView *)inputView {
    
    // Make an image from the input view.
    UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, NO, 0);
    [inputView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Create an image view.
    UIView *snapshot = [[UIImageView alloc] initWithImage:image];
    snapshot.layer.masksToBounds = NO;
    snapshot.layer.cornerRadius = 0.0;
    snapshot.layer.shadowOffset = CGSizeMake(-5.0, 0.0);
    snapshot.layer.shadowRadius = 5.0;
    snapshot.layer.shadowOpacity = 0.4;
    
    return snapshot;
}

@end

#define lastViewX (10+(viewWidth+10)*(3%4))

#define viewWidth ((self.view.bounds.size.width-50)/4)

#define viewHeight viewWidth*3/5

@interface ColumSortViewController ()

@end

@implementation ColumSortViewController

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController.navigationBar setShadowImage:[UIImage createImageWithColor:[UIColor redColor]]];
    
    [self rightPageNavTopButtons];
    
    [super viewWillAppear:animated];
    
    [self titleLableWithTitle:@"频道管理"];
    
    _moreArray        = [[NSMutableArray alloc]init];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray* array = [defaults objectForKey:@"more"];
    for (NSData* data in array) {
        Column *column = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        [_moreArray addObject:column];
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"whiteBack"] style:UIBarButtonItemStylePlain target:self action:@selector(goRightPageBack)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    _zjArray          = [[NSMutableArray alloc]init];
    _zjBottomArray    = [[NSMutableArray alloc]init];
    
    [self.view addSubview:[self myColumnsView]];
    [self viewConfig];
    
}

-(UIView*)myColumnsView
{
    UIView *myColumnsView = [[UIView alloc]init];
    myColumnsView.frame = CGRectMake(0, 0, self.view.frame.size.width, 50);
    myColumnsView.backgroundColor = [UIColor whiteColor];
    
    UIView *redView = [[UIView alloc]initWithFrame:CGRectMake(10, 15, 5, myColumnsView.frame.size.height-30)];
    redView.backgroundColor = [UIColor redColor];
    [myColumnsView addSubview:redView];
    
    UILabel *myColumsLabel = [[UILabel alloc]initWithFrame:CGRectMake(redView.frame.origin.x+redView.frame.size.width+10, redView.frame.origin.y, 70, redView.frame.size.height)];
    myColumsLabel.text = @"我的频道";
    myColumsLabel.font = [UIFont systemFontOfSize:16];
    [myColumnsView addSubview:myColumsLabel];
    
    UILabel *operationLabel = [[UILabel alloc]initWithFrame:CGRectMake(myColumsLabel.frame.origin.x+myColumsLabel.frame.size.width+10,myColumsLabel.frame.origin.y, 200, myColumsLabel.frame.size.height)];
    operationLabel.text = @"单击删除频道，长按拖拽排序";
    operationLabel.font = [UIFont systemFontOfSize:13];
    operationLabel.textColor = [UIColor lightGrayColor];
    [myColumnsView addSubview:operationLabel];
    
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, myColumnsView.frame.size.height-1, self.view.frame.size.width, .5)];
    lineView.backgroundColor = [UIColor lightGrayColor];
    [myColumnsView addSubview:lineView];
    
    return myColumnsView;
}

-(UIView*)moreColumnsView
{
    
    moreColumnsView = [[UIView alloc]init];
    moreColumnsView.frame = CGRectMake(0, _topScrollView.frame.size.height+_topScrollView.frame.origin.y, self.view.frame.size.width, 50);
    moreColumnsView.backgroundColor = [UIColor whiteColor];
    
    UIView *topLineView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, .5)];
    topLineView.backgroundColor = [UIColor lightGrayColor];
    [moreColumnsView addSubview:topLineView];
    
    UIView *redView = [[UIView alloc]initWithFrame:CGRectMake(10, 15, 5, moreColumnsView.frame.size.height-30)];
    redView.backgroundColor = [UIColor redColor];
    [moreColumnsView addSubview:redView];
    
    UILabel *myColumsLabel = [[UILabel alloc]initWithFrame:CGRectMake(redView.frame.origin.x+redView.frame.size.width+10, redView.frame.origin.y, 70, redView.frame.size.height)];
    myColumsLabel.text = @"更多频道";
    myColumsLabel.font = [UIFont systemFontOfSize:16];
    [moreColumnsView addSubview:myColumsLabel];
    
    UILabel *operationLabel = [[UILabel alloc]initWithFrame:CGRectMake(myColumsLabel.frame.origin.x+myColumsLabel.frame.size.width+10,myColumsLabel.frame.origin.y, 200, myColumsLabel.frame.size.height)];
    operationLabel.text = @"单击添加频道";
    operationLabel.font = [UIFont systemFontOfSize:13];
    operationLabel.textColor = [UIColor lightGrayColor];
    [moreColumnsView addSubview:operationLabel];
    
    return moreColumnsView;
}

-(void)viewConfig
{
    _topScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 50, self.view.bounds.size.width, (self.view.bounds.size.height-64-50)/2-25)];
    _topScrollView.delegate = self;
    [self.view addSubview:_topScrollView];
    
    for (int i = 0; i < _topColumArray.count; i++) {
        Column *column = [_topColumArray objectAtIndex:i];
        
        
//        我的频道--单击--删除频道
        UIView *topView = [[UIButton alloc]initWithFrame:CGRectMake(10+(viewWidth+10)*(i%4), 10+(viewHeight+5)*(i/4), viewWidth, viewHeight)];
        [topView setBackgroundColor:[UIColor whiteColor]];
        topView.tag = 100+i;
        topView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        topView.layer.borderWidth = .5;
        [_topScrollView addSubview:topView];
        
        UILabel *topLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, topView.frame.size.width, topView.frame.size.height)];
        topLabel.textAlignment = NSTextAlignmentCenter;
        topLabel.text = column.columnName;
        topLabel.font = [UIFont systemFontOfSize:14];
        [topView addSubview:topLabel];
        
        UITapGestureRecognizer *topTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(topTapClick:)];
        [topView addGestureRecognizer:topTap];
        
        UILongPressGestureRecognizer * panTap = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handlePanGesture:)];
        [topView addGestureRecognizer:panTap];
        
        [_zjArray addObject:topView];
        
    }
    if ((_topColumArray.count)%4 == 0) {
        _topScrollView.contentSize = CGSizeMake(self.view.frame.size.width, (viewHeight+5)*((_topColumArray.count)/4)+15);
    }else {
        _topScrollView.contentSize = CGSizeMake(self.view.frame.size.width, (viewHeight+5)*((_topColumArray.count)/4+1)+15);
    }
    
    
    
//        更多频道--单击--添加频道
    UIView *middleView = [[UIView alloc]initWithFrame:CGRectMake(0, _topScrollView.frame.size.height+_topScrollView.frame.origin.y, self.view.frame.size.width, 10)];
    middleView.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:middleView];
    
    [self.view addSubview:[self moreColumnsView]];
    
    _bottomScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, moreColumnsView.frame.origin.y+moreColumnsView.frame.size.height, self.view.frame.size.width, (self.view.bounds.size.height-64-50)/2-25)];
    _bottomScrollView.delegate = self;
    [self.view addSubview:_bottomScrollView];
    
    for (int i = 0; i < _bottomColumArray.count; i++) {
        
        Column *column = [_bottomColumArray objectAtIndex:i];
        
        UIView *bottomView = [[UIButton alloc]initWithFrame:CGRectMake(10+(viewWidth+10)*(i%4), 10+(viewHeight+5)*(i/4), viewWidth, viewHeight)];
        [bottomView setBackgroundColor:[UIColor whiteColor]];
        bottomView.tag = i;
        bottomView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        bottomView.layer.borderWidth = .5;
        [_bottomScrollView addSubview:bottomView];
        
        UILabel *bottomLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, bottomView.frame.size.width, bottomView.frame.size.height)];
        bottomLabel.textAlignment = NSTextAlignmentCenter;
        bottomLabel.text = column.columnName;
        bottomLabel.font = [UIFont systemFontOfSize:14];
        [bottomView addSubview:bottomLabel];
        
        UITapGestureRecognizer *bottomTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(bottomTapClick:)];
        [bottomView addGestureRecognizer:bottomTap];
        
        [_zjBottomArray addObject:bottomView];
    }
    
    if (_bottomColumArray.count%4 == 0) {
        _bottomScrollView.contentSize = CGSizeMake(self.view.frame.size.width, (viewHeight+5)*(_bottomColumArray.count/4)+15);
    }else {
        _bottomScrollView.contentSize = CGSizeMake(self.view.frame.size.width, (viewHeight+5)*(_bottomColumArray.count/4+1)+15);
    }
    
}
#pragma mark - 单击删除频道
-(void)topTapClick:(UITapGestureRecognizer*)sender
{
    //要闻栏目不允许排序；
    if(sender.view.tag == 100)
        return;
    [ToolClass tapViewMoveAnimate:sender VC:self TopVCHeight:_topScrollView.frame.size.height BottomArray:_zjBottomArray LastViewX:lastViewX ViewWidth:viewWidth ViewHeight:viewHeight isTop:YES AnimateFinish:^(UIView * view) {
        
        Column *topColumn = [_topColumArray objectAtIndex:sender.view.tag-100];
        if (_moreArray.count) {
            for (int i = 0; i < _moreArray.count; i++) {
                Column *moreColumn = [_moreArray objectAtIndex:i];
                if (moreColumn.columnId == topColumn.columnId) {
                    [_moreArray removeObjectAtIndex:i];
                    
                }
            }
        }
        
        [self saveMoreColumns];
        
        [_bottomColumArray addObject:[_topColumArray objectAtIndex:sender.view.tag-100]];
        [_topColumArray removeObjectAtIndex:sender.view.tag-100];
        [self viewReload];
        [view removeFromSuperview];
        [self saveColumns];
        
    }];
    
}
#pragma mark - 单击添加频道
-(void)bottomTapClick:(UITapGestureRecognizer*)sender
{
    [ToolClass tapViewMoveAnimate:sender VC:self TopVCHeight:_topScrollView.frame.size.height BottomArray:_zjArray LastViewX:lastViewX ViewWidth:viewWidth ViewHeight:viewHeight isTop:NO AnimateFinish:^(UIView *view){
        
        
        [_moreArray addObject:(Column*)[_bottomColumArray objectAtIndex:sender.view.tag]];
        [self saveMoreColumns];
        
        [_topColumArray addObject:[_bottomColumArray objectAtIndex:sender.view.tag]];
        
        [_bottomColumArray removeObjectAtIndex:sender.view.tag];
        
        [self viewReload];
        
        [view removeFromSuperview];
        
        [self saveColumns];
        
    }];
}
#pragma mark
-(void)saveMoreColumns
{
    NSMutableArray *dataArray = [NSMutableArray arrayWithCapacity:50];
    for (int i = 0; i<_moreArray.count; i++) {
        Column *column = [_moreArray objectAtIndex:i];
        Column *col = [[Column alloc] init];
        col.columnId = column.columnId;
        col.columnName = column.columnName;
        col.columnStyle = column.columnStyle;
        
        col.columnType = column.columnType;
        col.topArticleNum = column.topArticleNum;
        col.orderId = column.orderId;
        
        col.showcolumn = column.showcolumn;
        col.padIcon = column.padIcon;
        col.description = column.description;
        
        col.columnvalue = column.columnvalue;
        col.className = column.className;
        col.iconUrl = column.iconUrl;
        
        col.retinaIconUrl = column.retinaIconUrl;
        col.linkUrl = column.linkUrl;
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:col];
        [dataArray addObject:data];
    }
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"more"];
    NSArray *arr = [NSArray arrayWithArray:dataArray];
    [[NSUserDefaults standardUserDefaults] setObject:arr forKey:@"more"];
}

-(void)saveColumns
{
    NSMutableArray *dataArray = [NSMutableArray arrayWithCapacity:50];
    for (int i = 0; i<_topColumArray.count; i++) {
        Column *column = [_topColumArray objectAtIndex:i];
        Column *col = [[Column alloc] init];
        col.columnId = column.columnId;
        col.columnName = column.columnName;
        col.columnStyle = column.columnStyle;
        
        col.columnType = column.columnType;
        col.topArticleNum = column.topArticleNum;
        col.orderId = column.orderId;
        
        col.showcolumn = column.showcolumn;
        col.padIcon = column.padIcon;
        col.description = column.description;
        
        col.columnvalue = column.columnvalue;
        col.className = column.className;
        col.iconUrl = column.iconUrl;
        
        col.retinaIconUrl = column.retinaIconUrl;
        col.linkUrl = column.linkUrl;
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:col];
        [dataArray addObject:data];
    }
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"left"];
    NSData *subscribeData = [NSKeyedArchiver archivedDataWithRootObject:self.subscribe];
    [dataArray addObject:subscribeData];
    
    NSArray *arr = [NSArray arrayWithArray:dataArray];
    [[NSUserDefaults standardUserDefaults] setObject:arr forKey:@"left"];
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshColumn" object:nil];
}

- (void)handlePanGesture:(UIGestureRecognizer *)recognizer
{
    
    switch (recognizer.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            [self dragTileBegan:recognizer];
            [self startShake:recognizer.view];
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            [self dragTileMoved:recognizer];
            break;
        }
        case UIGestureRecognizerStateEnded:
        {
            [self dragTileEnded:recognizer];
            [self stopShake:recognizer.view];
            [self saveColumns];
            break;
        }
            
        default:
            break;
    }
    
}

-(void)viewReload
{
    for (UIView* subView in _topScrollView.subviews)
    {
        [subView removeFromSuperview];
    }
    for (UIView* subView in _bottomScrollView.subviews)
    {
        [subView removeFromSuperview];
    }

    [_zjArray removeAllObjects];
    [_zjBottomArray removeAllObjects];
    
    for (int i = 0; i < _topColumArray.count; i++) {
        
        Column *column = [_topColumArray objectAtIndex:i];
        
        UIView *topView = [[UIButton alloc]initWithFrame:CGRectMake(10+(viewWidth+10)*(i%4), 10+(viewHeight+5)*(i/4), viewWidth, viewHeight)];
        [topView setBackgroundColor:[UIColor whiteColor]];
        topView.tag = 100+i;
        topView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        topView.layer.borderWidth = .5;
        [_topScrollView addSubview:topView];
 
        
        UILabel *topLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, topView.frame.size.width, topView.frame.size.height)];
        topLabel.textAlignment = NSTextAlignmentCenter;
        topLabel.text = column.columnName;
        topLabel.font = [UIFont systemFontOfSize:14];
        [topView addSubview:topLabel];
        
        UITapGestureRecognizer *topTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(topTapClick:)];
        [topView addGestureRecognizer:topTap];
        
        UILongPressGestureRecognizer * panTap = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handlePanGesture:)];
        [topView addGestureRecognizer:panTap];
        
        [_zjArray addObject:topView];
        
    }
    if ((_topColumArray.count)%4 == 0) {
        _topScrollView.contentSize = CGSizeMake(self.view.frame.size.width, (viewHeight+5)*((_topColumArray.count)/4)+15);
    }else {
        _topScrollView.contentSize = CGSizeMake(self.view.frame.size.width, (viewHeight+5)*((_topColumArray.count)/4+1)+15);
    }
    
    for (int i = 0; i < _bottomColumArray.count; i++) {
        Column *column = [_bottomColumArray objectAtIndex:i];
        
        UIView *bottomView = [[UIButton alloc]initWithFrame:CGRectMake(10+(viewWidth+10)*(i%4), 10+(viewHeight+5)*(i/4), viewWidth, viewHeight)];
        [bottomView setBackgroundColor:[UIColor whiteColor]];
        bottomView.tag = i;
        bottomView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        bottomView.layer.borderWidth = .5;
        [_bottomScrollView addSubview:bottomView];
        
        UILabel *bottomLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, bottomView.frame.size.width, bottomView.frame.size.height)];
        bottomLabel.textAlignment = NSTextAlignmentCenter;
        bottomLabel.text = column.columnName;
        bottomLabel.font = [UIFont systemFontOfSize:14];
        [bottomView addSubview:bottomLabel];
        
        UITapGestureRecognizer *bottomTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(bottomTapClick:)];
        [bottomView addGestureRecognizer:bottomTap];
        
        [_zjBottomArray addObject:bottomView];
    }
    
    if (_bottomColumArray.count%4 == 0) {
        _bottomScrollView.contentSize = CGSizeMake(self.view.frame.size.width, (viewHeight+5)*(_bottomColumArray.count/4)+15);
    }else {
        _bottomScrollView.contentSize = CGSizeMake(self.view.frame.size.width, (viewHeight+5)*(_bottomColumArray.count/4+1)+15);
    }
}

- (void)dragTileBegan:(UIGestureRecognizer *)recognizer
{
    //把要移动的视图放在顶层
    [_topScrollView bringSubviewToFront:recognizer.view];
    
    _dragFromPoint = recognizer.view.center;
}

- (void)dragTileMoved:(UIGestureRecognizer *)recognizer
{
    CGPoint locationPoint = [recognizer locationInView:_topScrollView];
    recognizer.view.center = locationPoint;
    [self pushedTileMoveToDragFromPointIfNecessaryWithTileView:(UIView *)recognizer.view];
}

- (void)pushedTileMoveToDragFromPointIfNecessaryWithTileView:(UIView *)tileView
{
    for (UIButton *item in _topScrollView.subviews)
    {
        //移动到另一个按钮的区域，判断需要移动按钮的位置
        if (CGRectContainsPoint(item.frame, tileView.center) && item != tileView )
        {
            
            //开始的位置
            NSInteger fromIndex = tileView.tag - 100;
            //需要移动到的位置
            NSInteger toIndex = (item.tag - 100)>0?(item.tag - 100):0;
            if(toIndex == 0 || fromIndex == 0){
                //要闻栏目不允许排序；
                return;
            }
            NSLog(@"从位置%ld移动到位置%ld",(long)fromIndex, (long)toIndex);
            [self dragMoveFromIndex:fromIndex ToIndex:toIndex withView:tileView];
        }
    }
}

- (void)dragMoveFromIndex:(NSInteger)fromIndex ToIndex:(NSInteger)toIndex withView:(UIView *)tileView
{
    //局部变量是不能在闭包中发生改变的，所以需要把_dragFromPoint，_dragToPoint定义成全局变量
    __block NSMutableArray * bnewAlbumlist = _topColumArray;
    __block UIScrollView * bphotoScrol = _topScrollView;
    NSDictionary * moveDict = [bnewAlbumlist objectAtIndex:fromIndex];
    [bnewAlbumlist removeObjectAtIndex:fromIndex];
    [bnewAlbumlist insertObject:moveDict atIndex:toIndex];
    //向前移动
    if (fromIndex > toIndex)
    {
        //把移动相册的上一个相册移动到记录的移动相册的位置，并把上一相册的位置记为新的_dragFromPoint，并把view的tag值+1,依次处理
        [UIView animateWithDuration:0.3 animations:^{
            
            for (int i = fromIndex - 1; i >= toIndex; i--)
            {
                UIButton * dragBu = (UIButton *)[bphotoScrol viewWithTag:i + 100];
                _dragToPoint = dragBu.center;
                dragBu.center = _dragFromPoint;
                _dragFromPoint = _dragToPoint;
                dragBu.tag ++;
            }
            tileView.tag = 100 + toIndex;
            
        }];
        
    }
    //向后移动
    else
    {
        //把移动相册的下一个相册移动到记录的移动相册的位置，并把下一相册的位置记为新的_dragFromPoint，并把view的tag值-1,依次处理
        [UIView animateWithDuration:0.3 animations:^{
            for (int i = fromIndex + 1; i <= toIndex; i++)
            {
                UIButton * dragBu = (UIButton *)[bphotoScrol viewWithTag:i + 100];
                _dragToPoint = dragBu.center;
                dragBu.center = _dragFromPoint;
                _dragFromPoint = _dragToPoint;
                dragBu.tag --;
            }
            tileView.tag = 100 + toIndex;
            
        }];
    }
    
}

- (void)dragTileEnded:(UIGestureRecognizer *)recognizer
{
    [UIView animateWithDuration:0.2f animations:^{
        if (_isDragTileContainedInOtherTile)
            recognizer.view.center = _dragToPoint;
        else
            recognizer.view.center = _dragFromPoint;
    }];
    _isDragTileContainedInOtherTile = NO;
}

#pragma mark - 拖动晃动
- (void)startShake:(UIView* )imageV
{
    CABasicAnimation *shakeAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    shakeAnimation.duration = 0.08;
    shakeAnimation.autoreverses = YES;
    shakeAnimation.repeatCount = MAXFLOAT;
    shakeAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DRotate(imageV.layer.transform, -0.06, 0, 0, 1)];
    shakeAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DRotate(imageV.layer.transform, 0.06, 0, 0, 1)];
    [imageV.layer addAnimation:shakeAnimation forKey:@"shakeAnimation"];
}

- (void)stopShake:(UIView* )imageV
{
    [imageV.layer removeAnimationForKey:@"shakeAnimation"];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

 

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
