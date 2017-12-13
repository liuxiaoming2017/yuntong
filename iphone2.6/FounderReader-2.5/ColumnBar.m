//
//  ColumnBar.m
//  ColumnBarDemo
//
//  Created by chenfei on 4/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import "ColorStyleConfig.h"
#import "ColumnBar.h"
#import "ColumnBarConfig.h"
#import "UIButton+WebCache.h"
#import "UIView+Extention.h"
#import "GrayScale.h"
#import "ColumnBarConfig.h"
#import "AppConfig.h"
#import "AppStartInfo.h"

@implementation ColumnBar
{
    BOOL _isFirstLoadColumnBar;//是否是第一次加载栏目条
    
    BOOL _isFirstNewsVC;
}
@synthesize scrollView, selectedIndex, dataSource, delegate, enabled;

- (id)initWithFrame:(CGRect)frame withIsFirstNewsVC:(BOOL)isFirstNewsVC ViewControllerType:(FDViewControllerType)viewControllerType
{
    _isFirstNewsVC = isFirstNewsVC;
    self = [self initWithFrame:frame];
    if (self) {
        if (isFirstNewsVC) {//首页新闻
            if ([ColumnBarConfig sharedColumnBarConfig].columnHeaderHeight) {//有头部logo
                if ([AppStartInfo sharedAppStartInfo].ucTabisShow) {//个人中心在底部
                    if ([AppConfig sharedAppConfig].isColumnEidtInRight) {//编辑按钮位置
                        scrollView.frame = CGRectMake(5, 0, kSWidth-40, [ColumnBarConfig sharedColumnBarConfig].columnBtnHeight);
                    }else{
                        scrollView.frame = CGRectMake(5, 0, kSWidth-10, [ColumnBarConfig sharedColumnBarConfig].columnBtnHeight);
                    }
                }else{//个人中心不在底部
                    if ([AppConfig sharedAppConfig].isNavigationAddSearch) {//有头部logo时右侧加搜索框
                        scrollView.frame = CGRectMake(5, 0, kSWidth-40, [ColumnBarConfig sharedColumnBarConfig].columnBtnHeight);
                    }else{
                        scrollView.frame = CGRectMake(5, 0, kSWidth-10, [ColumnBarConfig sharedColumnBarConfig].columnBtnHeight);
                    }
                }
            }else{//无头部logo
                if ([AppStartInfo sharedAppStartInfo].ucTabisShow) {//个人中心在底部
                    if ([AppConfig sharedAppConfig].isChangeSearchAtUser) {
                        scrollView.frame = CGRectMake(35, 0, kSWidth-70, [ColumnBarConfig sharedColumnBarConfig].columnBtnHeight);
                    }else{
                        scrollView.frame = CGRectMake(5, 0, kSWidth-40, [ColumnBarConfig sharedColumnBarConfig].columnBtnHeight);
                    }
                }else{//个人中心不在底部
                    scrollView.frame = CGRectMake(35, 0, kSWidth-70, [ColumnBarConfig sharedColumnBarConfig].columnBtnHeight);
                }
            }
        }else{//非首页新闻
            if (viewControllerType == FDViewControllerForTabbarVC) {//一级栏目
                if ([AppStartInfo sharedAppStartInfo].ucTabisShow) {//个人中心在底部
                    scrollView.frame = CGRectMake(5, 0, kSWidth-40, [ColumnBarConfig sharedColumnBarConfig].columnBtnHeight);
                }else{//个人中心不在底部
                    scrollView.frame = CGRectMake(35, 0, kSWidth-70, [ColumnBarConfig sharedColumnBarConfig].columnBtnHeight);
                }
            }else{//其他页面
                scrollView.frame = CGRectMake(35, 0, kSWidth-70, [ColumnBarConfig sharedColumnBarConfig].columnBtnHeight);
            }
        }
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        self.enabled = YES;
        
        UIImageView *imageView = [[UIImageView alloc] init];
        if (_isFirstNewsVC) {
            imageView.image = [Global columnBarImage];
        }else {
            imageView.image = [Global navigationImage];
        }
        
        imageView.frame = self.bounds;
        [self addSubview:imageView];
        scrollView = [[UIScrollView alloc] init];
        scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        scrollView.delegate = self;
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.userInteractionEnabled = YES;
        [self addSubview:scrollView];
        
        UILabel *lineLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, [ColumnBarConfig sharedColumnBarConfig].columnBtnHeight-1, kSWidth, 1)];
        lineLabel.backgroundColor = [Global navigationLineColor];
        [self addSubview:lineLabel];
        lastSelectIndex = -1;
    }
    return self;
}

-(void)setColumnBarY:(CGFloat)y{
    
    return;
}

- (void)reloadData:(Column *)parentColumn
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
    
    float origin_x = [self configCell:items parentColumn:parentColumn];
    scrollView.contentSize = CGSizeMake(origin_x-10, scrollView.frame.size.height);
    self.selectedIndex = selectedIndex;
}

