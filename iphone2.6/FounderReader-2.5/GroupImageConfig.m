//
//  GroupImageConfig.m
//  FounderReader-2.5
//
//  Created by chenfei on 5/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GroupImageConfig.h"

//static GroupImageConfig *__groupImageConfig = nil;

@implementation GroupImageConfig

@synthesize columnCount, columnSpace, nameFontSize, isGroupImage, nameTextColor, hasBgImage, columnHeight, backgroundColor, isShowTitle;

//- (void)dealloc
//{
//    DELETE(nameTextColor);
//    DELETE(backgroundColor);
//    [super dealloc];
//}

- (id)initWithDict:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        self.columnCount = [[dict objectForKey:@"column_count"] intValue];
        self.columnSpace = [[dict objectForKey:@"column_space"] floatValue];
        self.nameFontSize = [[dict objectForKey:@"name_font_size"] intValue];
        self.isGroupImage = [[dict objectForKey:@"is_group_image"] boolValue];
        self.columnHeight = [[dict objectForKey:@"column_height"] floatValue];
        self.nameTextColor = UIColorFromString([dict objectForKey:@"name_text_color"]);
        self.backgroundColor = UIColorFromString([dict objectForKey:@"background_color"]);
        self.hasBgImage = [[dict objectForKey:@"has_bg_image"] boolValue];
        self.isShowTitle = [[dict objectForKey:@"is_show_title"] boolValue];
        
        
    }
    return self;
}

//+ (GroupImageConfig *)sharedGroupImageConfig
//{
//    if (__groupImageConfig == nil)
//        __groupImageConfig = [[self alloc] init];
//    return __groupImageConfig;
//}

+ (NSArray *)groupImageConfigs
{
    NSArray *configs = [NSArray arrayWithContentsOfFile:pathForMainBundleResource(@"group_image_config.plist")];
    NSMutableArray *groupConfigs = [NSMutableArray arrayWithCapacity:[configs count]];
    for (NSDictionary *dict in configs) {
        GroupImageConfig *config = [[GroupImageConfig alloc] initWithDict:dict];
        [groupConfigs addObject:config];
 
    }
    return [NSArray arrayWithArray:groupConfigs];
}

@end
