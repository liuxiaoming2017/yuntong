//
//  ShareSdkPackage.h
//  FounderReader-2.5
//
//  Created by lx on 15/8/15.
//
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>
#import <ShareSDK/ShareSDK.h>
#import "ShareViewDelegate.h"

@interface myContainer<ISSContainer>

@end

@interface ShareSdkPackage : NSObject
{
    ShareViewDelegate *_shareViewDelegate;
    UIView *shareView;
}

@property(nonatomic, retain) NSString *newsImageUrl;
@property(nonatomic, retain) NSString *newsTitle;
@property(nonatomic, retain) NSString *newsLink;
@property(nonatomic, retain) NSString *newsAbstract;

- (void)shareSdk;
- (void)shareSdk1;
+ (ShareSdkPackage *)shareSdkPackage;
@end
