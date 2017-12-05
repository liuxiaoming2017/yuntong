//
//  FDMyTopicAuditViewController.m
//  FounderReader-2.5
//
//  Created by julian on 2017/6/28.
//
//

#import "FDMyTopicAuditViewController.h"
#import "FDMyTopicCell.h"
#import "UIView+Extention.h"
#import "ColorStyleConfig.h"
#import "ColumnBarConfig.h"
#import "UIButton+Block.h"
#import "FDMyTopicModifyViewController.h"

@interface FDMyTopicAuditViewController ()<UIScrollViewDelegate>

@property (strong, nonatomic) FDMyTopic *myTopic;
@property (strong, nonatomic) UIScrollView *bgScrollView;

@end

@implementation FDMyTopicAuditViewController

- (instancetype)initWithMyTopic:(FDMyTopic *)myTopic
{
    if (self = [super init]) {
        _myTopic = myTopic;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
}

- (void)setupUI
{
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupNav];
    
    [self setupScrollView];
    
    [self setupDetailView];
}

- (void)setupNav {
    self.title = self.myTopic.title;
    // 设置导航默认标题的颜色及字体大小
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [ColorStyleConfig sharedColorStyleConfig].navbar_titlecolor_didselect, NSFontAttributeName : [UIFont boldSystemFontOfSize:18]};
    UIButton *preBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    preBtn.tag = 111;
    [preBtn setImage:[UIImage imageNamed:@"nav_bar_back"] forState:UIControlStateNormal];
    [preBtn sizeToFit];
    preBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    preBtn.contentEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
    [preBtn addTarget:self action:@selector(goPrePage) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:preBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
}

- (void)goPrePage {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setupScrollView
{
    self.bgScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.bgScrollView.delegate = self;
    self.bgScrollView.backgroundColor = [UIColor clearColor];
    self.bgScrollView.maximumZoomScale = 20.0f;
    self.bgScrollView.showsHorizontalScrollIndicator = NO;
    self.bgScrollView.showsVerticalScrollIndicator = NO;
    self.bgScrollView.alwaysBounceVertical = YES;//有弹性
    [self.view addSubview:self.bgScrollView];
}

- (void)setupDetailView
{
    FDMyTopicCell *myTopicCell = [[FDMyTopicCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DetailViewIdentifier"];
    self.myTopic.isHeader = YES;
    myTopicCell.frame = CGRectMake(0, 0, kSWidth, [self.myTopic cellHeight]);
    [myTopicCell layoutCell:self.myTopic IsHeader:YES IsFirstRow:NO];
    [self.bgScrollView addSubview:myTopicCell];
    
    UILabel *auditLabel = [[UILabel alloc] init];
    auditLabel.textColor = [UIColor redColor];
    auditLabel.font = [UIFont systemFontOfSize:14];
    auditLabel.numberOfLines = 2;
    auditLabel.origin = self.myTopic.pics.count >= 7 ? CGPointMake(15, CGRectGetMaxY(myTopicCell.frame)+10) : CGPointMake(15, CGRectGetMaxY(myTopicCell.frame)-20);
    auditLabel.width = kSWidth - 15*2;
    auditLabel.textAlignment = NSTextAlignmentCenter;
    auditLabel.text = [NSLocalizedString(@"未通过原因：", nil) stringByAppendingString:self.myTopic.reason];
    [auditLabel sizeToFit];
    [self.bgScrollView addSubview:auditLabel];
    auditLabel.hidden = self.myTopic.discussStatus.integerValue != 2;
    
    CGFloat needH = auditLabel.hidden ? CGRectGetMaxY(myTopicCell.frame)+30*2+36 : CGRectGetMaxY(auditLabel.frame)+30*2+36;
    CGFloat contentH = needH > kSHeight ? needH : kSHeight;
    self.bgScrollView.contentSize = CGSizeMake(kSWidth, contentH);
    
    UIButton *modifyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    modifyBtn.frame = CGRectMake(0, self.bgScrollView.contentSize.height-30-36-64, 376/2.0f, 36);
    modifyBtn.centerX = self.view.centerX;
    [modifyBtn setTitle:NSLocalizedString(@"修改", nil) forState:UIControlStateNormal];
    [modifyBtn setBackgroundColor:[ColumnBarConfig sharedColumnBarConfig].column_all_color];
    __weak __typeof (self)weakSelf = self;
    [modifyBtn addAction:^(UIButton *btn) {
        FDMyTopicModifyViewController *modifyVC = [[FDMyTopicModifyViewController alloc] initWithMyTopic:weakSelf.myTopic DetailModel:nil];
        [weakSelf.navigationController pushViewController:modifyVC animated:YES];
    }];
    modifyBtn.layer.masksToBounds = YES;
    modifyBtn.layer.cornerRadius = modifyBtn.height/2.0f;
    [self.bgScrollView addSubview:modifyBtn];
    modifyBtn.hidden = self.myTopic.discussStatus.integerValue != 2;
}

@end
