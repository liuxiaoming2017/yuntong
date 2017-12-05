//
//  PoliticalLocalPageController.m
//  FounderReader-2.5
//
//  Created by Julian on 16/7/27.
//
//

#import "PoliticalLocalController.h"
#import "ColumnRequest.h"
#import "Column.h"
#import "UIImageView+WebCache.h"
#import "PoliticalPageController.h"
#import "UIView+Extention.h"
#import "ColorStyleConfig.h"
#import "AppStartInfo.h"
#define kColumnCountEachRow 2
#define kMargin 10.0f
#define kColumnW (kSWidth - (kColumnCountEachRow + 1)*kMargin)*1.0f/kColumnCountEachRow
#define kColumnH kColumnW * 9/16.0f

@interface PoliticalLocalController ()
{
    NSMutableArray *_dataArr;
}
@end

@implementation PoliticalLocalController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self downLoadData];
    
    //设置导航条
    [self settingNavi];
    
    //设置图标
    [self settingIcon];
    
}
- (void)downLoadData
{
    _dataArr = [[NSMutableArray alloc] init];
    
    int columnId = [self.parentColumn.keyword[@"areaColumnID"] intValue];
    
    ColumnRequest *request = [ColumnRequest columnRequestWithParentColumnId:columnId];
    [request setCompletionBlock:^(NSArray *array) {
        
        if (array.count != 0) {
            for (int i = 0; i < array.count; i++) {
                Column *column = [array objectAtIndex:i];
                [_dataArr addObject:column];
            }
            [self settingIcon];
        }
    }];
    
    [request setFailedBlock:^(NSError *error) {
        [Global showTipNoNetWork];
    }];
    [request startAsynchronous];
}

- (void)settingIcon
{
    if (!_dataArr.count) {
        return;
    }
    
    for (int i = 0; i < _dataArr.count; i++) {
        
        Column *column = _dataArr[i];
        
        CGFloat MarginY = self.isFromColumnBar ? kMargin + 64 : kMargin;
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(kMargin + i%kColumnCountEachRow * (kColumnW + kMargin), MarginY +  i/kColumnCountEachRow * (kColumnH + kMargin), kColumnW, kColumnH)];
        UITapGestureRecognizer * tpg = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(click:)];
        [bgView addGestureRecognizer:tpg];
        bgView.userInteractionEnabled = YES;
        bgView.tag = 1314 + i;
        [self.view addSubview:bgView];
        
        UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kColumnW, kColumnH)];
        [imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@@!md169", column.iconUrl]] placeholderImage:[Global getBgImage169]];
        [bgView addSubview:imageView];
       
        UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, kColumnH - 24, kColumnW, 24)];
        label.font = [UIFont systemFontOfSize:15];
        label.textColor = [UIColor whiteColor];
        label.backgroundColor = [UIColor blackColor];
        label.alpha = 0.7;
        label.text = column.columnName;
        label.textAlignment = NSTextAlignmentCenter;
        [bgView addSubview:label];
    }
    
}

- (void)click:(UITapGestureRecognizer *)tpg
{
    PoliticalPageController *politicalController = [[PoliticalPageController alloc] initWithColumn:_dataArr[tpg.view.tag - 1314] withIsMain:0];
    politicalController.isFromLocalPolitical = YES;
    politicalController.isFromColumnBar = self.isFromColumnBar;
    [self.navigationController pushViewController:politicalController animated:YES];
}

- (void)settingNavi
{
    [self setupNavTitle];
    
    self.navigationController.navigationBarHidden = NO;
    self.tabBarController.tabBar.hidden = YES;
    
    //左边返回按钮
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftButton setImage:[UIImage imageNamed:@"nav_bar_back"] forState:UIControlStateNormal];
    leftButton.frame = CGRectMake(17, 20+(44-23)/2.0, 23, 23);
    leftButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    leftButton.contentEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
    [leftButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
}

- (void)setupNavTitle
{
    UILabel *navTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 140, 43)];
    navTitleLabel.text = NSLocalizedString(@"地方政情",nil);
    navTitleLabel.font = [UIFont systemFontOfSize:18];
    navTitleLabel.textAlignment = NSTextAlignmentCenter;
    navTitleLabel.backgroundColor = [UIColor clearColor];
    navTitleLabel.textColor = [ColorStyleConfig sharedColorStyleConfig].navbar_titlecolor_selected;
    self.navigationItem.titleView = navTitleLabel;
}

- (void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
