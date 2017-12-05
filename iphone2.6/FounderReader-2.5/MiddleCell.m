//
//  MiddleCell.m
//  FounderReader-2.5
//
//  Created by chenfei on 4/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import "UIImageView+WebCache.h"
#import "UIView+Extention.h"
#import "MiddleCell.h"
#import "NewsListConfig.h"
#import "NSString+Helper.h"
#import "DataLib/DataLib.h"
#import "NSDate+TimeAgo.h"
#import "UIView+Extention.h"
#import "ColorStyleConfig.h"
#import "ColumnBarConfig.h"
#import "LocalNotificationManager.h"
#import "UIAlertView+Helper.h"
#import "AppConfig.h"
#import "NSString+TimeStringHandler.h"
#import "UIImage+Extension.h"
#import "NSMutableAttributedString + Extension.h"

#define liveBgViewColor UIColorFromString(@"211,237,246")

@implementation MiddleCell
@synthesize timerSign,commentSign,commentLabel, pointviewBg;
@synthesize point,messageBackView,footSeq,groupViewLine, cellBgView, imageView;

- (void)dealloc
{
    
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //增加新闻列表背景
        self.backgroundColor = [UIColor whiteColor];
        CGRect bgFrame = CGRectMake(8, 10, kSWidth - 16, [NewsListConfig sharedListConfig].middleCellHeight-10);
        
        cellBgView = [[UIImageView alloc] initWithFrame:bgFrame];
        cellBgView.contentMode = UIViewContentModeScaleToFill;
        cellBgView.backgroundColor = [UIColor whiteColor];
        
        if ([reuseIdentifier isEqualToString:@"SearchMiddleCell"]) {
            self.backgroundColor = [UIColor whiteColor];
        }
        [self.contentView addSubview:cellBgView];
        
        self.imgIcon = [[UIImageView alloc] init];
        [self.contentView addSubview:self.imgIcon];
        
        footSeq =[ [UIView alloc]init];
        footSeq.backgroundColor = UIColorFromString(@"221,221,221");
        [self.contentView addSubview:footSeq];
        
        thumbnail = [[FLAnimatedImageView alloc] initWithFrame:[NewsListConfig sharedListConfig].middleCellThumbnailFrame];
        thumbnail.contentMode = UIViewContentModeScaleAspectFit;
        thumbnail.contentMode = UIViewContentModeScaleAspectFill;
        thumbnail.layer.masksToBounds = YES;
        [self.contentView addSubview:thumbnail];        
        
        titleLabel = [[UILabel alloc] initWithFrame:[NewsListConfig sharedListConfig].middleCellTitleLabelFrame];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.font = [UIFont fontWithName:[Global fontName] size:[NewsListConfig sharedListConfig].middleCellTitleFontSize];
        titleLabel.numberOfLines = 2;
        titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        titleLabel.textColor = [NewsListConfig sharedListConfig].middleCellTitleTextColor;
        [self.contentView addSubview:titleLabel];
        
        summaryLabel = [[UILabel alloc] initWithFrame:[NewsListConfig sharedListConfig].middleCellSummaryLabelFrame];
        summaryLabel.backgroundColor = [UIColor clearColor];
        summaryLabel.font = [UIFont fontWithName:[Global fontName] size:[NewsListConfig sharedListConfig].middleCellSummaryFontSize];
        
        summaryLabel.textColor = [NewsListConfig sharedListConfig].middleCellSummaryTextColor;
        summaryLabel.numberOfLines = 0;
        summaryLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.contentView addSubview:summaryLabel];
        
        dateLabel = [[UILabel alloc] initWithFrame:[NewsListConfig sharedListConfig].middleCellDateFrame];
        dateLabel.backgroundColor = [UIColor clearColor];
        dateLabel.font = [UIFont fontWithName:[Global fontName] size:[NewsListConfig sharedListConfig].middleCellDateFontSize];
        
        dateLabel.textColor = [NewsListConfig sharedListConfig].middleCellDateTextColor;
        dateLabel.numberOfLines = 0;
        dateLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.contentView addSubview:dateLabel];
        
        //赋予CGRectZero否则内存泄漏
        statusLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        statusLabel.backgroundColor = [UIColor clearColor];
        statusLabel.numberOfLines = 0;
        statusLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        statusLabel.textColor = [ColumnBarConfig sharedColumnBarConfig].column_all_color;
        statusLabel.textAlignment = 1;
        statusLabel.font = [UIFont fontWithName:[Global fontName] size:[NewsListConfig sharedListConfig].middleCellSummaryFontSize];
        [self.contentView addSubview:statusLabel];
        
        commentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.commentLabel.font = [UIFont fontWithName:[Global fontName] size:[NewsListConfig sharedListConfig].middleCellDateFontSize];
        self.commentLabel.textColor = [NewsListConfig sharedListConfig].middleCellDateTextColor;
        [self.contentView addSubview:self.commentLabel];
        self.signView = [[UIView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.signView];
        
        self.signLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.signLabel.textAlignment = 1;
        self.signLabel.font = [UIFont fontWithName:[Global fontName] size:[NewsListConfig sharedListConfig].middleCellSummaryFontSize-1];
        [self.signView addSubview:self.signLabel];
        
        self.liveDateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.liveDateLabel.textAlignment = 1;
        self.liveDateLabel.textColor = [NewsListConfig sharedListConfig].middleCellDateTextColor;
        self.liveDateLabel.font = [UIFont fontWithName:[Global fontName] size:[NewsListConfig sharedListConfig].middleCellSummaryFontSize-1-0.5];
        self.liveDateLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.liveDateLabel];
        
        //        self.liveRemindBgView = [[UIView alloc] initWithFrame:CGRectZero];
        //        self.liveRemindBgView.backgroundColor = [ColumnBarConfig sharedColumnBarConfig].column_all_color;
        //        self.liveRemindBgView.userInteractionEnabled = YES;
        //        [self.contentView addSubview:self.liveRemindBgView];//直播提醒转移到稿件内部
        
        //        self.liveRemindLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        //        self.liveRemindLabel.textAlignment = 1;
        //        self.liveRemindLabel.font = [UIFont fontWithName:[Global fontName] size:[NewsListConfig sharedListConfig].middleCellSummaryFontSize-1];
        //        self.liveRemindLabel.textColor = [UIColor whiteColor];
        //        [self.liveRemindBgView addSubview:self.liveRemindLabel];
        
        //        self.liveRemindImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_liveremind"]];
        //        [self.liveRemindBgView addSubview:self.liveRemindImageView];
        //        self.liveRemindImageView.hidden = YES;
        
        if ([reuseIdentifier isEqualToString:@"zhiboCell"])
        {
            sanjiao = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sanjiao"]];
            sanjiao.frame = CGRectMake(60, 20, 5, 5*29/13);
            [self.contentView addSubview:sanjiao];
            
            bkView = [[UIView alloc] initWithFrame:CGRectMake(70, 5, 230, 15)];
            bkView.backgroundColor = [UIColor clearColor];
            
            authorLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 5, 100, 15)];
            [bkView addSubview:authorLabel];
            [self.contentView addSubview:bkView];
            
            UIImageView *faceView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"man_photo.png"]];
            faceView.frame = CGRectMake(20, 1, 30, 30);
            faceView.layer.masksToBounds = YES;
            faceView.layer.cornerRadius = 15;
            [self.contentView addSubview:faceView];
            
            messageBackView = [[UIView alloc]initWithFrame:CGRectZero];
            [self.contentView addSubview:messageBackView];
        }
        if ([reuseIdentifier isEqualToString:@"PolicePersonCell"]){
            groupViewLine = [[UIImageView alloc]init];
            groupViewLine.contentMode = UIViewContentModeScaleAspectFit;
            
            groupViewLine.hidden = YES;
            groupViewLine.image = [UIImage imageNamed:@"groupViewLine"];
            [self.contentView addSubview:groupViewLine];
            
        }
    }
    
    return self;
}

- (void)showThumbnail:(BOOL)show
{
    CGRect titleFrame = [NewsListConfig sharedListConfig].middleCellTitleLabelFrame;
    CGRect summaryFrame = [NewsListConfig sharedListConfig].middleCellSummaryLabelFrame;

    if (summaryFrame.size.width == 0) {
        summaryLabel.hidden = YES;
    }
    else
        summaryLabel.hidden = NO;
    if (show) {
        thumbnail.hidden = NO;
        thumbnailbackground.hidden = NO;
        titleLabel.frame = titleFrame;
        summaryLabel.frame = summaryFrame;
    } else {
        thumbnail.hidden = YES;
        thumbnailbackground.hidden = YES;
        if(titleFrame.origin.x > thumbnail.frame.origin.x){
        
            float widthspan = titleFrame.origin.x - thumbnail.frame.origin.x;
            titleLabel.frame = CGRectMake(titleFrame.origin.x - widthspan, titleFrame.origin.y, titleFrame.size.width+widthspan, titleFrame.size.height);
            
            widthspan = summaryFrame.origin.x - thumbnail.frame.origin.x;
            summaryLabel.frame = CGRectMake(summaryFrame.origin.x - widthspan, summaryFrame.origin.y, summaryFrame.size.width+widthspan, summaryFrame.size.height);
        }
        else{
            titleLabel.frame = CGRectMake(titleFrame.origin.x, titleFrame.origin.y, kSWidth-20, titleFrame.size.height);
            summaryLabel.frame = CGRectMake(summaryFrame.origin.x, summaryFrame.origin.y, kSWidth-20, summaryFrame.size.height);
        }
    }
}

