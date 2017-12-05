//
//  CommentViewControllerGuo.m
//  FounderReader-2.5
//
//  Created by ld on 14-2-13.
//
//

#import "CommentViewControllerGuo.h"
#import <QuartzCore/QuartzCore.h>
#import "Comment.h"
#import "UIAlertView+Helper.h"
#import "HttpRequest.h"
#import "DataLib/DataLib.h"
#import "NSString+Helper.h"
#import "FCReader_OpenUDID.h"
#import "CommentConfig.h"
#import "Defines.h"
#import "UserAccountDefine.h"
#import "AppStartInfo.h"
#import "AppConfig.h"
#import "AppStartInfo.h"
#import "FounderIntegralRequest.h"
#import "FounderEventRequest.h"
#import "UIView+Extention.h"
#import "NSString+Helper.h"
#import "ColumnBarConfig.h"
#import "UIButton+Block.h"
#import "UIImageView+WebCache.h"
#import "SDWebImageManager.h"

#import "TZImagePickerController.h"
#import "UIView+Layout.h"
#import "FDTopicImageCell.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "FDTopicViewFlowLayout.h"
#import "TZImageManager.h"
#import "TZVideoPlayerController.h"
#import "TZPhotoPreviewController.h"
#import "TZGifPhotoPreviewController.h"
#import "TZLocationManager.h"
#import "UIView + ExtendTouchRect.h"
#import "FDTopicCommentSeparateView.h"

#define showTakePhotoBtnSwitch 1            // 在内部显示拍照按钮
#define sortAscendingSwitch 1               // 照片排列按修改时间升序
#define allowPickingImageSwitch 1           // 允许选择图片
#define allowPickingGifSwitch 0             // 允许选择Gif图片
#define allowPickingVideoSwitch 0           // 允许选择视频
#define allowPickingOriginalPhotoSwitch 0   // 允许选择原图
#define showSheetSwitch 0                   // 显示一个sheet,把拍照按钮放在外面
#define maxCountTF 9                        // 照片最大可选张数，设置为1即为单选模式
#define columnNumberTF 4                    // 相册中每行显示照片张数
#define allowCropSwitch 0                   // 是否需要裁剪
#define needCircleCropSwitch 0              // 是否需要圆形裁剪
#define needSortSelectedImagesSwitch 0      // 是否需要手势排列已选的图片

#define kTopic_TextView_PlaceHolder NSLocalizedString(@"我也要说一说",nil)

@interface CommentViewControllerGuo()<UIGestureRecognizerDelegate, TZImagePickerControllerDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UIAlertViewDelegate,UINavigationControllerDelegate>
{
    NSMutableArray *_selectedPhotos;
    NSMutableArray *_selectedAssets;
    NSMutableArray *_modifyPhotoDics;
    BOOL _isSelectOriginalPhoto;
    
    CGFloat _itemWH;
    CGFloat _margin;
}

@property(nonatomic, strong)UILabel *titleLabel;
@property(nonatomic, copy)FootHandleBlock footHandleBlock;
@property(nonatomic, strong)UIView *subTitleBgView;

@property (nonatomic, strong) UIImagePickerController *imagePickerVc;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (strong, nonatomic) CLLocation *location;

@property(nonatomic, strong)FDMyTopic *myTopic;//若存在，来自我的话题修改页面
@property(nonatomic, strong)FDTopicPlusDetaiHeaderlModel *detailModel;//若存在，来自话题详情栏目
@property(nonatomic, assign)BOOL isFromTopicDetailPage;//是否来自话题详情页面,但不是话题详情栏目

@end

@implementation CommentViewControllerGuo
@synthesize article;
@synthesize fullColumn;
@synthesize textView;
@synthesize submitButton,current,commentID,rootID,parentUserID,cancelButton;
@synthesize commentScore;
@synthesize isPDF;

- (instancetype)initWithMyTopic:(FDMyTopic *)myTopic DetailModel:(FDTopicPlusDetaiHeaderlModel *)detailModel
{
    if (self = [super init]) {
        _myTopic = myTopic;
        _detailModel = detailModel;
    }
    return self;
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:.2f];
    // 去掉点击其他地方评论页消失手势
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancel)];
//    tap.delegate = self;
//    [self.view addGestureRecognizer:tap];
    
    _backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, kSHeight - (10 + 40 + .4f*kSWidth + 10), kSWidth, 10 + 40 + .4f*kSWidth + 10)];
    _backgroundView.backgroundColor = [UIColor colorWithRed:235/255.f green:235/255.f blue:235/255.f alpha:1];
    [self.view addSubview:_backgroundView];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, kSWidth, 40)];
    _titleLabel.text = NSLocalizedString(@"写评论",nil);
    _titleLabel.font = [UIFont systemFontOfSize:18];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.textColor = colorWithHexString(@"333333");
    [_backgroundView addSubview:_titleLabel];
    
    submitButton = [[UIButton alloc] initWithFrame:CGRectMake(kSWidth - 60, 10, 60, 40)];
    [submitButton setTitle:NSLocalizedString(@"发布",nil) forState:UIControlStateNormal];
    [submitButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [submitButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    submitButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [submitButton addTarget:self action:@selector(submitButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    submitButton.enabled = NO;
    [_backgroundView addSubview:submitButton];
    
    cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 10, 60, 40)];
    [cancelButton setTitle:NSLocalizedString(@"取消",nil) forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    cancelButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [cancelButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    [_backgroundView addSubview:cancelButton];
    
    textView = [[UITextView alloc]initWithFrame:CGRectMake(10, 50, kSWidth-20, .4f * kSWidth)];
    textView.layer.cornerRadius = 3;
    textView.layer.masksToBounds = YES;
    textView.layer.borderColor = [colorWithHexString(@"bebebe") CGColor];
    textView.layer.borderWidth = 1;
    [textView setClipsToBounds:YES];
    textView.font = [UIFont systemFontOfSize:15];
    textView.delegate = self;
    if (!self.myTopic && !self.detailModel) {// 不是修改我的话题页面和话题详情栏目就不聚焦
        [textView becomeFirstResponder];
    }
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textViewDidEndEditing:)
                                                name:@"UITextViewTextDidEndEditingNotification" object:textView];
    
    [_backgroundView addSubview:textView];

    if (IS_IPHONE_6) {
        _titleLabel.font = [UIFont systemFontOfSize:18];
        cancelButton.titleLabel.font = [UIFont systemFontOfSize:16];
        submitButton.titleLabel.font = [UIFont systemFontOfSize:16];
    } else if (IS_IPHONE_6P) {
        _titleLabel.font = [UIFont systemFontOfSize:20];
        cancelButton.titleLabel.font = [UIFont systemFontOfSize:17];
        submitButton.titleLabel.font = [UIFont systemFontOfSize:17];
    } else {
        _titleLabel.font = [UIFont systemFontOfSize:16];
        cancelButton.titleLabel.font = [UIFont systemFontOfSize:13];
        submitButton.titleLabel.font = [UIFont systemFontOfSize:13];
    }
    
    [self backButton];
    [self calculateTextLength];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)noti {
    if (!self.myTopic && !self.detailModel){
        CGFloat height = [[noti.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
        if (!height) {
            return;
        }
        self.view.y = - height;
    }
}

- (void)keyboardWillHide:(NSNotification *)noti {
    self.view.y = 0;
}

- (void)cancel {
    if(self.isFromTopicDetailPage && (!self.myTopic && !self.detailModel)){
        //来自话题详情，不包括来自修改我的话题详情
        [self cancelTopicDiscuss];
        return;
    }
    //普通评论页面
    [self cancelCommit];
}

- (void)cancelCommit
{
    [_selectedPhotos removeAllObjects];
    [_selectedAssets removeAllObjects];
    self.collectionView = nil;
    if (self.cancelHandleBlock)
        self.cancelHandleBlock();
    [self.view removeFromSuperview];
}

- (void)backButton {
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"whiteBack"] style:UIBarButtonItemStylePlain target:self action:@selector(goBackIOS6)];
        self.navigationItem.leftBarButtonItem = leftItem;
    }else{
        UIImage *leftImage = [UIImage imageNamed:@"whiteBack"];
        UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        leftButton.frame = CGRectMake(0, 0, leftImage.size.width, leftImage.size.height);
        [leftButton setBackgroundImage:leftImage forState:UIControlStateNormal];
        //    [rightButton setTitle:@"下载" forState:UIControlStateNormal];
        [leftButton addTarget:self action:@selector(goBackIOS6) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
        self.navigationItem.leftBarButtonItem = leftItem;
    }
}

-(void)goBackIOS6
{
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
}
- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self setTextView:nil];
    
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)validateForm
{
    textView.text = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (![textView hasText]) {
        [Global showTip:NSLocalizedString(@"请输入评论内容",nil)];
        return NO;
    }
    
    if (textView.text.length > 140) {
        [Global showTip:NSLocalizedString(@"评论字数不能超过140个字符",nil)];
        return NO;
    }
    
    return YES;
}



