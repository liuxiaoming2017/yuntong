//
//  SideBarViewController.m
//  SwipeToTransferDemo
//
//  Created by lijiangang on 13-4-18.
//  Copyright (c) 2013年 lijiangang. All rights reserved.
//

#import "SideBarViewController.h"
#import "LeftViewController.h"
#import "RightViewController.h"
#import <QuartzCore/QuartzCore.h>

#import "UserAccountDefine.h"
@interface SideBarViewController ()<SiderBarDelegate>
@property (retain,nonatomic)LeftViewController *leftSideBarViewController;
@property (retain,nonatomic)RightViewController *rightSideBarViewController;

@end

@implementation SideBarViewController
{
    UIViewController  *currentMainController;
    UITapGestureRecognizer *tapGestureRecognizer;
    UIPanGestureRecognizer *panGestureReconginzer;
    BOOL sideBarShowing;
    CGFloat currentTranslate;
}
static  SideBarViewController *rootViewCon;
const int ContentOffset=230;
const int ContentMinOffset=60;
const float MoveAnimationDuration = 0.2;

@synthesize contentView = _contentView;
@synthesize navBackView = _navBackView;
@synthesize leftSideBarViewController = _leftSideBarViewController;
@synthesize rightSideBarViewController = _rightSideBarViewController;


-(void)dealloc
{
    self.contentView = nil;
    self.navBackView = nil;
    self.leftSideBarViewController = nil;
    self.rightSideBarViewController = nil;
    
    [super dealloc];
}

+ (id)share
{
    return rootViewCon;
}


