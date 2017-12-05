//
//  OpenGoodsServiceProtocol.h
//  CustomerNetwork
//
//  Created by 益达 on 15/11/19.
//  Copyright (c) 2015年 张伟. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YZSDKDefination.h"

typedef NS_ENUM(NSInteger,YZGoodsState) {
    YZGoodsOnSaleState,//出售中的商品
    YZGoodsDownShelvedState,//已下架的商品
    YZGoodsSoldOutState//已售罄的商品
};

typedef NS_ENUM(NSInteger,YZGoodsOrderByWay) {
    YZGOodsORderByModifyAscWay,//修改的升序
    YZGOodsORderByModifyDescWay,//修改的降序
    YZGOodsORderByCreateAscWay,//创建的升序
    YZGOodsORderByCreateDescWay//创建的降序
    
};

@protocol OpenGoodsServiceProtocol <NSObject>
/**
 *  获取有赞商品列表
 *  http://open.koudaitong.com/doc/api?method=kdt.items.onsale.get
 *  http://open.koudaitong.com/doc/api?method=kdt.items.inventory.get[文档说明]
 *
 *  @param field     返回商品信息的字段
 *  @param search    搜索字段，只支持title搜索
 *  @param state     商品所处的状态，出售中，已下架，已售罄
 *  @param tag_id    商品的标签id，也就是商品的分组
 *  @param page_no   页码
 *  @param page_size 每页的数据
 *  @param order_by  排序方式
 *  @param callback
 */

- (void) getGoodsItemsFields:(NSString *) field
                      search:(NSString *) search
                  goodsState:(YZGoodsState) state
                       tagId:(NSString *) tag_id
                      pageNO:(NSString *) page_no
                    pageSize:(NSString *) page_size
                  orderByWay:(YZGoodsOrderByWay) orderByWay
                    callback:(OpenServiceCallBack)callback;
            
/**
 *  获取商品的详细信息
 *  http://open.koudaitong.com/doc/api?method=kdt.item.get[文档说明]
 *  @param field     返回商品信息的字段
 *  @param goodId    商品的id
 *  @param goodAlias 商品的别称  注意：商品id和商品别称不能同时为空
 *  @param callback
 */
- (void) getGoodItemField:(NSString *)field
                   goodId:(NSString *) goodId
                goodAlias:(NSString *) goodAlias
                 callback:(OpenServiceCallBack)callback;

/**
 *  获取商品自定义标签，一次性获取所有标签，排序是按照序号排序
 *  http://open.koudaitong.com/doc/api?method=kdt.itemcategories.tags.get[文档说明]
 *  @param isSort   是否需要排序
 *  @param callback
 */
- (void) getItemCategoriesTagsSort:(BOOL) isSort
                          callback:(OpenServiceCallBack)callback;

/**
 *  获取商品自定义标签  分页接口，是否排序，排序仅仅支持YZGOodsORderByCreateAscWay和YZGOodsORderByCreateDescWay
 *  http://open.koudaitong.com/doc/api?method=kdt.itemcategories.tags.getpage[文档说明]
 *  @param pageNO     页码
 *  @param pageSize   每页条数
 *  @param orderByWay 排序方式
 */
- (void) getItemCategoriesTagsPageNo:(NSString *) pageNO
                            pageSize:(NSString *) pageSize
                          orderByWay:(YZGoodsOrderByWay) orderByWay
                            callback:(OpenServiceCallBack) callback;


@end
