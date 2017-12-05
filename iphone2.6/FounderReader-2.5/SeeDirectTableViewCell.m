//
//  SeeDirectTableViewCell.m
//  FounderReader-2.5
//
//  Created by lx on 15/8/15.
//
//
#import "CommentConfig.h"
#import "SeeDirectTableViewCell.h"
#import "NewsListConfig.h"
#import "Global.h"
#import "NSString+Helper.h"
#import "LiveFrame.h"
#import "AppConfig.h"
#import "HttpRequest.h"
#import "attactmentmodel.h"
#import "UIView+Extention.h"
#import "ImageViewCf.h"
#import "FCReader_OpenUDID.h"
#import "UIButton+WebCache.h"
#import "UIImageView+WebCache.h"

#define SCREEN_WIDTH kSWidth
#define KuserAccountLoginId             @"login_userId"
#define SCREEN_HEIGHT self.frame.size.height
#define iOSVersion [[[UIDevice currentDevice] systemVersion] floatValue]

@implementation SeeDirectTableViewCell
{
    
    UIImageView *_middleImage;
    UIView *_topLine;
    UIView *_bottomLine;
    //小三角形
    UIImageView *_taiangle;
    
    //作者的label
    UILabel *authorLabel;
    //简易的文字
    UILabel *summaryLael;

    //发布的时间
    UILabel *pushtime;
    
}
@synthesize userImage,livephotosView,authorLabel,pushtime,taiangle,messageBackView,summaryLael,videoImage,video_url,Frames;

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier indexRow:(NSInteger)indexrow andliveFrame:(LiveFrame *)liveframe
{
    //    _indexrow = indexrow;
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.contentView.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1.0];
        
        _topLine = [[UIView alloc] init];
        _topLine.backgroundColor = [UIColor colorWithRed:221/255.0 green:221/255.0 blue:221/255.0 alpha:1.0];
        [self.contentView addSubview:_topLine];
        
        _middleImage = [[UIImageView alloc] init];
        _middleImage.image = [UIImage imageNamed:@"b_pressed"];
        [self.contentView addSubview:_middleImage];
        
        _bottomLine = [[UIView alloc] init];
        _bottomLine.backgroundColor = [UIColor colorWithRed:221/255.0 green:221/255.0 blue:221/255.0 alpha:1.0];
        [self.contentView addSubview:_bottomLine];
        
        messageBackView = [[UIView alloc] init];
        messageBackView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview: messageBackView];
//        self.messageBackView.layer.cornerRadius = 3;
//        self.messageBackView.clipsToBounds = YES;
        //作者的头像
        userImage = [[ImageViewCf alloc] init];
