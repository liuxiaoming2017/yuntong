//
//  RemarksTableViewCell.m
//  FlowerReceiveDemo
//
//  Created by Eyes on 16/2/19.
//  Copyright © 2016年 DuanGuoLi. All rights reserved.
//

#import "FDQuestionsAndAnwsersPlusDetailCell.h"
#import "FDAskModel.h"
#import "UIImageView+WebCache.h"
#import "UIView+Extention.h"
#import "ColumnBarConfig.h"
#import "UIButton+Block.h"
#import "UIView + ExtendTouchRect.h"

@interface FDQuestionsAndAnwsersPlusDetailCell ()

@property (strong, nonatomic) UIView *askBgView;
@property (strong, nonatomic) UIImageView *askAvaterImageView;
@property (strong, nonatomic) UILabel *askNameLabel;
@property (strong, nonatomic) UILabel *askTimeLabel;
@property (strong, nonatomic) UILabel *askContentLabel;
@property (strong, nonatomic) UIButton *askMoreBtn;

@property (strong, nonatomic) UIView *answerBgView;
@property (strong, nonatomic) UIView *answerLineView;
@property (strong, nonatomic) UIImageView *answerAvaterImageView;
@property (strong, nonatomic) UILabel *answerNameLabel;
@property (strong, nonatomic) UILabel *answerTimeLabel;

@property (strong, nonatomic) UILabel *answerPraiseCountLabel;
@property (strong, nonatomic) UIButton *answerCommentBtn;
@property (strong, nonatomic) UILabel *answerContentLabel;
@property (strong, nonatomic) UIButton *answerMoreBtn;
@property (strong, nonatomic) UIView *separateView;

@property (assign, nonatomic)struct ItemShowStatus itemShowStatus;

@end

@implementation FDQuestionsAndAnwsersPlusDetailCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI
{
    [self.contentView addSubview:self.askBgView];
    [self.contentView addSubview:self.answerBgView];
    
    [self.askBgView addSubview:self.askAvaterImageView];
    [self.askBgView addSubview:self.askNameLabel];
    [self.askBgView addSubview:self.askTimeLabel];
    [self.askBgView addSubview:self.askContentLabel];
    [self.askBgView addSubview:self.askMoreBtn];
    
    [self.answerBgView addSubview:self.answerLineView];
    [self.answerBgView addSubview:self.answerAvaterImageView];
    [self.answerBgView addSubview:self.answerNameLabel];
    [self.answerBgView addSubview:self.answerTimeLabel];
    [self.answerBgView addSubview:self.answerPraiseBtn];
    [self.answerBgView addSubview:self.answerPraiseCountLabel];
//    [self.answerBgView addSubview:self.answerCommentBtn];
    [self.answerBgView addSubview:self.answerContentLabel];
    [self.answerBgView addSubview:self.answerMoreBtn];
    
    [self.contentView addSubview:self.separateView];
}

