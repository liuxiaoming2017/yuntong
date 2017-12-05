//
//  ColumnBarConfig.m
//  FounderReader-2.5
//
//  Created by chenfei on 4/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ColumnBarConfig.h"

static ColumnBarConfig *__columnBarConfig = nil;

@implementation ColumnBarConfig

@synthesize  columnBtnHeight, columnBtnMargin, columnNameFontSize, columnButtonSpacing, columnBarHeight,columnRefreshInterval, columnNameFontColor, columnNameFontSeledColor,  columnHeaderHeight, columnBKColor, specialImageScale, columnHeaderScale;

- (id)init
{
    self = [super init];
    if (self) { 
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:pathForMainBundleResource(@"column_bar_config.plist")];
        
        self.columnBtnMargin = [[dict objectForKey:@"column_button_margin"] floatValue];
        self.columnBtnHeight = [[dict objectForKey:@"column_button_height"] floatValue];
        self.columnNameFontSize = [[dict objectForKey:@"column_name_font_size"] floatValue];
        self.columnNameFontBold = [[dict objectForKey:@"column_name_font_bold"] boolValue];
        self.columnButtonSpacing = [[dict objectForKey:@"column_button_spacing"] floatValue];
        self.columnHeaderHeight = [[dict objectForKey:@"column_head_height"] floatValue];
        self.columnBarHeight = self.columnBtnHeight + self.columnHeaderHeight;//[[dict objectForKey:@"column_bar_height"] floatValue];
        self.columnBKColor = UIColorFromString([dict objectForKey:@"column_head_backcolor"]);
        self.columnRefreshInterval = [[dict objectForKey:@"column_refresh_interval"] intValue];
        self.columnNameFontColor = UIColorFromString([dict objectForKey:@"column_name_font_color"]);
        self.columnNameFontSeledColor = UIColorFromString([dict objectForKey:@"column_name_font_seledcolor"]);
        self.columnBarBackgroundColor = UIColorFromString([dict objectForKey:@"column_bar_backgroundcolor"]);
        self.column_diselect_imagecolor = [dict objectForKey:@"column_diselect_imagecolor"];
        
        self.column_all_color = UIColorFromString([dict objectForKey:@"column_all_color"]);
        NSDictionary * columnSelectStyleDict = [dict objectForKey:@"column_select_style"];
        self.columnSelectType = [[columnSelectStyleDict objectForKey:@"style_type"] integerValue];
        self.columnSelectColor = UIColorFromString([columnSelectStyleDict objectForKey:@"style_select_color"]);
        self.columnDisSelectColor = UIColorFromString([columnSelectStyleDict objectForKey:@"style_disselect_color"]);
        self.column_edit_backgroundColor =  UIColorFromString([dict objectForKey:@"column_edit_backgroundcolor"]);
        if([dict objectForKey:@"special_top_image_scale"]){
            self.specialImageScale = [[dict objectForKey:@"special_top_image_scale"] floatValue];
        }
        else{
            self.specialImageScale = 3.0;
        }
        if([dict objectForKey:@"column_head_scale"]){
            self.columnHeaderScale = [[dict objectForKey:@"column_head_scale"] floatValue];
        }
        else{
            self.columnHeaderScale = 1.33333;
        }
    }
    return self;
}

+ (ColumnBarConfig *)sharedColumnBarConfig
{
    if (__columnBarConfig == nil)
        __columnBarConfig = [[self alloc] init];
    return __columnBarConfig;
}

@end
