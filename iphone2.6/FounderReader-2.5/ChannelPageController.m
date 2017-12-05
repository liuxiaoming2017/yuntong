//
//  ChannelPageController.m
//  FounderReader-2.5
//
//  Created by chenfei on 4/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SeeRootViewController.h"
#import "ChannelPageController.h"
#import "Column.h"
#import "UIDevice-Reachability.h"
#import "Article.h"
#import "TemplateDetailPageController.h"
#import "ImageDetailPageController.h"
#import "SpecialNewsPageController.h"
#import "ColumnRequest.h"
#import "UIImage+Helper.h"
#import "UIView+Extention.h"
#import "TemplateNewDetailViewController.h"
#import "ColumnBarConfig.h"
#import "NewsCellUtil.h"
#import "ColorStyleConfig.h"
#import "AppStartInfo.h"

@interface ChannelPageController ()

@end

@implementation ChannelPageController
@synthesize parentColumn, subcolumns;
@synthesize isPDF;
@synthesize moreButton;

- (id)initWithColumn:(Column *)column withIsMain:(int)isMain{
    self = [super init];
    if (self) {
        self.parentColumn = column;
        self.isMain = isMain;
    }
    return self;
}

- (id)initWithColumn:(Column *)column
{
    self = [super init];
    if (self) {
        self.parentColumn = column;
    }
    return self;
}

- (id)initWithColumn:(Column *)column viewControllerType:(FDViewControllerType)viewControllerType
{
    self = [super init];
    if (self) {
        self.parentColumn = column;
        self.viewControllerType = viewControllerType;
    }
    return self;
}

- (void)left {
    return;
}

- (void)right {
    return;
}

// 导航栏右侧第二个按钮响应事件
- (void)right2{
    
}
- (void)moreClick{
    return;
}
- (void)leftAndRightButton
{
    if (self.moreButton) {
        return;
    }
    
    int px = 0;
    if (IS_IPHONE_6P) {
        px = -10;
    }
    else
    {
        px = -6;
    }
   
    if (![AppStartInfo sharedAppStartInfo].ucTabisShow) {
        UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [leftButton setImage:[UIImage imageNamed:@"icon-head"] forState:UIControlStateNormal];
        [leftButton sizeToFit];
        leftButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        
        leftButton.contentEdgeInsets = UIEdgeInsetsMake(0, px, 0, 0);
        
        [leftButton addTarget:self action:@selector(left) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
        self.navigationItem.leftBarButtonItem = leftItem;
    }

    UIView *rightButton = [[UIView alloc] initWithFrame:CGRectMake(0,3,16,16)];
    moreButton = [[UIImageView alloc] initWithFrame:CGRectMake(0, 3, 16, 16)];
    self.moreButton.image = [UIImage imageNamed:@"icon-edit"];
    self.moreButton.contentMode = UIViewContentModeScaleToFill;
    [rightButton addSubview:self.moreButton];
   
    UITapGestureRecognizer *recognizer2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(moreClick)];
    [rightButton addGestureRecognizer:recognizer2];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    [self.navigationController.navigationBar setBackgroundImage:[Global navigationImage] forBarMetrics:UIBarMetricsDefault];
    //去掉NavigationBar底部的那条黑线
    self.navigationController.navigationBar.barStyle = UIBaselineAdjustmentNone;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self leftAndRightButton];
    navTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 140, 43)];
    navTitleLabel.text = @"";
    navTitleLabel.font = [UIFont systemFontOfSize:18];
    navTitleLabel.textAlignment = NSTextAlignmentCenter;
    navTitleLabel.backgroundColor = [UIColor clearColor];
    navTitleLabel.textColor = [ColorStyleConfig sharedColorStyleConfig].navbar_titlecolor_selected;
    self.navigationItem.titleView = navTitleLabel;

    UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(0, self.navigationController.navigationBar.frame.size.height-0.5, kSWidth, 0.5)];
    line.backgroundColor = [UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:1.0];
    [self.navigationController.navigationBar addSubview:line];
    if (self.viewControllerType == FDViewControllerForDetailVC) {
        self.tabBarController.tabBar.hidden = YES;
    }
    NSLog(@"ChannelPageController:%@",NSStringFromCGRect(self.view.frame));
}

