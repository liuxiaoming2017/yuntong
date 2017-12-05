//
//  FDQuestionsAndAnwsersPlusCell.h
//  FounderReader-2.5
//
//  Created by snitsky on 2017/3/9.
//
//

#import <UIKit/UIKit.h>
#import "Article.h"

@interface FDQuestionsAndAnwsersPlusCell : UITableViewCell

@property (strong, nonatomic) UIButton *relationButton;

- (void)updateCellWithArticle:(Article *)article hideBottom:(BOOL)hideBottom;

@end
