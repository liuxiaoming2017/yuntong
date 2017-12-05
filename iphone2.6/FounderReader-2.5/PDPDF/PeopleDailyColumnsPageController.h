//
//  PeopleDailyColumnsPageController.h
//  FounderReader-2.5
//
//  Created by ld on 14-3-14.
//
//

#import <UIKit/UIKit.h>
#import "ChannelPageController.h"

@protocol PDFPagerChangeDelegate <NSObject>

-(void)updatePaper:(NSString *)paperId date:(NSString *)date;

@end

@interface PeopleDailyColumnsPageController : ChannelPageController <UITextFieldDelegate>

@property(nonatomic,assign) id <PDFPagerChangeDelegate> pdfDelegate;
@property(nonatomic,retain) UIButton *readBtn;
@property(nonatomic,retain) NSArray *leftArray;
@end