- (void)submitButtonClicked:(id)sender
{
    if (![self validateForm])
        return;
    [Global showTipAlways:NSLocalizedString(@"正在发送...",nil)];
    HttpRequest *request = [HttpRequest requestWithURL:[NSURL URLWithString:self.urlStr]];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *userName = [defaults stringForKey:KuserAccountNickName];
    if ([userName length] == 0) {
        userName = [CommentConfig sharedCommentConfig].defaultNickName;
    }
  
    NSString *userId = [Global userId];
    if(userId.length == 0)
    {
        userId = @"-1";
        userName = NSLocalizedString(@"手机用户",nil);
    }
    
    //评论类型sourceType :0是稿件，1直播，2是评论的评论(暂时不用)，3是数字报
    if (self.isPDF) {
        self.sourceType = 3;
    }else{
        if (article.articleType == ArticleType_LIVESHOW) {
            self.sourceType = 1;
        }
    }
    // 转义特殊字符
    CFStringRef contentstr = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                           (CFStringRef)textView.text,
                                                           NULL,
                                                           CFSTR(":/?#[]@!$&’()*+,;="),
                                                           kCFStringEncodingUTF8);
    if (self.footHandleBlock) {
        self.footHandleBlock((__bridge NSString *)contentstr, _selectedPhotos);
        return;
    }
    
    NSString *bodyString = [NSString stringWithFormat:@"sid=%@&rootID=%zd&parentID=%zd&content=%@&sourceType=%zd&articleType=%d&userID=%@&userName=%@&topic=%@",[AppConfig sharedAppConfig].sid,rootID,commentID,(__bridge NSString *)contentstr,self.sourceType,article.articleType,userId,userName,article.title];

    CFRelease(contentstr);
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[bodyString dataUsingEncoding:NSUTF8StringEncoding]];
    __weak __typeof (self)weakSelf = self;
    [request setCompletionBlock:^(NSData *data) {

        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers  error:nil];
        if ([[dic objectForKey:@"success"] boolValue]) {
            
            if (self.successCommentBlock)
                self.successCommentBlock();
            
            //积分入库
            FounderIntegralRequest *IntegralRequest = [[FounderIntegralRequest alloc] init];
            NSString *dateSign = [NSString stringWithFormat:@"CommDate-%@",[Global userId]];
            NSDate *commentDate = [[NSUserDefaults standardUserDefaults] objectForKey:dateSign];
            if ([[dic objectForKey:@"noAudit"] boolValue] == 0)//0为先审后发，1为先发后审
            {
                //积分入库达到上限次数，本日不调用积分入库接口
                if ([IntegralRequest isSameDay:commentDate date2:[NSDate date]]) {
                    [Global showTip:NSLocalizedString(@"您的评论已提交，请等待审核",nil)];
                }else{
                    [IntegralRequest addIntegralWithUType:UTYPE_COMMENT integralBlock:^(NSDictionary *integralDict) {
                        
                        if (!integralDict || ![[integralDict objectForKey:@"success"] boolValue]) {
                            [Global showTip:NSLocalizedString(@"您的评论已提交，请等待审核",nil)];
                            XYLog(@"评论积分错误:%@", [integralDict objectForKey:@"msg"]);
                        }else{
                            NSInteger score = [[integralDict objectForKey:@"score"] integerValue];
                            if (score) {//score分数不为0提醒
                                [Global showTip:[NSString stringWithFormat:@"%@，%@+%ld", NSLocalizedString(@"您的评论已提交，请等待审核",nil), [AppConfig sharedAppConfig].integralName, (long)score]];
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"duiba-load-WebView" object:weakSelf userInfo:nil];
                            }else{//score分数为0今日不调积分入库接口
                                [Global showTip:NSLocalizedString(@"您的评论已提交，请等待审核",nil)];
                                [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:dateSign];
                            }
                        }
                    }];
                }
                
                [weakSelf performSelector:@selector(cancel) withObject:[NSNumber numberWithBool:YES] afterDelay:1];
            } else if([[dic objectForKey:@"noAudit"] boolValue] == 1) {
                //积分入库达到上限次数，本日不访问积分入库方法
                if ([IntegralRequest isSameDay:commentDate date2:[NSDate date]]) {
                    [Global showTip:NSLocalizedString(@"您的评论已提交",nil)];
                }else{
                    [IntegralRequest addIntegralWithUType:UTYPE_COMMENT integralBlock:^(NSDictionary *integralDict) {
                        
                        if (!integralDict || ![[integralDict objectForKey:@"success"] boolValue]) {
                            [Global showTip:NSLocalizedString(@"您的评论已提交",nil)];
                        }else{
                            NSInteger score = [[integralDict objectForKey:@"score"] integerValue];
                            if (score) {
                                [Global showTip:[NSString stringWithFormat:@"%@，%@+%ld", NSLocalizedString(@"您的评论已提交",nil), [AppConfig sharedAppConfig].integralName, (long)score]];
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"duiba-load-WebView" object:weakSelf userInfo:nil];
                            }else{
                                [Global showTip:NSLocalizedString(@"您的评论已提交",nil)];
                                [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"CommentIntegralDate"];
                            }
                        }
                        
                    }];
                }
                [weakSelf performSelector:@selector(cancel) withObject:[NSNumber numberWithBool:YES] afterDelay:1];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"reload" object:nil];
                if ([weakSelf.delegate respondsToSelector:@selector(reloadTableView)])
                {
                    [weakSelf.delegate reloadTableView];
                }
            }
            //[FounderEventRequest articlecommentDateAnaly:article.fileId column:weakSelf.fullColumn];
        }
        else {

            [Global showTipNoNetWork];
        }
    }];
    [request setFailedBlock:^(NSError *error) {
        [Global showTipNoNetWork];
    }];
    [request startAsynchronous];
}

