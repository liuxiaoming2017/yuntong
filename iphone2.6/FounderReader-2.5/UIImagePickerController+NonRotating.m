//
//  UIImagePickerController+NonRotating.m
//  FounderReader-2.5
//
//  Created by ld on 14-9-23.
//
//

#import "UIImagePickerController+NonRotating.h"

@implementation UIImagePickerController (NonRotating)

- (BOOL)shouldAutorotate
{
    return NO;
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

@end
