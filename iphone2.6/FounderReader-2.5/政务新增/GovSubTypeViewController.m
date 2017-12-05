//
//  GovSubTypeViewController.m
//  FounderReader-2.5
//
//  Created by 黄柳姣 on 2017/12/4.
//

#import "GovSubTypeViewController.h"
#import "ColorStyleConfig.h"
#import "ArticleRequest.h"
#import "Article.h"
#import "MiddleCell.h"
#import "NewsCellUtil.h"

@interface GovSubTypeViewController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong)NSArray *dataArr;
@end

@implementation GovSubTypeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNav];
    [self initUI];
    [self requestData];
}

- (void)requestData
{
    ArticleRequest *request = [ArticleRequest articleRequestWithColumnId:116 lastFileId:0 count:20 rowNumber:0];
    [request setCompletionBlock:^(NSArray *arr) {
        self.dataArr=arr;
        [self.tableView reloadData];
    }];
    [request setFailedBlock:^(NSError *error) {
        
    }];
    [request startAsynchronous];
}

- (void)initUI
{
    navTitleLabel.text=@"省水利厅";
    //表视图
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kSWidth, kSHeight-20-44) style:UITableViewStylePlain];
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
}

- (void)setupNav
{
    
    self.title = NSLocalizedString(@"省科技局",nil);
    // 设置导航默认标题的颜色及字体大小
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [ColorStyleConfig sharedColorStyleConfig].navbar_titlecolor_didselect,
                                                                    NSFontAttributeName : [UIFont boldSystemFontOfSize:18]};
    
    UIButton *preBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    preBtn.tag = 111;
    [preBtn setImage:[UIImage imageNamed:@"nav_bar_back"] forState:UIControlStateNormal];
    [preBtn sizeToFit];
    preBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    preBtn.contentEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
    [preBtn addTarget:self action:@selector(goBack2) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:preBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn setImage:[UIImage imageNamed:@"login_country"] forState:UIControlStateNormal];
    [rightBtn setImage:[UIImage imageNamed:@"login_user"] forState:UIControlStateSelected];
    [rightBtn addTarget:self action:@selector(rightAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArr.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(cell==nil){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        
    }
    Article *article = nil;
    if(self.dataArr.count>indexPath.row){
        article = [self.dataArr objectAtIndex:0];
        cell=[NewsCellUtil getNewsCell:article in:tableView];
        
    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    Article *article = nil;
    if (self.dataArr.count > indexPath.row) {
        article = [self.dataArr objectAtIndex:indexPath.row];
    }
    
    return [NewsCellUtil getNewsCellHeight:article];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    Article *currentAricle = nil;
    if (self.dataArr.count > indexPath.row) {
        currentAricle = [self.dataArr objectAtIndex:indexPath.row];
    }
    Column *column = [columns objectAtIndex:columnBar.selectedIndex];
    
    [NewsCellUtil clickNewsCell:currentAricle column:column in:self];
    
    
    
}


//订阅按钮
- (void)rightAction:(UIButton *)button
{
    button.selected=!button.selected;
}

- (void)goBack2
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
}





@end
