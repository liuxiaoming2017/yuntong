//
//  MyBasicViewController.h
//  FounderReader-2.5
//
//  Created by ld on 15-2-4.
//
//

#import "ChannelPageController.h"
#import "MiddleCell.h"
#import "UserAccountDefine.h"
#import "FileLoader.h"
#import "EGORefreshTableHeaderView.h"

@interface MyBasicViewController : ChannelPageController<EGORefreshTableHeaderDelegate>
{
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL hasMore;
    BOOL _reloading;
}


@property (nonatomic, retain) NSArray *dataArray;
@property (nonatomic, retain) UIImageView *bgImageView;
@property (nonatomic, retain) UILabel *noDataLabel;
@property (nonatomic, retain) UITableView *basicTableView;

-(void)showNoDataPage;
-(void)showListPage;

- (void)downLoadData;
-(void)downLoadDataFinished;
-(void)downLoadDataFail;

- (void)downLoadMoreData;
-(void)downLoadMoreDataFinished;
-(void)downLoadMoreDataFail;
@end
