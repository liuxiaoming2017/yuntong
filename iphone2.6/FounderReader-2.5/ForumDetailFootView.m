//
//  ForumDetailFootView.m
//  FounderReader-2.5
//
//  Created by on 15/8/18.
//
//

#import "ForumDetailFootView.h"
#import "UIView+Extention.h"
#import "QuadCurveMenuItem.h"
#import "ColumnBarConfig.h"
#import "AppConfig.h"

#define FullSize CGRectMake(0,0,[UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)
#define kScale kSWidth/375.0
#define FOOD_HW 49
#define MARGIN 5
@interface ForumDetailFootView()<UITextViewDelegate>
@property (nonatomic, retain) UIView *bgview;
@property (nonatomic, retain) UIView *contentView;
@property (nonatomic, retain) UITextView *contentText;
@property (nonatomic, retain) UIButton *sender;
@property (nonatomic, assign) NSInteger IMG_COUNT;
@end
@implementation ForumDetailFootView
@synthesize webView,delegate,greetLabel,extCount,IMG_COUNT,delegateSub;
@synthesize commentLabel, viewCommentBtn, backBtn;
- (instancetype)initWithCount:(NSInteger)count commentClose:(BOOL)commentClose greatClose:(BOOL)greatClose
{
    self = [super init];
    IMG_COUNT = count;
    if (self)
    {
        self.frame = CGRectMake(0, kSHeight -  kTabBarHeight , kSWidth , kTabBarHeight);
        //返回按钮
        CGFloat widthSpan = 70;
        if(kSWidth < 375){
            widthSpan = 45;
        }
        self.backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.backBtn.tag = 1001;
        self.backBtn.frame = CGRectMake(5, 10, 30, 30);
        [self.backBtn setImage:[UIImage imageNamed:@"btn_back_normal"] forState:UIControlStateNormal];
        [self.backBtn setImage:[UIImage imageNamed:@"btn_back_press"] forState:UIControlStateHighlighted];
        [self.backBtn addTarget:self action:@selector(backClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.backBtn];
        //收藏按钮
        self.collectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.collectBtn.tag = 1002;
        self.collectBtn.frame = CGRectMake(kSWidth-50, 10, 30, 30);
        [self.collectBtn setImage:[UIImage imageNamed:@"toolbar_collect_normal"] forState:UIControlStateNormal];
        [self.collectBtn setImage:[UIImage imageNamed:@"toolbar_collect_normal"] forState:UIControlStateHighlighted];
        [self.collectBtn addTarget:self action:@selector(collectClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.collectBtn];
        //分享按钮
        self.shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.shareBtn.tag = 1003;
        self.shareBtn.frame = CGRectMake(kSWidth-50-widthSpan, 10, 30, 30);
        [self.shareBtn setImage:[UIImage imageNamed:@"toolbar_share_normal"] forState:UIControlStateNormal];
        [self.shareBtn setImage:[UIImage imageNamed:@"toolbar_share_press"] forState:UIControlStateHighlighted];
        [self.shareBtn addTarget:self action:@selector(shareClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.shareBtn];
        //点赞按钮
        self.greetBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.greetBtn.tag = 1004;
        self.greetBtn.frame = CGRectMake(kSWidth-50-widthSpan*2, 10, 30, 30);
        [self.greetBtn setImage:[UIImage imageNamed:@"toolbar_love_normal"] forState:UIControlStateNormal];
        [self.greetBtn setImage:[UIImage imageNamed:@"toolbar_love_press"] forState:UIControlStateHighlighted];
        [self.greetBtn addTarget:self action:@selector(praiseClick) forControlEvents:UIControlEventTouchUpInside];
        if(greatClose)
            self.greetBtn.enabled = NO;
        [self addSubview:self.greetBtn];
        greetLabel = [[UILabel alloc]init];
        greetLabel.textColor = [UIColor lightGrayColor];
        greetLabel.userInteractionEnabled = YES;
        greetLabel.textAlignment = NSTextAlignmentCenter;
        greetLabel.font = [UIFont systemFontOfSize:10];
        greetLabel.frame =CGRectMake(self.greetBtn.frame.origin.x + 13, 12, 30, 10);
        [self addSubview:greetLabel];
        //写评论按钮
        self.commentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.commentBtn.tag = 0;
        self.commentBtn.frame = CGRectMake(kSWidth-50-widthSpan*3, 10, 30, 30);
        [self.commentBtn setImage:[UIImage imageNamed:@"toolbar_comment_normal"] forState:UIControlStateNormal];
        [self.commentBtn setImage:[UIImage imageNamed:@"toolbar_comment_press"] forState:UIControlStateHighlighted];
        if(commentClose)
            self.commentBtn.enabled = NO;
        [self.commentBtn addTarget:self action:@selector(commentClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.commentBtn];
        
        //查看评论按钮
        self.viewCommentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.viewCommentBtn.tag = 0;
        self.viewCommentBtn.frame = CGRectMake(kSWidth-50-widthSpan*4, 10, 30, 30);
        [self.viewCommentBtn setImage:[UIImage imageNamed:@"toolbar_comment_new"] forState:UIControlStateNormal];
        [self.viewCommentBtn setImage:[UIImage imageNamed:@"toolbar_comment_new"] forState:UIControlStateHighlighted];
        [self.viewCommentBtn addTarget:self action:@selector(viewCommentClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.viewCommentBtn];
        if([[AppConfig sharedAppConfig].sid compare:@"xjdcb"] != NSOrderedSame){
            self.viewCommentBtn.hidden = YES;
        }
        
        commentLabel = [[UILabel alloc]init];
        commentLabel.textColor = [UIColor lightGrayColor];
        commentLabel.userInteractionEnabled = YES;
        commentLabel.textAlignment = NSTextAlignmentCenter;
        commentLabel.font = [UIFont systemFontOfSize:10];
        commentLabel.frame = CGRectMake(self.commentBtn.frame.origin.x + 13, 12, 30, 10);
        [self addSubview:commentLabel];
        
        if(self.viewCommentBtn.hidden){
            commentLabel.frame =CGRectMake(self.commentBtn.frame.origin.x + 13, 12, 30, 10);
        }
        else{
            commentLabel.frame =CGRectMake(self.viewCommentBtn.frame.origin.x + 13, 12, 30, 10);
        }
    }
    return self;
}

//返回操作
-(void)backClick{
    if ([self.delegate respondsToSelector:@selector(goBothBack)])
        [self.delegate goBothBack];
}
//写评论
-(void)commentClick{
    if ([delegate respondsToSelector:@selector(commentItemClick)])
        [delegate commentItemClick];
}
//收藏
-(void)collectClick{
    if ([delegate respondsToSelector:@selector(collectItemClick)])
        [delegate collectItemClick];
}
//点赞
-(void)praiseClick{
    if ([delegate respondsToSelector:@selector(greetItemClick)])
        [delegate greetItemClick];
}
//分享
-(void)shareClick{
    if ([delegate respondsToSelector:@selector(shareClick)])
        [delegate shareClick];
}
//查看评论
-(void)viewCommentClick{
    if ([delegate respondsToSelector:@selector(commentReadClick)])
        [delegate commentReadClick];
}
//不让评论方法
-(void)disableCommentBtn{
    self.commentBtn.enabled = NO;
}

//不让点赞方法
-(void)disablePraiseBtn{
    self.greetBtn.enabled = NO;
}

- (void)hideCommentButton {
    self.commentBtn.hidden = YES;
    self.commentLabel.hidden = YES;
}

- (void)hidePraiseButton {
    self.greetBtn.hidden = YES;
    self.greetLabel.hidden = YES;
}

- (void)hideCollectButton {
    self.collectBtn.hidden = YES;
    self.shareBtn.x = self.collectBtn.x;
}

- (void)addPostCommentView {
    
}

@end
