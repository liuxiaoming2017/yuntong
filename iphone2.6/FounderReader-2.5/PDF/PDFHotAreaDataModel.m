//
//  PDFHotAreaDataModel.m
//  PDFReader
//
//  Created by ld on 13-12-4.
//  Copyright (c) 2013年 chenfei. All rights reserved.
//

#import "PDFHotAreaDataModel.h"

@implementation PDFHotAreaDataModel

@synthesize hotArea,articleID,articleTitle;

-(void)dealloc
{
    self.hotArea = nil;
    self.articleID = nil;
    self.articleTitle = nil;
//    [super dealloc];
}
+(NSArray *)hotAreasFromPage:(NSArray *)arry
{
    NSMutableArray *arryM = [[NSMutableArray alloc]init];
    for (NSDictionary *dic in arry) {
        PDFHotAreaDataModel *hot = [[PDFHotAreaDataModel alloc]init];
        hot.articleTitle = [dic objectForKey:@"ArticleTitle"];
        hot.articleID = [dic objectForKey:@"articleID"];
        hot.hotArea = [dic objectForKey:@"mapping"];
        hot.contentUrl = @"";
        [arryM addObject:hot];
    }
    return arryM;
    
}

@end
