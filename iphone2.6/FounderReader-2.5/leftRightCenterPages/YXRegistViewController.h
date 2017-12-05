//
//  YXRegistViewController.h
//  FounderReader-2.5
//
//  Created by ld on 14-12-25.
//
//

#import <UIKit/UIKit.h>
#import "ChannelPageController.h"
#import "UserBasicViewController.h"
#import "FDAreaPickerModel.h"
@class YXRegistViewController;
typedef void (^RegistSuccessBlock)(YXRegistViewController *controller, NSString *phoneNumber, NSString *password, FDAreaPickerModel *areaModel);

@interface YXRegistViewController : UserBasicViewController<UITextFieldDelegate>

@property (nonatomic, assign) BOOL isForgetPassWord;
@property (nonatomic, retain) NSString *phoneNum;
@property (nonatomic, copy) RegistSuccessBlock registerSuccessBlock;
@end
