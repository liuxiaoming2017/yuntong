//
//  FDPickerView.h
//  FounderReader-2.5
//
//  Created by Julian on 2017/3/9.
//
//

#import <UIKit/UIKit.h>

typedef void(^PickerViewBlock)(NSInteger selectRow);

@interface FDPickerView : UIView

+ (instancetype)pickerViewWithFrame:(CGRect)frame Title:(NSString *)title Items:(NSArray *)items;
@property (nonatomic, copy)PickerViewBlock pickerViewBlock;

@end
