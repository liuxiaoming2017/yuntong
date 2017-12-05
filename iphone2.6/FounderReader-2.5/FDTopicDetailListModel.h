//
//  FDTopicDetailListModel.h
//  FounderReader-2.5
//
//  Created by julian on 2017/6/20.
//
//

#import <Foundation/Foundation.h>

@interface FDTopicDetailListModel : NSObject

@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *imgUrl;
@property (strong, nonatomic) NSNumber *discussID;
@property (copy, nonatomic) NSString *content;
@property (strong, nonatomic) NSNumber *uid;
@property (copy, nonatomic) NSString *createTime;
@property (copy, nonatomic) NSString *endTime;
@property (nonatomic,readonly,strong)NSDictionary *attUrls;
@property (nonatomic,strong)NSMutableArray *pics;
@property (strong, nonatomic) NSNumber *praiseCount;
@property (strong, nonatomic) NSNumber *commentCount;
@property (strong, nonatomic) NSNumber *topicID;
@property (copy, nonatomic) NSString *nickName;
@property (copy, nonatomic) NSString *faceUrl;
@property (assign, nonatomic) BOOL isHeader;

@property (copy, nonatomic) NSMutableAttributedString *attrContent;
@property (assign, nonatomic) CGFloat contentH;

@property (assign, nonatomic) CGFloat imagesH;

@property (assign, nonatomic) CGFloat cellHeight;
@property (assign, nonatomic) CGSize imagesSizeByOne;
@property (assign, nonatomic) CGSize imagesSizeByCaculate;

@end
