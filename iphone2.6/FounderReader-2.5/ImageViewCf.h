//
//  ImageView.h
//  FounderReader-2.5
//
//  Created by chenfei on 4/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FLAnimatedImageView;

@interface ImageViewCf : UIImageView {
    UIImage *defaultImage;
    BOOL sync;
    BOOL bUseDefaultImage;
}

@property(nonatomic, retain) NSString *imageUrlStr;
@property(nonatomic, retain) UIImage *defaultImage;
@property(nonatomic, assign) BOOL sync;

- (void)setUrlString:(NSString *)url;
- (void)setOriginalUrlString:(NSString *)url;
- (void)setLoadDefaultImage:(BOOL)bDefault;
-(void)loadImageFile;
-(void)loadImageWithOutCache;

- (void)setUrlString:(NSString *)url placeholderImage:(NSString *)imageName;
@end
