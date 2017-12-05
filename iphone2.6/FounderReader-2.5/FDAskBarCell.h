//
//  FDAskBarCell.h
//  FounderReader-2.5
//
//  Created by Julian on 2017/3/30.
//
//

#import <UIKit/UIKit.h>
#import "Article.h"

@interface FDAskBarCell : UITableViewCell

- (void)updateCellWithArticle:(Article *)article;

@end
