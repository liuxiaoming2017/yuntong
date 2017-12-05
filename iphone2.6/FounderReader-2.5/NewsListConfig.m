//
//  NewsListConfig.m
//  FounderReader-2.5
//
//  Created by chenfei on 4/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NewsListConfig.h"

static NewsListConfig *__listConfig = nil;

@implementation NewsListConfig

@synthesize headCellHeight, middleCellHeight, moreCellHeight, cellImageContentMode, middleActiveCellHeight;
@synthesize count;
@synthesize headCellTitleLabelHeight, headCellTitleFontSize, headCellTitleTextColor;
@synthesize headCellReadFontSize, headCellPubtimeFontSize;
@synthesize middleCellTitleFontSize, middleCellTitleTextColor, middleCellTitleLabelFrame;
@synthesize middleCellSummaryFontSize, middleCellSummaryTextColor, middleCellSummaryLabelFrame, middleCellSummaryTextCount;
@synthesize middleCellThumbnailFrame, middleCellDateFrame, middleCellDateTextColor, middleCellDateFontSize;
@synthesize middleActiveCellThumbnailFrame, middleActiveCellDateFrame, middleActiveCellDateTextColor, middleActiveCellDateFontSize;

@synthesize middleActiveCellTitleFontSize, middleActiveCellTitleTextColor, middleActiveCellTitleLabelFrame;
@synthesize cellBackgroundColor;
@synthesize moreCellTitle;
@synthesize moreCellTitleFontSize;
@synthesize middleActiveCellStateButtonFrame;

//imagecell
@synthesize imageCellHeight;
@synthesize imageCellTitleFontSize, imageCellTitleTextColor, imageCellTitleLabelFrame;
@synthesize imageCellSummaryFontSize, imageCellSummaryTextColor, imageCellSummaryLabelFrame, imageCellSummaryTextCount;
@synthesize imageCellThumbnailFrame, imageCellDateFrame, imageCellDateTextColor, imageCellDateFontSize,leftUserNameFontSize;
@synthesize pdfCellHeight,pdfCellTitleLabelFrame;



