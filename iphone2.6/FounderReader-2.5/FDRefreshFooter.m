//
//  FDRefreshFooter.m
//  FounderReader-2.5
//
//  Created by snitsky on 2016/12/13.
//
//

#import "FDRefreshFooter.h"

@implementation FDRefreshFooter

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)prepare {
    [super prepare];
    [self setTitle:NSLocalizedString(@"加载更多...",nil) forState:MJRefreshStateIdle];
}

@end
