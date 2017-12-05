//
//  NJSquarePageController.h
//  FounderReader-2.5
//
//  Created by lihuiguo on 15/8/31.
//
//

#import "DataChannelPageController.h"

@interface NJSquarePageController : DataChannelPageController <UITableViewDataSource, UITableViewDelegate>
{
    UITableView *tableView;
    NSMutableArray *bottomColumns;
}

@property (nonatomic, retain) Column *column;
-(void)refreshSquareData;

@end
