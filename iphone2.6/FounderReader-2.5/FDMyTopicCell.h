//
//  FDMyTopicCell.h
//  FounderReader-2.5
//
//  Created by Julian on 2017/5/5.
//
//

#import <UIKit/UIKit.h>
@class FDMyTopic;

@interface FDMyTopicCell : UITableViewCell

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UIButton *praiseBtn;
@property (strong, nonatomic) UIButton *commentBtn;

- (void)layoutCell:(FDMyTopic *)myTopic IsHeader:(BOOL)isHeader IsFirstRow:(BOOL)IsFirstRow;

@end
