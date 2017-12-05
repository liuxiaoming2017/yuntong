//
//  NJSquarePageController.m
//  FounderReader-2.5
//
//  Created by lihuiguo on 15/8/31.
//  便民服务页面
//
#import "NJSquarePageController.h"
#import "FDServiseColumnRequest.h"
#import "ColumnButton.h"
#import "NJWebPageController.h"
#import "NSString+Helper.h"
#import "MFSideMenu.h"
#import "UIImageView+WebCache.h"
#import <UMMobClick/MobClick.h>
#import "UIView+Extention.h"
#import "FLAnimatedImage.h"
#import "ColumnBarPageController.h"
#import "AppStartInfo.h"

typedef NS_ENUM(NSUInteger, FDServiseVCItemCountForLine) {
    FDTwoItemForLine   = 2,
    FDThreeItemForLine = 3,
    FDFourItemForLine  = 4,
};

const static CGFloat FDMargin = 10.0f;

@interface NJSquarePageController () <CDRTranslucentSideBarDelegate> {
    NSUInteger columnIndex;
}

@property (assign, nonatomic) FDServiseVCItemCountForLine itemCountForLine;

@end

@implementation NJSquarePageController

- (id)initWithColumn:(Column *)column withIsMain:(int)isMain
{
    self = [super init];
    if (self) {
        self.parentColumn = column;
        self.isMain = isMain;
    }
    return self;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // 这样做的目的是为了让scrollview里面的内容滑动时边界在导航栏下面位置，而不是最顶上
    // 但他会让pop回来后的页面上移64，只能整体调整了self.edgesForExtendedLayout=UIRectEdgeNone
    scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //将这个属性设置为UIRectEdgeNone，则代表设置viewController的所有子视图都会自动调整
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kSWidth, self.view.bounds.size.height - kNavBarHeight - 10-kTabBarHeight) style:UITableViewStyleGrouped];
    
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.backgroundColor = [UIColor clearColor];
    tableView.allowsSelection = NO;
    [self.view addSubview:tableView];
    
    UIPanGestureRecognizer *panGestureRecognizer = nil;
    if (!self.isMain) {
        leftController = [[PersonalCenterViewController alloc] init];
        self.leftController.view.frame = CGRectMake(0, 0, 240, self.view.bounds.size.height+kNavBarHeight);
        
        sideBar = [[CDRTranslucentSideBar alloc] init];
        self.sideBar.sideBarWidth = self.view.bounds.size.width * 0.5;
        self.sideBar.view.frame = CGRectMake(0, 0,self.view.bounds.size.width * 0.5, self.view.bounds.size.height);
        [self.sideBar setContentViewInSideBar:self.leftController.view];
        self.sideBar.delegate = self;
        self.leftController.sideBar = self.sideBar;
        panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        if (![AppStartInfo sharedAppStartInfo].ucTabisShow && self.viewControllerType == FDViewControllerForTabbarVC) {
            [self.view addGestureRecognizer:panGestureRecognizer];
        }
    }
    [self refreshSquareData];
}

-(void)refreshSquareData
{
    [self loadColumns];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    self.edgesForExtendedLayout = UIRectEdgeNone;
    if (self.isMain) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
    else
    {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
    [self leftAndRightButton];
    [self titleLableWithTitle:parentColumn.columnName];
    NSInteger onlyOne = [[[NSUserDefaults standardUserDefaults] objectForKey:@"onlyOne"] integerValue];
    if (onlyOne == 2){
        [self.tabBarController.tabBar setHidden:YES];
    }else{
        [self.tabBarController.tabBar setHidden:NO];
    }
    self.navigationItem.rightBarButtonItem = nil;
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}
- (void)handlePanGesture:(UIPanGestureRecognizer *)recognizer {
    
    // if you have left and right sidebar, you can control the pan gesture by start point.
    CGPoint translatedPoint = [recognizer translationInView:self.view];
    if (translatedPoint.x > 0){
        if (recognizer.state == UIGestureRecognizerStateBegan) {
            CGPoint startPoint = [recognizer locationInView:self.view];
            if (startPoint.x < kSWidth/3.0)
            {
                self.sideBar.isCurrentPanGestureTarget = YES;
            }
        }
        
        [self.sideBar handlePanGestureToShow:recognizer inView:self.view];
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.columns.count > section) {
        //返回大于等于整数
        return ceil(self.columns.count /(float)self.itemCountForLine);
    }
    return 0;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.itemCountForLine == FDTwoItemForLine ? (kSWidth - FDMargin*3) / 2.f / 16.f * 9.f + 10 : kSWidth/4+10;
}

- (UITableViewCell *)tableView:(UITableView *)sender cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"] ;
    NSInteger loc = indexPath.row * self.itemCountForLine;
    NSInteger len = MIN(self.columns.count - loc, self.itemCountForLine);
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(loc, len)];
    NSArray *array = [self.columns objectsAtIndexes:indexSet];
    [self configCell:cell withArray:array location:(int)loc forSection:indexPath.section];
    
    return cell;
}


