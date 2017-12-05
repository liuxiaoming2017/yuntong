//
//  FDPageController.m
//  FounderReader-2.5
//
//  Created by snitsky on 2017/3/7.
//
//

#import "FDPageController.h"
#import "AppConfig.h"
#import "AppStartInfo.h"
@interface FDPageController ()

@property (nonatomic, strong) NSMutableArray *columns;

@end

@implementation FDPageController

- (instancetype)init {
    if (self = [super init]) {
        self.titles = @[];
        self.delegate = self;
        self.dataSource = self;
        
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:pathForMainBundleResource(@"news_column_config.plist")];
        
        BOOL showOnNav = [dict valueForKey:@"column_show_logo"];
        self.showOnNavigationBar = showOnNav;
        
        BOOL isPic = [dict valueForKey:@"column_is_pic"];
        if (isPic) {
            self.menuViewStyle = WMMenuViewStyleDefault;
        } else {
            self.menuViewStyle = WMMenuViewStyleTriangle;
            self.progressHeight = 10;
            self.progressWidth = 10;
        }
        
        NSNumber *height = [dict valueForKey:@"column_bar_height"];
        self.menuHeight = height.floatValue;
        
        NSNumber *titleSize = [dict valueForKey:@"colomn_title_size"];
        self.titleSizeNormal = titleSize.floatValue;
        self.titleSizeSelected = titleSize.floatValue;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupNav];
    
}

- (void)setupNav {
    if (self.type == FDViewControllerForTabbarVC) {
        //设置左图标
        int px = -6;
        if (IS_IPHONE_6P)
            px = -10;
        if (![AppStartInfo sharedAppStartInfo].ucTabisShow) {
            
            UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [leftButton setImage:[UIImage imageNamed:@"icon-head"] forState:UIControlStateNormal];
            [leftButton sizeToFit];
            leftButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            
            leftButton.contentEdgeInsets = UIEdgeInsetsMake(0, px, 0, 0);
            
            [leftButton addTarget:self action:@selector(left) forControlEvents:UIControlEventTouchUpInside];
            UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
            self.navigationItem.leftBarButtonItem = leftItem;
        }
    }
    
    
    
    
    UIView *rightButton = [[UIView alloc] initWithFrame:CGRectMake(0,3,16,16)];
    UIImageView *moreButton = [[UIImageView alloc] initWithFrame:CGRectMake(0, 3, 16, 16)];
    moreButton.image = [UIImage imageNamed:@"icon-edit"];
    moreButton.contentMode = UIViewContentModeScaleToFill;
    [rightButton addSubview:moreButton];
    
    UITapGestureRecognizer *recognizer2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(moreClick)];
    [rightButton addGestureRecognizer:recognizer2];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    
    
    [self.navigationController.navigationBar setBackgroundImage:[Global navigationImage] forBarMetrics:UIBarMetricsDefault];
}

#pragma mark - delegate

- (NSInteger)numbersOfChildControllersInPageController:(WMPageController *)pageController {
    
}

@end