- (void)configWithTitle:(NSString *)title summary:(NSString *)summary thumbnailUrl:(NSString *)url columnId:(int)columnId
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    if (kSWidth == 375) {
        paragraphStyle.lineSpacing = 7;
    }else if (kSWidth == 414) {
        paragraphStyle.lineSpacing = 7;
    }else
        paragraphStyle.lineSpacing = 4;
    NSDictionary *attributes = @{
                                 NSFontAttributeName:[UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleCellTitleFontSize],
                                 NSParagraphStyleAttributeName:paragraphStyle
                                 };
    if (!title) {
        title = @"";
    }else{
        title = [title stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    }
    
    NSAttributedString *atrStr = [[NSAttributedString alloc] initWithString:title attributes:attributes];
    titleLabel.attributedText = atrStr;
    
    NSString *summarytemp = @"";
    if ([summary isKindOfClass:[NSString class]] && summary.length > 0){
        
        summarytemp = summary;
    }
    else{
        summarytemp = @"";
    }
    
    if (self.isPDF) {
        summaryLabel.text = summary;
    }
    else{
        if (summarytemp.length > [NewsListConfig sharedListConfig].middleCellSummaryTextCount) {
            summarytemp = [summarytemp substringToIndex:[NewsListConfig sharedListConfig].middleCellSummaryTextCount];
            summarytemp = [summarytemp stringByAppendingString:@""];
        }
        summaryLabel.text = summarytemp;
    }
    
    // 设置frame
    if (([NSString isNilOrEmpty:url] || [url hasPrefix:@"@"]) && ![AppConfig sharedAppConfig].isArticleShowDefaultImage) {
        [self showThumbnail:NO];
    } else {
        [self showThumbnail:YES];
        // 单张图
        if ([url containsString:@".gif"]) {
            NSString *gifStr = [url componentsSeparatedByString:@"@"].firstObject;
            thumbnail.image = [Global getBgImage43];
            [self loadAnimatedImageWithURL:[NSURL URLWithString:gifStr] completion:^(FLAnimatedImage *animatedImage) {
                [thumbnail setAnimatedImage:animatedImage];
            }];
        }else {
            imageView.hidden = YES;
            [thumbnail sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[Global getBgImage43]];
        }
    }
    
    // 是否图片放置在右侧
    if ([AppConfig sharedAppConfig].isRightWithThumbnail) {
        thumbnail.x = kSWidth-thumbnail.width-10;
        titleLabel.x = 10;
    }
}

- (void)configWithTitle:(NSString *)title summary:(NSString *)summary date:(NSString *)date thumbnailUrl:(NSString *)url columnId:(int)columnId{
    
    [self configWithTitle:title summary:summary thumbnailUrl:url columnId:columnId];
}

// GIF
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


-(void)configSpecialCellWithIsArticle:(Article *)article
{

    if ([NSString isNilOrEmpty:article.imageUrlBig] && ([NSString isNilOrEmpty:article.imageUrl] || [article.imageUrl isEqualToString:@"@!md169"]) && ![AppConfig sharedAppConfig].isArticleShowDefaultImage) {
        cellBgView.frame = CGRectMake(0, 0, kSWidth - 20, 235*proportion-(kSWidth-20)*9/16.0-10);
        footSeq.frame = CGRectMake(0, CGRectGetMaxY(cellBgView.frame) - 1, kSWidth, 0.5);
        thumbnail.frame = CGRectZero;
    }else {
        if (article.isBigPic == 1) {//16:9
            cellBgView.frame = CGRectMake(0, 0, kSWidth-20, 235*proportion);
            thumbnail.frame = CGRectMake(10, 10, kSWidth-20, (kSWidth-20)*9/16.0);
            footSeq.frame = CGRectMake(0, 235*proportion-0.5, kSWidth, 0.5);
        }else if(article.isBigPic == 2){//3:1
            cellBgView.frame = CGRectMake(0, 0, kSWidth-20, 166.25*proportion);
            thumbnail.frame = CGRectMake(10, 10, kSWidth-20, (kSWidth-20)*1/3.0);
            footSeq.frame = CGRectMake(0, 166.25*proportion-0.5, kSWidth, 0.5);
        }
    }
    
    [cellBgView addSubview:thumbnail];
    UIImage * placeholderImage = nil;
    if (article.isBigPic ==2) {
        placeholderImage = [Global getBgImage31];
    }else{
        placeholderImage = [Global getBgImage43];
    }
    if (article.imageUrl.length) { //专题
        
        NSString *str = [article.imageUrl componentsSeparatedByString:@"@"].firstObject;
        if ([article.imageUrl containsString:@".gif"]) {
            thumbnail.image = placeholderImage;
            [self loadAnimatedImageWithURL:[NSURL URLWithString:str] completion:^(FLAnimatedImage *animatedImage) {
                [thumbnail setAnimatedImage:animatedImage];
            }];
        }else {
            if (article.isBigPic == 1) {//16:9
               [thumbnail sd_setImageWithURL:[NSURL URLWithString:str] placeholderImage:placeholderImage];
            }else if(article.isBigPic == 2){//3:1
                [thumbnail sd_setImageWithURL:[NSURL URLWithString:str] placeholderImage:placeholderImage];
            }else{
                [thumbnail sd_setImageWithURL:[NSURL URLWithString:[article.imageUrl stringByReplacingOccurrencesOfString:@"sm43" withString:@"md43"]] placeholderImage:placeholderImage];
            }
        }
    }else
    {
        
        [thumbnail sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", article.imageUrlBig]] placeholderImage:placeholderImage];
    }
    CGRect titleFrame = titleLabel.frame;
    titleFrame.origin.y = CGRectGetMaxY(thumbnail.frame) + 10*proportion;
    titleFrame.origin.x = 10;
    titleFrame.size.width = kSWidth - 20;
    titleFrame.size.height = [NewsListConfig sharedListConfig].middleCellTitleFontSize+1;
    titleLabel.frame = titleFrame;
    
    dateLabel.text = @"";
    
    if (article.isRead)
        titleLabel.textColor = [NewsListConfig sharedListConfig].middleCellSummaryTextColor;
    else
        titleLabel.textColor = [UIColor blackColor];
    NSString *summarytemp = @"";
    if ([article.title isKindOfClass:[NSString class]] && article.title.length > 0){
        
        summarytemp = article.title;
    }
    else{
        summarytemp = @"";
    }
    
    if (self.isPDF) {
        titleLabel.text = article.title;
    }
    else{
        if (summarytemp.length > [NewsListConfig sharedListConfig].middleCellSummaryTextCount) {
            summarytemp = [summarytemp substringToIndex:[NewsListConfig sharedListConfig].middleCellSummaryTextCount];
            summarytemp = [summarytemp stringByAppendingString:@"..."];
        }
        titleLabel.text = summarytemp;
    }
    NSString *commentNum =[NSString stringWithFormat:@"%@%@",article.readCount, NSLocalizedString(@"人阅读","")];
    
    NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:[Global fontName] size:[NewsListConfig sharedListConfig].middleCellDateFontSize], NSFontAttributeName,nil];
    CGSize commentSize = [commentNum boundingRectWithSize:CGSizeMake(150, 12) options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading attributes:tdic context:nil].size;
    
    if (article.tag.length && ![article.tag isEqualToString:@"专题"]) {
        
        NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:[Global fontName] size:[NewsListConfig sharedListConfig].middleCellSummaryFontSize], NSFontAttributeName,nil];
        CGSize size = [article.tag boundingRectWithSize:CGSizeMake(100, 12) options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading attributes:tdic context:nil].size;
        CGFloat statusLabelY = 0;
        if (article.isBigPic == 1) {
           statusLabelY = (235-18)*proportion;
        }else if(article.isBigPic == 2){
           statusLabelY = (166.25-18)*proportion;
        }else{
           statusLabelY = (235-18)*proportion;
        }
        statusLabel.frame = CGRectMake(titleLabel.frame.origin.x, statusLabelY ,size.width+10,[NewsListConfig sharedListConfig].middleCellSummaryFontSize + 1);
        statusLabel.text = article.tag;
        //        statusLabel.text = @"laba";
        statusLabel.hidden = NO;
        
        self.commentLabel.frame = CGRectMake(CGRectGetMaxX(statusLabel.frame)+10,statusLabel.frame.origin.y, commentSize.width, [NewsListConfig sharedListConfig].middleCellSummaryFontSize + 1);
        self.commentLabel.text = [NSString stringWithFormat:@"%@%@",article.readCount, NSLocalizedString(@"人阅读",nil)];
        
        if (self.commentLabel.hidden) {
            dateLabel.frame = CGRectMake(CGRectGetMaxX(statusLabel.frame) + 10,statusLabel.frame.origin.y,180,[NewsListConfig sharedListConfig].middleCellDateFontSize + 1);
        }else{
            dateLabel.frame = CGRectMake(CGRectGetMaxX(commentLabel.frame) + 10,commentLabel.frame.origin.y,180,[NewsListConfig sharedListConfig].middleCellDateFontSize + 1);
        }
        dateLabel.text =[self dateToStr:article.publishTime];
        dateLabel.textColor = [UIColor lightGrayColor];
        dateLabel.font = [UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleCellDateFontSize ];
    }
    else{
        statusLabel.hidden = YES;
        self.commentLabel.text = [NSString stringWithFormat:@"%@%@",article.readCount, NSLocalizedString(@"人阅读",nil)];
        self.commentLabel.frame = CGRectMake(titleLabel.frame.origin.x, CGRectGetMaxY(titleLabel.frame)+10, commentSize.width, [NewsListConfig sharedListConfig].middleCellSummaryFontSize);
        if (self.commentLabel.hidden) {
            dateLabel.frame = CGRectMake(titleLabel.frame.origin.x,CGRectGetMaxY(titleLabel.frame)+10,180,[NewsListConfig sharedListConfig].middleCellDateFontSize + 1);
        }else{
            dateLabel.frame = CGRectMake(CGRectGetMaxX(commentLabel.frame) + 10,commentLabel.frame.origin.y,180,[NewsListConfig sharedListConfig].middleCellDateFontSize + 1);
        }
        
        dateLabel.text = [self dateToStr:article.publishTime];
        dateLabel.textColor = [UIColor lightGrayColor];
        dateLabel.font = [UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleCellDateFontSize];
    }
     
    self.signView.hidden = YES;
    self.liveDateLabel.hidden = YES;
    self.liveRemindBgView.hidden = YES;
    [self addSignViewWithArticle:article];
    
}