//- (void)seeSubmitButtonClicked:(id)sender
//{
//    if (![self validateForm])
//        return;
//    
//    NSString *urlString = [NSString stringWithFormat:@"%@/discuss",[AppConfig sharedAppConfig].serverIf];
//    HttpRequest *request = [HttpRequest requestWithURL:[NSURL URLWithString:urlString]];
//    
//    NSString *userName = [Global userName];
//    NSString *userid = [Global userId];
//    if ([userid isEqualToString: @""]) {
//        userid = @"0";
//    }
//    if ([userName isEqualToString:@""]) {
//        userName = NSLocalizedString(@"手机用户",nil);
//    }
//    //要求直播评论不登陆也能评论，但是配置文件相应地方已经是0，不需要登陆，没效果，所以直接注释掉了登陆页的弹出，并在这里给id，name赋值
//    
//    CFStringRef contentstr = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
//                                                                     (CFStringRef)textView.text,
//                                                                     NULL,
//                                                                     CFSTR(":/?#[]@!$&’()*+,;=%"),
//                                                                     kCFStringEncodingUTF8);
//    NSString *bodyString = [NSString stringWithFormat:@"sid=%@&rootID=%zd&parentID=%zd&content=%@&sourceType=%zd&articleType=6&userID=%@&userName=%@&topic=%@",[AppConfig sharedAppConfig].sid,rootID,commentID,(__bridge NSString *)contentstr,current,userid,userName,article.title];
//
//    [request setHTTPMethod:@"POST"];
//    [request setHTTPBody:[bodyString dataUsingEncoding:NSUTF8StringEncoding]];
//    __weak __typeof (self)weakSelf = self;
//    [request setCompletionBlock:^(NSData *data) {
//        NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//        
//        if ([str isEqualToString:@"true"]) {
//            [Global showTip:NSLocalizedString(@"您的评论已提交，请等待审核",nil)];
//            [weakSelf performSelector:@selector(cancel) withObject:[NSNumber numberWithBool:YES] afterDelay:1];
//           
//        } else {
//            [Global showTipNoNetWork];
//        } 
//    }];
//    [request setFailedBlock:^(NSError *error) {
//        XYLog(@"comment failed: %@", error);
//        [Global showTipNoNetWork];
//    }];
//    [request startAsynchronous];
//}


#pragma mark --calculate Text length
- (void)calculateTextLength
{
//    UIBarButtonItem *sendButton = self.navigationItem.rightBarButtonItem;
    if (textView.text.length > 0)
        [submitButton setEnabled:YES];
	else
		[submitButton setEnabled:NO];
    
}

#pragma mark - UITextViewDelegate Methods

- (void)textViewDidChange:(UITextView *)textView
{
    self.textView.textColor = colorWithHexString(@"333333");
    if ((self.isFromTopicDetailPage || (self.myTopic || self.detailModel)) && [self.textView.text containsString:kTopic_TextView_PlaceHolder])
        self.textView.text = [self.textView.text stringByReplacingOccurrencesOfString:kTopic_TextView_PlaceHolder withString:@""];
    [self calculateTextLength];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if ((self.isFromTopicDetailPage || (self.myTopic || self.detailModel)) && self.textView.text.length<1) {
        self.textView.text = kTopic_TextView_PlaceHolder;
        self.textView.textColor = colorWithHexString(@"999999");
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if ((self.isFromTopicDetailPage || (self.myTopic || self.detailModel)) && [self.textView.text isEqualToString:kTopic_TextView_PlaceHolder]) {
        self.textView.text = @"";
        self.textView.textColor = colorWithHexString(@"333333");
    }
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    if ((self.isFromTopicDetailPage || (self.myTopic || self.detailModel)) && [self.textView.text isEqualToString:kTopic_TextView_PlaceHolder]) {
        self.textView.text = @"";
        self.textView.textColor = colorWithHexString(@"333333");
    }
    return YES;
}

#pragma mark - 全屏手势和cell事件冲突

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if ([touch.view isKindOfClass:[UITextView class]] || [touch.view isKindOfClass:[UIButton class]])
    {
        return NO;
    }
    XYLog(@"%@",NSStringFromClass([touch.view.superview class]));
    // 若touch.view为UITableViewCellContentView（即点击了tableViewCell），则不截获Touch事件
    // 若touch.view.superview为FDTopicImageCell（即点击了FDTopicImageCell），则不截获Touch事件 <collectionCell布局的子视图不是contentView就是一个view>
    if ([NSStringFromClass([touch.view.superview class]) isEqualToString:@"FDTopicImageCell"]) {
        return NO;
    }
    return YES;
}

#pragma mark - 定制问答+ & 话题+ UI

