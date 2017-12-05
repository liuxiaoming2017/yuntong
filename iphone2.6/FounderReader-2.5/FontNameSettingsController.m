//
//  FontNameSettingsController.m
//  FounderReader-2.5
//
//  Created by chenfei on 5/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FontNameSettingsController.h"

@interface FontNameSettingsController ()

@end

@implementation FontNameSettingsController

//- (void)dealloc
//{
//    DELETE(_talbeView);
//    
//    [super dealloc];
//}

- (void)loadView
{
    _talbeView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    _talbeView.delegate = self;
    _talbeView.dataSource = self;
    self.view = _talbeView;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.title = NSLocalizedString(@"个性化字体",nil);
    [self leftBackButton];
}

-(void)leftBackButton
{
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
    {
        UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"whiteBack"] style:UIBarButtonItemStylePlain target:self action:@selector(goRightPageBack)];
        self.navigationItem.leftBarButtonItem = leftItem;
 
    }else{
        UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *leftImage = [UIImage imageNamed:@"whiteBack"];
        [leftButton setBackgroundImage:leftImage forState:UIControlStateNormal];
        leftButton.frame = CGRectMake(0, 0, leftImage.size.width, leftImage.size.height);
        [leftButton addTarget:self action:@selector(goRightPageBack) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
        self.navigationItem.leftBarButtonItem = leftItem;
 
    }
    
    self.navigationItem.rightBarButtonItem = nil;
}

-(void)goRightPageBack
{
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [Global setFontName:cell.textLabel.text];
    [_talbeView reloadData];
}

#pragma mark - table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    
    // config cell
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.row == 0)
        cell.textLabel.text = NSLocalizedString(@"系统默认字体",nil);
    else if (indexPath.row == 1)
        cell.textLabel.text = @"方正兰亭纤黑";
    
    if ([cell.textLabel.text compare:[Global fontShowName]] == NSOrderedSame)
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    else
        cell.accessoryType = UITableViewCellAccessoryNone;
    return cell;
}


@end