//        userImage.frame = CGRectMake(8, 12, 25, 25);
//        userImage.layer.masksToBounds = YES;
//        userImage.layer.cornerRadius = 17;
        userImage.image = [UIImage imageNamed:@""];
        [self.messageBackView addSubview:userImage];
        
        //作者的背景 和文
        authorLabel = [[UILabel alloc]init];
        authorLabel.font = [UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleCellSummaryFontSize];
        authorLabel.textColor = [UIColor colorWithRed:0x13/255.0 green:0xAF/255.0 blue:0xFD/255.0 alpha:1];
        [self.messageBackView addSubview:authorLabel];
        
        
        //发布的时间
        pushtime = [[UILabel alloc] initWithFrame:CGRectZero];
        pushtime.font = [UIFont fontWithName:[Global fontName] size:12];
        [self.messageBackView addSubview:pushtime];
        
        //直播的简易介绍的文字
        summaryLael = [[UILabel alloc] init];
        summaryLael.numberOfLines=0;
        summaryLael.font = [UIFont fontWithName:[Global fontName] size:14];
        CommentConfig *config = [CommentConfig sharedCommentConfig];
        summaryLael.textColor = config.contentTextColor;
        summaryLael.font = [UIFont fontWithName:[Global fontName] size:17];
        summaryLael.userInteractionEnabled = YES;
        UILongPressGestureRecognizer * longPressGr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressToCopy:)];
        longPressGr.minimumPressDuration = 1.0;
        [summaryLael addGestureRecognizer:longPressGr];
        [self.messageBackView addSubview:summaryLael];
        
        
        CGFloat taiangleX = CGRectGetMaxX(userImage.frame)+13;
        //三角
        _taiangle = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sanjiao"]];
        _taiangle.frame = CGRectMake(taiangleX, 32.5, 7.5, 7.5);
        [self.contentView addSubview:_taiangle];
        
        // 视频视图
        videoImage = [[ImageViewCf alloc] init];
        videoImage.contentMode = UIViewContentModeScaleAspectFill;
        videoImage.userInteractionEnabled = YES;
        videoImage.layer.masksToBounds = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(liveViedoImageClick:)];
        [videoImage addGestureRecognizer:tap];
        [self.messageBackView addSubview:videoImage];
        _videoIcon = [[UIImageView alloc] initWithFrame:CGRectMake(100*liveProportion, 55*liveProportion, 35*liveProportion, 35*liveProportion)];
        _videoIcon.image = [UIImage imageNamed:@"vedioIcon"];
        [videoImage addSubview:_videoIcon];
        
        //评论的图片
        livephotosView =[[SeeLivePhotosView alloc] init];
        
        [self.messageBackView addSubview:livephotosView];
        
        //两个图片的时候
        leftImageView = [[UIButton alloc] init];
        leftImageView.contentMode = UIViewContentModeScaleAspectFill;//不变形居中显示，会有部分裁剪
        [self.messageBackView addSubview:leftImageView];
        [leftImageView addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        rightImageView = [[UIButton alloc] init];
        rightImageView.contentMode = UIViewContentModeScaleAspectFill;//不变形居中显示，会有部分裁剪
        [self.messageBackView addSubview:rightImageView];
        [rightImageView addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return self;
}

-(void)directUIFrame:(LiveFrame *)liveDiss andReuseidentID:(NSString *)reuseID frames:(NSMutableArray *)frames andIndexpath:(NSIndexPath *)indexPath
{
    Frames = frames;
    _topLine.frame = liveDiss.topLineF;
    _middleImage.frame = liveDiss.middleImageF;
    
     //头像
    [userImage setDefaultImage:[UIImage imageNamed:@"icon-user.png"]];
    userImage.frame = liveDiss.userImageF;
    if (![NSString isNilOrEmpty:liveDiss.topModel.userIcon]) {
        [self.userImage setOriginalUrlString:liveDiss.topModel.userIcon];
    }
    authorLabel.textAlignment = NSTextAlignmentLeft;
    authorLabel.frame = liveDiss.authorLabelF;

    switch (liveDiss.topModel.userType) {
        case 0:
            authorLabel.text = [NSString stringWithFormat:@"[%@] %@",NSLocalizedString(@"嘉宾",nil), liveDiss.topModel.userName];
            break;
        case 1:
            authorLabel.text = [NSString stringWithFormat:@"[%@] %@",NSLocalizedString(@"主持人",nil), liveDiss.topModel.userName];
            break;
        case 2:
            authorLabel.text = [NSString stringWithFormat:@"[%@] %@",NSLocalizedString(@"网友",nil), liveDiss.topModel.userName];
            break;
        default:
            break;
    }
    
    authorLabel.textAlignment = NSTextAlignmentLeft;
    
    //时间
    pushtime.font = [UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleCellSummaryFontSize];
    pushtime.textAlignment = NSTextAlignmentRight;
    pushtime.frame = liveDiss.pushtimeF;
    pushtime.textColor = [UIColor grayColor];
    pushtime.text = liveDiss.topModel.publishTime;
    pushtime.text = intervalSinceNow(pushtime.text);
    
    pushtime.centerY = authorLabel.centerY = userImage.centerY;
    
    //内容
    summaryLael.frame = liveDiss.summaryLaelF;
    summaryLael.lineBreakMode = NSLineBreakByCharWrapping;
    summaryLael.numberOfLines = 0;
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    [paragraphStyle setLineSpacing:4.0f];
    NSDictionary *attribute = @{NSFontAttributeName: [UIFont fontWithName:[Global fontName] size:17],
                                NSParagraphStyleAttributeName:paragraphStyle
                                };
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc]initWithString:liveDiss.topModel.content attributes:attribute];
    summaryLael.attributedText = attStr;
    [summaryLael sizeToFit];
    
    //视频
    if (liveDiss.topModel.videos.count) {
    
        videoImage.frame = liveDiss.videoImageF;
        NSString *videoPic = [liveDiss.topModel.videoPics firstObject];
        if (![NSString isNilOrEmpty:videoPic]) {
            [videoImage sd_setImageWithURL:[NSURL URLWithString:[liveDiss.topModel.videoPics firstObject]] placeholderImage:[Global getBgImage169]];
            video_url = [liveDiss.topModel.videos firstObject];
        }else{
            videoImage.image = [Global getBgImage169];
        }
        NSString *videoUrl = [liveDiss.topModel.videos firstObject];
        if (![NSString isNilOrEmpty:videoUrl]) {
            video_url = videoUrl;
        }
        self.videoIcon.frame = liveDiss.videoIconF;
        
    }else{
        self.videoImage.hidden = YES;
    }
    
    //图片
    if (liveDiss.topModel.pics) {
        
        self.livephotosView.frame = liveDiss.photosImgViewF;
        self.livephotosView.photosViewArr = liveDiss.topModel.pics;
        self.livephotosView.hidden = NO;
        leftImageView.hidden = YES;
        rightImageView.hidden = YES;
        bigImageView.hidden = YES;
        
    }else{
        self.livephotosView.hidden = YES;
    }
    
    //背景
    messageBackView.frame = liveDiss.messageBackViewF;
    
    _bottomLine.frame = CGRectMake(10, CGRectGetMaxY(_middleImage.frame), 1, CGRectGetMaxY(self.messageBackView.frame)-37);
}

