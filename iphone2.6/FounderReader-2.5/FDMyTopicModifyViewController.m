//
//  FDMyTopicModifyViewController.m
//  FounderReader-2.5
//
//  Created by julian on 2017/6/29.
//
//

#import "FDMyTopicModifyViewController.h"
#import "UIView+Extention.h"
#import "ColorStyleConfig.h"
#import "ColumnBarConfig.h"
#import "UIButton+Block.h"
#import "CommentViewControllerGuo.h"
#import "HttpRequest.h"
#import "AppConfig.h"
#import "AESCrypt.h"
#import <AliyunOSSiOS/OSSService.h>
#import <AliyunOSSiOS/OSSCompat.h>
#import "FDMyTopicViewController.h"

@interface FDMyTopicModifyViewController ()
{
    NSString *_discussContent;
    NSMutableArray *_selectedPhotos;
    
    OSSClient * _client;
    NSDictionary *_dicInfo;
}

@property (strong, nonatomic) FDMyTopic *myTopic;
@property (strong, nonatomic) FDTopicPlusDetaiHeaderlModel *detailModel;
@property (strong, nonatomic) UIScrollView *bgScrollView;
@property (nonatomic, strong) CommentViewControllerGuo *commentController;

@end

@implementation FDMyTopicModifyViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithMyTopic:(FDMyTopic *)myTopic DetailModel:(FDTopicPlusDetaiHeaderlModel *)detailModel
{
    if (self = [super init]) {
        _myTopic = myTopic;
        _detailModel = detailModel;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    
    [self loadOSSInfo];
}

- (void)setupUI
{
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupNav];
    
    [self setupScrollView];
    
    [self setupModifyView];
}

- (void)setupNav {
    self.title = self.myTopic ? self.myTopic.title : NSLocalizedString(@"我要参与", nil);
    //去掉NavigationBar底部的那条黑线
    self.navigationController.navigationBar.barStyle = UIBaselineAdjustmentNone;
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
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"完成", nil) style:UIBarButtonItemStylePlain target:self action:@selector(commitModify)];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    
}

- (void)goPrePage {
    [_commentController cancelMyTopicModify];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)commitModify
{
    [_commentController commitMyTopicModify];
}

- (void)setupScrollView
{
    self.bgScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.bgScrollView.backgroundColor = [UIColor clearColor];
    self.bgScrollView.maximumZoomScale = 20.0f;
    self.bgScrollView.showsHorizontalScrollIndicator = NO;
    self.bgScrollView.showsVerticalScrollIndicator = NO;
    self.bgScrollView.alwaysBounceVertical = YES;//有弹性
    [self.view addSubview:self.bgScrollView];
}

- (void)setupModifyView
{
    [_commentController.view removeFromSuperview];
    [_commentController removeFromParentViewController];
     
    _commentController = [[CommentViewControllerGuo alloc] initWithMyTopic:self.myTopic DetailModel:self.detailModel];
    [self.bgScrollView addSubview:_commentController.view];
    [self addChildViewController:_commentController];
    __weak __typeof(self)weakSelf = self;
    NSString *title = self.myTopic ? self.myTopic.title : @"请输入您希望提交的内容";
    [_commentController setupCommentViewWith:NSLocalizedString(title, nil) SubTitle:nil IsTopic:YES HandleBlock:^(NSString *discussContent,NSMutableArray *photos) {
        _discussContent = discussContent;
        _selectedPhotos = [photos mutableCopy];
        if (weakSelf.myTopic)
            [weakSelf toModifyDiscuss];
        else
            [weakSelf toAddDiscuss];
    }];
    _commentController.cancelHandleBlock = ^() {
        [weakSelf cancelDiscuss];
    };
}

- (void)cancelDiscuss
{
    [_selectedPhotos removeAllObjects];
}


#pragma mark - add discuss
- (void)toAddDiscuss
{
    if ([_selectedPhotos count])
        [self sendAddPicsToAliyun];
    else
        [self addDicuss:nil];
}

