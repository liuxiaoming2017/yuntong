//
//  DishViewController.m
//  FounderReader-2.5
//
//  Created by 周志扬 on 15/9/28.
//
//
#define titleHoldPlaceText NSLocalizedString(@"提问标题 (20字以内)",nil)
#define phoneHoldPlaceText NSLocalizedString(@"联系电话",nil)
#define realNameHoldPlaceText NSLocalizedString(@"联系人",nil)
#define columnHoldSectionText NSLocalizedString(@"选择部门",nil)
#define columnHoldPlaceText   NSLocalizedString(@"选择类型",nil)
#define contentHoldPlaceText  NSLocalizedString(@"请输入报料内容",nil)

#define leftGap 10
#define topGap 12 + 0
#define labelHeight 30

#define freeHeight 0
#import "DishViewController.h"
#import "SeeMethod.h"
#import "AppStartInfo.h"
#import "FCReader_OpenUDID.h"
#import "InformAttachment.h"
#import "PersonalCenterViewController.h"
#import "CDRTranslucentSideBar.h"
#import <AliyunOSSiOS/OSSService.h>
#import <AliyunOSSiOS/OSSCompat.h>
#import "AESCrypt.h"
#import "NewsListConfig.h"
#import "ColumnBarConfig.h"
#import "AutoScrollView.h"
#import "UIView+Extention.h"

@interface DishViewController ()<CDRTranslucentSideBarDelegate, UIScrollViewDelegate>

@property (nonatomic, retain) InformAttachment *attachment;
@property (nonatomic, retain) PersonalCenterViewController *leftController;
@property (nonatomic, retain) CDRTranslucentSideBar *sideBar;
@property (nonatomic, retain) UIImageView *contentBgView2;
@property (nonatomic, retain) UILabel *starlableText;

@end


@implementation DishViewController
{
    UIImageView *duihaoImg1;
    UIImageView *duihaoImg2;
    UIImageView *duihaoImg3;
    UIImageView *duihaoImg4;
    UIButton *clueBtn; // 线索
    UIButton *complainBtn; // 投诉
    UIButton *jianjuBtn;
    UIButton *hellpBtn;
    OSSClient * client;
}
@synthesize sideBar,leftController;

