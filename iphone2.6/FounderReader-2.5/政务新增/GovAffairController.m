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

@interface GovAffairController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong) UITableView *tableView;
@property(nonatomic,strong) NSArray *dadaArr;
@end

@implementation GovAffairController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initWithView];
}

- (void)initWithView
{
    navTitleLabel.text=@"政务";
    self.moreButton.hidden=YES;
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
    
    [self requestData];
    //[self loadArticlesWithColumnId:116 lastFileId:0 rowNumber:0];
    
}

- (void)requestData
{
    ArticleRequest *request = [ArticleRequest articleRequestWithColumnId:116 lastFileId:0 count:20 rowNumber:0];
    [request setCompletionBlock:^(NSArray *arr) {
        self.dadaArr=arr;
        [self.tableView reloadData];
    }];
    [request setFailedBlock:^(NSError *error) {
        
    }];
    [request startAsynchronous];
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
    }

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 6;
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
        UIView *sectionV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSWidth, 55)];
        sectionV.backgroundColor=[UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1.0];
        sectionV.tag = 100+section;
        
        UIImageView *backImgV = [[UIImageView alloc]initWithFrame:CGRectMake(0, 5, kSWidth, 50)];
        backImgV.backgroundColor=[UIColor whiteColor];
        backImgV.userInteractionEnabled=YES;
        
        UIImageView *imgV = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10+5, 30, 30)];
        imgV.contentMode=UIViewContentModeScaleToFill;
        imgV.image=[UIImage imageNamed:@"my_shangchensmall"];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imgV.frame), 15+5, 100, 20)];
        titleLabel.textAlignment=NSTextAlignmentLeft;
        titleLabel.font=[UIFont systemFontOfSize:13];
        titleLabel.textColor=[UIColor blackColor];
        titleLabel.text=@"省水利厅";
        
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
        return 3;
    }
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(cell==nil){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        
    }
    Article *article = nil;
    if(self.dadaArr.count>indexPath.row){
        article = [self.dadaArr objectAtIndex:0];
        cell=[NewsCellUtil getNewsCell:article in:tableView];
        
    }

    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    Article *article = nil;
    if (self.dadaArr.count > indexPath.row) {
        article = [self.dadaArr objectAtIndex:indexPath.row];
    }
    
    return [NewsCellUtil getNewsCellHeight:article];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
        Article *currentAricle = nil;
        if (self.dadaArr.count > indexPath.row) {
            currentAricle = [self.dadaArr objectAtIndex:indexPath.row];
        }
        Column *column = [columns objectAtIndex:columnBar.selectedIndex];
    
        [NewsCellUtil clickNewsCell:currentAricle column:column in:self];
    
    
    
}


- (void)buttonAction
{
    GovSubscribeController *subVC = [[GovSubscribeController alloc]init];
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
    
    GovSubTypeViewController *govSubTypeVC = [[GovSubTypeViewController alloc] init];
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
