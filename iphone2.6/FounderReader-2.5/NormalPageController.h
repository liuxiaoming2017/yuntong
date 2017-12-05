//
//  NewsPageController.h
//  FounderReader-2.5
//
//  Created by chenfei on 4/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ColumnBarPageController.h"

@interface NormalPageController : ColumnBarPageController <UIAlertViewDelegate, UITableViewDelegate, UITableViewDataSource,UIGestureRecognizerDelegate>{
    CGRect nfImageFrame;
}
@property (nonatomic, retain) NSString  *columnName;
@property (nonatomic, assign) int  columnId;


@end
