//
//  CommentViewControllerGuo.h
//  FounderReader-2.5
//
//  Created by ld on 14-2-13.
//
//
#import <UIKit/UIKit.h>
#import "Article.h"
#import "FDMyTopic.h"
#import "FDTopicPlusDetaiHeaderlModel.h"

typedef void (^FootHandleBlock)(NSString *comment, NSMutableArray *photos);
typedef void (^CancelHandleBlock)(void);
typedef void (^SuccessCommentBlock)(void);

@protocol CommentViewDelegate;
@interface CommentViewControllerGuo : UIViewController <UIAlertViewDelegate,UITextViewDelegate,UITextFieldDelegate> {
    Article *article;
    NSInteger current;
    NSInteger commentID;
    int parentUserID;
}

@property (retain, nonatomic) Article *article;
@property (retain, nonatomic)  UITextView *textView;
@property (retain, nonatomic) UIButton *submitButton;
@property (retain, nonatomic) UIButton *cancelButton;
@property (assign, nonatomic) NSInteger current;
@property (assign, nonatomic) NSInteger commentID;
@property (assign, nonatomic) NSInteger rootID;
@property (retain, nonatomic) NSString *urlStr;
@property (assign, nonatomic) int parentUserID;
@property(nonatomic, assign) id<CommentViewDelegate> delegate;
@property (nonatomic,assign)int commentScore;
@property (nonatomic, assign) NSInteger sourceType;
@property (nonatomic, retain) NSString *fullColumn;
@property(nonatomic, strong)UIButton *photosButton;
@property(nonatomic, strong)UIView *backgroundView;
@property(nonatomic, copy)CancelHandleBlock cancelHandleBlock;
@property(nonatomic, copy)SuccessCommentBlock successCommentBlock;
@property(nonatomic, strong)NSMutableArray *modifyPhotoDics;

- (instancetype)initWithMyTopic:(FDMyTopic *)myTopic DetailModel:(FDTopicPlusDetaiHeaderlModel *)detailModel;

- (void)submitButtonClicked:(id)sender;

- (void)setupCommentViewWith:(NSString *)title SubTitle:(NSString *)subtitle IsTopic:(BOOL)isTopic HandleBlock:(FootHandleBlock)handleBlock;

- (void)setupCommentViewWithCollectionView:(UICollectionView *)collectionView;

- (void)commitMyTopicModify;

- (void)cancelMyTopicModify;

@property(nonatomic,assign) BOOL isPDF;

@end
@protocol CommentViewDelegate <NSObject>

@optional
- (void)reloadTableView;

@end
