//
//  FDMyTopicImageView.m
//  FounderReader-2.5
//
//  Created by Julian on 2017/5/16.
//
//

#import "FDMyTopicImageView.h"
#import "UIView+Extention.h"
#import "UIImageView+WebCache.h"
#import "SDPhotoBrowser.h"
#import "FDTopicDetailListModel.h"

#define kMarginW 15

@interface FDMyTopicImageView() <SDPhotoBrowserDelegate,UIGestureRecognizerDelegate>
{
    BOOL _isHeader;
    NSInteger _displayedPhotoCount;
    CGSize _imageSize;
}

@property (nonatomic, strong)NSMutableArray *topicImages;

@end

@implementation FDMyTopicImageView

+ (instancetype)TopicImageViewWithFrame:(CGRect)frame ImageArray:(NSArray *)topicImages IsHeader:(BOOL)isHeader ImageSize:(CGSize)imageSize
{
    return [[self alloc] initWithFrame:(CGRect)frame ImageArray:topicImages IsHeader:isHeader ImageSize:imageSize];
}

- (instancetype)initWithFrame:(CGRect)frame ImageArray:(NSArray *)topicImages IsHeader:(BOOL)isHeader ImageSize:(CGSize)imageSize
{
    if (self = [super initWithFrame:frame]) {
        _isHeader = isHeader;
        _imageSize = imageSize;
        for (NSDictionary *imageDict in topicImages) {
            if (imageDict) {
                [self.topicImages addObject:imageDict[@"url"]];
            }
        }
        [self setupUI];
    }
    return self;
}

