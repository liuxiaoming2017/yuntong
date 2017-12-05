//
//  UITabBarController+Helper.m
//  FounderReader-2.5
//
//  Created by chenfei on 5/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UITabBarController+Helper.h"

@implementation UITabBarController (Helper)

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (self.selectedViewController == self.moreNavigationController)
        return NO;
    
    if ([self.selectedViewController isKindOfClass:[UINavigationController class]]) {
        UIViewController *topViewController = [((UINavigationController *)self.selectedViewController) topViewController];
        return [topViewController shouldAutorotateToInterfaceOrientation:interfaceOrientation];
    }
    
    return [self.selectedViewController shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

@end
