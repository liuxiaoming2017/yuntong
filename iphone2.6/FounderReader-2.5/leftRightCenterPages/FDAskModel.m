//
//  FDMyAskModel.m
//  FounderReader-2.5
//
//  Created by snitsky on 2017/3/10.
//
//

#import "FDAskModel.h"
#import "NSString+Helper.h"
#import "ColumnBarConfig.h"
#import "NSMutableAttributedString + Extension.h"

@interface FDAskModel()

@end

@implementation FDAskModel

/*
 * 计算cell高度
 * itemShowStatus : 问答内容展示状态
 */
- (CGFloat)cellHeight:(struct ItemShowStatus)itemShowStatus
{
//    self.content = @"@@收到了防静电可令肌肤点开链接放得开垃圾分类控件是了看见埃里克九分裤来得及萨芬金坷垃的积分来得及卡了数据放到算了快递放家里开始就弗兰克胶水颗粒房价是看了记得分克里斯的解放路谁离开房间卡洛斯极度分裂看似简单风口浪尖松开立即反馈老师叫冯仑就是浪蝶狂蜂建设路口老司机对反馈老师叫风口浪尖埃里克京东方垃圾袋放辣椒肯定是";
//    self.answerContent = @"##收到了防静电可令肌肤点开链接放得开垃圾分类控件是了看见埃里克九分裤来得及萨芬金坷垃的积分来得及卡了数据放到算了快递放家里开始就弗兰克胶水颗粒房价是看了记得分克里斯的解放路谁离开房间卡洛斯极度分裂看似简单风口浪尖松开立即反馈老师叫冯仑就是浪蝶狂蜂建设路口老司机对反馈老师叫风口浪尖埃里克京东方垃圾袋放辣椒肯定是三轮坑放家里手机登录开始懂了发送的了附件";
//    self.answerTime = @"2017-03-15 18:51:47";
   
    CGFloat askContentDefaultHeight = 100;
    CGFloat askOtherUIHeight =  72.5;//【间隔8+名字16】+ 【2+时间13.5】+【10+内容x1】+【10+更多】+ 【5+界线5】
    CGFloat moreBtnH = _isShowAllMore ? 0 : [UIImage imageNamed:@"icon-more-close"].size.height;
    if (!_askOriginalContentHeight) {
        CGFloat askFont = 16;
        CGFloat askLineSpace = kSWidth == 320 ? 3 : 7;
        NSString *preAskStr = NSLocalizedString(@"问：", nil);
        
        _askAttrContent = [[NSMutableAttributedString alloc] init];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = askLineSpace;
        NSDictionary *attributes = @{
                                     NSFontAttributeName:[UIFont systemFontOfSize:askFont],
                                     NSForegroundColorAttributeName:[ColumnBarConfig sharedColumnBarConfig].column_all_color,
                                     NSParagraphStyleAttributeName:paragraphStyle
                                    };
        NSAttributedString *preAskAttrStr = [[NSAttributedString alloc] initWithString:preAskStr attributes:attributes];
        [_askAttrContent appendAttributedString:preAskAttrStr];
        NSAttributedString *askAttrContent = [self.content stringWithFont:askFont LineSpacing:askLineSpace];
        [_askAttrContent appendAttributedString:askAttrContent];
        
        _askOriginalContentHeight = [_askAttrContent boundingHeightWithSize:CGSizeMake(kSWidth - 20, CGFLOAT_MAX) font:[UIFont systemFontOfSize:askFont] lineSpacing:askLineSpace maxLines:CGFLOAT_MAX];
    }
    if (_askOriginalContentHeight > askContentDefaultHeight) {
        if (itemShowStatus.askShow)
            _askContentHeight = _askOriginalContentHeight;
        else
            _askContentHeight = askContentDefaultHeight;
        askOtherUIHeight += (15 + moreBtnH);
    } else
        _askContentHeight = _askOriginalContentHeight;
    _askContentHeight = _isShowAllMore ? _askOriginalContentHeight : _askContentHeight;
    
    CGFloat answerOtherUIHeight =  0;
    if (![NSString isNilOrEmpty:self.answerTime]) {
        answerOtherUIHeight =  72.5;
        CGFloat answerContentDefaultHeight = 110;
        CGFloat answerLineH = 0.5;
        answerOtherUIHeight = answerOtherUIHeight + answerLineH;
        if (!_answerOriginalContentHeight) {
            CGFloat answerFont = 18;
            CGFloat answerLineSpace = kSWidth == 320 ? 4 : 8;
            _answerAttrContent = [NSMutableAttributedString attributedStringWithString:self.answerContent Font:[UIFont systemFontOfSize:answerFont] lineSpacing:answerLineSpace];
            _answerOriginalContentHeight = [_answerAttrContent boundingHeightWithSize:CGSizeMake(kSWidth - 20, CGFLOAT_MAX) font:[UIFont systemFontOfSize:answerFont] lineSpacing:answerLineSpace maxLines:CGFLOAT_MAX];
        }
        
        if (_answerOriginalContentHeight > answerContentDefaultHeight) {
            if (itemShowStatus.answerShow)
                _answerContentHeight = _answerOriginalContentHeight;
            else
                _answerContentHeight = answerContentDefaultHeight;
            answerOtherUIHeight += (15 + moreBtnH);
        } else
            _answerContentHeight = _answerOriginalContentHeight;
        _answerContentHeight = _isShowAllMore ? _answerOriginalContentHeight : _answerContentHeight;
    }
    CGFloat seperateH = 5;
    _cellHeight = (askOtherUIHeight + _askContentHeight) + (answerOtherUIHeight + _answerContentHeight) + seperateH;
    
    return _cellHeight;
}

