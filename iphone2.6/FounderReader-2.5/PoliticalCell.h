//
//  PoliticalCell.h
//  FounderReader-2.5
//
//  Created by yanbf on 16/7/13.
//
//

#import "ImageViewCf.h"
#import "Column.h"
@interface PoliticalCell : UITableViewCell
@property (nonatomic, strong) UIView *footSeq;
@property (nonatomic, strong) ImageViewCf *thumbnail;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *summaryLabel;
@property (nonatomic, strong) UILabel *moreLabel;
//政情
-(void)configPoliticalWithColumn:(Column *)column;
@end
