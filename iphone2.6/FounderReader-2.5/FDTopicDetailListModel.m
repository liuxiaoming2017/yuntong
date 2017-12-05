//
//  FDTopicDetailListModel.m
//  FounderReader-2.5
//
//  Created by julian on 2017/6/20.
//
//

#import "FDTopicDetailListModel.h"
#import "NSMutableAttributedString + Extension.h"
#import "FDMyTopicImageView.h"
#import "HttpRequest.h"

@implementation FDTopicDetailListModel

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
    CGFloat marginH_15 = 15;
    CGFloat marginH_10 = 10;
    
    // start calculate height
    CGFloat topMarginH = 13;
    
    CGFloat nameH = 16;
    
    CGFloat nameMarginH = 2;
    
    CGFloat publishtimeH = 13.5;
    
    CGFloat publishtimeMarginH = marginH_15;
    
    CGFloat contentMarginH = 0;
    if (![NSString isNilOrEmpty:self.content]) {
        contentMarginH = marginH_10;
        if (!_contentH) {
            CGFloat contentDefaultH1 = kSWidth == 320 ? 42 : 46;
            CGFloat contentDefaultH2 = kSWidth == 320 ? 86 : 98;
            CGFloat contentDefaultH = ![self.pics count] ? contentDefaultH2 : contentDefaultH1;
            CGFloat font = 15.25f;
            CGFloat lineSpace = kSWidth == 320 ? 3 : 7;
            _attrContent = [[NSMutableAttributedString alloc] init];
            NSAttributedString *askAttrContent = [self.content stringWithFont:font LineSpacing:lineSpace];
            [_attrContent appendAttributedString:askAttrContent];
            CGFloat originalContentH = [_attrContent boundingHeightWithSize:CGSizeMake(kSWidth-marginH_15*2-25-marginH_10, CGFLOAT_MAX) font:[UIFont systemFontOfSize:font] lineSpacing:lineSpace maxLines:CGFLOAT_MAX];
            if (!_isHeader) {
                _contentH = originalContentH > contentDefaultH ? contentDefaultH : originalContentH;
            }else {
                _contentH = originalContentH;
            }
        }
    }
    
    CGFloat imagesMarginH = marginH_15;
    CGFloat imagesW = kSWidth-2*15-(25+10);
    if ([_pics count] == 1 && _isHeader)
        _imagesH = [FDMyTopicImageView getImageViewsHeightByOne:self];
    else
        _imagesH = [FDMyTopicImageView getImageViewsHeight:[_pics count] Width:imagesW IsHeader:_isHeader];
    
    if (_imagesH == 0)
        imagesMarginH = 0;
    
    CGFloat moreH = 0;
    CGFloat moreMarginH = 0;
    if (self.contentH == 42 || self.contentH == 46 || self.contentH == 86 || self.contentH == 98){
        moreH = _isHeader ? 0 : 16;
        moreMarginH = _isHeader ? 0 : marginH_15;
    } else {
        if ([_pics count] > 3) {
            moreH = _isHeader ? 0 : 16;
            moreMarginH = _isHeader ? 0 : marginH_15;
        }
    }
    
    CGFloat lineH = _isHeader ? 0 : 0.5;
    
    return topMarginH + nameH + nameMarginH + publishtimeH + publishtimeMarginH + _contentH + contentMarginH + _imagesH + imagesMarginH + moreH + moreMarginH + lineH;
}

- (void)getImageSizeFromAli:(NSString *)imageUrl
{
    NSString *requestString = [NSString stringWithFormat:@"%@@infoexif", imageUrl];
    HttpRequest *request = [[HttpRequest alloc] initWithURL:[NSURL URLWithString:requestString]];
    
    __weak __typeof (self)weakSelf = self;
    [request setCompletionBlock:^(NSData *data) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers  error:nil];
        NSDictionary *heightDict = [dict objectForKey:@"ImageHeight"];
        NSString *heightStr = [heightDict objectForKey:@"value"];
        NSDictionary *widthDict = [dict objectForKey:@"ImageWidth"];
        NSString *widthStr = [widthDict objectForKey:@"value"];
        weakSelf.imagesSizeByOne = CGSizeMake(widthStr.integerValue, heightStr.integerValue);
    }];
    [request setFailedBlock:^(NSError *error) {
        [Global showTip:NSLocalizedString(@"加载失败，请检查网络",nil)];
    }];
    [request startAsynchronous];
}

@end
