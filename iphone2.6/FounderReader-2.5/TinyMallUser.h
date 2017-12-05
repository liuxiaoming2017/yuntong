//
//  TinyMallUser.h
//  FounderReader-2.5
//
//  Created by Julian on 2016/11/7.
//
//

#import <Foundation/Foundation.h>
#import "YZUserModel.h"

@interface TinyMallUser : NSObject

@property (copy, nonatomic) NSString *userId;
@property (copy, nonatomic) NSString *gender;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *telephone;
@property (copy, nonatomic) NSString *avatar;

@property (assign, nonatomic) BOOL isLogined; /* 是否登录过有赞 */


+ (instancetype)sharedManage;

//数据格式转换
+ (YZUserModel *)modelWithUser:(TinyMallUser *)model;

@end
