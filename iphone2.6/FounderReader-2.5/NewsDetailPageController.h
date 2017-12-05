//
//  NewsDetailPageController.h
//  FounderReader-2.5
//
//  Created by chenfei on 5/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DetailPageController.h"
#import "QuadCurveMenu.h"

@interface NewsDetailPageController : DetailPageController <QuadCurveMenuDelegate> {
    UIButton *preButton;
    UIButton *nextButton;
    UIBarButtonItem *collectItem;
    NSMutableDictionary *saveIsAgreeDic;
    UIButton *collectButton;
    UIButton *greatButton;
    BOOL isNight;
    UIView *_viewNight;
    UIView *_viewFont;
    UILabel *_lableFont;
}
@property(nonatomic, assign) int subNum;
@property(nonatomic, retain) UIImage *sharedImage;
@property(nonatomic, retain) NSString *sharedImageUrl;
@property(nonatomic, retain) NSString *attAbstract;
@property(nonatomic,assign) BOOL isAudioPlay;
@property(nonatomic, retain) UIView *hudView;
@property(nonatomic, retain) UIView *bringView;

// virtual
- (void)reload;
- (void)addWebView;
- (void)zoomInOut:(NSString *)size;
- (void)zoomInOut:(NSString *)size  withIS:(int)top;
// protected:
- (void)playVideo:(NSString *)urlString;
- (void)collect:(Article *)article;

@end
