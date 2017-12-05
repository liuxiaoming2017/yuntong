//
//  Column.h
//  FounderReader-2.5
//
//  Created by chenfei on 4/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Column : NSObject
{
    int columnId;
    int topArticleNum;
    NSString *columnName;
    NSString *className;
    NSString *iconUrl;
    NSString *linkUrl;
    NSDate *lastupdatetime;
    NSString *version;
}

@property (nonatomic, assign) int columnId;                //栏目ID:100
@property (nonatomic, retain) NSString *columnName;        //栏目名称:栏目1
@property (nonatomic, retain) NSString *columnStyle;       //栏目样式
@property (nonatomic, retain) NSString *columnType;        //栏目类型（）
@property (nonatomic, retain) NSString *description;       //栏目描述
@property (nonatomic, retain) NSString *iconUrl;           //栏目图标
@property (nonatomic, assign) BOOL showcolumn;             //是否隐藏:默认 0表示显示，1表示隐藏
@property (nonatomic, retain) NSString *linkUrl;           //外链地址
@property (nonatomic, assign) int topArticleNum;           //栏目的头条个数
@property (nonatomic, strong) NSDictionary *keyword;       //扩展字段
@property (nonatomic, retain) NSString *version;            //栏目版本号
@property (nonatomic, retain) NSString *fullColumn;         //栏目完整路径
@property (nonatomic, assign) NSInteger hasSubColumn;       //子栏目数目

@property(nonatomic, assign) int orderId;
@property(nonatomic, retain) NSDate *lastupdatetime;
@property(nonatomic, retain) NSString *columnvalue;
@property(nonatomic, retain) NSString *className;
@property(nonatomic, retain) NSString *padIcon;
@property(nonatomic, assign) BOOL isSelected;
@property(nonatomic ,assign) NSNumber *catID;
@property(nonatomic ,retain) NSString *catName;
@property(nonatomic ,retain) NSArray *childrenArray;
@property(nonatomic ,retain) NSArray *columns;

+ (NSArray *)columnsFromArray:(NSArray *)array;
+ (Column *)columnsFromDic:(NSDictionary *)dict;

+ (NSArray *)loadAreaColumns:(NSArray *)array;
+ (NSArray *)loadAreaRightColumns:(NSArray *)array;
@end