- (void)addDicuss:(NSString *)attUrls
{
    // 若参与话题，默认关注此问答
    NSString *urlString = [NSString stringWithFormat:@"%@/topicApi/insertDiscuss", [AppConfig sharedAppConfig].serverIf];
    HttpRequest *addAskRequest = [HttpRequest requestWithURL:[NSURL URLWithString:urlString]];
    [addAskRequest setValue:@"newaircloud.com" forHTTPHeaderField:@"Referer"];
    [addAskRequest setHTTPMethod:@"POST"];
    // 评论页面中已被转义，加密时需要字符解码[askStr stringByRemovingPercentEncoding]
    NSString *sign = [AESCrypt encrypt:[NSString stringWithFormat:@"%@%@%@%@", [AppConfig sharedAppConfig].sid, [Global userId], self.detailModel.topicID, [_discussContent stringByRemovingPercentEncoding]] password:key];
    
    NSString *bodyString = [NSString stringWithFormat:@"sid=%@&topicID=%ld&uid=%@&content=%@&publishStatus=%ld&sign=%@",[AppConfig sharedAppConfig].sid, self.detailModel.topicID.integerValue, [Global userId], _discussContent, _detailModel.publishStatus.integerValue, sign];
    if(![NSString isNilOrEmpty:attUrls])
        bodyString = [bodyString stringByAppendingString:[NSString stringWithFormat:@"&attUrls=%@", attUrls]];
    
    [addAskRequest setHTTPBody:[bodyString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [addAskRequest setCompletionBlock:^(NSData *data) {
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers  error:nil];
        if ([[dic objectForKey:@"success"] boolValue]) {
            [Global showTip:NSLocalizedString([dic objectForKey:@"msg"], nil)];
            [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(popViewController) userInfo:nil repeats:NO];
        }else{
            [Global showTip:[NSString stringWithFormat:@"%@%@", NSLocalizedString(@"提交失败",nil),[dic objectForKey:@"msg"]]];
        }
    }];
    [addAskRequest setFailedBlock:^(NSError *error) {
        [Global showTipNoNetWork];
    }];
    [addAskRequest startAsynchronous];
}

#pragma mark - modify discuss

- (void)toModifyDiscuss
{
    NSString *content = [_discussContent stringByRemovingPercentEncoding];
    BOOL isModifyContent = [content isEqualToString:self.myTopic.content];
    BOOL isModifyPhotos = (_selectedPhotos.count == 0 && self.commentController.modifyPhotoDics.count == self.myTopic.pics.count);
    if (isModifyContent && isModifyPhotos) {
        [Global showTip:NSLocalizedString(@"你的话题已提交，请等待审核",nil)];
        [self popToListPage];
        return;
    }
    
    if ([_selectedPhotos count])
        /* 有新增图片 */
        [self sendModifyPicsToAliyun];
    else {
        if (self.commentController.modifyPhotoDics.count == 0) {
            /* 原来没有待修改的图片 */
            [self modifyDicuss:nil];
        }else {
            /* 原来待修改的图片被删减 */
            NSMutableArray *picUrls = [[NSMutableArray alloc] init];
            //取出原有图片路径
            for (NSDictionary *modifyDict in self.commentController.modifyPhotoDics) {
                NSString *url = modifyDict.allKeys[0];
                NSMutableDictionary *dictTmp = [[NSMutableDictionary alloc] init];
                [dictTmp setObject:url forKey:@"url"];
                [picUrls addObject:dictTmp];
            }
            // 数组转json字符串
            NSMutableDictionary *allUrlDict = [NSMutableDictionary dictionaryWithObject:picUrls forKey:@"pics"];
            NSString *allUrls = [Global dictionaryToJson:allUrlDict];
            allUrls = [allUrls stringByReplacingOccurrencesOfString:@" " withString:@""];
            allUrls = [allUrls stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            allUrls = [allUrls stringByReplacingOccurrencesOfString:@"\\" withString:@""];
            [self modifyDicuss:allUrls];
        }
    }
}

- (void)modifyDicuss:(NSString *)attUrls
{
    // 若参与话题，默认关注此问答
    NSString *urlString = [NSString stringWithFormat:@"%@/topicApi/modifyDiscuss", [AppConfig sharedAppConfig].serverIf];
    HttpRequest *addAskRequest = [HttpRequest requestWithURL:[NSURL URLWithString:urlString]];
    [addAskRequest setValue:@"newaircloud.com" forHTTPHeaderField:@"Referer"];
    [addAskRequest setHTTPMethod:@"POST"];
    // 评论页面中已被转义，加密时需要字符解码[askStr stringByRemovingPercentEncoding]
    NSString *sign = [AESCrypt encrypt:[NSString stringWithFormat:@"%@%@%@%@", [AppConfig sharedAppConfig].sid, [Global userId], self.myTopic.topicID, self.myTopic.discussID] password:key];
    
    NSString *bodyString = [NSString stringWithFormat:@"sid=%@&topicID=%ld&discussID=%ld&uid=%@&content=%@&sign=%@&discussStatus=0",[AppConfig sharedAppConfig].sid, self.myTopic.topicID.integerValue, self.myTopic.discussID.integerValue,[Global userId], _discussContent, sign];
    if(![NSString isNilOrEmpty:attUrls])
        bodyString = [bodyString stringByAppendingString:[NSString stringWithFormat:@"&attUrls=%@", attUrls]];
    
    [addAskRequest setHTTPBody:[bodyString dataUsingEncoding:NSUTF8StringEncoding]];
    __weak __typeof (self)weakSelf = self;
    [addAskRequest setCompletionBlock:^(NSData *data) {
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers  error:nil];
        if ([[dic objectForKey:@"success"] boolValue]) {
            [Global showTip:NSLocalizedString(@"修改成功，请等待审核",nil)];
            [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(popViewController) userInfo:nil repeats:NO];
        }else{
            [Global showTip:[NSString stringWithFormat:@"%@%@", NSLocalizedString(@"修改失败",nil),[dic objectForKey:@"msg"]]];
        }
    }];
    [addAskRequest setFailedBlock:^(NSError *error) {
        [Global showTipNoNetWork];
    }];
    [addAskRequest startAsynchronous];
    
    // 若提问，默认关注此问答
    //    _isFromAsking = YES;
    //    [self toAttention:_topMainView.attentionBtn];
}

- (void)popToListPage
{
    FDMyTopicViewController * listVC = nil;
    for (UIViewController * VC in self.navigationController.viewControllers) {
        if ([VC isKindOfClass:[FDMyTopicViewController class]]) {
            listVC = (FDMyTopicViewController *)VC;
        }
    }
    [self.navigationController popToViewController:listVC animated:YES];
}

- (void)popViewController
{
   if (self.myTopic) {
       // 刷新话题首列表页信息
       [[NSNotificationCenter defaultCenter] postNotificationName:@"updateMyTopicInfoByDetail"
                                                           object:self.myTopic];
        [self popToListPage];
    }else {
        if (self.successAddDiscussBlock)
            self.successAddDiscussBlock();
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark ====== 阿里云存储

- (void)initOSSClient {
    
    id<OSSCredentialProvider> credential = [[OSSPlainTextAKSKPairCredentialProvider alloc] initWithPlainTextAccessKey:[_dicInfo objectForKey:@"accessKeyId"] secretKey:[_dicInfo objectForKey:@"accessKeySecret"]];
    
    OSSClientConfiguration * conf = [OSSClientConfiguration new];
    conf.maxRetryCount = 2;
    conf.timeoutIntervalForRequest = 30;
    conf.timeoutIntervalForResource = 24 * 60 * 60;
    
    _client = [[OSSClient alloc] initWithEndpoint:[NSString stringWithFormat:@"http://%@",[_dicInfo objectForKey:@"endpoint"]] credentialProvider:credential clientConfiguration:conf];
}

- (void)loadOSSInfo
{
    _dicInfo = [NSDictionary dictionary];
    
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
            _dicInfo = [NSJSONSerialization JSONObjectWithData:dataDecrypt options:NSJSONReadingMutableContainers error:nil];
            [self initOSSClient];
        }
    }];
    
    [request setFailedBlock:^(NSError *error)
     {
         XYLog(@"send inform attachment error: %@", error);
     }];
    [request startAsynchronous];
}

