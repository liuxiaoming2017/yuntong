//
//  SetupPageController.h
//  FounderReader-2.5
//
//  Created by chenfei on 4/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ChannelPageController.h"

@interface SetupPageController : ChannelPageController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate,UIAlertViewDelegate> {
    
    UITableView *tableView;
    NSMutableArray *_shareTypeArray;
    UILabel *shareLabel;
    NSString *inviteCode;
}
@property(nonatomic,retain) UILabel *cacheSizeLabel;
//- (void)offline;
@end
