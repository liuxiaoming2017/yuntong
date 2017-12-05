//
//  TopDiscussmodel.m
//  FounderReader-2.5
//
//  Created by 周志扬 on 15/9/2.
//
//

#import "TopDiscussmodel.h"
#import "attactmentmodel.h"
#import "NSDate+Extension.h"
@implementation TopDiscussmodel
//@synthesize attachments,userID,user,atturl,publishtime,fileId,countPraise;
//@synthesize userIcon,content;
//-(void)dealloc
//{
//    DELETE(attachments);
//    DELETE(user);
//    DELETE(atturl);
//    DELETE(publishtime);
//    DELETE(content);
//    DELETE(userIcon);
//    DELETE(atturl);
//    [super dealloc];
//}
+(NSArray *)liveFromArray:(NSArray *)liveArray
{
    NSMutableArray *arr = [[NSMutableArray alloc] initWithCapacity:[liveArray count]];
    for (NSDictionary *dict in liveArray) {
        TopDiscussmodel *topmodel = [[TopDiscussmodel alloc] init];
        topmodel.content = [dict objectForKey:@"content"];
        topmodel.title = [dict objectForKey:@"title"];
        topmodel.publishTime = [dict objectForKey:@"publishTime"];
         topmodel.fileID = [[dict objectForKey:@"fileID"] intValue];
        topmodel.userName = [dict objectForKey:@"userName"];
        topmodel.attachments = [dict objectForKey:@"attachments"];
        topmodel.userType = [[dict objectForKey:@"userType"] intValue];
        topmodel.liveStatus = [[dict objectForKey:@"liveStatus"] intValue];
        topmodel.pics = [topmodel.attachments objectForKey:@"pics"];
        topmodel.videos  = [topmodel.attachments objectForKey:@"videos"];
        topmodel.videoPics  = [topmodel.attachments objectForKey:@"videoPics"];

        [arr addObject:topmodel];
    }
    return arr;
}
-(instancetype)initWithDict:(NSDictionary *)dict
{
    if (self = [super init]) {
        self.content = [dict objectForKey:@"content"];
        self.title = [dict objectForKey:@"title"];
        self.publishTime = [dict objectForKey:@"publishTime"];
        self.fileID = [[dict objectForKey:@"fileID"] intValue];
        self.userName = [dict objectForKey:@"userName"];
        self.attachments = [dict objectForKey:@"attachments"];
        self.userType = [[dict objectForKey:@"userType"] intValue];
        self.liveStatus = [[dict objectForKey:@"liveStatus"] intValue];
        if (![self.attachments isKindOfClass:[NSNull class]]) {
            self.pics = [self.attachments objectForKey:@"pics"];
            self.videos  = [self.attachments objectForKey:@"videos"];
            self.videoPics  = [self.attachments objectForKey:@"videoPics"];
        }
    }
    return self;
}
+(instancetype)seeWithDict:(NSDictionary *)dict
{
    return [[self alloc] initWithDict:dict];
}
-(NSString *)publishtime
{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
//    NSDate *createDate = [formatter dateFromString:publishtime];
    NSDate *createDate = [formatter dateFromString:self.publishTime];
    
    formatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US"];
    
    //    //取出当前时间
    NSDate *currentDate = [NSDate date];
    
    //拿着当前时间与publishtime进行一个对比
    
    //    if (是今年) {
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
    
}
+ ( instancetype)topSeeDirectFromDiction:(NSDictionary *)dict
{
    return [[self alloc] initTopWithDict:dict];
}
- (instancetype)initTopWithDict:(NSDictionary *)dict
{
    if (self = [super init]) {
        self.content = [dict objectForKey:@"content"];
        self.title = [dict objectForKey:@"title"];
        NSDictionary *attachments = [dict objectForKey:@"attachments"];
        //专题顶部主View只是图片，不会是视频
        if (![attachments isKindOfClass:[NSNull class]]) {
            self.picImage = [[attachments objectForKey:@"pics"] lastObject];
        }
    }
    return self;
}
@end
