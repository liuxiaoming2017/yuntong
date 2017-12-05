//
//  UIAlertView+Helper.m
//  FounderReader-2.5
//
//  Created by chenfei on 4/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIAlertView+Helper.h"

@implementation UIAlertView (Helper)

+ (void)showAlert:(NSString *)text
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:text message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show]; 
}

@end