/* 普通新闻Cell */
-(void)configMiddleCellWithArticle:(Article *)article
{
    
    /* 设置标题、标题图的value和frame */
    thumbnail.image = [Global getBgImage43];
    [self configWithTitle:article.title summary:article.attAbstract thumbnailUrl:article.imageUrl columnId:article.columnId];
    if (article.isRead)
        titleLabel.textColor = summaryLabel.textColor;
    else
        titleLabel.textColor = [UIColor blackColor];
    if (nil!=article.attributetitle)
        titleLabel.attributedText = article.attributetitle;
    
    /* 设置边界线frame */
    footSeq.frame = CGRectMake(0, CGRectGetMaxY(cellBgView.frame) - 1, kSWidth, 0.5);
    
    /* 设置阅读数Label */
    NSString *readStr = article.articleType == ArticleType_LIVESHOW ? NSLocalizedString(@"人参与",nil) : NSLocalizedString(@"人阅读",nil);
    NSString *commentNum = [NSString stringWithFormat:@"%@%@",article.readCount,readStr];
    NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:[Global fontName] size:[NewsListConfig sharedListConfig].middleCellDateFontSize], NSFontAttributeName,nil];
    CGSize commentSize = [commentNum boundingRectWithSize:CGSizeMake(150, 12) options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading attributes:tdic context:nil].size;
    if (article.advID == 0) {
        self.commentLabel.text = [NSString stringWithFormat:@"%@%@",article.readCount,readStr];
    } else {
        self.commentLabel.text = @"";
    }
    if (article.columnId == 13913 && [[AppConfig sharedAppConfig].sid isEqualToString: @"zgshb"]) {
        //中国石油报视频栏目添加视频图标
        self.commentLabel.frame = CGRectMake(titleLabel.frame.origin.x + [NewsListConfig sharedListConfig].middleCellDateFontSize + 10, CGRectGetMaxY(thumbnail.frame)-([NewsListConfig sharedListConfig].middleCellDateFontSize + 1), commentSize.width, [NewsListConfig sharedListConfig].middleCellDateFontSize + 1);
        
        self.imgIcon = [[UIImageView alloc] init];
        [self.contentView addSubview:self.imgIcon];
        self.imgIcon.frame = CGRectMake(titleLabel.frame.origin.x, CGRectGetMinY(self.commentLabel.frame), [NewsListConfig sharedListConfig].middleCellDateFontSize + 1, [NewsListConfig sharedListConfig].middleCellDateFontSize + 1);
        self.imgIcon.image = [UIImage imageNamed:@"icon-video"];
        self.imgIcon.hidden = NO;
    } else {
        self.imgIcon.hidden = YES;
        self.commentLabel.frame = CGRectMake(titleLabel.frame.origin.x, CGRectGetMaxY(thumbnail.frame)-([NewsListConfig sharedListConfig].middleCellDateFontSize + 1), commentSize.width, [NewsListConfig sharedListConfig].middleCellDateFontSize + 1);
    }
    
    /* 发布日期Label */
    if (self.commentLabel.hidden) {
        dateLabel.frame = CGRectMake(titleLabel.frame.origin.x, CGRectGetMaxY(thumbnail.frame)-([NewsListConfig sharedListConfig].middleCellDateFontSize + 1),120,[NewsListConfig sharedListConfig].middleCellDateFontSize + 1);
    }else{
        dateLabel.frame = CGRectMake(CGRectGetMaxX(commentLabel.frame) + 10,commentLabel.frame.origin.y,120,[NewsListConfig sharedListConfig].middleCellDateFontSize + 1);
    }
    dateLabel.text = intervalSinceNow(article.publishTime);
    dateLabel.textColor = [UIColor lightGrayColor];
    dateLabel.font = [UIFont fontWithName:[Global fontName] size:[NewsListConfig sharedListConfig].middleCellDateFontSize ];
    dateLabel.hidden = ![AppConfig sharedAppConfig].isAppearDate;

    /* 音视频标志image、标签Label */
    if (article.articleType == ArticleType_VIDEO || article.audioUrl.length > 0) {
        self.imgIcon.frame = CGRectMake(titleLabel.frame.origin.x, [NewsListConfig sharedListConfig].middleCellHeight - [NewsListConfig sharedListConfig].middleCellDateFontSize + 1 - 10*proportion, [NewsListConfig sharedListConfig].middleCellDateFontSize + 1, [NewsListConfig sharedListConfig].middleCellDateFontSize + 1);
        if(article.audioUrl.length > 0){
            self.imgIcon.image = [UIImage imageNamed:@"hornIcon-3"]; //音频小图
        }
        else{
            self.imgIcon.image = [UIImage imageNamed:@"icon-video"]; //视频小图
        }
        
        self.imgIcon.hidden = NO;
        
        if (article.tag.length) {
            
            CGSize size = [article.tag boundingRectWithSize:CGSizeMake(150, 12) options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading attributes:tdic context:nil].size;
            
            statusLabel.frame = CGRectMake(titleLabel.frame.origin.x+[NewsListConfig sharedListConfig].middleCellDateFontSize + 1+10,CGRectGetMaxY(thumbnail.frame)-([NewsListConfig sharedListConfig].middleCellDateFontSize + 1),size.width+10,[NewsListConfig sharedListConfig].middleCellSummaryFontSize + 1);
            statusLabel.text = article.tag;
            statusLabel.hidden = NO;
            CGSize commentSize = [commentNum boundingRectWithSize:CGSizeMake(150, 12) options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading attributes:tdic context:nil].size;
            self.commentLabel.frame = CGRectMake(statusLabel.frame.origin.x+statusLabel.frame.size.width+10, statusLabel.y, commentSize.width, [NewsListConfig sharedListConfig].middleCellSummaryFontSize + 1);
            if (self.commentLabel.hidden) {
                dateLabel.frame = CGRectMake(statusLabel.frame.origin.x+statusLabel.frame.size.width+10, statusLabel.y,120,[NewsListConfig sharedListConfig].middleCellDateFontSize + 1);
            }else{
                dateLabel.frame = CGRectMake(CGRectGetMaxX(commentLabel.frame) + 10*proportion,self.commentLabel.y,120,[NewsListConfig sharedListConfig].middleCellDateFontSize + 1);
            }
        }
        else{
            statusLabel.hidden = YES;
            self.commentLabel.frame = CGRectMake(titleLabel.frame.origin.x+10+[NewsListConfig sharedListConfig].middleCellDateFontSize + 1,[NewsListConfig sharedListConfig].middleCellHeight - [NewsListConfig sharedListConfig].middleCellDateFontSize + 1 - 10*proportion, commentSize.width, [NewsListConfig sharedListConfig].middleCellDateFontSize + 1);
            if (self.commentLabel.hidden) {
                dateLabel.frame = CGRectMake(titleLabel.frame.origin.x+10+[NewsListConfig sharedListConfig].middleCellDateFontSize + 1,commentLabel.frame.origin.y,120,[NewsListConfig sharedListConfig].middleCellDateFontSize + 1);
            }else{
                dateLabel.frame = CGRectMake(CGRectGetMaxX(commentLabel.frame) +[NewsListConfig sharedListConfig].middleCellDateFontSize + 1,commentLabel.frame.origin.y,120,[NewsListConfig sharedListConfig].middleCellDateFontSize + 1);
            }
            
        }
    }
    else if (article.columnId != 13913 || ![[AppConfig sharedAppConfig].sid isEqualToString: @"zgshb"])
    {
        self.imgIcon.frame = CGRectNull;
        self.imgIcon.hidden = YES;
        
        if (article.tag.length) {
            
            CGSize size = [article.tag boundingRectWithSize:CGSizeMake(150, 12) options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading attributes:tdic context:nil].size;
            statusLabel.frame = CGRectMake(titleLabel.frame.origin.x,CGRectGetMaxY(thumbnail.frame)-([NewsListConfig sharedListConfig].middleCellDateFontSize + 1),size.width+10,[NewsListConfig sharedListConfig].middleCellSummaryFontSize + 1);
            statusLabel.text = article.tag;
            statusLabel.hidden = NO;
            CGSize commentSize = [commentNum boundingRectWithSize:CGSizeMake(150, 12) options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading attributes:tdic context:nil].size;
            
            self.commentLabel.frame = CGRectMake(statusLabel.frame.origin.x+statusLabel.frame.size.width+10, statusLabel.y, commentSize.width, [NewsListConfig sharedListConfig].middleCellSummaryFontSize + 1);
            if (self.commentLabel.hidden) {
                dateLabel.frame = CGRectMake(statusLabel.frame.origin.x+statusLabel.frame.size.width+10, statusLabel.y,120,[NewsListConfig sharedListConfig].middleCellDateFontSize + 1);
            }else{
                dateLabel.frame = CGRectMake(CGRectGetMaxX(commentLabel.frame) + 10*proportion,self.commentLabel.y,120,[NewsListConfig sharedListConfig].middleCellDateFontSize + 1);
            }
            
        }
        else{
            statusLabel.hidden = YES;
        }
    }
    
    /* 直播时间Label、直播状态View、直播提醒View */
    /* 专题标志View */
    if (article.articleType == ArticleType_SPECIAL || article.articleType == ArticleType_LIVESHOW) {
        self.cellType = CellType_Middle;
        [self addSignViewWithArticle:article];
    } else {
        self.signView.hidden = YES;
        self.liveDateLabel.hidden = YES;
    }
}

