//
//  AdPageController.h
//  FounderReader-2.5
//  Created by wxq on 12-5-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//  链接栏目页面

#import <UIKit/UIKit.h>
#import "ChannelPageController.h"
#import "Article.h"
#import "Column.h"

@interface AdPageController : ChannelPageController<UIWebViewDelegate>{
    UIButton *imageview1;
    UIButton *imageview2;
    
    UIButton *btnClose;
    int jumpUrlCount;
}
@property(nonatomic, retain) UIWebView *webView;
@property(nonatomic, retain) NSString *columnUrl;
@property(nonatomic, retain) NSString *columnName;
@property(nonatomic, retain) Column *adColumn;
@property(nonatomic, retain) Article *adArticle;
@property(nonatomic, assign) BOOL imageFlag;  //判断是图片广告还是网页广告
@property(nonatomic, assign) int isMore; //判断源头是从哪里跳转的（左侧还是左侧的更多）
@property(nonatomic, assign) NSInteger firstClick;
@property(nonatomic, assign) NSInteger onceClick;

@end
