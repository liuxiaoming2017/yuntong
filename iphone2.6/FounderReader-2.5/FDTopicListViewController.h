//
//  FDTopicListViewController.h
//  FounderReader-2.5
//
//  Created by Julian on 2017/4/25.
//
//

#import "ChannelPageController.h"
#import "Column.h"

@interface FDTopicListViewController : ChannelPageController

- (instancetype)initWithColumn:(Column *)column viewControllerType:(FDViewControllerType)viewControllerType;

@end