- (id)initWithColumn:(Column *)column withIsMain:(int)isMain
{
    self = [super init];
    if (self) {
        self.column = column;
        self.isMain = isMain;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self loadData];

    self.view.backgroundColor = [UIColor whiteColor];
    self.view.frame = CGRectMake(0, 64, kSWidth, kSHeight-64-49);
    UIPanGestureRecognizer *panGestureRecognizer = nil;
    if (self.isMain) {
        
    }
    else
    {
        leftController = [[PersonalCenterViewController alloc] init];
        self.leftController.view.frame = CGRectMake(0, 0, 240, self.view.bounds.size.height+64);
        
        sideBar = [[CDRTranslucentSideBar alloc] init];
        self.sideBar.sideBarWidth = self.view.bounds.size.width * 0.5;
        self.sideBar.view.frame = CGRectMake(0, 0,self.view.bounds.size.width * 0.5, self.view.bounds.size.height);
        [self.sideBar setContentViewInSideBar:self.leftController.view];
        self.sideBar.delegate = self;
        self.leftController.sideBar = self.sideBar;
        
        panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    }
    
    // 报料页左侧导航样式
    if (self.navStyle == 1) {
        [self rightPageNavTopButtons];
    }
    else
    {
        [self leftAndRightButton];
        if (self.isMain) {
            
        }
        else
        {
            if (![AppStartInfo sharedAppStartInfo].ucTabisShow && self.viewControllerType == FDViewControllerForTabbarVC) {
                [self.view addGestureRecognizer:panGestureRecognizer];
            }
        }
        
    }
    
    self.navigationItem.rightBarButtonItem = nil;
    // Do any additional setup after loading the view.
    self.navStyle = 0;
    // 内容必填标示
    self.starlableText = [[UILabel alloc] init];
    self.starlableText.frame = CGRectMake(8, 55+freeHeight-30, 12, 25);
    self.starlableText.textColor = [ColumnBarConfig sharedColumnBarConfig].column_all_color;
    self.starlableText.textAlignment = NSTextAlignmentCenter;
    self.starlableText.text = @"*";
    [self.view addSubview:self.starlableText];
    
    
    
    // 内容
    self.contentBgView2 = nil;
    if (IS_IPHONE_4) {
        self.contentBgView2 = [[UIImageView alloc] initWithFrame:CGRectMake(10+leftGap,50+freeHeight-30,kSWidth-30, 80)];
    }
    else if (IS_IPHONE_5) {
        self.contentBgView2 = [[UIImageView alloc] initWithFrame:CGRectMake(10+leftGap,50+freeHeight-30,kSWidth-30, 100)];
    }
    else
    {
        self.contentBgView2 = [[UIImageView alloc] initWithFrame:CGRectMake(10+leftGap,50+freeHeight-30,kSWidth-30, 130)];
    }
    self.contentBgView2.layer.borderWidth = 1;
    self.contentBgView2.layer.borderColor = UIColorFromString(@"234,234,234").CGColor;
    [self.view addSubview:self.contentBgView2];
    
    self.contentBgView2.userInteractionEnabled = YES;
    contentTextView = [[UITextView alloc] initWithFrame:CGRectMake(2, 0, kSWidth-25, self.contentBgView2.height)];
    contentTextView.delegate = self;
    contentTextView.backgroundColor = [UIColor clearColor];
    contentTextView.text = contentHoldPlaceText;
    contentTextView.font = [UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleCellTitleFontSize-3];
    contentTextView.textColor = [UIColor colorWithRed:160/255.0 green:160/255.0 blue:160/255.0 alpha:1.0];
    [self.contentBgView2 addSubview:contentTextView];
    
    
    //    leftController = [[PersonalCenterViewController alloc] init];
    //    self.leftController.view.frame = CGRectMake(0, 0, 240, self.view.bounds.size.height+64);
    //
    //    sideBar = [[CDRTranslucentSideBar alloc] init];
    //    self.sideBar.sideBarWidth = self.view.bounds.size.width * 0.5;
    //    self.sideBar.view.frame = CGRectMake(0, 0,self.view.bounds.size.width * 0.5, self.view.bounds.size.height);
    //    [self.sideBar setContentViewInSideBar:self.leftController.view];
    //    self.sideBar.delegate = self;
    //    self.leftController.sideBar = self.sideBar;
    
    // 拖动手势
    //    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    //    panGestureRecognizer.delegate = self;
    //    [self.view addGestureRecognizer:panGestureRecognizer];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardDown)];
    tapRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapRecognizer];
    
    [self addAutoScrollView];
    
    [self updateLocalSaveContent];
}