- (void)setupCommentViewWith:(NSString *)title SubTitle:(NSString *)subtitle IsTopic:(BOOL)isTopic HandleBlock:(FootHandleBlock)handleBlock
{
    self.footHandleBlock = handleBlock;
    
    _titleLabel.font = [UIFont systemFontOfSize:18];
    _titleLabel.text = title;
    _titleLabel.frame = CGRectMake(70, 5, kSWidth-70*2, 40);
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    submitButton.y = cancelButton.y = _titleLabel.y;
    if (isTopic) {
        self.isFromTopicDetailPage = YES;
        self.photosButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.photosButton setImage:[UIImage imageNamed:@"topic_photoBtn"] forState:UIControlStateNormal];
        [self.photosButton sizeToFit];
        self.photosButton.origin = CGPointMake(textView.x, CGRectGetMaxY(textView.frame)+10);
        [self.photosButton setTouchExtendInset:UIEdgeInsetsMake(-50, -10, -10, -10)];
        __weak __typeof(self)weakSelf = self;
        [self.photosButton addAction:^(UIButton *btn) {
            if (!weakSelf.collectionView.superview)
                [weakSelf pushTZImagePickerController];
        }];
        _backgroundView.height = 10 + 40 + .4f*kSWidth + 10 + self.photosButton.height +10;
        _backgroundView.y = kSHeight - _backgroundView.height;
        [_backgroundView addSubview:self.photosButton];
        
        if (self.myTopic || self.detailModel) {
            self.photosButton.enabled = YES;
            [self configCollectionView];
            _backgroundView.frame = self.view.bounds;
            [submitButton removeFromSuperview];
            [cancelButton removeFromSuperview];
            if (self.myTopic) {
                textView.text = self.myTopic.content;
                if (self.myTopic.pics.count) {
                    _modifyPhotoDics = [NSMutableArray array];
                    __weak __typeof (self)weakSelf = self;
                    for (NSDictionary *dict in self.myTopic.pics) {
                        [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:dict[@"url"]] options:SDWebImageHighPriority progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                            
                        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                            NSDictionary *photoDict = [NSDictionary dictionaryWithObject:image forKey:dict[@"url"]];
                            [_modifyPhotoDics addObject:photoDict];
                            if (_modifyPhotoDics.count == weakSelf.myTopic.pics.count) {
                                [weakSelf.collectionView reloadData];
                            }
                        }];
                    }
                }
            }else {
                textView.text = kTopic_TextView_PlaceHolder;
                textView.textColor = colorWithHexString(@"999999");
                textView.selectedRange = NSMakeRange(0,0);
                //设置文字与边界距离
                textView.textContainerInset = kSWidth == 414 ? UIEdgeInsetsMake(7, 4, 0, 0) : UIEdgeInsetsMake(7, 5, 0, 0);
            }
        }else {
            textView.text = kTopic_TextView_PlaceHolder;
            textView.textColor = colorWithHexString(@"999999");
            textView.selectedRange = NSMakeRange(0,0);
            //设置文字与边界距离
            textView.textContainerInset = kSWidth == 414 ? UIEdgeInsetsMake(7, 4, 0, 0) : UIEdgeInsetsMake(7, 5, 0, 0);
            [cancelButton setTitleColor:colorWithHexString(@"666666") forState:UIControlStateNormal];
            [submitButton setTitleColor:colorWithHexString(@"666666") forState:UIControlStateDisabled];
            [submitButton setTitleColor:[ColumnBarConfig sharedColumnBarConfig].column_all_color forState:UIControlStateNormal];
        }
    }else {
        CGSize subTitleSize = [subtitle sizeWithFont:16 LineSpacing:(kSWidth == 320 ? 3 : 7) maxSize:CGSizeMake(kSWidth-20, CGFLOAT_MAX)];
        if (!_subTitleBgView) {
            _subTitleBgView = [[UIView alloc] init];
            _subTitleBgView.frame = CGRectMake(0, _backgroundView.y-(subTitleSize.height+20), kSWidth, subTitleSize.height+20);
            _subTitleBgView.backgroundColor = [UIColor whiteColor];
            [self.view addSubview:_subTitleBgView];
            
            UILabel *subTitleLabel = [[UILabel alloc] init];
            subTitleLabel.frame = CGRectMake(10, 10, subTitleSize.width, subTitleSize.height);
            subTitleLabel.textColor = [ColumnBarConfig sharedColumnBarConfig].column_all_color;
            subTitleLabel.font = [UIFont systemFontOfSize:16];
            [_subTitleBgView addSubview:subTitleLabel];
            
            subTitleLabel.attributedText = [subtitle stringWithFont:16 LineSpacing:(kSWidth == 320 ? 3 : 7)];
        }
    }
} 

- (void)setupCommentViewWithCollectionView:(UICollectionView *)collectionView
{
    [self.view endEditing:YES];
    
    FDTopicCommentSeparateView *separateView = [[FDTopicCommentSeparateView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.photosButton.frame)+8, kSWidth, 8)];
    [_backgroundView addSubview:separateView];
    
    collectionView.origin = CGPointMake(self.photosButton.x, CGRectGetMaxY(separateView.frame));
    collectionView.backgroundColor = [UIColor clearColor];
    [_backgroundView addSubview:collectionView];
    
    _backgroundView.height = (10 + 40 + .4f*kSWidth + 10) + (self.photosButton.height +8) + separateView.height + collectionView.height;
    _backgroundView.y = kSHeight - _backgroundView.height;
}

// 点击“完成”
- (void)commitMyTopicModify
{
    if (self.myTopic) {
        // 判断是否被改变
        BOOL isModifiedContent = ![textView.text isEqualToString:self.myTopic.content];
        BOOL isModifiedPhotos = !(_selectedPhotos.count == 0 && self.modifyPhotoDics.count == self.myTopic.pics.count);
        if (isModifiedContent || isModifiedPhotos)
            [self submitButtonClicked:nil];
        else
            [self setupAlertController:NSLocalizedString(@"您没有进行任何修改，确认提交吗？",nil)];
    } else {
        // 判断是否参与（从详情栏目过来）
        if ([NSString isNilOrEmpty:textView.text] || [textView.text isEqualToString:kTopic_TextView_PlaceHolder])
            [Global showTip:NSLocalizedString(@"请编辑参与内容",nil)];
        else {
            [self submitButtonClicked:nil];
        }
    }
}