- (CGFloat)getZSCTextHight:(NSString *)textStr andWidth:(CGFloat)width andTextFontSize:(NSInteger)fontSize
{
    CGSize size = CGSizeZero;
    NSDictionary *attribute = @{NSFontAttributeName: [UIFont fontWithName:[Global fontName] size:fontSize]};
    size = [textStr boundingRectWithSize:CGSizeMake(width, 1000) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
    
    return size.height;
}
- (void)configCellStyle:(Article*)article
{
    if (article.isRead)
        titleLabel.textColor = summaryLabel.textColor;
    else
        titleLabel.textColor = [UIColor blackColor];
    
    if (nil!=article.attributetitle)
        titleLabel.attributedText = article.attributetitle;
    
    if (article.tag.length) {
        NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:[Global fontName] size:10], NSFontAttributeName,nil];
        CGSize size = [article.tag boundingRectWithSize:CGSizeMake(100, 12) options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading attributes:tdic context:nil].size;
        
        statusLabel.frame = CGRectMake(titleLabel.frame.origin.x,60,size.width+4,12);
        if (article.imageUrl == nil || article.imageUrl.length == 0) {
            statusLabel.frame = CGRectMake(13,60,size.width+4,12);
        }
        statusLabel.text = article.tag;
        statusLabel.textAlignment = 1;
        statusLabel.hidden = YES;
    }
    else{
        statusLabel.hidden = NO;
    }
    
    
    self.timerSign.frame = CGRectMake(263,61,10,10);
    self.commentSign.frame = CGRectMake(197-60, 61,15,10);
    self.commentLabel.frame = CGRectMake(220-60, 61, 40, 10);
    self.commentLabel.textAlignment = NSTextAlignmentLeft;
    dateLabel.frame = CGRectMake(268,61,40,10);
    dateLabel.textAlignment = NSTextAlignmentRight;
    
    NSString *dateStr = article.publishTime;
    dateStr = [dateStr stringByReplacingOccurrencesOfString:@"T" withString:@" "];
    dateStr = [dateStr stringByReplacingOccurrencesOfString:@"Z" withString:@""];
    dateLabel.text = intervalSinceNow(dateStr);
    dateLabel.textColor = [UIColor lightGrayColor];
    dateLabel.font = [UIFont fontWithName:[Global fontName] size:9];
    
    //按照阅读数显示
    if (![NSString isNilOrEmpty:article.readCount]/* && ![article.readCount isEqual:@"0"]*/) {
        self.commentLabel.text = [NSString stringWithFormat:@"%@%@",article.readCount, NSLocalizedString(@"人阅读",nil)];
        self.commentLabel.hidden = NO;
        self.commentSign.hidden = NO;
    }
    else{
        self.commentLabel.hidden = YES;
        self.commentSign.hidden = YES;
    }
}

- (CGFloat)contentCellHeightWithText:(NSString*)text Font:(UIFont*)font width:(float)width
{
    NSInteger ch;
    //设置字体
    CGSize size = CGSizeMake(width, 20000.0f);//注：这个宽：300 是你要显示的宽度既固定的宽度，高度可以依照自己的需求而定
    NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName,nil];
    size =[text boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading attributes:tdic context:nil].size;
    
    ch = size.height;
    return ch;
}

-(NSString *)dateToStr:(NSString*)date
{
    if ([NSString isNilOrEmpty:date]) {
        return @"";
    }
    date = [date stringByReplacingOccurrencesOfString:@"T" withString:@" "];
    date = [date stringByReplacingOccurrencesOfString:@"Z" withString:@""];
    if (date.length >16) {
        NSString *subStr1 = [date substringWithRange:NSMakeRange(5, 11)];
        return subStr1;
    }
    return @"";
}

-(void)configSearchMiddleCellWithArticle:(Article *)article
{
    //普通新闻Cell
    footSeq.frame = CGRectMake(0, [NewsListConfig sharedListConfig].middleCellHeight - 1, kSWidth, 0.5);
    
    [self configSearchWithTitle:article.attributetitle publishTime:article.publishTime];
    //[self configCellStyle:article];
    thumbnail.hidden = YES;
}

- (void)configSearchWithTitle:(NSAttributedString *)title publishTime:(NSString *)publishTime
{
    int newLinesToPad = 2;
    titleLabel.frame = CGRectMake(15, 18, kSWidth-30, 40*proportion);
    titleLabel.numberOfLines = 0;
    for (int i=0; i<newLinesToPad; i++) {
        titleLabel.attributedText = title;
    }
    
    dateLabel.frame = CGRectMake(titleLabel.frame.origin.x,[NewsListConfig sharedListConfig].middleCellHeight-23,140,13);
    dateLabel.textAlignment = NSTextAlignmentLeft;
    
    NSString *dateStr = publishTime;
    dateStr = [dateStr stringByReplacingOccurrencesOfString:@"T" withString:@" "];
    dateStr = [dateStr stringByReplacingOccurrencesOfString:@"Z" withString:@""];
    dateLabel.text = intervalSinceNow(dateStr);
    
    dateLabel.textColor = [UIColor lightGrayColor];
    dateLabel.font = [UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleCellDateFontSize];
    dateLabel.hidden = ![AppConfig sharedAppConfig].isAppearDate;
    
}

/**
 *  活动稿件&&投票稿件&&问吧
 *
 *  @param article
 */
- (void)configActivityAndVoteWithArticle:(Article *)article
{
    cellBgView.hidden = YES;
    if (article.isBigPic == 1) {
    CGFloat  height = (IS_IPHONE_4 || IS_IPHONE_5) ? 248.75 : 238.75;
      footSeq.frame = CGRectMake(0, height*proportion-1, kSWidth, 0.5);
      thumbnail.frame = CGRectMake(10, 10, kSWidth-20, (kSWidth-20)*9/16.0f);
        
    }else{
        CGFloat  height = (IS_IPHONE_4 || IS_IPHONE_5) ? 180 : 170;
        footSeq.frame = CGRectMake(0, height*proportion-1, kSWidth, 0.5);
        thumbnail.frame = CGRectMake(10, 10, kSWidth-20, (kSWidth-20)/3.0f);
    }
    if (![NSString isNilOrEmpty:article.imageUrlBig]) {
        
        if ([article.imageUrl containsString:@".gif"]) {
//            imageView.hidden = NO;
//            imageView.frame = thumbnail.bounds;
            thumbnail.image = [Global getBgImage31];
            [self loadAnimatedImageWithURL:[NSURL URLWithString:article.imageUrlBig] completion:^(FLAnimatedImage *animatedImage) {

                [thumbnail setAnimatedImage:animatedImage];
            }];
        }else {
//            imageView.hidden = YES;
            [thumbnail sd_setImageWithURL:[NSURL URLWithString:article.imageUrlBig] placeholderImage:[Global getBgImage31]];
        }
        
    }else {
        if ([AppConfig sharedAppConfig].isArticleShowDefaultImage) {
            [thumbnail sd_setImageWithURL:[NSURL URLWithString:article.imageUrlBig] placeholderImage:[Global getBgImage31]];
        }else {
            thumbnail.frame = CGRectZero;
            if (article.isBigPic==1) {
                CGFloat  height = (IS_IPHONE_4 || IS_IPHONE_5) ? 248.75 : 238.75;
                 footSeq.frame = CGRectMake(0, height*proportion-1-(kSWidth-20)*9/16.0f-10, kSWidth, 0.5);
            }else{
                 CGFloat  height = (IS_IPHONE_4 || IS_IPHONE_5) ? 180 : 170;
                 footSeq.frame = CGRectMake(0, height*proportion-1-(kSWidth-20)/3.0f-10, kSWidth, 0.5);
            }
           
        }
    }
    
    /* 标题 */
    CGFloat titleableY = CGRectGetMaxY(thumbnail.frame)+10*proportion;
    titleLabel.frame = CGRectMake(10, titleableY, kSWidth-20, 25);
    titleLabel.textColor = [UIColor colorWithRed:0x22/255.0 green:0x22/255.0 blue:0x22/255.0 alpha:1];
    titleLabel.font = [UIFont fontWithName:[Global fontName] size:(14/320.0)*kSWidth];
    if (article.isRead) {
        titleLabel.textColor = summaryLabel.textColor;
    }else{
        titleLabel.textColor = [UIColor blackColor];
    }
    NSString *summarytemp = @"";
    if ([article.title isKindOfClass:[NSString class]] && article.title.length > 0){
        
        summarytemp = article.title;
    }
    else{
        summarytemp = @"";
    }
    
    if (summarytemp.length > [NewsListConfig sharedListConfig].middleCellSummaryTextCount) {
        summarytemp = [summarytemp substringToIndex:[NewsListConfig sharedListConfig].middleCellSummaryTextCount];
        summarytemp = [summarytemp stringByAppendingString:@"..."];
    }
    titleLabel.text = summarytemp;
    
    /* 标签 */
    if (article.tag.length) {
        
        NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleCellDateFontSize], NSFontAttributeName,nil];
        CGSize size = [article.tag boundingRectWithSize:CGSizeMake(100, 12) options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading attributes:tdic context:nil].size;
        
        statusLabel.frame = CGRectMake(titleLabel.x,CGRectGetMaxY(titleLabel.frame)+10,size.width+10,12*proportion);
        statusLabel.text = article.tag;
        statusLabel.font = [UIFont fontWithName:[Global fontName] size:[NewsListConfig sharedListConfig].middleCellSummaryFontSize];
        statusLabel.textColor = [ColumnBarConfig sharedColumnBarConfig].column_all_color;
        statusLabel.backgroundColor = [UIColor clearColor];
        statusLabel.textAlignment = 1;
        statusLabel.hidden = NO;
        NSString *commentNum =[NSString stringWithFormat:@"%@%@  ",article.readCount, NSLocalizedString(@"人阅读","")];
        CGSize commentSize = [commentNum boundingRectWithSize:CGSizeMake(150, 12) options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading attributes:tdic context:nil].size;
        
        self.commentLabel.frame = CGRectMake(CGRectGetMaxX(statusLabel.frame)+10,CGRectGetMaxY(titleLabel.frame)+10, commentSize.width, 12*proportion);//220-60+30
    }else{
        statusLabel.hidden = YES;
        
        self.timerSign.frame = CGRectMake(263,105,10,10);
        self.commentSign.frame = CGRectMake(197-60+30, 105,10,10);
        self.commentLabel.font = [UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleCellDateFontSize];
        NSString *commentNum =[NSString stringWithFormat:@"%@%@  ",article.readCount, NSLocalizedString(@"人阅读","")];
        NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleCellDateFontSize], NSFontAttributeName,nil];
        CGSize commentSize = [commentNum boundingRectWithSize:CGSizeMake(100, 12) options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading attributes:tdic context:nil].size;
        self.commentLabel.frame = CGRectMake(titleLabel.x,CGRectGetMaxY(titleLabel.frame)+10, commentSize.width, 12*proportion);//220-60+30
        self.commentLabel.textAlignment = NSTextAlignmentLeft;
    }
    /* 阅读数 */
    if (!self.isAppearReadCount) {
        self.commentLabel.hidden = YES;
        self.commentSign.hidden = YES;
    }else {
        if (self.article.isHideReadCount) {
            // 在全局显示阅读数的情况下，单独隐藏栏目数
            self.commentLabel.hidden = YES;
            self.commentSign.hidden = YES;
        }else {
            if (![NSString isNilOrEmpty:article.readCount]) {
                self.commentLabel.text = [NSString stringWithFormat:@"%@%@",article.readCount, NSLocalizedString(@"人阅读",nil)];
                self.commentLabel.hidden = NO;
                self.commentSign.hidden = NO;
            }
            else{
                self.commentLabel.hidden = YES;
                self.commentSign.hidden = YES;
            }
        }
    }
    
    /* 活动时间/投票时间 */
    dateLabel.hidden = YES;
    
    // 状态
    self.liveRemindBgView.hidden = YES;
    [self addSignViewWithArticle:article];
}

