//
//  DownloadManager.h
//  DataLib
//
//  Created by chenfei on 4/1/13.
//  Copyright (c) 2013 chenfei. All rights reserved.
//  下载报纸数据包管理器

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"

typedef void (^ReportBlock)(float progress);
typedef void (^CompleteBlock)();
CGPDFDocumentRef getPDFDocument(const char *filePath);
void drawPDFPageToImage(CGPDFPageRef page, size_t i, NSString *dstPath);

@interface DownloadManager : NSObject

@property(nonatomic, retain) NSString *dstPath;

+ (id)sharedDownloadManager;

- (void)addHTTPRequest:(ASIHTTPRequest *)request WithTag:(int)tag;
- (void)cancelHTTPRequestWithTag:(int)tag;
- (ASIHTTPRequest *)requestWithTag:(int)tag;
- (NSArray *)allRequests;

// 生成pdf缩略图
// report 报告进度
// complete 报告生成完毕
- (void)makePDFThumbnailWithPDFPath:(NSString *)pdfpath reportBlock:(ReportBlock)report completeBlock:(CompleteBlock)complete;

// 删除数据包以及缩略图
- (void)deleteDataPkgWithTag:(int)tag;


@end
