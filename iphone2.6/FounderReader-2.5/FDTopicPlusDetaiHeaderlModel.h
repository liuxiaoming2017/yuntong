//
//  FDTopicPlusDetailModel.h
//  FounderReader-2.5
//
//  Created by snitsky on 2017/5/5.
//
//

#import <Foundation/Foundation.h>
#import <MJExtension/MJExtension.h>

typedef NS_ENUM(NSUInteger, FDTopicPlusAuditStatus) {
    FDTopicPlusAuditNeeded   = 1,
    FDTopicPlusAuditUnneeded = 2,
};

@interface FDTopicPlusDetaiHeaderlModel : NSObject

@property (strong, nonatomic) NSNumber *topicID;
@property (copy, nonatomic) NSString *topicPlusDescription;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *imgUrl;
@property (copy, nonatomic) NSString *endTime;
@property (strong, nonatomic) NSNumber *interestCount;
@property (assign, nonatomic) BOOL isFollow;
@property (assign, nonatomic) FDTopicPlusAuditStatus auditStatus;
@property (strong, nonatomic) NSNumber *publishStatus;

@end
