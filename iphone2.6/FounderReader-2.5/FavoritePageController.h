//
//  FavoritePageController.h
//  FounderReader-2.5
//
//  Created by chenfei on 4/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ChannelPageController.h"

@interface FavoritePageController : ChannelPageController <UITableViewDataSource, UITableViewDelegate> {
    UITableView *_tableView;
    
    NSArray *articles;
}

@property(nonatomic, retain) NSArray *articles;
@property(nonatomic, retain) UIView *hudView;

@end