// 点击“返回”
- (void)cancelMyTopicModify
{
    if (self.myTopic) {
        // 判断是否被修改
        BOOL isModifiedContent = ![textView.text isEqualToString:self.myTopic.content];
        BOOL isModifiedPhotos = !(_selectedPhotos.count == 0 && self.modifyPhotoDics.count == self.myTopic.pics.count);
        if (isModifiedContent || isModifiedPhotos)
            [self setupAlertController:NSLocalizedString(@"是否放弃修改的内容？",nil)];
    } else {
        // 判断是否参与（从详情栏目过来）
        if ((![NSString isNilOrEmpty:textView.text] && ![textView.text isEqualToString:kTopic_TextView_PlaceHolder]) || (_selectedPhotos && _selectedPhotos.count > 0))
            [self setupAlertController:NSLocalizedString(@"是否放弃参与的内容？",nil)];
    }
}

- (void)cancelTopicDiscuss
{
    if ((![NSString isNilOrEmpty:textView.text] && ![textView.text isEqualToString:kTopic_TextView_PlaceHolder]) || (_selectedPhotos && _selectedPhotos.count > 0))
        [self setupAlertController:NSLocalizedString(@"是否放弃编辑的内容？",nil)];
    else
        [self cancelCommit];
}

- (void)setupAlertController:(NSString *)alertTitle
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:alertTitle message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"取消",nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"确定",nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        if ([alertTitle isEqualToString:NSLocalizedString(@"是否放弃编辑的内容？",nil)]) {
            [self cancelCommit];
        } else if ([alertTitle isEqualToString:NSLocalizedString(@"是否放弃修改的内容？",nil)]) {
            [self cancelCommit];
            [self.navigationController popViewControllerAnimated:YES];
        } else if ([alertTitle isEqualToString:NSLocalizedString(@"是否放弃参与的内容？",nil)]) {
            [self cancelCommit];
            [self.navigationController popViewControllerAnimated:YES];
        } else if ([alertTitle isEqualToString:NSLocalizedString(@"您没有进行任何修改，确认提交吗？",nil)]) {
            [self submitButtonClicked:nil];
        }
    }]];
    [self presentViewController:alert animated:YES completion:NULL];
}

#pragma mark ======== 选取相片相关

- (void)configCollectionView {
    
    if (!_collectionView) {
        _selectedPhotos = [NSMutableArray array];
        _selectedAssets = [NSMutableArray array];
        
        // 如不需要长按排序效果，将FDTopicViewFlowLayout类改成UICollectionViewFlowLayout即可
        UICollectionViewFlowLayout *layout = nil;
        if (needSortSelectedImagesSwitch)
            layout = [[FDTopicViewFlowLayout alloc] init];
        else
            layout = [[UICollectionViewFlowLayout alloc] init];
        _margin = 10;
        _itemWH = ((self.view.tz_width-10) - 5*_margin) / 4;
        layout.itemSize = CGSizeMake(_itemWH, _itemWH);
        layout.minimumInteritemSpacing = _margin;
        layout.minimumLineSpacing = _margin;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.tz_width, _itemWH+15*2) collectionViewLayout:layout];
        _collectionView.contentInset = UIEdgeInsetsMake(4, 4, 4, 4);
//        _collectionView.alwaysBounceVertical = YES;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;// 滚动scrollview键盘消失
        [_collectionView registerClass:[FDTopicImageCell class] forCellWithReuseIdentifier:@"FDTopicImageCell"];
    }
    [self setupCommentViewWithCollectionView:_collectionView];
}

- (UIImagePickerController *)imagePickerVc {
    if (_imagePickerVc == nil) {
        _imagePickerVc = [[UIImagePickerController alloc] init];
        _imagePickerVc.delegate = self;
        // set appearance / 改变相册选择页的导航栏外观
        _imagePickerVc.navigationBar.barTintColor = self.navigationController.navigationBar.barTintColor;
        _imagePickerVc.navigationBar.tintColor = self.navigationController.navigationBar.tintColor;
        UIBarButtonItem *tzBarItem, *BarItem;
        if (iOS9Later) {
            tzBarItem = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[TZImagePickerController class]]];
            BarItem = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UIImagePickerController class]]];
        } else {
            tzBarItem = [UIBarButtonItem appearanceWhenContainedIn:[TZImagePickerController class], nil];
            BarItem = [UIBarButtonItem appearanceWhenContainedIn:[UIImagePickerController class], nil];
        }
        NSDictionary *titleTextAttributes = [tzBarItem titleTextAttributesForState:UIControlStateNormal];
        [BarItem setTitleTextAttributes:titleTextAttributes forState:UIControlStateNormal];
    }
    return _imagePickerVc;
}

