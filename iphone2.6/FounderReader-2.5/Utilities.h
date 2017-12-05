//
//  Utilities.h
//  FounderReader-2.5
//
//  Created by chenfei on 4/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

#define DELETE(p) [p release], p = nil

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

#ifndef __OPTIMIZE__
#define NSLog(...) NSLog(__VA_ARGS__)
#else
#define NSLog(...) {}
#endif

UIColor *UIColorFromString(NSString *string);
UIColor *colorWithHexString(NSString *color);

#pragma mark - path

NSString *pathForMainBundleResource(NSString *resource);
NSString *pathForResourceBundle(NSString *resource);

NSString *docDirPath();
NSString *cacheDirPath();
NSString *fileNameFromeURL(NSString *url);
NSString *cachePathFromURL(NSString *url);
NSString *docDirPathFromURL(NSString *url);


NSString *localTemplatePath();

void copyMainBundleResourceToCacheDir(NSString *fileName);

NSString *dbPath();

BOOL isFileExists(NSString *path);

void renameFile(NSString *srcPath, NSString *dstPath);

#pragma mark -

NSString *NSStringFromData(NSData *data);

#pragma mark -

AppDelegate *appDelegate();

NSString *appName();

#pragma mark -

BOOL isRetina();
BOOL unzipTemplateFile(NSString *filePath);

UIImage *convertImageSize(UIImage *image, CGSize size);

NSString *intervalSinceNow(NSString *aDate);

//guo天气缓存
NSString * weatherBaseUrl(NSString *baseFolder);
NSString *buildWeatherFolder(NSString *baseFolder,NSString *firstFolder,NSString *secondFolder);

void printAllFontNames();

//pdf(peopleDaily)
#define hgap 10
#define sgap 10
#define pdfcontentWidth 290

//在页面添加帮助提示
BOOL IsViewFirstShow(NSString *key_view);

void RecordViewShowTimes(NSString *key_view);
void ResetViewShowTimes(NSString *key_view);

//判断是否广东的一个城市
BOOL isGuangDongCity(NSString *city);