- (void)configCell:(UITableViewCell *)cell withArray:(NSArray *)array location:(int)loc forSection:(NSInteger)section
{
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    int column_count = self.itemCountForLine;
    CGFloat button_width = kSWidth / column_count;
    
    for (int i = 0; i < [array count]; ++i) {
        Column *column = [array objectAtIndex:i];
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(button_width*i,0,button_width,kSWidth/4+10)];
        [cell.contentView addSubview:bgView];
        ColumnButton *button = [[ColumnButton alloc] initWithFrame:CGRectMake(0,0,button_width-0.5,kSWidth/4+10)];
        [bgView addSubview:button];
        
         button.nameLabel.numberOfLines = 0;
        if (self.itemCountForLine == FDTwoItemForLine) {
            button.thumbnail.frame = CGRectMake(FDMargin / (i + 1), FDMargin, button.frame.size.width - FDMargin * 1.5, button.frame.size.height - FDMargin);
            button.nameLabel.frame = CGRectMake(FDMargin / (i + 1), CGRectGetMaxY(button.thumbnail.frame) - 24, button.thumbnail.frame.size.width, 24);
            button.nameLabel.font = [UIFont fontWithName:[Global fontName] size:15];
            button.nameLabel.textColor = [UIColor whiteColor];
            button.nameLabel.backgroundColor = [UIColor blackColor];
            button.nameLabel.alpha = 0.7;

        } else {
            button.thumbnail.frame = CGRectMake((button.frame.size.width-(kScale*40))/2.0, kScale*19, kScale*40, kScale*40);
            button.nameLabel.frame = CGRectMake((button.frame.size.width-(kScale*74))/2.0, CGRectGetMaxY(button.thumbnail.frame)+10*kScale, kScale*74, kScale*20);
            button.nameLabel.font = [UIFont fontWithName:[Global fontName] size:14];
            
            UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(0, bgView.height-0.5, bgView.width, 0.5)];
            label1.backgroundColor = [UIColor colorWithRed:0xED/255.0 green:0xED/255.0 blue:0xED/255.0 alpha:1];
            [bgView addSubview:label1];
            UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(bgView.width-0.5, 0, 0.5, bgView.height)];
            label2.backgroundColor = [UIColor colorWithRed:0xED/255.0 green:0xED/255.0 blue:0xED/255.0 alpha:1];
            [bgView addSubview:label2];
        }
        
        button.index = section*1000 +(loc+i);
        
        button.nameLabel.text = column.columnName;
        button.thumbnail.image = [Global getBgImage43];
        if (![column.iconUrl isEqual:[NSNull null]]) {
            if (![NSString isNilOrEmpty:column.iconUrl])
            {
                if ([column.iconUrl containsString:@".gif"])
                {
                    FLAnimatedImageView *imageView = [[FLAnimatedImageView alloc] initWithFrame:button.thumbnail.frame];
                    imageView.image = [Global getBgImage43];
                    [self loadAnimatedImageWithURL:[NSURL URLWithString:column.iconUrl] completion:^(FLAnimatedImage *animatedImage) {
                        [imageView setAnimatedImage:animatedImage];
                    }];
                    [button addSubview:imageView];
                }
                else
                {
                    [button.thumbnail sd_setImageWithURL:[NSURL URLWithString:column.iconUrl] placeholderImage:[Global getBgImage43]];
                }
            }
        }
        [button addTarget:self action:@selector(columnButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:bgView];

    }
}
- (void)loadAnimatedImageWithURL:(NSURL *const)url completion:(void (^)(FLAnimatedImage *animatedImage))completion
{
    NSString *const filename = url.lastPathComponent;
    NSString *const diskPath = [NSHomeDirectory() stringByAppendingPathComponent:filename];
    
    NSData * __block animatedImageData = [[NSFileManager defaultManager] contentsAtPath:diskPath];
    FLAnimatedImage * __block animatedImage = [[FLAnimatedImage alloc] initWithAnimatedGIFData:animatedImageData];
    
    if (animatedImage) {
        if (completion) {
            completion(animatedImage);
        }
    } else {
        [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            animatedImageData = data;
            animatedImage = [[FLAnimatedImage alloc] initWithAnimatedGIFData:animatedImageData];
            if (animatedImage) {
                if (completion) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(animatedImage);
                    });
                }
                [data writeToFile:diskPath atomically:YES];
            }
        }] resume];
    }
}

