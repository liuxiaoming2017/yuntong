//
//  FounderIntegralRequest.h
//  FounderReader-2.5
//
//  Created by Julian on 16/5/26.
//
//

#import "HttpRequest.h"

typedef void(^Blo)(NSDictionary *integralDict);

@interface FounderIntegralRequest : HttpRequest
{
    Blo integralBlock;
}

@property (nonatomic, assign) NSInteger IntegralArrCount;

/**
 *  @brief 积分入库
 *
 *  @param eType 行为类型
 */
- (void)addIntegralWithUType:(NSInteger)uType integralBlock:(Blo)integralBlock;

/**
 *  @brief 查询总积分
 */
- (void)getAllIntegral;

- (void)setIntegralBlock:(Blo)aIntegralBlock;

/**
 *  是否为同一天
 */
- (BOOL)isSameDay:(NSDate*)date1 date2:(NSDate*)date2;

@end
