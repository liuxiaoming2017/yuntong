//
//  PoliticalCollectionCell.h
//  FounderReader-2.5
//
//  Created by yanbf on 16/7/13.
//
//

#import "ImageViewCf.h"
#import "Column.h"
@interface PoliticalCollectionCell : UITableViewCell
@property (nonatomic, strong) ImageViewCf *thumbnail;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *summaryLabel;
-(void)configPoliticalWithColumn:(Column *)column;
@end
