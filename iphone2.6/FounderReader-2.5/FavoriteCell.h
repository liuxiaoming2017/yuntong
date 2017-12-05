//
//  FavoriteCell.h
//  FounderReader-2.5
//
//  Created by chenfei on 6/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MiddleCell.h"

@class Article;

@interface FavoriteCell : MiddleCell

-(void)configMyFavoriteArticle:(Article *)article;
@end
