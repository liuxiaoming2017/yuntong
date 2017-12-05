//
//  RootWebPageController.h
//  FounderReader-2.5
//
//  Created by sa on 15-7-31.
//
//
#import "ChannelPageController.h"

#import "ColumnBar.h"
#import "ColumnBarConfig.h"
#import "CDRTranslucentSideBar.h"
#import "PersonalCenterViewController.h"

@interface RootWebPageController : ChannelPageController <UIWebViewDelegate> {
    UIWebView *webView;
    PersonalCenterViewController *leftController;
    CDRTranslucentSideBar *sideBar;
}

@property(nonatomic,retain)  PersonalCenterViewController *leftController;
@property (nonatomic, retain) CDRTranslucentSideBar *sideBar;
@property(nonatomic, assign) NSInteger firstClick;
-(void)showLoginPage;
-(void)showActivityIndicatorView;
@end
