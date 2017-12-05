//
//  UINavigationController+Rotation.m
//  FounderReader-2.5
//
//  Created by ld on 14-6-6.
//
//

#import "UINavigationController+Rotation.h"

@implementation UINavigationController (Rotation)

-(BOOL)shouldAutorotate {

    return [[self.viewControllers lastObject] shouldAutorotate];
}

-(NSUInteger)supportedInterfaceOrientations {
    
    return [[self.viewControllers lastObject] supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
     
     return [[self.viewControllers lastObject] preferredInterfaceOrientationForPresentation];
}


@end
