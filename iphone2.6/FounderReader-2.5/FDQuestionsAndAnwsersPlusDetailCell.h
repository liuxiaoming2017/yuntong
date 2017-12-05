//
//  RemarksTableViewCell.h
//  FlowerReceiveDemo
//
//  Created by Eyes on 16/2/19.
//  Copyright © 2016年 DuanGuoLi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FDAskModel;

typedef void (^EventBlock)(NSDictionary *dic);

@interface FDQuestionsAndAnwsersPlusDetailCell : UITableViewCell

@property (strong, nonatomic) UIButton *answerPraiseBtn;

@property (strong, nonatomic)FDAskModel *askModel;

- (void)layoutCellUI:(FDAskModel *)askModel ShowStatus:(struct ItemShowStatus)itemShowStatus IndexPath:(NSIndexPath *)indexPath EventBlock:(EventBlock)eventBlock;

- (void)updatePraiseCount:(NSString *)praiseCount;

@end
