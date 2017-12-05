//
//  XHExampleSideDrawerViewController.m
//  XHDrawerController
//
//  Created by 曾 宪华 on 13-12-27.
//  Copyright (c) 2013年 曾宪华 开发团队(http://iyilunba.com ) 本人QQ:543413507. All rights reserved.
//

#import "XHMainViewController.h"
#import "XHDrawerController.h"

@interface XHMainViewController ()

@end

@implementation XHMainViewController


- (void)left {
    [self.drawerController toggleDrawerSide:XHDrawerSideLeft animated:YES completion:NULL];
}

- (void)right {
    [self.drawerController toggleDrawerSide:XHDrawerSideRight animated:YES completion:^(BOOL finished) {
        
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Left", @"") style:UIBarButtonItemStyleBordered target:self action:@selector(left)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Right", @"") style:UIBarButtonItemStyleBordered target:self action:@selector(right)];
}

- (id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
