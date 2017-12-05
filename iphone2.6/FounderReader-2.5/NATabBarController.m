//
//  NATableViewController.m
//  FounderReader-2.5
//
//  Created by mac on 2017/6/22.
//
//

#import "NATabBarController.h"
@interface NATabBarController ()
@property (nonatomic,assign) BOOL canCotate;
@end

@implementation NATabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    //self.tabBar.frame.size.height = 83;
    //self.tabBar.frame = CGRectMake(self.tabBar.frame.origin.x, self.tabBar.frame.origin.y, self.tabBar.frame.size.width, 83);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(screenRotates:) name:@"KScreenRotates" object:nil];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    CGRect tabBarFrame = self.tabBar.frame;
    tabBarFrame.size.height = kTabBarHeight;
    //NSLog(@"height:%d",kTabBarHeight);
    self.tabBar.frame = tabBarFrame;
}

-(void)screenRotates:(NSNotification *)noti{
    NSDictionary * dic = noti.userInfo;
    NSString * rotate = dic[@"canRotate"];
    if ([rotate isEqualToString:@"YES"] ) {
        self.canCotate = YES;
    }else{
        self.canCotate = NO;
    }
    [self shouldAutorotate];
    [self supportedInterfaceOrientations];
    [self preferredInterfaceOrientationForPresentation];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (BOOL)shouldAutorotate {
    //确定你的控制器是否能够旋转（手动控制，或者自动旋转都要Return YES）
    return self.canCotate;
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_9_0
- (NSUInteger)supportedInterfaceOrientations {
#else
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
#endif
        //返回你的屏幕支持的方向
    if (self.canCotate) {
        return UIInterfaceOrientationMaskPortrait|UIInterfaceOrientationMaskLandscapeLeft|UIInterfaceOrientationMaskLandscapeRight;
    }else{
        return UIInterfaceOrientationMaskPortrait;
    }
    }
    
-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
        //你跳转（present）到这个新控制器时，按照什么方向初始化控制器
    if (self.canCotate) {
        return UIInterfaceOrientationLandscapeLeft| UIInterfaceOrientationLandscapeRight |UIInterfaceOrientationMaskPortrait|UIInterfaceOrientationPortraitUpsideDown;
    }else{
        
        return UIInterfaceOrientationPortrait;
    }
    }
@end
