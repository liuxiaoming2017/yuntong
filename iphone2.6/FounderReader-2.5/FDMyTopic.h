//
//  FDMyTopic.h
//  FounderReader-2.5
//
//  Created by Julian on 2017/5/5.
//
//

#import <Foundation/Foundation.h>
#import <MJExtension/MJExtension.h>

@interface FDMyTopic : NSObject

@property (nonatomic,readonly,strong)NSNumber *discussID;
@property (nonatomic,copy)NSString *content;
@property (nonatomic,readonly,copy)NSString *createTime;
@property (nonatomic,strong)NSNumber *praiseCount;
@property (nonatomic,readonly,strong)NSNumber *commentCount;
@property (nonatomic,readonly,strong)NSNumber *topicID;
@property (nonatomic,copy)NSString *title;
@property (nonatomic,strong)NSNumber *discussStatus;
@property (nonatomic,copy)NSString *reason;
@property (nonatomic,readonly,strong)NSDictionary *attUrls;
@property (nonatomic,strong)NSArray *pics;

@property (copy, nonatomic) NSMutableAttributedString *attrTitle;
@property (assign, nonatomic) CGFloat titleH;

@property (copy, nonatomic) NSMutableAttributedString *attrContent;
@property (assign, nonatomic) CGFloat contentH;

@property (assign, nonatomic) CGFloat imagesH;

@property (assign,nonatomic) CGFloat cellHeight;

@property (assign, nonatomic) BOOL isHeader;

@end
