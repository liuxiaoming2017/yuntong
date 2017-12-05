//
//  ForumDetailFootView.h
//  FounderReader-2.5
//
//  Created by 袁野 on 15/8/18.
//
//

#import <UIKit/UIKit.h>

@protocol FootViewDelegate;

@protocol SubscribeDelegateSub <NSObject>
@optional
- (void)sendColumnsDetaile:(NSArray *)array;

- (void)sendContentColumns;
@end


@interface ForumDetailFootView : UIView
{
    int _more;
    UIView *_hideView;
    UIView *_viewFont;
    UILabel *_lableFont;
}
@property(nonatomic, assign) BOOL isGreatClose;
@property(nonatomic, assign) id<SubscribeDelegateSub> delegateSub;
@property(nonatomic,retain) UIWebView *webView;
@property(nonatomic, assign) id<FootViewDelegate> delegate;
@property(nonatomic,retain) UIButton *commentBtn;
@property(nonatomic,retain) UILabel *commentLabel;
@property(nonatomic,retain) UIButton *greetBtn;
@property(nonatomic,retain) UIButton *collectBtn;
@property(nonatomic,retain) UILabel *greetLabel;
@property(nonatomic ,retain)UIButton *moreBtn;
@property(nonatomic ,retain)UIButton *darkBtn;
@property(nonatomic ,retain)UIButton *shareBtn;
@property(nonatomic,retain) UIButton *viewCommentBtn;
@property(nonatomic,retain) UIButton *backBtn;
@property(nonatomic,assign) int extCount;

//-(void)disableCommentBtn;//不让评论
//-(void)disablePraiseBtn; //不让点赞

- (void)hideCommentButton;
- (void)hidePraiseButton;
- (void)hideCollectButton;


//根据count数量创建底部按钮
- (instancetype)initWithCount:(NSInteger)count commentClose:(BOOL)commentClose greatClose:(BOOL)greatClose;
@end


@protocol FootViewDelegate<NSObject>
@optional
-(void)collectItemClick;//收藏
-(void)greetItemClick;//点赞
-(void)commentItemClick;//评论
-(void)fontItemClick:(int)size;//字号
-(void)shareClick;//分享
-(void)commentReadClick;//查看评论
- (void)goBothBack;
- (void)ForumCommentItemClicked;
@end
