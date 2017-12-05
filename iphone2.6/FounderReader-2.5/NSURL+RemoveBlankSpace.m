//
//  NSURL+RemoveBlankSpace.m
//  FounderReader-2.5
//
//  Created by snitsky on 2016/11/29.
//
//

#import "NSURL+RemoveBlankSpace.h"
#import <objc/runtime.h>

@implementation NSURL (RemoveBlankSpace)

+ (void)load {
    Method URLWithStringMethod = class_getClassMethod(self, @selector(URLWithString:));
    Method fd_URLWithStringMethod = class_getClassMethod(self, @selector(fd_URLWithString:));
    method_exchangeImplementations(URLWithStringMethod, fd_URLWithStringMethod);
}

#pragma mark - Method Swizzling

+ (instancetype)fd_URLWithString:(NSString *)URLString {
    NSString *filterString = [URLString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([filterString hasPrefix:@"http://"] && [filterString containsString:@"newaircloud.com"] && ![filterString containsString:@"oss2"]) {
        NSMutableString *urlString = filterString.mutableCopy;
        //[urlString insertString:@"s" atIndex:4];
        filterString = urlString;
    }
    return [NSURL fd_URLWithString:filterString];
}

@end
