//
//  GreatestCommentPageController.h
//  FounderReader-2.5
//
//  Created by ld on 14-8-1.
//
//

#import "CommentPageController.h"

@interface GreatestCommentPageController : CommentPageController

@property (nonatomic, retain) UIView *hudView;
@property (nonatomic, assign) BOOL isLiveVideoType;
@property (nonatomic, assign) int isSeeRoot;


- (void)reloadTableView;

@end
