//
//  ABELTableView.h
//  ABELTableViewDemo
//
//  Created by abel on 14-4-28.
//  Copyright (c) 2014年 abel. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol BATableViewDelegate;
@interface BATableView : UIView
@property (nonatomic, retain) UITableView * tableView;
@property (nonatomic, retain) id<BATableViewDelegate> delegate;
- (void)reloadData;
@end

@protocol BATableViewDelegate <UITableViewDataSource,UITableViewDelegate>

- (NSArray *)sectionIndexTitlesForABELTableView:(BATableView *)tableView;


@end
