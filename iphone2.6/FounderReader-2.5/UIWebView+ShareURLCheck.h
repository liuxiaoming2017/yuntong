//
//  UIWebView+ShareURLCheck.h
//  FounderReader-2.5
//
//  Created by snitsky on 2017/3/22.
//
//

#import <UIKit/UIKit.h>

@interface UIWebView (ShareURLCheck)

+ (BOOL)checkShareURLWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType WebView:(UIWebView *)webView;

- (void)giveResultWithWebView:(NSDictionary *)infoDict;

@end
