//
//  ImageDetailPageController.h
//  FounderReader-2.5
//
//  Created by chenfei on 5/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DetailPageController.h"
#import "ArrayPageController.h"
#import "SummaryView.h"
#import "Column.h"
#import "CacheManager.h"
#import "ATPagingView.h"

@interface ImageDetailPageController : DetailPageController <ATPagingViewDelegate, ArrayPageControllerDelegate,UITextViewDelegate> {
    ATPagingView *pagingView;
    SummaryView  *summaryView;
    SummaryView  *summaryViewFen;
    BOOL isSummaryViewShow;
    UIButton *btnBack;
    UILabel *_fenlabel;
    NSArray *pictures;
    UIButton *greatButton;
    UIButton *collectButton;
    UIBarButtonItem *collectItem;
}
@property(nonatomic,retain) SummaryView *summaryViewFenTop;
@property(nonatomic,retain) UIButton *btnDownLoad;
@property(nonatomic,retain) UILabel *lab;
@property(nonatomic, retain) NSNumber *openFirstIndex;
@property(nonatomic, assign) int isFirst;
- (void)loadAttachment;
- (void)updateIndex;

@end
