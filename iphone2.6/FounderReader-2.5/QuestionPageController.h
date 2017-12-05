//
//  QuestionPageController.h
//  FounderReader-2.5
//
//  Created by ld on 15-4-23.
//
//
@protocol QuestionPageDelegate <NSObject>

@optional
-(void)LoginPage;
@end
#import "InformPageController.h"
#import "Column.h"
@interface QuestionPageController : InformPageController
{
    BOOL checkArrow;
    UIButton *checkBox;
}
@property(nonatomic, retain) NSArray *columns;
@property(nonatomic,retain) Column *currentColumn;
@property(nonatomic,retain) UIButton *photoButton;
@property(nonatomic,assign) id<QuestionPageDelegate>delegate;
@property(nonatomic,retain) NSString *columnName;
@property(nonatomic,assign) int columnId;
@property(nonatomic,retain) UIImageView *contentBgView;
@property(nonatomic,retain) UIImageView *subjectBgView;
@property(nonatomic,retain) UIImageView *phBgView;
@property(nonatomic,retain) UIView *userView;
@property(nonatomic,retain) UIButton *smallButton;
@property (nonatomic, retain) UILabel *starlablePhone;
@property (nonatomic, retain) UILabel *starlableName;
- (void)reloadPreviewImages;
- (void)clearForm;
-(void)showLoginPage;
-(void)saveUserInfo;
- (UIImage*) thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time;
-(NSString *)textForKeyInform:(NSString *)key;
- (BOOL)validateForm;

-(void)addDeleteButton:(UIView *)view index:(NSInteger)index;
-(void)configPhotoButtonFrame;
@end
