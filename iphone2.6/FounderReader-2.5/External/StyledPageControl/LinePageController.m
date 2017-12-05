//
//  GuoPageController.m
//  FounderReader-2.5
//
//  Created by 郭 莉慧 on 13-4-20.
//
//

#import "LinePageController.h"

@interface LinePageController()
@property(nonatomic,assign) float pageLineWidth;
@property(nonatomic,retain) UIView * frontLineView;
@end

@implementation LinePageController
@synthesize frontLineView = _frontLineView;
@synthesize totalNum = _totalNum;
@synthesize currentIndex = _currentIndex;
@synthesize pageLineWidth = _pageLineWidth;

- (id)initWithFrame:(CGRect)frame andTotalNumber:(NSInteger)totalNum
{
    self = [super initWithFrame:frame];
    if (self) {
    
        if (totalNum)
            _pageLineWidth = self.bounds.size.width/totalNum;
        self.totalNum = totalNum;
        
        self.backgroundColor = [UIColor blackColor];
        [self initSubview];
    }
    return self;
}

-(void)dealloc
{
    self.frontLineView = nil;
//    [super dealloc];
}

-(void)initSubview
{
    if (_frontLineView) {
        [self.frontLineView removeFromSuperview];
    }
    _frontLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.pageLineWidth, self.bounds.size.height)];
    self.frontLineView.backgroundColor = [UIColor redColor];
    [self addSubview:self.frontLineView];
}

-(void)updateSubView
{
    NSInteger x = self.pageLineWidth *self.currentIndex;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    self.frontLineView.frame = CGRectMake(x, 0, self.pageLineWidth, self.bounds.size.height);
    [UIView commitAnimations];
 
}
@end
