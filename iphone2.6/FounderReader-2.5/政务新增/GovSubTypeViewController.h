//
//  GovSubTypeViewController.h
//  FounderReader-2.5
//
//  Created by 黄柳姣 on 2017/12/4.
//

#import <UIKit/UIKit.h>
#import "ColumnBarPageController.h"

@interface GovSubTypeViewController : ColumnBarPageController
@property(nonatomic,strong) UITableView *tableView;
- (id)initWithDataArr:(NSArray *)arr withDic:(NSDictionary *)dic withSelected:(BOOL)selected;
@end
