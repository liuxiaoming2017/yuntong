//
//  VideoTableCell.h
//  FounderReader-2.5
//
//  Created by 黄柳姣 on 2017/11/29.
//

#import "TableViewCell.h"
#import "Article.h"
@interface VideoTableCell : TableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageV;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIView *videoBackView;
@property(nonatomic,strong) Article *article;
@end
