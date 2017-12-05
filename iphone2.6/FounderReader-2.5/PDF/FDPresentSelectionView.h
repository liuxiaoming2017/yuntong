//
//  FDPresentSelectionView.h
//  FounderReader-2.5
//
//  Created by snitsky on 2017/1/13.
//
//

#import <UIKit/UIKit.h>

@class FDPresentSelectionView;

@protocol FDPresentSelectionViewDelegate <NSObject>

@optional
- (CGFloat)selectionView:(FDPresentSelectionView *)selectionView heightForRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)selectionView:(FDPresentSelectionView *)selectionView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@protocol FDPresentSelectionViewDataSource <NSObject>

@required
- (NSInteger)selectionView:(FDPresentSelectionView *)selectionView numberOfRowsInSection:(NSInteger)section;

- (UITableViewCell *)selectionView:(FDPresentSelectionView *)selectionView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface FDPresentSelectionView : UIView

@property (nonatomic, weak) id <FDPresentSelectionViewDataSource> dataSource;
@property (nonatomic, weak) id <FDPresentSelectionViewDelegate> delegate;

@property (strong, nonatomic) UITableView *tableView;

- (instancetype)initWithPresentTableViewFrame:(CGRect)frame;

- (void)show;

- (void)hide;

- (void)reloadData;

@end
