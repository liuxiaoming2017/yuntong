//
//  AutoScrollView.m
//  FounderReader-2.5
//
//  Created by Julian on 16/8/19.
//
//

#import "AutoScrollView.h"
#import "UIView+Extention.h"
#define K_MAIN_VIEW_SCROLL_HEIGHT 80.0f
#define K_MAIN_VIEW_SCROLL_TEXT_TAG 300
#define K_MAIN_VIEW_TEME_INTERVAL 0.03         //计时器间隔时间(单位秒)
#define K_MAIN_VIEW_SCROLLER_SPACE 20          //每次移动的距离
#define K_MAIN_VIEW_SCROLLER_LABLE_WIDTH  320  //字体宽度
#define K_MAIN_VIEW_SCROLLER_LABLE_MARGIN 50   //前后间隔距离


@implementation AutoScrollView
{
    NSTimer *timer;
    CGFloat _allWidth;
    CGFloat _HEIGHT;
}


- (instancetype)initWithFrame:(CGRect)frame array:(NSArray *)array articleArr:(NSArray *)articleArr
{
    if ([super initWithFrame:frame]) {
        _HEIGHT = frame.size.height;
        self.arrData = array;
        _articleArr = articleArr;
        //文字滚动
        [self initScrollText];
        
        //开启滚动
        [self startScroll];
    }
    
    return  self;
}

-(void) initScrollText{
    
    self.showsHorizontalScrollIndicator = NO;   //隐藏水平滚动条
    self.showsVerticalScrollIndicator = NO;
    self.scrollEnabled = NO;
    //隐藏垂直滚动条
    self.tag = K_MAIN_VIEW_SCROLL_TEXT_TAG;
    //    [self setBackgroundColor:[UIColor whiteColor]];
    
    //清除子控件
    for (UIView *view in [self subviews]) {
        [view removeFromSuperview];
    }
    
    if (self.arrData) {
        
        CGFloat offsetX = 0 ,i = 0;
        
        //设置滚动文字
        UILabel *labText = nil;
        for (NSDictionary *dicTemp in self.arrData) {
            
            labText = [[UILabel alloc] initWithFrame:CGRectMake(_allWidth,0,K_MAIN_VIEW_SCROLLER_LABLE_WIDTH,_HEIGHT)];
            [labText setFont:[UIFont systemFontOfSize:14]];
            labText.tag = i+100;
//            [labText setTextColor:UIColorFromString(@"135,135,135")];
             [labText setTextColor: [UIColor blackColor]];
            labText.text = dicTemp[@"newsTitle"];
            
            //            if (self.arrData.count == 1) {
            //
            //            }else if (self.arrData.count == 2){
            //
            //            }else{
            //
            //            }
            NSDictionary *attribute = @{NSFontAttributeName: [UIFont systemFontOfSize:13]};
            CGSize size = [labText.text boundingRectWithSize:CGSizeMake(MAXFLOAT, 0) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
            
            
            //            [labText setFrame:CGRectMake(0, 0, size.width, size.height)];
            labText.width = size.width;
            labText.height = size.height;
            [labText sizeToFit];
            offsetX += labText.frame.origin.x;
            
            labText.userInteractionEnabled = YES;
            UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(titleClick:)];
            [labText addGestureRecognizer:recognizer];
            
            self.userInteractionEnabled = YES;
            //添加到滚动视图
            [self addSubview:labText];
            
            CGSize sizeName = [labText sizeThatFits:CGSizeZero];
            
            _allWidth += sizeName.width + K_MAIN_VIEW_SCROLLER_LABLE_MARGIN;
            
            
            i++;
        }
        
        //设置滚动区域大小
        [self setContentSize:CGSizeMake(offsetX, 0)];
        NSLog(@"%f",offsetX);
    }
}
- (void)titleClick:(UITapGestureRecognizer*)tap{
    UILabel *label =(UILabel*)tap.view;
    //    NSLog(@"%zd", label.tag - 100);
    
    //    Article *article = [_articleArr objectAtIndex:label.tag - 100];
    if ([self.autoDelegate respondsToSelector:@selector(gotoDetail:)]) {
        [self.autoDelegate gotoDetail:label.tag - 100];
    }
}
//开始滚动
-(void)startScroll{
    if (!timer)
        timer = [NSTimer scheduledTimerWithTimeInterval:K_MAIN_VIEW_TEME_INTERVAL target:self selector:@selector(setScrollText) userInfo:nil repeats:YES];
    
    [timer fire];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}
//滚动处理
-(void)setScrollText{
    
    CGRect rect;
    
    for (int i = 0; i < [self.subviews count]; i++) {
        UILabel *label = (UILabel *)[self.subviews objectAtIndex:i];
        rect = label.frame;
        
        if (rect.origin.x <= -rect.size.width) {
            rect.origin.x = _allWidth - rect.size.width;
            label.frame = rect;
            
        }
        label.frame = CGRectMake(rect.origin.x-1 , rect.origin.y, rect.size.width, rect.size.height);
    }
    
    return;
    
}

@end
