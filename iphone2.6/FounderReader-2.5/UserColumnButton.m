//
//  UserColumnButton.m
//  FounderReader-2.5
//
//  Created by ld on 14-8-13.
//
//

#import "UserColumnButton.h"

@implementation UserColumnButton
@synthesize badgeLabel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
       
        self.thumbnail.frame = CGRectMake(0, 0, 38, 38);
        self.thumbnail.center = CGPointMake(self.frame.size.width/2, (self.frame.size.height-15)/2-2);
        self.nameLabel.center = CGPointMake(self.frame.size.width/2, (self.frame.size.height-30)/2+self.thumbnail.frame.size.height-2);
        self.nameLabel.textColor = [UIColor whiteColor];
        self.nameLabel.font = [UIFont systemFontOfSize:11];
        badgeLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        self.badgeLabel.backgroundColor = [UIColor redColor];
        self.badgeLabel.font = [UIFont systemFontOfSize:8];
        self.badgeLabel.textColor = [UIColor whiteColor];
        self.badgeLabel.textAlignment = NSTextAlignmentCenter;
        self.badgeLabel.layer.masksToBounds = YES;
        self.badgeLabel.layer.cornerRadius = 25;
        [self addSubview:self.badgeLabel];
        
    }
    return self;
}

@end
