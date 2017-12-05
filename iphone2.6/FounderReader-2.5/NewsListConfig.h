//
//  NewsListConfig.h
//  FounderReader-2.5
//
//  Created by chenfei on 4/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewsListConfig : NSObject {
    CGFloat headCellHeight;
    CGFloat middleCellHeight;
    CGFloat moreCellHeight;
    
    CGFloat middleActiveCellHeight;
    
    int     count;
    
    CGFloat headCellTitleLabelHeight;
    CGFloat headCellTitleFontSize;
    UIColor *headCellTitleTextColor;
    
    CGFloat headCellReadFontSize;
    CGFloat headCellPubtimeFontSize;
    
    CGFloat middleCellTitleFontSize;
    UIColor *middleCellTitleTextColor;
    CGRect  middleCellTitleLabelFrame;
    
    CGFloat middleCellStateFontSize;
    UIColor *middleCellStateTextColor;
    CGRect  middleCellStateLabelFrame;
  
    CGFloat middleActiveCellTitleFontSize;
    UIColor *middleActiveCellTitleTextColor;
    CGRect  middleActiveCellTitleLabelFrame;
    
    CGFloat middleCellSummaryFontSize;
    UIColor *middleCellSummaryTextColor;
    CGRect  middleCellSummaryLabelFrame;
    CGFloat middleCellSummaryTextCount;
    
    CGRect  middleCellThumbnailFrame;
    CGRect  middleActiveCellThumbnailFrame;
    
    CGRect middleCellDateFrame;
    CGFloat middleCellDateFontSize;
    UIColor *middleCellDateTextColor;
    
    CGRect middleActiveCellDateFrame;
    CGFloat middleActiveCellDateFontSize;
    UIColor *middleActiveCellDateTextColor;
   
    UIColor *cellBackgroundColor;
    NSString *moreCellTitle;
    NSInteger cellImageContentMode;
    
    CGRect middleCellStateButtonFrame;
    
    //image类型cell
    CGFloat imageActiveCellHeight;
    CGRect  imageCellThumbnailFrame;
    
    CGFloat imageCellTitleFontSize;
    UIColor *imageCellTitleTextColor;
    CGRect  imageCellTitleLabelFrame;
    
    CGFloat imageCellSummaryFontSize;
    UIColor *imageCellSummaryTextColor;
    CGRect  imageCellSummaryLabelFrame;
    CGFloat imageCellSummaryTextCount;
    
    CGRect imageCellDateFrame;
    CGFloat imageleCellDateFontSize;
    UIColor *imageCellDateTextColor;
    
    CGFloat leftUserNameFontSize;
}

@property(nonatomic, assign) CGFloat headCellHeight;
@property(nonatomic, assign) CGFloat middleCellHeight;
@property(nonatomic, assign) CGFloat moreCellHeight;

@property(nonatomic, assign) CGFloat middleActiveCellHeight;

@property(nonatomic, assign) int     count;

@property(nonatomic, assign) CGFloat headCellTitleLabelHeight;
@property(nonatomic, assign) CGFloat headCellTitleFontSize;
@property(nonatomic, retain) UIColor *headCellTitleTextColor;

@property(nonatomic, assign) CGFloat headCellReadFontSize;
@property(nonatomic, assign) CGFloat headCellPubtimeFontSize;//add by chenyuqi

@property(nonatomic, assign) CGFloat middleCellTitleFontSize;
@property(nonatomic, retain) UIColor *middleCellTitleTextColor;
@property(nonatomic, assign) CGRect  middleCellTitleLabelFrame;

@property(nonatomic, assign) CGFloat middleActiveCellTitleFontSize;
@property(nonatomic, retain) UIColor *middleActiveCellTitleTextColor;
@property(nonatomic, assign) CGRect  middleActiveCellTitleLabelFrame;

@property(nonatomic, assign) int     cache_count;

@property(nonatomic, assign) CGFloat middleCellSummaryFontSize;
@property(nonatomic, retain) UIColor *middleCellSummaryTextColor;
@property(nonatomic, assign) CGRect  middleCellSummaryLabelFrame;
@property(nonatomic, assign) CGFloat middleCellSummaryTextCount;

@property(nonatomic, assign) CGRect  middleCellThumbnailFrame;
@property(nonatomic, assign) CGRect  middleActiveCellThumbnailFrame;

@property(nonatomic, assign) CGRect  middleCellDateFrame;
@property(nonatomic, assign) CGFloat middleCellDateFontSize;
@property(nonatomic, retain) UIColor *middleCellDateTextColor;

@property(nonatomic, assign) CGRect  middleActiveCellDateFrame;
@property(nonatomic, assign) CGFloat middleActiveCellDateFontSize;
@property(nonatomic, retain) UIColor *middleActiveCellDateTextColor;

@property(nonatomic, retain) UIColor *cellBackgroundColor;
@property(nonatomic, retain) NSString *moreCellTitle;
@property(nonatomic, assign) int moreCellTitleFontSize;
@property(nonatomic, assign) NSInteger cellImageContentMode;

@property(nonatomic, assign) CGRect middleActiveCellStateButtonFrame;

//imagecell
@property(nonatomic, assign) CGFloat imageCellHeight;
@property(nonatomic, assign) CGRect  imageCellThumbnailFrame;

@property(nonatomic, assign) CGFloat imageCellTitleFontSize;
@property(nonatomic, retain) UIColor *imageCellTitleTextColor;
@property(nonatomic, assign) CGRect  imageCellTitleLabelFrame;

@property(nonatomic, assign) CGFloat imageCellSummaryFontSize;
@property(nonatomic, retain) UIColor *imageCellSummaryTextColor;
@property(nonatomic, assign) CGRect  imageCellSummaryLabelFrame;
@property(nonatomic, assign) CGFloat imageCellSummaryTextCount;

@property(nonatomic, assign) CGRect  imageCellDateFrame;
@property(nonatomic, assign) CGFloat imageCellDateFontSize;
@property(nonatomic, retain) UIColor *imageCellDateTextColor;

@property(nonatomic, assign) CGFloat leftUserNameFontSize;
@property(nonatomic, assign) CGFloat pdfCellHeight;
@property(nonatomic, assign) CGRect  pdfCellTitleLabelFrame;

@property(nonatomic, assign) CGFloat left_userIcon_width;
@property(nonatomic, assign) CGFloat right_userIcon_width;



+ (NewsListConfig *)sharedListConfig;

@end
