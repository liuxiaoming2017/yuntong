//
//  SharePlatformWithSingle.h
//  FounderReader-2.5
//
//  Created by Julian on 16/8/1.
//
//

#import <Foundation/Foundation.h>

@interface SharePlatformWithSingle : NSObject

+ (void)sharePlatformWithSingle:(int)platformTag Content:(NSString *)content image:(UIImage *)image title:(NSString *)title url:(NSString *)url;
@end
