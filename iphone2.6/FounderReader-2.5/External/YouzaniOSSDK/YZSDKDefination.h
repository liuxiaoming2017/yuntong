//
//  YZSDKDefination.h
//  CustomerNetwork
//
//  Created by 益达 on 15/11/19.
//  Copyright © 2015年 张伟. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSMutableDictionary+NullObject.h"


#ifndef YZSDKDefination_h
#define YZSDKDefination_h

static NSInteger YZNetworkErrorCode = -10000;
static NSString * YZNetworkErrorMessage = @"数据获取失败";

typedef void (^OpenServiceCallBack)(NSDictionary *response, NSError *error);


static NSString* const errorUserInfo = @"获取错误的用户信息";
static NSString* const errorUserInfoFormat = @"获取错误格式的用户信息";



#endif /* YZSDKDefination_h */
