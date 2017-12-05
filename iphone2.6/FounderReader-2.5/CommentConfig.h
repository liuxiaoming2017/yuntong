//
//  CommentConfig.h
//  FounderReader-2.5
//
//  Created by chenfei on 5/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommentConfig : NSObject

@property(nonatomic, retain) UIColor *commentBgColor;
@property(nonatomic, retain) UIColor *commentTextViewBorderColor;
@property(nonatomic, assign) UIEdgeInsets cellEdge;
@property(nonatomic, assign) CGFloat usernameContentSpace;
@property(nonatomic, retain) UIColor *usernameTextColor;
@property(nonatomic, assign) CGFloat usernameFontSize;
@property(nonatomic, retain) UIColor *contentTextColor;
@property(nonatomic, assign) CGFloat contentFontSize;
@property(nonatomic, retain) UIColor *oddCellBgColor;
@property(nonatomic, retain) UIColor *evenCellBgColor;
@property(nonatomic, assign) CGFloat moreCellHeight;
@property(nonatomic, retain) NSString *moreCellTitle;
@property(nonatomic, assign) CGFloat moreCellTitleFontSize;
@property(nonatomic, retain) UIColor *moreCellTitleColor;
@property(nonatomic, retain) NSString *defaultNickName;
@property(nonatomic, assign) BOOL     commentvisiable;
+ (CommentConfig *)sharedCommentConfig;

@end
