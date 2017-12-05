//
//  UIWebView+ShareURLCheck.m
//  FounderReader-2.5
//
//  Created by snitsky on 2017/3/22.
//
//

#import "UIWebView+ShareURLCheck.h"
#import "shareCustomView.h"
#import "UserAccountDefine.h"
#import "AppConfig.h"

@implementation UIWebView (ShareURLCheck)

+ (BOOL)checkShareURLWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType WebView:(UIWebView *)webView {
    NSURL *url = [request URL];
    NSString *urlString = [url absoluteString];
    if ([urlString containsString:@"xkyapp://appShare"]) {
        
        NSRange range = [urlString rangeOfString:@"?"];
        if (range.location == NSNotFound) {
            return NO;
        }
        NSString *paramsString = [urlString substringFromIndex:range.location + 1];
        NSArray *paramsArray = [paramsString componentsSeparatedByString:@"&"];
        NSString *xky_ti;
        NSString *xky_des;
        id xky_img;
        NSString *xky_url;
        NSString *xky_type;
        for (NSString *string in paramsArray) {
            if ([string hasPrefix:@"xky_ti"]) {
                xky_ti = [[string substringFromIndex:7] stringByRemovingPercentEncoding];
            } else if ([string hasPrefix:@"xky_des"]) {
                xky_des = [[string substringFromIndex:8] stringByRemovingPercentEncoding];
            } else if ([string hasPrefix:@"xky_img"]) {
                xky_img = [[string substringFromIndex:8] stringByRemovingPercentEncoding];
            } else if ([string hasPrefix:@"xky_url"]) {
                xky_url = [[string substringFromIndex:8] stringByRemovingPercentEncoding];
            } else if ([string hasPrefix:@"xky_type"]) {
                xky_type = [string substringFromIndex:9];
            }
        }
        if (!xky_type.length) {
            return NO;
        }
        if (![(NSString *)xky_img length]) {
            xky_img = [Global getAppIcon];
        }
        [shareCustomView shareWithContentInWeb:xky_type.intValue Content:xky_des image:xky_img  title:xky_ti url:xky_url completion:^(NSString *resultJson){
            [webView performSelectorOnMainThread:@selector(giveResultWithWebView:) withObject:@{@"webView":webView, @"resultJson":resultJson} waitUntilDone:NO];
        }];
        return NO;
    }
    return YES;
}

- (void)giveResultWithWebView:(NSDictionary *)infoDict
{
    UIWebView *webView = (UIWebView *)[infoDict objectForKey:@"webView"];
    NSString *resultJson = [infoDict objectForKey:@"resultJson"];
    NSString *jsMethod = [NSString stringWithFormat:@"xkyShareNotify('%@');",resultJson];
    [webView stringByEvaluatingJavaScriptFromString:jsMethod];
}

@end
