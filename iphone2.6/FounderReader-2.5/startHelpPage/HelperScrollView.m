//
//  HelperScrollView.m
//  E-Publishing
//
//  Created by xiaobai on 11-6-6.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "HelperScrollView.h"
#import "Defines.h"

#define NUMBEROFPAGES (3)

@implementation HelperScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    if (self) 
    {
        _index = 1;
        [self setBackgroundColor:[UIColor colorWithWhite:0.2 alpha:1]];
        CGSize mainScreenBounds = [[UIScreen mainScreen] bounds].size;
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, mainScreenBounds.width, mainScreenBounds.height)];
        [scrollView setBackgroundColor:[UIColor clearColor]];
        scrollView.pagingEnabled = YES;
        scrollView.contentSize = CGSizeMake(mainScreenBounds.width * NUMBEROFPAGES, mainScreenBounds.height);
        scrollView.bounces = NO;
        scrollView.delegate = self;
        // Initialization code
        for (int index = 0; index < NUMBEROFPAGES; index ++) 
        {
            NSString *imageName = [NSString stringWithFormat:@"Helper%d",index];
            if (IS_IPHONE_5) {
                imageName = [NSString stringWithFormat:@"Helper%d_phone5",index];
            }
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
            imageView.frame = CGRectMake(index*mainScreenBounds.width, 0, mainScreenBounds.width, mainScreenBounds.height);
            //[imageView setCenter:CGPointMake(mainScreenBounds.width/2 + index *mainScreenBounds.width, mainScreenBounds.height/2)];
            imageView.contentMode = UIViewContentModeScaleToFill;
            if (index == NUMBEROFPAGES - 1)
            {
                UIButton *returnBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                [returnBtn addTarget:self action:@selector(return) forControlEvents:UIControlEventTouchUpInside];

                if (IS_IPHONE_5) {
                    [returnBtn setBounds:CGRectMake(0, 0, 200, 60)];
                    [returnBtn setCenter:CGPointMake(mainScreenBounds.width/2, mainScreenBounds.height-30)];
                }
                else{
                    returnBtn.bounds = CGRectMake(0, 0, 200, 80);
                    returnBtn.center = CGPointMake(mainScreenBounds.width/2, mainScreenBounds.height-40);
                }
                returnBtn.userInteractionEnabled = YES;
                [imageView addSubview:returnBtn];
            }
            imageView.userInteractionEnabled = YES;
            [scrollView addSubview:imageView];
        }
        [self addSubview:scrollView];
        
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickSkip)];
        UIView *viewclick = [[UIView alloc] initWithFrame:CGRectMake(96, 513, 222, 23)];
        [viewclick addGestureRecognizer:recognizer];
        [self addSubview:viewclick]; 
    }
    return self;
}

-(void)clickSkip{
    if (_index==3) {
        [self removeFromSuperview];
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    }
}

-(void)dealloc
{
//    [super dealloc];
}

#pragma Actions

-(void)return
{
    [self removeFromSuperview];
     [[UIApplication sharedApplication] setStatusBarHidden:NO];
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.x == 320)
    {
        [_pageNumLabel setText:@"2/4"];
        _index = 2;
    }
    else if (scrollView.contentOffset.x == 640)
    {
        [_pageNumLabel setText:@"3/4"];
        _index = 3;
    }
    else if (scrollView.contentOffset.x == 960)
    {
        [_pageNumLabel setText:@"4/4"];
        _index = 4;
    }
    else if (scrollView.contentOffset.x == 0)
    {
        [_pageNumLabel setText:@"1/4"];
        _index = 1;
    }
}

//-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
//{
//    float off_x = scrollView.contentOffset.x;
//    float pageWidth = self.frame.size.width;
//    
//    int currentPage = off_x/pageWidth;
//    
//    [imagePageControl setCurrentPage:currentPage];
//}


@end
