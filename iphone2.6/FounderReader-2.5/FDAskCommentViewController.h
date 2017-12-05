//
//  FDAskCommentViewController.h
//  FounderReader-2.5
//
//  Created by snitsky on 2017/3/14.
//
//

#import <UIKit/UIKit.h>
#import "FDAskModel.h"

typedef void(^HasPraiseBlock)(NSNumber *praiseCount);

@interface FDAskCommentViewController : UIViewController

@property (strong, nonatomic) HasPraiseBlock hasPraiseBlock;

- (instancetype)initWithAskModel:(FDAskModel *)model;

@end
