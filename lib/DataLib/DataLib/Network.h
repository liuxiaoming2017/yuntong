//
//  Network.h
//  PluginLib
//
//  Created by chenfei on 3/27/13.
//  Copyright (c) 2013 chenfei. All rights reserved.
//

#import <Foundation/Foundation.h>

void downloadData(NSString *urlString, BOOL useCache, void (^b)(NSData *data));
void downloadDataOrFromCache(NSString *urlString, void (^b)(NSData *data));
