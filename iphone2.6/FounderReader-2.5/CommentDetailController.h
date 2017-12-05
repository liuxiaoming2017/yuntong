//
//  CommentDetailController.h
//  FounderReader-2.5
//
//  Created by  on 15/9/4.
//
//

#import "CommentPageController.h"
#import "Comment.h"
#import "CommentPageController.h"
@interface CommentDetailController : UIViewController
{
    Comment *comment;
    NSMutableArray *comments;
    NSMutableArray *RootComments;
    NSIndexPath *comment2Index;
    BOOL hasMore;
}
/**
 *  更多回复数组
 */
@property (nonatomic,retain)NSMutableArray *comments;
/**
 *  父评论数组模型
 */
@property (nonatomic,retain)NSMutableArray *RootComments;
@property (nonatomic,assign)NSInteger ID;
@property (nonatomic,retain) Comment *comment;
/**
 *  父评论索引
 */
@property(nonatomic,retain)NSIndexPath *comment2Index;
@end
