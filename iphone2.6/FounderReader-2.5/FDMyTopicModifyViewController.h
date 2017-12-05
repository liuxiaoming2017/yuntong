//
//  FDMyTopicModifyViewController.h
//  FounderReader-2.5
//
//  Created by julian on 2017/6/29.
//
//

#import <UIKit/UIKit.h>
#import "FDMyTopic.h"
#import "FDTopicPlusDetaiHeaderlModel.h"

typedef void (^SuccessAddDiscussBlock)(void);

@interface FDMyTopicModifyViewController : UIViewController

@property(nonatomic, copy)SuccessAddDiscussBlock successAddDiscussBlock;

- (instancetype)initWithMyTopic:(FDMyTopic *)myTopic DetailModel:(FDTopicPlusDetaiHeaderlModel *)detailModel;

@end