#pragma mark UICollectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if (!self.myTopic)
        return _selectedPhotos.count + 1;
    else {
        return _modifyPhotoDics.count + _selectedPhotos.count + 1;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FDTopicImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FDTopicImageCell" forIndexPath:indexPath];
    cell.videoImageView.hidden = YES;
    if (!self.myTopic) {
        if (indexPath.row == _selectedPhotos.count) {
            cell.imageView.image = [UIImage imageNamed:@"topic_photo_add"];
            cell.deleteBtn.hidden = YES;
            cell.gifLable.hidden = YES;
            cell.backgroundColor = [UIColor clearColor];
        } else {
            cell.imageView.image = _selectedPhotos[indexPath.row];
            cell.asset = _selectedAssets[indexPath.row];
            cell.deleteBtn.hidden = NO;
            cell.backgroundColor = [UIColor whiteColor];
        }
    }else {
        if (indexPath.row == _modifyPhotoDics.count + _selectedPhotos.count) {
            cell.imageView.image = [UIImage imageNamed:@"topic_photo_add"];
            cell.deleteBtn.hidden = YES;
            cell.gifLable.hidden = YES;
            cell.backgroundColor = [UIColor clearColor];
        } else {
            cell.backgroundColor = [UIColor whiteColor];
            // 证明取的是modify图片
            if (indexPath.row < _modifyPhotoDics.count) {
                __block NSMutableDictionary *photoDict = _modifyPhotoDics[indexPath.row];
                NSString *url = photoDict.allKeys[0];
                UIImage *photo = photoDict.allValues[0];
                if ([photo isKindOfClass:[UIImage class]]) {
                    cell.imageView.image = photo;
                }else{
                    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:url] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                        [photoDict setObject:image forKey:url];
                    }];
                }
            }else {
                cell.imageView.image = _selectedPhotos[indexPath.row-_modifyPhotoDics.count];
                cell.asset = _selectedAssets[indexPath.row-_modifyPhotoDics.count];
                cell.deleteBtn.hidden = NO;
            }
            cell.deleteBtn.hidden = NO;
        }
    }
    
    if (!allowPickingGifSwitch) {
        cell.gifLable.hidden = YES;
    }
    cell.deleteBtn.tag = indexPath.row;
    [cell.deleteBtn addTarget:self action:@selector(deleteBtnClik:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.myTopic) {
        if (indexPath.row == _selectedPhotos.count) {
            BOOL showSheet = showSheetSwitch;
            if (showSheet) {
                UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"取消",nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"拍照",nil),NSLocalizedString(@"去相册选择",nil), nil];
                [sheet showInView:self.view];
            } else {
                [self pushTZImagePickerController];
            }
        } else { // preview photos or video / 预览照片或者视频
            id asset = _selectedPhotos[indexPath.row];
            BOOL isVideo = NO;
            if ([asset isKindOfClass:[PHAsset class]]) {
                PHAsset *phAsset = asset;
                isVideo = phAsset.mediaType == PHAssetMediaTypeVideo;
            } else if ([asset isKindOfClass:[ALAsset class]]) {
                ALAsset *alAsset = asset;
                isVideo = [[alAsset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo];
            }
            
            // preview photos / 预览照片
            TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithSelectedAssets:_selectedAssets selectedPhotos:_selectedPhotos index:indexPath.row];
            imagePickerVc.maxImagesCount = maxCountTF;
            imagePickerVc.allowPickingOriginalPhoto = allowPickingOriginalPhotoSwitch;
            imagePickerVc.isSelectOriginalPhoto = _isSelectOriginalPhoto;
            [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
                _selectedPhotos = [NSMutableArray arrayWithArray:photos];
                _selectedAssets = [NSMutableArray arrayWithArray:assets];
                _isSelectOriginalPhoto = isSelectOriginalPhoto;
                [_collectionView reloadData];
                _collectionView.contentSize = CGSizeMake(0, ((_selectedPhotos.count + 2) / 3 ) * (_margin + _itemWH));
            }];
            [self presentViewController:imagePickerVc animated:YES completion:nil];
        }
    }else {
        if (indexPath.row == _modifyPhotoDics.count + _selectedPhotos.count) {
            BOOL showSheet = showSheetSwitch;
            if (showSheet) {
                UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"取消",nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"拍照",nil),NSLocalizedString(@"去相册选择",nil), nil];
                [sheet showInView:self.view];
            } else {
                [self pushTZImagePickerController];
            }
        }//不需预览照片
    }
}

#pragma mark - LxGridViewDataSource

/// 以下三个方法为长按排序相关代码
- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.item < _selectedPhotos.count;
}

- (BOOL)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)sourceIndexPath canMoveToIndexPath:(NSIndexPath *)destinationIndexPath {
    return (sourceIndexPath.item < _selectedPhotos.count && destinationIndexPath.item < _selectedPhotos.count);
}

- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)sourceIndexPath didMoveToIndexPath:(NSIndexPath *)destinationIndexPath {
    UIImage *image = _selectedPhotos[sourceIndexPath.item];
    [_selectedPhotos removeObjectAtIndex:sourceIndexPath.item];
    [_selectedPhotos insertObject:image atIndex:destinationIndexPath.item];
    
    id asset = _selectedAssets[sourceIndexPath.item];
    [_selectedAssets removeObjectAtIndex:sourceIndexPath.item];
    [_selectedAssets insertObject:asset atIndex:destinationIndexPath.item];
    
    [_collectionView reloadData];
}

#pragma mark - TZImagePickerController

- (void)pushTZImagePickerController {
    if (maxCountTF <= 0) {
        return;
    }
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:maxCountTF columnNumber:columnNumberTF delegate:self pushPhotoPickerVc:YES];
#pragma mark - 四类个性化设置，这些参数都可以不传，此时会走默认设置
    imagePickerVc.isSelectOriginalPhoto = _isSelectOriginalPhoto;
    
    if (maxCountTF > 1) {
        // 1.设置目前已经选中的图片数组
        imagePickerVc.selectedAssets = _selectedAssets; // 目前已经选中的图片数组
    }
    imagePickerVc.allowTakePicture = showTakePhotoBtnSwitch; // 在内部显示拍照按钮
    
    // 2. Set the appearance
    // 2. 在这里设置imagePickerVc的外观
    // imagePickerVc.navigationBar.barTintColor = [UIColor greenColor];
    // imagePickerVc.oKButtonTitleColorDisabled = [UIColor lightGrayColor];
    // imagePickerVc.oKButtonTitleColorNormal = [UIColor greenColor];
    // imagePickerVc.navigationBar.translucent = NO;
    
    // 3. Set allow picking video & photo & originalPhoto or not
    // 3. 设置是否可以选择视频/图片/原图
    imagePickerVc.allowPickingVideo = allowPickingVideoSwitch;
    imagePickerVc.allowPickingImage = allowPickingImageSwitch;
    imagePickerVc.allowPickingOriginalPhoto = allowPickingOriginalPhotoSwitch;
    imagePickerVc.allowPickingGif = allowPickingGifSwitch;
    
    // 4. 照片排列按修改时间升序
    imagePickerVc.sortAscendingByModificationDate = sortAscendingSwitch;
    
    // imagePickerVc.minImagesCount = 3;
    // imagePickerVc.alwaysEnableDoneBtn = YES;
    
    // imagePickerVc.minPhotoWidthSelectable = 3000;
    // imagePickerVc.minPhotoHeightSelectable = 2000;
    
    /// 5. Single selection mode, valid when maxImagesCount = 1
    /// 5. 单选模式,maxImagesCount为1时才生效
    imagePickerVc.showSelectBtn = NO;
    imagePickerVc.allowCrop = allowCropSwitch;
    imagePickerVc.needCircleCrop = needCircleCropSwitch;
    imagePickerVc.circleCropRadius = 100;
    imagePickerVc.isStatusBarDefault = NO;
    /*
     [imagePickerVc setCropViewSettingBlock:^(UIView *cropView) {
     cropView.layer.borderColor = [UIColor redColor].CGColor;
     cropView.layer.borderWidth = 2.0;
     }];*/
    
    //imagePickerVc.allowPreview = NO;
#pragma mark - 到这里为止
    
    // You can get the photos by block, the same as by delegate.
    // 你可以通过block或者代理，来得到用户选择的照片.
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        
    }];
    
    [self presentViewController:imagePickerVc animated:YES completion:nil];
}

#pragma mark - UIImagePickerController

