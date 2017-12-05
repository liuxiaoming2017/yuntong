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
        
        self.isPDF = NO;
        self.userInteractionEnabled = YES;
        self.enabled = YES;
        if([ColumnBarConfig sharedColumnBarConfig].columnHeaderHeight > 0){
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"column_bar_header"]];
            imageView.frame = CGRectMake(0, 0, kSWidth, [ColumnBarConfig sharedColumnBarConfig].columnHeaderHeight);
            [self addSubview:imageView];
            [self sendSubviewToBack:imageView];
        }
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"nav_bar_background"]];
        imageView.frame = self.bounds;
        [self addSubview:imageView];
        [self sendSubviewToBack:imageView];
        
        


        scrollView = [[UIScrollView alloc] init];
        scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        scrollView.delegate = self;
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.frame = CGRectMake([ColumnBarConfig sharedColumnBarConfig].columnBtnMargin, [ColumnBarConfig sharedColumnBarConfig].columnBarHeight - [ColumnBarConfig sharedColumnBarConfig].columnBtnHeight, kSWidth-2*[ColumnBarConfig sharedColumnBarConfig].columnBtnMargin, [ColumnBarConfig sharedColumnBarConfig].columnBtnHeight);

        
        [self addSubview:scrollView];
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
                NSLog(@"标签栏名称：%@",btn.titleLabel.text);
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
    if (self.isPDF) {
        origin_x = [self configPDFPageCell:items];
    }else{
        origin_x = [self configCell:items];
    }
    
    scrollView.contentSize = CGSizeMake(origin_x-10, scrollView.frame.size.height);
    
    self.selectedIndex = selectedIndex;
}

-(float)configCell:(NSInteger)buttonNummbers
{
    int x;
    float origin_x = 5;
    for(x = 0; x < buttonNummbers; x++) {
        
        //添加栏目条按钮
        Column *column = [self.dataSource columnBar:self titleForTabAtIndex:x];
        
        self.button = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.button addObserver:self forKeyPath:@"selected" options:0 context:@"KVO_CONTEXT_SELECTED_CHANGED"];
        
        Column *parentColumn = nil;
        if ([self.delegate respondsToSelector:@selector(parentColumn)]) {
            parentColumn = [self.dataSource performSelector:@selector(parentColumn)];
        }
        if (parentColumn && [parentColumn.columnStyle isEqualToString:@"新闻icon"]) {
            //导航图片固定尺寸(110, 95)像素
            self.button.frame = CGRectMake(origin_x, 0.0f, scrollView.frame.size.height *(110/95.0f)+5, scrollView.frame.size.height);
            origin_x += self.button.frame.size.width + [ColumnBarConfig sharedColumnBarConfig].columnButtonSpacing + 5;
            [self.button sd_setImageWithURL:[NSURL URLWithString:column.iconUrl] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"btn-read"]];
        }else {
            if ([column.columnName isKindOfClass:[NSNull class]]) {
                column.columnName = @"";
            }
            
            NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:self.button.titleLabel.font, NSFontAttributeName,nil];
            CGSize size = [column.columnName boundingRectWithSize:CGSizeMake(320, 100) options:NSStringDrawingUsesLineFragmentOrigin attributes:tdic context:nil].size;
            
            
            if ([ColumnBarConfig sharedColumnBarConfig].columnSelectType == 1) {
                self.button.frame = CGRectMake(origin_x, 0.0f, size.width+5, scrollView.frame.size.height);
            }
            else if ([ColumnBarConfig sharedColumnBarConfig].columnSelectType == 2) {
                self.button.frame = CGRectMake(origin_x, 5.0f, size.width+5, scrollView.frame.size.height-10);
                self.button.layer.masksToBounds = YES;
                self.button.layer.cornerRadius = 5;
            }
            
            origin_x += size.width + [ColumnBarConfig sharedColumnBarConfig].columnButtonSpacing + 5;
            self.button.titleLabel.alpha = 1;
            self.button.titleLabel.font = [UIFont systemFontOfSize:[ColumnBarConfig sharedColumnBarConfig].columnNameFontSize];
            [self.button setTitle:column.columnName forState:UIControlStateNormal];
            [self.button setTitleColor:[ColumnBarConfig sharedColumnBarConfig].columnNameFontColor forState:UIControlStateNormal];
            [self.button setTitleColor:[ColumnBarConfig sharedColumnBarConfig].columnNameFontSeledColor forState:UIControlStateSelected];
        }
        
        //栏目条添加底部三角选中标签
        UIImageView *bottomTag = [[UIImageView alloc]initWithFrame:CGRectMake((self.button.bounds.size.width-10)/2,self.button.bounds.size.height-9, 10, 6)];
        bottomTag.image = [UIImage imageNamed:@"icon-point"];
        bottomTag.tag = 101;
        bottomTag.hidden = YES;//默认隐藏
        [self.button addSubview:bottomTag];
        
        NSInteger columnCount = [[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"columnCount%@",self.columnName]] integerValue];
        if (columnCount == 2) {
            bottomTag.image = [UIImage imageNamed:@""];
        }
        [scrollView addSubview:self.button];
    }
    
    return origin_x;
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
            //圆矩形背景 默认灰色
            currentButton.backgroundColor = currentButton.selected ?  [ColumnBarConfig sharedColumnBarConfig].columnSelectColor : [ColumnBarConfig sharedColumnBarConfig].column_all_color;
        }
    }
}

