//
//  Columns.h
//  FounderReader-2.5
//
//  Created by chenfei on 4/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Columns : NSObject {
    int version;
    NSArray *columns;
}

@property(nonatomic, assign) int version;
@property(nonatomic, retain) NSArray *columns;

@end