//大图
-(void)configBigimageWithArticle:(Article *)article
{
    if ([NSString isNilOrEmpty:article.imageUrlBig] && ([NSString isNilOrEmpty:article.imageUrl] || [article.imageUrl isEqualToString:@"@!md169"]) && ![AppConfig sharedAppConfig].isArticleShowDefaultImage) {
        thumbnail.frame = CGRectZero;
        footSeq.frame = CGRectMake(0, 238*proportion-(kSWidth-20)*9/16.0-10-0.5, kSWidth, 0.5);
    }else {
        if (article.isBigPic == 1) {//16:9
           thumbnail.frame = CGRectMake(10, 10, kSWidth-20, (kSWidth-20)*9/16.0);
            footSeq.frame = CGRectMake(0, 238*proportion-0.5, kSWidth, 0.5);
        }else if(article.isBigPic == 2){//3:1
            thumbnail.frame = CGRectMake(10, 10, kSWidth-20, (kSWidth-20)*1/3.0);
            footSeq.frame = CGRectMake(0, 169*proportion-0.5, kSWidth, 0.5);
        }
    }
    
    CGFloat titleableY = CGRectGetMaxY(thumbnail.frame)+10*proportion;
    titleLabel.frame = CGRectMake(10, titleableY, kSWidth-20, 25);
    titleLabel.textColor = [UIColor colorWithRed:0x22/255.0 green:0x22/255.0 blue:0x22/255.0 alpha:1];
    titleLabel.font = [UIFont fontWithName:[Global fontName] size:(14/320.0)*kSWidth];
    if (article.isRead)
        titleLabel.textColor = summaryLabel.textColor;
    else
        titleLabel.textColor = [UIColor blackColor];
    
    if (article.imageUrl.length) {
        NSString *str = [article.imageUrl componentsSeparatedByString:@"@"].firstObject;
        UIImage * placeholderImage = nil;
        if (article.isBigPic ==2) {
            placeholderImage = [Global getBgImage31];
        }else{
            placeholderImage = [Global getBgImage43];
        }
        if ([article.imageUrl containsString:@".gif"]) {
            thumbnail.image = placeholderImage;
            [self loadAnimatedImageWithURL:[NSURL URLWithString:str] completion:^(FLAnimatedImage *animatedImage) {

                [thumbnail setAnimatedImage:animatedImage];
            }];
        }else {
            [thumbnail sd_setImageWithURL:[NSURL URLWithString:str] placeholderImage:placeholderImage];
        }

    }else  {
        if (article.isBigPic ==2) {
            thumbnail.image = [Global getBgImage43];
        }else{
          thumbnail.image = [Global getBgImage31];
        }
        
    }
    
    NSString *summarytemp = @"";
    if ([article.title isKindOfClass:[NSString class]] && article.title.length > 0){
        
        summarytemp = article.title;
    }
    else{
        summarytemp = @"";
    }
    
    if (self.isPDF) {
        titleLabel.text = article.title;
    }
    else{
        if (summarytemp.length > [NewsListConfig sharedListConfig].middleCellSummaryTextCount) {
            summarytemp = [summarytemp substringToIndex:[NewsListConfig sharedListConfig].middleCellSummaryTextCount];
            summarytemp = [summarytemp stringByAppendingString:@"..."];
        }
        titleLabel.text = summarytemp;
    }
    NSString *readStr = article.articleType == ArticleType_LIVESHOW ? NSLocalizedString(@"人参与",nil) : NSLocalizedString(@"人阅读",nil);
    NSString *commentNum =[NSString stringWithFormat:@"%@%@",article.readCount,readStr];
    NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleCellDateFontSize], NSFontAttributeName,nil];
    CGSize commentSize = [commentNum boundingRectWithSize:CGSizeMake(150, 12) options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading attributes:tdic context:nil].size;
    
    // 视频
    if (article.articleType == ArticleType_VIDEO)
    {
        if(kSWidth >= 375){
        self.imgIcon.frame = CGRectMake(titleLabel.frame.origin.x, CGRectGetMaxY(titleLabel.frame)+11, [NewsListConfig sharedListConfig].middleCellDateFontSize + 1, [NewsListConfig sharedListConfig].middleCellDateFontSize + 1);
        }
        else{
         self.imgIcon.frame = CGRectMake(titleLabel.frame.origin.x, CGRectGetMaxY(titleLabel.frame)+9, [NewsListConfig sharedListConfig].middleCellDateFontSize + 1, [NewsListConfig sharedListConfig].middleCellDateFontSize + 1);
        }
        self.imgIcon.image = [UIImage imageNamed:@"icon-video"];
        self.imgIcon.hidden = NO;
        // 标签
        if (article.tag.length)
        {
            NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleCellSummaryFontSize], NSFontAttributeName,nil];
            CGSize size = [article.tag boundingRectWithSize:CGSizeMake(100, 12) options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading attributes:tdic context:nil].size;
            
            if (IS_IPHONE_6P||IS_IPHONE_6) {
                statusLabel.frame = CGRectMake(titleLabel.frame.origin.x+[NewsListConfig sharedListConfig].middleCellDateFontSize + 1+10, CGRectGetMaxY(titleLabel.frame) +11,size.width+10,[NewsListConfig sharedListConfig].middleCellSummaryFontSize + 1);
            }else
            {
                statusLabel.frame = CGRectMake(titleLabel.frame.origin.x+[NewsListConfig sharedListConfig].middleCellDateFontSize + 1+10, CGRectGetMaxY(titleLabel.frame) +9,size.width+10,[NewsListConfig sharedListConfig].middleCellSummaryFontSize + 1);
            }
            statusLabel.text = article.tag;
            statusLabel.hidden = NO;
            self.commentLabel.frame = CGRectMake(statusLabel.frame.origin.x+statusLabel.frame.size.width+10,statusLabel.frame.origin.y, commentSize.width+1, [NewsListConfig sharedListConfig].middleCellSummaryFontSize + 1);
            self.commentLabel.text = [NSString stringWithFormat:@"%@%@",article.readCount,readStr];
            if (self.commentLabel.hidden) {
                dateLabel.frame = CGRectMake(statusLabel.frame.origin.x+statusLabel.frame.size.width+10,statusLabel.frame.origin.y,120,[NewsListConfig sharedListConfig].middleCellDateFontSize + 1);
            }else{
                dateLabel.frame = CGRectMake(CGRectGetMaxX(commentLabel.frame) +10,statusLabel.frame.origin.y,120,[NewsListConfig sharedListConfig].middleCellDateFontSize + 1);
            }
            
            NSString *dateStr = article.publishTime;
            dateStr = [dateStr stringByReplacingOccurrencesOfString:@"T" withString:@" "];
            dateStr = [dateStr stringByReplacingOccurrencesOfString:@"Z" withString:@""];
            dateLabel.text = intervalSinceNow(dateStr);
            //        dateLabel.text =[self dateToStr:article.publishTime];
            dateLabel.textColor = [UIColor lightGrayColor];
            dateLabel.font = [UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleCellDateFontSize ];
        }
        else{
            
            self.commentLabel.text = [NSString stringWithFormat:@"%@%@",article.readCount,readStr];
            statusLabel.hidden = YES;
            if (IS_IPHONE_6P||IS_IPHONE_6) {
                NSString *commentNum =[NSString stringWithFormat:@"%@%@",article.readCount,readStr];
                NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleCellDateFontSize], NSFontAttributeName,nil];
                CGSize commentSize = [commentNum boundingRectWithSize:CGSizeMake(150, 12) options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading attributes:tdic context:nil].size;
                
                self.commentLabel.frame = CGRectMake(titleLabel.frame.origin.x+[NewsListConfig sharedListConfig].middleCellDateFontSize + 1+10, CGRectGetMaxY(titleLabel.frame) +11, commentSize.width+1, [NewsListConfig sharedListConfig].middleCellSummaryFontSize);
                if (self.commentLabel.hidden) {
                    dateLabel.frame = CGRectMake(titleLabel.frame.origin.x+[NewsListConfig sharedListConfig].middleCellDateFontSize + 1+10, CGRectGetMaxY(titleLabel.frame) +11,120,[NewsListConfig sharedListConfig].middleCellDateFontSize);
                }else{
                    dateLabel.frame = CGRectMake(CGRectGetMaxX(commentLabel.frame)+10 ,CGRectGetMaxY(titleLabel.frame) +11 ,120,[NewsListConfig sharedListConfig].middleCellDateFontSize);
                }
            }else
            {
                self.commentLabel.frame = CGRectMake(titleLabel.frame.origin.x+[NewsListConfig sharedListConfig].middleCellDateFontSize + 1+10, CGRectGetMaxY(titleLabel.frame) +9, commentSize.width, [NewsListConfig sharedListConfig].middleCellSummaryFontSize);
                if (self.commentLabel.hidden) {
                    dateLabel.frame = CGRectMake(titleLabel.frame.origin.x+[NewsListConfig sharedListConfig].middleCellDateFontSize + 1+10, CGRectGetMaxY(titleLabel.frame) +9,120,[NewsListConfig sharedListConfig].middleCellDateFontSize);
                }else{
                    dateLabel.frame = CGRectMake(CGRectGetMaxX(commentLabel.frame)+10 ,CGRectGetMaxY(titleLabel.frame) +9 ,120,[NewsListConfig sharedListConfig].middleCellDateFontSize);
                }
                
            }
            NSString *dateStr = article.publishTime;
            dateStr = [dateStr stringByReplacingOccurrencesOfString:@"T" withString:@" "];
            dateStr = [dateStr stringByReplacingOccurrencesOfString:@"Z" withString:@""];
            dateLabel.text = intervalSinceNow(dateStr);
            dateLabel.textColor = [UIColor lightGrayColor];
            dateLabel.font = [UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleCellDateFontSize ];
        }
    }
    else//其他
    {
        self.imgIcon.frame = CGRectNull;
        self.imgIcon.hidden = YES;
        // 标签
        if (article.tag.length && article.articleType != ArticleType_LIVESHOW) {
            
            NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleCellSummaryFontSize], NSFontAttributeName,nil];
            CGSize size = [article.tag boundingRectWithSize:CGSizeMake(100, 12) options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading attributes:tdic context:nil].size;
            
            if (IS_IPHONE_6P||IS_IPHONE_6) {
                statusLabel.frame = CGRectMake(titleLabel.frame.origin.x, CGRectGetMaxY(titleLabel.frame) +11,size.width+10,[NewsListConfig sharedListConfig].middleCellSummaryFontSize + 1);
            }else
            {
                statusLabel.frame = CGRectMake(titleLabel.frame.origin.x, CGRectGetMaxY(titleLabel.frame) +9,size.width+10,[NewsListConfig sharedListConfig].middleCellSummaryFontSize + 1);
            }
            statusLabel.text = article.tag;
            statusLabel.hidden = NO;
            self.commentLabel.frame = CGRectMake(statusLabel.frame.origin.x+statusLabel.frame.size.width+10,statusLabel.frame.origin.y, commentSize.width+1, [NewsListConfig sharedListConfig].middleCellSummaryFontSize + 1);
            self.commentLabel.text = [NSString stringWithFormat:@"%@%@",article.readCount,readStr];
            if (self.commentLabel.hidden) {
                dateLabel.frame = CGRectMake(statusLabel.frame.origin.x+statusLabel.frame.size.width+10,statusLabel.frame.origin.y,120,[NewsListConfig sharedListConfig].middleCellDateFontSize + 1);
            }else{
                dateLabel.frame = CGRectMake(CGRectGetMaxX(commentLabel.frame) +10,statusLabel.frame.origin.y,120,[NewsListConfig sharedListConfig].middleCellDateFontSize + 1);
            }
            
            NSString *dateStr = article.publishTime;
            dateStr = [dateStr stringByReplacingOccurrencesOfString:@"T" withString:@" "];
            dateStr = [dateStr stringByReplacingOccurrencesOfString:@"Z" withString:@""];
            dateLabel.text = intervalSinceNow(dateStr);
            //        dateLabel.text =[self dateToStr:article.publishTime];
            dateLabel.textColor = [UIColor lightGrayColor];
            dateLabel.font = [UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleCellDateFontSize ];
        }
        else{
            
            self.commentLabel.text = [NSString stringWithFormat:@"%@%@",article.readCount,readStr];
            statusLabel.hidden = YES;
            if (IS_IPHONE_6P||IS_IPHONE_6) {
                NSString *commentNum =[NSString stringWithFormat:@"%@%@",article.readCount,readStr];
                NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleCellDateFontSize], NSFontAttributeName,nil];
                CGSize commentSize = [commentNum boundingRectWithSize:CGSizeMake(150, 12) options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading attributes:tdic context:nil].size;
                
                self.commentLabel.frame = CGRectMake(titleLabel.frame.origin.x, CGRectGetMaxY(titleLabel.frame) +11, commentSize.width+1, [NewsListConfig sharedListConfig].middleCellSummaryFontSize);
                if (self.commentLabel.hidden) {
                    dateLabel.frame = CGRectMake(titleLabel.frame.origin.x, CGRectGetMaxY(titleLabel.frame) +11,120,[NewsListConfig sharedListConfig].middleCellDateFontSize);
                }else{
                    dateLabel.frame = CGRectMake(CGRectGetMaxX(commentLabel.frame)+10 ,CGRectGetMaxY(titleLabel.frame) +11 ,120,[NewsListConfig sharedListConfig].middleCellDateFontSize);
                }
            }else
            {
                self.commentLabel.frame = CGRectMake(titleLabel.frame.origin.x, CGRectGetMaxY(titleLabel.frame) +9, commentSize.width+1, [NewsListConfig sharedListConfig].middleCellSummaryFontSize);
                if (self.commentLabel.hidden) {
                    dateLabel.frame = CGRectMake(titleLabel.frame.origin.x, CGRectGetMaxY(titleLabel.frame) +9,120,[NewsListConfig sharedListConfig].middleCellDateFontSize);
                }else{
                    dateLabel.frame = CGRectMake(CGRectGetMaxX(commentLabel.frame)+10 ,CGRectGetMaxY(titleLabel.frame) +9 ,120,[NewsListConfig sharedListConfig].middleCellDateFontSize);
                }            }
            NSString *dateStr = article.publishTime;
            dateStr = [dateStr stringByReplacingOccurrencesOfString:@"T" withString:@" "];
            dateStr = [dateStr stringByReplacingOccurrencesOfString:@"Z" withString:@""];
            dateLabel.text = intervalSinceNow(dateStr);
            dateLabel.textColor = [UIColor lightGrayColor];
            dateLabel.font = [UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleCellDateFontSize ];
        }
    }
    self.signView.hidden = YES;
    self.liveDateLabel.hidden = YES;
    self.liveRemindBgView.hidden = YES;
    if (article.articleType == ArticleType_LIVESHOW) {
        dateLabel.hidden = YES;
        [self addSignViewWithArticle:article];
        if (kSWidth == 320) {
            self.signView.y -= 3;
        }
    } else
        dateLabel.hidden = ![AppConfig sharedAppConfig].isAppearDate;
    
    summaryLabel.hidden = YES;
    
    if([[AppConfig sharedAppConfig].sid compare:@"xjdcb"] == NSOrderedSame){
        titleLabel.frame = CGRectMake(titleLabel.frame.origin.x, 10, titleLabel.frame.size.width, titleLabel.frame.size.height);
        thumbnail.frame = CGRectMake(thumbnail.frame.origin.x, 44, thumbnail.frame.size.width, thumbnail.frame.size.height);
    }
}

