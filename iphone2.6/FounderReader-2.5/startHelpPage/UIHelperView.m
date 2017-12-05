//
//  UIHelperView.m
//  FounderReader-2.5
//
//  Created by zhou.zy on 14-11-15.
//
//

#import "UIHelperView.h"

@implementation UIHelperView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor blackColor];
        self.alpha = 0.8;
    }
    return self;
}

-(void)dealloc{
    
//    [super dealloc];
}

-(void)showHelp:(NSString *)viewName{
    
//    NSString *viewNameMark = [viewName stringByAppendingString:@"_6"];;
//    if (IS_IPHONE_4) {
//       
//    }else if (IS_IPHONE_5) {
//        viewNameMark = [viewNameMark stringByAppendingString:@"_5"];
//    }else
//    {
//        viewNameMark = [viewNameMark stringByAppendingString:@"_6"];
//    }
    
    UIImage *image = [UIImage imageNamed:viewName];
    
    if (image != nil) {
//        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.contentMode = UIViewContentModeScaleToFill;
        imageView.frame = self.frame;
        [self addSubview:imageView]; 
    }
    else{
        //[self removeFromSuperview];
        return;
    }
    
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self removeFromSuperview];
}
@end
