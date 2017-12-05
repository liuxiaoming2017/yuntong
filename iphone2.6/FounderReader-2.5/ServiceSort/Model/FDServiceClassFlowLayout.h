//
//  FDServiceClassFlowLayout.h
//  FounderReader-2.5
//
//  Created by mac on 2017/7/11.
//
//

#import <UIKit/UIKit.h>

@interface FDServiceClassFlowLayout : UICollectionViewFlowLayout
/** 每一行之间的间距 */
@property (nonatomic,assign) CGFloat rowMargin;
/** 每一列之间的间距 */
@property (nonatomic,assign) CGFloat columnMargin;
/** 左右边距 */
@property (nonatomic,assign) CGFloat leftRightMargin;
/** 上边距 */
@property (nonatomic,assign) CGFloat topMargin;
/** cell宽 */
@property (nonatomic,assign) CGFloat itemWidth;
/** cell高 */
@property (nonatomic,assign) CGFloat itemHeight;
/** 默认的列数 */
@property (nonatomic,assign) int columsCount;
@end
