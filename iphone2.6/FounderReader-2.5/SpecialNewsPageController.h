//
//  SpecialNewsPageController.h
//  FounderReader-2.5
//
//  Created by ld on 14-7-31.
//
//

#import "DataChannelPageController.h"
#import "Article.h"
#import "EGORefreshTableHeaderView.h"
@interface SpecialNewsPageController : DataChannelPageController<EGORefreshTableHeaderDelegate>
{
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
    CGFloat topImageScale;
}

@property (nonatomic, retain) NSMutableArray *allArrays;
@property (nonatomic, retain) Article *speArticle;
@property (nonatomic, retain) NSString *speUrl;
@property (nonatomic, strong) Column *column;
@end
