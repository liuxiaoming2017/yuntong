//
//  AVDTableViewCell.m
//  FounderReader-2.5
//
//  Created by 周志扬 on 15/8/28.
//  推广Cell样式

#import "ADadvnadageViewCell.h"
#import "NewsListConfig.h"
#import "NSString+Helper.h"
#import "ColumnBarConfig.h"
#import "FLAnimatedImage.h"
#import "UIImageView+WebCache.h"
@implementation ADadvnadageViewCell
@synthesize typeLabel,commentLabel;

//广告页面的cell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.backgroundColor = [NewsListConfig sharedListConfig].cellBackgroundColor;
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 12, self.bounds.size.width - 20, 25)];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.font = [UIFont fontWithName:[Global fontName] size:[NewsListConfig sharedListConfig].middleCellTitleFontSize];
        titleLabel.numberOfLines = 0;
        titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        titleLabel.textColor = [NewsListConfig sharedListConfig].middleActiveCellTitleTextColor;
        titleLabel.text = @"";
        [self.contentView addSubview: titleLabel];
        
        commentLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.size.width-75, 12, 60, 30)];
        self.commentLabel.font = [UIFont systemFontOfSize:9];
        self.commentLabel.textColor = [UIColor lightGrayColor];
        self.commentLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:self.commentLabel];
        self.commentLabel.hidden = YES;
        thumbnail = [[FLAnimatedImageView alloc] initWithFrame:CGRectMake(10, 40, kSWidth-20, (kSWidth-20)/3.0)];
        thumbnail.contentMode =UIViewContentModeScaleAspectFill;//不变形居中示，会有部分裁剪
        thumbnail.layer.masksToBounds = YES;
        [self.contentView addSubview: thumbnail];

        flagLabel = [[UILabel alloc]initWithFrame:CGRectMake(kSWidth-50 , titleLabel.center.y - 10, 40, 20)];
        flagLabel.text = NSLocalizedString(@"推广", nil);
        flagLabel.font = [UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleCellTitleFontSize-2];
        flagLabel.backgroundColor = [UIColor clearColor];
        flagLabel.textColor = [ColumnBarConfig sharedColumnBarConfig].column_all_color;
        flagLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:flagLabel];
        
        self.footSeq = [[UIView alloc] init];
        self.footSeq.frame = CGRectMake(0, [NewsListConfig sharedListConfig].middleCellHeight +10 +40*proportion - 1 + 19, kSWidth, 0.5);
        self.footSeq.backgroundColor = UIColorFromString(@"221,221,221");
        [self addSubview:self.footSeq];
    }
    return self;
}

-(void)configImageCellWithArticle:(Article *)artice
{
    //网络请求的图片 列表广告图@!md31
    if (![NSString isNilOrEmpty:artice.imageUrl]){
        if (artice.sizeScale == ArticleSizeScale_1_2)
        {
            self.footSeq.frame = CGRectMake(0, (kSWidth-20)/2 + 40+10-1, kSWidth, 0.5);
            thumbnail.frame = CGRectMake(10, 40, kSWidth-20, (kSWidth-20)/2);
            thumbnail.image = [Global getBgImage21];
        }
        else if (artice.sizeScale == ArticleSizeScale_1_1)
        {
            self.footSeq.frame = CGRectMake(0, (kSWidth-20)/3 + 40+10-1, kSWidth, 0.5);
            thumbnail.frame = CGRectMake(10, 40, kSWidth-20, (kSWidth-20)/3);
            thumbnail.image = [Global getBgImage11];
        }
        else if (artice.sizeScale == ArticleSizeScale_1_3)
        {
            self.footSeq.frame = CGRectMake(0, (kSWidth-20)/3 + 40+10-1, kSWidth, 0.5);
            thumbnail.frame = CGRectMake(10, 40, kSWidth-20, (kSWidth-20)/3);
            thumbnail.image = [Global getBgImage31];
        }
        else if (artice.sizeScale == ArticleSizeScale_1_4)
        {
            self.footSeq.frame = CGRectMake(0, (kSWidth-20)/4 + 40+10-1, kSWidth, 0.5);
            thumbnail.frame = CGRectMake(10, 40, kSWidth-20, (kSWidth-20)/4);
            thumbnail.image = [Global getBgImage41];
        }
        else if (artice.sizeScale == ArticleSizeScale_3_4)
        {
            self.footSeq.frame = CGRectMake(0, (kSWidth-20)/4*3 + 40+10-1, kSWidth, 0.5);
            thumbnail.frame = CGRectMake(10, 40, kSWidth-20, (kSWidth-20)/4*3);
            thumbnail.image = [Global getBgImage43];
        }
        else if (artice.sizeScale == ArticleSizeScale_9_16)
        {
            self.footSeq.frame = CGRectMake(0, (kSWidth-20)/16*9 + 40+10-1, kSWidth, 0.5);
            thumbnail.frame = CGRectMake(10, 40, kSWidth-20, (kSWidth-20)/16*9);
            thumbnail.image = [Global getBgImage169];
        }
        else
        {
            self.footSeq.frame = CGRectMake(0, (kSWidth-20)/3 + 40-1, kSWidth, 0.5);
            thumbnail.frame = CGRectMake(10, 40, kSWidth-20, (kSWidth-20)/3);
        }
    }
    
    if ([artice.imageUrl containsString:@".gif"]) {
        thumbnail.image = [Global getBgImage43];
        [self loadAnimatedImageWithURL:[NSURL URLWithString:artice.imageUrl] completion:^(FLAnimatedImage *animatedImage) {
            [thumbnail setAnimatedImage:animatedImage];
        }];
        
    }else{
        [thumbnail sd_setImageWithURL:[NSURL URLWithString:artice.imageUrl] placeholderImage:[Global getBgImage43]];
    }
    
    titleLabel.text = artice.title;
    self.commentLabel.text = [NSString stringWithFormat:@"%@%@",artice.readCount, NSLocalizedString(@"人阅读",nil)];
}

- (void)loadAnimatedImageWithURL:(NSURL *const)url completion:(void (^)(FLAnimatedImage *animatedImage))completion
{
    NSString *const filename = url.lastPathComponent;
    NSString *const diskPath = [NSHomeDirectory() stringByAppendingPathComponent:filename];
    
    NSData * __block animatedImageData = [[NSFileManager defaultManager] contentsAtPath:diskPath];
    FLAnimatedImage * __block animatedImage = [[FLAnimatedImage alloc] initWithAnimatedGIFData:animatedImageData];
    
    if (animatedImage) {
        if (completion) {
            completion(animatedImage);
        }
    } else {
        [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            animatedImageData = data;
            animatedImage = [[FLAnimatedImage alloc] initWithAnimatedGIFData:animatedImageData];
            if (animatedImage) {
                if (completion) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(animatedImage);
                    });
                }
                [data writeToFile:diskPath atomically:YES];
            }
        }] resume];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}
@end
