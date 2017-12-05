//
//  TemplateDetailPageController.h
//  FounderReader-2.5
//
//  Created by chenfei on 5/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NewsDetailPageController.h"
#import "Column.h"

@interface TemplateDetailPageController : NewsDetailPageController <UIWebViewDelegate,UIGestureRecognizerDelegate,UIScrollViewDelegate> {
    UIWebView *webView;
    
}
@property(nonatomic, retain) NSMutableArray *imageArray;
@property(nonatomic, retain) UIWebView *webView;
@property(nonatomic, assign) BOOL isKuaidian;
@property(nonatomic, assign) BOOL isFirstUrl;
@property(nonatomic, assign) NSInteger firstClick;
@property(nonatomic, retain) UIView *fontHudView;

@property(nonatomic,copy) NSString *contentStr;

-(void)loadArticleContent:(Article *)article;
@end