- (void)layoutCellUI:(FDAskModel *)askModel ShowStatus:(struct ItemShowStatus)itemShowStatus IndexPath:(NSIndexPath *)indexPath EventBlock:(EventBlock)eventBlock
{
    _askModel = askModel;
    _itemShowStatus = itemShowStatus;
    
    if (_askModel.isShowAllMore) {
        _itemShowStatus.askShow = YES;
        _itemShowStatus.answerShow = YES;
    }

    /* ask部分 */
    _askBgView.frame = CGRectMake(0, 0, kSWidth, CGFLOAT_MIN);
    
    CGFloat avaterImageViewW = 25;
    _askAvaterImageView.frame = CGRectMake(10, 15, avaterImageViewW, avaterImageViewW);
    [_askAvaterImageView sd_setImageWithURL:[NSURL URLWithString:askModel.askFaceUrl] placeholderImage:[UIImage imageNamed:@"me_icon_head-app"]];
    _askAvaterImageView.layer.masksToBounds = YES;
    _askAvaterImageView.layer.cornerRadius = avaterImageViewW/2.0f;
    
    _askNameLabel.frame = CGRectMake(CGRectGetMaxX(_askAvaterImageView.frame)+10, 13, kSWidth-CGRectGetMaxX(_askAvaterImageView.frame)-10-10, 16);
    _askNameLabel.font = [UIFont systemFontOfSize:13];
    _askNameLabel.textAlignment = NSTextAlignmentLeft;
    _askNameLabel.textColor = [ColumnBarConfig sharedColumnBarConfig].column_all_color;
    _askNameLabel.text = _askModel.askUserName;
    
    _askTimeLabel.frame = CGRectMake(CGRectGetMaxX(_askAvaterImageView.frame)+10, CGRectGetMaxY(_askNameLabel.frame)+2, kSWidth-CGRectGetMaxX(_askAvaterImageView.frame)-10-10, 13.5);
    _askTimeLabel.font = [UIFont systemFontOfSize:11.5];
    _askTimeLabel.textAlignment = NSTextAlignmentLeft;
    _askTimeLabel.textColor = [UIColor grayColor];
    _askTimeLabel.text = intervalSinceNow(_askModel.createTime);
    
    _askContentLabel.frame = CGRectMake(10, CGRectGetMaxY(_askTimeLabel.frame)+13, kSWidth-20, _askModel.askContentHeight);
    _askContentLabel.textColor = colorWithHexString(@"666666");
    _askContentLabel.attributedText = _askModel.askAttrContent;
    
    UIImage *moreCloseImage = [UIImage imageNamed:@"icon-more-close"];
    UIImage *moreOpenImage = [UIImage imageNamed:@"icon-more-open"];
    _askMoreBtn.frame = CGRectMake((kSWidth-moreCloseImage.size.width)/2.0f, CGFLOAT_MIN, moreCloseImage.size.width,moreCloseImage.size.height);
    // 图片往上移动
//    _askMoreBtn.imageEdgeInsets = UIEdgeInsetsMake(-5, 5, 5, 5);
    [_askMoreBtn setTouchExtendInset:UIEdgeInsetsMake(-50, -10, -10, -10)];
    [_askMoreBtn setImage:moreCloseImage forState:UIControlStateNormal];
    [_askMoreBtn setImage:moreOpenImage forState:UIControlStateSelected];
    __weak __typeof(self)weakSelf = self;
    [_askMoreBtn addAction:^(UIButton *btn) {
        btn.selected = !btn.selected;
        _itemShowStatus.askShow = btn.selected;
        // 记录当前按钮的选中状态，并传递给Controller
        NSDictionary *showDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:weakSelf.itemShowStatus.askShow], @"ask", [NSNumber numberWithInteger:weakSelf.itemShowStatus.answerShow], @"answer", nil];
        NSDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"show", @"event", [NSNumber numberWithInteger:indexPath.row], @"row", showDic, @"showStatus", nil];
        // 回调，改变Controller中存放Cell展开收起状态的字典
        if (eventBlock)
            eventBlock(dic);
    }];
    
    if (_askModel.askOriginalContentHeight > 100) {
        // 文字大于三行，显示展开收起按钮
        _askMoreBtn.hidden = NO;
        if (_itemShowStatus.askShow) {
            _askContentLabel.numberOfLines = 0;
        } else {
            _askContentLabel.numberOfLines = 4;
            // 虽然可以不用变为80，但为了避免高度不变文字行数变少导致居中显示了。
            _askContentLabel.height = 100;
        }
        _askMoreBtn.hidden = askModel.isShowAllMore;
    } else {
        // 文字小于4行，隐藏展开收起按钮
        _askMoreBtn.hidden = YES;
        _askContentLabel.numberOfLines = 4;
    }

    _askMoreBtn.y = CGRectGetMaxY(_askContentLabel.frame)+15;
    _askBgView.height = _askMoreBtn.hidden ? CGRectGetMaxY(_askContentLabel.frame)+15: CGRectGetMaxY(_askMoreBtn.frame)+15;
    
    /* answer部分 */
    if ([NSString isNilOrEmpty:_askModel.answerTime]) {
        _answerBgView.hidden = YES;
    }else {
        
        _answerBgView.hidden = NO;
        _answerBgView.frame = CGRectMake(0, CGRectGetMaxY(_askBgView.frame), kSWidth, CGFLOAT_MIN);
        
        _answerLineView.frame = CGRectMake(_askAvaterImageView.x, 0, kSWidth-20, 0.5);
        _answerLineView.backgroundColor = colorWithHexString(@"dddddd");
        
        _answerAvaterImageView.frame = CGRectMake(_askAvaterImageView.x, CGRectGetMaxY(_answerLineView.frame)+_askAvaterImageView.y, avaterImageViewW, avaterImageViewW);
        [_answerAvaterImageView sd_setImageWithURL:[NSURL URLWithString:askModel.answerFaceUrl] placeholderImage:nil];
        _answerAvaterImageView.layer.masksToBounds = YES;
        _answerAvaterImageView.layer.cornerRadius = avaterImageViewW/2.0f;
        
        CGSize answerNameSize = [_askModel.answerName sizeWithFont:13 LineSpacing:0 maxSize:CGSizeMake(CGFLOAT_MAX, 0)];
        _answerNameLabel.frame = CGRectMake(CGRectGetMaxX(_answerAvaterImageView.frame)+10, CGRectGetMaxY(_answerLineView.frame)+_askNameLabel.y, answerNameSize.width, 16);
        _answerNameLabel.font = [UIFont systemFontOfSize:13];
        _answerNameLabel.textAlignment = NSTextAlignmentLeft;
        _answerNameLabel.textColor = [ColumnBarConfig sharedColumnBarConfig].column_all_color;
        _answerNameLabel.text = _askModel.answerName;
        
        NSString *answerTimeStr = intervalSinceNow(_askModel.answerTime);
        CGSize answerTimeSize = [answerTimeStr sizeWithFont:11.5 LineSpacing:0 maxSize:CGSizeMake(CGFLOAT_MAX, 0)];
        _answerTimeLabel.frame = CGRectMake(CGRectGetMaxX(_answerAvaterImageView.frame)+10, CGRectGetMaxY(_answerNameLabel.frame)+2, answerTimeSize.width, 13.5);
        _answerTimeLabel.font = [UIFont systemFontOfSize:11.5];
        _answerTimeLabel.textAlignment = NSTextAlignmentLeft;
        _answerTimeLabel.textColor = [UIColor grayColor];
        _answerTimeLabel.text = answerTimeStr;
        
        UIImage *praiseImage = [UIImage imageNamed:@"btn_comment_normal"];
        _answerPraiseBtn.frame = CGRectMake(kSWidth-praiseImage.size.width-10-10, _answerAvaterImageView.y, praiseImage.size.width+10,praiseImage.size.height+10);
        [_answerPraiseBtn setTouchExtendInset:UIEdgeInsetsMake(-50, -10, -10, -10)];
        [_answerPraiseBtn setImage:praiseImage forState:UIControlStateNormal];
        [_answerPraiseBtn setImage:[UIImage imageNamed:@"btn_comment_press"] forState:UIControlStateSelected];
        NSString *prasieKey = [NSString stringWithFormat:@"isPraise_%ld", _askModel.qid.integerValue];
        _answerPraiseBtn.selected = [[[NSUserDefaults standardUserDefaults] objectForKey:prasieKey] boolValue];
        [_answerPraiseBtn addAction:^(UIButton *btn) {
            NSDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"praise", @"event", indexPath, @"indexPath", btn, @"eventView", nil];
            //已点赞不能取消，只处理未点赞
            if (!btn.selected) {
                // 回调，改变Controller中存放Cell展开收起状态的字典
                if (eventBlock)
                    eventBlock(dic);
            }
        }];
        
        CGSize answerPraiseCountSize = [[NSString stringWithFormat:@"%ld", _askModel.praiseCount.integerValue] sizeWithFont:12 LineSpacing:0 maxSize:CGSizeMake(CGFLOAT_MAX, 0)];
        _answerPraiseCountLabel.frame = CGRectMake(_answerPraiseBtn.x-2-answerPraiseCountSize.width, _answerPraiseBtn.y+8, answerPraiseCountSize.width, 13.5);
        _answerPraiseCountLabel.font = [UIFont systemFontOfSize:12];
        _answerPraiseCountLabel.textAlignment = NSTextAlignmentLeft;
        _answerPraiseCountLabel.textColor = [UIColor grayColor];
        _answerPraiseCountLabel.text = [NSString stringWithFormat:@"%ld", _askModel.praiseCount.integerValue];
        
        UIImage *commentImage = [UIImage imageNamed:@"toolbar_comment_normal"];
        _answerCommentBtn.frame = CGRectMake(_answerPraiseBtn.x-10-praiseImage.size.width, _answerAvaterImageView.y, praiseImage.size.width+10,praiseImage.size.height+10);
        [_answerCommentBtn setImage:commentImage forState:UIControlStateNormal];
        [_answerCommentBtn setImage:[UIImage imageNamed:@"toolbar_comment_press"] forState:UIControlStateSelected];
        [_answerCommentBtn addAction:^(UIButton *btn) {
            btn.selected = !btn.selected;
        }];
        
        _answerContentLabel.frame = CGRectMake(10, CGRectGetMaxY(_answerTimeLabel.frame)+13, kSWidth-20, _askModel.answerContentHeight);
        _answerContentLabel.textColor = colorWithHexString(@"333333");
        _answerContentLabel.attributedText = _askModel.answerAttrContent;
        
        _answerMoreBtn.frame = CGRectMake((kSWidth-moreCloseImage.size.width)/2.0f, CGRectGetMaxY(_answerContentLabel.frame)+10, moreCloseImage.size.width,moreCloseImage.size.height);
        [_answerMoreBtn setTouchExtendInset:UIEdgeInsetsMake(-50, -10, -10, -10)];
        [_answerMoreBtn setImage:moreCloseImage forState:UIControlStateNormal];
        [_answerMoreBtn setImage:moreOpenImage forState:UIControlStateSelected];
        [_answerMoreBtn addAction:^(UIButton *btn) {
            btn.selected = !btn.selected;
            _itemShowStatus.answerShow = btn.selected;
            // 记录当前按钮的选中状态，并传递给Controller
            NSDictionary *showDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:weakSelf.itemShowStatus.askShow], @"ask", [NSNumber numberWithInteger:weakSelf.itemShowStatus.answerShow], @"answer", nil];
            NSDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"show", @"event", [NSNumber numberWithInteger:indexPath.row], @"row", showDic, @"showStatus", nil];
            // 回调，改变Controller中存放Cell展开收起状态的字典
            if (eventBlock)
                eventBlock(dic);
        }];
        
        if (_askModel.answerOriginalContentHeight > 110) {
            // 文字大于三行，显示展开收起按钮
            _answerMoreBtn.hidden = NO;
            if (_itemShowStatus.answerShow) {
                _answerContentLabel.numberOfLines = 0;
            } else {
                _answerContentLabel.numberOfLines = 4;
                // 虽然可以不用变为80，但为了避免高度不变文字行数变少导致居中显示了。
                _answerContentLabel.height = 110;
            }
            _answerMoreBtn.hidden = askModel.isShowAllMore;
        } else {
            // 文字小于4行，隐藏展开收起按钮
            _answerMoreBtn.hidden = YES;
            _answerContentLabel.numberOfLines = 4;
        }
        
        _answerMoreBtn.y = CGRectGetMaxY(_answerContentLabel.frame)+15;
        _answerBgView.height = _answerMoreBtn.hidden ? CGRectGetMaxY(_answerContentLabel.frame)+15 : CGRectGetMaxY(_answerMoreBtn.frame)+15;
    }
    CGFloat separateAskY = _askMoreBtn.hidden ? CGRectGetMaxY(_askBgView.frame) : CGRectGetMaxY(_askBgView.frame);
    CGFloat separateAnswerY = _answerMoreBtn.hidden ? CGRectGetMaxY(_answerBgView.frame) : CGRectGetMaxY(_answerBgView.frame);
    _separateView.frame = _answerBgView.hidden ? CGRectMake(0, separateAskY, kSWidth, 5) : CGRectMake(0, separateAnswerY, kSWidth, 5);
}

