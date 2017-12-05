//
//  PeopleDailyDataChannelController.h
//  FounderReader-2.5
//
//  Created by ld on 14-3-18.
//
//

#import <UIKit/UIKit.h>

@interface PeopleDailyDataChannelController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
      
}

@property(nonatomic,retain) UITableView *pdfTableView;
@property(nonatomic,retain) NSArray *paperArray;
@property(nonatomic, retain) NSArray *allPages;
@property(nonatomic, retain) NSString *selectedDate;
@property(nonatomic, retain) NSMutableArray *pagesWithArticle;

-(void)loadAllPagesFinishedForOnePaper;

- (void)loadPaperLayouts:(NSString*)paperId date:(NSString *)date;
@end
