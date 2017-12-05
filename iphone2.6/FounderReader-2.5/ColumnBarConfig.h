//
//  ColumnBarConfig.h
//  FounderReader-2.5
//
//  Created by chenfei on 4/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ColumnBarConfig : NSObject {
 
    CGFloat columnNameFontSize;
    CGFloat columnButtonSpacing;
    CGFloat columnBarHeight;
    int columnRefreshInterval;
    CGFloat specialImageScale;
    CGFloat columnHeaderScale;
}
@property(nonatomic) CGFloat columnHeaderScale;
@property(nonatomic) CGFloat specialImageScale;
@property(nonatomic) CGFloat columnHeaderHeight;
@property(nonatomic) CGFloat columnBtnMargin;
@property(nonatomic) CGFloat columnBtnHeight;
@property(nonatomic) CGFloat columnNameFontSize;
@property(nonatomic, assign) BOOL columnNameFontBold;
@property(nonatomic) CGFloat columnButtonSpacing;
@property(nonatomic) CGFloat columnBarHeight;
@property(nonatomic) int columnRefreshInterval;
@property(nonatomic, retain) UIColor* columnNameFontColor;
@property(nonatomic, retain) UIColor* columnNameFontSeledColor;
@property(nonatomic, retain) UIColor* columnBarBackgroundColor;

@property(nonatomic,retain) UIColor *column_all_color;
@property(nonatomic,assign) NSInteger columnSelectType;
@property(nonatomic,retain) UIColor *columnSelectColor;
@property(nonatomic,retain) UIColor *columnDisSelectColor;
@property(nonatomic, retain) UIColor *columnBKColor;
@property(nonatomic, copy) NSString *column_diselect_imagecolor;
@property(nonatomic,strong)UIColor * column_edit_backgroundColor;

+ (ColumnBarConfig *)sharedColumnBarConfig;

@end