- (void)updatePraiseCount:(NSString *)praiseCount
{
    CGSize answerPraiseCountSize = [praiseCount sizeWithFont:12 LineSpacing:0 maxSize:CGSizeMake(CGFLOAT_MAX, 0)];
    _answerPraiseCountLabel.frame = CGRectMake(_answerPraiseBtn.x-5-answerPraiseCountSize.width, _answerPraiseBtn.y+8, answerPraiseCountSize.width, 13.5);
    _answerPraiseCountLabel.text = praiseCount;
}

#pragma mark - LazyLoadUI

- (UIView *)askBgView
{
    if (!_askBgView) {
        _askBgView = [[UIView alloc] init];
    }
    return _askBgView;
}

- (UIView *)answerBgView
{
    if (!_answerBgView) {
        _answerBgView = [[UIView alloc] init];
    }
    return _answerBgView;
}

- (UIView *)answerLineView
{
    if (!_answerLineView) {
        _answerLineView = [[UIView alloc] init];
    }
    return _answerLineView;
}

- (UIImageView *)askAvaterImageView
{
    if (!_askAvaterImageView) {
        _askAvaterImageView = [[UIImageView alloc] init];
    }
    return _askAvaterImageView;
}

- (UILabel *)askNameLabel
{
    if (!_askNameLabel) {
        _askNameLabel = [[UILabel alloc] init];
    }
    return _askNameLabel;
}

