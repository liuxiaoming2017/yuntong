//
//  SeeRootViewController.h
//  FounderReader-2.5
//
//  Created by lx on 15/8/17.
//
//

#import <UIKit/UIKit.h>
#import "PLPlayer.h"
#import "SeeViewmodel.h"
#import "DirectFram.h"
#import "Column.h"
@class Article;
@interface SeeRootViewController : UIViewController<UIScrollViewDelegate>{
}
@property (nonatomic, retain) SeeViewmodel *mainModel;
@property (nonatomic, retain) DirectFram *liveFrame;
@property (nonatomic, retain) UIScrollView *scrollview;
@property (nonatomic, strong) Article *seeArticle;
@property (nonatomic ,assign) BOOL isNavGoback;
@property (nonatomic, strong) NSString *liveTypeOrStatus;
@property (nonatomic, retain) Column *column;

@end
