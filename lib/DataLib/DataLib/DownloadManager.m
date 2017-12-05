//
//  DownloadManager.m
//  DataLib
//
//  Created by chenfei on 4/1/13.
//  Copyright (c) 2013 chenfei. All rights reserved.
//

#import "DownloadManager.h"

static DownloadManager *_download_manager_ = nil;

@implementation DownloadManager
{
    NSMutableDictionary *_requestDict;
    ASINetworkQueue *_queue;
}
@synthesize dstPath = _dstPath;

+ (id)sharedDownloadManager
{
    if (_download_manager_ == nil)
        _download_manager_ = [[self alloc] init];
    return _download_manager_;
}

- (id)init
{
    self = [super init];
    if (self) {
        _requestDict = [[NSMutableDictionary alloc] init];
        _queue = [[ASINetworkQueue alloc] init];
        [_queue setMaxConcurrentOperationCount:5];
        [_queue setShouldCancelAllRequestsOnFailure:NO];
        [_queue setShowAccurateProgress:YES];
        _queue.delegate = self;
        _queue.requestDidFinishSelector = @selector(requestDidFinish:);
        _queue.requestDidFailSelector = @selector(requestDidFail:);
        [_queue go];
    }
    return self;
}

- (void)dealloc
{
    [_requestDict release];
    [_queue release];
    [_dstPath release];
    
    [super dealloc];
}

- (void)addHTTPRequest:(ASIHTTPRequest *)request WithTag:(int)tag
{
    NSString *issueDirPath = [self.dstPath stringByAppendingFormat:@"/%d/", tag];
    if (![[NSFileManager defaultManager] fileExistsAtPath:issueDirPath])
        [[NSFileManager defaultManager] createDirectoryAtPath:issueDirPath withIntermediateDirectories:YES attributes:nil error:NULL];
    if ([_requestDict objectForKey:[NSNumber numberWithInt:tag]] == nil) {
        [_requestDict setObject:request forKey:[NSNumber numberWithInt:tag]];
        request.tag = tag;
        [request setTemporaryFileDownloadPath:[issueDirPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%d.tmp", tag]]];
        [request setDownloadDestinationPath:[issueDirPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%d", tag]]];
        [request setAllowResumeForFileDownloads:YES];
        [_queue addOperation:request];
    }
}

- (void)requestDidFinish:(ASIHTTPRequest *)request
{
    [_requestDict removeObjectForKey:[NSNumber numberWithInt:(int)request.tag]];
}

- (void)requestDidFail:(ASIHTTPRequest *)request
{
    [_requestDict removeObjectForKey:[NSNumber numberWithInt:(int)request.tag]];
    
//    NSLog(@"%d load failded", request.tag);
}

- (void)cancelHTTPRequestWithTag:(int)tag
{
    ASIHTTPRequest *request = [_requestDict objectForKey:[NSNumber numberWithInt:tag]];
    if (request) {
        [request clearDelegatesAndCancel];
        [_requestDict removeObjectForKey:[NSNumber numberWithInt:tag]];
    }
}

- (ASIHTTPRequest *)requestWithTag:(int)tag
{
    return [_requestDict objectForKey:[NSNumber numberWithInt:tag]];
}

- (NSArray *)allRequests
{
    return [_requestDict allValues];
}

CGPDFDocumentRef getPDFDocument(const char *filePath)
{
    CFStringRef path = CFStringCreateWithCString(NULL, filePath, kCFStringEncodingUTF8);
    CFURLRef url = CFURLCreateWithFileSystemPath(NULL, path, kCFURLPOSIXPathStyle, 0);
    CFRelease (path);
    CGPDFDocumentRef document = CGPDFDocumentCreateWithURL(url);
    CFRelease(url);
    size_t count = CGPDFDocumentGetNumberOfPages(document);
    if (count == 0) {
        CGPDFDocumentRelease(document);
        return NULL;
    }
    return document;
}

// 缩小到1/4
void drawPDFPageToImage(CGPDFPageRef page, size_t i, NSString *dstPath)
{
    CGRect pageRect = CGPDFPageGetBoxRect(page, kCGPDFMediaBox);
    pageRect.size = CGSizeMake(pageRect.size.width/4, pageRect.size.height/4);
    UIGraphicsBeginImageContext(pageRect.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // First fill the background with white.
    CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
    CGContextFillRect(context, pageRect);
    
    CGContextSaveGState(context);
    // Flip the context so that the PDF page is rendered right side up.
    CGContextTranslateCTM(context, 0.0, pageRect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    // Scale the context so that the PDF page is rendered at the correct size for the zoom level.
    CGContextScaleCTM(context, .25, .25);
    CGContextDrawPDFPage(context, page);
    CGContextRestoreGState(context);
    
    UIImage *pdfImage = UIGraphicsGetImageFromCurrentImageContext();
    NSData *imageData = UIImageJPEGRepresentation(pdfImage, 0.9);
    NSString *imagePath = [dstPath stringByAppendingFormat:@"/%zd.jpg", i];
    [imageData writeToFile:imagePath atomically:YES];
    UIGraphicsEndImageContext();
}

- (void)makePDFThumbnailWithPDFPath:(NSString *)pdfpath reportBlock:(ReportBlock)report completeBlock:(CompleteBlock)complete
{
    NSString *thumbnailDirPath = [[pdfpath stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"thumbnail/"];

    if (![[NSFileManager defaultManager] fileExistsAtPath:thumbnailDirPath])
        [[NSFileManager defaultManager] createDirectoryAtPath:thumbnailDirPath withIntermediateDirectories:YES attributes:nil error:0];
    CGPDFDocumentRef doc = getPDFDocument([pdfpath cStringUsingEncoding:NSUTF8StringEncoding]);
    size_t count = CGPDFDocumentGetNumberOfPages(doc);
    dispatch_queue_t download_queue = dispatch_queue_create(NULL, NULL);
    dispatch_async(download_queue, ^(void) {
        for (size_t i=1; i<=count; ++i) {
            CGPDFPageRef page = CGPDFDocumentGetPage(doc, i);
            drawPDFPageToImage(page, i, thumbnailDirPath);
            dispatch_async(dispatch_get_main_queue(), ^(void) {     // 在主线程中执行
                report(i*1.0/count);
            });
        }
        dispatch_async(dispatch_get_main_queue(), ^(void) {     // 在主线程中执行
            complete();
        });
        
        CGPDFDocumentRelease(doc);
    });
    
    dispatch_release(download_queue);
}

- (void)deleteDataPkgWithTag:(int)tag
{
    // 删除数据包
    NSString *path = [self.dstPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%d", tag]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path])
        [[NSFileManager defaultManager] removeItemAtPath:path error:0];
}

@end
