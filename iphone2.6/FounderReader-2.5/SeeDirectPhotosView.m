//
//  SeeDirectPhotosView.m
//  FounderReader-2.5
//
//  Created by 周志扬 on 15/9/6.
//
//

#import "SeeDirectPhotosView.h"
#import "UIButton+WebCache.h"
#import "UIView+Extention.h"
#import "attactmentmodel.h"
#define HWStatusPhotoWH 67
#define HWStatusPhotoMargin 5
#define SeeDiectPhotoMaxCol(count) ((count==4)?2:3)
@implementation SeeDirectPhotosView
@synthesize photos,imageView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // 清除图片缓存，便于测试
//        [[SDWebImageManager sharedManager].imageCache clearDisk];
    }
    return self;
}
-(void)setPhotos:(NSArray *)photo
{
    
    photos = photo;
    
    
    [photo enumerateObjectsUsingBlock:^(attactmentmodel *obj, NSUInteger idx, BOOL *stop) {
        UIButton *btn = [[UIButton alloc] init];
//        attactmentmodel *ph = [[attactmentmodel alloc]init];
//        ph = obj;
        NSDictionary *dict = [obj valueForKey:@"thumbnail_pic"];
        NSString *url = [NSString stringWithFormat:@"%@.0",[dict objectForKey:@"url"]];
//        NSString *url = [dict objectForKey:@"url"];
        [btn sd_setImageWithURL:[NSURL URLWithString:url] forState:UIControlStateNormal];
        
        btn.tag = idx;
        
        [btn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
    }];
    
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // 设置图片的尺寸和位置
    int photosCount = (int)self.photos.count;
    int maxCol = SeeDiectPhotoMaxCol(photosCount);
    for (int i = 0; i<photosCount; i++) {
        UIView *photoView = self.subviews[i];
        
        int col = i % maxCol;
        photoView.x = col * (HWStatusPhotoWH + HWStatusPhotoMargin);
        
        int row = i / maxCol;
        photoView.y = row * (HWStatusPhotoWH + HWStatusPhotoMargin);
        photoView.width = HWStatusPhotoWH;
        photoView.height = HWStatusPhotoWH;
    }
}
+ (CGSize)sizeWithCount:(int)count
{
    // 最大列数（一行最多有多少列）
    int maxCols = SeeDiectPhotoMaxCol(count);
    
    int cols = (count >= maxCols)? maxCols : count;
    CGFloat photosW = cols * HWStatusPhotoWH + (cols - 1) * HWStatusPhotoMargin;
    
    // 行数
    int rows = (count + maxCols - 1) / maxCols;
    CGFloat photosH = rows * HWStatusPhotoWH + (rows - 1) * HWStatusPhotoMargin;
    
    return CGSizeMake(photosW, photosH);
}
- (void)seeTopImageClick:(UIGestureRecognizer *)ges
{
}
- (void)buttonClick:(UIButton *)button
{
    SDPhotoBrowser *browser = [[SDPhotoBrowser alloc] init];
    browser.sourceImagesContainerView = self; // 原图的父控件
    browser.imageCount = self.photos.count; // 图片总数
    browser.currentImageIndex = button.tag;
    browser.delegate = self;
    [browser show];
    
}

- (void)viewImageClick
{
    SDPhotoBrowser *browser = [[SDPhotoBrowser alloc] init];
    browser.sourceImagesContainerView = self; // 原图的父控件
    browser.imageCount = self.photos.count; // 图片总数
    browser.currentImageIndex = 0;
    browser.delegate = self;
    [browser show];
    
}

- (UIImage *)photoBrowser:(SDPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index
{
    return [self.subviews[index] currentImage];
}


// 返回高质量图片的url
- (NSURL *)photoBrowser:(SDPhotoBrowser *)browser highQualityImageURLForIndex:(NSInteger)index
{
    NSDictionary *dict= self.photos[index];
    
    NSString *thpurl = [NSString stringWithFormat:@"%@.2",[dict valueForKey:@"url"]];
//    NSString *thpurl = [dict valueForKey:@"url"];
    NSString *urlStr = [thpurl stringByReplacingOccurrencesOfString:@"thumbnail" withString:@"bmiddle"];
    return [NSURL URLWithString:urlStr];
}

@end
