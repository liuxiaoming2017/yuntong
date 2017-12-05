//
//  FDTopicPlusDetailHeader.h
//  FounderReader-2.5
//
//  Created by snitsky on 2017/5/5.
//
//

#import <UIKit/UIKit.h>
#import "FDTopicPlusDetaiHeaderlModel.h"

#define FDTopicPlusDetailHeaderHeight kSWidth/16*9

@interface FDTopicPlusDetailHeader : UIView

@property (strong, nonatomic) UILabel *navTitleLabel;
@property (strong, nonatomic) UIButton *followButton;

- (void)updateUIWithModel:(FDTopicPlusDetaiHeaderlModel *)model;

@end