-(void)leftAndRightButton
{
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *leftImage = [UIImage imageNamed:@"left-3pages"];
    [leftButton setBackgroundImage:leftImage forState:UIControlStateNormal];
    leftButton.frame = CGRectMake(0, 0, leftImage.size.width/2, leftImage.size.height/2);
    [leftButton addTarget:self action:@selector(goHome) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = leftItem;
    [leftItem release];
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    NSString *photoUrl = [[NSUserDefaults standardUserDefaults] objectForKey:KuserAccountFace];
    UIImage *rightImage = [UIImage imageNamed:@"right-3pages"];
    
    if (photoUrl.length)
    {
        rightImage = [UIImage imageWithContentsOfFile:cachePathFromURL(photoUrl)];
        
        CGSize size = CGSizeMake(25, 25);
        //CGSize masksize = CGSizeMake(98.5, 60);
        //UIImage *maskImage = [UIImage imageNamed:@"userPhoto_mask"];
        /*UIGraphicsBeginImageContext(size);
         // Draw rightImage
         [rightImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
         // Draw maskImage
         //[maskImage drawInRect:CGRectMake(0, 0, masksize.width, masksize.height)];
         rightImage = UIGraphicsGetImageFromCurrentImageContext();
         UIGraphicsEndImageContext();*/
        
        UIGraphicsBeginImageContext(size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetLineWidth(context, 2);
        CGContextSetStrokeColorWithColor(context, [UIColor clearColor].CGColor);
        CGRect rect = CGRectMake(0, 0, size.width, size.height);
        CGContextAddEllipseInRect(context, rect);
        CGContextClip(context);
        
        [rightImage drawInRect:rect];
        CGContextAddEllipseInRect(context, rect);
        CGContextStrokePath(context);
        rightImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    [rightButton setBackgroundImage:rightImage forState:UIControlStateNormal];
    rightButton.frame = CGRectMake(0, 0, rightImage.size.width/2, rightImage.size.height/2);
    [rightButton addTarget:self action:@selector(goHome) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightItem;
    [rightItem release];
}

-(void)goHome
{
    return;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if (rootViewCon) {
        rootViewCon = nil;
    }
    sideBarShowing = NO;
    currentTranslate = 0;
    _contentView = [[UIView alloc]initWithFrame:self.view.bounds];
    _contentView.layer.shadowOffset = CGSizeMake(0, 0);
    _contentView.layer.shadowColor = [UIColor blackColor].CGColor;
    _contentView.layer.shadowOpacity = 1;
    
    LeftViewController *left=[[LeftViewController alloc]init];
    left.delegate = self;
    _leftSideBarViewController = left;
    RightViewController *right = [[RightViewController alloc]init];
    _rightSideBarViewController =right;
  //  [self addChildViewController:_leftSideBarViewController];
    [self addChildViewController:_rightSideBarViewController];
    _navBackView = [[UIView alloc]initWithFrame:self.view.bounds];
    self.navBackView.backgroundColor = [UIColor clearColor];
    [_navBackView addSubview:_leftSideBarViewController.view];
    [_navBackView addSubview:_rightSideBarViewController.view];
    [self.view addSubview:self.navBackView];
    panGestureReconginzer  = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panInContentView:)];
    [self.contentView addGestureRecognizer:panGestureReconginzer];
    [self.view addSubview:self.contentView];
    
    [self leftAndRightButton];
}
- (void)showSideBarControllerWithDirection:(SideBarShowDirection)direction
{
    
    if (direction!=SideBarShowDirectionNone) {
        UIView *view ;
        if (direction == SideBarShowDirectionLeft)
        {
            view = self.leftSideBarViewController.view;
        }else
        {
            view = self.rightSideBarViewController.view;
        }
        [self.navBackView bringSubviewToFront:view];
    }
    [self moveAnimationWithDirection:direction duration:MoveAnimationDuration];
}


- (void)leftSideBarSelectWithController:(UIViewController *)controller
{
    if ([controller isKindOfClass:[UINavigationController class]]) {
        [(UINavigationController *)controller setDelegate:self];
    }
    if (currentMainController == nil) {
		controller.view.frame = self.contentView.bounds;
		currentMainController = controller;
		[self addChildViewController:currentMainController];
		[self.contentView addSubview:currentMainController.view];
        //guo
        currentMainController.view.userInteractionEnabled = NO;
      
		[currentMainController didMoveToParentViewController:self];
	} else if (currentMainController != controller && controller !=nil) {
		controller.view.frame = self.contentView.bounds;
		[currentMainController willMoveToParentViewController:nil];
		[self addChildViewController:controller];
		self.view.userInteractionEnabled = NO;
		[self transitionFromViewController:currentMainController
						  toViewController:controller
								  duration:0
								   options:UIViewAnimationOptionTransitionNone
								animations:^{}
								completion:^(BOOL finished){
									self.view.userInteractionEnabled = YES;
									[currentMainController removeFromParentViewController];
									[controller didMoveToParentViewController:self];
									currentMainController = controller;
								}
         ];
	}
    
    [self showSideBarControllerWithDirection:SideBarShowDirectionNone];
}
- (void)rightSideBarSelectWithController:(UIViewController *)controller
{
    
}
//guo
-(void)panInColumnsToRight
{
    NSInteger currentIndex = [[NSUserDefaults standardUserDefaults] integerForKey:kCurrentColumnIndex];
    if (currentIndex == 0){
        currentMainController.view.userInteractionEnabled = YES;
        return;
    }
    else
        currentMainController.view.userInteractionEnabled = NO;
}

-(void)panInColumnsToLeft
{
    NSInteger count = [[NSUserDefaults standardUserDefaults] integerForKey:kCurrentColumnCount];
    NSInteger currentIndex = [[NSUserDefaults standardUserDefaults] integerForKey:kCurrentColumnIndex];
    if (currentIndex == count-1){
        currentMainController.view.userInteractionEnabled = YES;
        return;
    }
    else
        currentMainController.view.userInteractionEnabled = NO;
}
//guo

- (void)panInContentView:(UIPanGestureRecognizer *)abc
{
	if (abc.state == UIGestureRecognizerStateChanged)
    {
        CGFloat translation = [abc translationInView:self.contentView].x;
        self.contentView.transform = CGAffineTransformMakeTranslation(translation+currentTranslate, 0);
        UIView *view ;
        if (translation+currentTranslate>0)
        {
            [self panInColumnsToRight];
            view = self.leftSideBarViewController.view;
        }else
        {
            [self panInColumnsToLeft];
            view = self.rightSideBarViewController.view;
        }
        currentMainController.view.userInteractionEnabled = YES;
        [self.navBackView bringSubviewToFront:view];
        
	} else if (panGestureReconginzer.state == UIGestureRecognizerStateEnded)
    {
		currentTranslate = self.contentView.transform.tx;
        if (!sideBarShowing) {
            if (fabs(currentTranslate)<ContentMinOffset) {
                [self moveAnimationWithDirection:SideBarShowDirectionNone duration:MoveAnimationDuration];
            }else if(currentTranslate>ContentMinOffset){
                
                [self moveAnimationWithDirection:SideBarShowDirectionLeft duration:MoveAnimationDuration];
            }else{
                
                [self moveAnimationWithDirection:SideBarShowDirectionRight duration:MoveAnimationDuration];
            }
        }else
        {
            if (fabs(currentTranslate)<ContentOffset-ContentMinOffset) {
                [self moveAnimationWithDirection:SideBarShowDirectionNone duration:MoveAnimationDuration];
                
            }else if(currentTranslate>ContentOffset-ContentMinOffset){
                
                [self moveAnimationWithDirection:SideBarShowDirectionLeft duration:MoveAnimationDuration];
                
            }else{
                
                [self moveAnimationWithDirection:SideBarShowDirectionRight duration:MoveAnimationDuration];
            }
        }
	}
}
- (void)moveAnimationWithDirection:(SideBarShowDirection)direction duration:(float)duration
{
    void (^animations)(void) = ^{
		switch (direction) {
            case SideBarShowDirectionNone:
            {
                self.contentView.transform  = CGAffineTransformMakeTranslation(0, 0);
            }
                break;
            case SideBarShowDirectionLeft:
            {
                self.contentView.transform  = CGAffineTransformMakeTranslation(ContentOffset, 0);
            }
                break;
            case SideBarShowDirectionRight:
            {
                self.contentView.transform  = CGAffineTransformMakeTranslation(-ContentOffset, 0);
            }
                break;
            default:
                break;
        }
	};
    void (^complete)(BOOL) = ^(BOOL finished) {
        self.contentView.userInteractionEnabled = YES;
        self.navBackView.userInteractionEnabled = YES;
        
        if (direction == SideBarShowDirectionNone) {
            
            if (tapGestureRecognizer) {
                [self.contentView removeGestureRecognizer:tapGestureRecognizer];
                tapGestureRecognizer = nil;
            }
            sideBarShowing = NO;
            
            
        }else
        {
            [self contentViewAddTapGestures];
            sideBarShowing = YES;
        }
        currentTranslate = self.contentView.transform.tx;
	};
    self.contentView.userInteractionEnabled = NO;
    self.navBackView.userInteractionEnabled = NO;
    [UIView animateWithDuration:duration animations:animations completion:complete];
}
- (void)contentViewAddTapGestures
{
    if (tapGestureRecognizer) {
        [self.contentView   removeGestureRecognizer:tapGestureRecognizer];
        tapGestureRecognizer = nil;
    }
    
    tapGestureRecognizer = [[UITapGestureRecognizer  alloc] initWithTarget:self action:@selector(tapOnContentView:)];
    [self.contentView addGestureRecognizer:tapGestureRecognizer];
}
- (void)tapOnContentView:(UITapGestureRecognizer *)tapGestureRecognizer
{
    [self moveAnimationWithDirection:SideBarShowDirectionNone duration:MoveAnimationDuration];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
