//
//  FDQuestionsAndAnwsersPlusDetailTopHeaderView.h
//  FounderReader-2.5
//
//  Created by Julian on 2017/3/23.
//
//

#import <UIKit/UIKit.h>
@class FDQuestionsAndAnwsersPlusDetailModel;

typedef void (^HeaderMoreBlock)();

@interface FDQuestionsAndAnwsersPlusDetailHeaderView : UIView

@property (nonatomic, strong)FDQuestionsAndAnwsersPlusDetailModel *detailModel;
@property (nonatomic, copy)HeaderMoreBlock headerMoreBlock;

@end
