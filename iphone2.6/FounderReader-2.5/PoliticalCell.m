//
//  PoliticalCell.m
//  FounderReader-2.5
//
//  Created by yanbf on 16/7/13.
//
//

#import "PoliticalCell.h"
#import "NewsListConfig.h"
#import "ColumnBarConfig.h"
@implementation PoliticalCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //增加新闻列表背景
        self.backgroundColor = [UIColor clearColor];
        
        self.footSeq =[[UIView alloc]init];
        self.footSeq.backgroundColor = UIColorFromString(@"221,221,221");
        [self.contentView addSubview:self.footSeq];
        
        _thumbnail = [[ImageViewCf alloc] init];
        [_thumbnail setDefaultImage:[UIImage imageNamed:@"political_head"]];
        [self.contentView addSubview:_thumbnail];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:[NewsListConfig sharedListConfig].middleCellTitleLabelFrame];
        
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.font = [UIFont fontWithName:[Global fontName] size:[NewsListConfig sharedListConfig].middleCellTitleFontSize];
        self.titleLabel.numberOfLines = 1;
        self.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        self.titleLabel.textColor = [NewsListConfig sharedListConfig].middleCellTitleTextColor;
        [self.contentView addSubview:self.titleLabel];
        
        self.summaryLabel = [[UILabel alloc] initWithFrame:[NewsListConfig sharedListConfig].middleCellSummaryLabelFrame];
        self.summaryLabel.backgroundColor = [UIColor clearColor];
        self.summaryLabel.font = [UIFont fontWithName:[Global fontName] size:[NewsListConfig sharedListConfig].middleCellSummaryFontSize];
        
        self.summaryLabel.textColor = [NewsListConfig sharedListConfig].middleCellSummaryTextColor;
        self.summaryLabel.numberOfLines = 2;
        self.summaryLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.contentView addSubview:self.summaryLabel];
        
        self.moreLabel = [[UILabel alloc] initWithFrame:[NewsListConfig sharedListConfig].middleCellSummaryLabelFrame];
        self.moreLabel.backgroundColor = [UIColor clearColor];
        self.moreLabel.font = [UIFont fontWithName:[Global fontName] size:[NewsListConfig sharedListConfig].middleCellSummaryFontSize-3];
        self.moreLabel.textColor = [NewsListConfig sharedListConfig].middleCellSummaryTextColor;
        self.moreLabel.numberOfLines = 0;
        self.moreLabel.textAlignment = NSTextAlignmentRight;
        self.moreLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.contentView addSubview:self.moreLabel];
        
    }
    return self;
}
-(void)configPoliticalWithColumn:(Column *)column
{
    int h = 100*kSWidth/320 - 10*2;
    int w = h * 3/4.0f;
    _thumbnail.frame = CGRectMake(10, 10, w, h);
    self.moreLabel.text = NSLocalizedString(@"查看相关新闻》", nil);
    if (column != nil) {
        self.titleLabel.text = column.columnName;
        self.summaryLabel.text = column.description;
        if(column.iconUrl.length > 0){
           [_thumbnail setUrlString:column.iconUrl placeholderImage:@"political_head"];
            self.titleLabel.frame = CGRectMake(w+20, 12*kSWidth/320, kSWidth-(w+30), 20);
            self.summaryLabel.frame = CGRectMake(w+20, 35*kSWidth/320, kSWidth-(w+30), 40);
            _thumbnail.hidden = NO;
            self.moreLabel.frame = CGRectMake(kSWidth-100-10, 100*kSWidth/320-25*kSWidth/320, 100, 20);
            self.footSeq.frame = CGRectMake(0, 100*kSWidth/320-1, kSWidth, 0.5);
        }
        else{
            self.titleLabel.frame = CGRectMake(20, (12*kSWidth/320)*3/4, kSWidth-30, 20);
            self.summaryLabel.frame = CGRectMake(20, (35*kSWidth/320)*3/4, kSWidth-30, 40);
            _thumbnail.hidden = YES;
            self.moreLabel.frame = CGRectMake(kSWidth-100-10, (100*kSWidth/320-25*kSWidth/320)*3/4, 100, 20);
            self.footSeq.frame = CGRectMake(0, (100*kSWidth/320-1)*3/4, kSWidth, 0.5);
        }
    }
    
    
}
@end
