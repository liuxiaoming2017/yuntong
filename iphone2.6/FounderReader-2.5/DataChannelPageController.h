
//
//  DataChannelPageController.h
//  FounderReader-2.5
//
//  Created by chenfei on 4/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ChannelPageController.h"
#import "PersonalCenterViewController.h"
#import "CDRTranslucentSideBar.h"

@class Column;
@interface DataChannelPageController : ChannelPageController{
    
    NSMutableArray *columns;
    NSMutableArray *allcolumns;
    NSString *cityCode;
    BOOL isRefresh;
    
    PersonalCenterViewController *leftController;
    CDRTranslucentSideBar *sideBar;
}
@property (nonatomic, retain) NSArray *subColumns;
@property (nonatomic, retain) NSMutableArray *columns;
@property (nonatomic, retain) NSMutableArray *allcolumns;

@property (nonatomic, retain) PersonalCenterViewController *leftController;
@property (nonatomic, retain) CDRTranslucentSideBar *sideBar;

// public:
- (void)loadColumns;
- (void)updateColumns;
// protected:
// virtual
- (void)loadColumnsFinished;
// virtual
- (void)loadColumnsFailed;

@end
