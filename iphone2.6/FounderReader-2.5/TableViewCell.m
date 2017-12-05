//
//  TableViewCell.m
//  FounderReader-2.5
//
//  Created by chenfei on 4/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TableViewCell.h"

@implementation TableViewCell
@synthesize isPDF;
@synthesize articeType;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.isPDF = NO;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configWithTitle:(NSString *)title summary:(NSString *)summary thumbnailUrl:(NSString *)url columnId:(int)columnId
{

}

- (void)configWithTitle:(NSString *)title summary:(NSString *)summary thumbnailUrl:(NSString *)url column:(Column *)column
{
    
}

- (void)configWithTitle:(NSString *)title summary:(NSString *)summary date:(NSString *)date thumbnailUrl:(NSString *)url columnId:(int)columnId{
    
    [self configWithTitle:title summary:summary thumbnailUrl:url columnId:columnId];
}

-(void)configGroupImageCellWithArticle:(Article *)article
{
    
}
-(void)configGroupImageCellWithTitle:(NSString *)title groupImage:(NSString *)groupImage columnId:(int)columnId
{
    
}
- (void)configWithTitle:(NSString *)title summary:(NSString *)summary date:(NSString *)date thumbnailUrl:(NSString *)url columnId:(int)columnId finished:(BOOL)finished
{
    
}

-(void)configMiddleCellWithArticle:(Article *)article
{

}
-(void)configSpecialCellWithIsArticle:(Article *)article
{
    
}
-(void)configImageCellWithArticle:(Article *)artice{
    
}
-(void)configActivityAndVoteWithArticle:(Article*)article
{
    
}
-(void)configSearchMiddleCellWithArticle:(Article *)article{
    
}
//大图


-(void)configBigimageWithArticle:(Article *)article
{
    
}

//活动
- (void)configActivityWithArticle:(Article *)article
{
    
}

- (void)setArticle:(Article *)article
{
    _article = article;
    /*
     * 隐藏阅读数
     * 在全局显示阅读数下，隐藏栏目才有效，不存在全局隐藏而设置某些栏目显示，只能全局显示设置某些栏目隐藏
     */
    NSArray *groupArry = [article.groupImageUrl componentsSeparatedByString:@","];
    // 图集稿件和三个标题图图文
    if ((!article.isBigPic && article.articleType == ArticleType_IMAGE) || (!article.isBigPic && article.articleType == ArticleType_PLAIN && [groupArry count] > 1))
        [self setGroupCellHideReadCount];
    else
        [self setHideReadCount];
}

- (void)setHideReadCount
{
    // 过渡到子类
}

- (void)setGroupCellHideReadCount
{
    // 过渡到子类
}

@end
