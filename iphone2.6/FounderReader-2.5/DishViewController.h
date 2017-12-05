//
//  DishViewController.h
//  FounderReader-2.5
//
//  Created by 周志扬 on 15/9/28.
//
//

#import "QuestionPageController.h"

@interface DishViewController : QuestionPageController
// 标题
@property (nonatomic, retain) UIView *viewhud;
@property (nonatomic, retain) NSString *dishLabel;
@property (nonatomic, retain) Column *column;
@property (nonatomic, retain) NSDictionary *dicInfo;
@property (nonatomic, retain) NSData *dataVideopic;
@property (nonatomic, retain) NSString *videoPicUrl;
@property (nonatomic, assign) int navStyle;

@end
