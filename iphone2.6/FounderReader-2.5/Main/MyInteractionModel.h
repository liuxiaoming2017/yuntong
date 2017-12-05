//
//  MyInteractionModel.h
//  FounderReader-2.5
//
//  Created by yanbf on 16/8/17.
//
//

#import <Foundation/Foundation.h>

@interface MyInteractionModel : NSObject

@property (nonatomic, copy) NSString *icon;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *controllerClass;

+ (instancetype)interactionWithDict:(NSDictionary *)dict;
@end
