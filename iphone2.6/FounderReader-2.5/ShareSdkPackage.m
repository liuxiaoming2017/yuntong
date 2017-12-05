//
//  ShareSdkPackage.m
//  FounderReader-2.5
//
//  Created by lx on 15/8/15.
//
//

#import "ShareSdkPackage.h"
#import "FounderEventRequest.h"
#import "NSString+Helper.h"
#import "FileRequest.h"
#import "shareCustomView.h"

//设备物理大小

#define SYSTEM_VERSION   [[UIDevice currentDevice].systemVersion floatValue]

//屏幕宽度相对iPhone6屏幕宽度的比例
#define KWidth_Scale    1//kSWidth/375.0f

static ShareSdkPackage *__shareSdkPackage = nil;

@implementation ShareSdkPackage
@synthesize newsImageUrl,newsTitle,newsLink,newsAbstract;


//static id _publishContent;//类方法中的全局变量这样用（类型前面加static）

/*
 自定义的分享类，使用的是类方法，其他地方只要 构造分享内容publishContent就行了
 */

/*只需要在分享按钮事件中 构建好分享内容publishContent传过来就好了*/
-(void)shareWithContent
{
    //_publishContent = publishContent;
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    UIView *blackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSWidth, kSHeight)];
    blackView.backgroundColor = [UIColor clearColor];//[UIColor colorWithString:@"000000" Alpha:0.85f];
    blackView.alpha = 0.85;
    
    blackView.tag = 440;
    [appDelegate().window addSubview:blackView];
    
    shareView = [[UIView alloc] initWithFrame:CGRectMake(/*(kScreenWidth-300*KWidth_Scale)/2.0f*/0, /*(kScreenHeight-270*KWidth_Scale)/2.0f*/kSHeight-270*KWidth_Scale, /*300*KWidth_Scale*/kSWidth, 270*KWidth_Scale)];
    shareView.backgroundColor = [UIColor whiteColor];//[UIColor colorWithString:@"f6f6f6"];
    shareView.tag = 441;
    [window addSubview:shareView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, shareView.frame.size.width, 45*KWidth_Scale)];
    titleLabel.text = @"分享到";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont systemFontOfSize:15*KWidth_Scale];
    titleLabel.textColor = [UIColor redColor];// [UIColor colorWithString:@"2a2a2a"];
    titleLabel.backgroundColor = [UIColor clearColor];
    //[shareView addSubview:titleLabel];
    
    NSArray *btnImages = @[@"changeUserIcon", @"changeUserIcon", @"changeUserIcon", @"changeUserIcon", @"changeUserIcon", @"changeUserIcon", @"changeUserIcon", @"changeUserIcon"];
    NSArray *btnTitles = @[@"微信好友", @"微信朋友圈", @"QQ好友", @"QQ空间", @"微信收藏", @"新浪微博", @"豆瓣", @"短信"];
    for (NSInteger i=0; i<8; i++) {
        CGFloat top = 0.0f;
        if (i<4) {
            top = 10*KWidth_Scale;
            
        }else{
            top = 90*KWidth_Scale;
        }
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(10*KWidth_Scale+(i%4)*70*KWidth_Scale, titleLabel.frame.size.height+titleLabel.frame.origin.y+top, 70*KWidth_Scale, 70*KWidth_Scale)];
        [button setImage:[UIImage imageNamed:btnImages[i]] forState:UIControlStateNormal];
        [button setTitle:btnTitles[i] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:11*KWidth_Scale];
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        
        [button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
        [button setContentVerticalAlignment:UIControlContentVerticalAlignmentTop];
        [button setImageEdgeInsets:UIEdgeInsetsMake(0, 15*KWidth_Scale, 30*KWidth_Scale, 15*KWidth_Scale)];
        if (SYSTEM_VERSION >= 8.0f) {
            [button setTitleEdgeInsets:UIEdgeInsetsMake(45*KWidth_Scale, -40*KWidth_Scale, 5*KWidth_Scale, 0)];
        }else{
            [button setTitleEdgeInsets:UIEdgeInsetsMake(45*KWidth_Scale, -90*KWidth_Scale, 5*KWidth_Scale, 0)];
        }
        
        button.tag = 331+i;
        [button addTarget:self action:@selector(shareItemClicked:) forControlEvents:UIControlEventTouchUpInside];

        [shareView addSubview:button];
    }
    
    UIButton *cancleBtn = [[UIButton alloc] initWithFrame:CGRectMake((shareView.frame.size.width-150*KWidth_Scale)/2.0f, shareView.frame.size.height-40*KWidth_Scale-18*KWidth_Scale, 150*KWidth_Scale, 40*KWidth_Scale)];
    cancleBtn.layer.borderWidth = 1;
    cancleBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
    //[cancleBtn setBackgroundImage:[UIImage imageNamed:@"changeUserIcon"] forState:UIControlStateNormal];
    cancleBtn.tag = 339;
    [cancleBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancleBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [cancleBtn addTarget:self action:@selector(shareItemClicked:) forControlEvents:UIControlEventTouchUpInside];
    [shareView addSubview:cancleBtn];
    
    //为了弹窗不那么生硬，这里加了个简单的动画
    shareView.transform = CGAffineTransformMakeScale(1/300.0f, 1/270.0f);
    blackView.alpha = 0;
    [UIView animateWithDuration:0.35f animations:^{
        shareView.transform = CGAffineTransformMakeScale(1, 1);
        blackView.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
}

+ (ShareSdkPackage *)shareSdkPackage
{
    if (__shareSdkPackage == nil) {
        __shareSdkPackage = [[self alloc] init];
    }
    return __shareSdkPackage;
}

- (id)init
{
    self = [super init];
    if (self) {
        _shareViewDelegate = [[ShareViewDelegate alloc]init];
    }
    return self;
}

- (void)dealloc
{
//    DELETE(_shareViewDelegate);
    
//    [super dealloc];
}

- (UIImage *)newsImage
{
    __block UIImage *image = nil;
    if ([NSString isNilOrEmpty:newsImageUrl]) {
        image = [UIImage imageNamed:@"Bitmap-2"];
    }
    else{
        FileRequest *request = [FileRequest fileRequestWithURL:newsImageUrl];
        
        [request setCompletionBlock:^(NSData *data) {
            image = [UIImage imageWithData:data];
        }];
        [request setFailedBlock:^(NSError *error) {}];
        [request startSynchronous];
    }
    return image;
}

- (NSString *)newsTitle
{
    return newsTitle;
}

- (NSString *)newsLink
{
    return newsLink;
}

- (NSString *)newsAbstract
{
    return newsAbstract;
}

- (void)shareSdk
{
    UIImage *newsImage = [self newsImage];
    NSString *content = [NSString stringWithFormat:@"分享:%@",[self newsTitle]];
    //构造分享内容
    id<ISSContent> publishContent = [ShareSDK content:content
                                       defaultContent:@""
                                                image:[ShareSDK jpegImageWithImage:newsImage quality:0.8]
                                                title:[self newsTitle]
                                                  url:[self newsLink]
                                          description:[self newsAbstract]
                                            mediaType:SSPublishContentMediaTypeNews];
    NSString *newContent = [NSString stringWithFormat:@"分享:%@ %@", [self newsTitle], [self newsLink]];///*@"分享:%@ %@ 分享自%@"*/
    //新浪微博
    [publishContent addSinaWeiboUnitWithContent:newContent image:[ShareSDK jpegImageWithImage:newsImage quality:0.8]];
    //腾讯微博
    [publishContent addTencentWeiboUnitWithContent:newContent image:[ShareSDK jpegImageWithImage:newsImage quality:0.8]];
    //邮件
    [publishContent addMailUnitWithSubject:[self newsTitle] content:newContent isHTML:[NSNumber numberWithBool:YES] attachments:INHERIT_VALUE to:nil cc:nil bcc:nil];
    //复制链接
    [publishContent addCopyUnitWithContent:newContent image:nil];
    //短信
    [publishContent addSMSUnitWithContent:newContent];
    //QQ好友
    [publishContent addQQUnitWithType:INHERIT_VALUE content:newContent title:[self newsTitle] url:[self newsLink] image:[ShareSDK jpegImageWithImage:newsImage quality:0.8]];
    
    //创建弹出菜单容器
    id<ISSContainer> container = [ShareSDK container];
    id<ISSAuthOptions> authOptions = [ShareSDK authOptionsWithAutoAuth:YES
                                                         allowCallback:NO
                                                         authViewStyle:2
                                                          viewDelegate:_shareViewDelegate
                                               authManagerViewDelegate:_shareViewDelegate];
    
    id<ISSShareOptions> shareOptions = [ShareSDK simpleShareOptionsWithTitle:@"分享" shareViewDelegate:_shareViewDelegate];
    
    NSArray *shareList = [ShareSDK getShareListWithType:
                          ShareTypeSinaWeibo, ShareTypeTencentWeibo,ShareTypeWeixiSession,ShareTypeWeixiTimeline,ShareTypeMail,ShareTypeQQSpace,ShareTypeQQ,ShareTypeCopy,ShareTypeSMS,nil];
    //需要定制分享视图的显示属性，使用以下接口
    [ShareSDK showShareActionSheet:container
                         shareList:shareList
                           content:publishContent
                     statusBarTips:NO
                       authOptions:authOptions
                      shareOptions:shareOptions
                            result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                if (state == SSPublishContentStateSuccess)
                                {
                                    if(type == ShareTypeCopy){
                                        [Global showTip:@"复制成功"];
                                    }
                                    else{
                                        [Global showTip:@"分享成功"];
                                    }
                                    
                                }
                                else
                                {
                                    if (![NSString isNilOrEmpty:[error errorDescription]]) {
                                        [Global showTip:[error errorDescription]];
                                    }
                                }
                            }];
    
}

- (void)shareSdk1
{
    [self shareWithContent];
    
    return;
}

-(void)shareItemClicked:(UIButton *)sender
{
    NSLog(@"%@",[ShareSDK version]);
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UIView *blackView = [window viewWithTag:440];
    shareView = [window viewWithTag:441];
    
    //为了弹窗不那么生硬，这里加了个简单的动画
    shareView.transform = CGAffineTransformMakeScale(1, 1);
    [UIView animateWithDuration:0.35f animations:^{
        shareView.transform = CGAffineTransformMakeScale(1/300.0f, 1/270.0f);
        blackView.alpha = 0;
    } completion:^(BOOL finished) {
        
        [shareView removeFromSuperview];
        [blackView removeFromSuperview];
    }];
    
    int shareType = 0;
    //id publishContent = _publishContent;
    switch (sender.tag) {
        case 331:
        {
            shareType = ShareTypeWeixiSession;
        }
            break;
            
        case 332:
        {
            shareType = ShareTypeWeixiTimeline;
        }
            break;
            
        case 333:
        {
            shareType = ShareTypeQQ;
        }
            break;
            
        case 334:
        {
            shareType = ShareTypeQQSpace;
        }
            break;
            
        case 335:
        {
            shareType = ShareTypeWeixiFav;
        }
            break;
            
        case 336:
        {
            shareType = ShareTypeSinaWeibo;
        }
            break;
            
        case 337:
        {
            shareType = ShareTypeDouBan;
        }
            break;
            
        case 338:
        {
            shareType = ShareTypeSMS;
        }
            break;
            
        case 339:
        {
            
        }
            break;
            
        default:
            break;
    }
    [self share:shareType];
}

-(void)share:(int)shareType
{
    /*
     调用shareSDK的无UI分享类型，
     链接地址：http://bbs.mob.com/forum.php?mod=viewthread&tid=110&extra=page%3D1%26filter%3Dtypeid%26typeid%3D34
     */
    NSString *content = [NSString stringWithFormat:@"分享:%@",[self newsTitle]];
    
    /*NSString *newContent = [NSString stringWithFormat:@"分享:%@ %@ 分享自%@", [self newsTitle], [self newsLink], appName()];
     
     id<ISSContent> publishContent = [ShareSDK content:newContent
     defaultContent:@""
     image:[ShareSDK jpegImageWithImage:[self newsImage] quality:0.8]
     title:[self newsTitle]
     url:[self newsLink]
     description:[self newsAbstract]
     mediaType:SSPublishContentMediaTypeText];*/
    //构造分享内容
    id<ISSContent> publishContent = [ShareSDK content:content
                        defaultContent:@""
                                 image:[ShareSDK jpegImageWithImage:[self newsImage] quality:0.8]
                                 title:[self newsTitle]
                                   url:[self newsLink]
                           description:[self newsAbstract]
                             mediaType:SSPublishContentMediaTypeNews];
    NSString *newContent = [NSString stringWithFormat:@"分享:%@ %@ 分享自%@", [self newsTitle], [self newsLink], appName()];
    
    //新浪微博
    [publishContent addSinaWeiboUnitWithContent:newContent image:[ShareSDK jpegImageWithImage:[self newsImage] quality:0.8]];
    //腾讯微博
    [publishContent addTencentWeiboUnitWithContent:newContent image:[ShareSDK jpegImageWithImage:[self newsImage] quality:0.8]];
    //邮件
    [publishContent addMailUnitWithSubject:[self newsTitle] content:newContent isHTML:[NSNumber numberWithBool:YES] attachments:INHERIT_VALUE to:nil cc:nil bcc:nil];
    //复制链接
    [publishContent addCopyUnitWithContent:newContent image:nil];
    //短信
    [publishContent addSMSUnitWithContent:newContent];
    //QQ好友
    [publishContent addQQUnitWithType:INHERIT_VALUE content:newContent title:[self newsTitle] url:[self newsLink] image:[ShareSDK jpegImageWithImage:[self newsImage] quality:0.8]];
    
    //创建弹出菜单容器
    id<ISSContainer> container = [ShareSDK container];
    id<ISSAuthOptions> authOptions = [ShareSDK authOptionsWithAutoAuth:YES
                                      allowCallback:NO
                                      authViewStyle:2
                                       viewDelegate:_shareViewDelegate
                            authManagerViewDelegate:_shareViewDelegate];
    
    id<ISSShareOptions> shareOptions = [ShareSDK simpleShareOptionsWithTitle:@"分享" shareViewDelegate:_shareViewDelegate];
    
    [ShareSDK showShareViewWithType:shareType container:container content:publishContent statusBarTips:NO authOptions:authOptions shareOptions:shareOptions result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
        if (state == SSResponseStateSuccess)
        {
            NSLog(NSLocalizedString(@"TEXT_ShARE_SUC", @"分享成功"));
        }
        else if (state == SSResponseStateFail)
        {
            UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"" message:@"未检测到客户端 分享失败" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
            NSLog(NSLocalizedString(@"TEXT_ShARE_FAI", @"分享失败,错误码:%d,错误描述:%@"), [error errorCode], [error errorDescription]);
        }
        else if (state == SSResponseStateCancel)
        {
            //UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"" message:@"取消了" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            //[alert show];
        }
    }];
    /*[ShareSDK shareContent:publishContent
                      type:ShareTypeSinaWeibo
               authOptions:nil
              shareOptions:nil
             statusBarTips:YES
                    result:^(ShareType type, SSResponseState state,
                             id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                        if (state == SSResponseStateSuccess)
                        {
                            NSLog(NSLocalizedString(@"TEXT_ShARE_SUC", @"分享成功"));
                        }
                        else if (state == SSResponseStateFail)
                        {
                            NSLog(NSLocalizedString(@"TEXT_ShARE_FAI", @"分享失败,错误码:%d,错误描述:%@"), [error errorCode], [error errorDescription]);
                        }
                        
                    }];
    */
}

-(void)cancelItemClick:(UIButton *)sender
{
    //[shareView removeFromSuperview];
    shareView.hidden = YES;
}

@end
