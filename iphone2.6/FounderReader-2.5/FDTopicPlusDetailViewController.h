//
//  FDTopicPlusDetailViewController.h
//  FounderReader-2.5
//
//  Created by snitsky on 2017/5/4.
//
//

#import <UIKit/UIKit.h>
#import "DetailPageController.h"

@interface FDTopicPlusDetailViewController : DetailPageController

- (instancetype)initWithTopicID:(NSNumber *)topicID viewControllerType:(FDViewControllerType)viewControllerType;

@end
