//
//  MyInteractionModel.m
//  FounderReader-2.5
//
//  Created by yanbf on 16/8/17.
//
//

#import "MyInteractionModel.h"

@implementation MyInteractionModel

+ (instancetype)interactionWithDict:(NSDictionary *)dict {
    id obj = [[self alloc] init];
    [obj setValuesForKeysWithDictionary:dict];
    return obj;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {}

@end
