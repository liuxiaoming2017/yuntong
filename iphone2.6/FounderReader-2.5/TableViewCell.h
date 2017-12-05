//
//  TableViewCell.h
//  FounderReader-2.5
//
//  Created by chenfei on 4/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Column.h"
#import "Article.h"

@interface TableViewCell : UITableViewCell
@property(nonatomic,retain) Article *article;
@property(assign,nonatomic) BOOL isPDF;
@property(nonatomic,assign) NSInteger articeType;
@property(nonatomic,retain) UIImageView *cellBgView;
@property(nonatomic,assign) BOOL isAppearReadCount;

- (void)configWithTitle:(NSString *)title summary:(NSString *)summary thumbnailUrl:(NSString *)url columnId:(int)columnId;


- (void)configWithTitle:(NSString *)title summary:(NSString *)summary date:(NSString *)date thumbnailUrl:(NSString *)url columnId:(int)columnId;

- (void)configWithTitle:(NSString *)title summary:(NSString *)summary thumbnailUrl:(NSString *)url column:(Column *)column;

- (void)configWithTitle:(NSString *)title summary:(NSString *)summary date:(NSString *)date thumbnailUrl:(NSString *)url columnId:(int)columnId finished:(BOOL)finished;

-(void)configGroupImageCellWithTitle:(NSString *)title groupImage:(NSString *)groupImage columnId:(int)columnId;

//已经读过
-(void)configMiddleCellWithArticle:(Article *)article;
-(void)configSpecialCellWithIsArticle:(Article *)article;
-(void)configGroupImageCellWithArticle:(Article *)article;

-(void)configImageCellWithArticle:(Article *)artice;

//大图
-(void)configBigimageWithArticle:(Article *)article;
-(void)configSearchMiddleCellWithArticle:(Article *)article;
//活动
- (void)configActivityAndVoteWithArticle:(Article *)article;
//互动+
- (void)configQuestionsAndAnswersWithArticle:(Article *)article;
@end
