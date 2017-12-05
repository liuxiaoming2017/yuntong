//
//  CommentConfig.m
//  FounderReader-2.5
//
//  Created by chenfei on 5/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CommentConfig.h"

static CommentConfig *__commentConfig = nil;

@implementation CommentConfig

@synthesize commentBgColor, commentTextViewBorderColor, cellEdge, usernameContentSpace, usernameTextColor, usernameFontSize, contentTextColor, contentFontSize, oddCellBgColor, evenCellBgColor, moreCellHeight, moreCellTitle, moreCellTitleFontSize, moreCellTitleColor, defaultNickName, commentvisiable;

- (id)init
{
    self = [super init];
    if (self) {
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:pathForMainBundleResource(@"comment_config.plist")];
        self.commentBgColor = UIColorFromString([dict objectForKey:@"comment_bg_color"]);
        self.commentTextViewBorderColor = UIColorFromString([dict objectForKey:@"comment_text_view_border_color"]);
        self.cellEdge = UIEdgeInsetsFromString([dict objectForKey:@"cell_edge"]);
        self.usernameContentSpace = [[dict objectForKey:@"username_content_space"] floatValue];
        self.usernameTextColor = UIColorFromString([dict objectForKey:@"username_text_color"]);
        self.usernameFontSize = [[dict objectForKey:@"username_font_size"] floatValue];
        self.contentTextColor = UIColorFromString([dict objectForKey:@"content_text_color"]);
        self.contentFontSize = [[dict objectForKey:@"content_font_size"] floatValue];
        self.oddCellBgColor = UIColorFromString([dict objectForKey:@"odd_cell_bg_color"]);
        self.evenCellBgColor = UIColorFromString([dict objectForKey:@"even_cell_bg_color"]);
        self.moreCellHeight = [[dict objectForKey:@"more_cell_height"] floatValue];
        self.moreCellTitle = NSLocalizedString(@"查看更多", nil);
        self.moreCellTitleColor = UIColorFromString([dict objectForKey:@"more_cell_title_color"]);
        self.moreCellTitleFontSize = [[dict objectForKey:@"more_cell_title_font_size"] floatValue];
        self.defaultNickName = NSLocalizedString(@"手机用户", nil);
        self.commentvisiable = [[dict objectForKey:@"comment_visiable"] boolValue];
    }
    return self;
}

+ (CommentConfig *)sharedCommentConfig
{
    if (__commentConfig == nil)
        __commentConfig = [[self alloc] init];
    return __commentConfig;
}

- (void)dealloc
{
    self.commentBgColor = nil;
    self.commentTextViewBorderColor = nil;
    self.usernameTextColor = nil;
    self.contentTextColor = nil;
    self.oddCellBgColor = nil;
    self.evenCellBgColor = nil;
    self.moreCellTitle = nil;
    self.moreCellTitleColor = nil;
    self.defaultNickName = nil;
    
//    [super dealloc];
}

@end
