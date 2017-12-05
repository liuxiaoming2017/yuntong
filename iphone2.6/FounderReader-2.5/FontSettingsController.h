//
//  FontSettingsController.h
//  FounderReader-2.5
//
//  Created by chenfei on 5/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FontSettingsController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    UITableView *_talbeView;
}

@property (nonatomic, assign) BOOL isSetupVoice;

@end
