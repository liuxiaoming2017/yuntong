//
//  Column.m
//  FounderReader-2.5
//
//  Created by chenfei on 4/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Column.h"
#import "NSString+Helper.h"

@implementation Column

@synthesize columnId, topArticleNum,columnName, className, iconUrl, linkUrl,lastupdatetime;
@synthesize columnStyle,columnvalue,showcolumn,columnType,orderId,description, fullColumn;
@synthesize isSelected, version;

+(NSArray *)loadAreaColumns:(NSArray *)array
{
    NSMutableArray *areaColumns = [[NSMutableArray alloc] initWithCapacity:[array count]];
    for (NSDictionary *dict in array)
    {
        Column *column = [[Column alloc] init];
        column.catName = [dict objectForKey:@"catName"];
        column.childrenArray =[dict objectForKey:@"children"];
        [areaColumns addObject:column];
    }
    return areaColumns;
}
+(NSArray *)loadAreaRightColumns:(NSArray *)array
{
    NSMutableArray *areaColumns = [[NSMutableArray alloc]initWithCapacity:[array count]];
    for (NSDictionary *dict in array)
    {
        Column *column =[[Column alloc] init];
        column.catID = [dict objectForKey:@"catID"];
        column.catName = [dict objectForKey:@"catName"];
        [areaColumns addObject:column];
    }
    return areaColumns;
}
+ (NSArray *)columnsFromArray:(NSArray *)array
{
    NSMutableArray *columns = [[NSMutableArray alloc] initWithCapacity:[array count]];
    for (NSDictionary *dict in array) {
        Column *column = [[Column alloc] init];
        column.columnId = [[dict objectForKey:@"columnID"] intValue];
        column.topArticleNum = [[dict objectForKey:@"topCount"] intValue];
        column.columnName = [dict objectForKey:@"columnName"];
        column.columnStyle = [dict objectForKey:@"columnStyle"];
        column.columnType = [dict objectForKey:@"channelType"];
        column.fullColumn = [dict objectForKey:@"fullColumn"];
        column.showcolumn = [[dict objectForKey:@"isHide"] boolValue];
        column.linkUrl = [dict objectForKey:@"linkUrl"];
        column.description = [dict objectForKey:@"description"];
        column.iconUrl = [dict objectForKey:@"imgUrl"];
        column.columnvalue = [dict objectForKey:@"columnvalue"];
        column.orderId = [[dict objectForKey:@"orderId"] intValue];
        column.padIcon = [dict objectForKey:@"padIcon"];
        column.version = [dict objectForKey:@"version"];
        column.hasSubColumn = [[dict objectForKey:@"hasSubColumn"] integerValue];
        column.columns = [dict objectForKey:@"columns"];
        if (![NSString isNilOrEmpty:[dict objectForKey:@"keyword"]]) {
            NSData *keywordJSONData = [[dict objectForKey:@"keyword"] dataUsingEncoding:NSUTF8StringEncoding];
            column.keyword = [NSJSONSerialization JSONObjectWithData:keywordJSONData options:NSJSONReadingMutableLeaves error:nil];
        }
        [columns addObject:column];
    }
    return columns;
}

+ (Column *)columnsFromDic:(NSDictionary *)dict
{
    Column *column = [[Column alloc] init];
    column.columnId = [[dict objectForKey:@"columnID"] intValue];
    column.topArticleNum = [[dict objectForKey:@"topCount"] intValue];
    column.columnName = [dict objectForKey:@"columnName"];
    column.columnStyle = [dict objectForKey:@"columnStyle"];
    column.columnType = [dict objectForKey:@"channelType"];
    column.showcolumn = [[dict objectForKey:@"isHide"] boolValue];
    column.linkUrl = [dict objectForKey:@"linkUrl"];
    column.description = [dict objectForKey:@"description"];
    column.iconUrl = [dict objectForKey:@"imgUrl"];
    column.columnvalue = [dict objectForKey:@"columnvalue"];
    column.orderId = [[dict objectForKey:@"orderId"] intValue];
    column.padIcon = [dict objectForKey:@"padIcon"];
    column.version = [dict objectForKey:@"version"];
    column.fullColumn = [dict objectForKey:@"fullColumn"];
    column.hasSubColumn = [[dict objectForKey:@"hasSubColumn"] integerValue];
    
    if (![NSString isNilOrEmpty:[dict objectForKey:@"keyword"]]) {
        NSData *keywordJSONData = [[dict objectForKey:@"keyword"] dataUsingEncoding:NSUTF8StringEncoding];
        column.keyword = [NSJSONSerialization JSONObjectWithData:keywordJSONData options:NSJSONReadingMutableLeaves error:nil];
    }
    
    return column;
}

@end
