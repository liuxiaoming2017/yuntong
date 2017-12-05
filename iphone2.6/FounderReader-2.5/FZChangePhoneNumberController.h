//
//  FZChangePhoneNumberController.h
//  FounderReader-2.5
//
//  Created by mac on 2017/6/26.
//
//

#import <UIKit/UIKit.h>
@class ChangeUserInfoController;
@interface FZChangePhoneNumberController : UIViewController
@property (nonatomic,copy) void (^bindSuccessCallBack)(NSString *);
@property (nonatomic,copy) void (^cancleBindCallBack)();
@property (nonatomic,assign) BOOL isPush;
@property (nonatomic,assign) BOOL isFromeLogin;
@end
