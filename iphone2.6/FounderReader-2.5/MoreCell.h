//
//  MoreCell.h
//  FounderReader-2.5
//
//  Created by chenfei on 4/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TableViewCell.h"

@interface MoreCell : TableViewCell

@property(nonatomic, retain) UIActivityIndicatorView *indicator;

@property(nonatomic,retain) UIView *footSeq;
- (void)showIndicator;
- (void)hideIndicator;

@end
