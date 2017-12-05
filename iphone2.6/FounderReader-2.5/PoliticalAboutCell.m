//
//  PoliticalCell.m
//  FounderReader-2.5
//
//  Created by yanbf on 16/7/13.
//
//

#import "PoliticalAboutCell.h"
#import "NewsListConfig.h"
#import "ColumnBarConfig.h"
#import "FounderDetailPackage.h"
#import "NewsListConfig.h"
#import "UIImageView+WebCache.h"
#import "UIView+Extention.h"
#import "AppConfig.h"

@implementation PoliticalAboutCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //增加新闻列表背景
        self.backgroundColor = [UIColor clearColor];
        
        self.footSeq =[[UIView alloc]init];
        self.footSeq.backgroundColor = UIColorFromString(@"221,221,221");
        [self.contentView addSubview:self.footSeq];
        
        self.iconImageView = [[UIImageView alloc] initWithFrame:[NewsListConfig sharedListConfig].middleCellThumbnailFrame];
        [self.contentView addSubview:_iconImageView];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:[NewsListConfig sharedListConfig].middleCellTitleLabelFrame];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.font = [UIFont fontWithName:[Global fontName] size:[NewsListConfig sharedListConfig].middleCellTitleFontSize];
        self.titleLabel.numberOfLines = 2;
        self.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        self.titleLabel.textColor = [NewsListConfig sharedListConfig].middleCellTitleTextColor;
        [self.contentView addSubview:self.titleLabel];
        
        self.readerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.readerLabel.font = [UIFont fontWithName:[Global fontName] size:[NewsListConfig sharedListConfig].middleCellDateFontSize];
        self.readerLabel.textColor = [NewsListConfig sharedListConfig].middleCellDateTextColor;
        [self.contentView addSubview:self.readerLabel];
        
        self.dateLabel = [[UILabel alloc] initWithFrame:[NewsListConfig sharedListConfig].middleCellDateFrame];
        self.dateLabel.backgroundColor = [UIColor clearColor];
        self.dateLabel.font = [UIFont fontWithName:[Global fontName] size:[NewsListConfig sharedListConfig].middleCellDateFontSize];
        
        self.dateLabel.textColor = [NewsListConfig sharedListConfig].middleCellDateTextColor;
        self.dateLabel.numberOfLines = 2;
        self.dateLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.contentView addSubview:self.dateLabel];
        
    }
    return self;
}
-(void)configPoliticalAboutWithArticle:(Article *)article
{
    self.titleLabel.text = article.title;
    self.article = article;

    NSString *strReader = [NSString stringWithFormat:@"%@%@",article.readCount, NSLocalizedString(@"人阅读","")];
    self.readerLabel.text = strReader;
    
    NSString *strDate = [NSString stringWithFormat:@"%@",article.publishTime];
    NSRange range;
    range.length = 11;
    range.location = 5;
    strDate = [NSString stringWithFormat:@"%@", [strDate substringWithRange:range]];
    self.dateLabel.text = strDate;
    
    //没图时隐藏占为图
    if (![AppConfig sharedAppConfig].isArticleShowDefaultImage && ([NSString isNilOrEmpty:article.imageUrl] || [article.imageUrl isEqualToString:@"@!sm43"])) {
        self.iconImageView.frame = CGRectZero;
        self.titleLabel.x = 10;
        self.titleLabel.width = kSWidth - 20;
        self.readerLabel.x = 10;
        self.dateLabel.x = CGRectGetMaxX(self.readerLabel.frame) + 10;
    }else {
        UIImage * placeholderImage = nil;
        if (article.isBigPic == 1) {
            placeholderImage = [Global getBgImage169];
        }else if(article.isBigPic == 2){
            placeholderImage = [Global getBgImage31];
        }else{
            placeholderImage = [Global getBgImage43];
        }
        [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:article.imageUrl] placeholderImage:placeholderImage];
    }
    
}
-(void)layoutSubviews{
    [super layoutSubviews];
    //没图时隐藏占为图
    if (![AppConfig sharedAppConfig].isArticleShowDefaultImage && ([NSString isNilOrEmpty:self.article.imageUrl] || [self.article.imageUrl isEqualToString:@"@!sm43"])) {
        self.iconImageView.frame = CGRectZero;
        self.titleLabel.x = 10;
        self.titleLabel.width = kSWidth - 20;
        self.readerLabel.x = 10;
        self.dateLabel.x = CGRectGetMaxX(self.readerLabel.frame) + 10;
    }else {
        NSString *strReader = [NSString stringWithFormat:@"%@%@",self.article.readCount, NSLocalizedString(@"人阅读","")];
        float wReader = [FounderDetailPackage WidthWithText:strReader Font:[UIFont fontWithName:[Global fontName] size:[NewsListConfig sharedListConfig].middleCellDateFontSize] height:15];
        NSString *strDate = [NSString stringWithFormat:@"%@",self.article.publishTime];
        NSRange range;
        range.length = 11;
        range.location = 5;
        strDate = [NSString stringWithFormat:@"%@", [strDate substringWithRange:range]];
        float wDate = [FounderDetailPackage WidthWithText:strDate Font:[UIFont fontWithName:[Global fontName] size:[NewsListConfig sharedListConfig].middleCellDateFontSize] height:15];
        
        if (self.article.isBigPic == 1) {
            self.iconImageView.frame = CGRectMake(10, 10, kSWidth-20, (kSWidth-20)*9/16.0);
            CGFloat titleableY = CGRectGetMaxY(self.iconImageView.frame)+10*proportion;
            self.titleLabel.frame = CGRectMake(10, titleableY, kSWidth-20, 25);
            self.readerLabel.frame = CGRectMake(10, CGRectGetMaxY(self.titleLabel.frame)+10, wReader, 15);
            self.dateLabel.frame = CGRectMake(CGRectGetMaxX(self.readerLabel.frame) + 10, self.readerLabel.frame.origin.y, wDate, 15);
            self.footSeq.frame = CGRectMake(0, 238*proportion-1, kSWidth, 1);
        }else if(self.article.isBigPic == 2){
            self.iconImageView.frame = CGRectMake(10, 10, kSWidth-20, (kSWidth-20)*1/3.0);
            CGFloat titleableY = CGRectGetMaxY(self.iconImageView.frame)+10*proportion;
            self.titleLabel.frame = CGRectMake(10, titleableY, kSWidth-20, 25);
            self.readerLabel.frame = CGRectMake(10, CGRectGetMaxY(self.titleLabel.frame)+10, wReader, 15);
            self.dateLabel.frame = CGRectMake(CGRectGetMaxX(self.readerLabel.frame) + 10, self.readerLabel.frame.origin.y, wDate, 15);
            self.footSeq.frame = CGRectMake(0, 169*proportion-1, kSWidth, 1);
        }else{
            self.titleLabel.frame = [NewsListConfig sharedListConfig].middleCellTitleLabelFrame;
            self.iconImageView.frame = [NewsListConfig sharedListConfig].middleCellThumbnailFrame;
            self.readerLabel.frame = CGRectMake(CGRectGetMaxX(self.iconImageView.frame) + 10, 80*kSWidth/320-25, wReader, 15);
            self.dateLabel.frame = CGRectMake(CGRectGetMaxX(self.readerLabel.frame) + 10, 80*kSWidth/320-25, wDate, 15);
            self.footSeq.frame = CGRectMake(0, 80*kSWidth/320-1, kSWidth, 1);
        }

    }
    //隐藏阅读数
    if (self.article.articleType == ArticleType_LIVESHOW) {
        if (![AppConfig sharedAppConfig].isLiveAppearReadCount || self.hideReadCount) {
            self.readerLabel.hidden = YES;
            if (self.article.isBigPic == 1 || self.article.isBigPic == 2) {
                self.dateLabel.x = 10;
            }else{
                self.dateLabel.x = CGRectGetMaxX(self.iconImageView.frame) + 10;
            }
        }
    }else{
        if (![AppConfig sharedAppConfig].isAppearReadCount || self.hideReadCount) {
            self.readerLabel.hidden = YES;
            if (self.article.isBigPic == 1 || self.article.isBigPic == 2) {
                self.dateLabel.x = 10;
            }else{
                self.dateLabel.x = CGRectGetMaxX(self.iconImageView.frame) + 10;
            }
        }
    }
    
}
@end
