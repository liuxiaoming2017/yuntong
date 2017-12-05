//
//  FDTopicContentDetailViewController.h
//  FounderReader-2.5
//
//  Created by julian on 2017/6/28.
//
//

#import <UIKit/UIKit.h>

#import "FDTopicPlusDetaiHeaderlModel.h"

typedef void(^HasPraiseBlock)(NSNumber *praiseCount);
typedef void(^HasCommentBlock)();

@interface FDTopicContentDetailViewController : UIViewController

@property (strong, nonatomic) FDTopicPlusDetaiHeaderlModel *detailModel;

@property (strong, nonatomic) HasPraiseBlock hasPraiseBlock;

@property (strong, nonatomic) HasCommentBlock hasCommentBlock;

- (instancetype)initWithDiscussID:(NSNumber *)discussID IsFromTopicDetailColumn:(BOOL)isFromTopicDetailColumn;

@end
