//
//  PersonalCenterViewController.h
//  FounderReader-2.5
//
//  Created by lx on 15/8/13.
//
//

#import <UIKit/UIKit.h>
#import "ChannelPageController.h"
#import "CDRTranslucentSideBar.h"

@interface PersonalCenterViewController : ChannelPageController<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain)  CDRTranslucentSideBar *sideBar;

- (void)updateUserInfo;

- (void)downLoadMyScore;
@end
