//
//  GreatestCommentCell.h
//  FounderReader-2.5
//
//  Created by ld on 14-8-1.
//
//

#import "CommentCell.h"


@interface GreatestCommentCell : CommentCell

-(void)greatAnimate:(UIButton *)sender;


- (void)updateWithModel:(Comment *)comment articleType:(ArticleType)articleType;
- (void)updateWithModel:(Comment *)comment authorID:(NSNumber *)authorID articleType:(ArticleType)articleType;;

@end
