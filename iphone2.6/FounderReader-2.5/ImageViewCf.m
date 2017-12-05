//
//  ImageView.m
//  FounderReader-2.5
//
//  Created by chenfei on 4/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import "UIImageView+WebCache.h"
#import "ImageViewCf.h"
#import "FileRequest.h"
//#import "Global.h"
#import "NSString+Helper.h"

@implementation ImageViewCf

@synthesize defaultImage;
@synthesize sync;
@synthesize imageUrlStr;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        bUseDefaultImage = true;
    }
    return self;
}

- (void)setDefaultImage:(UIImage *)image
{
    defaultImage = image;
    self.image = defaultImage;
}

- (void)setUrlString:(NSString *)url placeholderImage:(NSString *)imageName
{
    
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    [self sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:imageName]];
}

- (void)setUrlString:(NSString *)url
{
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [self sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:defaultImage];
}

- (void)setOriginalUrlString:(NSString *)url
{
    self.imageUrlStr = url;
    if (isFileExists(cachePathFromURL(url))) {
        @try{
            self.image = [UIImage imageWithContentsOfFile:cachePathFromURL(url)];
            if (self.image.size.width == 0) {
                self.image = defaultImage;
            }
        }
        @catch(NSException *exception) {
            XYLog(@"exception:%@", exception);
            self.image = defaultImage;
        }
        @finally {
            
        }
    }
    else{
        //2g/3g不下图
        if ([Global isWanNetWorking] && [Global isWANswitch] && bUseDefaultImage == true)//true
        {
            self.image = defaultImage;
            return;
        }
        else{
            [self loadImageFile];
        }
    }
}

-(void)loadImageFile
{
    if([self.imageUrlStr hasPrefix:@"http"] == NO){
        self.image = defaultImage;
        return;
    }
    FileRequest *request = [FileRequest fileRequestWithURL:self.imageUrlStr];
    [request setCompletionBlock:^(NSData *data) {
        UIImage *image = [UIImage imageWithData:data];
        if (image)
            self.image = image;
        else
            self.image = defaultImage;
    }];
    
    [request setFailedBlock:^(NSError *error) {
        XYLog(@"load thumbnail failed: %@", error);
        self.image = defaultImage;
    }];
    
    if (sync)
        [request startSynchronous];
    else
        [request startAsynchronous];
}

-(void)loadImageWithOutCache
{
    //微博登录头像不更新
    FileRequest *request = [FileRequest fileRequestWithURL:self.imageUrlStr];
    request.ifCache = NO;
    [request setCompletionBlock:^(NSData *data) {
        UIImage *image = [UIImage imageWithData:data];
        if (image)
            self.image = image;
        else
            self.image = defaultImage;
    }];
    
    [request setFailedBlock:^(NSError *error) {
        XYLog(@"load thumbnail failed: %@", error);
        self.image = defaultImage;
    }];
    
    if (sync)
        [request startSynchronous];
    else
        [request startAsynchronous];
}

-(void)showAlterView
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                    message:NSLocalizedString(@"您已经设置3G/4G不下载图片与视频，可以在设置中关闭此选项。",nil)
                                                   delegate:self
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"确定",nil];
    [alert show]; 
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
}

- (void)setLoadDefaultImage:(BOOL)bDefault{
    
    bUseDefaultImage = bDefault;
}
@end
