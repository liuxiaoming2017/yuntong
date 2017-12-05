//
//  ColumnButton.h
//  FounderReader-2.5
//
//  Created by chenfei on 4/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageViewCf.h"

@interface ColumnButton : UIButton {
    ImageViewCf *thumbnail;
    UILabel   *nameLabel;
    NSInteger       index;
}

@property(nonatomic, retain) ImageViewCf *thumbnail;
@property(nonatomic, retain) UILabel   *nameLabel;
@property(nonatomic, assign) NSInteger       index;

@property(nonatomic, assign) NSInteger       columnBtnId;
@property(nonatomic, retain) NSString  *columnName;

@end
