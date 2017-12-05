//
//  EGORefreshTableHeaderView.m
//  Demo
//
//  Created by Devin Doty on 10/14/09October14.
//  Copyright 2009 enormego. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "EGORefreshTableHeaderView.h"


#define TEXT_COLOR	 [UIColor colorWithRed:87.0/255.0 green:108.0/255.0 blue:137.0/255.0 alpha:1.0]
#define FLIP_ANIMATION_DURATION 0.01f


@interface EGORefreshTableHeaderView (Private)
- (void)setState:(EGOPullRefreshState)aState;
@end

@implementation EGORefreshTableHeaderView

@synthesize delegate=_delegate;


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = [UIColor clearColor];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, frame.size.height - 16.0f, self.frame.size.width, 20.0f)];
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        label.font = [UIFont fontWithName:[Global fontName] size:12.0f];
        label.textColor = [UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:1];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:label];
        _lastUpdatedLabel = label;
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, frame.size.height - 35.0f, self.frame.size.width, 20.0f)];
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        label.font=[UIFont fontWithName:[Global fontName] size:12];
        label.textColor = [UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:1];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:label];
        _statusLabel=label;
        
        CALayer *layer = [CALayer layer];
        layer.frame = CGRectMake(25.0f, frame.size.height - 65.0f+16.0f, 20.0f, 36.0f);
        layer.contentsGravity = kCAGravityResizeAspect;
        layer.contents = (id)[UIImage imageNamed:@"blue_arrow"].CGImage;
        
        if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
            layer.contentsScale = [[UIScreen mainScreen] scale];
        }
        
        [[self layer] addSublayer:layer];
        _arrowImage = layer;
        [self setState:EGOOPullRefreshNormal];
    }
    
    return self;
    
}


#pragma mark -
#pragma mark Setters

- (void)refreshLastUpdatedDate {
    
    if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDataSourceLastUpdated:)]) {
        
        NSDate *date = [_delegate egoRefreshTableHeaderDataSourceLastUpdated:self];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setAMSymbol:NSLocalizedString(@"上午",nil)];
        [formatter setPMSymbol:NSLocalizedString(@"下午",nil)];
        [formatter setDateFormat:@"yyyy-MM-dd hh:mm a"];
        _lastUpdatedLabel.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"上次刷新",nil), [formatter stringFromDate:date]];
        [[NSUserDefaults standardUserDefaults] setObject:_lastUpdatedLabel.text forKey:@"EGORefreshTableView_LastRefresh"];
        _lastUpdatedLabel.hidden = NO;
        [[NSUserDefaults standardUserDefaults] synchronize]; 
        
    } else {
        
        _lastUpdatedLabel.text = nil;
        
    }
    
}

- (void)setState:(EGOPullRefreshState)aState{
    
    switch (aState) {
        case EGOOPullRefreshPulling:
            
            _statusLabel.text = NSLocalizedString(@"松开刷新...",nil);
            
            [CATransaction begin];
            [CATransaction setAnimationDuration:FLIP_ANIMATION_DURATION];
            _arrowImage.transform = CATransform3DIdentity;
            [CATransaction commit];
            
            break;
        case EGOOPullRefreshNormal:
            
            if (_state == EGOOPullRefreshPulling) {
                [CATransaction begin];
                [CATransaction setAnimationDuration:FLIP_ANIMATION_DURATION];
                _arrowImage.transform = CATransform3DMakeRotation((M_PI / 180.0) * 180.0f, 0.0f, 0.0f, 1.0f);
                [CATransaction commit];
            }
            
            _statusLabel.text = NSLocalizedString(@"下拉刷新...",nil);
            [_activityView stopAnimating];
            [CATransaction begin];
            [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
            _arrowImage.hidden = NO;
            _arrowImage.transform = CATransform3DMakeRotation((M_PI / 180.0) * 180.0f, 0.0f, 0.0f, 1.0f);
            [CATransaction commit];
            
            [self refreshLastUpdatedDate];
            
            break;
        case EGOOPullRefreshLoading:
            
            _statusLabel.text = NSLocalizedString(@"正在加载...", nil);
            [_activityView startAnimating];
            [CATransaction begin];
            [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
            _arrowImage.hidden = YES;
            [CATransaction commit];
            
            break;
        default:
            break;
    }
    
    _state = aState;
}


#pragma mark -
#pragma mark ScrollView Methods

- (void)egoRefreshScrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (_state == EGOOPullRefreshLoading) {
        
        CGFloat offset = MAX(scrollView.contentOffset.y * -1, 0);
        offset = MIN(offset, 60);
        scrollView.contentInset = UIEdgeInsetsMake(offset, 0.0f, 0.0f, 0.0f);
        
    } else{
        
        BOOL _loading = NO;
        if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDataSourceIsLoading:)]) {
            _loading = [_delegate egoRefreshTableHeaderDataSourceIsLoading:self];
        }
        
        if (_state == EGOOPullRefreshPulling && scrollView.contentOffset.y > -REFRESH_HEIGHT && scrollView.contentOffset.y < 0.0f && !_loading) {
            [self setState:EGOOPullRefreshNormal];
        } else if (_state == EGOOPullRefreshNormal && scrollView.contentOffset.y < -REFRESH_HEIGHT && !_loading) {
            [self setState:EGOOPullRefreshPulling];
        }
        
        if (scrollView.contentInset.top != 0) {
            scrollView.contentInset = UIEdgeInsetsZero;
        }
        
    }
    
}

- (void)egoRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView {
    
    BOOL _loading = NO;
    if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDataSourceIsLoading:)]) {
        _loading = [_delegate egoRefreshTableHeaderDataSourceIsLoading:self];
    }
    if (scrollView.contentOffset.y <= - REFRESH_HEIGHT) {
        
        if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDidTriggerRefresh:)]) {
            [_delegate egoRefreshTableHeaderDidTriggerRefresh:self];
        }
        
        [self setState:EGOOPullRefreshLoading];
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.5];
        scrollView.contentInset = UIEdgeInsetsMake(60.0f, 0.0f, 0.0f, 0.0f);
        [UIView commitAnimations];
    }
}

- (void)egoRefreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView {	
    
    [UIView beginAnimations:nil context:@"up"];
    [UIView setAnimationDuration:.1];
    scrollView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
    [UIView commitAnimations];
    
    [self setState:EGOOPullRefreshNormal];
    NSLog(@"%f",scrollView.contentInset.top);
    NSLog(@"%f",scrollView.contentInset.top);
    
}

- (void)egoRefreshScrollViewWillBeginDragging:(UIScrollView *)scrollView{
    
}
#pragma mark -
@end