#pragma mark - uitableview
- (void)loadColumnsArray {
    FDServiseColumnRequest *request = [FDServiseColumnRequest columnRequestWithParentColumnId:parentColumn.columnId];
    __weak __typeof (self)weakSelf = self;
    [request setCompletionBlock:^(NSDictionary *dict) {
        NSString *keywordString = dict[@"column"][@"keyword"];
        NSData *jsonData = [keywordString dataUsingEncoding:NSUTF8StringEncoding];
        NSError *err;
        NSDictionary *keywordDict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                            options:NSJSONReadingMutableContainers
                                                              error:&err];
        NSNumber *number = keywordDict[@"showCols"];
        FDServiseVCItemCountForLine itemCount = number.integerValue;
        if (itemCount) {
            weakSelf.itemCountForLine = itemCount;
        } else {
            weakSelf.itemCountForLine = 4;
        }
        NSArray *array = [Column columnsFromArray:[dict objectForKey:@"columns"]];
        
        NSMutableArray *muArray = [[NSMutableArray alloc] initWithArray:array];
        if (array.count != 0) {
            for (int i = 0; i < array.count; i++) {
                Column *column = [array objectAtIndex:i];
                if (column.showcolumn) {
                    [muArray removeObject:column];
                }
            }
        }
        self.columns = [[NSMutableArray alloc] initWithArray:muArray];
        [tableView reloadData];
    }];
    
    [request setFailedBlock:^(NSError *error) {
        NSLog(@"load Columns failed: %@", error);
        [self loadColumnsFailed];
    }];
    [request startAsynchronous];
}

- (void)columnButtonClicked:(ColumnButton *)sender
{
    NSInteger row = sender.index%1000;
    Column *column = [self.columns objectAtIndex:row];
    NSString *strurl = column.linkUrl;
    if([column.columnStyle isEqualToString:@"新闻"]){
        column.className = column.hasSubColumn ? @"NewsPageController" : @"NormalPageController";
        ColumnBarPageController *pageController = [[NSClassFromString(column.className) alloc] init];
        pageController.parentColumn = column;
        pageController.isNotOneLevelNewsVC = YES;
        pageController.viewControllerType = FDViewControllerForDetailVC;
        [self.navigationController pushViewController:pageController animated:YES];
        return;
    }else{
        NJWebPageController * controller = [[NJWebPageController alloc] init];
        Column *one = [[Column alloc] init];
        one.linkUrl = strurl;
        one.columnName = column.columnName;
        controller.parentColumn = one;
        controller.isFromModal = YES;
        [self presentViewController:[Global controllerToNav:controller] animated:YES completion:nil];
        return;
    }
    
//    ChannelPageController *pageController = [[NSClassFromString(column.className) alloc] init];
//    pageController.parentColumn = column;
//    [self.navigationController pushViewController:pageController animated:YES];
}

- (void)sideBar:(CDRTranslucentSideBar *)sideBar1 willAppear:(BOOL)animated {
    [self.leftController updateUserInfo];
}
@end
