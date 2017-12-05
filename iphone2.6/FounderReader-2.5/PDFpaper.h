//
//  PDFpaper.h
//  FounderReader-2.5
//
//  Created by ld on 16/1/13.
//
//

#import <Foundation/Foundation.h>

@interface PDFpaper : NSObject

@property(nonatomic,retain) NSString *paperId;
@property(nonatomic,retain) NSString *paperCode;
@property(nonatomic,retain) NSString *paperName;
@property(nonatomic,retain) NSString *iconSmall;
@property(nonatomic,retain) NSString *iconBig;

+ (NSArray *)papersFromArray:(NSArray *)array;
@end
