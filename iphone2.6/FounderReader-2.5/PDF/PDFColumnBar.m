//
//  PDFColumnBar.m
//  PDFColumnBarDemo
//
//  Created by chenfei on 4/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import "ColorStyleConfig.h"
#import "PDFColumnBar.h"
#import "ColumnBarConfig.h"
#import "UIButton+WebCache.h"
#import "UIView+Extention.h"

@implementation PDFColumnBar

@synthesize scrollView, selectedIndex, dataSource, delegate, enabled;
@synthesize isPDF;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.userInteractionEnabled = YES;
        self.enabled = YES;
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[Global navigationImage]];
        imageView.frame = self.bounds;
        [self addSubview:imageView];
        [self sendSubviewToBack:imageView];

        scrollView = [[UIScrollView alloc] init];
        scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        scrollView.delegate = self;
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.frame = CGRectMake(0, 0, kSWidth, 64);
        [self addSubview:scrollView];
        UILabel *lineLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 63, kSWidth, 1)];
        lineLabel.backgroundColor = [Global navigationLineColor];
        [self addSubview:lineLabel];
        lastSelectIndex = -1;
    }
    return self;
}

- (void)reloadData
{
    if(scrollView.subviews && scrollView.subviews.count > 0){
        
        for (id object in scrollView.subviews) {
            if ([object isKindOfClass:[UIButton class]]) {
                UIButton *btn = (UIButton *)object;
                [btn removeObserver:self forKeyPath:@"selected" context:@"KVO_CONTEXT_SELECTED_CHANGED"];
            }
        }
        
        [scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    if(!self.dataSource)
        return;
    
    int items = [self.dataSource numberOfTabsInColumnBar:self];
    if (items == 0)
        return;
    
    float origin_x = 0;
    origin_x = [self configPDFPageCell:items];
    
    scrollView.contentSize = CGSizeMake(origin_x-10, scrollView.frame.size.height);
    
    self.selectedIndex = selectedIndex;
}

#pragma mark KVO method
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    NSString *conText = (__bridge NSString *)context;
    if ([conText isEqualToString:@"KVO_CONTEXT_SELECTED_CHANGED"]) {
        UIButton *currentButton = (UIButton *)object;
        if ([ColumnBarConfig sharedColumnBarConfig].columnSelectType == 1) {
            //三角
            UIImageView *bottomTag = (UIImageView *)[currentButton viewWithTag:101];
            bottomTag.hidden = !currentButton.selected;
        }else if ([ColumnBarConfig sharedColumnBarConfig].columnSelectType == 2){
            //圆矩形选中背景颜色和未选中背景颜色
            currentButton.backgroundColor = currentButton.selected ?  [ColumnBarConfig sharedColumnBarConfig].columnSelectColor : [ColumnBarConfig sharedColumnBarConfig].columnDisSelectColor;
        }
    }
}

#pragma mark - 读报子栏目
-(float)configPDFPageCell:(NSInteger)buttonNummbers
{
    int x;
    float origin_x;
    if (IS_IPHONE_5) {
        origin_x = 30;

    }else if (IS_IPHONE_6) {
        origin_x = 30;

    }else if (IS_IPHONE_6P) {
        origin_x = 48;

    }else {
        origin_x = 5;

    }

	for(x = 0; x < buttonNummbers; x++) {
		NSString *name = [self.dataSource columnBar:self titleForTabAtIndex:x].columnName;
		
		UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.backgroundColor = [UIColor clearColor];
		[button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];

        int margin = (scrollView.frame.size.width - 80*2 - 10)/2.0;
        if (IS_IPHONE_5) {
            margin = (scrollView.frame.size.width - 80*2 - 10)/2.0;
        }else if (IS_IPHONE_6P){
            margin = (scrollView.frame.size.width - 80*2 - 10)/2.0;
        }
        if ([ColumnBarConfig sharedColumnBarConfig].columnSelectType == 1) {
            button.frame = CGRectMake(margin*kScale+90*x, 20, 80, scrollView.frame.size.height-25);
        }
        else if ([ColumnBarConfig sharedColumnBarConfig].columnSelectType == 2) {
            button.frame = CGRectMake(margin*kScale+90*x, 20+5, 80, scrollView.frame.size.height-25-10);
            button.layer.masksToBounds = YES;
            button.layer.cornerRadius = 5;
        }
        
        //导航条添加底部红色选中标签
        self.bottomTag = [[UIImageView alloc]initWithFrame:CGRectMake((button.bounds.size.width-10)/2,button.bounds.size.height-4, 10, 6)];
        self.bottomTag.image = [UIImage imageNamed:@"icon-point"];

        self.bottomTag.hidden = YES;
        self.bottomTag.tag = 101;
        [button addSubview:self.bottomTag];
        [button addObserver:self forKeyPath:@"selected" options:0 context:@"KVO_CONTEXT_SELECTED_CHANGED"];
        
        button.titleLabel.font = [UIFont systemFontOfSize:[ColumnBarConfig sharedColumnBarConfig].columnNameFontSize];
		[button setTitle:name forState:UIControlStateNormal];
		[button setTitleColor:[ColorStyleConfig sharedColorStyleConfig].navbar_titlecolor_didselect forState:UIControlStateNormal];
        [button setTitleColor:[ColorStyleConfig sharedColorStyleConfig].navbar_titlecolor_selected forState:UIControlStateSelected];
		[scrollView addSubview:button];
        
	}
    
    return origin_x;
}

- (void)buttonClicked:(UIButton *)button
{
    if (!self.enabled) return;

    NSMutableArray *buttons = [[NSMutableArray alloc] init];
    for (UIButton *btn in scrollView.subviews) {
        if ([btn isKindOfClass:[UIButton class]]) {
            btn.selected = NO;
            [buttons addObject:btn];
        }
    }
    
    
    button.selected = YES;
    selectedIndex = (int)[buttons indexOfObject:button];
    CGRect rect = button.frame;
    if (lastSelectIndex < selectedIndex) {
        rect.size.width += self.frame.size.width/3;
    }
    else{
        rect.origin.x -= self.frame.size.width/3;
        if(rect.origin.x < 0)
            rect.origin.x = 0;
    }
    [scrollView scrollRectToVisible:rect animated:YES];
    
    lastSelectIndex = selectedIndex;
    if(self.delegate && [self.delegate respondsToSelector:@selector(columnBar:didSelectedTabAtIndex:)])
		[self.delegate columnBar:self didSelectedTabAtIndex:selectedIndex];
}

-(void)setButtonTitleColor:(UIColor *)color
{
    UIButton *button = (UIButton *)[self.scrollView viewWithTag:500];
    [button setTitleColor:color forState:UIControlStateNormal];
    [button setTitleColor:color forState:UIControlStateSelected];
    
}

-(NSString *)currentButtonTitle
{
    UIButton *button = (UIButton *)[self.scrollView viewWithTag:500];
    return button.currentTitle;
}


- (void)selectTabAtIndex:(int)index
{
    selectedIndex = index;
    lastSelectIndex = selectedIndex;
    if(self.delegate && [self.delegate respondsToSelector:@selector(columnBar:didSelectedTabAtIndex:)])
        [self.delegate columnBar:self didSelectedTabAtIndex:selectedIndex];

}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)inScrollView
{
}

//左右切换栏目时，设置导航条的对应按钮为选中
- (void)setSelectedIndex:(int)index{
    
    selectedIndex = index;
    NSMutableArray *buttons = [[NSMutableArray alloc] init];
    for (UIButton *btn in scrollView.subviews) {
        if ([btn isKindOfClass:[UIButton class]]) {
            btn.selected = NO;
            [buttons addObject:btn];
        }
    }
    if ([buttons count]==0)
        return;
    UIButton *button = [buttons objectAtIndex:index];
    button.selected = YES;
    
    CGRect rect = button.frame;
    if (lastSelectIndex < selectedIndex) {
        rect.size.width += self.frame.size.width/3;
    }
    else{
        rect.origin.x -= self.frame.size.width/3;
        if(rect.origin.x < 0)
            rect.origin.x = 0;
    }
    [scrollView scrollRectToVisible:rect animated:YES];
}

@end
