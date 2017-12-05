//
//  ColorStyleConfig.h
//  FounderReader-2.5
//
//  Created by 袁野 on 16/3/14.
//
//

#import <Foundation/Foundation.h>

@interface ColorStyleConfig : NSObject
@property(nonatomic, retain) UIColor *login_button_color;
@property(nonatomic, retain) NSString *tabbar_titlecolorstring_diselect;
@property(nonatomic, retain) NSString *tabbar_imagecolorstring_diselect;
@property(nonatomic, retain) UIColor *cell_statusLabel_color;
@property(nonatomic, retain) UIColor *nav_bar_color;
@property(nonatomic, retain) UIColor *navbar_titlecolor_didselect;
@property(nonatomic, retain) UIColor *navbar_titlecolor_selected;

+ (ColorStyleConfig *)sharedColorStyleConfig;
@end
