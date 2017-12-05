//
//  OpenTradeServiceProtocol.h
//  CustomerNetwork
//
//  Created by 益达 on 15/11/19.
//  Copyright (c) 2015年 张伟. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YZSDKDefination.h"

@protocol OpenTradeServiceProtocol <NSObject>
/** 
*  获取单笔订单的信息
*  http://open.koudaitong.com/doc/api?method=kdt.trade.get[文档说明]
*  @param field            过滤显示的字段
*  @param orderNO          订单的编号
*  @param subTradePageNO   订单内部商品页
*  @param subTradePageSize 订单内部商品每个页面显示的条数
*/

- (void) getTradeField:(NSString *)field
               orderNO:(NSString *)orderNO
        subTradePageNo:(NSString *)subTradePageNO
      subTradePageSize:(NSString *)subTradePageSize
              callback:(OpenServiceCallBack) callback;

@end