- (id)init
{
    self = [super init];
    if (self) {
        NSString *fileName = nil;
        if (kSWidth == 375) {
            fileName =@"news_list_config_6.plist";
        }else if (kSWidth == 414) {
            fileName =@"news_list_config_6p.plist";
        }else
            fileName =@"news_list_config.plist";
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:pathForMainBundleResource(fileName)];
        self.headCellHeight = [[dict objectForKey:@"head_cell_height"] floatValue];
        self.middleCellHeight = [[dict objectForKey:@"middle_cell_height"] floatValue];
        self.middleActiveCellHeight = [[dict objectForKey:@"middle_active_cell_height"] floatValue];
        self.moreCellHeight = [[dict objectForKey:@"more_cell_height"] floatValue];
        
        self.count = [[dict objectForKey:@"count"] intValue];
        
        self.headCellTitleLabelHeight = [[dict objectForKey:@"head_cell_title_label_height"] floatValue];
        self.headCellTitleFontSize = [[dict objectForKey:@"head_cell_title_font_size"] floatValue];
        self.headCellTitleTextColor = UIColorFromString([dict objectForKey:@"head_cell_title_text_color"]);
        
        self.headCellReadFontSize = [[dict objectForKey:@"head_cell_read_font_size"] floatValue];
        self.headCellPubtimeFontSize = [[dict objectForKey:@"head_cell_pubtime_font_size"] floatValue];//chenyuqi
        
        self.middleCellTitleFontSize = [[dict objectForKey:@"middle_cell_title_font_size"] floatValue];
        self.middleCellTitleTextColor = UIColorFromString([dict objectForKey:@"middle_cell_title_text_color"]);
        self.middleCellTitleLabelFrame = CGRectFromString([dict objectForKey:@"middle_cell_title_label_frame"]);
        self.middleActiveCellStateButtonFrame = CGRectFromString([dict objectForKey:@"middle_active_cell_state_button_frame"]);
       
        self.middleActiveCellTitleFontSize = [[dict objectForKey:@"middle_active_cell_title_font_size"] floatValue];
        self.middleActiveCellTitleTextColor = UIColorFromString([dict objectForKey:@"middle_active_cell_title_text_color"]);
        self.middleActiveCellTitleLabelFrame = CGRectFromString([dict objectForKey:@"middle_active_cell_title_label_frame"]);
        
        self.middleCellSummaryFontSize = [[dict objectForKey:@"middle_cell_summary_font_size"] floatValue];
        self.middleCellSummaryTextColor = UIColorFromString([dict objectForKey:@"middle_cell_summary_text_color"]);
        self.middleCellSummaryLabelFrame = CGRectFromString([dict objectForKey:@"middle_cell_summary_label_frame"]);
        self.middleCellSummaryTextCount = [[dict objectForKey:@"middle_cell_summary_text_count"] floatValue];
        
        self.middleCellThumbnailFrame = CGRectFromString([dict objectForKey:@"middle_cell_thumbnail_frame"]);
        self.middleActiveCellThumbnailFrame = CGRectFromString([dict objectForKey:@"middle_active_cell_thumbnail_frame"]);
        
        self.middleCellDateFrame = CGRectFromString([dict objectForKey:@"middle_cell_date_label_frame"]);
        self.middleCellDateFontSize = [[dict objectForKey:@"middle_cell_date_font_size"] floatValue];
        self.middleCellDateTextColor = UIColorFromString([dict objectForKey:@"middle_cell_date_text_color"]);
        
        self.middleActiveCellDateFrame = CGRectFromString([dict objectForKey:@"middle_active_cell_date_label_frame"]);
        self.middleActiveCellDateFontSize = [[dict objectForKey:@"middle_active_cell_date_font_size"] floatValue];
        self.middleActiveCellDateTextColor = UIColorFromString([dict objectForKey:@"middle_active_cell_date_text_color"]);
       
        self.cache_count = [[dict objectForKey:@"cache_count"] intValue];
        
        self.cellBackgroundColor = UIColorFromString([dict objectForKey:@"cell_background_color"]);
        self.moreCellTitle = NSLocalizedString(@"查看更多", nil);
        self.moreCellTitleFontSize = [[dict objectForKey:@"more_cell_title_font_size"] intValue];
        
        self.cellImageContentMode = [[dict objectForKey:@"image_show_mode"] intValue];
        
        //imagecell
        self.imageCellHeight = [[dict objectForKey:@"image_cell_height"] floatValue];
        self.imageCellThumbnailFrame = CGRectFromString([dict objectForKey:@"image_cell_thumbnail_frame"]);
        
        self.imageCellTitleFontSize = [[dict objectForKey:@"image_cell_title_font_size"] floatValue];
        self.imageCellTitleTextColor = UIColorFromString([dict objectForKey:@"image_cell_title_text_color"]);
        self.imageCellTitleLabelFrame = CGRectFromString([dict objectForKey:@"image_cell_title_label_frame"]);
        
        self.imageCellSummaryFontSize = [[dict objectForKey:@"image_cell_summary_font_size"] floatValue];
        self.imageCellSummaryTextColor = UIColorFromString([dict objectForKey:@"image_cell_summary_text_color"]);
        self.imageCellSummaryLabelFrame = CGRectFromString([dict objectForKey:@"image_cell_summary_label_frame"]);
        self.imageCellSummaryTextCount = [[dict objectForKey:@"image_cell_summary_text_count"] floatValue];
        
        self.imageCellDateFrame = CGRectFromString([dict objectForKey:@"image_cell_date_label_frame"]);
        self.imageCellDateFontSize = [[dict objectForKey:@"image_cell_date_font_size"] floatValue];
        self.imageCellDateTextColor = UIColorFromString([dict objectForKey:@"image_cell_date_text_color"]);
        
        
        self.leftUserNameFontSize = [[dict objectForKey:@"left_username_font_size"] floatValue];
        
        self.pdfCellHeight = [[dict objectForKey:@"pdf_cell_height"] floatValue];
        self.pdfCellTitleLabelFrame = CGRectFromString([dict objectForKey:@"pdf_cell_title_label_frame"]);
        
        self.left_userIcon_width = [[dict objectForKey:@"left_userIcon_width"] floatValue];
        self.right_userIcon_width = [[dict objectForKey:@"right_userIcon_width"] floatValue];
    }
    return self;
}

+ (NewsListConfig *)sharedListConfig
{
    if (__listConfig == nil) {
        __listConfig = [[self alloc] init];
    }
    return __listConfig;
}

@end
