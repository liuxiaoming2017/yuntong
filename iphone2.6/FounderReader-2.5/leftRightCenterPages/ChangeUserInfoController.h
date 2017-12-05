//
//  ChangeUserInfoController.h
//  FounderReader-2.5
//
//  Created by ld on 14-12-29.
//
//

#import "ChannelPageController.h"

typedef void(^ChangeUserInfoSuccessBlock)();
@interface ChangeUserInfoController : UITableViewController<UIPickerViewDelegate>{
    BOOL isThirdLogin;
}

@property (nonatomic, copy)ChangeUserInfoSuccessBlock changeUserInfoSuccessBlock;
@property(nonatomic,assign) bool *isMenu;
@property(nonatomic,retain) NSArray *columnValue;
@property(nonatomic,retain) UIView *sexView;
@property(nonatomic,retain) NSDictionary *dicInfo;
@property (nonatomic,assign) BOOL isFromeLogin;

@end
