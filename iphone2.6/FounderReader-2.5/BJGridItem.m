//
//  BJGridItem.m
//  ZakerLike
//
//  Created by bupo Jung on 12-5-15.
//  Copyright (c) 2012年 Wuxi Smart Sencing Star. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "BJGridItem.h"
#import "NewsListConfig.h"
#import "ColumnBarConfig.h"
//#define itemframe CGRectMake(100, 15, 150, 50)
#define deleteiconX 20
#define deleteiconY 20
#define offsetX -5
#define offsetY -5

@implementation BJGridItem
@synthesize isEditing,isRemovable,index,ID;
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id) initWithTitle:(NSString *)title withImageName:(NSString *)imageName atIndex:(NSInteger)aIndex editable:(BOOL)removable groupid:(NSInteger) groupid  ID:(int)_id currentName:(NSString*)currentName{
    self = [super initWithFrame:CGRectMake(0.05*kSWidth, (26/1136.0)*kSHeight, (172/640.0)*kSWidth, (52/1136.0)*kSHeight)];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        normalImage = [UIImage imageNamed:imageName];
        titleText = title;
        self.isEditing = NO;
        index = aIndex;
        groupId = groupid;

        self.isRemovable = removable;
        
        //第一个栏目不允许删除
        if (aIndex == 0) {
            self.isRemovable = NO;
        }
        ID = _id;
        
        // place a clickable button on top of everything
        _button= [UIButton buttonWithType:UIButtonTypeRoundedRect];
        _button.layer.cornerRadius=5;
        [_button.layer setBorderWidth:1];
//        [button.layer setBorderColor:[[UIColor darkGrayColor]CGColor]];  //设置边框为深灰色
        [_button.layer setBorderColor:UIColorFromString(@"221,221,221").CGColor];
        
        [_button setFrame:self.bounds];
        [_button setBackgroundColor:[UIColor whiteColor]];
//        if ([title isEqualToString:currentName]) {
//            [_button setTitleColor:[UIColor colorWithRed:0x39/255.0 green:0xd2/255.0 blue:0xe0/255.0 alpha:1] forState:UIControlStateNormal];
//            [_button.layer setBorderColor:[UIColor colorWithRed:0x39/255.0 green:0xd2/255.0 blue:0xe0/255.0 alpha:1].CGColor];
//        }
        [_button setTitle:titleText forState:UIControlStateNormal];
        
        [_button.titleLabel setFont: [UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleCellTitleFontSize]];
        [_button setTitleColor:UIColorFromString(@"90,90,90") forState:UIControlStateNormal];
        if ([title isEqualToString:currentName]) {
            [_button setTitleColor:[ColumnBarConfig sharedColumnBarConfig].column_all_color forState:UIControlStateNormal];
            [_button.layer setBorderColor:[ColumnBarConfig sharedColumnBarConfig].column_all_color.CGColor];
        }
    
       [_button addTarget:self action:@selector(clickItem:) forControlEvents:UIControlEventTouchUpInside];
        if (groupid)
        {
            UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(pressedLong:)];
            UIPanGestureRecognizer *panPress = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pressedPan:)];
            UITapGestureRecognizer *tapPress=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pressedTap:)];
            tapPress.numberOfTapsRequired=1;
            tapPress.numberOfTouchesRequired=1;
            
            //longPress.minimumPressDuration=0.5;
            [self addGestureRecognizer:longPress];
            [self addGestureRecognizer:panPress];
            [self addGestureRecognizer:tapPress];
            
        }
        //[button addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];

        [self addSubview:_button];
        
//        [self performSelector:@selector(delay:) withObject:_button afterDelay:0.3];
        
        
        if (self.isRemovable) {
            // place a remove button on top right corner for removing item from the board
            float w = deleteiconX;
            float h = deleteiconY;
            
            deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [deleteButton setBackgroundColor: [UIColor clearColor]];
            [deleteButton setFrame:CGRectMake(offsetX, offsetY, w, h)];
            [deleteButton setImage:[UIImage imageNamed:@"column_bar_delete.png"] forState:UIControlStateNormal];
            [deleteButton setImage:[UIImage imageNamed:@"column_bar_delete.png"] forState:UIControlStateHighlighted];
            [deleteButton addTarget:self action:@selector(removeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [deleteButton setHidden:YES];

            [self addSubview:deleteButton];
        }
        _button.titleLabel.font = [UIFont systemFontOfSize: 14.0];
    }
    return self;
}


//-(void)delay:(UIButton *)button
//{
//    [_button setTitle:titleText forState:UIControlStateNormal];
//    
//    [_button.titleLabel setFont: [UIFont boldSystemFontOfSize:14]];
//    [_button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
//    if ([_title isEqualToString:currentName]) {
//        [_button setTitleColor:[UIColor colorWithRed:0x39/255.0 green:0xd2/255.0 blue:0xe0/255.0 alpha:1] forState:UIControlStateNormal];
//        [_button.layer setBorderColor:[UIColor colorWithRed:0x39/255.0 green:0xd2/255.0 blue:0xe0/255.0 alpha:1].CGColor];
//    }
//}
#pragma mark - UI actions

