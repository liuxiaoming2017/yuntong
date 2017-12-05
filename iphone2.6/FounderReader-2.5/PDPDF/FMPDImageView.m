//
//  FMPDImageView.m
//  FounderReader-2.5
//
//  Created by ld on 14-3-10.
//
//

#import "FMPDImageView.h"

@implementation FMPDImageView
@synthesize imageView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        imageView = [[ImageViewCf alloc]initWithFrame:self.frame];
        imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth &UIViewAutoresizingFlexibleHeight;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:self.imageView];
    }
    return self;
}

- (void)addTarget:(id)target actionB:(SEL)actionB actionE:(SEL)actionE
{
    _target = target;
    _actionB = actionB;
    _actionE = actionE;
}

- (void)addTarget:(id)target actionB:(SEL)actionB actionE:(SEL)actionE withObject:(id)object
{
    [self addTarget:target actionB:actionB actionE:actionE];
    _actionObject = object;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    if ([_target respondsToSelector:_actionB])
        [_target performSelector:_actionB withObject:[NSValue valueWithCGPoint:touchPoint]];
    
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    if ([_target respondsToSelector:_actionE])
        [_target performSelector:_actionE withObject:[NSValue valueWithCGPoint:touchPoint]];
}

@end
