//
//  shareCustomView.h
//  FounderReader-2.5
//
//  Created by 袁野 on 15/9/14.
//
//

#import <UIKit/UIKit.h>
#import <UShareUI/UShareUI.h>

@interface shareCustomView : NSObject
{
    UIView *_shareView;
}
@property (nonatomic,assign)UIView *shareView;
//自定义分享界面
+(void)shareWithContent:(NSString *)content image:(id)image title:(NSString *)title url:(NSString *)url type:(int)type completion:(FinishBlock)finishBlock;
+ (void)shareWithContentInWeb:(int)platformTag Content:(NSString *)content image:(id)image title:(NSString *)title url:(NSString *)url completion:(FinishBlock)finishBlock;
+(void)shareContentWithShareType:(UMSocialPlatformType)shareType;
@end
