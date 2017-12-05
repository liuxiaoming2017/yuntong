//
//  FounderIntegralRequest.m
//  FounderReader-2.5
//
//  Created by Julian on 16/5/26.
//
//

#import "FounderIntegralRequest.h"
#import "AppStartInfo.h"
#import "AppConfig.h"
#import "UserAccountDefine.h"
#import "NSString+Helper.h"
@implementation FounderIntegralRequest

- (void)addIntegralWithUType:(NSInteger)uType integralBlock:(Blo)finishBlock
{
    if (![Global userId].length) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setObject:[NSNumber numberWithBool:NO] forKey:@"success"];
        [dict setObject:@"用户未登录" forKey:@"msg"];
        finishBlock(dict);
        return;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@/api/scoreEvent", [AppConfig sharedAppConfig].serverIf];
    NSURL *url = [NSURL URLWithString:urlString];
    HttpRequest *request = [HttpRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    
    NSString *informString = [NSString stringWithFormat:@"sid=%@&uid=%@&uType=%ld", [AppConfig sharedAppConfig].sid, [Global userId], (long)uType];
    informString = [informString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *informData = [informString dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:informData];
    
    [request setCompletionBlock:^(NSData *data) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers  error:nil];
        finishBlock(dict);
        
    }];
    [request setFailedBlock:^(NSError *error) {
        XYLog(@"积分错误信息:%@", error);
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setObject:[NSNumber numberWithBool:NO] forKey:@"success"];
        [dict setObject:[error description] forKey:@"msg"];
        finishBlock(dict);
    }];
    
    [request startAsynchronous];
}

- (void)getAllIntegral
{
    if (![Global userId].length) {
        return;
    }
    NSString *urlString  = [NSString stringWithFormat:@"%@/api/getUserBaseInfo?sid=%@&uid=%@", [AppConfig sharedAppConfig].serverIf, @"xy", [Global userId]];
    //urlString = @"https://h5test.newaircloud.com/api/getUserBaseInfo?sid=xy&uid=2622757";
    HttpRequest *request = [HttpRequest requestWithURL:[NSURL URLWithString:urlString]];
    [request setCompletionBlock:^(id data) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers  error:nil];
        NSString * fullName = [dict objectForKey:KuserAccountFullName];
        if (![NSString isNilOrEmpty:fullName]) {
            [[NSUserDefaults standardUserDefaults] setObject:KuserAccountFullName forKey:fullName];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        integralBlock(dict);
    }];
    [request setFailedBlock:^(NSError *error) {
        XYLog(@"获取总积分失败");
    }];
    
    [request startAsynchronous];
}

- (void)setIntegralBlock:(Blo)aIntegralBlock
{
    integralBlock = [aIntegralBlock copy];
}

/**
 *  是否为同一天
 */
- (BOOL)isSameDay:(NSDate*)date1 date2:(NSDate*)date2
{
    if (!date1) {
        return false;
    }
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay;
    NSDateComponents* comp1 = [calendar components:unitFlags fromDate:date1];
    NSDateComponents* comp2 = [calendar components:unitFlags fromDate:date2];
    
    return [comp1 day]   == [comp2 day] &&
    [comp1 month] == [comp2 month] &&
    [comp1 year]  == [comp2 year];
}

@end
