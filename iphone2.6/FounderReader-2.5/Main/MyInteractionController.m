//
//  MyInteractionController.m
//  FounderReader-2.5
//
//  Created by yanbf on 16/8/17.
//
//

#import "MyInteractionController.h"
#import "ColumnBarConfig.h"
#import "MyInteractionModel.h"
#import "MyInteractionCell.h"

#import "YXLoginViewController.h"
#import "MyCommentLIstController.h"
#import "NJWebPageController.h"
#import "FavoritePageController.h"
#import "AESCrypt.h"
#import "ColorStyleConfig.h"
#import "FDMyQuestionsViewController.h"
#import "FDMyTopicViewController.h"

#import <UMMobClick/MobClick.h>
#define itemSizeHeight 120
#define itemSizeWidth kSWidth / 2

@interface MyInteractionController ()<UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) NSMutableArray *interactions;

@property (nonatomic, strong) UICollectionView *collectionView;

@end

static NSString *interactionID = @"interaction";

@implementation MyInteractionController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNav];
    [self layout];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)setNav {
    
    self.title = NSLocalizedString(@"我的互动",nil);
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

- (void)goBack {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)layout {
    //流布局
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(itemSizeWidth, itemSizeHeight);
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    [self.view addSubview:_collectionView];
    
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    
    [_collectionView registerClass:[NSClassFromString(@"MyInteractionCell")  class] forCellWithReuseIdentifier:interactionID];
    _collectionView.backgroundColor = [UIColor whiteColor];
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.interactions.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MyInteractionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:interactionID forIndexPath:indexPath];
    MyInteractionModel *interaction = self.interactions[indexPath.item];
    NSDictionary *topicConfigDict = [[NSUserDefaults standardUserDefaults] objectForKey:FDTopicConfigsNameKey];
    if ([interaction.controllerClass isEqualToString:@"FDMyTopicViewController"])
        interaction.name = [topicConfigDict objectForKey:FDTopicMyTopicTitileWordKey];
    if ([NSString isNilOrEmpty:interaction.name])
        interaction.name = @"我的话题";
    cell.interaction = interaction;

    return cell;
}


#pragma mark - UICollectionViewDelegate

-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    MyInteractionModel *model = [self.interactions objectAtIndex:indexPath.row];
    NSString *contrllerStr = model.controllerClass;
    
    if ([contrllerStr isEqualToString:@""]) {
        return;
    }else if ([contrllerStr isEqualToString:@"MyCommentLIstController"]) {
        //我的评论
        //是否登录
        if (![Global userId].length) {
            
            YXLoginViewController *controller = [[YXLoginViewController alloc]init];
            controller.loginSuccessBlock = ^(){
                [self showCommentLIstControllerWithContrllerStr:contrllerStr];
            };
            [controller rightPageNavTopButtons];
            [self presentViewController:[Global controllerToNav:controller] animated:YES completion:nil];
            return;
        }
        else{
            [MobClick event:@"my_interaction" attributes:@{@"my_interaction_click":NSLocalizedString(@"我的评论",nil)}];
        [self showCommentLIstControllerWithContrllerStr:contrllerStr];
        return;
        }
    }else if ([contrllerStr isEqualToString:@"MyActivityController"]) {
        //我的活动
        if (![Global userId].length) {
            YXLoginViewController *controller = [[YXLoginViewController alloc]init];
            controller.loginSuccessBlock = ^(){
                [self ActivityControllerWithContrllerStr:contrllerStr];
            };
            [controller rightPageNavTopButtons];
            [self presentViewController:[Global controllerToNav:controller] animated:YES completion:nil];
            return;
        }
        else{
            [MobClick event:@"my_interaction" attributes:@{@"my_interaction_click":NSLocalizedString(@"我的活动",nil)}];
            [self ActivityControllerWithContrllerStr:contrllerStr];
        
        return;
        }
    }else if ([contrllerStr isEqualToString:@"FavoritePageController"]) {
        //我的收藏
        [MobClick event:@"my_interaction" attributes:@{@"my_interaction_click":NSLocalizedString(@"我的收藏",nil)}];
        [self showFavoritePageControllerWithContrllerStr:contrllerStr];
        
        return;
    }else if ([contrllerStr isEqualToString:@"MyAnswerController"]) {
        // 我的提问
        if (![Global userId].length) {
            YXLoginViewController *controller = [[YXLoginViewController alloc]init];
            controller.loginSuccessBlock = ^(){
                [self showMyAnswerControllerWithContrllerStr:contrllerStr];
            };
            [controller rightPageNavTopButtons];
            [self presentViewController:[Global controllerToNav:controller] animated:YES completion:nil];
            return;
        }
        else{
            [MobClick event:@"my_interaction" attributes:@{@"my_interaction_click":NSLocalizedString(@"我的提问",nil)}];
            [self showMyAnswerControllerWithContrllerStr:contrllerStr];
            return;
        }
    }else if ([contrllerStr isEqualToString:@"MyCouponController"]) {
        //我的兑换券
        //是否登录
        if (![Global userId].length) {
            YXLoginViewController *controller = [[YXLoginViewController alloc]init];
            controller.loginSuccessBlock = ^(){
                [self showMyCouponControllerWithContrllerStr:contrllerStr];
            };
            [controller rightPageNavTopButtons];
            [self presentViewController:[Global controllerToNav:controller] animated:YES completion:nil];
            return;
        }
        else{
            [MobClick event:@"my_interaction" attributes:@{@"my_interaction_click":NSLocalizedString(@"我的兑换券",nil)}];
            [self showMyCouponControllerWithContrllerStr:contrllerStr];
            return;
       }
    }else if ([contrllerStr isEqualToString:@"FDMyTopicViewController"]) {
        //我的话题
        if (![Global userId].length) {
            YXLoginViewController *controller = [[YXLoginViewController alloc]init];
            controller.loginSuccessBlock = ^(){
                [self showMyTopicControllerWithModel:model];
            };
            [controller rightPageNavTopButtons];
            [self presentViewController:[Global controllerToNav:controller] animated:YES completion:nil];
            return;
        }
        else{
            [MobClick event:@"my_interaction" attributes:@{@"my_interaction_click":NSLocalizedString(@"我的话题",nil)}];
            [self showMyTopicControllerWithModel:model];
            return;
        }
    }else if ([contrllerStr isEqualToString:@"FDMyTopicDetailViewController"]) {
        //我的话题详情栏目
        if (![Global userId].length) {
            YXLoginViewController *controller = [[YXLoginViewController alloc]init];
            controller.loginSuccessBlock = ^(){
                [self showMyTopicControllerWithModel:model];
            };
            [controller rightPageNavTopButtons];
            [self presentViewController:[Global controllerToNav:controller] animated:YES completion:nil];
            return;
        }
        else{
            [MobClick event:@"my_interaction" attributes:@{@"my_interaction_click":NSLocalizedString(@"我的话题",nil)}];
            [self showMyTopicControllerWithModel:model];
            return;
        }
    }
    self.navigationController.navigationBarHidden = NO;
}