- (void)setupUI
{
    self.backgroundColor = [UIColor whiteColor];
    self.userInteractionEnabled = YES;
    
    NSInteger count = [self.topicImages count];
    if (count == 0) {
        // 不需占位图
    } else if (count == 1) {
        self.height = !_isHeader ? self.width * 9/16.0f : _imageSize.height;
        _displayedPhotoCount = 1;
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(enlargePhoto:)];
        [imageView addGestureRecognizer:tap];
        imageView.tag = 0;
        imageView.frame = !_isHeader ? self.bounds :CGRectMake(0, (self.height-_imageSize.height)/2.0f, _imageSize.width, _imageSize.height);
        [self addSubview:imageView];
        if (!_isHeader)
            [imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@@!md169", self.topicImages[0]]] placeholderImage:[Global getBgImage169]];
        else
            [imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@@!lg", self.topicImages[0]]] placeholderImage:[Global getBgImage169]];
    } else if (count == 2) {
        if (!_isHeader) {
            for (int i = 0; i < count; i++) {
                _displayedPhotoCount = 2;
                self.height = (self.width-8)/2.0f;
                UIImageView *imageView = [[UIImageView alloc] init];
                imageView.tag = i;
                imageView.userInteractionEnabled = YES;
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(enlargePhoto:)];
                [imageView addGestureRecognizer:tap];
                imageView.frame = CGRectMake((self.height+8) * i, 0, self.height, self.height);
                [self addSubview:imageView];
                [imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@@!md11", self.topicImages[i]]] placeholderImage:[Global getBgImage11]];
            }
        }else {
            [self layoutImagesBySudoku];
        }
    } else {
        if (!_isHeader) {
            _displayedPhotoCount = 3;
            CGFloat unitLength = (self.width-8)/(5.0f+3.0f);
            self.height = unitLength * 4;
            for (int i = 0; i <= 2; i++) {
                UIImageView *imageView = [[UIImageView alloc] init];
                imageView.tag = i;
                imageView.userInteractionEnabled = YES;
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(enlargePhoto:)];
                [imageView addGestureRecognizer:tap];
                if (i == 0) {
                    imageView.frame = CGRectMake(0, 0, unitLength * 5, self.height);
                    [imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@@!md54", self.topicImages[i]]] placeholderImage:[Global getBgImage43]];
                }else {
                    CGFloat imageH2 = unitLength*2-4;
                    imageView.frame = CGRectMake(unitLength * 5 + 8, (imageH2 + 8) * (i - 1), unitLength * 3, imageH2);
                    [imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@@!md32", self.topicImages[i]]] placeholderImage:[Global getBgImage43]];
                }
                [self addSubview:imageView];
            }
        }else {
            [self layoutImagesBySudoku];
        }
    }
}

/** 九宫格形式添加图片 */
- (void)layoutImagesBySudoku {
    
    _displayedPhotoCount = 0;
    CGFloat pic_width = (self.width-8*2)/3.0f;
    CGFloat pic_height = pic_width;
    NSInteger col_count = 3;
    
    for (int i = 0; i < _topicImages.count; i++) {
        //创建图片
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.tag = i;
        imageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(enlargePhoto:)];
        [imageView addGestureRecognizer:tap];
        [imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@@!md11", self.topicImages[i]]] placeholderImage:[Global getBgImage11]];
        
        // 图片所在行
        NSInteger row = i / col_count;
        // 图片所在列
        NSInteger col = i % col_count;
        // 间距
        CGFloat margin = (self.width - (pic_width * col_count)) / (col_count + 1);
        // PointX
        CGFloat picX = margin + (pic_width + margin) * col;
        // PointY
        CGFloat picY = margin + (pic_height + margin) * row;
        
        // 图片的frame
        imageView.frame = CGRectMake(picX, picY, pic_width, pic_height);
        
        [self addSubview:imageView];
    }
}

- (NSMutableArray *)topicImages
{
    if (!_topicImages) {
        _topicImages = [NSMutableArray array];
    }
    return _topicImages;
}

+ (CGFloat)getImageViewsHeight:(NSInteger)picCount Width:(CGFloat)imagesW IsHeader:(BOOL)isHeader
{ 
    CGFloat imagesH = 0;
    if (picCount == 0) {
        imagesH = 0;
    }else if (picCount == 1) {
        imagesH = imagesW * 9/16.0f;
    }else if (picCount == 2) {
        if (!isHeader) {
            imagesH = (imagesW-8)/2.0f;
        } else {
            //九宫格
            float cols = picCount/3.0f;
            if (cols>= 3)
                cols = 3;
            else
                cols = ceilf(cols);
            imagesH = (imagesW-8*2)/3.0f * cols + 8*(cols-1);
        }
    }else {
        if (!isHeader) {
            CGFloat unitLength = (imagesW-8)/(5.0f+3.0f);
            imagesH = unitLength * 4;
        } else {
            //九宫格
            float cols = picCount/3.0f;
            if (cols>= 3)
                cols = 3;
            else
                cols = ceilf(cols);
            imagesH = (imagesW-8*2)/3.0f * cols + 8*(cols-1);
        }
    }
    return imagesH;
}

+ (CGFloat)getImageViewsHeightByOne:(FDTopicDetailListModel *)listModel
{
    float scale = listModel.imagesSizeByOne.width*1.0f/listModel.imagesSizeByOne.height*1.0f;
    CGFloat imageW = 0;
    CGFloat imageH = 0;
    if (scale > 0 && scale < 0.56) {
        imageW = kSHeight/4.0f;
        imageH = imageW * 1.78f;
    }else if (scale >= 0.56 && scale < 1) {
        imageW = kSHeight/4.0f;
        imageH = imageW/scale;
    }else if (scale == 1) {
        imageW = kSHeight/4.0f;
        imageH = imageW;
    }else if (scale > 1 && scale <= 1.78) {
        imageH = kSHeight/4.50f;
        imageW = imageH * scale;
    }else if (scale > 1.78) {
        imageH = kSHeight/4.0f;
        imageW = imageH * 1.78f;
    }
    listModel.imagesSizeByCaculate = CGSizeMake(imageW, imageH);
    return imageH;
}

- (void)enlargePhoto:(UITapGestureRecognizer *)tap
{
    UIImageView *clickImageView = (UIImageView *)tap.view;
    SDPhotoBrowser *browser = [[SDPhotoBrowser alloc] init];
    browser.displayedPhotoCount = _displayedPhotoCount;
    browser.sourceImagesContainerView = self; // 原图的父控件
    browser.imageCount = self.topicImages.count; // 图片总数
    browser.currentImageIndex = clickImageView.tag;
    browser.delegate = self;
    [browser show];
    
}

#pragma mark - 图片浏览组件delegate

// 返回高质量图片的url
- (NSURL *)photoBrowser:(SDPhotoBrowser *)browser highQualityImageURLForIndex:(NSInteger)index
{
    NSString *thpurl = self.topicImages[index];
    NSString *urlStr = [thpurl stringByReplacingOccurrencesOfString:@"thumbnail" withString:@"bmiddle"];
    urlStr = [urlStr stringByAppendingString:@"@!lg"];
    return [NSURL URLWithString:urlStr];
}

// 返回占位图
- (UIImage *)photoBrowser:(SDPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index
{
    return [Global getBgImage169];
}

@end
