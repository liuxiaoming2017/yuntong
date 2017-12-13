//
//  GovSubscribeController.h
//  FounderReader-2.5
//
//  Created by 黄柳姣 on 2017/12/1.
//

#import <UIKit/UIKit.h>
#import "ChannelPageController.h"

@interface GovSubscribeController : UIViewController
@property (nonatomic,strong) NSMutableArray *mySubscribeArr;
- (id)initWithMySubscribeArr:(NSMutableArray *)arr;
@end
