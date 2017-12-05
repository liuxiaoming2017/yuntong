//
//  FDServiseColumnRequest.h
//  FounderReader-2.5
//
//  Created by snitsky on 2016/11/25.
//
//

#import "VersioningRequest.h"

@interface FDServiseColumnRequest : VersioningRequest {
    int parentColumnId;
    int linkId;
    BOOL isUseCache; //YES:设置栏目直接取上一次的缓存再请求新的数据到缓存
}

- (id)initWithParentColumnId:(int)parentColumnId;
+ (id)columnRequestWithParentColumnId:(int)parentColumnId;
@end
