//
//  ArrayPageController.m
//  FounderReader-2.5
//
//  Created by chenfei on 5/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ArrayPageController.h"
#import "Thumbnail.h"
#import <QuartzCore/QuartzCore.h>
#import "Attachment.h"

@interface ArrayPageController ()

@end

@implementation ArrayPageController

@synthesize pictures;
@synthesize delegate;
@synthesize columnId;

//- (void)dealloc
//{
//    DELETE(pictures);
//    
//    [super dealloc];
//}

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)loadView
{
    arrayView = [[ATArrayView alloc] init];
    arrayView.delegate = self;
    self.view = arrayView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.title = NSLocalizedString(@"图集",nil);
    self.navigationController.navigationBar.translucent = NO;
    self.view.backgroundColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
    [arrayView reloadData];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - array view delegate

- (NSInteger)numberOfItemsInArrayView:(ATArrayView *)arrayView
{
    return [pictures count];
}

- (UIView *)viewForItemInArrayView:(ATArrayView *)sender atIndex:(NSInteger)index
{
    
    Thumbnail *thumbnail = (Thumbnail *)[arrayView dequeueReusableItem];
    if (thumbnail == nil) {
        thumbnail = [[Thumbnail alloc] init];
    }
    
    UIButton *maskButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    maskButton.frame = CGRectMake(0, 0, 70, 70);
    [thumbnail addSubview:maskButton];
    maskButton.tag = index;
    [maskButton addTarget:self action:@selector(cellDidSelected:) forControlEvents:UIControlEventTouchUpInside];
    thumbnail.userInteractionEnabled = YES;
    
    Attachment *attachment = [pictures objectAtIndex:index];
    thumbnail.defaultImage = [UIImage imageNamed:@"array_thumbnail_default.jpg"];
    [thumbnail setUrlString:[NSString stringWithFormat:@"%@&size=%d&columnId=%d", attachment.imageUrl, kMiddleImage, self.columnId]];

    thumbnail.tag = index;
    [thumbnail addTarget:self action:@selector(cellDidSelected:)];
    
    return thumbnail;
}

- (void)cellDidSelected:(Thumbnail *)sender
{
    if ([delegate respondsToSelector:@selector(cellDidSelectedAtIndex:)]){
        
        NSNumber *index = [NSNumber numberWithInteger:sender.tag];
        [delegate performSelector:@selector(cellDidSelectedAtIndex:) withObject:index];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

                     
@end