/**
 互动+
 */
- (void)configQuestionsAndAnswersWithArticle:(Article *)article {
    for (UIView *view in self.contentView.subviews) {
        [view removeFromSuperview];
    }
    CGFloat placeholderHeight = 6;
    CGFloat avaterHeight = 60;
    self.backgroundColor = [UIColor whiteColor];
    UIView *placeholderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSWidth, placeholderHeight)];
    placeholderView.backgroundColor = [UIColor colorWithRed:237/255.f green:237/255.f blue:237/255.f alpha:1];
    [self.contentView addSubview:placeholderView];
    
    UIImageView *mainImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, placeholderHeight + 10 + avaterHeight/2.f, kSWidth, kSWidth / 3.f)];
    [mainImageView sd_setImageWithURL:[NSURL URLWithString:article.imgUrl] placeholderImage:[Global getBgImage31]];
     [self.contentView addSubview:mainImageView];
    
    UIView *avaterBackground = [[UIView alloc] initWithFrame:CGRectMake(10, placeholderHeight + 10, avaterHeight, avaterHeight)];
    avaterBackground.backgroundColor = [UIColor whiteColor];
    avaterBackground.layer.masksToBounds = YES;
    avaterBackground.layer.cornerRadius = avaterHeight /2.f;
    UIImageView *avaterView = [[UIImageView alloc] initWithFrame:CGRectMake(1.5, 1.5, avaterHeight-3, avaterHeight-3)];
    [avaterView sd_setImageWithURL:[NSURL URLWithString:article.authorFace] placeholderImage:[Global getBgImage11]];
    avaterView.layer.masksToBounds = YES;
    avaterView.layer.cornerRadius = (avaterHeight-3) /2.f;
    [self.contentView addSubview:avaterBackground];
    [avaterBackground addSubview:avaterView];
    
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10+avaterHeight+10, 25, 0, 15)];
    if (article.isRead) {
        nameLabel.textColor = [NewsListConfig sharedListConfig].middleCellSummaryTextColor;
    } else {
        nameLabel.textColor = colorWithHexString(@"333333");
    }
    nameLabel.font = [UIFont systemFontOfSize:15];
    nameLabel.text = article.authorName;
    [nameLabel sizeToFit];
    if (nameLabel.width > kSWidth/5*2) {
        nameLabel.width = kSWidth/5*2;
    }
    [self.contentView addSubview:nameLabel];
    
    UILabel *positionLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(nameLabel.frame)+10, 28, 0, 12)];
    if (article.isRead) {
        positionLabel.textColor = [NewsListConfig sharedListConfig].middleCellSummaryTextColor;
    } else {
        positionLabel.textColor = colorWithHexString(@"666666");
    }
    positionLabel.font = [UIFont systemFontOfSize:12];
    positionLabel.text = article.authorTitle;
    positionLabel.width = kSWidth - 10 - positionLabel.x;
    [self.contentView addSubview:positionLabel];
    
    UILabel *tagLabel = [[UILabel alloc] initWithFrame:CGRectMake(kSWidth - 10 - 38-3, CGRectGetMaxY(mainImageView.frame) - 4 - 16-2, 38+3, 16+2)];
    tagLabel.textColor = [UIColor whiteColor];
    tagLabel.font = [UIFont systemFontOfSize:11];
    tagLabel.textAlignment = NSTextAlignmentCenter;
    tagLabel.clipsToBounds = YES;
    tagLabel.layer.cornerRadius = 2;
    tagLabel.textColor = [UIColor whiteColor];
    [self.contentView addSubview:tagLabel];
    
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 30, 0, 10)];
    timeLabel.textColor = colorWithHexString(@"999999");
    timeLabel.font = [UIFont systemFontOfSize:12];
    if ([article.beginTime isLaterThanNowWithDateFormat:TimeToSeconds]) {
        NSString *string = NSLocalizedString(@"开始", nil);
        timeLabel.text = [NSString stringWithFormat:@"%@ %@", [article.beginTime timeStringForQAndA], string];
        tagLabel.text = NSLocalizedString(@"未开始", nil);
        tagLabel.backgroundColor = [colorWithHexString(@"a292f5") colorWithAlphaComponent:.8];
    } else if ([article.endTime isLaterThanNowWithDateFormat:TimeToSeconds]) {
        NSString *string = NSLocalizedString(@"结束", nil);
        timeLabel.text = [NSString stringWithFormat:@"%@ %@", [article.endTime timeStringForQAndA], string];
        tagLabel.text = NSLocalizedString(@"进行中", nil);
        tagLabel.backgroundColor = [colorWithHexString(@"00d1bc") colorWithAlphaComponent:.8];
    } else {
        timeLabel.text = @"";
        tagLabel.text = NSLocalizedString(@"已结束", nil);
        tagLabel.backgroundColor = [colorWithHexString(@"666666") colorWithAlphaComponent:.8];
    }
    [timeLabel sizeToFit];
    [timeLabel setX:kSWidth - 10 - CGRectGetWidth(timeLabel.frame)];
    //[self.contentView addSubview:timeLabel];
    
    
    UILabel *descLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(mainImageView.frame) + 10, kSWidth - 20, 50)];
    if (article.isRead) {
        descLabel.textColor = [NewsListConfig sharedListConfig].middleCellSummaryTextColor;
    } else {
        descLabel.textColor = colorWithHexString(@"333333");
    }
    descLabel.numberOfLines = 0;
    CGFloat lineSpacing;
    if (kSWidth == 375 ||kSWidth == 414) {
        lineSpacing = 7;
    }else
    lineSpacing = 4;

    NSMutableAttributedString *string = [NSMutableAttributedString attributedStringWithString:article.title Font:[UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleCellTitleFontSize] lineSpacing:lineSpacing];
    descLabel.height = [string boundingHeightWithSize:CGSizeMake(kSWidth-20, 0) font:[UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleCellTitleFontSize] lineSpacing:lineSpacing maxLines:2];
    descLabel.attributedText = string;
    [self.contentView addSubview:descLabel];
    
    UILabel *typeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(descLabel.frame) + 10, 0, 12)];
    typeLabel.textColor = colorWithHexString(@"13b7f6");
    typeLabel.font = [UIFont systemFontOfSize:12];
    if ([article.tag isKindOfClass:[NSString class]]) {
        typeLabel.text = article.tag;
        [typeLabel sizeToFit];
    }
    [self.contentView addSubview:typeLabel];
    
    UILabel *followLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(typeLabel.frame)+10, CGRectGetMinY(typeLabel.frame), 0, 12)];
    if (!typeLabel.text.length) {
        followLabel.x = 10;
    }
    followLabel.textColor = colorWithHexString(@"999999");
    followLabel.font = [UIFont systemFontOfSize:12];
    NSString *followString = NSLocalizedString(@"人关注", nil);
    followLabel.text = [NSString stringWithFormat:@"%lld%@", article.interestCount.longLongValue, followString];
    [followLabel sizeToFit];
    [self.contentView addSubview:followLabel];

    UILabel *askLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(followLabel.frame)+10, CGRectGetMinY(typeLabel.frame), 0, 12)];
    askLabel.textColor = colorWithHexString(@"999999");
    askLabel.font = [UIFont systemFontOfSize:12];
    NSString *askString = NSLocalizedString(@"个提问", nil);
    askLabel.text = [NSString stringWithFormat:@"%lld%@", article.askCount.longLongValue, askString];
    [askLabel sizeToFit];
    [self.contentView addSubview:askLabel];
    
    _relationButton = [[UIButton alloc] initWithFrame:CGRectMake(kSWidth - 63, 0, 53, 20)];
    _relationButton.layer.cornerRadius = 3;
    _relationButton.layer.borderWidth = 1;
    if (article.isFollow && [Global userId].length) {
        _relationButton.layer.borderColor = colorWithHexString(@"13b7f6").CGColor;
        [_relationButton setTitle:NSLocalizedString(@"已关注", nil) forState:UIControlStateNormal];
        [_relationButton setTitleColor:colorWithHexString(@"13b7f6") forState:UIControlStateNormal];
        _relationButton.titleLabel.font = [UIFont systemFontOfSize:12];
    } else {
        _relationButton.layer.borderColor = colorWithHexString(@"13b7f6").CGColor;
        [_relationButton setTitle:NSLocalizedString(@"关注", nil) forState:UIControlStateNormal];
        [_relationButton setTitleColor:colorWithHexString(@"13b7f6") forState:UIControlStateNormal];
        _relationButton.titleLabel.font = [UIFont systemFontOfSize:12];
    }
    _relationButton.centerY = askLabel.centerY;
    [self.contentView addSubview:_relationButton];
    
}