- (void)takePhoto {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if ((authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) && iOS7Later) {
        // 无相机权限 做一个友好的提示
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"无法使用相机",nil) message:NSLocalizedString(@"请在iPhone的""设置-隐私-相机""中允许访问相机",nil) delegate:self cancelButtonTitle:NSLocalizedString(@"取消",nil) otherButtonTitles:NSLocalizedString(@"设置",nil), nil];
        [alert show];
    } else if (authStatus == AVAuthorizationStatusNotDetermined) {
        // fix issue 466, 防止用户首次拍照拒绝授权时相机页黑屏
        if (iOS7Later) {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted) {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [self takePhoto];
                    });
                }
            }];
        } else {
            [self takePhoto];
        }
        // 拍照之前还需要检查相册权限
    } else if ([TZImageManager authorizationStatus] == 2) { // 已被拒绝，没有相册权限，将无法保存拍的照片
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"无法访问相册",nil) message:NSLocalizedString(@"请在iPhone的""设置-隐私-相册""中允许访问相册",nil) delegate:self cancelButtonTitle:NSLocalizedString(@"取消",nil) otherButtonTitles:NSLocalizedString(@"设置",nil), nil];
        alert.tag = 1;
        [alert show];
    } else if ([TZImageManager authorizationStatus] == 0) { // 未请求过相册权限
        [[TZImageManager manager] requestAuthorizationWithCompletion:^{
            [self takePhoto];
        }];
    } else {
        [self pushImagePickerController];
    }
}

// 调用相机
- (void)pushImagePickerController {
    // 提前定位
    [[TZLocationManager manager] startLocationWithSuccessBlock:^(CLLocation *location, CLLocation *oldLocation) {
        _location = location;
    } failureBlock:^(NSError *error) {
        _location = nil;
    }];
    
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        self.imagePickerVc.sourceType = sourceType;
        if(iOS8Later) {
            _imagePickerVc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        }
        [self presentViewController:_imagePickerVc animated:YES completion:nil];
    } else {
        XYLog(@"模拟器中无法打开照相机,请在真机中使用");
    }
}

- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    if ([type isEqualToString:@"public.image"]) {
        TZImagePickerController *tzImagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 delegate:self];
        tzImagePickerVc.sortAscendingByModificationDate = sortAscendingSwitch;
        [tzImagePickerVc showProgressHUD];
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        
        // save photo and get asset / 保存图片，获取到asset
        [[TZImageManager manager] savePhotoWithImage:image location:self.location completion:^(NSError *error){
            if (error) {
                [tzImagePickerVc hideProgressHUD];
                XYLog(@"图片保存失败 %@",error);
            } else {
                [[TZImageManager manager] getCameraRollAlbum:NO allowPickingImage:YES completion:^(TZAlbumModel *model) {
                    [[TZImageManager manager] getAssetsFromFetchResult:model.result allowPickingVideo:NO allowPickingImage:YES completion:^(NSArray<TZAssetModel *> *models) {
                        [tzImagePickerVc hideProgressHUD];
                        TZAssetModel *assetModel = [models firstObject];
                        if (tzImagePickerVc.sortAscendingByModificationDate) {
                            assetModel = [models lastObject];
                        }
                        if (allowCropSwitch) { // 允许裁剪,去裁剪
                            TZImagePickerController *imagePicker = [[TZImagePickerController alloc] initCropTypeWithAsset:assetModel.asset photo:image completion:^(UIImage *cropImage, id asset) {
                                [self refreshCollectionViewWithAddedAsset:asset image:cropImage];
                            }];
                            imagePicker.needCircleCrop = needCircleCropSwitch;
                            imagePicker.circleCropRadius = 100;
                            [self presentViewController:imagePicker animated:YES completion:nil];
                        } else {
                            [self refreshCollectionViewWithAddedAsset:assetModel.asset image:image];
                        }
                    }];
                }];
            }
        }];
    }
}

- (void)refreshCollectionViewWithAddedAsset:(id)asset image:(UIImage *)image {
    [_selectedAssets addObject:asset];
    [_selectedPhotos addObject:image];
    [_collectionView reloadData];
    
    if ([asset isKindOfClass:[PHAsset class]]) {
        PHAsset *phAsset = asset;
        NSLog(@"location:%@",phAsset.location);
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    if ([picker isKindOfClass:[UIImagePickerController class]]) {
        [picker dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) { // take photo / 去拍照
        [self takePhoto];
    } else if (buttonIndex == 1) {
        [self pushTZImagePickerController];
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) { // 去设置界面，开启相机访问权限
        if (iOS8Later) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        } else {
            NSURL *privacyUrl;
            if (alertView.tag == 1) {
                privacyUrl = [NSURL URLWithString:@"prefs:root=Privacy&path=PHOTOS"];
            } else {
                privacyUrl = [NSURL URLWithString:@"prefs:root=Privacy&path=CAMERA"];
            }
            if ([[UIApplication sharedApplication] canOpenURL:privacyUrl]) {
                [[UIApplication sharedApplication] openURL:privacyUrl];
            } else {
                UIAlertView * alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"抱歉",nil) message:NSLocalizedString(@"无法跳转到隐私设置页面，请手动前往设置页面，谢谢",nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"确定",nil) otherButtonTitles: nil];
                [alert show];
            }
        }
    }
}

#pragma mark - TZImagePickerControllerDelegate

/// User click cancel button
/// 用户点击了取消
- (void)tz_imagePickerControllerDidCancel:(TZImagePickerController *)picker {
    // NSLog(@"cancel");
}

// The picker should dismiss itself; when it dismissed these handle will be called.
// If isOriginalPhoto is YES, user picked the original photo.
// You can get original photo with asset, by the method [[TZImageManager manager] getOriginalPhotoWithAsset:completion:].
// The UIImage Object in photos default width is 828px, you can set it by photoWidth property.
// 这个照片选择器会自己dismiss，当选择器dismiss的时候，会执行下面的代理方法
// 如果isSelectOriginalPhoto为YES，表明用户选择了原图
// 你可以通过一个asset获得原图，通过这个方法：[[TZImageManager manager] getOriginalPhotoWithAsset:completion:]
// photos数组里的UIImage对象，默认是828像素宽，你可以通过设置photoWidth属性的值来改变它
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto {
    // 设置UI
    if (!_collectionView.superview)
        [self configCollectionView];
    _selectedPhotos = [NSMutableArray arrayWithArray:photos];
    _selectedAssets = [NSMutableArray arrayWithArray:assets];
    _isSelectOriginalPhoto = isSelectOriginalPhoto;
    [_collectionView reloadData];
    // _collectionView.contentSize = CGSizeMake(0, ((_selectedPhotos.count + 2) / 3 ) * (_margin + _itemWH));
    
    // 1.打印图片名字
    [self printAssetsName:assets];
    // 2.图片位置信息
    if (iOS8Later) {
        for (PHAsset *phAsset in assets) {
            NSLog(@"location:%@",phAsset.location);
        }
    }
}

