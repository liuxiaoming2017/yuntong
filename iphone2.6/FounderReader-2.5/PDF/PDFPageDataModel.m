//
//  PDFPageDataModel.m
//  FounderReader-2.5
//
//  Created by ld on 13-12-5.
//
//

#import "PDFPageDataModel.h"
#import "PDFHotAreaDataModel.h"
#import "Article.h"

@implementation PDFPageDataModel
@synthesize hotAreaList,articlesList;
@synthesize pageId;
@synthesize pageHeight,pageWidth;
@synthesize pageTitle;
@synthesize pagePic;

-(void)dealloc
{
    self.hotAreaList = nil;
    self.articlesList = nil;
    self.pageId = nil;
    self.pageTitle = nil;
    self.pagePic = nil;

}

+(NSArray *)pagesFromArray:(NSArray *)arry
{
    NSMutableArray *arryM = [[NSMutableArray alloc]init];
    for (NSDictionary *dic in arry) {
        PDFPageDataModel *page = [[PDFPageDataModel alloc]init];
        page.hotAreaList = [PDFHotAreaDataModel hotAreasFromPage:[dic objectForKey:@"mapping"]];
        [Article changePagerFlag];
        page.articlesList = [Article articlesFromArray:[dic objectForKey:@"list"]];
         [Article changePagerFlag];
        page.pageId = [dic objectForKey:@"id"];
        page.pageTitle = [dic objectForKey:@"name"];
        page.pagePic = [dic objectForKey:@"picUrl"];
        if (![[dic objectForKey:@"width"] isKindOfClass:[NSNull class]] && ![[dic objectForKey:@"width"] isKindOfClass:[NSNull class]]) {
            page.pageWidth = [[dic objectForKey:@"width"] floatValue];
            page.pageHeight = [[dic objectForKey:@"height"] floatValue];

        }
        [arryM addObject:page];
    }
    return arryM;
    
}
@end
