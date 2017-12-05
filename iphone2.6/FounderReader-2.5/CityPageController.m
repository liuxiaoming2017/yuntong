//
//  LocationPageController.m
//  FounderReader-2.5
//
//  Created by lx on 15/8/26.
//
//

#import "CityPageController.h"
#import "ColumnBarConfig.h"
#import "ColumnRequest.h"
#import "ColumnButton.h"
#import "Column.h"
#import "NewsPageController.h"
#import "ColorStyleConfig.h"
#define buttonWith 90
#define buttonLeftW 10
@interface CityPageController ()
{
    UIView *_myView;
}
@end

@implementation CityPageController
@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _myView = [[UIView alloc] init];
    _myView.frame = CGRectMake(buttonLeftW, 50, [UIScreen mainScreen].bounds.size.width-2*buttonLeftW, [UIScreen mainScreen].bounds.size.height-50-64-60);
    [self.view addSubview:_myView];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self.tabBarController.tabBar setHidden:YES];
    [self.navigationController.navigationBar setTranslucent:NO];
    [self configWebViewToolBar];
    
    [self configTopChannelsButton];
}

-(void)configWebViewToolBar
{
    UIView *toolBarView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kSWidth, 64)];
    toolBarView.backgroundColor=[UIColor colorWithPatternImage:[Global navigationImage]];
    toolBarView.userInteractionEnabled = YES;
    [self.view addSubview:toolBarView];
    
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 20, kSWidth-80, 44)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    titleLabel.textAlignment = 1;
    titleLabel.textColor = [ColorStyleConfig sharedColorStyleConfig].navbar_titlecolor_didselect;//[ColumnBarConfig sharedColumnBarConfig].columnNameFontColor;
    titleLabel.text = NSLocalizedString(@"城市切换", nil);
    titleLabel.tag = 222;
    [toolBarView addSubview:titleLabel];
    
    
    UIButton *preBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 31, 22, 22)];
    preBtn.tag = 111;
    [preBtn addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [preBtn setBackgroundImage:[UIImage imageNamed:@"nav_bar_back"] forState:UIControlStateNormal];
    [toolBarView addSubview:preBtn];
}

-(void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)viewWillAppear:(BOOL)animated
{

    self.navigationItem.leftBarButtonItem = nil;
    [super viewWillAppear:animated];
    
}
-(void)btnTitleClick:(UIButton *)button
{
    
}

-(void)configTopChannelsButton
{
    
    NSInteger columnNumber = self.columns.count/3;
    if (self.columns.count%3) {
        columnNumber++;
    }
    for (UIView *v in [_myView subviews])
    {
        [v removeFromSuperview];
    }
    for (NSInteger i = 0; i<columnNumber; i++) {
        
        for (NSInteger j = 0; j<3; j++) {
            
            if (i*3+j == self.columns.count) {
                return;
            }
            Column *oneColumn = [self.columns objectAtIndex:i*3+j];
            
            UIButton *columnButton = [[UIButton alloc] initWithFrame:CGRectMake((buttonWith+(_myView.bounds.size.width-3*buttonWith)/2)*(j), 64+40*i, buttonWith, 30)];
            [columnButton setTitle:oneColumn.columnName forState:UIControlStateNormal];
            [columnButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            columnButton.titleLabel.font = [UIFont systemFontOfSize:13];
            columnButton.titleLabel.textAlignment = NSTextAlignmentCenter;
            columnButton.layer.borderWidth = 0.5;
            columnButton.layer.borderColor = [UIColor colorWithRed:221/255 green:221/255 blue:221/255 alpha:0.3].CGColor;
            columnButton.tag = 300+i*3+j;
            [columnButton addTarget:self action:@selector(TopChannelClicked:) forControlEvents:UIControlEventTouchUpInside];
            [_myView addSubview:columnButton];
        }
    }
}

-(void)TopChannelClicked:(ColumnButton*)button
{
    [self.navigationController popViewControllerAnimated:YES];
    
    if ([self.delegate respondsToSelector:@selector(LocationPageController:)])
        [self.delegate LocationPageController:(int)button.tag-300];
    
    //[self.controller changeCity:(int)button.tag-300];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
