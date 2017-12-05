//
//  GroupImageConfig.h
//  FounderReader-2.5
//
//  Created by chenfei on 5/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GroupImageConfig : NSObject {
    int columnCount;
    CGFloat columnSpace;
    int     nameFontSize;
    CGFloat columnHeight;
    BOOL isGroupImage;
    BOOL hasBgImage;
    UIColor *backgroundColor;
    BOOL isShowTitle;
}

@property(nonatomic) int     columnCount;
@property(nonatomic) CGFloat columnSpace;
@property(nonatomic) CGFloat columnHeight;
@property(nonatomic) int     nameFontSize;
@property(nonatomic) BOOL    isGroupImage;
@property(nonatomic, retain) UIColor *nameTextColor;
@property(nonatomic, retain) UIColor *backgroundColor;
@property(nonatomic, assign) BOOL hasBgImage;
@property(nonatomic, assign) BOOL isShowTitle;

//+ (GroupImageConfig *)sharedGroupImageConfig;
+ (NSArray *)groupImageConfigs;

@end