#pragma mark - 跳转方法
- (void)showCommentLIstControllerWithContrllerStr:(NSString *)contrllerStr {
    MyCommentLIstController*controller = [[NSClassFromString(contrllerStr) alloc] init];
    [self presentViewController:[Global controllerToNav:controller] animated:YES completion:nil];
}

- (void)ActivityControllerWithContrllerStr:(NSString *)contrllerStr {
    //http://h5.newaircloud.com/myactivity?sc=xy&uid=123&sign=AES(sc+uid)
    NJWebPageController * controller = [[NJWebPageController alloc] init];
    Column *one = [[Column alloc] init];
    one.linkUrl = [NSString stringWithFormat:@"%@/myactivity?sc=%@&uid=%@&sign=%@",[AppConfig sharedAppConfig].serverIf,[AppConfig sharedAppConfig].sid, [Global userId], [AESCrypt encrypt:[NSString stringWithFormat:@"%@%@", [AppConfig sharedAppConfig].sid,[Global userId]] password:key]];
    one.columnName = NSLocalizedString(@"我的活动",nil);
    controller.parentColumn = one;
    controller.isFromModal = YES;
    [self presentViewController:[Global controllerToNav:controller] animated:YES completion:nil];
}

- (void)showFavoritePageControllerWithContrllerStr:(NSString *)contrllerStr {
    FavoritePageController *controller = [[NSClassFromString(contrllerStr) alloc] init];
    controller.hidesBottomBarWhenPushed = YES;
    controller.parentColumn = [appDelegate().channels lastObject];
    [self presentViewController:[Global controllerToNav:controller] animated:YES completion:nil];
}

- (void)showMyAnswerControllerWithContrllerStr:(NSString *)contrllerStr {
    //小红点
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:[NSString stringWithFormat:@"%@%@",[Global userId],KuserAccountAskDotViewShow]];
    [self.collectionView reloadData];
    NSString *redDotKey = @"askPlusReply";
    NSString *urlString  = [NSString stringWithFormat:@"%@/api/removeInteractionStatus?uid=%@&key=%@&sign=%@", [AppConfig sharedAppConfig].serverIf, [Global userId], redDotKey, [AESCrypt encrypt:[NSString stringWithFormat:@"%@%@", [Global userId], redDotKey] password:key]];
    HttpRequest *request = [HttpRequest requestWithURL:[NSURL URLWithString:urlString]];
    [request setCompletionBlock:^(id data) {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if ([[dic objectForKey:@"success"] boolValue]) {
            
        }
        else{
            XYLog(@"%@",[dic objectForKey:@"msg"]);
        }

    }];
    [request setFailedBlock:^(NSError *error) {
        
    }];
    [request startAsynchronous];
    
    FDMyQuestionsViewController *vc = [[FDMyQuestionsViewController alloc] init];
    [self presentViewController:[Global controllerToNav:vc] animated:YES completion:nil];
}

