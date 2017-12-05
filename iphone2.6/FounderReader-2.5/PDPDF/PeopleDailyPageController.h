//
//  PeopleDailyPageController.h
//  FounderReader-2.5
//
//  Created by ld on 14-3-5.
//
//

#import <UIKit/UIKit.h>
//#import "ChannelPageController.h"
#import "PDFColumnBar.h"
#import "DataChannelPageController.h"
#import "PeopleDailyPDFPageController.h"
#import "PeopleDailyColumnListPageController.h"

@interface PeopleDailyPageController :  DataChannelPageController <PDFColumnBarDelegate, PDFColumnBarDataSource> {
   

}
@property (nonatomic, retain) Column *column;
@property (nonatomic, retain) PeopleDailyColumnListPageController *columnListController;
@property (nonatomic, retain) PeopleDailyPDFPageController *pdfPageController;
@property (nonatomic, assign) NSInteger currentColumnIndex;
@property (nonatomic, assign) int navStyle;
@property(nonatomic, retain) NSArray *allPages;
@property (nonatomic, retain) NSArray *paperArray;
@property(nonatomic, retain) NSMutableArray *pagesWithArticle;
- (id)initWithColumn:(Column *)column withIsMain:(int)isMain;
@end
