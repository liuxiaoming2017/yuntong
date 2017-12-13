//
//  GovAffairController.m
//  FounderReader-2.5
//
//  Created by 黄柳姣 on 2017/12/1.
//

#import "GovAffairController.h"
#import "GovSubscribeController.h"
#import "GovSubTypeViewController.h"
#import "ArticleRequest.h"
#import "Article.h"
#import "MiddleCell.h"
#import "NewsCellUtil.h"
#import "ColumnRequest.h"
#import "VideoCell.h"
#import "UIImageView+WebCache.h"
#import "NewsListConfig.h"

@interface GovAffairController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong) UITableView *tableView;
@property(nonatomic,strong) NSArray *dataArr;
@property(nonatomic,strong) NSMutableArray *articleArr;
@property(nonatomic,strong) NSMutableArray *columnArr;
@property(nonatomic,strong) UIImageView *noDataImg;
@property(nonatomic,strong) UILabel *noDataLabel;
@end

@implementation GovAffairController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initWithView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    [self.columnArr removeAllObjects];
    [self requestData];
}

- (void)initWithView
{
    navTitleLabel.text=@"政务";
    self.moreButton.hidden=YES;
    
    self.articleArr = [NSMutableArray arrayWithCapacity:0];
    self.columnArr = [NSMutableArray arrayWithCapacity:0];
    
    UIView *headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kSWidth, 40)];
    UIImageView *imagV = [[UIImageView alloc]initWithFrame:CGRectMake(0, 39, kSWidth, 1)];
    imagV.backgroundColor = [UIColor redColor];
    [headView addSubview:imagV];
    headView.tag=2014;
    headView.backgroundColor=[UIColor whiteColor];
    headView.alpha=0.6;
    [self.view addSubview:headView];
    
    //头部按钮
    NSArray *titleArr = @[@"政务订阅",@"服务大厅"];
    for(NSInteger i=0;i<titleArr.count;i++){
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame=CGRectMake(5+100*i, 0, 100, 39);
        btn.tag=200+i;
        [btn setTitle:[titleArr objectAtIndex:i] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        btn.titleLabel.font=[UIFont systemFontOfSize:16.0];
        [btn setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
        btn.backgroundColor=[UIColor clearColor];
        [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
        if(i==0){
            btn.selected=YES;
        }
        [headView addSubview:btn];
    }
    
    //表视图
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(headView.frame), kSWidth, kSHeight-CGRectGetMaxY(headView.frame)-49-20-44) style:UITableViewStylePlain];
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    self.tableView.backgroundColor=[UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:1.0];
    self.tableView.bounces=YES;
    
    [self noDataShow];
    
    //[self requestData];
    //[self loadArticlesWithColumnId:116 lastFileId:0 rowNumber:0];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(submitSubscribeSuccess) name:@"submitSubscribe" object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cancelSubscribeSuccess) name:@"cancelSubscribe" object:nil];
}

#pragma mark - 获取我的订阅
- (void)requestData
{
    self.noDataImg.hidden=YES;
    self.noDataLabel.hidden=YES;
    __weak typeof(self) weakSelf = self;
    ColumnRequest *request = [ColumnRequest govAffairRequestWithuid:@"getMySubAndArticles"];
    [request setCompletionBlock:^(id data) {
        weakSelf.dataArr=[data objectForKey:@"list"];
        for(NSInteger i=0;i<weakSelf.dataArr.count;i++){
            NSDictionary *dic = [[self.dataArr objectAtIndex:i] objectForKey:@"column"];
            [self.columnArr addObject:dic];
        }
        [weakSelf.tableView reloadData];
        if(weakSelf.dataArr.count==0){
            self.noDataImg.hidden=NO;
            self.noDataLabel.hidden=NO;
        }
    }];
    [request setFailedBlock:^(NSError *error) {
        [weakSelf.tableView reloadData];
        self.noDataImg.hidden=NO;
        self.noDataLabel.hidden=NO;
    }];
    [request startAsynchronous];
}

-(void)noDataShow
{
    self.noDataImg = [[UIImageView alloc]init];
    self.noDataImg.frame = CGRectMake(kSWidth * 0.5, 160, 50*proportion, 50*proportion);
    CGPoint poin = CGPointMake(kSWidth * 0.5, 160*proportion + 64);
    self.noDataImg.center = poin;
    self.noDataImg.image = [UIImage imageNamed:@"holdIMG"];
    [self.view addSubview:self.noDataImg];
    self.noDataImg.hidden=YES;
    
    self.noDataLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.noDataImg.frame) + 20, kSWidth, 20)];
    self.noDataLabel.font = [UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleCellTitleFontSize];
    self.noDataLabel.text = NSLocalizedString(@"您还没有订阅消息哟!",nil);
    self.noDataLabel.textAlignment = NSTextAlignmentCenter;
    self.noDataLabel.textColor = [UIColor grayColor];
    [self.view addSubview:self.noDataLabel];
    self.noDataLabel.hidden=YES;
}

