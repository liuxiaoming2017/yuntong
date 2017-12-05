//
//  ChannelPageController.h
//  FounderReader-2.5
//
//  Created by chenfei on 4/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UINavigationController+Rotation.h"
#import "ImageViewCf.h"
#import "FounderEventRequest.h"
#import "AppConfig.h"
#import "UIImage+Helper.h"

@class Column,Article;
@interface ChannelPageController : UIViewController{

    Column  *parentColumn;
    UILabel *navTitleLabel;
    UIButton *leftNavButton;
    UIButton *rightNavButton;
    NSArray *subcolumns;
}
@property (nonatomic, retain) Column *parentColumn;
@property (nonatomic, retain) NSArray *subcolumns;
@property (nonatomic, assign) BOOL isPDF;
@property (nonatomic, assign) int isMain;
@property(nonatomic, assign) BOOL isNavGoback;
@property (assign) NSUInteger index;
@property (nonatomic, retain) UIImageView *moreButton;
@property (assign, nonatomic) FDViewControllerType viewControllerType;

- (void)titleLableWithTitle:(NSString *)titleStr;

- (void)rightPageNavTopButtons;
- (void)goRightPageBack;
- (void)leftNavBackButton;
- (void)GetBack;

- (void)left;
- (void)right;
- (void)leftAndRightButton;

- (void)showHeaderTopDetailArticle:(Article*)article withColumn:(Column *)column;
- (void)goBackIOS6Button:(UIViewController *)controller;
- (void)goBackIOS6;
- (void)configBottomBackView;

- (id)initWithColumn:(Column *)column;
- (id)initWithColumn:(Column *)column withIsMain:(int)isMain;
- (id)initWithColumn:(Column *)column viewControllerType:(FDViewControllerType)viewControllerType;
@end
