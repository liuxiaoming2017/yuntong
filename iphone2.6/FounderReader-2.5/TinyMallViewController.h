//
//  TinyMallViewController.h
//  FounderReader-2.5
//
//  Created by Julian on 2016/11/7.
//
//

#import <UIKit/UIKit.h>
#import "ChannelPageController.h"

@interface TinyMallViewController : ChannelPageController

@property (assign, nonatomic) BOOL needLogin;//访问微商城是否需要先登录再准浏览
@property (assign, nonatomic) BOOL isFromLeftMenu;//是否来自侧边栏
@property (copy, nonatomic) NSString *mallTitle;//微商城名

@end
