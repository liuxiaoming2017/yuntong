//
//  FDVerticalCollectionCell.h
//  FounderReader-2.5
//
//  Created by mac on 2017/7/11.
//
//

#import <UIKit/UIKit.h>
#import "Column.h"
typedef NS_ENUM(NSUInteger, SHOWTYPE) {
    SHOWTYPE_ONE = 1,
    SHOWTYPE_TWO,
    SHOWTYPE_THREE,
    SHOWTYPE_FOUR,
};
@interface FDVerticalCollectionCell : UICollectionViewCell
@property (nonatomic,assign)SHOWTYPE showType;
@property (nonatomic,strong)Column * column;
@end
