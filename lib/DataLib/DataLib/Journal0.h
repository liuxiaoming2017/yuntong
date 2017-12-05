//
//  Journal.h
//  DataLib
//
//  Created by chenfei on 4/10/13.
//  Copyright (c) 2013 chenfei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Journal0 : NSObject
@property(nonatomic, assign) int journalID;
@property(nonatomic, retain) NSString *journalName;

+ (NSArray *)journalsFromArray:(NSArray *)array;

@end
