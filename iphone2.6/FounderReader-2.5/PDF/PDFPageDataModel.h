//
//  PDFPageDataModel.h
//  FounderReader-2.5
//
//  Created by ld on 13-12-5.
//
//

#import <Foundation/Foundation.h>

@interface PDFPageDataModel : NSObject
@property(nonatomic,retain) NSArray *hotAreaList;
@property(nonatomic,retain) NSArray *articlesList;
@property(nonatomic,retain) NSString *pageId;
@property(nonatomic,assign) float pageWidth;
@property(nonatomic,assign) float pageHeight;
@property(nonatomic,retain) NSString *pageTitle;
@property(nonatomic,retain) NSString *pagePic;

+(NSArray *)pagesFromArray:(NSArray *)arry;
@end
