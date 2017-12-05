//
//  SearchTableViewController.h
//  FounderReader-2.5
//
//  Created by sa on 15-7-16.
//
//

#import <UIKit/UIKit.h>

@protocol SearchTableViewDelegate;
@interface SearchTableViewController : UIViewController<UISearchBarDelegate>
{
    NSMutableArray *dataSoureResult;
    NSMutableArray *dataSoureFilterResult;
    id<SearchTableViewDelegate>  _delegate;
}

@property (nonatomic, retain) NSArray *columns;
@property (nonatomic, assign) BOOL isSearch;
@property (nonatomic, assign) id<SearchTableViewDelegate> delegate;
@end

@protocol SearchTableViewDelegate <NSObject>
@optional
- (void)refresh:(int) columnID;
- (void)backValue:(int) columnID withName:(NSString *)columuName;
@end
