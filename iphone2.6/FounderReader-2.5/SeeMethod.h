//
//  SeeMethod.h
//  FounderReader-2.5
//
//  Created by lx on 15/8/13.
//
//

#import <Foundation/Foundation.h>

@interface SeeMethod : NSObject


+(CATransition *)animationIn;
+(CATransition *)animationOut;

+(UIButton *)newButtonWithFrame:(CGRect)frame type:(UIButtonType)type title:(NSString *)title target:(id)target UIImage:(NSString *)imagename andAction:(SEL)sel;

+(UIImage *)thumbnailImageRequest:(NSURL *)videoURL atTime:(CGFloat )timeBySecond;
@end
