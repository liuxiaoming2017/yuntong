//
//  ArrayPageController.h
//  FounderReader-2.5
//
//  Created by chenfei on 5/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ATArrayView.h"

@protocol ArrayPageControllerDelegate <NSObject>

- (void)cellDidSelectedAtIndex:(int)index;

@end

@interface ArrayPageController : UIViewController <ATArrayViewDelegate> {
    ATArrayView *arrayView;
    
    NSArray *pictures;
    
    id<ArrayPageControllerDelegate> delegate;
}

@property(nonatomic, retain) NSArray *pictures;
@property(nonatomic, retain) id<ArrayPageControllerDelegate> delegate;

@property(nonatomic, assign) int columnId;

@end
