//
//  FMNewTableView.h
//  FounderReader-2.5
//
//  Created by 郭 莉慧 on 14-3-1.
//
//

#import <UIKit/UIKit.h>

@interface FMArticlesListTableView : UITableView
{
    NSUInteger index;
    NSDate *lastupdatetime;
}
@property (assign) NSUInteger index;
@property (retain) NSDate *lastupdatetime;

@end
