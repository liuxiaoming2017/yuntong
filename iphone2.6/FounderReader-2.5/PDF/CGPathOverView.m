//
//  CGPathOverView.m
//  FounderReader-2.5
//
//  Created by ld on 13-12-6.
//
//

#import "CGPathOverView.h"
#import "PDFHotAreaDataModel.h"
@implementation CGPathOverView
@synthesize pathRef;

-(void)dealloc

{
//    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
//        self.frame = [[UIScreen mainScreen]bounds];
    }
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeAway)];
    [self addGestureRecognizer:recognizer];
    return self;
}

-(void)removeAway
{
    [self removeFromSuperview];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef pathContext = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(pathContext, [UIColor colorWithWhite:0.8 alpha:.5].CGColor);
    CGContextSetStrokeColorWithColor(pathContext, [UIColor grayColor].CGColor);
    CGContextStrokePath(pathContext);
    CGContextAddPath(pathContext, self.pathRef);
    CGContextFillPath(pathContext);
    
}

@end
