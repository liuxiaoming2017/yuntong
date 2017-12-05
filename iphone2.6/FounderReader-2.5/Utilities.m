//
//  Utilities.m
//  FounderReader-2.5
//
//  Created by chenfei on 4/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Utilities.h"
#import "ZipArchive.h"

UIColor *UIColorFromString(NSString *string)
{
    if(string == nil)
        return nil;
    NSArray *array = [string componentsSeparatedByString:@","];
    
    assert([array count] >= 3);
	
	CGFloat red = [[array objectAtIndex:0] floatValue];
	CGFloat green = [[array objectAtIndex:1] floatValue];
	CGFloat blue = [[array objectAtIndex:2] floatValue];
	
	return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1];
}

UIColor* colorWithHexString(NSString *color)
{
    //删除字符串中的空格
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    // String should be 6 or 8 characters
    if ([cString length] < 6)
    {
        return [UIColor clearColor];
    }
    // strip 0X if it appears
    //如果是0x开头的，那么截取字符串，字符串从索引为2的位置开始，一直到末尾
    if ([cString hasPrefix:@"0X"])
    {
        cString = [cString substringFromIndex:2];
    }
    //如果是#开头的，那么截取字符串，字符串从索引为1的位置开始，一直到末尾
    if ([cString hasPrefix:@"#"])
    {
        cString = [cString substringFromIndex:1];
    }
    if ([cString length] != 6)
    {
        return [UIColor clearColor];
    }
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    //r
    NSString *rString = [cString substringWithRange:range];
    //g
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    //b
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    return [UIColor colorWithRed:((float)r / 255.0f) green:((float)g / 255.0f) blue:((float)b / 255.0f) alpha:1];
}

#pragma mark - path

NSString *pathForMainBundleResource(NSString *resource)
{
    NSString *fileName = [[resource componentsSeparatedByString:@"."] objectAtIndex:0];
    NSString *extension =[resource pathExtension];
    return [[NSBundle mainBundle] pathForResource:fileName ofType:extension];
}

NSString *pathForResourceBundle(NSString *resource)
{
    NSString *mainBundlePath = [[NSBundle mainBundle] resourcePath];
    NSString *resourceBundlePath = [mainBundlePath stringByAppendingPathComponent:@"Resource.bundle"];
    return [resourceBundlePath stringByAppendingString:resource];;
}

NSString *docDirPath()
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

NSString *cacheDirPath()
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

NSString *fileNameFromeURL(NSString *url)
{
    if ([url isKindOfClass:[NSString class]])
        return [url lastPathComponent];
    return nil;
}

NSString *cachePathFromURL(NSString *url)
{
    return [cacheDirPath() stringByAppendingPathComponent:fileNameFromeURL(url)];
}

NSString *docDirPathFromURL(NSString *url)
{
    return [docDirPath() stringByAppendingPathComponent:fileNameFromeURL(url)];
}

NSString *localTemplatePath()//content_template.html
{//news_detail.html
    return pathForMainBundleResource(@"news_detail.html");
}

BOOL isFileExists(NSString *path)
{
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

void renameFile(NSString *srcPath, NSString *dstPath)
{
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:dstPath]) {
        [manager removeItemAtPath:dstPath error:0];
    }
    [manager moveItemAtPath:srcPath toPath:dstPath error:0];
}

void copyMainBundleResourceToCacheDir(NSString *fileName)
{
    NSString *srcPath = pathForMainBundleResource(fileName);
    NSString *desPath = [cacheDirPath() stringByAppendingPathComponent:fileName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:desPath]) {
        NSError *error = nil;
        if (srcPath == nil)
        {
            return;
        }
        [[NSFileManager defaultManager] copyItemAtPath:srcPath toPath:desPath error:&error];
        if (error)
        {
            XYLog(@"%@", error);
        }
    }
}

NSString *dbPath()
{
    return [cacheDirPath() stringByAppendingPathComponent:kDBName];
}

#pragma mark - 

NSString *NSStringFromData(NSData *data)
{
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

#pragma mark -

AppDelegate *appDelegate()
{
    return (AppDelegate *)([UIApplication sharedApplication].delegate);
}

NSString *appName()
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
}

BOOL isRetina()
{
    CGFloat scale = [[UIScreen mainScreen] scale];
    
    if (scale > 1.0)
        return YES;
    return NO;
}

BOOL unzipTemplateFile(NSString *filePath)
{
    BOOL ok = NO;

    ZipArchive *zipArchive = [[ZipArchive alloc] init];
    BOOL open_ok = [zipArchive UnzipOpenFile:filePath];
    if (open_ok) {
        ok = [zipArchive UnzipFileTo:cacheDirPath() overWrite:YES];
        [zipArchive UnzipCloseFile];
    }
//    DELETE(zipArchive);
    return ok;
}

