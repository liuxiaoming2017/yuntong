//
//  RemarksCellHeightModel.m
//  EasyFlowerCustomer
//
//  Created by 罗金 on 16/2/26.
//  Copyright © 2016年 chenglin.zhao. All rights reserved.
//

#import "FDQuestionsAndAnwsersPlusDetailModel.h"
#import <MJExtension/MJExtension.h>

@implementation FDQuestionsAndAnwsersPlusDetailModel

// 实现这个方法的目的：告诉MJExtension框架模型中的属性名对应着字典的哪个key
+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{
             @"questionDescription" : @"description"
             };
}

@end
