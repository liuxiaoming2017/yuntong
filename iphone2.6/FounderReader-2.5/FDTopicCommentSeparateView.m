//
//  FDTopicCommentSeparateView.m
//  FounderReader-2.5
//
//  Created by Julian on 2017/7/16.
//
//

#import "FDTopicCommentSeparateView.h"
#import <QuartzCore/QuartzCore.h>

@implementation FDTopicCommentSeparateView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

/* 
 CGContextRef画线
 */
// 覆盖drawRect方法，你可以在此自定义绘画和动画
- (void)drawRect:(CGRect)rect
{
    //一个不透明类型的Quartz 2D绘画环境,相当于一个画布,你可以在上面任意绘画
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBStrokeColor(context,190/255.0f, 190/255.0f, 190/255.0f, 1.0);//画笔线的颜色
    CGContextSetLineWidth(context, 0.5f);//线宽1像素
    
    //只要三个点就行跟画一条线方式一样，把三点连接起来
    /* ！注意：因为绘制的原因，想要绘制基数像素线宽的线，必须要x点(竖向)、或y点(横线)坐标是带0.5。
       原因：https://my.oschina.net/lych0317/blog/126215
     */
    CGFloat lineY = 7.5;
    CGPoint sPoints[5];//坐标点
    sPoints[0] =CGPointMake(0, lineY);
    sPoints[1] =CGPointMake(17, lineY);
    sPoints[2] =CGPointMake(22, 0);
    sPoints[3] =CGPointMake(27, lineY);
    sPoints[4] =CGPointMake(kSWidth, lineY);
    CGContextAddLines(context, sPoints, 5);//添加线
//    CGContextClosePath(context);//不封起来，不闭合
    CGContextDrawPath(context, kCGPathStroke); //根据坐标绘制路径
}

/*
 贝塞尔曲线画线，是对CGContextRef先画贝塞尔的封装
 */
//- (void)drawRect:(CGRect)rect
//{
//    CGFloat lineY = 7.5;
//    UIBezierPath *path = [UIBezierPath bezierPath];
//    [path moveToPoint:CGPointMake(0, lineY)];
//    [path addLineToPoint:CGPointMake(17, lineY)];
//    [path addLineToPoint:CGPointMake(22, 0)];
//    [path addLineToPoint:CGPointMake(27, lineY)];
//    [path addLineToPoint:CGPointMake(kSWidth, lineY)];
//    
//    // 最后的闭合线是可以通过调用closePath方法来自动生成的，也可以调用-addLineToPoint:方法来添加
//    //  [path addLineToPoint:CGPointMake(20, 20)];
////    [path closePath];//不闭合
//    
//    // 设置线宽
//    path.lineWidth = 0.5f;
//    
//    // 设置填充颜色
////    UIColor *fillColor = [UIColor greenColor];
////    [fillColor set];
////    [path fill];
//    
//    // 设置画笔颜色
//    UIColor *strokeColor = [UIColor colorWithRed:190/255.0f green:190/255.0f blue:190/255.0f alpha:1];
//    [strokeColor set];
//    
//    // 根据我们设置的各个点连线
//    [path stroke];
//}

@end
