//
//  FDMyAskModel.h
//  FounderReader-2.5
//
//  Created by snitsky on 2017/3/10.
//
//

#import <Foundation/Foundation.h>
#import <MJExtension/MJExtension.h>

typedef NS_ENUM(NSUInteger, FDAskStatus) {
    FDAskStatusWaitingForReview,
    FDAskStatusRelease,
    FDAskStatusDeleted,
};

@interface FDAskModel : NSObject<NSCopying, NSMutableCopying>

@property (strong, nonatomic) NSNumber *qid;
/**
 提问内容
 */
@property (copy, nonatomic) NSString *content;
@property (copy, nonatomic) NSString *createTime;
@property (copy, nonatomic) NSString *answerTime;
@property (assign, nonatomic) FDAskStatus askStatus;
@property (copy, nonatomic) NSString *uid;
@property (copy, nonatomic) NSString *answerContent;
@property (strong, nonatomic) NSNumber *praiseCount;
@property (strong, nonatomic) NSNumber *aid;
@property (strong, nonatomic) NSNumber *authorID;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *askbarTopImg;
@property (copy, nonatomic) NSString *askFaceUrl;
@property (copy, nonatomic) NSString *answerFaceUrl;
@property (copy, nonatomic) NSString *answerName;
@property (copy, nonatomic) NSString *askUserName;

@property (copy, nonatomic) NSMutableAttributedString *askAttrContent;
@property (copy, nonatomic) NSMutableAttributedString *answerAttrContent;
@property (assign, nonatomic) CGFloat askContentHeight;
@property (assign, nonatomic) CGFloat answerContentHeight;
@property (assign, nonatomic) CGFloat askOriginalContentHeight;
@property (assign, nonatomic) CGFloat answerOriginalContentHeight;
@property (assign, nonatomic) CGFloat cellHeight;
@property (nonatomic, assign)BOOL isShowAllMore;

/*
 * 计算cell高度
 * itemShowStatus : 问答内容展示状态
 */
- (CGFloat)cellHeight:(struct ItemShowStatus)itemShowStatus;

@end
