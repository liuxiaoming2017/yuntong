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

@interface YXResetViewController : UserBasicViewController<UITextFieldDelegate>

@property (nonatomic, assign) BOOL isForgetPassWord;
@property (nonatomic, retain) NSString *phoneNum;
@end
