//
//  Author.h
//  FounderReader-2.5
//
//  Created by lihuiguo on 15/10/22.
//
//

#import <Foundation/Foundation.h>

@interface Author : NSObject

@property(nonatomic,assign) NSInteger authorId;
@property(nonatomic,retain) NSString *authorName;
@property(nonatomic,retain) NSString *authorImageUrl;
@property(nonatomic,retain) NSString *authorDuty;
@property(nonatomic,retain) NSString *authorDescription;
@property(nonatomic,assign) NSInteger articleCount;
@property(nonatomic,assign) NSInteger fansCount;

@property(nonatomic,assign) BOOL isAttention;

+ (Author *)authorFromDict:(NSDictionary *)dict;
@end
