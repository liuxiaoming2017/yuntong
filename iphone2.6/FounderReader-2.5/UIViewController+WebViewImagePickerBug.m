//
//  UIViewController+WebViewImagePickerBug.m
//  TestModalWebCamera
//
//  Created by snitsky on 2017/4/12.
//  Copyright © 2017年 snitsky. All rights reserved.
//

#import "UIViewController+WebViewImagePickerBug.h"
#import <objc/runtime.h>

@implementation UIViewController (WebViewImagePickerBug)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        SEL originalSelector1 = @selector(presentViewController:animated:completion:);
        SEL swizzledSelector1 = @selector(snit_presentViewController:animated:completion:);
        
        Method originalMethod1 = class_getInstanceMethod(class, originalSelector1);
        Method swizzledMethod1 = class_getInstanceMethod(class, swizzledSelector1);
        
        BOOL didAddMethod1 = class_addMethod(class, originalSelector1, method_getImplementation(swizzledMethod1), method_getTypeEncoding(swizzledMethod1));
        
        if (didAddMethod1) {
            class_replaceMethod(class, swizzledSelector1, method_getImplementation(originalMethod1), method_getTypeEncoding(originalMethod1));
        } else {
            method_exchangeImplementations(originalMethod1, swizzledMethod1);
        }
        
        SEL originalSelector2 = @selector(dismissViewControllerAnimated:completion:);
        SEL swizzledSelector2 = @selector(snit_dismissViewControllerAnimated:completion:);
        
        Method originalMethod2 = class_getInstanceMethod(class, originalSelector2);
        Method swizzledMethod2 = class_getInstanceMethod(class, swizzledSelector2);
        
        BOOL didAddMethod2 = class_addMethod(class, originalSelector2, method_getImplementation(swizzledMethod2), method_getTypeEncoding(swizzledMethod2));
        
        if (didAddMethod2) {
            class_replaceMethod(class, swizzledSelector2, method_getImplementation(originalMethod2), method_getTypeEncoding(originalMethod2));
        } else {
            method_exchangeImplementations(originalMethod2, swizzledMethod2);
        }
    });
}

#pragma mark - Method Swizzling

- (void)snit_presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion {
    if ([viewControllerToPresent isKindOfClass:[UIDocumentMenuViewController class]] && [[(UIDocumentMenuViewController *)viewControllerToPresent delegate] isKindOfClass: NSClassFromString(@"UIWebFileUploadPanel")] && [UIDevice currentDevice].systemVersion.floatValue > 10) {
        objc_setAssociatedObject(self, @"snit_passDismiss", @YES, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    [self snit_presentViewController:viewControllerToPresent animated:flag completion:completion];
}

- (void)snit_dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    BOOL isBugVC = [self.presentedViewController isKindOfClass:[UIDocumentMenuViewController class]] || [self.presentedViewController isKindOfClass:[UIDocumentPickerViewController class]];
    BOOL isSystemBugVC = isBugVC && [[(UIDocumentMenuViewController *)self.presentedViewController delegate] isKindOfClass: NSClassFromString(@"UIWebFileUploadPanel")];
    
    NSNumber *passDismiss = objc_getAssociatedObject(self, @"snit_passDismiss");
    
    if (isSystemBugVC) {
        objc_setAssociatedObject(self, @"snit_passDismiss", @YES, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    } else if (passDismiss.boolValue) {
        objc_setAssociatedObject(self, @"snit_passDismiss", @NO, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        return;
    }
    [self snit_dismissViewControllerAnimated:flag completion:completion];
}

@end
