//
//  FavoritePageController.m
//  FounderReader-2.5
//
//  Created by chenfei on 4/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FavoritePageController.h"
#import "NewsListConfig.h"
#import "Article.h"
#import "TableViewCell.h"
#import "FavoriteCell.h"
#import "TemplateDetailPageController.h"
#import "CacheManager.h"
#import "ImageDetailPageController.h"
#import "TemplateNewDetailViewController.h"
#import "ColumnBarConfig.h"
#import "NewsCellUtil.h"
#import "ColorStyleConfig.h"

@interface FavoritePageController () {
    NSString *_backFileID;
}

@property (nonatomic, strong) UIView *audioView;
@property (nonatomic, strong) UIButton *titleBtn;
@property (nonatomic, strong) UIButton *closeBtn;
@property (nonatomic, strong) UIImageView *hornImageView;
@property (nonatomic, strong) UIButton *operationBtn;
@property (nonatomic, strong) UIProgressView *progress;

@end

@implementation FavoritePageController

@synthesize articles;


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self rightPageNavTopButtons];
    self.editButtonItem.tintColor = [ColorStyleConfig sharedColorStyleConfig].navbar_titlecolor_selected;
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kSWidth , kSHeight - 64) style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = [UIColor whiteColor];
    //剔除tableview出数据之前现满屏空白cell
    //[_tableView setTableFooterView:[[UIView alloc] init]];
    [self.view addSubview: _tableView];
}

- (void)showHudView
{
    _hudView.hidden = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    [self titleLableWithTitle:NSLocalizedString(@"我的收藏",nil)];
    self.articles = [[CacheManager sharedCacheManager] favoriteArticles];
    if (self.articles.count == 0) {
        _hudView = [[UIView alloc] init];
        _hudView.frame = CGRectMake(0, (kSHeight-100-49-64)/2, kSWidth, 120);
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"holdIMG"]];
        _hudView.hidden = YES;
        imageView.frame = CGRectMake((kSWidth-50)/2, 0, 50, 50);
        UILabel *labelT = [[UILabel alloc] init];
        labelT.frame = CGRectMake(0, 60, kSWidth, 50);
        labelT.text = NSLocalizedString(@"您还没有任何收藏哦!",nil);
        labelT.textColor = [UIColor grayColor];
        labelT.textAlignment = NSTextAlignmentCenter;
        labelT.font = [UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleCellTitleFontSize];
        [_hudView addSubview:labelT];
        [_hudView addSubview:imageView];
        [self.view addSubview:_hudView];
        [self performSelector:@selector(showHudView) withObject:nil afterDelay:1];
        self.navigationItem.rightBarButtonItem = nil;
    }
    else
    {
        _hudView.hidden = YES;
        self.navigationItem.rightBarButtonItem = [self editButtonItem];
    }
    
    [_tableView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];

    [_tableView setEditing:editing animated:animated];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return UITableViewCellEditingStyleDelete;
}

#pragma mark - table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [NewsListConfig sharedListConfig].middleCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == [self.articles count]) {
        return;
    }
    else
    {
        Article *currentAricle = nil;
        if (self.articles.count > indexPath.row) {
            currentAricle = [self.articles objectAtIndex:indexPath.row];
        }
        Column *column = [[Column alloc] init];
        [NewsCellUtil clickNewsCell:currentAricle column:column in:self];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    Article *article = [articles objectAtIndex:indexPath.row];
    [[CacheManager sharedCacheManager] unCollect:article.fileId];
    
    NSMutableArray *tmpArray = [NSMutableArray arrayWithArray:articles];
    [tmpArray removeObjectAtIndex:indexPath.row];
    self.articles = tmpArray;
    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                     withRowAnimation:UITableViewRowAnimationAutomatic];
    
    if (self.articles.count) {
        self.navigationItem.rightBarButtonItem = [self editButtonItem];
    }else{
        self.navigationItem.rightBarButtonItem = nil;
    }
}

#pragma mark - table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [articles count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    FavoriteCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FavoriteCell"];
        if (cell == nil)
            cell = [[FavoriteCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FavoriteCell"];
    
    cell.shouldIndentWhileEditing = NO;
    
    if (articles.count > indexPath.row) {
        Article *article = [articles objectAtIndex:indexPath.row];
        
        [cell configMyFavoriteArticle:article];
    }
   
    for (UIView *subview in cell.contentView.subviews) {
        if (![NSStringFromClass([subview class]) isEqualToString:@"ImageViewCf"])
            subview.autoresizingMask = UIViewAutoresizingNone;
        cell.contentView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    }
   
    UIImageView *selectedImageView = [[UIImageView alloc] initWithFrame:cell.bounds];
    selectedImageView.backgroundColor = [UIColor colorWithRed:0xe8/255.0 green:0xe8/255.0 blue:0xe8/255.0 alpha:1];
    cell.selectedBackgroundView = selectedImageView;
    
    return cell;
}

-(void)viewDidLayoutSubviews
{
    if ([_tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [_tableView setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
    }
    
    if ([_tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [_tableView setLayoutMargins:UIEdgeInsetsMake(0,0,0,0)];
    }
}

-(void)goRightPageBack
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
@end


