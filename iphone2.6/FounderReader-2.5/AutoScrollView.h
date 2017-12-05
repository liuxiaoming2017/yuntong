//
//  AutoScrollView.h
//  FounderReader-2.5
//
//  Created by Julian on 16/8/19.
//
//

#import <UIKit/UIKit.h>

@protocol autoScrollviewDelegate <NSObject>
@optional
- (void)gotoDetail:(NSInteger)num;
- (void)gotoDetail;
@end

@interface AutoScrollView : UIScrollView

@property(nonatomic, assign) id<autoScrollviewDelegate> autoDelegate;
@property (nonatomic, strong)NSArray *arrData;
@property (nonatomic, strong)NSArray *articleArr;

- (instancetype)initWithFrame:(CGRect)frame array:(NSArray *)array articleArr:(NSArray *)articleArr;

- (void)titleClick:(UITapGestureRecognizer*)tap;

@end