- (void)titleLableWithTitle:(NSString *)titleStr
{
    navTitleLabel.text = titleStr;
}

#pragma mark -
#pragma mark initNavigationBar & add navigationItem methods
- (void)rightPageNavTopButtons
{
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftButton setImage:[UIImage imageNamed:@"nav_bar_back"] forState:UIControlStateNormal];
    [leftButton sizeToFit];
    leftButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    leftButton.contentEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
    [leftButton addTarget:self action:@selector(goRightPageBack) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)leftNavBackButton
{
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftButton setImage:[UIImage imageNamed:@"nav_bar_back"] forState:UIControlStateNormal];
    [leftButton sizeToFit];//按钮大小自适应
    /**设置按钮的位置---start---*/
    // 让按钮内部的所有内容左对齐
    leftButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    // 让按钮的内容往左边偏移10，内容可移出按钮边框，还是可以点击
    leftButton.contentEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);//内容相对按钮上左下右
    /*----end----*/
    
    [leftButton addTarget:self action:@selector(goBackPageBack) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)GetBack
{
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = nil;
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(10, 20, 40, 40);
    [backButton setImage:[UIImage imageNamed:@"nav_bar_back"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(goBackPageBack) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    [self.view bringSubviewToFront:backButton];
}

- (void)goBackPageBack
{
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)goRightPageBack
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)showHeaderTopDetailArticle:(Article*)article withColumn:(Column *)column
{
    if (!article) {
        return;
    }
    article.isRead = YES;
    [NewsCellUtil clickNewsCell:article column:column in:self];
}

/**
 *  返回
 */
- (void)goBackIOS6
{
    if (self.navigationController) {
        if (self.presentingViewController)
            [self dismissViewControllerAnimated:YES completion:nil];
        else
            [self.navigationController popViewControllerAnimated:YES];
    } else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)goBackIOS6Button:(UIViewController *)controller
{
    UIImage *leftImage = [UIImage imageNamed:@"Policebacknomal"];
    UIImage *leftImage_hl = [UIImage imageNamed:@"Policebackpress"];
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftButton.frame = CGRectMake(0, 0, leftImage.size.width/2, leftImage.size.height/2);
    [leftButton setBackgroundImage:leftImage forState:UIControlStateNormal];
    [leftButton setBackgroundImage:leftImage_hl forState:UIControlStateHighlighted];
    
    [leftButton addTarget:controller action:@selector(goBackIOS6) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    controller.navigationItem.leftBarButtonItem = leftItem;
    
}
/**
 *  设置底部工具栏返回按钮
 */
- (void)configBottomBackView
{
    UIView *backView = [[UIView alloc]initWithFrame:CGRectMake(0, kSHeight-45, kSWidth, 45)];
    backView.backgroundColor=[UIColor clearColor];
    UILabel *lineLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, -1, kSWidth, 1)];
    lineLabel.backgroundColor = [Global navigationLineColor];;
    [backView addSubview:lineLabel];
    
    UIButton *backButton=[[UIButton alloc]initWithFrame:CGRectMake(10, 3, 40, 40)];
    [backButton setBackgroundImage:[UIImage imageNamed:@"Policebacknomal"] forState:UIControlStateNormal];
    [backButton setBackgroundImage:[UIImage imageNamed:@"Policebackpress"] forState:UIControlStateSelected];
    [backButton addTarget:self action:@selector(goBackIOS6) forControlEvents:UIControlEventTouchUpInside];
    [backView addSubview:backButton];
    [self.view addSubview:backView];
    [self.view bringSubviewToFront:backView];
    
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goBackIOS6)];
    [backView addGestureRecognizer:recognizer];

}

@end
