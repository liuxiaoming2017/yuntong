//
//  SeeLivePhotosView.m
//  FounderReader-2.5
//
//  Created by 周志扬 on 15/9/8.
//
//

#import "SeeLivePhotosView.h"
#import "UIView+Extention.h"
#import "attactmentmodel.h"
#import "UIButton+WebCache.h"
//#define HWStatusPhotoWH 94.1*kScale
#define HWStatusPhotoMargin 5
//#define HWStatusPhotoAllW 
#define SeeDiectPhotoMaxCol(count) ((count==4)?2:3)

@interface SeeLivePhotosView ()
@property (nonatomic, assign) CGFloat summWidth;
@end

@implementation SeeLivePhotosView
@synthesize photosViewArr;
//-(void)dealloc
//{
//    [super dealloc];
//}

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // 单张图片的宽度,也是多图框架的宽度
        self.summWidth = (liveCellContentW - 13*liveProportion*2);
    }
    return self;
}
-(void)setPhotosViewArr:(NSArray *)photos
{
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    photosViewArr = photos;
    __block CGFloat imgHeight;
    [photos enumerateObjectsUsingBlock:^(NSArray *obj, NSUInteger idx, BOOL *stop) {
        UIButton *btn = [[UIButton alloc] init];
        if (photos.count == 1) {
            btn.imageView.contentMode = UIViewAutoresizingNone;
        } else {
            btn.imageView.contentMode = UIViewContentModeScaleAspectFill;
        }

        NSString *url = [NSString stringWithFormat:@"%@",obj];
        [btn sd_setImageWithURL:[NSURL URLWithString:url] forState:UIControlStateNormal placeholderImage:[Global getBgImage169] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {

        }];

        btn.tag = idx;
        [btn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        IMGHeight = imgHeight;
        [self addSubview:btn]; 
    }];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // 设置图片的尺寸和位置
//    int photosCount = self.photosViewArr.count;
    
//    int maxCol = SeeDiectPhotoMaxCol(photosCount);
    int maxCol = 3;
    
    
    [self.subviews enumerateObjectsUsingBlock:^(UIButton *btn, NSUInteger idx, BOOL *stop) {
        //一个
        if (self.photosViewArr.count == 1) {
            btn.frame = CGRectMake(0, 0, self.summWidth, self.summWidth*9/16.0);
//            btn.imageView.contentMode = UIViewContentModeCenter;
            btn.imageView.contentMode = UIViewContentModeScaleAspectFill;
            
        }else if (self.photosViewArr.count == 2)
        {
            long row = idx / maxCol;
            int col = idx % maxCol;
            CGFloat x = col * ((self.summWidth-5)/2 + HWStatusPhotoMargin);
            CGFloat y = row * ((self.summWidth-5)/2 + HWStatusPhotoMargin);
            btn.frame = CGRectMake(x, y, (self.summWidth-5)/2,(self.summWidth-5)/2*3/4.0);
        }
        else
        {
            long row = idx / maxCol;
            int col = idx % maxCol;
            // 在这里就是标准9宫格, 所以直接把图片的宽计算出来
            CGFloat everyPhotosW = (self.summWidth - 2*HWStatusPhotoMargin)/3;;
            CGFloat x = col * (everyPhotosW + HWStatusPhotoMargin);
            CGFloat y = row * (everyPhotosW + HWStatusPhotoMargin);
            btn.frame = CGRectMake(x, y, everyPhotosW, everyPhotosW);
        
        }
    }];
}

+ (CGSize)sizeViewWithCount:(int)count andSummaryWidth:(CGFloat)summaryWidth
{
    
    /* 一张用16:9;两张用4:3;其余用1:1 */
    if (count == 1) {
        
        return CGSizeMake(summaryWidth,summaryWidth*9/16);
    }else if (count == 2) {
        return CGSizeMake(summaryWidth,(summaryWidth-HWStatusPhotoMargin)/2*3/4.0);
    }
    // 最大列数（一行最多有多少列）
//    int maxCols = SeeDiectPhotoMaxCol(count);
    
    int maxCols = 3;
    
    int cols = (count >= maxCols)? maxCols : count;
    CGFloat everyPhotosW = (summaryWidth - (cols - 1)*HWStatusPhotoMargin)/cols;
    CGFloat photosW = cols * everyPhotosW + (cols - 1) * HWStatusPhotoMargin;
    
    // 行数
    int rows = (count + maxCols - 1) / maxCols;
    CGFloat photosH = rows * everyPhotosW + (rows - 1) * HWStatusPhotoMargin;
    
    return CGSizeMake(photosW, photosH);
}

- (void)ForumImageClick:(UIGestureRecognizer *)ges
{
    XYLog(@"你才是怪人图片点击");
}
- (void)buttonClick:(UIButton *)button
{
    SDPhotoBrowser *browser = [[SDPhotoBrowser alloc] init];
    browser.sourceImagesContainerView = self; // 原图的父控件
    browser.imageCount = self.photosViewArr.count; // 图片总数
    browser.currentImageIndex = button.tag;
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
//    NSDictionary *dict= self.photosViewArr[index];
//    NSString *thpurl = [NSString stringWithFormat:@"%@.2",[dict valueForKey:@"url"]];
//    NSString *thpurl = [dict valueForKey:@"url"];
    NSString *thpurl = self.photosViewArr[index];
    NSString *urlStr = [thpurl stringByReplacingOccurrencesOfString:@"thumbnail" withString:@"bmiddle"];
    return [NSURL URLWithString:urlStr];
}

@end
