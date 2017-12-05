//
//  NewsPageController.h
//  FounderReader-2.5
//
//  Created by chenfei on 4/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ColumnBarPageController.h"
#import "CityPageController.h"

@interface LocalPageController : ColumnBarPageController <UIAlertViewDelegate, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate,LocationPageDelegate>{
    CGRect nfImageFrame;
}
@property (nonatomic, retain) NSString  *columnName;
@property (nonatomic, assign) int  columnId;

@end
