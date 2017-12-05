//
//  PDFHotAreaDataModel.h
//  PDFReader
//
//  Created by ld on 13-12-4.
//  Copyright (c) 2013年 chenfei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PDFHotAreaDataModel : NSObject
@property(nonatomic,retain) NSString *articleID;
@property(nonatomic,retain) NSString *articleTitle;
@property(nonatomic,retain) NSArray *hotArea;
@property(nonatomic,retain) NSString *contentUrl;
@property(nonatomic,assign) int *version;

+(NSArray *)hotAreasFromPage:(NSArray *)arry;
@end
