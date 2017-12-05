//
//  FDRefreshHeader.m
//  FounderReader-2.5
//
//  Created by snitsky on 2016/12/12.
//
//

#import "FDRefreshHeader.h"
#define TEXT_COLOR	 [UIColor colorWithRed:87.0/255.0 green:108.0/255.0 blue:137.0/255.0 alpha:1.0]

@implementation FDRefreshHeader

- (void)prepare
{
    [super prepare];
    
    NSMutableArray *refreshingImages = [NSMutableArray array];
    for (NSUInteger i = 1; i<=16; i++) {
        UIImage *image = [UIImage imageNamed:@"blue_arrow"];
        [refreshingImages addObject:image];
    }
    [self setImages:refreshingImages duration:0.7 forState:MJRefreshStateIdle];
    [self setImages:refreshingImages duration:0.7 forState:MJRefreshStatePulling];
    [self setImages:refreshingImages duration:0.7 forState:MJRefreshStateRefreshing];
    self.lastUpdatedTimeLabel.textColor = [UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:1];
    self.stateLabel.textColor = [UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:1];
    self.lastUpdatedTimeLabel.font = [UIFont fontWithName:[Global fontName] size:12];
    self.stateLabel.font = [UIFont fontWithName:[Global fontName] size:12];
    [self setTitle:NSLocalizedString(@"下拉刷新...",nil) forState:MJRefreshStateIdle];
}

- (void)placeSubviews {
    [super placeSubviews];
    if (kSWidth == 320) {
        self.gifView.mj_x = -30;
    } else if (kSWidth == 375) {
        self.gifView.mj_x = -50;
    } else {
        self.gifView.mj_x = -70;
    }
    
}

@end
