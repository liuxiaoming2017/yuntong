//
//  ImageCell.m
//  FounderReader-2.5
//
//  Created by sa on 15-1-5.
//
//

#import "ImageCell.h"
#import "NewsListConfig.h"
#import "NSString+Helper.h"
#import "DataLib/DataLib.h"

@implementation ImageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //增加新闻列表背景
        CGRect bgFrame = CGRectMake(0, 0, self.frame.size.width, [NewsListConfig sharedListConfig].imageCellHeight);
        cellBgView = [[UIImageView alloc] initWithFrame:bgFrame];
        cellBgView.contentMode = UIViewContentModeScaleToFill;
        cellBgView.image = [UIImage imageNamed:@"middle_cell_background"];
        if (cellBgView.image) {
            [self.contentView addSubview:cellBgView];
        }
        
        UIImageView *selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"middle_cell_selected_background"]];
        self.selectedBackgroundView = selectedBackgroundView;

        self.backgroundColor = [NewsListConfig sharedListConfig].cellBackgroundColor;
        
        int nSpan = 3;
        CGRect bkthumbnail = [NewsListConfig sharedListConfig].imageCellThumbnailFrame;
        bkthumbnail = CGRectMake(bkthumbnail.origin.x-nSpan, bkthumbnail.origin.y-nSpan, bkthumbnail.size.width + 2*nSpan, bkthumbnail.size.height+2*nSpan);
        thumbnailbackground = [[UIImageView alloc] initWithFrame:bkthumbnail];
        thumbnailbackground.contentMode = UIViewContentModeScaleToFill;
        thumbnailbackground.image = [UIImage imageNamed:@"middle_cell_thumbtail_background"];
        if (thumbnailbackground.image) {
            [self.contentView addSubview:thumbnailbackground];
        }
        thumbnail = [[ImageViewCf alloc] initWithFrame:[NewsListConfig sharedListConfig].imageCellThumbnailFrame];
        
        NSInteger contentMode = UIViewContentModeScaleToFill;
        NSInteger nImageShowMode = [NewsListConfig sharedListConfig].cellImageContentMode;
        switch (nImageShowMode) {
            case 0:
                contentMode = UIViewContentModeScaleToFill; //拉伸铺满全部显示
                break;
            case 1:
                contentMode = UIViewContentModeScaleAspectFit;//不变形全部显示
                break;
            case 2:
                contentMode = UIViewContentModeScaleAspectFill;//不变形居中显示，会有部分裁剪
                break;
            default:
                contentMode = UIViewContentModeScaleToFill;
                break;
        }
        
        thumbnail.contentMode = contentMode;
        [self.contentView addSubview:thumbnail];
        
        titleLabel = [[UILabel alloc] initWithFrame:[NewsListConfig sharedListConfig].imageCellTitleLabelFrame];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.font = [UIFont systemFontOfSize:[NewsListConfig sharedListConfig].imageCellTitleFontSize];
        titleLabel.numberOfLines = 0;
        titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        titleLabel.textColor = [NewsListConfig sharedListConfig].imageCellTitleTextColor;
        [self.contentView addSubview:titleLabel];
        
        summaryLabel = [[UILabel alloc] initWithFrame:[NewsListConfig sharedListConfig].imageCellSummaryLabelFrame];
        summaryLabel.backgroundColor = [UIColor clearColor];
        summaryLabel.font = [UIFont systemFontOfSize:[NewsListConfig sharedListConfig].imageCellSummaryFontSize];
        summaryLabel.textColor = [NewsListConfig sharedListConfig].imageCellSummaryTextColor;
        summaryLabel.numberOfLines = 0;
        summaryLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.contentView addSubview:summaryLabel];
        
        dateLabel = [[UILabel alloc] initWithFrame:[NewsListConfig sharedListConfig].imageCellDateFrame];
        dateLabel.backgroundColor = [UIColor clearColor];
        dateLabel.font = [UIFont systemFontOfSize:[NewsListConfig sharedListConfig].imageCellDateFontSize];
        dateLabel.textColor = [NewsListConfig sharedListConfig].imageCellDateTextColor;
        dateLabel.numberOfLines = 0;
        dateLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.contentView addSubview:dateLabel];
    }
    return self;
}

