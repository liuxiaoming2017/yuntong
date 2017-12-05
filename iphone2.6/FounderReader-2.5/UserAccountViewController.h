//
//  UserAccountViewController.h
//  AppSetting
//
//  Created by guo.lh on 13-7-23.
//  Copyright (c) 2013年 Beijing Founder Electronics Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChannelPageController.h"


@protocol UserAccountViewDelegate <NSObject>
@optional
- (void) gotoPage:(UINavigationController *)navController;
@end

@interface UserAccountViewController : ChannelPageController<UITableViewDataSource,
                                                            UITableViewDelegate,
                                                            UITextFieldDelegate,UIWebViewDelegate>
{
    UIWebView *webView;
    id<UserAccountViewDelegate>  _accountDelegate;
    UINavigationController *_fartherNavigation;
    BOOL GetInformFinished;
}

@property(nonatomic, retain) id<UserAccountViewDelegate>  accountDelegate;
@property(nonatomic, retain) UINavigationController*  fartherNavigation;
@end
