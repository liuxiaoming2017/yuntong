//
//  SummaryView.h
//  FounderReader-2.5
//
//  Created by chenfei on 5/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Label.h"

@interface SummaryView : UIImageView {
    Label *titleLabel;
    UILabel *sumTitleLabel;
    UITextView *summaryLabel;
}

@property(nonatomic, retain) Label *titleLabel;
@property(nonatomic, retain) UITextView *summaryLabel;
@property(nonatomic, retain) UILabel *sumTitleLabel;

@end