- (void)addAutoScrollView
{
    NSString *url = [NSString stringWithFormat:@"%@/api/getTipOffMsg?sid=%@", [AppConfig sharedAppConfig].serverIf, [AppConfig sharedAppConfig].sid];
    HttpRequest *request = [HttpRequest requestWithURL: [NSURL URLWithString:url]];
    [request setCompletionBlock:^(NSData *data) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers  error:nil];
        if ([[dict objectForKey:@"success"] boolValue])
        {
            NSString *str = [dict objectForKey:@"configValue"];
            if (![NSString isNilOrEmpty:str]) {
                NSArray *strArr = [str componentsSeparatedByString:@"\n"];
                NSMutableArray *dataArr = [[NSMutableArray alloc] init];
                if (strArr.count == 1) {
                    //如果只有一条，三条重复内容循环滚动
                    [dataArr addObject:@{@"newsTitle" : str}];
                    [dataArr addObject:@{@"newsTitle" : str}];
                    [dataArr addObject:@{@"newsTitle" : str}];
                } else {
                    for (NSString *subStr in strArr) {
                        NSDictionary *subDict = @{@"newsTitle" : subStr};
                        [dataArr addObject: subDict];
                    }
                }
                
                UIImage *speakImage = [UIImage imageNamed:@"ic_baoliao_marquee"];
                UIImageView *speakImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.starlableText.x + 4, 15, speakImage.size.width/2.0f, speakImage.size.height/2.0f)];
                speakImageView.image = speakImage;
                [self.view addSubview:speakImageView];
             
                CGRect frame = CGRectMake(CGRectGetMaxX(speakImageView.frame) + 5, 15, kSWidth - speakImageView.width - 5 - 25, 50);
                AutoScrollView *autoScrollview = [[AutoScrollView alloc] initWithFrame:frame array:dataArr articleArr:nil];
                [self.view addSubview:autoScrollview];
                
                self.contentBgView2.y += 25;
                self.contentBgView2.height -= 25;
                contentTextView.height -= 25;
                sendButton.y += 25;
                
                UILabel *statementLabel = [[UILabel alloc] init];
                statementLabel.frame = CGRectMake(self.contentBgView2.x, CGRectGetMaxY(self.userView.frame)+2.5, kSWidth-self.contentBgView2.x, 20);
                statementLabel.text = NSLocalizedString(@"本爆料活动和设备生产商Apple Inc.公司无关",nil);
                statementLabel.font=[UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleCellDateFontSize-1];
                statementLabel.textColor = [UIColor lightGrayColor];
                statementLabel.textAlignment = NSTextAlignmentCenter;
                [self.view addSubview:statementLabel];
            }
        }
    }];
    
    [request setFailedBlock:^(NSError *error) {
        [Global showTipNoNetWork];
    }];
    
    [request startAsynchronous];
    
}

-(void)keyboardDown
{
    [contentTextView resignFirstResponder];
    [phoneNoField resignFirstResponder];
    [subjectField resignFirstResponder];
}
- (void)initOSSClient {
    
    id<OSSCredentialProvider> credential = [[OSSPlainTextAKSKPairCredentialProvider alloc] initWithPlainTextAccessKey:[self.dicInfo objectForKey:@"accessKeyId"]
                                                                                                            secretKey:[self.dicInfo objectForKey:@"accessKeySecret"]];
    
    OSSClientConfiguration * conf = [OSSClientConfiguration new];
    conf.maxRetryCount = 2;
    conf.timeoutIntervalForRequest = 30;
    conf.timeoutIntervalForResource = 24 * 60 * 60;
    
    client = [[OSSClient alloc] initWithEndpoint:[NSString stringWithFormat:@"http://%@",[self.dicInfo objectForKey:@"endpoint"]] credentialProvider:credential clientConfiguration:conf];
}

-(void)genleBtnClick
{
    clueBtn = [SeeMethod newButtonWithFrame:CGRectMake(10+leftGap, topGap, (kSWidth-10-leftGap-10)/3+2, 30) type:UIButtonTypeCustom title:NSLocalizedString(@"线索",nil) target:self UIImage:nil andAction:@selector(titleBtnclcik:)];
    clueBtn.tag =  1267;
    clueBtn.layer.borderWidth = 1;
    clueBtn.layer.borderColor = UIColorFromString(@"234,234,234").CGColor;
    [self.view addSubview:clueBtn];
    duihaoImg1 = [[UIImageView alloc] initWithFrame:CGRectMake((kSWidth-10-leftGap-10)/3-10, 20, 8, 8)];
    duihaoImg1.image = [UIImage imageNamed:@"duihao"];
    duihaoImg1.hidden = YES;
    [clueBtn addSubview:duihaoImg1];
    
    complainBtn = [SeeMethod newButtonWithFrame:CGRectMake(10+leftGap+((kSWidth-10-leftGap-10)/3)*1+5, topGap, (kSWidth-10-leftGap-10)/3-3, 30) type:UIButtonTypeCustom title:@"投诉" target:self UIImage:nil andAction:@selector(titleBtnclcik:)];
    complainBtn.tag = 1268;
    complainBtn.layer.borderWidth = 1;
    complainBtn.layer.borderColor = UIColorFromString(@"234,234,234").CGColor;
    duihaoImg2 = [[UIImageView alloc] initWithFrame:CGRectMake((kSWidth-10-leftGap-10)/3-15, 20, 8, 8)];
    duihaoImg2.image = [UIImage imageNamed:@"duihao"];
    duihaoImg2.hidden = YES;
    [complainBtn addSubview:duihaoImg2];
    [self.view addSubview:complainBtn];
    
    jianjuBtn = [SeeMethod newButtonWithFrame:CGRectMake(10+leftGap+((kSWidth-10-leftGap-10)/3)*2+5, topGap, (kSWidth-10-leftGap-10)/3-3, 30) type:UIButtonTypeCustom title:@"举报" target:self UIImage:nil andAction:@selector(titleBtnclcik:)];
    jianjuBtn.tag =1269;
    jianjuBtn.layer.borderWidth = 1;
    jianjuBtn.layer.borderColor = UIColorFromString(@"234,234,234").CGColor;
    duihaoImg3 = [[UIImageView alloc] initWithFrame:CGRectMake((kSWidth-10-leftGap-10)/3-15, 20, 8, 8)];
    duihaoImg3.image = [UIImage imageNamed:@"duihao"];
    duihaoImg3.hidden = YES;
    [jianjuBtn addSubview:duihaoImg3];
    [self.view addSubview:jianjuBtn];
    
    [self.view addSubview:hellpBtn];
    
}