- (void) clickItem:(id)sender {
    NSLog(@"clickItem");
    [_delegate gridItemDidClicked:self];
}
- (void) pressedLong:(UILongPressGestureRecognizer *) gestureRecognizer{
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
            point = [gestureRecognizer locationInView:self];
            [_delegate gridItemDidEnterEditingMode:self];
            //放大这个item
            //[self setAlpha:1.0];
            NSLog(@"press long began");
            break;
        case UIGestureRecognizerStateEnded:
            /*point = [gestureRecognizer locationInView:self];
            [_delegate gridItemDidMoved:self withLocation:point moveGestureRecognizer:gestureRecognizer];
            [_delegate gridItemDidEndMoved:self withLocation:point moveGestureRecognizer:gestureRecognizer];*/
            //变回原来大小
            //[self setAlpha:0.5f];
            NSLog(@"press long ended");
            break;
        case UIGestureRecognizerStateFailed:
            NSLog(@"press long failed");
            break;
        case UIGestureRecognizerStateChanged:
            //移动
            /*[_delegate gridItemDidMoving:self withLocation:point moveGestureRecognizer:gestureRecognizer];*/
            NSLog(@"press long changed");
            break;
        default:
            NSLog(@"press long else");
            break;
    }
    
    //CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:@"transform"];
    
}
- (void) pressedPan:(UILongPressGestureRecognizer *) gestureRecognizer{
    
    //第一个栏目不允许删除
    if (self.index == 0) {
        return;
    }
    if (self.isEditing==YES) {
        switch (gestureRecognizer.state) {
            case UIGestureRecognizerStateBegan:
                point = [gestureRecognizer locationInView:self];
                [_delegate gridItemDidEnterEditingMode:self];
                //放大这个item
                //[self setAlpha:1.0];
                NSLog(@"press pan began");
                break;
            case UIGestureRecognizerStateEnded:
                point = [gestureRecognizer locationInView:self];
                [_delegate gridItemDidMoved:self withLocation:point moveGestureRecognizer:gestureRecognizer];
                [_delegate gridItemDidEndMoved:self withLocation:point moveGestureRecognizer:gestureRecognizer];
                //变回原来大小
                //[self setAlpha:0.5f];
                NSLog(@"press pan ended");
                break;
            case UIGestureRecognizerStateFailed:
                NSLog(@"press pan failed");
                break;
            case UIGestureRecognizerStateChanged:
                //移动
                [_delegate gridItemDidMoving:self withLocation:point moveGestureRecognizer:gestureRecognizer];
                NSLog(@"press an changed");
                break;
            default:
                NSLog(@"press long else");
                break;
        }

    }else
        return;
    
    //CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:@"transform"];
    
}

- (void) pressedTap:(UITapGestureRecognizer *) gestureRecognizer{
    
    //第一个栏目不允许删除
    if (self.index == 0) {
        return;
    }
    CGPoint _point = [gestureRecognizer locationInView:self];
    if (_point.y < deleteiconX && _point.y < deleteiconY)
    {
        [_delegate gridItemDidDeleted:self atIndex:index];
        NSLog(@"pressedTap Delete:%ld",(long)index);
    }
}

- (void) removeButtonClicked:(id) sender  {
    
    //第一个栏目不允许删除
    if (self.index == 0) {
        return;
    }
    [_delegate gridItemDidDeleted:self atIndex:index];
    NSLog(@"removeButtonClicked Delete:%ld",(long)index);
}

#pragma mark - Custom Methods

- (void) enableEditing {
    if (self.isEditing == YES)
        return;

    // put item in editing mode
    self.isEditing = YES;
    
    // make the remove button visible
    [deleteButton setHidden:NO];
    [_button setEnabled:NO];
    // start the wiggling animation
    CGFloat rotation = 0.08;
    
    CABasicAnimation *shake = [CABasicAnimation animationWithKeyPath:@"transform"];
    shake.duration = 0.13;
    shake.autoreverses = YES;
    shake.repeatCount  = MAXFLOAT;
    shake.removedOnCompletion = NO;
    shake.fromValue = [NSValue valueWithCATransform3D:CATransform3DRotate(self.layer.transform,-rotation, 0.0 ,0.0 ,1.0)];
    shake.toValue   = [NSValue valueWithCATransform3D:CATransform3DRotate(self.layer.transform, rotation, 0.0 ,0.0 ,1.0)];
    
    [self.layer addAnimation:shake forKey:@"shakeAnimation"];
}

- (void) disableEditing {
    [self.layer removeAnimationForKey:@"shakeAnimation"];
    [deleteButton setHidden:YES];
    [_button setEnabled:YES];
    self.isEditing = NO;
}

# pragma mark - Overriding UiView Methods

- (void) removeFromSuperview {
    
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 0.0;
        [self setFrame:CGRectMake(self.frame.origin.x+50, self.frame.origin.y+50, 0, 0)];
        [deleteButton setFrame:CGRectMake(0, 0, 0, 0)];
    }completion:^(BOOL finished) {
        [super removeFromSuperview];
    }]; 
}

@end
