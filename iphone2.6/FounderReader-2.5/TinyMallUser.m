//
//  TinyMallUser.m
//  FounderReader-2.5
//
//  Created by Julian on 2016/11/7.
//
//

#import "TinyMallUser.h"
#import "UserAccountDefine.h"

@implementation TinyMallUser

+ (instancetype)sharedManage {
    static TinyMallUser *shareManage = nil;
    static dispatch_once_t once;
    dispatch_once(&once,^{
        shareManage = [[self alloc] init];
        [shareManage setUpUserValue];
    });
    return shareManage;
}

- (void)setUpUserValue
{
    self.gender = @"1";// 1男2女
    self.userId = [Global userId];
    self.name = [Global userInfoByKey:KuserAccountNickName];
    self.telephone = [Global userPhone];
    self.avatar = [Global userInfoByKey:KuserAccountFace];
    self.isLogined = NO;
}

+ (YZUserModel *)modelWithUser:(TinyMallUser *)model {
    YZUserModel *userModel = [YZUserModel new];
    userModel.userID = model.userId;
    userModel.userName = model.name;
    userModel.nickName = model.name;
    userModel.gender = model.gender;
    userModel.avatar = model.avatar;
    userModel.telePhone = model.telephone;
    return userModel;
}


@end
