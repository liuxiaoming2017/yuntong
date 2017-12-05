//
//  NewsCellUtil.h
//  FounderReader-2.5
//
//  Created by mac on 16/8/2.
//
//

#import <Foundation/Foundation.h>
#import "Article.h"
#import "TableViewCell.h"

@interface NewsCellUtil : NSObject

+(CGFloat)getNewsCellHeight:(Article *)article;
+(TableViewCell *)getNewsCell:(Article *)article in:(UITableView *)tableView;
+(void)clickNewsCell:(Article *)currentAricle column:(Column *)column in:(UIViewController *)viewController;
@end
