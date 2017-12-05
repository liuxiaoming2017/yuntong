//
//  NSStringAdditions.m
//  E-Publishing
//
//  Created by guo.lh on 12-10-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

//===============有用的NSString分类====================

#import "NSStringAdditions.h"
#import "GTMBase64.h"

@implementation NSString (FounderMobile)

+ (NSString*)encodeBase64String:(NSString * )input {
    NSData *data = [input dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    data = [GTMBase64 encodeData:data];
    NSString *base64String = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return base64String;
}

+(CGRect)stringToRect:(NSString *)rectString
{
    NSArray *rectList;
    rectList = [rectString componentsSeparatedByString:@","];
    CGRect rect;
    rect.origin.x = [[rectList objectAtIndex:0] floatValue];
    rect.origin.y = [[rectList objectAtIndex:1] floatValue];
    rect.size.width = [[rectList objectAtIndex:2] floatValue];
    rect.size.height = [[rectList objectAtIndex:3] floatValue];
    return rect;
}

+(NSArray *)stringDate:(NSString *)dateString
{
    return [dateString componentsSeparatedByString:@"-"];
    
}


+ (BOOL)isNilOrEmpty:(NSString *)str {
    
    if(![str isKindOfClass:[NSString class]])
        return YES;
    
    return (str == nil || str.length == 0);
}


+ (NSComparisonResult)compare:(NSString *)str1 to:(NSString *)str2 {
	
	if (str1 == str2)
		return NSOrderedSame;
	
	if (str1 == nil && str2 != nil)
		return NSOrderedDescending;
	
	if (str1 != nil && str2 == nil)
		return NSOrderedAscending;
	
	return [str1 compare:str2];
}

+ (NSString *)trim:(NSString *)original {
	
	if (original == nil)
		return nil;
	
	NSMutableString *copy = [original mutableCopy];
	
	return [NSString stringWithString:[copy stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
}


+ (NSString *)createUuid {
	
	CFUUIDRef theUUID = CFUUIDCreate(NULL);
	CFStringRef string = CFUUIDCreateString(NULL, theUUID);
	CFRelease(theUUID);
	
	return (__bridge NSString *)string;
}

- (BOOL)isValidEMail {
    
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"; 
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex]; 
    
    return [emailTest evaluateWithObject:self];
}


- (BOOL)isEmpty {
    
    return (self.length == 0);
}

- (BOOL)hasSubString:(NSString *)subString isCaseInsensitive:(BOOL)b {
    
    if ([NSString isNilOrEmpty:subString])
        return NO;
    
    NSRange range;
    if (b) 
        range = [self rangeOfString:subString options:NSCaseInsensitiveSearch];
    else
        range = [self rangeOfString:subString];
    
    return (range.location != NSNotFound);
}

- (BOOL)isWhitespaceAndNewlines {
    NSCharacterSet* whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    for (NSInteger i = 0; i < self.length; ++i) {
        unichar c = [self characterAtIndex:i];
        if (![whitespace characterIsMember:c]) {
            return NO;
        }
    }
    
    return YES;
}


- (NSDictionary*)queryContentsUsingEncoding:(NSStringEncoding)encoding {
    NSCharacterSet* delimiterSet = [NSCharacterSet characterSetWithCharactersInString:@"&;"];
    NSMutableDictionary* pairs = [NSMutableDictionary dictionary];
    NSScanner* scanner = [[NSScanner alloc] initWithString:self];
    while (![scanner isAtEnd]) {
        NSString* pairString = nil;
        [scanner scanUpToCharactersFromSet:delimiterSet intoString:&pairString];
        [scanner scanCharactersFromSet:delimiterSet intoString:NULL];
        NSArray* kvPair = [pairString componentsSeparatedByString:@"="];
        if (kvPair.count == 1 || kvPair.count == 2) {
            NSString* key = [[kvPair objectAtIndex:0]
                             stringByReplacingPercentEscapesUsingEncoding:encoding];
            NSMutableArray* values = [pairs objectForKey:key];
            if (nil == values) {
                values = [NSMutableArray array];
                [pairs setObject:values forKey:key];
            }
            if (kvPair.count == 1) {
                [values addObject:[NSNull null]];
                
            } else if (kvPair.count == 2) {
                NSString* value = [[kvPair objectAtIndex:1]
                                   stringByReplacingPercentEscapesUsingEncoding:encoding];
                [values addObject:value];
            }
        }
    }
    
    return [NSDictionary dictionaryWithDictionary:pairs];
}

- (NSString*)stringByAddingQueryDictionary:(NSDictionary*)query {
    NSMutableArray* pairs = [NSMutableArray array];
    for (NSString* key in [query keyEnumerator]) {
        NSString* value = [query objectForKey:key];
        value = [value stringByReplacingOccurrencesOfString:@"?" withString:@"%3F"];
        value = [value stringByReplacingOccurrencesOfString:@"=" withString:@"%3D"];
        NSString* pair = [NSString stringWithFormat:@"%@=%@", key, value];
        [pairs addObject:pair];
    }
    
    NSString* params = [pairs componentsJoinedByString:@"&"];
    if ([self rangeOfString:@"?"].location == NSNotFound) {
        return [self stringByAppendingFormat:@"?%@", params];
        
    } else {
        return [self stringByAppendingFormat:@"&%@", params];
    }
}



- (id)urlEncoded {
    CFStringRef cfUrlEncodedString = CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                             (CFStringRef)self,NULL,
                                                                             (CFStringRef)@"!*’();:@&=$,/?%#[]",
                                                                             kCFStringEncodingUTF8);
    
    NSString *urlEncoded = [NSString stringWithString:(__bridge NSString *)cfUrlEncodedString];
    CFRelease(cfUrlEncodedString);
    return urlEncoded;
}


- (NSString *)urlDecoded {
    
    NSMutableString *resultString = [NSMutableString stringWithString:self];
    [resultString replaceOccurrencesOfString:@"+"
                                  withString:@" "
                                     options:NSLiteralSearch
                                       range:NSMakeRange(0, [resultString length])];
    
    return [resultString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

@end

//guo wangwei's code===============================================================================================

@implementation UIAlertView (FounderMobile)


+ (void)showAlert:(NSString *)title {
	
	[UIAlertView showAlert:title withMessage:nil];
}


+ (void)showAlert:(NSString *)title withMessage:(NSString *)message {
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
													message:message 
												   delegate:nil 
										  cancelButtonTitle:@"确认"
										  otherButtonTitles:nil];
	[alert show];
}

+ (void)showAlert:(NSString *)message second:(int)second
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@" " message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
    [alert show];
    
    [alert performSelector:@selector(dismissWithClickedButtonIndex:animated:) withObject:nil afterDelay:second];
 
}

@end

//guo wangwei's code===============================================================================================