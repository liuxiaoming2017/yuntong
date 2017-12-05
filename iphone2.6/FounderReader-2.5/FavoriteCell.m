//
//  FavoriteCell.m
//  FounderReader-2.5
//
//  Created by chenfei on 6/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import "UIView+Extention.h"
#import "FavoriteCell.h"
#import "NSString+Helper.h"
#import "NewsListConfig.h"
#import "UIImageView+WebCache.h"
@implementation FavoriteCell

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.isEditing) {
        [self sendSubviewToBack:self.contentView];
    }
}



- (void)configWithTitle:(NSString *)title summary:(NSString *)summary thumbnailUrl:(NSString *)url columnId:(int)columnId date:(NSString *)date readCount:(NSString *)readCount category:(NSString *)category
{
    self.footSeq.frame = CGRectMake(0, CGRectGetMaxY(cellBgView.frame) - 1, kSWidth, 0.5);
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    if (kSWidth == 375) {
        paragraphStyle.lineSpacing = 7;
    }else if (kSWidth == 414) {
        paragraphStyle.lineSpacing = 7;
    }else
        paragraphStyle.lineSpacing = 4;
    NSDictionary *attributes = @{
                                 NSFontAttributeName:[UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleCellTitleFontSize],
                                 NSParagraphStyleAttributeName:paragraphStyle
                                 };
    if ([title isKindOfClass:[NSNull class]]) {
        title = @"";
    }
    if (!title) {
        title = @"";
    }
    NSAttributedString *atrStr = [[NSAttributedString alloc] initWithString:title attributes:attributes];
    titleLabel.attributedText = atrStr; 
    if ([summary isKindOfClass:[NSString class]])
        summaryLabel.text = summary;
    else
        summaryLabel.text = @"";
    
    if ([NSString isNilOrEmpty:url] || [url isEqualToString:@"@!sm43"]) {
        [self showThumbnail:NO];
    } else {
        [self showThumbnail:YES];
        if ([url containsString:@".gif"]) {
            thumbnail.image = [Global getBgImage43];
            [self loadAnimatedImageWithURL:[NSURL URLWithString:url] completion:^(FLAnimatedImage *animatedImage) {
                [thumbnail setAnimatedImage:animatedImage];
            }];
        }
        else {
        UIImage *image = [UIImage imageWithContentsOfFile:cachePathFromURL(url)];
        if (image)
            thumbnail.image = image;
        else
            [thumbnail sd_setImageWithURL:[NSURL URLWithString:url]];
        }
    }
    
    dateLabel.frame = CGRectMake(titleLabel.frame.origin.x,[NewsListConfig sharedListConfig].middleCellHeight - [NewsListConfig sharedListConfig].middleCellDateFontSize + 1 - 10*proportion,150,[NewsListConfig sharedListConfig].middleCellDateFontSize + 1);
    
    dateLabel.text = intervalSinceNow(date);
    dateLabel.textColor = [UIColor lightGrayColor];
    dateLabel.font = [UIFont fontWithName:[Global fontName] size:[NewsListConfig sharedListConfig].middleCellDateFontSize ];
    
    if (category.length) {
        NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:[Global fontName] size:[NewsListConfig sharedListConfig].middleCellDateFontSize ], NSFontAttributeName,nil];
        CGSize size = [summary boundingRectWithSize:CGSizeMake(150, 12) options:NSStringDrawingUsesLineFragmentOrigin attributes:tdic context:nil].size;
    
        statusLabel.frame = CGRectMake(titleLabel.frame.origin.x,CGRectGetMaxY(titleLabel.frame) + 11,size.width+4,[NewsListConfig sharedListConfig].middleCellSummaryFontSize + 1);
        statusLabel.text = category;
        statusLabel.hidden = NO;
        dateLabel.frame = CGRectMake(statusLabel.frame.origin.x+statusLabel.frame.size.width+18,CGRectGetMaxY(titleLabel.frame) + 11,150,[NewsListConfig sharedListConfig].middleCellDateFontSize + 1);
    }
    else{
        statusLabel.hidden = YES;
    }
}

-(void)configMyFavoriteArticle:(Article *)article
{
   [self configWithTitle:article.title summary:article.attAbstract thumbnailUrl:article.imageUrl columnId:article.columnId date:article.publishTime readCount:article.readCount category:article.category];
}
@end
