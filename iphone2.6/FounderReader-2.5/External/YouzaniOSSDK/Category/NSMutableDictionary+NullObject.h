//
//  NSMutableDictionary+NullObject.h
//  CustomerNetwork
//
//  Created by 益达 on 15/11/19.
//  Copyright (c) 2015年 张伟. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (NullObject)

//区分一些的类别，添加标志性的函数名
- (void)addYZObject:(id)object forKey:(NSString *)key;

@end
