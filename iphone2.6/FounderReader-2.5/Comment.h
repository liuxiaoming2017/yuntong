//
//  Comment.h
//  FounderReader
//
//  Created by he jinbo on 11-6-21.
//  Copyright 2011年 founder. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Comment : NSObject {
    
    NSInteger ID;	        //评论ID
	NSString  *content;     //评论内容
    NSString  *userName;    //评论人
    NSString  *commentTime; //评论时间
    NSInteger greatCount;
    NSArray *imgUrl;
    NSString *userIcon;
}
// 新空云-字段
@property (nonatomic, assign) NSInteger ID;              //评论ID
@property (nonatomic, retain) NSString  *content;        //评论内容
@property (nonatomic, retain) NSString  *userName;       //匿名用户
@property (nonatomic, retain) NSString  *commentTime;    //创建时间
@property (nonatomic, assign) NSInteger greatCount;      //点赞数
@property (nonatomic, retain) NSString  *articleId;      //稿件ID
@property (nonatomic, retain) NSString  *articleTitle;   //稿件标题
@property (nonatomic, retain) NSString  *articleType;    //稿件类型
@property (nonatomic, retain) NSString  *parentUserName; //父评论用户昵称
@property (nonatomic, retain) NSString  *parentContent;  //父评论内容
@property (nonatomic, assign) NSInteger parentID;        //父评论ID
@property (nonatomic, assign) NSInteger parentUserID;    //父评论用户ID
@property (nonatomic, assign) NSInteger ueserID;         //用户ID

// 旧字段-不可删
@property (nonatomic, retain) NSArray *topDiscuss;       //

@property (nonatomic, retain) NSArray *UpDiscuss;       //

@property (nonatomic, retain) NSArray  *imgUrl;          //
@property (nonatomic, retain) NSString  *userIcon;       //
@property (nonatomic, retain) NSData  *dataIcon;       //
+ (NSMutableArray *)commentsFromArray:(NSArray *)array;

@end