- (void)addSignViewWithArticle:(Article *)article {

    if (article.articleType == ArticleType_LIVESHOW
        || (![NSString isNilOrEmpty:article.activityStartTime] && ![NSString isNilOrEmpty:article.activityEndTime])
        || (![NSString isNilOrEmpty:article.voteStartTime] && ![NSString isNilOrEmpty:article.voteEndTime])
        || (![NSString isNilOrEmpty:article.askStartTime] && ![NSString isNilOrEmpty:article.askEndTime])) {
        
        // 设置直播标记
        [self setupLiveSign:article];
        
        // 设置直播提醒
        [self setupLiveRemind];
    }else{
        // 设置专题标记
        [self setupSpecialSign];
    }
    CGSize signLabelSize = [self.signLabel sizeThatFits:CGSizeMake(100, 100)];
    CGSize liveDateLabelSize = [self.liveDateLabel sizeThatFits:CGSizeMake(1000, 100)];
    
    if (self.cellType == CellType_Middle && [AppConfig sharedAppConfig].isRightWithThumbnail && !thumbnail.hidden)
        self.signView.frame = CGRectMake(kSWidth-10-thumbnail.width-10-(signLabelSize.width+4),0, signLabelSize.width+8,signLabelSize.height+4);
    else
        self.signView.frame = CGRectMake(kSWidth-10-(signLabelSize.width+4),0, signLabelSize.width+8,signLabelSize.height+4);
    
    self.signView.centerY = commentLabel.centerY;
    self.signView.clipsToBounds = YES;
    self.signView.layer.cornerRadius = 2;
    self.signLabel.frame = CGRectMake(4,2, signLabelSize.width,signLabelSize.height);
    self.liveDateLabel.frame = CGRectMake(self.signView.x - 5 - liveDateLabelSize.width, self.commentLabel.y, liveDateLabelSize.width, liveDateLabelSize.height);
}

- (void)setupSpecialSign
{
    // 专题有发布时间、无直播时间
    dateLabel.hidden = ![AppConfig sharedAppConfig].isAppearDate;

    self.signView.hidden = NO;
    self.liveDateLabel.hidden = YES;
    
    self.signLabel.text = NSLocalizedString(@"专题", nil);
    self.signLabel.textColor = [ColumnBarConfig sharedColumnBarConfig].column_all_color;
    self.signView.backgroundColor = liveBgViewColor;
}

- (void)setupLiveRemind
{
    self.liveRemindBgView.frame = CGRectMake(thumbnail.width - 71.5 + 10, thumbnail.height - 20 + 10, 71.5, 20);
    self.liveRemindLabel.frame = CGRectMake(16.5, 2, 52, 16);
    self.liveRemindImageView.x = 3;
    self.liveRemindImageView.y = (self.liveRemindBgView.height - self.liveRemindImageView.height)/2;
    self.liveRemindImageView.hidden = NO;
    UITapGestureRecognizer *liveRemindTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openOrNotLiveRemindClick)];
    [self.liveRemindBgView addGestureRecognizer:liveRemindTap];
}

