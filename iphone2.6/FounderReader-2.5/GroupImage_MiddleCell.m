//
//  GroupImage_MiddleCell.m
//  FounderReader-2.5
//
//  Created by ld on 14-7-23.
//
//

#import "GroupImage_MiddleCell.h"
#import "NSString+Helper.h"
#import "NewsListConfig.h"
#import "UIImageView+WebCache.h"
#import "UIView+Extention.h"
#import "ColorStyleConfig.h"
#import "ColumnBarConfig.h"
#import "AppConfig.h"

@implementation GroupImage_MiddleCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        leftImageView = [[FLAnimatedImageView alloc] init];
        leftImageView.contentMode = UIViewContentModeScaleAspectFill;//不变形居中显示，会有部分裁剪
        leftImageView.clipsToBounds  = YES;//超出边界部分裁剪
        leftImageView.image =[Global getBgImage43];
        [self.contentView addSubview:leftImageView];
        
        centerImageView = [[FLAnimatedImageView alloc] init];
        centerImageView.image = [Global getBgImage43];
        centerImageView.contentMode = UIViewContentModeScaleAspectFill;//不变形居中显示，会有部分裁剪
        centerImageView.clipsToBounds  = YES;//超出边界部分裁剪
        centerImageView.image =[Global getBgImage43];
        [self.contentView addSubview:centerImageView];
        
        rightImageView = [[FLAnimatedImageView alloc] init];
        rightImageView.contentMode = UIViewContentModeScaleAspectFill;//不变形居中显示，会有部分裁剪
        rightImageView.clipsToBounds  = YES;//超出边界部分裁剪
        rightImageView.image = [Global getBgImage43];
        centerImageView.image =[Global getBgImage43];
        [self.contentView addSubview:rightImageView];
    }
     return self;
}
//按要求截取字符串
-(NSString *)stringAtIndexByCount:(NSString *)string withCount:(NSInteger)count
{
    int i;
    int sum=0;
    for(i=0;i<[string length];i++)
    {
        unichar str = [string characterAtIndex:i];
        if(str < 256){
            sum+=1;
        }
        else {
            sum+=2;
        }
        if(sum>count){
            //当字符大于count时，剪取三个位置，显示省略号。否则正常显示
            NSString * str=[string substringWithRange:NSMakeRange(0,[self charAtIndexByCount:string withCount:count-3])];
            
            return [NSString stringWithFormat:@"%@",str];
        }
    }
    return string;
}
//超过count时，截取字符
-(NSInteger)charAtIndexByCount:(NSString *)string withCount:(NSInteger)count
{
    int i;
    int sum=0;
    int count2=0;
    for(i=0;i<[string length];i++)
    {
        unichar str = [string characterAtIndex:i];
        if(str < 256){
            sum+=1;
        }
        else {
            sum+=2;
        }
        count2++;
        if (sum>=count){
            break;
        }
    }
    if(sum>count){
        return count2-1;
    }
    else
        return count2;
}
-(void)configGroupImageCellWithTitle:(NSString *)title groupImage:(NSString *)groupImageStr columnId:(int)columnId
{
    [thumbnailbackground removeFromSuperview];
    [thumbnail removeFromSuperview];
    [summaryLabel removeFromSuperview];
    titleLabel.text = title;
    titleLabel.frame = CGRectMake(10*proportion, 10*proportion, cellBgView.frame.size.width - 20*proportion, 18);
    titleLabel.numberOfLines = 1;
    titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    titleLabel.font = [UIFont fontWithName:[Global fontName] size:[NewsListConfig sharedListConfig].middleCellTitleFontSize];
    NSArray *groupArry = [groupImageStr componentsSeparatedByString:@","];
    leftImageView.frame = CGRectMake(10, CGRectGetMaxY(titleLabel.frame)+8*proportion, 96*proportion, 72*proportion);
    
    if (groupArry.count > 0) {
        NSString *str = [groupArry objectAtIndex:0];
        if ([str containsString:@".gif"]) {
            leftImageView.image = [Global getBgImage43];
            [self loadAnimatedImageWithURL:[NSURL URLWithString:str] completion:^(FLAnimatedImage *animatedImage) {
                
                [leftImageView setAnimatedImage:animatedImage];
            }];
        }else {
            leftImageView.image = [Global getBgImage43];
            [leftImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@@!sm43",[groupArry objectAtIndex:0]]] placeholderImage:[Global getBgImage43]];
            leftImageView.hidden = NO;
        }
    }
    else
        leftImageView.hidden = YES;
    
    centerImageView.frame = CGRectMake(CGRectGetMaxX(leftImageView.frame) + ((320-96*3)*proportion-20)/2, leftImageView.frame.origin.y, 96*proportion, 72*proportion);
    if (groupArry.count >1) {
        NSString *str = [groupArry objectAtIndex:1];
        if ([str containsString:@".gif"]) {
            centerImageView.image = [Global getBgImage43];
            [self loadAnimatedImageWithURL:[NSURL URLWithString:str] completion:^(FLAnimatedImage *animatedImage) {
                
                [centerImageView setAnimatedImage:animatedImage];
            }];
        }else {
            centerImageView.image = [Global getBgImage43];
            [centerImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@@!sm43",[groupArry objectAtIndex:1]]] placeholderImage:[Global getBgImage43]];
            centerImageView.hidden = NO;
        }
    }
    else
        centerImageView.hidden = YES;
    
    rightImageView.frame = CGRectMake(CGRectGetMaxX(centerImageView.frame) + ((320-96*3)*proportion-20)/2, leftImageView.frame.origin.y, 96*proportion, 72*proportion);
    if (groupArry.count >2) {
        NSString *str = [groupArry objectAtIndex:2];
        if ([str containsString:@".gif"]) {
            rightImageView.image = [Global getBgImage43];
            [self loadAnimatedImageWithURL:[NSURL URLWithString:str] completion:^(FLAnimatedImage *animatedImage) {
                
                [rightImageView setAnimatedImage:animatedImage];
            }];
        }else {
            rightImageView.image = [Global getBgImage43];
            [rightImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@@!sm43",[groupArry objectAtIndex:2]]] placeholderImage:[Global getBgImage43]];
            rightImageView.hidden = NO;
        }
    }
    else
        rightImageView.hidden = YES;
}

-(void)configGroupImageCellWithArticle:(Article *)article
{

    CGRect bgFrame = CGRectMake(8, 10, kSWidth-16, (82 + 45)*proportion);
    cellBgView.frame = bgFrame;
    footSeq.frame = CGRectMake(0, CGRectGetMaxY(cellBgView.frame) -1, kSWidth, 0.5);
    [self configGroupImageCellWithTitle:article.title groupImage:article.groupImageUrl columnId:article.columnId];
    if (article.isRead) {
        titleLabel.textColor = summaryLabel.textColor;
    }else{
        titleLabel.textColor = [UIColor blackColor];
        
    }
    
    if (article.tag.length) {
        
        NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleCellDateFontSize], NSFontAttributeName,nil];
        CGSize size = [article.tag boundingRectWithSize:CGSizeMake(100, 12*proportion) options:NSStringDrawingUsesLineFragmentOrigin attributes:tdic context:nil].size;
        
        statusLabel.frame = CGRectMake(leftImageView.x,CGRectGetMaxY(leftImageView.frame)+10,size.width+10,12*proportion);
        statusLabel.text = article.tag;
        statusLabel.font = [UIFont fontWithName:[Global fontName] size:[NewsListConfig sharedListConfig].middleCellSummaryFontSize];
        statusLabel.textColor = [ColumnBarConfig sharedColumnBarConfig].column_all_color;
        statusLabel.backgroundColor = [UIColor clearColor];
        statusLabel.textAlignment = 1;
        statusLabel.hidden = NO;
        self.commentLabel.textAlignment = NSTextAlignmentLeft;
        if (self.isAppearReadCount && (![NSString isNilOrEmpty:article.readCount] && ![article.readCount isEqualToString:@"0"])) {
            self.commentLabel.hidden = NO;
            self.commentSign.hidden = NO;
            NSString *commentNum = [NSString stringWithFormat:@"%@%@",article.readCount, NSLocalizedString(@"人阅读","")];
            CGSize commentSize = [commentNum boundingRectWithSize:CGSizeMake(320, 12) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:tdic context:nil].size;
            self.commentLabel.frame = CGRectMake(CGRectGetMaxX(statusLabel.frame)+10,CGRectGetMaxY(leftImageView.frame)+9, commentSize.width+5, commentSize.height);//220-60+30
            self.commentLabel.text = [NSString stringWithFormat:@"%@%@",article.readCount, NSLocalizedString(@"人阅读",nil)];
            dateLabel.frame = CGRectMake(CGRectGetMaxX(self.commentLabel.frame)+10,CGRectGetMaxY(leftImageView.frame)+10,120,12*proportion);
        }
        else{
            self.commentLabel.hidden = YES;
            self.commentSign.hidden = YES;
            dateLabel.frame = CGRectMake(CGRectGetMaxX(statusLabel.frame)+10,CGRectGetMaxY(leftImageView.frame)+10,120,12*proportion);
        }
    }
    else{
        statusLabel.hidden = YES;
    
        self.timerSign.frame = CGRectMake(263,105,10,10);
        self.commentSign.frame = CGRectMake(197-60+30, 105,10,10);
        self.commentLabel.font = [UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleCellDateFontSize];
        if (self.isAppearReadCount && (![NSString isNilOrEmpty:article.readCount] && ![article.readCount isEqualToString:@"0"])) {
            self.commentLabel.hidden = NO;
            self.commentSign.hidden = NO;
            NSString *commentNum =[NSString stringWithFormat:@"%@%@",article.readCount, NSLocalizedString(@"人阅读","")];
            NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:[Global fontName] size:[NewsListConfig sharedListConfig].middleCellDateFontSize], NSFontAttributeName,nil];
            CGSize commentSize = [commentNum boundingRectWithSize:CGSizeMake(320, 16) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:tdic context:nil].size;
            self.commentLabel.frame = CGRectMake(leftImageView.x,CGRectGetMaxY(leftImageView.frame)+8, commentSize.width+5, commentSize.height);//220-60+30
            self.commentLabel.text = [NSString stringWithFormat:@"%@%@",article.readCount, NSLocalizedString(@"人阅读",nil)];
            dateLabel.frame = CGRectMake(CGRectGetMaxX(self.commentLabel.frame)+10,CGRectGetMaxY(leftImageView.frame)+10,120,12*proportion);
        }
        else{
            self.commentLabel.hidden = YES;
            self.commentSign.hidden = YES;
            dateLabel.frame = CGRectMake(leftImageView.x,CGRectGetMaxY(leftImageView.frame)+10,120,12*proportion);
        }
    }
    dateLabel.textAlignment = NSTextAlignmentRight;
    NSString *dateStr = article.publishTime;
    dateStr = [dateStr stringByReplacingOccurrencesOfString:@"T" withString:@" "];
    dateStr = [dateStr stringByReplacingOccurrencesOfString:@"Z" withString:@""];
    dateLabel.text = intervalSinceNow(dateStr);
    dateLabel.textColor = [UIColor lightGrayColor];
    dateLabel.textAlignment = NSTextAlignmentLeft;
    dateLabel.font = [UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleCellDateFontSize];
    dateLabel.hidden = ![AppConfig sharedAppConfig].isAppearDate;
}

- (void)setGroupCellHideReadCount
{
    // 在全局显示阅读数的情况下，单独隐藏栏目的阅读数
    if ([AppConfig sharedAppConfig].isAppearReadCount)
        self.isAppearReadCount = !self.article.isHideReadCount;
    else
        self.isAppearReadCount = NO;
}

@end