- (void)loadData
{
    NSString *urlString = [NSString stringWithFormat:@"%@/api/getOSSInfo?sid=%@",[AppConfig sharedAppConfig].serverIf,[AppConfig sharedAppConfig].sid];
    XYLog(@"%@",urlString);
    HttpRequest *request = [HttpRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    [request setCompletionBlock:^(NSData *data) {
        NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        NSString *strEncrypt = [responseDict objectForKey:@"info"];
        if (strEncrypt != nil){
            //开始解密newaircloud_vjow9Dej#JDj4[oIDF
            NSString *strDecrypt = [AESCrypt decrypt:strEncrypt password:key];
            NSData *dataDecrypt = [strDecrypt dataUsingEncoding:NSUTF8StringEncoding];
            self.dicInfo = [NSJSONSerialization JSONObjectWithData:dataDecrypt options:NSJSONReadingMutableContainers error:nil];
            [self initOSSClient];
        }
    }];
    
    [request setFailedBlock:^(NSError *error)
     {
         XYLog(@"send inform attachment error: %@", error);
     }];
    [request startAsynchronous];
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}
-(void)titleBtnclcik:(UIButton *)btn
{
    if (btn.tag == 1267) {
        
        _dishLabel= btn.titleLabel.text;
        btn.layer.borderWidth = 1;
        btn.layer.borderColor = [UIColor redColor].CGColor;
        duihaoImg1.hidden = NO;
        duihaoImg2.hidden = YES;
        duihaoImg3.hidden = YES;
        duihaoImg4.hidden = YES;
        complainBtn.layer.borderColor = UIColorFromString(@"234,234,234").CGColor;
        jianjuBtn.layer.borderColor = UIColorFromString(@"234,234,234").CGColor;
        hellpBtn.layer.borderColor  = UIColorFromString(@"234,234,234").CGColor;
        [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [complainBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [jianjuBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [hellpBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        
    }else if (btn.tag == 1268){
        _dishLabel = btn.titleLabel.text;
        btn.layer.borderWidth = 1;
        btn.layer.borderColor = [UIColor redColor].CGColor;
        duihaoImg2.hidden = NO;
        duihaoImg1.hidden = YES;
        duihaoImg3.hidden = YES;
        duihaoImg4.hidden = YES;
        [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [clueBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [jianjuBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [hellpBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        clueBtn.layer.borderColor= UIColorFromString(@"234,234,234").CGColor;
        jianjuBtn.layer.borderColor = UIColorFromString(@"234,234,234").CGColor;
        hellpBtn.layer.borderColor  = UIColorFromString(@"234,234,234").CGColor;
        
    }else if (btn.tag == 1269){
        _dishLabel= btn.titleLabel.text;
        btn.layer.borderWidth = 1;
        btn.layer.borderColor = [UIColor redColor].CGColor;
        duihaoImg3.hidden = NO;
        duihaoImg1.hidden = YES;
        duihaoImg2.hidden = YES;
        duihaoImg4.hidden = YES;
        [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [clueBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [complainBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [hellpBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        clueBtn.layer.borderColor = UIColorFromString(@"234,234,234").CGColor;
        complainBtn.layer.borderColor = UIColorFromString(@"234,234,234").CGColor;
        hellpBtn.layer.borderColor = UIColorFromString(@"234,234,234").CGColor;
    }else {
        _dishLabel = btn.titleLabel.text;
        btn.layer.borderWidth = 1;
        btn.layer.borderColor = [UIColor redColor].CGColor;
        duihaoImg4.hidden = NO;
        duihaoImg1.hidden = YES;
        duihaoImg2.hidden = YES;
        duihaoImg3.hidden = YES;
        [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [clueBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [complainBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [jianjuBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        clueBtn.layer.borderColor= UIColorFromString(@"234,234,234").CGColor;
        jianjuBtn.layer.borderColor = UIColorFromString(@"234,234,234").CGColor;
        complainBtn.layer.borderColor = UIColorFromString(@"234,234,234").CGColor;
    }
    
}

- (void)send:(id)sender
{
    NSArray *arr = hScrollView.subviews;
    if (arr.count > 9) {
        [Global showTip:NSLocalizedString(@"图片最多只能选9张",nil)];
        return ;
    }
    if ([informAttachments count]){
        for (int i =0 ; i< [informAttachments count];i++) {
            if (((InformAttachment*)[informAttachments objectAtIndex:i]).movieStr.length >0&&[informAttachments count]>1){
                [Global showTip:NSLocalizedString(@"图片和视频不能同时上传",nil)];
                return;
            }
        }
    }
    if ([contentTextView.text isEqualToString:@""]||[contentTextView.text isEqualToString:@" "]||(contentTextView.text == NULL)||[contentTextView.text isKindOfClass:[NSNull class]]||([[contentTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]==0)||[contentTextView.text isEqualToString:contentHoldPlaceText]) {
        [Global showTip:NSLocalizedString(@"报料内容不能为空",nil)];
        return;
    }

    if (![self validateForm])
        return;
    
    if(self.dicInfo == nil){
        [Global showTipNoNetWork];
        [self loadData];
        return;
    }
    
    [self saveUserInfo];

    [sendButton setBackgroundColor:UIColorFromString(@"150, 150, 150")];
    [self setSendButtonEnable:NO];
    [self down:nil];
    
    [self showLoading:10];
    
    if ([informAttachments count]){
        
        BOOL isVideoUpload = NO;
        for (InformAttachment *attachment in informAttachments) {
            if (attachment.movieStr.length > 0) {
                isVideoUpload = YES;
                break;
            }
        }
        // 上传图片
        if (isVideoUpload == NO) {
            
            [self sendAttachment];
        }
        // 上传视频
        else{
            if (((InformAttachment*)[informAttachments objectAtIndex:0]).movieStr.length == 0
                &&[informAttachments count] > 1){
                [informAttachments exchangeObjectAtIndex:0 withObjectAtIndex:1];
            }
            [self sendAttachment2];
        }
    }
    else{
        [self sendInformInfo:nil];
    }
    
}

-(void)showLoading:(NSInteger)percent{

    dispatch_async(dispatch_get_main_queue(), ^{
        //通知主线程刷新
        [Global showTipAlways:[NSString stringWithFormat:@"%@%ld％", NSLocalizedString(@"正在上传中...",nil), percent]];
    });
}
// 上传图片
- (void)sendAttachment{
    
    __block NSMutableArray *urls = [[NSMutableArray alloc] init];
    __block NSInteger percent = 10;
    dispatch_group_t serviceGroup = dispatch_group_create();
    for (int i = 0; i < informAttachments.count; i++) {
        
        dispatch_group_enter(serviceGroup);
        NSInteger step = 80/informAttachments.count;
        OSSPutObjectRequest * put = [OSSPutObjectRequest new];
        put.bucketName = [self.dicInfo objectForKey:@"bucket"];
        put.objectKey = [NSString stringWithFormat:@"%@%@_%d.png",[self.dicInfo objectForKey:@"uploadDir"],[self.dicInfo objectForKey:@"uploadFile"],i];
        put.uploadingData = ((InformAttachment*)[informAttachments objectAtIndex:i]).data;
        
        OSSTask * putTask = [client putObject:put];
        [putTask continueWithBlock:^id(OSSTask *task) {
            if (!task.error) {
                NSString *url = [NSString stringWithFormat:@"%@/%@",[self.dicInfo objectForKey:@"picRoot"],put.objectKey];
                [urls addObject:url];
                percent += step;
                [self showLoading:percent];
            } else {
                NSLog(@"upload object failed, error: %@" , task.error);
            }
            dispatch_group_leave(serviceGroup);
            return nil;
        }];
    }
    
    dispatch_group_notify(serviceGroup, dispatch_get_main_queue(),^{

        if(urls.count != informAttachments.count){
            [Global showTipNoNetWork];
            [self setSendButtonEnable:YES];
            return;
        }
        [self showLoading:90];
        [self sendInformInfo:urls];
    });
}

// 上传视频
- (void)sendAttachment2{
    
    __block NSMutableArray *urls = [[NSMutableArray alloc] init];
    dispatch_group_t serviceGroup = dispatch_group_create();
    //上传视频截图
    for (int i = 0; i < informAttachments.count; i++) {
        dispatch_group_enter(serviceGroup);
        OSSPutObjectRequest * put = [OSSPutObjectRequest new];
        // required fields
        put.bucketName = [self.dicInfo objectForKey:@"bucket"];
        put.objectKey = [NSString stringWithFormat:@"%@%@_%d.png",[self.dicInfo objectForKey:@"uploadDir"],[self.dicInfo objectForKey:@"uploadFile"],i];
        put.uploadingData = self.dataVideopic;
        OSSTask * putTask = [client putObject:put];

        [putTask continueWithBlock:^id(OSSTask *task) {
            if (!task.error) {
               self.videoPicUrl = [NSString stringWithFormat:@"%@/%@",[self.dicInfo objectForKey:@"picRoot"],put.objectKey];
            } else {
                NSLog(@"upload object failed, error: %@" , task.error);
            }
            dispatch_group_leave(serviceGroup);
            return nil;
        }];
    }
    //上传视频
    for (int i = 0; i < informAttachments.count; i++) {
        dispatch_group_enter(serviceGroup);
        OSSPutObjectRequest * put = [OSSPutObjectRequest new];
        __block InformAttachment *informAttachment = [informAttachments objectAtIndex:i];
        // required fields
        put.bucketName = [self.dicInfo objectForKey:@"bucket"];
        put.objectKey = [NSString stringWithFormat:@"%@%@_%d.mp4",[self.dicInfo objectForKey:@"uploadDir"],[self.dicInfo objectForKey:@"uploadFile"],i];
        put.uploadingData = informAttachment.data;
        OSSTask * putTask = [client putObject:put];
        [putTask continueWithBlock:^id(OSSTask *task) {
            if (!task.error) {
                NSString *url = [NSString stringWithFormat:@"%@/%@",[self.dicInfo objectForKey:@"picRoot"],put.objectKey];
                [urls addObject:url];
                NSLog(@"upload:%@", url);
            } else {
                NSLog(@"upload object failed, error: %@" , task.error);
            }
            dispatch_group_leave(serviceGroup);
            return nil;
        }];
    }
    
    dispatch_group_notify(serviceGroup, dispatch_get_main_queue(),^{
   
        if(urls.count != informAttachments.count){
            [Global showTipNoNetWork];
            [self setSendButtonEnable:YES];
            return;
        }
        [self showLoading:90];
        [self sendInformInfo:urls];
    });
}

- (void)sendInformInfo:(NSArray *)urls
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    NSMutableArray *pics = [[NSMutableArray alloc] init];
    NSMutableArray *videos = [[NSMutableArray alloc] init];
    NSMutableArray *videoPics = [[NSMutableArray alloc] init];
    if (urls == nil || [urls count] == 0) {
        dic = nil;
    }
    else {
        int i = 0;
        for (NSString *url in urls) {
            if (((InformAttachment*)[informAttachments objectAtIndex:i]).movieStr.length == 0)
            {
                [pics addObject:url];
            }
            else
            {
                [videos addObject:url];
            }
            i++;
        }
        
    }
    if (self.videoPicUrl.length) {
        [videoPics addObject:self.videoPicUrl];
    }
    [dic setObject:pics forKey:@"pics"];
    [dic setObject:videos forKey:@"videos"];
    [dic setObject:videoPics forKey:@"videoPics"];
    NSString *str15 = @"";
    if (dic != nil) {
        NSString *str = [NSString stringWithFormat:@"%@",dic];
        NSString *str1 = [str stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        NSString *str2 = [str1 stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSString *str3 = [str2 stringByReplacingOccurrencesOfString:@"(" withString:@"["];
        NSString *str4 = [str3 stringByReplacingOccurrencesOfString:@")" withString:@"]"];
        NSString *str5 = [str4 stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        NSString *str6 = [str5 stringByReplacingOccurrencesOfString:@";" withString:@","];
        NSString *str7 = [str6 substringToIndex:str6.length-2];
        NSString *str8 = [NSString stringWithFormat:@"%@}",str7];
        NSString *str9 = [str8 stringByReplacingOccurrencesOfString:@"=" withString:@":"];
        NSString *str10 = [str9 stringByReplacingOccurrencesOfString:@"pics" withString:@"\"pics\""];
        NSString *str11 = [str10 stringByReplacingOccurrencesOfString:@"videos" withString:@"\"videos\""];
        NSString *str12 = [str11 stringByReplacingOccurrencesOfString:@"http" withString:@"\"http"];
        NSString *str13 = [str12 stringByReplacingOccurrencesOfString:@"png" withString:@"png\""];
        NSString *str14 = [str13 stringByReplacingOccurrencesOfString:@"mp4" withString:@"mp4\""];
        str15 = [str14 stringByReplacingOccurrencesOfString:@"videoPics" withString:@"\"videoPics\""];
        XYLog(@"%@",str15);
    }
    
    NSString *title = contentTextView.text;
    
    NSString *urlString = [NSString stringWithFormat:@"%@/api/tipOff",[AppConfig sharedAppConfig].serverIf];
    NSString *informString = [NSString stringWithFormat:@"sid=%@&content=%@&attachment=%@&userName=%@&phone=%@",[AppConfig sharedAppConfig].sid,title,str15,subjectField.text,phoneNoField.text];
    
    NSURL *url = [NSURL URLWithString:urlString];
    HttpRequest *request = [HttpRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    
    NSData *informData = [informString dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:informData];
    
    self.viewhud.hidden = YES;
    [request setCompletionBlock:^(NSData *data) {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers  error:nil];
        if ([[dic objectForKey:@"success"] boolValue]) {
            [self clearForm];
            [self clearLocalFile];
            [informAttachments removeAllObjects];
            [self reloadPreviewImages];
            
            [Global showTip:NSLocalizedString(@"您的报料我们已收到，十分感谢！",nil)];
            [self setSendButtonEnable:YES];
            
            [self performSelector:@selector(returnBack) withObject:nil afterDelay:2];
        }
        else
        {
            [Global showTipNoNetWork];
            [self setSendButtonEnable:YES];
        }
    }];
    
    [request setFailedBlock:^(NSError *error) {
        [Global showTipNoNetWork];
        [self setSendButtonEnable:YES];
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    [request startAsynchronous];
    
}

-(void)setSendButtonEnable:(BOOL)isEnable{
    if(isEnable){
        [sendButton setBackgroundColor:[ColumnBarConfig sharedColumnBarConfig].column_all_color];
        sendButton.enabled = YES;
    }
    else{
        [sendButton setBackgroundColor:UIColorFromString(@"150, 150, 150")];
        sendButton.enabled = NO;
    }
}

// 上传视频截图
- (void)sendAttachmentVideoPic{

    for (int i = 0; i < informAttachments.count; i++) {
        OSSPutObjectRequest * put = [OSSPutObjectRequest new];
        
        // required fields
        put.bucketName = [self.dicInfo objectForKey:@"bucket"];
        put.objectKey = [NSString stringWithFormat:@"%@%@_%d.png",[self.dicInfo objectForKey:@"uploadDir"],[self.dicInfo objectForKey:@"uploadFile"],i];
        put.uploadingData = self.dataVideopic;
        
        OSSTask * putTask = [client putObject:put];
        // 同步
        [putTask waitUntilFinished];
        if (!putTask.error) {
            self.videoPicUrl = [NSString stringWithFormat:@"%@/%@",[self.dicInfo objectForKey:@"picRoot"],put.objectKey];
        } else {
            XYLog(@"upload object failed, error: %@" , putTask.error);
            [Global showTipNoNetWork];
            [self setSendButtonEnable:YES];
            return;
        }
    }
}

- (void)reloadPreviewImages
{
    // page control
    if (pageControl.superview) {
        [pageControl removeFromSuperview];
    }
    
    // remove hScrollView's subviews
    for (UIView *subview in hScrollView.subviews) {
        [subview removeFromSuperview];
    }
    
    int k = 0;
    for (int i = 0; i < informAttachments.count; ++i) {
        InformAttachment *attachment = [informAttachments objectAtIndex:i];
        if (!attachment.flagShow)
        {
            k++;
            continue;
        }
        
        i = i - k;
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(60*(i%4)+10*(int)(i%4+1), 7*(int)(i/4+1)+60*(int)(i/4),60, 60)];
        imageView.contentMode = UIViewContentModeScaleToFill;
        
        //        if (i>2) {
        //            imageView.frame = CGRectMake(100*(i-3), 113,90, 93);
        //        }
        
        if (attachment.movieStr.length)
        {
            if ([attachment.movieStr isEqualToString:@"VIDEO"])
            {
                
                //CGImageRef ratioThum = [attachment.rep aspectRatioThumbnail];
                //                //获取相片的缩略图，该缩略图是相册中每张照片的poster图
                //                CGImageRef thum = [asset thumbnail];
                //                UIImage* rti = [UIImage imageWithCGImage:ratioThum];
                //                imageView.image = rti;
                NSURL *videoURL = [attachment.rep url];
                NSDate * oldDate=[NSDate date];
                NSDate * date=[NSDate date];
                NSTimeInterval time = [date timeIntervalSinceDate:oldDate];
                imageView.image = [self thumbnailImageForVideo:videoURL atTime:time];
                self.dataVideopic = UIImageJPEGRepresentation(imageView.image, 0.5);
            }
            else
                imageView.image = [Global thumbnailImageForVideo:[NSURL URLWithString:attachment.movieStr] atTime:1];
            
            UIImageView *vedioIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"vedioIcon"]];
            vedioIcon.frame = CGRectMake(0, 0, 20, 20);
            vedioIcon.center = CGPointMake(30, 30);
            [imageView addSubview:vedioIcon];
        }
        else
            imageView.image = [UIImage imageWithData:attachment.data];
        
        [self addDeleteButton:imageView index:i];
        
        [hScrollView addSubview:imageView];
        //        DELETE(imageView);
    }
    [self configPhotoButtonFrame];
    
}
-(void)returnBack{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)goRightPageBack{
    if (self.viewControllerType == FDViewControllerForDetailVC) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [super goRightPageBack];
    }
}
-(void)left
{
    [self.sideBar show];
    return;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self titleLableWithTitle:NSLocalizedString(@"报料",nil)];
    [self.navigationController.navigationBar setTranslucent:NO];
    if (self.isMain) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    } else {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
}
#pragma mark - leftPage delegate

- (void)sideBar:(CDRTranslucentSideBar *)sideBar1 willAppear:(BOOL)animated {
    
    [self.leftController updateUserInfo];
}

- (void)sideBar:(CDRTranslucentSideBar *)sideBar1 willDisappear:(BOOL)animated {
    
}

#pragma mark - Gesture Handler

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
#pragma mark - Gesture Handler
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

#pragma mark - UItableView滚动时收键盘
- (void)scrollViewWillBeginDragging:(UITableView *)scrollView
{
    [self.view endEditing:YES];
}

@end
