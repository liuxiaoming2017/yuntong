//
//  SeeMethod.m
//  FounderReader-2.5
//
//  Created by lx on 15/8/13.
//
//

#import "SeeMethod.h"
#import <AVFoundation/AVFoundation.h>
#import "Global.h"
#define SCREEN_WIDTH self.view.bounds.size.width
#define SCREEN_HEIGHT self.view.bounds.size.height
@implementation SeeMethod

+(UIButton *)newButtonWithFrame:(CGRect)frame type:(UIButtonType)type title:(NSString *)title target:(id)target UIImage:(NSString *)imagename andAction:(SEL)sel
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame=frame;
    button.titleLabel.font  = [UIFont fontWithName:[Global fontName] size:17];
    [button setImage:[UIImage imageNamed:imagename] forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
   
    [button addTarget:target action:sel forControlEvents:UIControlEventTouchUpInside];
    return button;

    
}

//动态效果
+(CATransition *)animationIn
{
    CATransition *animation=[CATransition animation];
    [animation setType:@"moveIn"];
    [animation setSubtype:kCATransitionFromBottom];
    animation.duration=0.5f;
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    return animation;
}

+(CATransition *)animationOut
{
    CATransition *animation=[CATransition animation];
    [animation setType:@"reveal"];
    [animation setSubtype:kCATransitionFromTop];
    animation.duration=0.2f;
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    return animation;
}


//获取视频的缩略图
+(UIImage *)thumbnailImageRequest:(NSURL *)videoURL atTime:(CGFloat )timeBySecond{
    //创建URL
    //    NSURL *url=[self getNetworkUrl];
    //根据url创建AVURLAsset
    AVURLAsset *urlAsset=[AVURLAsset assetWithURL:videoURL];
    //根据AVURLAsset创建AVAssetImageGenerator
    AVAssetImageGenerator *imageGenerator=[AVAssetImageGenerator assetImageGeneratorWithAsset:urlAsset];
    /*截图
     * requestTime:缩略图创建时间
     * actualTime:缩略图实际生成的时间
     */
    NSError *error=nil;
    CMTime time=CMTimeMakeWithSeconds(timeBySecond, 1);//CMTime是表示电影时间信息的结构体，第一个参数表示是视频第几秒，第二个参数表示每秒帧数.(如果要活的某一秒的第几帧可以使用CMTimeMake方法)
    CMTime actualTime;
    CGImageRef cgImage= [imageGenerator copyCGImageAtTime:time actualTime:&actualTime error:&error];
    if(error){
        NSLog(@"截取视频缩略图时发生错误，错误信息：%@",error.localizedDescription);
        
    }
    CMTimeShow(actualTime);
    //视频缩略图获得的图片
    UIImage *thumbnail=[UIImage imageWithCGImage:cgImage];//转化为UIImage
    CGImageRelease(cgImage);
    //保存到相册
    //    UIImageWriteToSavedPhotosAlbum(_thumbnail,nil, nil, nil);
    //    CGImageRelease(cgImage);
    return thumbnail;
    //内存检测 
    
}
@end
