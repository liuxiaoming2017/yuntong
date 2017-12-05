//
//  MyInform.h
//  FounderReader-2.5
//
//  Created by ld on 14-8-22.
//
//

#import <Foundation/Foundation.h>

@interface MyInform : NSObject

@property(nonatomic,retain) NSString *informId;
@property(nonatomic,retain) NSString *title;
@property(nonatomic,retain) NSString *content;
@property(nonatomic,retain) NSString *userName;
@property(nonatomic,retain) NSString *phone;
@property(nonatomic,retain) NSString *email;
@property(nonatomic,retain) NSString *createTime;
@property(nonatomic,retain) NSString *sourceDevice;
@property(nonatomic,retain) NSString *attachmentAmount;
@property(nonatomic,retain) NSString *userId;
@property(nonatomic,retain) NSArray *attachments;


+ (NSArray *)myInformsFromArray:(NSArray *)array;
@end
