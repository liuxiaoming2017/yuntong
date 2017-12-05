//
//  DirectFram.m
//  FounderReader-2.5
//
//  Created by 周志扬 on 15/8/19.
//
//

#import "DirectFram.h"
#import "Global.h"
#import "SeeDirectPhotosView.h"

#define SeeViewCellBorderW 5
@implementation DirectFram
@synthesize groundViewF;

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

-(void)setDirecttop:(SeeViewmodel *)directtop
{
    _directtop = directtop;
    
    self.groundViewF = CGRectMake(0, 0, kSWidth, kSWidth/16*9);
    //下面的标题
    CGFloat describelabelY = CGRectGetMaxY(groundViewF)+13;
    CGFloat describelabelX = SeeViewCellBorderW;
  CGSize describelabelSize = [self sizeWithText:directtop.title font:[UIFont fontWithName:[Global fontName] size:15] maxW:kSWidth-30];
    self.describelabelF = (CGRect){{describelabelX,describelabelY},describelabelSize};
    //点击的按钮
    CGFloat btnY = CGRectGetMaxY(self.describelabelF)+5;
    
    self.buttonLabel = CGRectMake(kSWidth-50, btnY, 20, 20);
    CGFloat buttonImageX = CGRectGetMaxX(self.buttonLabel);
    self.buttonImage =CGRectMake(buttonImageX, btnY, 20, 20);
    self.buttonF = CGRectMake(kSWidth-50, btnY, 40, 20);
    
    self.btnCellHeight = CGRectGetMaxY(self.buttonF);
    
    //下面的文字描述
    CGFloat contentlabelY =CGRectGetMaxY(self.buttonF);
    CGSize sourceSize = [self sizeWithText:directtop.content font:[UIFont fontWithName:[Global fontName] size:15] maxW:kSWidth-10];
    self.contentlabelF = (CGRect){{SeeViewCellBorderW,contentlabelY},sourceSize.width,sourceSize.height+3};
    
    if ([[[directtop.attachments lastObject]valueForKey:@"type"]intValue]==1) {
        //配图
        if (directtop.attachments.count) {
            CGFloat photosX = SeeViewCellBorderW;
            CGFloat photosY = CGRectGetMaxY(self.contentlabelF)+13;
            CGSize photosSize = [SeeDirectPhotosView sizeWithCount:(int)directtop.attachments.count];
            self.photosImageF = (CGRect){{photosX,photosY},photosSize};
            _originalH = CGRectGetMaxY(self.photosImageF)+10;
        }else{
            _originalH = CGRectGetMaxY(self.contentlabelF)+10;
        }
    }
   else if ([[[directtop.attachments lastObject]valueForKey:@"type"]intValue]==2) {
        CGFloat videoImageX = SeeViewCellBorderW;
        CGFloat videoImageY = CGRectGetMaxY(self.contentlabelF)+13;
        self.viedeoImageF = CGRectMake(videoImageX, videoImageY, kSWidth-30, (kSWidth-30)/16*9);
         _originalH = CGRectGetMaxY(self.viedeoImageF)+10;
    }else{
    
        _originalH = CGRectGetMaxY(self.contentlabelF)+10;
    }

    self.cellHeight = _originalH;
}
@end