-(float)configCell:(NSInteger)buttonNummbers parentColumn:(Column *)parentColumn
{
    int x;
    float origin_x = 5;
    for(x = 0; x < buttonNummbers; x++) {
        
        //添加栏目条按钮
        Column *column = [self.dataSource columnBar:self titleForTabAtIndex:x];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [button addObserver:self forKeyPath:@"selected" options:0 context:@"KVO_CONTEXT_SELECTED_CHANGED"];
        
        CGFloat bottomTagY = 0;
        if (parentColumn && [parentColumn.columnStyle isEqualToString:@"新闻icon"]) {
            //导航图片固定尺寸(110, 95)像素
//            button.frame = CGRectMake(origin_x, 0.0f, scrollView.frame.size.height *(110/95.0f)+5, scrollView.frame.size.height);
//            origin_x += button.frame.size.width + [ColumnBarConfig sharedColumnBarConfig].columnButtonSpacing + 5;
//            [button sd_setImageWithURL:[NSURL URLWithString:column.iconUrl] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"btn-read"]];
            //导航图片固定尺寸(110, 95)像素
            button.frame = CGRectMake(origin_x, 0.0f + 5, (scrollView.frame.size.height -10) *(110/95.0f)+5, (scrollView.frame.size.height -10));
            origin_x += button.frame.size.width + [ColumnBarConfig sharedColumnBarConfig].columnButtonSpacing + 5;
            bottomTagY = button.bounds.size.height - 4;
            [button sd_setImageWithURL:[NSURL URLWithString:column.iconUrl] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"btn-read"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                [button setImage:image forState:UIControlStateSelected];
                [button setImage:[image convertImageColorScale2xWithRGBColorStr:[ColumnBarConfig sharedColumnBarConfig].column_diselect_imagecolor] forState:UIControlStateNormal];
                //只是第一次加载才去刷新reloadData但会调用本方法，设置一个开关就不走reloadData了
                if (x == buttonNummbers - 1 && !_isFirstLoadColumnBar) {
                    _isFirstLoadColumnBar = YES;//不能和下面[self reloadData]调换，否则不会走falg = yes;
                    [self reloadData:parentColumn];//因为是异步加载图片，所以需要在所有图片异步加载完以后刷新一下
                }
            }];
        }else {
            if ([column.columnName isKindOfClass:[NSNull class]]) {
                column.columnName = @"";
            }
            
            if ([ColumnBarConfig sharedColumnBarConfig].columnNameFontBold)
                button.titleLabel.font = [UIFont boldSystemFontOfSize:[ColumnBarConfig sharedColumnBarConfig].columnNameFontSize];
            else
                button.titleLabel.font = [UIFont systemFontOfSize:[ColumnBarConfig sharedColumnBarConfig].columnNameFontSize];
            
            NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:button.titleLabel.font, NSFontAttributeName,nil];
            CGSize size = [column.columnName boundingRectWithSize:CGSizeMake(320, 100) options:NSStringDrawingUsesLineFragmentOrigin attributes:tdic context:nil].size;

            if ([ColumnBarConfig sharedColumnBarConfig].columnSelectType == 1) {
                button.frame = CGRectMake(origin_x, 0.0f, size.width+5, scrollView.frame.size.height);
            }
            else if ([ColumnBarConfig sharedColumnBarConfig].columnSelectType == 2) {
                button.frame = CGRectMake(origin_x, 5.0f, size.width+5, scrollView.frame.size.height-10);
                button.layer.masksToBounds = YES;
                button.layer.cornerRadius = 5;
            }
            
            origin_x += size.width + [ColumnBarConfig sharedColumnBarConfig].columnButtonSpacing + 5;
            
            if(buttonNummbers == 1){
                button.frame = CGRectMake((scrollView.width-kSWidth/4)/2.0f, button.frame.origin.y, kSWidth/4, button.frame.size.height);
                button.titleLabel.textAlignment = NSTextAlignmentCenter;
            }
            
            button.titleLabel.alpha = 1;
            [button setTitle:column.columnName forState:UIControlStateNormal];
            if (_isFirstNewsVC) {
                [button setTitleColor:[ColumnBarConfig sharedColumnBarConfig].columnNameFontColor forState:UIControlStateNormal];
                [button setTitleColor:[ColumnBarConfig sharedColumnBarConfig].columnNameFontSeledColor forState:UIControlStateSelected];
            }else {
                [button setTitleColor:[ColorStyleConfig sharedColorStyleConfig].navbar_titlecolor_didselect forState:UIControlStateNormal];
                [button setTitleColor:[ColorStyleConfig sharedColorStyleConfig].navbar_titlecolor_selected forState:UIControlStateSelected];
            }
        }
        
        //栏目条添加底部三角选中标签
        UIImageView *bottomTag = [[UIImageView alloc]initWithFrame:CGRectMake((button.bounds.size.width-10)/2,button.bounds.size.height-9, 10, 6)];
        bottomTag.image = [UIImage imageNamed:@"icon-point"];
        bottomTag.tag = 101;
        bottomTag.hidden = YES;//默认隐藏
        [button addSubview:bottomTag];
        
        NSInteger columnCount = [[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"columnCount%@",self.columnName]] integerValue];
        if (columnCount == 2) {
            bottomTag.image = [UIImage imageNamed:@""];
        }
        [scrollView addSubview:button];
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
            //圆矩形选中背景颜色和未选中背景颜色
            currentButton.backgroundColor = currentButton.selected ?  [ColumnBarConfig sharedColumnBarConfig].columnSelectColor : [ColumnBarConfig sharedColumnBarConfig].columnDisSelectColor;
        }
    }
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
    //selectedIndex = index;
    //lastSelectIndex = selectedIndex;
    [self setSelectedIndex:index];
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
