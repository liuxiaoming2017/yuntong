//
//  FDTopicListCell.h
//  FounderReader-2.5
//
//  Created by Julian on 2017/4/27.
//
//

#import <UIKit/UIKit.h>
#import "Article.h"

@interface FDTopicListCell : UITableViewCell

@property (strong, nonatomic) UIButton *attentionBtn;
@property (assign, nonatomic) BOOL isFromMyTopic;
@property (assign, nonatomic) BOOL isFirstRow;

- (void)setTopicArticle:(Article *)topicArticle IsFirstRow:(BOOL)isFirstRow;

@end
