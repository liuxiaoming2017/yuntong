//
//  NSArray+Plist.h
//  FounderReader-2.5
//
//  Created by ld on 14-9-5.
//
//

#import <Foundation/Foundation.h>

@interface NSArray (Plist)

-(BOOL)writeToPlistFile:(NSString*)filename;

+(NSArray*)readFromPlistFile:(NSString*)filename;
@end