- (void)testScrollView:(UIScrollView *)scrollview{
    CGFloat sectionHeaderHeight = 40;
    //让section头视图和cell一起滚动
    if(scrollview == self.tableView){
   if(scrollview.contentOffset.y<=sectionHeaderHeight&&scrollview.contentOffset.y>=0) {
            scrollview.contentInset = UIEdgeInsetsMake(-scrollview.contentOffset.y, 0, 0, 0);
        } else if (scrollview.contentOffset.y>=sectionHeaderHeight) {
            scrollview.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
        }
        //禁止下拉
        CGPoint offset = self.tableView.contentOffset;
        if (offset.y <= 0) {
            offset.y = 0;
        }
        self.tableView.contentOffset = offset;
    }

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(self.dataArr.count==0){
        return 1;
    }else{
        return self.dataArr.count+1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section==0){
        return 45;
    }
    return 55;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(section == 0){
    UIView *sectionV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSWidth, 45)];
        sectionV.backgroundColor=[UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1.0];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame=CGRectMake(0, 5, kSWidth, 40);
    [button setTitle:@"点此免费添加订阅" forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:13];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonAction) forControlEvents:UIControlEventTouchUpInside];
    button.backgroundColor=[UIColor whiteColor];
    [sectionV addSubview:button];
    return sectionV;
    }else{
        
        NSDictionary *dic = [self.columnArr objectAtIndex:section-1];
        
        UIView *sectionV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSWidth, 55)];
        sectionV.backgroundColor=[UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1.0];
        sectionV.tag = 100+section;
        
        UIImageView *backImgV = [[UIImageView alloc]initWithFrame:CGRectMake(0, 5, kSWidth, 50)];
        backImgV.backgroundColor=[UIColor whiteColor];
        backImgV.userInteractionEnabled=YES;
        
        UIImageView *imgV = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10+5, 30, 30)];
        imgV.contentMode=UIViewContentModeScaleToFill;
        [imgV sd_setImageWithURL:[NSURL URLWithString:[dic objectForKey:@"smallIconUrl"]] placeholderImage:[UIImage imageNamed:@"my_shangchensmall"]];
        
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imgV.frame), 15+5, 100, 20)];
        titleLabel.textAlignment=NSTextAlignmentLeft;
        titleLabel.font=[UIFont systemFontOfSize:13];
        titleLabel.textColor=[UIColor blackColor];
        titleLabel.text=[dic objectForKey:@"columnName"];
        
        UIImageView *rightImg = [[UIImageView alloc] initWithFrame:CGRectMake(kSWidth-30, 10+5, 30, 30)];
        rightImg.contentMode=UIViewContentModeScaleToFill;
        rightImg.image=[UIImage imageNamed:@"rightBackButton"];
        
        UIImageView *lineImageV = [[UIImageView alloc]initWithFrame:CGRectMake(0, sectionV.frame.size.height-1, sectionV.frame.size.width, 1)];
        lineImageV.backgroundColor=[UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1.0];
        
        [sectionV addSubview:backImgV];
        [sectionV addSubview:imgV];
        [sectionV addSubview:titleLabel];
        [sectionV addSubview:rightImg];
        [sectionV addSubview:lineImageV];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
        [sectionV addGestureRecognizer:tap];
        return sectionV;
    }
    return nil;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section==0){
        return 0;
    }
    else{
        if(self.dataArr.count>0){
        NSArray *arr = [[self.dataArr objectAtIndex:section-1]objectForKey:@"list"];
        if(arr.count>3){
            return 3;
        }else{
            return arr.count;
        }
    }
        return 0;
    }
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    NSArray *arr = [[self.dataArr objectAtIndex:indexPath.section-1]objectForKey:@"list"];
    NSArray *articleArr = [Article articlesFromArray:arr];
    if(cell==nil){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        
    }
    Article *article = nil;
    if(articleArr.count>indexPath.row){
        article = [articleArr objectAtIndex:indexPath.row];
        cell=[NewsCellUtil getNewsCell:article in:tableView];
        if([cell isKindOfClass:[VideoCell class]]){
            VideoCell *cell2 = (VideoCell *)cell;
            cell2.row=indexPath.row;
            cell2.delegate=self;
        }
    }

    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSArray *arr = [[self.dataArr objectAtIndex:indexPath.section-1]objectForKey:@"list"];
    NSArray *articleArr = [Article articlesFromArray:arr];
    Article *article = nil;
    if (articleArr.count > indexPath.row) {
        article = [articleArr objectAtIndex:indexPath.row];
    }
    return [NewsCellUtil getNewsCellHeight:article];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
       NSArray *arr = [[self.dataArr objectAtIndex:indexPath.section-1]objectForKey:@"list"];
       NSArray *articleArr = [Article articlesFromArray:arr];
       Article *currentAricle = nil;
        if (articleArr.count > indexPath.row) {
            currentAricle = [articleArr objectAtIndex:indexPath.row];
        }
        Column *column = [columns objectAtIndex:columnBar.selectedIndex];
    
        [NewsCellUtil clickNewsCell:currentAricle column:column in:self];
    
    
    
}


- (void)buttonAction
{
    GovSubscribeController *subVC = [[GovSubscribeController alloc]initWithMySubscribeArr:self.columnArr];
    
    if(self.navigationController){
        [self.navigationController pushViewController:subVC animated:YES];
    }else{
        [self presentViewController:subVC animated:YES completion:nil];
    }
}

- (void)btnAction:(UIButton *)btn
{
    UIView *headV = [self.view viewWithTag:2014];
    if(!btn.selected){
        btn.selected=YES;
    }
    if(btn.tag==200){
        UIButton *btn = [headV viewWithTag:201];
        if(btn.selected){
            btn.selected=NO;
        }
    }else if (btn.tag==201){
        UIButton *btn = [headV viewWithTag:200];
        if(btn.selected){
            btn.selected=NO;
        }
    }
}

- (void)tapAction:(UITapGestureRecognizer *)tapGesture
{
    UIView *sectionV = tapGesture.view;
    NSInteger sectionTag = sectionV.tag-100;
    
    GovSubTypeViewController *govSubTypeVC = [[GovSubTypeViewController alloc] initWithDataArr:[[self.dataArr objectAtIndex:sectionTag-1]objectForKey:@"list"] withDic:[self.columnArr objectAtIndex:sectionTag-1] withSelected:YES];
    [self.navigationController pushViewController:govSubTypeVC animated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    self.tabBarController.tabBar.hidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
