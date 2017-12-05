//
//  LiveFrame.m
//  FounderReader-2.5
//
//  Created by 周志扬 on 15/9/7.
//
//

#import "LiveFrame.h"
#import "Global.h"
#import "SeeLivePhotosView.h"
#import "NewsListConfig.h"
#define SeeViewCellBorderW 13*liveProportion
@implementation LiveFrame

- (CGSize)sizeWithText:(NSString *)text font:(UIFont *)font maxW:(CGFloat)maxW
{
    CGSize maxSize = CGSizeMake(maxW, MAXFLOAT);
    CGSize size = CGSizeZero;//
    NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
    attrs[NSFontAttributeName] = font;
    size = [text boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
    return size;
}

- (CGSize)sizeWithText:(NSString *)text font:(UIFont *)font
{
    return [self sizeWithText:text font:font maxW:MAXFLOAT];
}
-(void)setTopModel:(TopDiscussmodel *)topModel
{
    _topModel = topModel;
    
    
    self.middleImageF = CGRectMake(9, 35, 3.5, 3.5);
    self.topLineF = CGRectMake(10, 0, 1, CGRectGetMinY(self.middleImageF));
    
    self.userImageF = CGRectMake(10, 10, 25, 25);
    
    //三角
    CGFloat taiangleX = CGRectGetMaxX(self.userImageF)-20;//距离头像的距离
    self.taiangleF = CGRectMake(taiangleX, 20, 5, 5*29/13);
    
    //直播卡片宽度
    XYLog(@"%f",CGRectGetMaxX(self.taiangleF));
    CGFloat cellContentW = kSWidth-CGRectGetMaxX(self.taiangleF)-10;
    
    //作者的名字
    CGFloat authorLabelX = SeeViewCellBorderW;
    
    NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:[Global fontName] size:[NewsListConfig sharedListConfig].middleCellSummaryFontSize], NSFontAttributeName,nil];
    NSString *userNameStr = @"[主持人] 名字限制最多十个汉字再加五个字";
    CGSize username =[userNameStr boundingRectWithSize:CGSizeMake(MAXFLOAT, 10) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:tdic context:nil].size;
    self.authorLabelF =  (CGRect){{authorLabelX + 25,12},username};
    
    //时间
    CGSize pushtimes = [topModel.publishTime boundingRectWithSize:CGSizeMake(MAXFLOAT, 10) options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading attributes:tdic context:nil].size;
    self.pushtimeF = CGRectMake(cellContentW-SeeViewCellBorderW-(pushtimes.width-50*kScale), 12, pushtimes.width-50*kScale, pushtimes.height);
    //赞的图片
    CGFloat contentLabelY = CGRectGetMaxY(self.userImageF)+13;
    //计算内容的高度（宽度固定）
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    [paragraphStyle setLineSpacing:4.0f];
    NSDictionary *attribute = @{NSFontAttributeName: [UIFont fontWithName:[Global fontName] size:17],
                                NSParagraphStyleAttributeName:paragraphStyle
                                };
    CGSize size = [topModel.content boundingRectWithSize:CGSizeMake(cellContentW-SeeViewCellBorderW*2, 100000) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
    self.summaryLaelF = (CGRect){authorLabelX,contentLabelY,cellContentW-SeeViewCellBorderW*2, size.height};
    
    // 视频:只有一个
    
    if (topModel.videos.count) {
        CGFloat videoImageX = SeeViewCellBorderW;
        CGFloat videoImageY = CGRectGetMaxY(self.summaryLaelF)+10;
        CGFloat videoImageW = self.summaryLaelF.size.width;
        CGFloat videoImageH = self.summaryLaelF.size.width/16.0*9;
        self.videoImageF = CGRectMake(videoImageX, videoImageY, videoImageW, videoImageH);
        _originalH = CGRectGetMaxY(self.videoImageF)+10;
        
        CGFloat videoIconWH = 35*liveProportion;
        self.videoIconF = CGRectMake((videoImageW - videoIconWH )/2,(videoImageH - videoIconWH )/2,videoIconWH, videoIconWH);
    }
    
    // 图片多个
    if (topModel.pics.count) {
        CGFloat photosX = SeeViewCellBorderW;
        CGFloat photosY;
        if (self.videoImageF.size.height) {
            photosY = CGRectGetMaxY(self.videoImageF)+10;
        }else{
            photosY = CGRectGetMaxY(self.summaryLaelF)+10;
        }
        
        CGSize photosSize = [SeeLivePhotosView sizeViewWithCount:(int)topModel.pics.count andSummaryWidth:self.summaryLaelF.size.width];
        
        self.photosImgViewF = (CGRect){{photosX,photosY},photosSize};
        XYLog(@"到底是%@",NSStringFromCGRect(self.photosImgViewF));
        _originalH = CGRectGetMaxY(self.photosImgViewF)+10;
        
    }
    
    if (!topModel.videos.count && !topModel.pics.count) {
        _originalH = CGRectGetMaxY(self.summaryLaelF)+10;
    }
    
    //白色背景的位置
    CGFloat messageBackViewH = _originalH;
    CGFloat messageBackViewX = CGRectGetMaxX(self.taiangleF);
    CGFloat messageBackViewY = 14;
    CGFloat messageBackViewW = kSWidth-messageBackViewX-10;
    self.messageBackViewF = CGRectMake(messageBackViewX, messageBackViewY, messageBackViewW, messageBackViewH);
    //点赞图片
    CGFloat topImageviewY =7;
    CGFloat topImageviewX = self.messageBackViewF.size.width-31;
    self.topImageview = CGRectMake(topImageviewX, topImageviewY, 23, 23);
    
    //赞的人数
    CGFloat toppeopleX = CGRectGetMaxX(self.topImageview)-60;
    CGFloat toppeopleY = topImageviewY;
    self.topPeople = CGRectMake(toppeopleX, toppeopleY, 40, 23);
    
    //赞的button
    CGFloat topbbuttonY = topImageviewY;
    self.topButton = CGRectMake(toppeopleX, topbbuttonY, 60, 25);
    
    
    
    self.cellHight = _originalH+5;
    //视频图片返回的高度  有些问题 返回的高度 太多 需要考虑 视频和九宫格
    //    self.videopicCellHight =backH+5;
}
@end
