//
//  Attachment.h
//  FounderReader-2.5
//
//  Created by chenfei on 5/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Attachment : NSObject {
    int attId;
    int picType;
    NSString *imageUrl;
    NSString *title;
    NSString *description;
    
}

@property(nonatomic, assign) int attId;
@property(nonatomic, assign) int picType;
@property(nonatomic, retain) NSString *imageUrl;
@property(nonatomic, retain) NSString *title;
@property(nonatomic, retain) NSString *description;

+ (NSArray *)attachmentsFromArray:(NSArray *)array;

@end