#pragma mark - 读报子栏目
-(float)configPDFPageCell:(NSInteger)buttonNummbers
{
    int x;
    float origin_x;
    if (IS_IPHONE_5) {
        origin_x = 23;

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

        int margin = (scrollView.frame.size.width - 80*2 - 10)/2.0+10;
        if (IS_IPHONE_5) {
            margin = (scrollView.frame.size.width - 80*2 - 10)/2.0+15;
        }else if (IS_IPHONE_6P){
            margin = (scrollView.frame.size.width - 80*2 - 10)/2.0;
        }
        button.frame = CGRectMake(margin*kScale+90*x, 5, 80, scrollView.frame.size.height-10);
        
        //导航条添加底部红色选中标签
        self.bottomTag = [[UIImageView alloc]initWithFrame:CGRectMake((button.bounds.size.width-10)/2,button.bounds.size.height-4, 10, 6)];
        self.bottomTag.image = [UIImage imageNamed:@"icon-point"];

        self.bottomTag.hidden = YES;
        self.bottomTag.tag = 101;
        [button addSubview:self.bottomTag];
        [button addObserver:self forKeyPath:@"selected" options:0 context:@"KVO_CONTEXT_SELECTED_CHANGED"];
        
        button.titleLabel.font = [UIFont systemFontOfSize:[ColumnBarConfig sharedColumnBarConfig].columnNameFontSize];
		[button setTitle:name forState:UIControlStateNormal];
		[button setTitleColor:[ColumnBarConfig sharedColumnBarConfig].columnNameFontColor forState:UIControlStateNormal];
        [button setTitleColor:[ColumnBarConfig sharedColumnBarConfig].columnNameFontSeledColor forState:UIControlStateSelected];
		[scrollView addSubview:button];
        
	}
    
    moreCap.hidden = YES;
    return origin_x;
}

- (void)moveToFrame:(CGRect)frame animated:(BOOL)animated
{
    NSTimeInterval duration;
    
    if (animated)
        duration = 0.3;
    else
        duration = 0;
    
    [UIView animateWithDuration:duration animations:^(void) {
        [mover removeFromSuperview];
        ColumnBarConfig *config = [ColumnBarConfig sharedColumnBarConfig];
        mover.frame = CGRectMake(frame.origin.x, (frame.size.height-config.moverHeight)/2+4, frame.size.width, config.moverHeight);
        [scrollView addSubview:mover];
    }];
    
    [scrollView sendSubviewToBack:mover];
}

- (void)buttonClicked:(UIButton *)button
{
    if (!self.enabled) return;
    
    [self moveToFrame:button.frame animated:YES];

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
