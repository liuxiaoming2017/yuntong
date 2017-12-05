//
//  FDMyTopicImageView.h
//  FounderReader-2.5
//
//  Created by Julian on 2017/5/16.
//
//

#import <UIKit/UIKit.h>
@class FDTopicDetailListModel;

@interface FDMyTopicImageView : UIView

+ (instancetype)TopicImageViewWithFrame:(CGRect)frame ImageArray:(NSArray *)topicImages IsHeader:(BOOL)isHeader ImageSize:(CGSize)imageSize;

+ (CGFloat)getImageViewsHeight:(NSInteger) picCount Width:(CGFloat)imagesW IsHeader:(BOOL)isHeader;

+ (CGFloat)getImageViewsHeightByOne:(FDTopicDetailListModel *)listModel;

@end
