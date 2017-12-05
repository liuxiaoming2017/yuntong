//
//  PersonMenu.m
//  FounderReader-2.5
//
//  Created by mac on 2017/6/19.
//
//

#import "PersonMenu.h"

@implementation PersonMenu
+(instancetype)initWith:(NSDictionary*)dict{
    PersonMenu * menu = [[PersonMenu alloc]init];
    menu.name = NSLocalizedString([dict objectForKey:@"name"], nil);
    menu.image = dict[@"icon"];
    menu.class = dict[@"class"];
    menu.moretype = moreType_default;
    return menu;
}
@end
