//
//  FDAreaPickerViewController.h
//  FounderReader-2.5
//
//  Created by snitsky on 2017/5/10.
//
//

#import <UIKit/UIKit.h>
#import "FDAreaPickerModel.h"

typedef void(^FDAreaPickerBlock)(FDAreaPickerModel *model);

@interface FDAreaPickerViewController : UIViewController

- (instancetype)initWithDefaultModel:(FDAreaPickerModel *)model FDAreaPickerBlock:(FDAreaPickerBlock)block;

@end
