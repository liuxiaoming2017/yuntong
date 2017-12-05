//
//  GuoPageController.h
//  FounderReader-2.5
//
//  Created by 郭 莉慧 on 13-4-20.
//
//

#import <UIKit/UIKit.h>

@interface LinePageController : UIView

@property(nonatomic,assign) NSInteger totalNum;
@property(nonatomic,assign) NSInteger currentIndex;

- (id)initWithFrame:(CGRect)frame andTotalNumber:(NSInteger)totalNum;
-(void)updateSubView;
@end