// 实现自定义浅、深拷贝【不可变】对象
- (id)copyWithZone:(NSZone *)zone
{
    FDAskModel *askModel=[[self class] allocWithZone:zone];
    
    //浅拷贝
    askModel.qid = _qid;
    askModel.content = _content;
    //...
    
    // 深拷贝【不可变】对象
    // NSNumber CGFloat等是不可变的copy/mutableCopy无意义，会返回本身
    askModel.qid = _qid;
    askModel.content = [_content copy];
    askModel.createTime = [_createTime copy];
    askModel.answerTime = [_answerTime copy];
    askModel.askStatus = _askStatus;
    askModel.uid = [_uid copy];
    askModel.answerContent = [_answerContent copy];
    askModel.praiseCount = _praiseCount;
    askModel.aid = _aid;
    askModel.authorID = _authorID;
    askModel.title = [_title copy];
    askModel.askbarTopImg = [_askbarTopImg copy];
    askModel.askFaceUrl = [_askFaceUrl copy];
    askModel.answerFaceUrl = [_answerFaceUrl copy];
    askModel.askUserName = [_askUserName copy];
    askModel.answerName = [_answerName copy];
    askModel.askAttrContent = [_askAttrContent copy];
    askModel.answerAttrContent = [_answerAttrContent copy];
    askModel.askContentHeight = _askContentHeight;
    askModel.answerContentHeight = _answerContentHeight;
    askModel.askOriginalContentHeight = _askOriginalContentHeight;
    askModel.answerOriginalContentHeight = _answerOriginalContentHeight;
    askModel.cellHeight = _cellHeight;
    askModel.isShowAllMore = _isShowAllMore;
    
    return askModel;
}

// 实现自定义浅、深拷贝【可变】对象
- (id)mutableCopyWithZone:(NSZone *)zone
{
    FDAskModel *askModel=[[self class] allocWithZone:zone];
    
    //浅拷贝
//    askModel.qid = _qid;
//    askModel.content = _content;
    //...
    
    // 深拷贝【可变】对象
    // NSNumber CGFloat等是不可变的copy/mutableCopy无意义，会返回本身
    askModel.qid = _qid;
    askModel.content = [_content mutableCopy];
    askModel.createTime = [_createTime mutableCopy];
    askModel.answerTime = [_answerTime mutableCopy];
    askModel.askStatus = _askStatus;
    askModel.uid = [_uid mutableCopy];
    askModel.answerContent = [_answerContent mutableCopy];
    askModel.praiseCount = _praiseCount;
    askModel.aid = _aid;
    askModel.authorID = _authorID;
    askModel.title = [_title mutableCopy];
    askModel.askbarTopImg = [_askbarTopImg mutableCopy];
    askModel.askFaceUrl = [_askFaceUrl mutableCopy];
    askModel.answerFaceUrl = [_answerFaceUrl mutableCopy];
    askModel.askUserName = [_askUserName mutableCopy];
    askModel.answerName = [_answerName mutableCopy];
    askModel.askAttrContent = [_askAttrContent mutableCopy];
    askModel.answerAttrContent = [_answerAttrContent mutableCopy];
    askModel.askContentHeight = _askContentHeight;
    askModel.answerContentHeight = _answerContentHeight;
    askModel.askOriginalContentHeight = _askOriginalContentHeight;
    askModel.answerOriginalContentHeight = _answerOriginalContentHeight;
    askModel.cellHeight = _cellHeight;
    askModel.isShowAllMore = _isShowAllMore;
    
    return askModel;
}

@end
