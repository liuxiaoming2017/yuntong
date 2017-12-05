//
//  ColorStyleConfig.m
//  FounderReader-2.5
//
//  Created by 袁野 on 16/3/14.
//
//

#import "ColorStyleConfig.h"
static ColorStyleConfig *_ColorStyleConfig = nil;
@implementation ColorStyleConfig
@synthesize login_button_color,tabbar_titlecolorstring_diselect,tabbar_imagecolorstring_diselect, cell_statusLabel_color, nav_bar_color;
- (id)init
{
    self = [super init];
    if (self) {
        
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:pathForMainBundleResource(@"color_style_config.plist")];
        self.login_button_color = UIColorFromString([dict objectForKey:@"login_button_color"]);
        self.navbar_titlecolor_didselect = UIColorFromString([dict objectForKey:@"navbar_titlecolor_didselect"]);
        self.navbar_titlecolor_selected = UIColorFromString([dict objectForKey:@"navbar_titlecolor_selected"]);
        self.tabbar_titlecolorstring_diselect = [dict objectForKey:@"tabbar_titlecolor_diselect"];
        self.tabbar_imagecolorstring_diselect = [dict objectForKey:@"tabbar_imagecolor_diselect"];
        self.cell_statusLabel_color = UIColorFromString([dict objectForKey:@"cell_statusLabel_color"]);
        self.nav_bar_color = UIColorFromString([dict objectForKey:@"nav_bar_color"]);   
    }
    return self;
}
+ (ColorStyleConfig *)sharedColorStyleConfig
{
    if (_ColorStyleConfig == nil)
        _ColorStyleConfig = [[self alloc] init];
    return _ColorStyleConfig;
}
@end
