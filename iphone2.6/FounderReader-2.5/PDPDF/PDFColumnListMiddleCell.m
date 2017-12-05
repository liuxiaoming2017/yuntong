//
//  PDFColumnListMiddleCell.m
//  FounderReader-2.5
//
//  Created by ld on 14-3-19.
//
//

#import "PDFColumnListMiddleCell.h"
#import "NewsListConfig.h"

#define pdfImagewidth 120
#define pdfImageHeight 80
#define pdftitlewidth 160


@implementation PDFColumnListMiddleCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    return self;
}

- (void)configWithTitle:(NSString *)title summary:(NSString *)summary thumbnailUrl:(NSString *)url columnId:(int)columnId{
    
    [super configWithTitle:title summary:summary thumbnailUrl:url columnId:columnId];
}

-(void)configPDFmiddleCell:(Article *)article{
    
    [self configWithTitle:article.title summary:article.attAbstract date:article.publishTime thumbnailUrl:article.imageUrl columnId:article.columnId];
    if (article.isRead)
        titleLabel.textColor = [NewsListConfig sharedListConfig].middleCellSummaryTextColor;
    else
        titleLabel.textColor = [UIColor blackColor];
}

@end
