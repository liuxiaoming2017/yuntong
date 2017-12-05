//
//  NewsPageController.h
//  FounderReader-2.5
//
//  Created by chenfei on 4/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ColumnBarPageController.h"
#import "ColumnScrollView.h"


@interface LifePageController : ColumnBarPageController <UIAlertViewDelegate, ColumnScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>{
    CGRect nfImageFrame;
    ColumnScrollView *_columnScrollView;
}
@property (nonatomic, retain) ColumnScrollView *columnScrollView;
@property (nonatomic, retain) NSString  *columnName;
@property (nonatomic, assign) int  columnId;
@property(nonatomic,retain) HeaderNewsWidget *headerView;
@end
