//
//  AboutPageController.m
//  FounderReader-2.5
//
//  Created by chenfei on 4/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AboutPageController.h"

@interface AboutPageController ()

@end

@implementation AboutPageController
@synthesize isDismissBack;

- (void)loadView
{
    webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, kSWidth, kSHeight)];
    webView.mediaPlaybackRequiresUserAction = NO;
    webView.scalesPageToFit = YES;
    self.view = webView;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    NSURL *url = [NSURL URLWithString:self.parentColumn.linkUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [webView loadRequest:request];
    [self rightPageNavTopButtons];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self titleLableWithTitle:self.parentColumn.columnName];
}

-(void)goRightPageBack
{
    if (self.isDismissBack) {
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}
@end
