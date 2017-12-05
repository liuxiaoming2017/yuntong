//
//  SeeDirectView.h
//  FounderReader-2.5
//
//  Created by lx on 15/8/18.
//
//

#import <UIKit/UIKit.h>
#import "SeeRootViewController.h"
#import "SeeViewmodel.h"
#import "DirectFram.h"
#import "LiveFrame.h"
#import "EGORefreshTableHeaderView.h"
#import "Column.h"

@interface SeeDirectView : UIView<UITableViewDataSource,UITableViewDelegate,EGORefreshTableHeaderDelegate>
{
    BOOL isAn;
    BOOL isHiden;
    UILabel *la;
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL hasMore;
    
}
@property (nonatomic, retain) NSMutableArray *dirArray;
@property (nonatomic, retain) UITableView *directtableview;
@property (nonatomic, retain) UIButton *button;
@property (nonatomic, retain) NSArray *arr;
@property (nonatomic, assign) int fileid;
@property (nonatomic, assign) int aid;
@property (nonatomic, assign) int articleType;
@property (nonatomic, retain) SeeViewmodel *mainModel;
@property (nonatomic, retain) DirectFram *liveDirectfram;
@property (nonatomic, retain) UIViewController *controller;
@property (nonatomic, retain) Column *column;
@property (nonatomic, retain) Article *article;
typedef void(^block)();
@property (nonatomic, copy) block block;
@property (nonatomic,copy) void(^playerButtonClickedBlock)(NSURL*urlStr);


-(void)creatDirect;
//- (instancetype)initWithFileId:(int)FileId;

- (void)shareAllButtonClickHandler:(UIButton *)sender;

@end
