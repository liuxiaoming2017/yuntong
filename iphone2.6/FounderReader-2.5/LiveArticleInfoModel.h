//
//  LiveArticleInfoModel.h
//  FounderReader-2.5
//
//  Created by yanbf on 2016/10/26.
//
//

#import <Foundation/Foundation.h>

@interface LiveArticleInfoModel : NSObject
@property (nonatomic, strong) NSString *liveTitle;
@property (nonatomic, strong) NSString *liveStartTime;
@property (nonatomic, strong) NSString *liveEndTime;
@property (nonatomic, assign) NSInteger countClick;//参与人数

+ (instancetype)articleInfoFromeDiction:(NSDictionary *)dict;
- (instancetype)initArticleInfoWithDict:(NSDictionary *)dict;
@end