- (void)showThumbnail:(BOOL)show
{
    return;
}

- (void)configWithTitle:(NSString *)title summary:(NSString *)summary thumbnailUrl:(NSString *)url columnId:(int)columnId
{
    titleLabel.text = title;
    NSString *summarytemp = @"";
    if ([summary isKindOfClass:[NSString class]] && summary.length > 0){
        
        summarytemp = summary;
    }
    else{
        summarytemp = @"";
    }
    
    if (self.isPDF) {
        summaryLabel.text = summary;
    }
    else{
        if (summarytemp.length > [NewsListConfig sharedListConfig].imageCellSummaryTextCount) {
            summarytemp = [summarytemp substringToIndex:[NewsListConfig sharedListConfig].imageCellSummaryTextCount];
            summarytemp = [summarytemp stringByAppendingString:@"..."];
        }
        summaryLabel.text = summarytemp;
    }
    
    [thumbnail setDefaultImage:[Global getBgImage43]];
    
    if ([NSString isNilOrEmpty:url]) {
        [self showThumbnail:NO];
    } else {
        [self showThumbnail:YES];
        [thumbnail setUrlString:url];
    }
}

- (void)configWithTitle:(NSString *)title summary:(NSString *)summary date:(NSString *)date thumbnailUrl:(NSString *)url columnId:(int)columnId{
    
    [self configWithTitle:title summary:summary thumbnailUrl:url columnId:columnId];
    
    dateLabel.text = @"";
}

-(void)configSpecialCellWithIsArticle:(Article *)article
{
    [self configWithTitle:article.title summary:article.attAbstract thumbnailUrl:article.imageUrl columnId:article.columnId];
    dateLabel.text = @"";
    
    if (article.isRead)
        titleLabel.textColor = summaryLabel.textColor;
    else
        titleLabel.textColor = [UIColor blackColor];
    
}
-(void)configTitleCellWithArticle:(Article *)article
{
    //普通新闻Cell
    [self configWithTitle:article.title summary:article.attAbstract thumbnailUrl:article.imageUrl columnId:article.columnId];
    if (article.isRead)
        titleLabel.textColor = summaryLabel.textColor;
    else
        titleLabel.textColor = [UIColor blackColor];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    NSLocale* locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:locale];
    [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"];
    NSDate *date1 = [dateFormatter dateFromString:article.publishTime];
    [dateFormatter setDateFormat:@"MM-dd HH:mm"];
    dateLabel.text = [dateFormatter stringFromDate:date1];
 
    if (![NSString isNilOrEmpty:article.videoUrl]) {
        CGRect newframe = [NewsListConfig sharedListConfig].imageCellDateFrame;
        newframe.origin.x -= 40;
        dateLabel.frame = newframe;
    }
}

-(void)configimageCellWithArticle:(Article *)article
{
    //普通新闻Cell
    [self configWithTitle:article.title summary:article.attAbstract thumbnailUrl:article.imageUrl columnId:article.columnId];
    if (article.isRead)
        titleLabel.textColor = summaryLabel.textColor;
    else
        titleLabel.textColor = [UIColor blackColor];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    NSLocale* locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:locale];
    [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"];
    NSDate *date1 = [dateFormatter dateFromString:article.publishTime];
    [dateFormatter setDateFormat:@"MM-dd HH:mm"];
    dateLabel.text = [dateFormatter stringFromDate:date1];
 
    if (![NSString isNilOrEmpty:article.videoUrl]) {
        CGRect newframe = [NewsListConfig sharedListConfig].imageCellDateFrame;
        newframe.origin.x -= 40;
        dateLabel.frame = newframe;
    }
}

@end