- (void)setupLiveSign:(Article *)article
{
    // 专题无发布时间、有直播时间
    dateLabel.hidden = YES;//不然会和直播时间重合
    self.signView.hidden = NO;
    self.liveDateLabel.hidden = NO;
    
    NSString *startDateTimeStr = nil;
    NSString *endDateTimeStr = nil;
    if (article.articleType == ArticleType_LIVESHOW) {
        if ([NSString isNilOrEmpty:article.liveStartTime]
            || [NSString isNilOrEmpty:article.liveEndTime] || [article.liveEndTime isEqualToString:@"(null)"] || [article.liveStartTime isEqualToString:@"(null)"]) {
            self.liveDateLabel.hidden = YES;
            self.signLabel.text = NSLocalizedString(@"直播", nil);
            self.signLabel.textColor = [ColumnBarConfig sharedColumnBarConfig].column_all_color;
            self.signView.backgroundColor = liveBgViewColor;
            return;
        }else{
            startDateTimeStr = article.liveStartTime;
            endDateTimeStr = article.liveEndTime;
        }
    }else if (![NSString isNilOrEmpty:article.activityStartTime]
              && ![NSString isNilOrEmpty:article.activityEndTime]) {
        startDateTimeStr = article.activityStartTime;
        endDateTimeStr = article.activityEndTime;
    }else if (![NSString isNilOrEmpty:article.voteStartTime]
              &&! [NSString isNilOrEmpty:article.voteEndTime]) {
        startDateTimeStr = article.voteStartTime;
        endDateTimeStr = article.voteEndTime;
    }else if (![NSString isNilOrEmpty:article.askStartTime]
              &&! [NSString isNilOrEmpty:article.askEndTime]) {
        startDateTimeStr = article.askStartTime;
        endDateTimeStr = article.askEndTime;
    }
    
    NSString *articleStartDate = [startDateTimeStr componentsSeparatedByString:@" "][0];
    NSString *articleStartTime = [startDateTimeStr componentsSeparatedByString:@" "][1];
    NSString *articleEndDate = [endDateTimeStr componentsSeparatedByString:@" "][0];
    NSString *articleEndTime = [endDateTimeStr componentsSeparatedByString:@" "][1];
    if (articleStartDate.length == 10 ) {
        articleStartDate = [articleStartDate substringWithRange:NSMakeRange(2, 8)];
    }
    if (articleEndDate.length == 10 ) {
        articleEndDate = [articleEndDate substringWithRange:NSMakeRange(2, 8)];
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSDate *endDateTime = [formatter dateFromString:endDateTimeStr];
    // 筛出已结束的稿件
    if ([endDateTime timeIntervalSinceNow] < 0) {
        self.liveDateLabel.hidden = YES;
        if (article.articleType == ArticleType_LIVESHOW){
            self.signLabel.text = NSLocalizedString(@"直播回顾", nil);
        }else if(![NSString isNilOrEmpty:article.activityStartTime]
                 && ![NSString isNilOrEmpty:article.activityEndTime]){
            self.signLabel.text = NSLocalizedString(@"活动回顾", nil);
        }else if (![NSString isNilOrEmpty:article.voteStartTime]
                  && ![NSString isNilOrEmpty:article.voteEndTime]){
            self.signLabel.text = NSLocalizedString(@"投票结束", nil);
        }
        else if (![NSString isNilOrEmpty:article.askStartTime]
                 && ![NSString isNilOrEmpty:article.askEndTime]){
            self.signLabel.text = NSLocalizedString(@"提问结束", nil);
        }
        self.signLabel.textColor = [UIColor whiteColor];//[NewsListConfig sharedListConfig].middleCellDateTextColor;
        self.signView.backgroundColor = colorWithHexString(@"c9c9c9");
        
    }else {
        switch ([Global judgeDate:startDateTimeStr]) {
                
            case DayType_TodayOnTime:
            {//正在直播
                self.liveDateLabel.hidden = NO;
                if (article.articleType == ArticleType_LIVESHOW){
                    self.signLabel.text = NSLocalizedString(@"正在直播", nil);
                }
                else if (![NSString isNilOrEmpty:article.askStartTime]
                          && ![NSString isNilOrEmpty:article.askEndTime]){
                    self.signLabel.text = NSLocalizedString(@"正在提问", nil);
                }
                else if(![NSString isNilOrEmpty:article.activityStartTime]
                         && ![NSString isNilOrEmpty:article.activityEndTime]){
                    self.signLabel.text = NSLocalizedString(@"正在进行", nil);
                }else if (![NSString isNilOrEmpty:article.voteStartTime]
                          && ![NSString isNilOrEmpty:article.voteEndTime]){
                    self.signLabel.text = NSLocalizedString(@"正在进行", nil);
                }
                
                self.signLabel.textColor = [UIColor whiteColor];
                self.signView.backgroundColor = colorWithHexString(@"00d1bc");
                self.liveDateLabel.text = [NSString stringWithFormat:@"%@%@%@", NSLocalizedString(@"今天", nil), articleStartTime, NSLocalizedString(@"开始", nil)];
                switch ([Global judgeDate:endDateTimeStr]) {
                        
                    case DayType_TodayNextTime:
                        self.liveDateLabel.text = [NSString stringWithFormat:@"%@%@%@", NSLocalizedString(@"今天", nil), articleEndTime, NSLocalizedString(@"结束", nil)];
                        break;
                    case DayType_Tomorrow:
                        self.liveDateLabel.text = [NSString stringWithFormat:@"%@%@%@", NSLocalizedString(@"明天", nil), articleEndTime, NSLocalizedString(@"结束", nil)];
                        break;
                    case DayType_AfterTomorrow:
                        self.liveDateLabel.text = [NSString stringWithFormat:@"%@%@%@", NSLocalizedString(@"后天", nil), articleEndTime, NSLocalizedString(@"结束", nil)];
                        break;
                    case DayType_Future:
                        self.liveDateLabel.text = [NSString stringWithFormat:@"%@%@",articleEndDate, NSLocalizedString(@"结束", nil)];
                        break;
                    default:
                        break;
                }
            }
                break;
            case DayType_TodayNextTime:
            {//今天将要直播
                [self showLiveSignAndDateWithArticle:article andLiveDateLabelText:[NSString stringWithFormat:@"%@%@%@", NSLocalizedString(@"今天", nil), articleStartTime, NSLocalizedString(@"开始", nil)]];
            }
                break;
                
            case DayType_Tomorrow:
            {//明天
                [self showLiveSignAndDateWithArticle:article andLiveDateLabelText:[NSString stringWithFormat:@"%@%@%@", NSLocalizedString(@"明天", nil), articleStartTime, NSLocalizedString(@"开始", nil)]];
            }
                break;
            case DayType_AfterTomorrow:
                self.liveDateLabel.text = [NSString stringWithFormat:@"%@%@%@", NSLocalizedString(@"后天", nil), articleStartTime, NSLocalizedString(@"开始", nil)];
                break;
            case DayType_Future:
            {//未来
                [self showLiveSignAndDateWithArticle:article andLiveDateLabelText:[NSString stringWithFormat:@"%@%@", articleStartDate, NSLocalizedString(@"开始", nil)]];
            }
                break;
            default:
                break;
        }
    }
}

- (void)showLiveSignAndDateWithArticle:(Article *)article  andLiveDateLabelText:(NSString *)liveDateLabelText
{
    self.liveRemindBgView.hidden = article.articleType == ArticleType_LIVESHOW ? NO : YES;
    NSString *notiKey = [NSString stringWithFormat:@"%@%d", kLiveRemindNotificationKey, article.fileId];
    self.liveRemindLabel.text = [LocalNotificationManager checkLocalNotificationWithKey:notiKey] ? NSLocalizedString(@"提醒已开", nil) : NSLocalizedString(@"添加提醒", nil);
    self.liveDateLabel.hidden = NO;
    if (self.articeType == ArticleType_LIVESHOW) {
        self.signLabel.text = NSLocalizedString(@"即将直播", nil);
    }else {
        self.signLabel.text = NSLocalizedString(@"即将开始", nil);
    }
    
    self.signLabel.textColor = [UIColor whiteColor];
    self.signView.backgroundColor = colorWithHexString(@"a292f5");
    self.liveDateLabel.text = liveDateLabelText;
}

/**
 *  开启或关闭直播提醒
 */
- (void)openOrNotLiveRemindClick
{
    NSString *notiKey = [NSString stringWithFormat:@"%@%d", kLiveRemindNotificationKey, self.article.fileId];
    if ([self.liveRemindLabel.text isEqualToString:NSLocalizedString(@"提醒已开", nil)] && [LocalNotificationManager checkLocalNotificationWithKey:notiKey]) {
        self.liveRemindLabel.text = NSLocalizedString(@"添加提醒", nil);
        [LocalNotificationManager cancelLocalNotificationWithKey:notiKey];
    }else {
        self.liveRemindLabel.text = NSLocalizedString(@"提醒已开", nil);
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        NSDictionary *userInfo = @{notiKey:NSLocalizedString(@"直播提醒", nil),
                                   @"fileID":[NSString stringWithFormat:@"%d",self.article.fileId],
                                   @"linkID":[NSString stringWithFormat:@"%d",self.article.linkID],
                                   @"articleType":[NSString stringWithFormat:@"%d",self.article.articleType],
                                   @"title":self.article.title};
        [LocalNotificationManager configLocalNotificationWithFireDate:[formatter dateFromString:self.article.liveStartTime] alertMessage:[NSString stringWithFormat:@"%@:%@", NSLocalizedString(@"您订阅的直播即将开始", nil), self.article.title]  userInfo:userInfo];
    }
}

- (void)setHideReadCount
{
    if (self.article.articleType == ArticleType_LIVESHOW) {
        self.isAppearReadCount = [AppConfig sharedAppConfig].isLiveAppearReadCount;
        // 在全局显示阅读数的情况下，单独隐藏栏目数
        if ([AppConfig sharedAppConfig].isLiveAppearReadCount) {
            self.commentLabel.hidden = self.article.isHideReadCount;
        }else{
            self.commentLabel.hidden = YES;
        }
    }else{
        self.isAppearReadCount = [AppConfig sharedAppConfig].isAppearReadCount;
        // 在全局显示阅读数的情况下，单独隐藏栏目数
        if ([AppConfig sharedAppConfig].isAppearReadCount) {
            self.commentLabel.hidden = self.article.isHideReadCount;
        }else{
            self.commentLabel.hidden = YES;
        }
    }
    
}

@end
