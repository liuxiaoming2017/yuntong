//
//  FDMyTopic.m
//  FounderReader-2.5
//
//  Created by Julian on 2017/5/5.
//
//

#import "FDMyTopic.h"
#import "NSMutableAttributedString + Extension.h"
#import "NewsListConfig.h"
#import "FDMyTopicImageView.h"

@interface FDMyTopic()

@end

@implementation FDMyTopic

/**
 *  当字典转模型完毕时调用
 */
- (void)mj_keyValuesDidFinishConvertingToObject
{
    if ([self.attUrls count]) {
        self.pics = [self.attUrls objectForKey:@"pics"];
    }
}

- (CGFloat)cellHeight
{
    CGFloat topMargin_15 = 15;
    CGFloat topMargin_10 = 10;
    
    if (!_titleH) {
        CGFloat fontSize = 17;
        CGFloat lineSpacing = (kSWidth == 375 ||kSWidth == 414) ? 6 : 3;
        _attrTitle = [NSMutableAttributedString attributedStringWithString:_title Font:[UIFont systemFontOfSize:fontSize] lineSpacing:lineSpacing];
        CGFloat titleLabelW = kSWidth-15*3-24;
        CGFloat _originalTitleH= [_attrTitle boundingHeightWithSize:CGSizeMake(titleLabelW, 0) font:[UIFont systemFontOfSize:fontSize] lineSpacing:lineSpacing maxLines:2];
        _titleH = _originalTitleH > 48.96 ? 48.96 : _originalTitleH;
        _titleH = _titleH < 30 ? 24 : _titleH;
    }
    
    CGFloat titleMarginH = topMargin_15;
    
    CGFloat contentMarginH = 0;
    if (![NSString isNilOrEmpty:self.content]) {
        contentMarginH = topMargin_15;
        if (!_contentH) {
            CGFloat contentDefaultH1 = kSWidth == 320 ? 42 : 46;
            CGFloat contentDefaultH2 = kSWidth == 320 ? 86 : 98;
            CGFloat contentDefaultH = ![self.pics count] ? contentDefaultH2 : contentDefaultH1;
            CGFloat font = 15;
            CGFloat lineSpace = kSWidth == 320 ? 3 : 7;
            _attrContent = [[NSMutableAttributedString alloc] init];
            NSAttributedString *askAttrContent = [self.content stringWithFont:font LineSpacing:lineSpace];
            [_attrContent appendAttributedString:askAttrContent];
            CGFloat originalContentH = [_attrContent boundingHeightWithSize:CGSizeMake(kSWidth - 30, CGFLOAT_MAX) font:[UIFont systemFontOfSize:font] lineSpacing:lineSpace maxLines:CGFLOAT_MAX];
            _contentH = originalContentH > contentDefaultH ? contentDefaultH : originalContentH;
        }
    }
    
    CGFloat imagesMarginH = 0;
    CGFloat imagesW = kSWidth-2*15;
    _imagesH = [FDMyTopicImageView getImageViewsHeight:[_pics count] Width:imagesW IsHeader:_isHeader];
    if (_imagesH != 0)
        imagesMarginH = topMargin_15;
    
    CGFloat toolsBtnH = 16;
    
    CGFloat toolsBtnMarginH = topMargin_10;
    
    CGFloat reasonH = 0;
    CGFloat reasonMarginH = 0;
    if (_discussStatus.integerValue == 2 && ![NSString isNilOrEmpty:_reason]) {
        reasonH = 20;
        reasonMarginH = topMargin_10;
    }
    
    CGFloat lineH = 0.5;
    
    return topMargin_15 + _titleH + titleMarginH + _contentH + contentMarginH + _imagesH + imagesMarginH + toolsBtnH + toolsBtnMarginH + reasonH + reasonMarginH + lineH;
}

@end
