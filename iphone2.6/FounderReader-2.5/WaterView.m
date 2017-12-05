//
//  WaterView.m
//  FounderReader-2.5
//
//  Created by mac on 2017/6/19.
//

#import "WaterView.h"
#import "ColumnBarConfig.h"
#import "Defines.h"
@interface WaterView()
{
    UIColor *_waterColor;
    UIColor * _lightColor;
    CGFloat _waterLineY;
    CGFloat _waveAmplitude;
    CGFloat _waveCycle;
    NSTimer * _timer;
    BOOL increase;
    CADisplayLink *_waveDisplayLink;
}

@end

@implementation WaterView

-(instancetype)initWithFrame:(CGRect)frame
{
    self=[super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[ColumnBarConfig sharedColumnBarConfig].column_all_color];
        _waveAmplitude=3.0;
        _waveCycle=1.0;
        increase=NO;
        _waterColor=[UIColor whiteColor];
//        const CGFloat *components = CGColorGetComponents([ColumnBarConfig sharedColumnBarConfig].column_all_color.CGColor);
//        CGFloat r ,g , b;
//        r = components[0]*1.1 > 1.0 ?1.0:components[0]*1.1;
//        g = components[1]*1.1 > 1.0 ?1.0:components[1]*1.1;
//        b = components[2]*1.1 > 1.0 ?1.0:components[2]*1.1;
        _lightColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.7];
        _waterLineY=140.0*kScale;
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(runWave) userInfo:nil repeats:YES];
//        _waveDisplayLink=[CADisplayLink displayLinkWithTarget:self selector:@selector(runWave)];
//        [_waveDisplayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        [[NSRunLoop currentRunLoop]addTimer:_timer forMode:NSRunLoopCommonModes];
    }
    return self;
}

-(void)runWave
{
    
    if (increase) {
        _waveAmplitude += 0.01;
    }else{
        _waveAmplitude -= 0.01;
    }
    
    if (_waveAmplitude<=1) {
        increase = YES;
    }
    
    if (_waveAmplitude>=1.3) {
        increase = NO;
    }
    
    _waveCycle+=0.1;
    
    [self setNeedsDisplay];
}

-(NSMutableAttributedString *) formatBatteryLevel:(NSInteger)percent
{
    UIColor *textColor=[UIColor redColor];
    NSMutableAttributedString *attrText;
    
    NSString *percentText=[NSString stringWithFormat:@"%ld%%",(long)percent];
    
    NSMutableParagraphStyle *paragrahStyle = [[NSMutableParagraphStyle alloc] init];
    [paragrahStyle setAlignment:NSTextAlignmentCenter];
    if (percent<10) {
        attrText=[[NSMutableAttributedString alloc] initWithString:percentText];
        UIFont *capacityNumberFont=[UIFont fontWithName:@"HelveticaNeue-Thin" size:80];
        UIFont *capacityPercentFont=[UIFont fontWithName:@"HelveticaNeue-Thin" size:40];
        [attrText addAttribute:NSFontAttributeName value:capacityNumberFont range:NSMakeRange(0, 1)];
        [attrText addAttribute:NSFontAttributeName value:capacityPercentFont range:NSMakeRange(1, 1)];
        [attrText addAttribute:NSForegroundColorAttributeName value:textColor range:NSMakeRange(0, 2)];
        [attrText  addAttribute:NSParagraphStyleAttributeName value:paragrahStyle range:NSMakeRange(0, 2)];
        
    }
    else
    {
        attrText=[[NSMutableAttributedString alloc] initWithString:percentText];
        UIFont *capacityNumberFont=[UIFont fontWithName:@"HelveticaNeue-Thin" size:80];
        UIFont *capacityPercentFont=[UIFont fontWithName:@"HelveticaNeue-Thin" size:40];
        
        
        if (percent>=100) {
            
            [attrText addAttribute:NSFontAttributeName value:capacityNumberFont range:NSMakeRange(0, 3)];
            [attrText addAttribute:NSFontAttributeName value:capacityPercentFont range:NSMakeRange(3, 1)];
            [attrText addAttribute:NSForegroundColorAttributeName value:textColor range:NSMakeRange(0, 4)];
            [attrText addAttribute:NSParagraphStyleAttributeName value:paragrahStyle range:NSMakeRange(0, 4)];
        }
        else
        {
            [attrText addAttribute:NSFontAttributeName value:capacityNumberFont range:NSMakeRange(0, 2)];
            [attrText addAttribute:NSFontAttributeName value:capacityPercentFont range:NSMakeRange(2, 1)];
            [attrText addAttribute:NSForegroundColorAttributeName value:textColor range:NSMakeRange(0, 3)];
            [attrText  addAttribute:NSParagraphStyleAttributeName value:paragrahStyle range:NSMakeRange(0, 3)];
        }
        
    }
    
    
    return attrText;
}
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    //初始化画布
    CGContextRef context = UIGraphicsGetCurrentContext();
    
