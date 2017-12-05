//
//  PersonMenu.h
//  FounderReader-2.5
//
//  Created by mac on 2017/6/19.
//
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSUInteger, moreType) {
    moreType_default,
};
@interface PersonMenu : NSObject
@property (nonatomic,strong)NSString * name;
@property (nonatomic,strong)NSString * image;
@property (nonatomic,assign)moreType moretype;
@property (nonatomic,copy)NSString * class;
+(instancetype)initWith:(NSDictionary*)dict;
@end