- (void)longPressToCopy:(UILongPressGestureRecognizer *)longGesture
{
    [self becomeFirstResponder];
    
    // 获得菜单
    UIMenuController *menu = [UIMenuController sharedMenuController];
    // 设置菜单内容 默认只有拷贝
//    menu.menuItems = @[
//                       [[UIMenuItem alloc] initWithTitle:@"顶" action:@selector(ding:)],
//                       [[UIMenuItem alloc] initWithTitle:@"回复" action:@selector(reply:)],
//                       [[UIMenuItem alloc] initWithTitle:@"举报" action:@selector(warn:)]
//                       ];
    // 菜单最终显示的位置
    CGRect rect = CGRectMake((summaryLael.width-100)/2.0f, 0, 100, 100);
    [menu setTargetRect:rect inView:summaryLael];
    // 显示菜单
    [menu setMenuVisible:YES animated:YES];
}

#pragma mark - UIMenuController相关
/**
 * 让Label具备成为第一响应者的资格
 */
- (BOOL)canBecomeFirstResponder
{
    return YES;
}

/**
 * 通过第一响应者的这个方法告诉UIMenuController可以显示什么内容
 */
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if (action == @selector(copy:) && ![NSString isNilOrEmpty:summaryLael.text]) // 需要有文字才能支持复制
        return YES;
    return NO;
}

#pragma mark - 监听MenuItem的点击事件
/** 复制 */
- (void)copy:(UIMenuController *)menu
{
    // 将label的文字存储到粘贴板
    [UIPasteboard generalPasteboard].string = summaryLael.text;
}

- (void)liveViedoImageClick:(UIGestureRecognizer *)ges
{
    NSURL *url = nil;
    if ([video_url hasPrefix:@"http://"] || [video_url hasPrefix:@"https://"]) {//网络资源
        url = [NSURL URLWithString:video_url];
    }else{//本地资源
        url = [NSURL fileURLWithPath:video_url];
    }
    XYLog(@"%@", url);
    if (self.playerButtonClickedBlock) {
        self.playerButtonClickedBlock(url);
    }
}
- (void)buttonClick:(UIButton *)button
{
    SDPhotoBrowser *browser = [[SDPhotoBrowser alloc] init];
    browser.sourceImagesContainerView = self; // 原图的父控件
    browser.imageCount = 2; // 图片总数
    browser.currentImageIndex = button.tag;
    browser.delegate = self;
    [browser show];
    
}
- (UIImage *)photoBrowser:(SDPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index
{
    return [self.subviews[index] currentImage];
}

// 返回高质量图片的url
- (NSURL *)photoBrowser:(SDPhotoBrowser *)browser highQualityImageURLForIndex:(NSInteger)index
{
    return nil;
}
@end
