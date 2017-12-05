//
//  AdNewDetailViewController.h
//  FounderReader-2.5
/*
        网页链接页面
 */
//  Created by wxq on 12-5-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "Article.h"
#import <MessageUI/MessageUI.h>

#import "NewsDetailPageController.h"
@interface AdNewDetailViewController : UIViewController<MFMailComposeViewControllerDelegate,UIActionSheetDelegate>{
    Article *_adArticle;
    BOOL _imageFlag;     //判断是图片广告还是网页广告
    //UIWebView *_webView;
    NSString *columnUrl;
    UIButton *imageview1;
    UIButton *imageview2;
    UIWebView *webView;
    UIButton *btnClose;
    int jumpUrlCount;
    
}

@property(nonatomic,retain) Column *column;
@property (nonatomic, retain) NSString *columnUrl;
@property (nonatomic, retain) Article *adArticle;
@property (nonatomic, assign) BOOL imageFlag;
@property (nonatomic, assign) int isMore; //判断源头是从哪里跳转的（左侧还是左侧的更多）

@end
