//
//  GovSubscribeController.m
//  FounderReader-2.5
//
//  Created by 黄柳姣 on 2017/12/1.
//

#import "GovSubscribeController.h"
#import "ColorStyleConfig.h"
#import "GovSubscribeCell.h"
#import "GovSubLeftCell.h"
#import "SearchToolBarView.h"
#import "GovSubTypeViewController.h"

static NSString *leftIdentifier = @"leftIdentifier";
static NSString *rightIdentifier = @"rightIdentifier";


@interface GovSubscribeController ()<UITableViewDelegate,UITableViewDataSource,GovSubscribeCellDelegate>

@property(nonatomic,strong)UITableView *leftTableView;
@property(nonatomic,strong)UITableView *rightTableView;
@property (nonatomic,assign) NSInteger leftLastIndexPath;

@end

@implementation GovSubscribeController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNav];
    [self setupUI];
}

- (void)setupNav
{
    self.title = NSLocalizedString(@"添加订阅",nil);
    // 设置导航默认标题的颜色及字体大小
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [ColorStyleConfig sharedColorStyleConfig].navbar_titlecolor_didselect,
                                                                    NSFontAttributeName : [UIFont boldSystemFontOfSize:18]};
    
    UIButton *preBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    preBtn.tag = 111;
    [preBtn setImage:[UIImage imageNamed:@"nav_bar_back"] forState:UIControlStateNormal];
    [preBtn sizeToFit];
    preBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    preBtn.contentEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
    [preBtn addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:preBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
}

- (void)setupUI
{
    //搜索视图
    SearchToolBarView *searchBarView = [[SearchToolBarView alloc] initWithFrame:CGRectMake(0, 0, kSWidth, 40)];
    [self.view addSubview:searchBarView];
    
    //左边表视图
    self.leftTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 40, 80, kSHeight-20-44-40) style:UITableViewStylePlain];
    self.leftTableView.backgroundColor=[UIColor clearColor];
    self.leftTableView.backgroundView=nil;
    self.leftTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    self.leftTableView.delegate=self;
    self.leftTableView.dataSource=self;
    self.leftTableView.showsVerticalScrollIndicator=NO;
    [self.view addSubview:self.leftTableView];
    self.leftLastIndexPath=0;
    
    
    //中间隔线
    UIImageView *middleImg = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.leftTableView.frame)+1, self.leftTableView.frame.origin.y, 1, self.leftTableView.frame.size.height)];
    middleImg.backgroundColor=[UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1.0];
    [self.view addSubview:middleImg];
    
    //右边表视图
    self.rightTableView = [[UITableView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(middleImg.frame), self.leftTableView.frame.origin.y, kSWidth-CGRectGetMaxX(middleImg.frame), self.leftTableView.frame.size.height) style:UITableViewStylePlain];
    self.rightTableView.backgroundView=nil;
    self.rightTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    self.rightTableView.backgroundColor=[UIColor clearColor];
    self.rightTableView.dataSource=self;
    self.rightTableView.delegate=self;
    self.rightTableView.showsVerticalScrollIndicator=NO;
    [self.rightTableView registerNib:[UINib nibWithNibName:@"GovSubscribeCell" bundle:nil] forCellReuseIdentifier:rightIdentifier];
    [self.view addSubview:self.rightTableView];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView==self.leftTableView){
        return 40;
    }else{
        return 80;
    }
    return 80;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView==self.leftTableView){
        return 3;
    }else if (tableView == self.rightTableView){
        return 16;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if(tableView==self.leftTableView){
        GovSubLeftCell *cell1=[tableView dequeueReusableCellWithIdentifier:leftIdentifier];
        if(!cell1){
            cell1 = [[GovSubLeftCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:leftIdentifier];
             cell1.selectionStyle=UITableViewCellSelectionStyleNone;
        }
       
        if(indexPath.row==0){
            cell1.contentLabel.textColor=[UIColor redColor];
            cell1.selectLine.hidden=NO;
        }
        return cell1;
    }else if (tableView==self.rightTableView){
        GovSubscribeCell *cell2 = [tableView dequeueReusableCellWithIdentifier:rightIdentifier];
        if(!cell2){
            cell2 = [[GovSubscribeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:rightIdentifier];
            
        }
        cell2.delegate=self;
        return cell2;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView==self.leftTableView){
        
        GovSubLeftCell *cell1 = [self.leftTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.leftLastIndexPath inSection:0]];
        cell1.contentLabel.textColor=[UIColor blackColor];
        cell1.selectLine.hidden=YES;
        
        GovSubLeftCell *cell = [self.leftTableView cellForRowAtIndexPath:indexPath];
        cell.contentLabel.textColor=[UIColor redColor];
        cell.selectLine.hidden=NO;
        self.leftLastIndexPath=indexPath.row;
    }
}

-(void)buttonClickCell:(UITableViewCell *)tableViewCell
{
    NSIndexPath *indexPath = [self.rightTableView indexPathForCell:tableViewCell];
    //GovSubscribeCell *cell = (GovSubscribeCell *)tableViewCell;
    NSLog(@"haha:%ld",indexPath.row);
    [Global showCustomMessage:@"您已成功定制此栏目"];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
}

- (void)goBack
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
