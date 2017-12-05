//
//  PeopleDailyColumnListPageController.h
//  FounderReader-2.5
//
//  Created by ld on 14-3-5.
//
//

#import <UIKit/UIKit.h>

@interface PeopleDailyColumnListPageController:UIViewController<UITableViewDataSource,UITableViewDelegate>{
    UILabel *_headerLabel;
}

@property(nonatomic,retain) UITableView *pdfTableView;
@property(nonatomic, retain) NSString *selectedDate;
@property(nonatomic, retain) NSMutableArray *pagesWithArticle;

-(void)reloadPage;

- (instancetype)initWithMain:(BOOL)isMain;

@end