#pragma mark 上传图片

- (void)sendAddPicsToAliyun
{
    if([NSString isNilOrEmpty:[_dicInfo objectForKey:@"bucket"]]){
        [Global showTipNoNetWork];
        [self loadOSSInfo];
        return;
    }
    
    __block int j = 1;
    __block NSMutableArray *picUrlArr = [[NSMutableArray alloc] init];
    dispatch_group_t serviceGroup = dispatch_group_create();
    for (int i = 0; i < _selectedPhotos.count; i++) {
        
        NSTimeInterval interval = [[NSDate date] timeIntervalSince1970] * 1000;
        dispatch_group_enter(serviceGroup);
        OSSPutObjectRequest * put = [OSSPutObjectRequest new];
        put.bucketName = [_dicInfo objectForKey:@"bucket"];
        put.objectKey = [NSString stringWithFormat:@"%@%@_img_%f.png",[_dicInfo objectForKey:@"uploadDir"],[_dicInfo objectForKey:@"uploadFile"],interval];
        /* 两种压缩方式，png和jpeg，对清晰度不是很要求的话后者压缩力度很大且很快 */
        //    put.uploadingData = UIImagePNGRepresentation(image);
        put.uploadingData = [Global compressImageData:_selectedPhotos[i]];
        XYLog(@"第%d张图片大小为%ldKB",i, put.uploadingData.length/1024);
        
        OSSTask * putTask = [_client putObject:put];
        [putTask continueWithBlock:^id(OSSTask *task) {
            if (!task.error) {
                NSString *url = [NSString stringWithFormat:@"%@/%@",[_dicInfo objectForKey:@"picRoot"],put.objectKey];
                [picUrlArr addObject:url];
                j = j<_selectedPhotos.count ? j+1 : j;
                if (j == _selectedPhotos.count) {
                    NSString *alertTitle = [NSString stringWithFormat:@"%@%@",@"正在上传中...",@"99%"];
                    [self showLoading:alertTitle];
                }else {
                    NSString*alertTitle = [NSString stringWithFormat:@"%@%.0f%@",@"正在上传中...",((float)j/(_selectedPhotos.count))*100, @"%"];
                    XYLog(@"分子j=%d,分母count=%lu,分数float=%f",j,(unsigned long)_selectedPhotos.count,((float)j/(_selectedPhotos.count)));
                    [self showLoading:alertTitle];
                }
            } else {
                XYLog(@"upload object failed, error: %@" , task.error);
            }
            dispatch_group_leave(serviceGroup);
            return nil;
        }];
    }
    
    dispatch_group_notify(serviceGroup, dispatch_get_main_queue(),^{
        if(picUrlArr.count != _selectedPhotos.count){
            [self showLoading:NSLocalizedString(@"网络不给力，请检查一下网络设置", nil)];
            return;
        }
        NSArray *picUrlsTemp = [picUrlArr sortedArrayUsingSelector:@selector(compare:)];
        NSMutableArray *picUrls = [NSMutableArray array];
        for (NSString *url in picUrlsTemp) {
            NSMutableDictionary *dictTmp = [[NSMutableDictionary alloc] init];
            [dictTmp setObject:url forKey:@"url"];
            // 字典转json字符串
            //            NSString *jsonDic = [Global dictionaryToJson:dictTmp];
            [picUrls addObject:dictTmp];
        }
        // 数组转json字符串
        //        picUrlsJson = [Global objArrayToJSON:picUrls];
        // 那些层需要转成json串，取决于后台怎么解析的，这里只是最外面包一层
        NSMutableDictionary *allUrlDict = [NSMutableDictionary dictionaryWithObject:picUrls forKey:@"pics"];
        NSString *allUrls = [Global dictionaryToJson:allUrlDict];
        allUrls = [allUrls stringByReplacingOccurrencesOfString:@" " withString:@""];
        allUrls = [allUrls stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        allUrls = [allUrls stringByReplacingOccurrencesOfString:@"\\" withString:@""];
        [self addDicuss:allUrls];
        
    });
}

// 上传图片
- (void)sendModifyPicsToAliyun
{
    if([NSString isNilOrEmpty:[_dicInfo objectForKey:@"bucket"]]){
        [Global showTipNoNetWork];
        [self loadOSSInfo];
        return;
    }
    
    __block int j = 1;
    __block NSMutableArray *picUrlArr = [[NSMutableArray alloc] init];
    //取出原有图片路径
    for (NSDictionary *modifyDict in self.commentController.modifyPhotoDics) {
        NSString *url = modifyDict.allKeys[0];
        [picUrlArr addObject:url];
    }
    
    dispatch_group_t serviceGroup = dispatch_group_create();
    for (int i = 0; i < _selectedPhotos.count; i++) {
        
        NSTimeInterval interval = [[NSDate date] timeIntervalSince1970] * 1000;
        dispatch_group_enter(serviceGroup);
        OSSPutObjectRequest * put = [OSSPutObjectRequest new];
        put.bucketName = [_dicInfo objectForKey:@"bucket"];
        put.objectKey = [NSString stringWithFormat:@"%@%@_img_%f.png",[_dicInfo objectForKey:@"uploadDir"],[_dicInfo objectForKey:@"uploadFile"],interval];
        /* 两种压缩方式，png和jpeg，对清晰度不是很要求的话后者压缩力度很大且很快 */
        //    put.uploadingData = UIImagePNGRepresentation(image);
        put.uploadingData = [Global compressImageData:_selectedPhotos[i]];
        XYLog(@"第%d张图片大小为%ldKB",i, put.uploadingData.length/1024);
        
        OSSTask * putTask = [_client putObject:put];
        [putTask continueWithBlock:^id(OSSTask *task) {
            if (!task.error) {
                NSString *url = [NSString stringWithFormat:@"%@/%@",[_dicInfo objectForKey:@"picRoot"],put.objectKey];
                [picUrlArr addObject:url];
                j = j<_selectedPhotos.count ? j+1 : j;
                if (j == _selectedPhotos.count) {
                    NSString *alertTitle = [NSString stringWithFormat:@"%@%@", @"正在上传中...",@"99%"];
                    [self showLoading:alertTitle];
                }else {
                    NSString*alertTitle = [NSString stringWithFormat:@"%@%.0f%@", @"正在上传中...",((float)j/(_selectedPhotos.count))*100, @"%"];
                    XYLog(@"分子j=%d,分母count=%lu,分数float=%f",j,(unsigned long)_selectedPhotos.count,((float)j/(_selectedPhotos.count)));
                    [self showLoading:alertTitle];
                }
            } else {
                XYLog(@"upload object failed, error: %@" , task.error);
            }
            dispatch_group_leave(serviceGroup);
            return nil;
        }];
    }
    
    dispatch_group_notify(serviceGroup, dispatch_get_main_queue(),^{
        if(picUrlArr.count != (self.commentController.modifyPhotoDics.count + _selectedPhotos.count)){
            [self showLoading:NSLocalizedString(@"网络不给力，请检查一下网络设置", nil)];
            return;
        }
        NSArray *picUrlsTemp = [picUrlArr sortedArrayUsingSelector:@selector(compare:)];
        NSMutableArray *picUrls = [NSMutableArray array];
        for (NSString *url in picUrlsTemp) {
            NSMutableDictionary *dictTmp = [[NSMutableDictionary alloc] init];
            [dictTmp setObject:url forKey:@"url"];
            [picUrls addObject:dictTmp];
        }
        // 数组转json字符串
        NSMutableDictionary *allUrlDict = [NSMutableDictionary dictionaryWithObject:picUrls forKey:@"pics"];
        NSString *allUrls = [Global dictionaryToJson:allUrlDict];
        allUrls = [allUrls stringByReplacingOccurrencesOfString:@" " withString:@""];
        allUrls = [allUrls stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        allUrls = [allUrls stringByReplacingOccurrencesOfString:@"\\" withString:@""];
        [self modifyDicuss:allUrls];
    });
}

- (void)showLoading:(NSString *)alertTitle{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //通知主线程刷新
        [Global showTipAlways:alertTitle];
    });
}

@end