- (void)showMyTopicControllerWithModel:(MyInteractionModel *)model {
    //小红点
//    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:[NSString stringWithFormat:@"%@%@",[Global userId],KuserAccountAskDotViewShow]];
//    [self.collectionView reloadData];
//    NSString *redDotKey = @"askPlusReply";
//    NSString *urlString  = [NSString stringWithFormat:@"%@/api/removeInteractionStatus?uid=%@&key=%@&sign=%@", [AppConfig sharedAppConfig].serverIf, [Global userId], redDotKey, [AESCrypt encrypt:[NSString stringWithFormat:@"%@%@", [Global userId], redDotKey] password:key]];
//    HttpRequest *request = [HttpRequest requestWithURL:[NSURL URLWithString:urlString]];
//    [request setCompletionBlock:^(id data) {
//        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
//        if ([[dic objectForKey:@"success"] boolValue]) {
//            
//        }
//        else{
//            XYLog(@"%@",[dic objectForKey:@"msg"]);
//        }
//        
//    }];
//    [request setFailedBlock:^(NSError *error) {
//        
//    }];
//    [request startAsynchronous];
    BOOL isFromMyTopicDetail = [model.controllerClass isEqualToString:@"FDMyTopicDetailViewController"];
    FDMyTopicViewController *vc = [[FDMyTopicViewController alloc] initWithIsFromMyTopicDetail:isFromMyTopicDetail];
    vc.title = model.name;
    [self presentViewController:[Global controllerToNav:vc] animated:YES completion:nil];
}

- (void)showMyCouponControllerWithContrllerStr:(NSString *)contrllerStr {
    NJWebPageController * controller = [[NJWebPageController alloc] init];
    Column *one = [[Column alloc] init];
    one.linkUrl = [NSString stringWithFormat:@"%@/wenjuan/myCoupon?sc=%@&uid=%@&sign=%@",[AppConfig sharedAppConfig].serverIf,[AppConfig sharedAppConfig].sid, [Global userId], [AESCrypt encrypt:[NSString stringWithFormat:@"%@%@", [AppConfig sharedAppConfig].sid,[Global userId]] password:key]];
    one.columnName = NSLocalizedString(@"我的兑换券",nil);
    controller.parentColumn = one;
    controller.isFromModal = YES;
    [self presentViewController:[Global controllerToNav:controller] animated:YES completion:nil];
}

#pragma mark - 懒加载
- (NSMutableArray *)interactions {
    if (_interactions == nil) {
        NSArray *dictArr = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"myInteraction.plist" ofType:nil]];
        NSMutableArray *arrM = [NSMutableArray arrayWithCapacity:dictArr.count];
        for (NSDictionary *dict in dictArr) {
            MyInteractionModel *interaction = [MyInteractionModel interactionWithDict:dict];
            if([interaction.controllerClass compare:@"MyActivityController"] == NSOrderedSame){
                interaction.name = NSLocalizedString(@"我的活动", nil);
            }
            else if([interaction.controllerClass compare:@"FavoritePageController"] == NSOrderedSame){
                interaction.name = NSLocalizedString(@"我的收藏", nil);
            }
            else if([interaction.controllerClass compare:@"MyAnswerController"] == NSOrderedSame){
                interaction.name = NSLocalizedString(@"我的问答", nil);
            }
            else if([interaction.controllerClass compare:@"MyCommentLIstController"] == NSOrderedSame){
                interaction.name = NSLocalizedString(@"我的评论", nil);
            } else if([interaction.controllerClass compare:@"MyCouponController"] == NSOrderedSame){
                interaction.name = NSLocalizedString(@"我的兑换券", nil);
            }else if([interaction.controllerClass compare:@"FDMyTopicViewController"] == NSOrderedSame){
                interaction.name = NSLocalizedString(@"我的话题", nil);
            }

            [arrM addObject:interaction];
        }
        _interactions = arrM;
    }
    return _interactions;
}

// 判断登录
-(void)showLoginPage
{
    YXLoginViewController *controller = [[YXLoginViewController alloc]init];
    [controller rightPageNavTopButtons];
    [self presentViewController:[Global controllerToNav:controller] animated:YES completion:nil];
}

@end
