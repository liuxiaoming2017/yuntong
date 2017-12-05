//
//  SummaryView.m
//  FounderReader-2.5
//
//  Created by chenfei on 5/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SummaryView.h"
#import <QuartzCore/QuartzCore.h>

@implementation SummaryView

@synthesize titleLabel, summaryLabel,sumTitleLabel;



- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.userInteractionEnabled = YES;
        UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        bgImageView.image = [UIImage imageNamed:@"summary_background"];
        [self addSubview:bgImageView];
        
        summaryLabel = [[UITextView alloc] init];
        summaryLabel.frame = CGRectMake(4, 20, frame.size.width-4, 110);
        summaryLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        summaryLabel.font = [UIFont fontWithName:[Global fontName] size:(12/320.0)*kSWidth];
        summaryLabel.textColor = [UIColor whiteColor];
        summaryLabel.scrollEnabled = YES;
        
        summaryLabel.userInteractionEnabled = YES;
        summaryLabel.backgroundColor = [UIColor clearColor];
        //        summaryLabel.edgeInsets = UIEdgeInsetsMake(6.5, 9.5, 8, 9.5);
        [self addSubview:summaryLabel];
     
        titleLabel = [[Label alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 20)];
        titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        //        titleLabel.font = [UIFont fontWithName:[Global fontName] size:(12.5/320.0)*kSWidth];
        //小标题加粗加大
        titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:14];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.edgeInsets = UIEdgeInsetsMake(0, 9.5, 0, 9.5);
        titleLabel.backgroundColor = [UIColor clearColor];
        [summaryLabel addSubview:titleLabel];
        
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
