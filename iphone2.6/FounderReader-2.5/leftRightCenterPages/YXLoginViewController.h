//
//  YXLoginViewController.h
//  FounderReader-2.5
//
//  Created by ld on 14-12-24.
//
//

#import <UIKit/UIKit.h>
#import "ChannelPageController.h"


@class YXLoginViewController;
typedef void (^LoginSuccessBlock)();
typedef void (^LoginFailedBlock)(YXLoginViewController *controller);
@protocol YXLoginViewControllerDelegate <NSObject>
@optional
- (void)loginFinished;
@end
@interface YXLoginViewController : ChannelPageController
//三方外链需要登录时登录后处理
@property (nonatomic, copy) LoginSuccessBlock loginSuccessBlock;
@property (nonatomic, copy) LoginFailedBlock loginFailedBlock;
@property (nonatomic, assign) id<YXLoginViewControllerDelegate > delegate;
@property (nonatomic, assign) BOOL isNavBack;
@property (nonatomic, assign) BOOL isFromBind;
@end
