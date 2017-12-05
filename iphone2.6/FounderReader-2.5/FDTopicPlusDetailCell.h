//
//  FDTopicPlusDetailCell.h
//  FounderReader-2.5
//
//  Created by snitsky on 2017/5/5.
//
//

#import <UIKit/UIKit.h>
@class FDTopicDetailListModel;

@interface FDTopicPlusDetailCell : UITableViewCell

@property (strong, nonatomic) UIButton *praiseBtn;

@property (strong, nonatomic) NSNumber *discussID;

- (void)layoutCell:(FDTopicDetailListModel *)topicModel IsHeader:(BOOL)isHeader;

- (void)updatePraiseCount:(NSString *)praiseCount;

@end