// If user picking a video, this callback will be called.
// If system version > iOS8,asset is kind of PHAsset class, else is ALAsset class.
// 如果用户选择了一个视频，下面的handle会被执行
// 如果系统版本大于iOS8，asset是PHAsset类的对象，否则是ALAsset类的对象
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingVideo:(UIImage *)coverImage sourceAssets:(id)asset {
    _selectedPhotos = [NSMutableArray arrayWithArray:@[coverImage]];
    _selectedAssets = [NSMutableArray arrayWithArray:@[asset]];
    // open this code to send video / 打开这段代码发送视频
    // [[TZImageManager manager] getVideoOutputPathWithAsset:asset completion:^(NSString *outputPath) {
    // NSLog(@"视频导出到本地完成,沙盒路径为:%@",outputPath);
    // Export completed, send video here, send by outputPath or NSData
    // 导出完成，在这里写上传代码，通过路径或者通过NSData上传
    
    // }];
    [_collectionView reloadData];
    // _collectionView.contentSize = CGSizeMake(0, ((_selectedPhotos.count + 2) / 3 ) * (_margin + _itemWH));
}

// If user picking a gif image, this callback will be called.
// 如果用户选择了一个gif图片，下面的handle会被执行
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingGifImage:(UIImage *)animatedImage sourceAssets:(id)asset {
    _selectedPhotos = [NSMutableArray arrayWithArray:@[animatedImage]];
    _selectedAssets = [NSMutableArray arrayWithArray:@[asset]];
    [_collectionView reloadData];
}

// Decide album show or not't
// 决定相册显示与否
- (BOOL)isAlbumCanSelect:(NSString *)albumName result:(id)result {
    /*
     if ([albumName isEqualToString:@"个人收藏"]) {
     return NO;
     }
     if ([albumName isEqualToString:@"视频"]) {
     return NO;
     }*/
    return YES;
}

// Decide asset show or not't
// 决定asset显示与否
- (BOOL)isAssetCanSelect:(id)asset {
    /*
     if (iOS8Later) {
     PHAsset *phAsset = asset;
     switch (phAsset.mediaType) {
     case PHAssetMediaTypeVideo: {
     // 视频时长
     // NSTimeInterval duration = phAsset.duration;
     return NO;
     } break;
     case PHAssetMediaTypeImage: {
     // 图片尺寸
     if (phAsset.pixelWidth > 3000 || phAsset.pixelHeight > 3000) {
     // return NO;
     }
     return YES;
     } break;
     case PHAssetMediaTypeAudio:
     return NO;
     break;
     case PHAssetMediaTypeUnknown:
     return NO;
     break;
     default: break;
     }
     } else {
     ALAsset *alAsset = asset;
     NSString *alAssetType = [[alAsset valueForProperty:ALAssetPropertyType] stringValue];
     if ([alAssetType isEqualToString:ALAssetTypeVideo]) {
     // 视频时长
     // NSTimeInterval duration = [[alAsset valueForProperty:ALAssetPropertyDuration] doubleValue];
     return NO;
     } else if ([alAssetType isEqualToString:ALAssetTypePhoto]) {
     // 图片尺寸
     CGSize imageSize = alAsset.defaultRepresentation.dimensions;
     if (imageSize.width > 3000) {
     // return NO;
     }
     return YES;
     } else if ([alAssetType isEqualToString:ALAssetTypeUnknown]) {
     return NO;
     }
     }*/
    return YES;
}

#pragma mark 删除图片Click Event

- (void)deleteBtnClik:(UIButton *)sender {
    if (!self.myTopic) {
        [_selectedPhotos removeObjectAtIndex:sender.tag];
        [_selectedAssets removeObjectAtIndex:sender.tag];
    }else {
        if (sender.tag < _modifyPhotoDics.count) {
            [_modifyPhotoDics removeObjectAtIndex:sender.tag];
        } else {
            [_selectedPhotos removeObjectAtIndex:sender.tag-_modifyPhotoDics.count];
            [_selectedAssets removeObjectAtIndex:sender.tag-_modifyPhotoDics.count];
        }
    }
    [_collectionView performBatchUpdates:^{
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:sender.tag inSection:0];
        [_collectionView deleteItemsAtIndexPaths:@[indexPath]];
    } completion:^(BOOL finished) {
        [_collectionView reloadData];
    }];
}

#pragma mark - alertController action
// 添加对应的title 这个方法也可以传进一个数组的titles  我只传一个是为了方便实现每个title的对应的响应事件不同的需求不同的方法
- (void)addActionTarget:(UIAlertController *)alertController title:(NSString *)title color:(UIColor *)color style:(UIAlertActionStyle)style action:(void(^)(UIAlertAction *action))actionTarget
{
    UIAlertAction *action = [UIAlertAction actionWithTitle:title style:style handler:^(UIAlertAction *action) {
        actionTarget(action);
    }];
    [action setValue:color forKey:@"_titleTextColor"];
    [alertController addAction:action];
}

- (void)showCamera
{
    UIImagePickerController *controller = [[UIImagePickerController alloc] init];
    controller.delegate = self;
    controller.sourceType = UIImagePickerControllerSourceTypeCamera;
    // 类别方法：获取本视图所在的第一个父控制器
    [self presentViewController:controller animated:YES completion:nil];
    
}

- (void)openPhotoAlbum
{
    UIImagePickerController *controller = [[UIImagePickerController alloc] init];
    controller.delegate = self;
    controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:controller animated:YES completion:nil];
}

/// 打印图片名字
- (void)printAssetsName:(NSArray *)assets {
    NSString *fileName;
    for (id asset in assets) {
        if ([asset isKindOfClass:[PHAsset class]]) {
            PHAsset *phAsset = (PHAsset *)asset;
            fileName = [phAsset valueForKey:@"filename"];
        } else if ([asset isKindOfClass:[ALAsset class]]) {
            ALAsset *alAsset = (ALAsset *)asset;
            fileName = alAsset.defaultRepresentation.filename;;
        }
        //NSLog(@"图片名字:%@",fileName);
    }
}

@end