- (UILabel *)askTimeLabel
{
    if (!_askTimeLabel) {
        _askTimeLabel = [[UILabel alloc] init];
    }
    return _askTimeLabel;
}

- (UILabel *)askContentLabel
{
    if (!_askContentLabel) {
        _askContentLabel = [[UILabel alloc] init];
    }
    return _askContentLabel;
}

- (UIImageView *)answerAvaterImageView
{
    if (!_answerAvaterImageView) {
        _answerAvaterImageView = [[UIImageView alloc] init];
    }
    return _answerAvaterImageView;
}

- (UILabel *)answerNameLabel
{
    if (!_answerNameLabel) {
        _answerNameLabel = [[UILabel alloc] init];
    }
    return _answerNameLabel;
}

- (UILabel *)answerTimeLabel
{
    if (!_answerTimeLabel) {
        _answerTimeLabel = [[UILabel alloc] init];
    }
    return _answerTimeLabel;
}

- (UIButton *)answerCommentBtn
{
    if (!_answerCommentBtn) {
        _answerCommentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    return _answerCommentBtn;
}

- (UIButton *)answerPraiseBtn
{
    if (!_answerPraiseBtn) {
        _answerPraiseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    return _answerPraiseBtn;
}

- (UILabel *)answerContentLabel
{
    if (!_answerContentLabel) {
        _answerContentLabel = [[UILabel alloc] init];
    }
    return _answerContentLabel;
}

- (UIButton *)askMoreBtn
{
    if (!_askMoreBtn) {
        _askMoreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    return _askMoreBtn;
}

- (UIButton *)answerMoreBtn
{
    if (!_answerMoreBtn) {
        _answerMoreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    return _answerMoreBtn;
}

- (UIView *)separateView
{
    if (!_separateView) {
        _separateView = [[UIView alloc] init];
        _separateView.backgroundColor = UIColorFromString(@"246,246,246");
    }
    return _separateView;
}

- (UILabel *)answerPraiseCountLabel
{
    if (!_answerPraiseCountLabel) {
        _answerPraiseCountLabel = [[UILabel alloc] init];
    }
    return _answerPraiseCountLabel;
}

@end
