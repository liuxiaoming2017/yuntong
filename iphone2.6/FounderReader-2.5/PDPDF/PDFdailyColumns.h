//
//  PDFdailyColumns.h
//  FounderReader-2.5
//
//  Created by ld on 16/1/14.
//
//

#import <Foundation/Foundation.h>

@class PDFPageDataModel;

@interface PDFdailyColumns : NSObject

@property(nonatomic,retain) PDFPageDataModel *pageInfo;
@property(nonatomic,retain) NSArray *articlesArry;

@end
