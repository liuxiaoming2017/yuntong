//
//  YZUserModel.h
//  YouzaniOSDemo
//
//  Created by 益达 on 15/12/1.
//  Copyright (c) 2015年 张伟. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YZUserModel : NSObject

@property (copy, nonatomic) NSString *userID;
@property (copy, nonatomic) NSString *userName;
@property (copy, nonatomic) NSString *nickName;
@property (copy, nonatomic) NSString *gender;
@property (copy, nonatomic) NSString *telePhone;
@property (copy, nonatomic) NSString *avatar;

/**
 *  将YZUserModel数据模型转化成字典格式
 *
 *  @param userInfo 数据模型
 *
 *  @return 字典格式的数据模型
 */
+ (NSDictionary *)transformUserModelToDictionary:(YZUserModel *) userInfo;

@end
