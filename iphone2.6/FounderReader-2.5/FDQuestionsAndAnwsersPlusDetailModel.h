//
//  RemarksCellHeightModel.h
//  EasyFlowerCustomer
//
//  Created by 罗金 on 16/2/26.
//  Copyright © 2016年 chenglin.zhao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FDQuestionsAndAnwsersPlusDetailModel : NSObject

@property (strong, nonatomic) NSNumber *aid;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *questionDescription;
@property (copy, nonatomic) NSString *tag;
@property (copy, nonatomic) NSString *beginTime;
@property (copy, nonatomic) NSString *imgUrl;
@property (copy, nonatomic) NSString *endTime;
@property (strong, nonatomic) NSNumber *authorID;
@property (copy, nonatomic) NSString *authorName;
@property (copy, nonatomic) NSString *authorTitle;
@property (copy, nonatomic) NSString *authorDesc;
@property (copy, nonatomic) NSString *authorFace;
@property (copy, nonatomic) NSString *createTime;
@property (copy, nonatomic) NSString *modifyTime;
@property (copy, nonatomic) NSString *askTime;
@property (strong, nonatomic) NSNumber *publishStatus;
@property (strong, nonatomic) NSNumber *askCount;
@property (strong, nonatomic) NSNumber *interestCount;
@property (assign, nonatomic) BOOL isFollow;

@end
