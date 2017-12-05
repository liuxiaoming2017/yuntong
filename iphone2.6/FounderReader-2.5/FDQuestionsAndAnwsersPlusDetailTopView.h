//
//  FDQuestionsAndAnwsersPlusDetailTopView.h
//  FounderReader-2.5
//
//  Created by Julian on 2017/3/15.
//
//

#import <UIKit/UIKit.h>

typedef void (^AttentionBlock)(UIButton *btn);

@class FDQuestionsAndAnwsersPlusDetailModel;

@interface FDQuestionsAndAnwsersPlusDetailTopView : UIView

@property (nonatomic, strong) UILabel *titleLable;
@property (nonatomic, strong) UIButton *attentionBtn;
@property (nonatomic, strong)FDQuestionsAndAnwsersPlusDetailModel *detailModel;

@property (nonatomic, copy)AttentionBlock attentionBlock;

@end
