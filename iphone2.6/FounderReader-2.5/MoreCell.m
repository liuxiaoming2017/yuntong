//
//  MoreCell.m
//  FounderReader-2.5
//
//  Created by chenfei on 4/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MoreCell.h"
#import "NewsListConfig.h"

@implementation MoreCell

@synthesize indicator;

//- (void)dealloc
//{
//    DELETE(indicator);
//    
//    [super dealloc];
//}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

        indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        CGFloat height = [NewsListConfig sharedListConfig].moreCellHeight;
        indicator.frame = CGRectMake(90, height/2-20/2, 20, 20);
        indicator.hidesWhenStopped = YES;
        [self addSubview:indicator];
        self.backgroundColor = [UIColor clearColor];
        
        
        
        
        UIImageView *selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"more_cell_selected_background"]];
        self.selectedBackgroundView = selectedBackgroundView;
//        DELETE(selectedBackgroundView);
    
    }
    return self;
}

- (void)configWithTitle:(NSString *)title summary:(NSString *)summary thumbnailUrl:(NSString *)url columnId:(int)columnId
{
    self.textLabel.text = title;
    self.textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.textLabel.font = [UIFont fontWithName:[Global fontName] size:12.0f];
    self.textLabel.textColor = [UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:1];
    self.textLabel.textAlignment = NSTextAlignmentCenter;
    
    [self hideIndicator];
}

- (void)configWithTitle:(NSString *)title summary:(NSString *)summary date:(NSString *)date thumbnailUrl:(NSString *)url columnId:(int)columnId{
    
    [self configWithTitle:title summary:summary thumbnailUrl:url columnId:columnId];
}

- (void)showIndicator
{
    [indicator startAnimating];
    
    self.textLabel.text = NSLocalizedString(@"正在载入", nil);
}

- (void)hideIndicator
{
    [indicator stopAnimating];
}


@end
