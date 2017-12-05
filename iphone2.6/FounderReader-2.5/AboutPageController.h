//
//  AboutPageController.h
//  FounderReader-2.5
//
//  Created by chenfei on 4/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ChannelPageController.h"

@interface AboutPageController : ChannelPageController {
    UIWebView *webView;
}

@property(nonatomic,assign) BOOL isDismissBack;
@end
