//
//  PoliticalCell.h
//  FounderReader-2.5
//
//  Created by yanbf on 16/7/13.
//
//

#import "Article.h"
@interface PoliticalAboutCell : UITableViewCell
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UIView *footSeq;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *readerLabel;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) Article *article;
@property (nonatomic, assign) BOOL  hideReadCount;
//政情
-(void)configPoliticalAboutWithArticle:(Article *)article;
@end
