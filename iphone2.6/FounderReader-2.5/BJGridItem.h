//
//  BJGridItem.h
//  :
//
//  Created by bupo Jung on 12-5-15.
//  Copyright (c) 2012年 Wuxi Smart Sencing Star. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum{
    BJGridItemNormalMode = 0,
    BJGridItemEditingMode = 1,
}BJMode;
@protocol BJGridItemDelegate;
@interface BJGridItem : UIView{
    UIImage *normalImage;
    UIImage *editingImage;
    @public NSString *titleText;
    BOOL isEditing;
    BOOL isRemovable;
    UIButton *deleteButton;
//    UIButton *button;
    NSInteger index;
    NSInteger groupId;
    CGPoint point;//long press point
    id<BJGridItemDelegate>  _delegate;
}
@property(nonatomic) BOOL isEditing;
@property(nonatomic) BOOL isRemovable;
@property(nonatomic) NSInteger index;
@property (nonatomic,retain) UIButton *button;
@property (nonatomic,retain) UILabel *descriptionLabel;
@property(nonatomic) int ID;
@property(nonatomic, retain) id<BJGridItemDelegate> delegate;
@property(nonatomic,retain)NSString *descStr;
@property(nonatomic,retain)UIImageView *pluView;


- (id) initWithTitle:(NSString *)title withImageName:(NSString *)imageName atIndex:(NSInteger)aIndex editable:(BOOL)removable groupid:(NSInteger) groupid ID:(int) _id currentName:(NSString*)currentName;
- (void) enableEditing;
- (void) disableEditing;
@end
@protocol BJGridItemDelegate <NSObject>

- (void) gridItemDidClicked:(BJGridItem *) gridItem;
- (void) gridItemDidEnterEditingMode:(BJGridItem *) gridItem;
- (void) gridItemDidDeleted:(BJGridItem *) gridItem atIndex:(NSInteger)index;
- (void) gridItemDidMoved:(BJGridItem *) gridItem withLocation:(CGPoint)point moveGestureRecognizer:(UILongPressGestureRecognizer*)recognizer;
- (void) gridItemDidMoving:(BJGridItem *) gridItem withLocation:(CGPoint)point moveGestureRecognizer:(UILongPressGestureRecognizer*)recognizer;
- (void) gridItemDidEndMoved:(BJGridItem *) gridItem withLocation:(CGPoint)point moveGestureRecognizer:(UILongPressGestureRecognizer*) recognizer;
@end