//
//  NSArray+Plist.m
//  FounderReader-2.5
//
//  Created by ld on 14-9-5.
//
//

#import "NSArray+Plist.h"

@implementation NSArray (Plist)

//-(BOOL)writeToPlistFile:(NSString*)filename{
//    NSData * data = [NSKeyedArchiver archivedDataWithRootObject:self];
//    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString * documentsDirectory = [paths objectAtIndex:0];
//    NSString * path = [documentsDirectory stringByAppendingPathComponent:filename];
//    BOOL didWriteSuccessfull = [data writeToFile:path atomically:YES];
//    return didWriteSuccessfull;
//}
//
//+(NSArray*)readFromPlistFile:(NSString*)filename{
//    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString * documentsDirectory = [paths objectAtIndex:0];
//    NSString * path = [documentsDirectory stringByAppendingPathComponent:filename];
//    NSData * data = [NSData dataWithContentsOfFile:path];
//    return  [NSKeyedUnarchiver unarchiveObjectWithData:data];
//}


-(BOOL)writeToPlistFile:(NSString*)filePath{
    NSData * data = [NSKeyedArchiver archivedDataWithRootObject:self];
    BOOL didWriteSuccessfull = [data writeToFile:filePath atomically:YES];
    return didWriteSuccessfull;
}

+(NSArray*)readFromPlistFile:(NSString*)filePath{

    NSData * data = [NSData dataWithContentsOfFile:filePath];
    return  [NSKeyedUnarchiver unarchiveObjectWithData:data];
}
@end