//    NSMutableAttributedString *attriButedText=[self formatBatteryLevel:50];
//    CGRect textSize = [attriButedText boundingRectWithSize:CGSizeMake(400, 10000) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
//    CGPoint textPoint = CGPointMake(kSWidth/2-textSize.size.width/2, 70);
//    [attriButedText drawAtPoint:textPoint];
    
    //推入
    CGContextSaveGState(context);
    
    
    //定义前波浪path
    CGMutablePathRef frontPath = CGPathCreateMutable();
    
    //定义后波浪path
    CGMutablePathRef backPath=CGPathCreateMutable();
    
    //定义前波浪反色path
    CGMutablePathRef frontReversePath = CGPathCreateMutable();
    
    //定义后波浪反色path
    CGMutablePathRef backReversePath=CGPathCreateMutable();
    
    //画水
    CGContextSetLineWidth(context, 0);
    
    
    //前波浪位置初始化
    float frontY=_waterLineY;
    CGPathMoveToPoint(frontPath, NULL, 0, frontY);
    
    //前波浪反色位置初始化
    float frontReverseY=_waterLineY;
    CGPathMoveToPoint(frontReversePath, NULL, 0,frontReverseY);
    
    //后波浪位置初始化
    float backY=_waterLineY;
    CGPathMoveToPoint(backPath, NULL, 0, backY);
    
    //后波浪反色位置初始化
    float backReverseY=_waterLineY;
    CGPathMoveToPoint(backReversePath, NULL, 0, backReverseY);
    
    for(float x=0;x<=kSWidth;x++){
        
        //前波浪绘制
        frontY= _waveAmplitude * sin( x/120*M_PI + 4*_waveCycle/M_PI ) * 4 + _waterLineY-2;
        CGPathAddLineToPoint(frontPath, nil, x, frontY);
        
        //后波浪绘制
        backY= _waveAmplitude * cos( x/120*M_PI + 3*_waveCycle/M_PI ) * 4 + _waterLineY-2;
        CGPathAddLineToPoint(backPath, nil, x, backY);
        
        
        if (x>=0) {
            
            //后波浪反色绘制
            backReverseY= _waveAmplitude * cos( x/120*M_PI + 3*_waveCycle/M_PI ) * 4 + _waterLineY-2;
            CGPathAddLineToPoint(backReversePath, nil, x, backReverseY);
            
            //前波浪反色绘制
            frontReverseY= _waveAmplitude * sin( x/120*M_PI + 4*_waveCycle/M_PI ) * 4 + _waterLineY-2;
            CGPathAddLineToPoint(frontReversePath, nil, x, frontReverseY);
        }
    }
    
    //后波浪绘制
    CGContextSetFillColorWithColor(context, [_lightColor CGColor]);
    
    CGPathAddLineToPoint(backPath, nil, kSWidth, rect.size.height-1);
    CGPathAddLineToPoint(backPath, nil, 0, rect.size.height-1);
    CGPathAddLineToPoint(backPath, nil, 0, _waterLineY);
    CGPathCloseSubpath(backPath);
    CGContextAddPath(context, backPath);
    CGContextFillPath(context);
    
    //推入
    CGContextSaveGState(context);
    
    //后波浪反色绘制
    CGPathAddLineToPoint(backReversePath, nil, kSWidth, rect.size.height-1);
    CGPathAddLineToPoint(backReversePath, nil, kSWidth*0.5, rect.size.height-1);
    CGPathAddLineToPoint(backReversePath, nil, kSWidth*0.5, _waterLineY);
    
    CGContextAddPath(context, backReversePath);
    CGContextClip(context);
//    [attriButedText addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, attriButedText.length)];
//    [attriButedText drawAtPoint:textPoint];
    
    
    // CGContextSaveGState(context);
    //弹出
    CGContextRestoreGState(context);
    
    //前波浪绘制
    CGContextSetFillColorWithColor(context, [_waterColor CGColor]);
    CGPathAddLineToPoint(frontPath, nil, kSWidth, rect.size.height+1);
    CGPathAddLineToPoint(frontPath, nil, 0, rect.size.height+1);
    CGPathAddLineToPoint(frontPath, nil, 0, _waterLineY);
    CGPathCloseSubpath(frontPath);
    CGContextAddPath(context, frontPath);
    CGContextFillPath(context);
    
    //推入
    CGContextSaveGState(context);
    
    
    //前波浪反色绘制
    CGPathAddLineToPoint(frontReversePath, nil, kSWidth, rect.size.height+1);
    CGPathAddLineToPoint(frontReversePath, nil, kSWidth*0.5, rect.size.height+1);
    CGPathAddLineToPoint(frontReversePath, nil, kSWidth*0.5, _waterLineY);
    
    CGContextAddPath(context, frontReversePath);
    CGContextClip(context);
//    [attriButedText addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, attriButedText.length)];
//    [attriButedText drawAtPoint:textPoint];
    
    //推入
    CGContextSaveGState(context);
    
    
    //释放
    CGPathRelease(backPath);
    CGPathRelease(backReversePath);
    CGPathRelease(frontPath);
    CGPathRelease(frontReversePath);
    
}

@end
