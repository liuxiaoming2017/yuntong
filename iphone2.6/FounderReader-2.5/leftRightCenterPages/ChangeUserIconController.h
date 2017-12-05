//
//  ChangeUserIconController.h
//  FounderReader-2.5
//
//  Created by ld on 14-12-30.
//
//

#import <UIKit/UIKit.h>
#import "ChannelPageController.h"
#import "PECropViewController.h"

@interface ChangeUserIconController : ChannelPageController
@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) UIPopoverController *popover;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *editButton;
@end
