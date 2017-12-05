//
//  NJSquarePageController.h
//  FounderReader-2.5
//
//  Created by lihuiguo on 15/8/31.
//
// 政情栏目页面

#import "DataChannelPageController.h"
#import "Article.h"
@interface PoliticalAboutController : DataChannelPageController <UITableViewDataSource, UITableViewDelegate>
{
    UITableView *tableView;
    NSMutableArray *bottomColumns;
}
@property (nonatomic, retain) NSMutableArray *topArticles;
@property (nonatomic, retain) Article *aboutArticle;
@property (nonatomic, retain) UIView *topView;
@property (nonatomic, retain) UILabel *introduction; // 简介
@property (nonatomic, retain) UIButton *aboutNew;    //相关新闻
@property (nonatomic, retain) UIButton *detailNew;   //履历介绍
@property (nonatomic, retain) ImageViewCf *topImageView;
@property (nonatomic, retain) NSString *content;
@property (nonatomic, retain) UIWebView *webView;

@end
