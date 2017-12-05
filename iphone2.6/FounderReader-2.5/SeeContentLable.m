//
//  SeeContentLable.m
//  FounderReader-2.5
//
//  Created by yanbf on 16/10/17.
//
//

#import "SeeContentLable.h"
#import "DirectFram.h"
#import "SeeMethod.h"
#import "UIView+Extention.h"
#import "SeeViewmodel.h"
#import "TopDiscussmodel.h"
#import "AppStartInfo.h"
#import "NSString+Helper.h"
#import "FileLoader.h"
#import "UIDevice-Reachability.h"
#import "YXLoginViewController.h"
#import "UIImageView+WebCache.h"

@interface SeeContentLable ()



@end

@implementation SeeContentLable
@synthesize contentLable;

-(void)creatContentLableView {
    
    [self creatCountLable:self.discussmodel];
}

-(void)creatCountLable:(TopDiscussmodel *)topmodel {

    contentLable = [[UILabel alloc] init]; //摘要
    contentLable.tag = 662;
    contentLable.font = [UIFont fontWithName:[Global fontName] size:17];
    
    contentLable.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
    contentLable.numberOfLines = 0;
//    contentLable.numberOfLines = 5;
    contentLable.lineBreakMode = NSLineBreakByTruncatingTail;
//    [contentLable sizeToFit];
//    contentLable.lineBreakMode = UILineBreakModeWordWrap | UILineBreakModeTailTruncation;
    if ([self.msg isEqualToString:@"直播话题还未发布"]) {
        contentLable.text = @"友情提示:直播话题还未发布,请稍后重试!";
    }else {
        contentLable.text = topmodel.content;
    }
    
    
    CGFloat height = [self getZSCTextHight:contentLable.text andWidth:kSWidth-20 andTextFontSize:(13/320.0)*kSWidth];
    // 模拟没有内容
//    height = 0.0;
//    contentLable.text = @"";
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    
    paragraphStyle.lineSpacing = 5*kScale;
    NSDictionary *attributes = @{
                                 NSFontAttributeName:[UIFont fontWithName:[Global fontName] size:(13/320.0)*kSWidth],
                                 NSParagraphStyleAttributeName:paragraphStyle
                                 };
    
    if ([NSString isNilOrEmpty:contentLable.text]) {
        contentLable.text = @"";//设置为空
        height = 0.0;
    }
    NSAttributedString *atrStr = [[NSAttributedString alloc] initWithString:contentLable.text attributes:attributes];
    contentLable.attributedText = atrStr;
    
    contentLable.frame = CGRectMake(10, 0, kSWidth-20, height*1.5+10);
    CGFloat contentLableHeight = contentLable.bounds.size.height;
    if (height == 0.0) {
        contentLableHeight = 0;
    }
    
    [self addSubview:contentLable];
    
    
    
    NSDictionary *contentLableDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%f",contentLableHeight],@"contentLableHeight", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ContentLableHeight" object:self userInfo:contentLableDict];
}

- (CGFloat)getZSCTextHight:(NSString *)textStr andWidth:(CGFloat)width andTextFontSize:(NSInteger)fontSize {
    
    CGSize size = CGSizeZero;
    NSDictionary *attribute = @{NSFontAttributeName: [UIFont fontWithName:[Global fontName] size:fontSize]};
    if ([NSString isNilOrEmpty:textStr]) {
        return 0;
    }
    size = [textStr boundingRectWithSize:CGSizeMake(width, 1000) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
    
    return size.height;
}

@end
