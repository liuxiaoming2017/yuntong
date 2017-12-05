//
//  FDTopicPlusDetailModel.m
//  FounderReader-2.5
//
//  Created by snitsky on 2017/5/5.
//
//

#import "FDTopicPlusDetaiHeaderlModel.h"

@implementation FDTopicPlusDetaiHeaderlModel

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{
             @"topicPlusDescription" : @"description",
             };
}

/**
 *  当字典转模型完毕时调用
 */
- (void)mj_keyValuesDidFinishConvertingToObject
{
    
}

@end
