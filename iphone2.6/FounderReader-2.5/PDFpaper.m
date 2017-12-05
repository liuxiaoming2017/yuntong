//
//  PDFpaper.m
//  FounderReader-2.5
//
//  Created by ld on 16/1/13.
//
//

#import "PDFpaper.h"

@implementation PDFpaper

@synthesize paperId,paperCode,paperName,iconBig,iconSmall;

+ (NSArray *)papersFromArray:(NSArray *)array
{
    NSMutableArray *papers = [[NSMutableArray alloc] initWithCapacity:array.count];
    for (NSDictionary *dict in array) {
        PDFpaper *paper = [[PDFpaper alloc] init];
        paper.paperId = [dict objectForKey:@"id"];
        paper.paperCode = [dict objectForKey:@"code"];
        paper.paperName = [dict objectForKey:@"name"];
        paper.iconSmall = [dict objectForKey:@"iconSmall"];
        paper.iconBig = [dict objectForKey:@"iconBig"];
        [papers addObject:paper];
       
    }
    return papers;
}
@end
