//
//  ColumnRequest.h
//  FounderReader-2.5
//
//  Created by chenfei on 4/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VersioningRequest.h"

@interface ColumnRequest : VersioningRequest {
    int parentColumnId;
    int linkId;
    BOOL isUseCache;//YES:设置栏目直接取上一次的缓存再请求新的数据到缓存
}

- (id)initWithParentColumnId:(int)parentColumnId;
+ (id)columnRequestWithParentColumnId:(int)parentColumnId;
@end
