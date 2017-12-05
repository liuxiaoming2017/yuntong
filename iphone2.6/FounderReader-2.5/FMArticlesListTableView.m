//
//  FMNewTableView.m
//  FounderReader-2.5
//
//  Created by 郭 莉慧 on 14-3-1.
//
//

#import "FMArticlesListTableView.h"

@implementation FMArticlesListTableView

@synthesize index;
@synthesize lastupdatetime;

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self) {
        // Initialization code
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.backgroundColor = [UIColor colorWithRed:0xED/255.0 green:0xED/255.0 blue:0xED/255.0 alpha:1];
     
    }
    return self;
}


@end
