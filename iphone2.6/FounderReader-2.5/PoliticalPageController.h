//
//  NJSquarePageController.h
//  FounderReader-2.5
//
//  Created by lihuiguo on 15/8/31.
//
//
#import "DataChannelPageController.h"
@interface PoliticalPageController : DataChannelPageController <UITableViewDataSource, UITableViewDelegate>
{
    UITableView *tableView;
    NSMutableArray *bottomColumns;
}

@property (nonatomic, retain) Column *column;
@property (nonatomic, retain) UIView *topView;
@property (nonatomic, assign) BOOL isFromLocalPolitical;
@property (nonatomic, assign) BOOL isFromColumnBar;

-(void)refreshSquareData;

@end
