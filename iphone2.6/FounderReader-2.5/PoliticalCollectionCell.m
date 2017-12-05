//
//  PoliticalCollectionCell.m
//  FounderReader-2.5
//
//  Created by yanbf on 16/7/13.
//
//

#import "PoliticalCollectionCell.h"
#import "NewsListConfig.h"
#import "ColumnBarConfig.h"
@implementation PoliticalCollectionCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
   
        self.backgroundColor = [UIColor clearColor];
        //设置栏目标题
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, kSWidth-20, 20)];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.font = [UIFont fontWithName:[Global fontName] size:[NewsListConfig sharedListConfig].middleCellTitleFontSize];
        self.titleLabel.numberOfLines = 1;
        self.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        self.titleLabel.textColor = [NewsListConfig sharedListConfig].middleCellTitleTextColor;
        [self.contentView addSubview:self.titleLabel];
        //设置栏目描述
        self.summaryLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 30, kSWidth-20, 60)];
        self.summaryLabel.backgroundColor = [UIColor clearColor];
        self.summaryLabel.font = [UIFont fontWithName:[Global fontName] size:[NewsListConfig sharedListConfig].middleCellSummaryFontSize];
        self.summaryLabel.textColor = [NewsListConfig sharedListConfig].middleCellSummaryTextColor;
        self.summaryLabel.numberOfLines = 3;
        self.summaryLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.contentView addSubview:self.summaryLabel];
        
        //设置栏目背景图
        _thumbnail = [[ImageViewCf alloc] init];
        _thumbnail.frame = CGRectMake(0, 0, kSWidth, kSWidth/3);
        _thumbnail.hidden = YES;
        [self.contentView addSubview:_thumbnail];
        
        UIView *footSeq =[[UIView alloc] initWithFrame:CGRectMake(0, kSWidth/3-1, kSWidth, 1)];
        footSeq.backgroundColor = UIColorFromString(@"221,221,221");
        [self.contentView addSubview:footSeq];
    }
    return self;
}
-(void)configPoliticalWithColumn:(Column *)column{

    if (column != nil) {
        if(column.iconUrl.length > 0){
            [_thumbnail setUrlString:column.iconUrl placeholderImage:@"bgicon31"];
            _thumbnail.hidden = NO;
        }
        else{
            _thumbnail.hidden = YES;
        }
        self.titleLabel.text = column.columnName;
        self.summaryLabel.text = column.description;
    }
}
@end
