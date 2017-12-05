//
//  FDScanViewController.m
//  FounderReader-2.5
//
//  Created by snitsky on 2017/2/22.
//
//

#import "FDScanViewController.h"
#import "ColorStyleConfig.h"
#import "LXDScanView.h"
#import "NJWebPageController.h"
#import "AppConfig.h"
#import "AESCrypt.h"
#import "UIDevice+FCUUID.h"

@interface FDScanViewController ()<LXDScanViewDelegate>

@property (nonatomic, strong) LXDScanView * scanView;

@end

@implementation FDScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setNav];
    [self.view addSubview: self.scanView];
    //[self.scanView start];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear: animated];
    [self.scanView stop];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.scanView start];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [self.scanView stop];
}

- (void)setNav {
    
    self.title = NSLocalizedString(@"扫一扫",nil);
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

#pragma mark - getter
/**
 *  懒加载扫描view
 */
- (LXDScanView *)scanView
{
    if (!_scanView) {
        _scanView = [LXDScanView scanViewShowInController: self];
    }
    return _scanView;
}


#pragma mark - LXDScanViewDelegate
/**
 *  返回扫描结果
 */
- (void)scanView:(LXDScanView *)scanView codeInfo:(NSString *)codeInfo
{
    NSURL * url = [NSURL URLWithString: codeInfo];
    if ([[UIApplication sharedApplication] canOpenURL: url]) {
        [self showWebViewControllerWithCode:codeInfo];
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"扫描错误" message:[NSString stringWithFormat: @"%@:%@", @"无法解析的二维码", codeInfo] preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:
         [UIAlertAction actionWithTitle:NSLocalizedString(@"确认", nil)
                                  style:UIAlertActionStyleCancel
                                handler:^(UIAlertAction * _Nonnull action) {
                                    [self.scanView start];
        }]];
        [self presentViewController:alert animated:YES completion:NULL];
    }
}

- (void)showWebViewControllerWithCode:(NSString *)code {
    NJWebPageController * controller = [[NJWebPageController alloc] init];
    Column *one = [[Column alloc] init];
    if (![code containsString:@"?"]) {
        code = [NSString stringWithFormat:@"%@?", code];
    }
    if (![code hasSuffix:@"?"]) {
        code = [NSString stringWithFormat:@"%@&", code];
    }
    one.linkUrl = [NSString stringWithFormat:@"%@xky_deviceid=%@&xky_sign=%@", code,[[UIDevice currentDevice] uuid], [AESCrypt encrypt:[[UIDevice currentDevice] uuid] password:key]];
    one.columnName = @"";
    controller.parentColumn = one;
    controller.isFromModal = YES;
    [self presentViewController:[Global controllerToNav:controller] animated:YES completion:nil];
}

@end
