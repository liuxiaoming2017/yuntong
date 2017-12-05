//
//  AppDelegate.h
//  FounderReader-2.5
//
//  Created by chenfei on 4/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSSplashViewController.h"
//#import "GeTuiSdk.h"
#import "Global.h"


#import "NATabBarController.h"



@class StoreViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate, SSSplashViewControllerDelegate, UITabBarControllerDelegate>
{    
    NSMutableArray *channels;
    UIAlertView *errorAlertView;
}

@property (strong, nonatomic) UIWindow *window;
@property (retain, nonatomic) NSMutableArray *channels;
@property (retain, nonatomic) NATabBarController *tabBarController;
@property (assign, nonatomic) BOOL isAllOrientation;
@property (assign, nonatomic) int FirstStart;
@property (assign, nonatomic) int FirstOnceStart;
@property (assign, nonatomic) int FirstBackStart;

- (UIViewController *)currentViewController;

- (void)loadFasterStart;

- (void)loadHTMLTemplate:(FinishDataBlock)finishedBlock;
- (void)addHelperPage:(NSString *)viewName;
- (void)lazyLoadTask;
@end
