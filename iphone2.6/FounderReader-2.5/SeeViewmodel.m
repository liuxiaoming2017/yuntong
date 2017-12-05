//
//  SeeViewmodel.m
//  FounderReader-2.5
//
//  Created by 周志扬 on 15/8/25.
//
//

#import "SeeViewmodel.h"
#import "TopDiscussmodel.h"
#import "NSDate+Extension.h"
@implementation SeeViewmodel
{
    NSMutableArray *arr;
}
@synthesize user,userID,content,title,publishtime,attmodel,attachments;
@synthesize location,distance;

#pragma mark copying协议的方法
- (id)copyWithZone:(NSZone *)zone {
    SeeViewmodel *copy = [[[self class] allocWithZone:zone] init];
    
    // 拷贝名字给副本对象
    copy.content = self.content;
    copy.title = self.title;
    copy.publishtime = self.publishtime;
    copy.fileld = self.fileld;
    copy.user = self.user;
    copy.userID = self.userID;
    copy.distance = self.distance;
    copy.location = self.location;
    copy.attachments = self.attachments;
    copy.countDiscuss = self.countDiscuss;
    copy.userIcon = self.userIcon;
    copy.countDiscuss = self.countDiscuss;
    copy.countDiscuss = self.countDiscuss;
    copy.countDiscuss = self.countDiscuss;
    copy.countDiscuss = self.countDiscuss;
    copy.countDiscuss = self.countDiscuss;
    
    return copy;
}

+(NSMutableArray *)seeFromArray:(NSArray *)dataArray
{
    NSMutableArray *arr = [[NSMutableArray alloc] initWithCapacity:[dataArray count]];
    for (NSDictionary *dict in dataArray) {
        SeeViewmodel *semodel = [[SeeViewmodel alloc] init];
        semodel.content = [dict objectForKey:@"content"];
        semodel.title = [dict objectForKey:@"title"];
        semodel.publishtime = [dict objectForKey:@"publishtime"];
        semodel.fileld = [[dict objectForKey:@"fileId"] intValue];
        semodel.user = [dict objectForKey:@"user"];
        semodel.userID = [[dict objectForKey:@"userID"] intValue];
        semodel.distance = [dict[@"distance"] intValue];
        semodel.location = dict[@"location"];
        if ([semodel.location isKindOfClass:[NSNull class]]||[semodel.location isEqualToString:@"(null)"]) {
            semodel.location = @"";
        }
        semodel.attachments = [dict objectForKey:@"attachments"];
        semodel.countDiscuss = [[dict objectForKey:@"countDiscuss"] intValue];
        semodel.userIcon = [dict objectForKey:@"userIcon"];
        for (NSDictionary *attachment in semodel.attachments ) {
            attactmentmodel *attmodel  = [[attactmentmodel alloc] init];
            attmodel.thumbnail_pic = [attachment objectForKey:@"url"];
            attmodel.type  = [[attachment objectForKey:@"type"] intValue];
            semodel.attmodel = attmodel;
        }

        [arr addObject:semodel];
    }
    //内存检测
    return arr;

}

-(NSString *)publishtime
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    NSDate *createDate = [formatter dateFromString:publishtime];
    
    formatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US"];
    
    //    //取出当前时间
    NSDate *currentDate = [NSDate date];
    
    //拿着当前时间与publishtime进行一个对比
    
    if ([NSDate isThisYearWithDate:createDate]) {
        //是同一年
        
        //判断是否是今天
        if ([NSDate isTodayWithDate:createDate]) {
            //是今天
            //如果创建时间加上60秒,大于当前时间,代表1分钟之内
            NSDate *resultDate = [createDate dateByAddingTimeInterval:60];
            if ([resultDate compare:currentDate] == NSOrderedDescending) {
                //代表是1分钟之内
                return NSLocalizedString(@"刚刚",nil);
            }else{
                //判断1小时之内
                resultDate = [createDate dateByAddingTimeInterval:3600];
                if ([resultDate compare:currentDate] == NSOrderedDescending) {
                    //代表1小时之内
                    
                    //计算多少分钟前
                    NSTimeInterval interval = [currentDate timeIntervalSinceDate:createDate];
                    //分钟数
                    NSInteger intervalMinute = interval/60;
                    return [NSString stringWithFormat:@"%zd%@",intervalMinute,NSLocalizedString(@"分钟前",nil)];
                }else{
                    //几小时前
                    NSTimeInterval interval = [currentDate timeIntervalSinceDate:createDate];
                    //分钟数
                    NSInteger intervalMinute = interval/3600;
                    return [NSString stringWithFormat:@"%zd%@",intervalMinute, NSLocalizedString(@"小时前",nil)];
                }
            }
            //是不是1分钟之内
            
            //是不是1小时之内
        }else{
            //如果是昨天-->昨天 11:11
            if ([NSDate isYesterdayWithDate:createDate]) {
                //不是今天先这么去显示:08-01 15-03
                formatter.dateFormat = [NSString stringWithFormat:@"%@ HH:mm", NSLocalizedString(@"昨天",nil)];
                return [formatter stringFromDate:createDate];
            }else{
                //不是今天先这么去显示:08-01 15-03
                //                    formatter.dateFormat = @"MM-dd HH:mm";
                formatter.dateFormat = @"MM-dd";
                return [formatter stringFromDate:createDate];
            }
        }
    }else{
        //不是今年:2014-05-05 09:17:31
        formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        return [formatter stringFromDate:createDate];
    }
    //内存检测 
}


@end
