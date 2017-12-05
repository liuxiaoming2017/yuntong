//
//  TemplateNewDetailViewController.h
//  FounderReader-2.5
//  Created by wxq on 12-5-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Article.h"
#import <MessageUI/MessageUI.h>

#import "NewsDetailPageController.h"
@interface TemplateNewDetailViewController : NewsDetailPageController<MFMailComposeViewControllerDelegate,UIActionSheetDelegate,UIWebViewDelegate>{
    Article *_adArticle;
    BOOL _imageFlag;     //判断是图片广告还是网页广告
    NSString *columnUrl;
    UIButton *imageview1;
    UIButton *imageview2;
    
    UIButton *btnClose;
    int jumpUrlCount;
}
@property(nonatomic, retain) UIWebView *webView;
@property(nonatomic, retain) NSString *columnUrl;
@property(nonatomic, assign) BOOL imageFlag;
@property(nonatomic, assign) int isMore; //判断源头是从哪里跳转的（左侧还是左侧的更多）

@end