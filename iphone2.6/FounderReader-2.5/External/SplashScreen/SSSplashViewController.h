//
//  SSSplashViewController.h
//  SplashScreen
//
//  Created by chenfei on 4/22/13.
//  Copyright (c) 2013 chenfei. All rights reserved.
//

#import <UIKit/UIKit.h>
#ifndef IS_IPHONE
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_6P (IS_IPHONE && [[UIScreen mainScreen] bounds].size.width == 414.0f)
#define IS_IPHONE_6 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.width == 375.0f)
#define IS_IPHONE_5 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0f)
#define IS_IPHONE_4 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 480.0f)
#endif

@class SSSplashViewController;
@class SSPageCF;
@protocol SSSplashViewControllerDelegate <NSObject>

- (void)splashDidfinished:(SSSplashViewController *)splashController;
- (void)showStartPageDetailPage:(SSSplashViewController *)splashController;
@end
@interface SSSplashViewController : UIViewController
@property(nonatomic, retain) NSArray *startPages;
@property(nonatomic, retain) NSMutableArray *pages;
@property(nonatomic, retain) NSString *pagesUrlString;
@property(nonatomic, retain) UIButton *skipButton;
@property(nonatomic, assign) id<SSSplashViewControllerDelegate> delegate;
@property(nonatomic, assign) int pid;
@property(nonatomic, retain) NSString *webUrl;
@property(nonatomic, retain) NSString *titleText;
@property(nonatomic, retain) NSString *startTime;

@end
