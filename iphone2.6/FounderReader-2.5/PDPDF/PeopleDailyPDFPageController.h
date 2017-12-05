//
//  PeopleDailyPDFPageController.h
//  FounderReader-2.5
//
//  Created by ld on 14-3-10.
//
//

#import <UIKit/UIKit.h>

@interface PeopleDailyPDFPageController:UIViewController{
}

@property(nonatomic, retain) NSArray *allPages;
@property(nonatomic, retain) NSString *selectedDate;
@property (nonatomic, assign) int isMain;
@property(nonatomic, retain) UILabel *pdfTimeLabel;
- (id)initWithFrame:(CGRect)rect isMain:(int)isMain;
-(void)reloadPage;
@end
