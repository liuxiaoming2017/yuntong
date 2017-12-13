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
    BOOL isGovAffair;
    
}

- (id)initWithParentColumnId:(int)parentColumnId;
+ (id)columnRequestWithParentColumnId:(int)parentColumnId;

+ (id)govAffairRequestWithSid:(NSString *)str;

+ (id)govAffairRequestSubscribeWithCid:(int)cid uid:(NSString *)uid withStr:(NSString *)str;

+ (id)govAffairRequestWithuid:(NSString *)str;

@end
