//
//  FontSettingsController.m
//  FounderReader-2.5
//
//  Created by chenfei on 5/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FontSettingsController.h"
#import "NewsListConfig.h"
#import "ColumnBarConfig.h"
#import "UIView+Extention.h"
#import "ColorStyleConfig.h"

@interface FontSettingsController ()<UIGestureRecognizerDelegate>
{
    NSArray *_announcerArr;
    NSArray *_announcerKeyArr;
}
@end

@implementation FontSettingsController

//- (void)dealloc
//{
//    DELETE(_talbeView);
//    
//    [super dealloc];
//}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self leftBackButton];
    
    _announcerArr = @[NSLocalizedString(@"优美女音普通话",nil), NSLocalizedString(@"浑厚男音普通话",nil), NSLocalizedString(@"标准女音粤语",nil), NSLocalizedString(@"标准女音台湾话",nil)];
    _announcerKeyArr = @[@"xiaoyan", @"xiaoyu", @"vixm", @"vixl"];
    
    _talbeView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kSWidth, kSHeight)];
    _talbeView.delegate = self;
    _talbeView.dataSource = self;
    _talbeView.tableFooterView = [[UIView alloc] init];
    _talbeView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview: _talbeView];
}

-(void)leftBackButton
{
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftButton setImage:[UIImage imageNamed:@"nav_bar_back"] forState:UIControlStateNormal];
    [leftButton sizeToFit];
    leftButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    leftButton.contentEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
    [leftButton addTarget:self action:@selector(goLastPageBack) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    UILabel *navTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 140, 44)];
    navTitleLabel.text = self.isSetupVoice ? NSLocalizedString(@"播报员设置",nil) : NSLocalizedString(@"正文字号",nil);
    navTitleLabel.font = [UIFont boldSystemFontOfSize:18];
    navTitleLabel.textAlignment = NSTextAlignmentCenter;
    navTitleLabel.backgroundColor = [UIColor clearColor];
    navTitleLabel.textColor = [ColorStyleConfig sharedColorStyleConfig].navbar_titlecolor_selected;
    self.navigationItem.titleView = navTitleLabel;
}

-(void)goLastPageBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isSetupVoice) {
        [[NSUserDefaults standardUserDefaults] setObject:_announcerKeyArr[indexPath.row] forKey:@"VoiceAnnouncer"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }else {
        NSString *font = @"";
        if (indexPath.row == 0) {
            font = @"sm";
        }
        else if (indexPath.row == 1) {
            font = @"md";
        }
        else if (indexPath.row == 2) {
            font = @"lg";
        }
        else if (indexPath.row == 3) {
            font = @"hg";
        }
        [Global setFontSize:font];
    }
    
    [_talbeView reloadData];
}

#pragma mark - table view data source

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40*proportion;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 40*proportion-1, kSWidth, 1)];
    lineView.backgroundColor = UIColorFromString(@"221,221,221");
    [cell.contentView addSubview:lineView];
    
    UIImageView *img = [[UIImageView alloc]initWithFrame:CGRectMake(kSWidth - 37*proportion, 10, 23*proportion, 23*proportion)];
    img.image = [UIImage imageNamed:@"fontSure"];
    img.hidden = YES;
    [cell.contentView addSubview:img];
    
    if (self.isSetupVoice) {
        cell.textLabel.text = _announcerArr[indexPath.row];
        cell.textLabel.font = [UIFont systemFontOfSize:[NewsListConfig sharedListConfig].leftUserNameFontSize-2];
        NSString *voiceAnnouncer = [[NSUserDefaults standardUserDefaults] objectForKey:@"VoiceAnnouncer"];
        img.hidden = (voiceAnnouncer && [voiceAnnouncer isEqualToString: _announcerKeyArr[indexPath.row]]) ? NO : YES;
    }else {
        if (indexPath.row == 0){
            cell.textLabel.font  = [UIFont systemFontOfSize:12*proportion];
            cell.textLabel.text = NSLocalizedString(@"小",nil);
        }
        else if (indexPath.row == 1)
        {
            cell.textLabel.font  = [UIFont systemFontOfSize:14*proportion];
            cell.textLabel.text = NSLocalizedString(@"中",nil);
        }
        else if (indexPath.row == 2){
            cell.textLabel.font  = [UIFont systemFontOfSize:16*proportion];
            cell.textLabel.text = NSLocalizedString(@"大",nil);
        }
        else if (indexPath.row == 3){
            cell.textLabel.font  = [UIFont systemFontOfSize:18*proportion];
            cell.textLabel.text = NSLocalizedString(@"超大",nil);
        }
        NSString *font = @"";
        if (indexPath.row == 0) {
            font = @"sm";
        }
        else if (indexPath.row == 1) {
            font = @"md";
        }
        else if (indexPath.row == 2) {
            font = @"lg";
        }
        else if (indexPath.row == 3) {
            font = @"hg";
        }
        
        img.hidden = [font isEqualToString:[Global fontSize]] ? NO : YES;
    }
    
    return cell;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (self.childViewControllers.count == 1) {
        return NO;
    }
    return YES;
}

@end