UIImage *convertImageSize(UIImage *image, CGSize size)
{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

NSString *intervalSinceNow(NSString *aDate)
{
    if (!aDate.length || [aDate isKindOfClass:[NSNull class]]) {
        return @"0";
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [dateFormatter dateFromString:aDate];
 
    
    NSTimeInterval interval_1 = [date timeIntervalSince1970];

    NSDate *nowdate = [NSDate date];
    NSTimeInterval interval_2 = [nowdate timeIntervalSince1970];

    NSTimeInterval diff  = interval_2 - interval_1;
    if (diff < 0)
        diff = 0;
    NSString *timeString = nil;

    if (diff/60 <= 1) {
        timeString = [NSString stringWithFormat:@"%f", diff];
        timeString = [timeString substringToIndex:timeString.length-7];
        timeString = [NSString stringWithFormat:NSLocalizedString(@"刚刚",nil)];
    }
    
    if (diff/60 > 1 && diff/3600 <= 1) {
        timeString = [NSString stringWithFormat:@"%f", diff/60];
        timeString = [timeString substringToIndex:timeString.length-7];
        timeString = [NSString stringWithFormat:@"%@%@", timeString, NSLocalizedString(@"分钟前",nil)];
    }

    if (diff/3600 > 1 && diff/86400 <= 1) {
        timeString = [NSString stringWithFormat:@"%f", diff/3600];
        timeString = [timeString substringToIndex:timeString.length-7];
        timeString = [NSString stringWithFormat:@"%@%@", timeString, NSLocalizedString(@"小时前",nil)];
    }

    if (diff/86400 > 1 && diff/86400 <= 2)  {
        timeString = [NSString stringWithFormat:@"%f", diff/86400];
        timeString = [timeString substringToIndex:timeString.length-7];
        timeString = [NSString stringWithFormat:@"%@%@", timeString, NSLocalizedString(@"天前",nil)];
    }

    
    if (diff/86400 > 2){
        NSRange range;
        range.length = 11;
        range.location = 5;
//        if (timeString.length>=16)
        {
            timeString = [NSString stringWithFormat:@"%@", [aDate substringWithRange:range]];
        }
        
    }
    
    if (diff/86400 >= 30) {
        NSRange range;
        range.length = 10;
        range.location = 0;
        timeString = [NSString stringWithFormat:@"%@", [aDate substringWithRange:range]];
    }
    
    return timeString;
}

//guo天气缓存

NSString * weatherBaseUrl(NSString *baseFolder)
{
	NSString *baseFolderPath = [cacheDirPath() stringByAppendingPathComponent:baseFolder];
    
	NSFileManager *fileManager = [NSFileManager defaultManager];
	BOOL fileExists = [fileManager fileExistsAtPath:baseFolderPath];
	if (!fileExists) 
	{
		[fileManager createDirectoryAtPath:baseFolderPath
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:nil];
	}

	return baseFolderPath;
}

NSString *buildWeatherFolder(NSString *baseFolder,NSString *firstFolder,NSString *secondFolder)
{
    NSString *imgFolder = [weatherBaseUrl(baseFolder) stringByAppendingFormat:@"/%@/%@",firstFolder,secondFolder];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
	BOOL fileExists = [fileManager fileExistsAtPath:imgFolder];
	if (!fileExists) 
	{
		[fileManager createDirectoryAtPath:imgFolder
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:nil];
	}
	
	return imgFolder;
}

void printAllFontNames()
{
    NSArray *familyNames = [UIFont familyNames];
    for (NSString *familyName in familyNames) {
        XYLog(@"%@:", familyName);
        NSArray *fontNames = [UIFont fontNamesForFamilyName:familyName];
        for (NSString *fontName in fontNames) {
            XYLog(@" • %@", fontName);
        }
    }
}
//计数
void RecordViewShowTimes(NSString *key_view) {
    
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber *times = [standardDefaults objectForKey:key_view];
    if (!times) {
        [standardDefaults setObject:[NSNumber numberWithInt:1] forKey:key_view];
    }
    else {
        [standardDefaults setObject:[NSNumber numberWithInt:[times intValue] + 1]
                             forKey:key_view];
    }
    
    [standardDefaults synchronize];
}

//清空
void ResetViewShowTimes(NSString *key_view) {
    
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    [standardDefaults setObject:[NSNumber numberWithInt:0] forKey:key_view];
    [standardDefaults synchronize];
}

BOOL IsViewFirstShow(NSString *key_view) {
    
    RecordViewShowTimes(key_view);
    NSNumber *times = [[NSUserDefaults standardUserDefaults] objectForKey:key_view];
    return [times isEqualToNumber:[NSNumber numberWithInt:1]];
}


BOOL isGuangDongCity(NSString *city){
    
    if (city == nil || city.length == 0) {
        return NO;
    }
    NSString *strCity = @"广州，深圳，佛山，东莞，云浮，汕尾，湛江，惠州，江门，中山，清远，肇庆，茂名，阳江，揭阳，珠海，梅州，汕头，潮州，河源，韶关";
    NSRange range = [strCity rangeOfString:city];
    if (range.location == NSNotFound) {
        return NO;
    }
    else
        return YES;
}

