//
//  Attachment.m
//  FounderReader-2.5
//
//  Created by chenfei on 5/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Attachment.h"

@implementation Attachment

@synthesize attId, picType,imageUrl, title, description;

//- (void)dealloc
//{
//    DELETE(imageUrl);
//    DELETE(title);
//    DELETE(description);
//    
//    [super dealloc];
//}

+ (NSArray *)attachmentsFromArray:(NSArray *)array
{
    @try {
        NSMutableArray *attachments = [[NSMutableArray alloc] initWithCapacity:[array count]];
        for (NSDictionary *dict in array) {
            Attachment *attachment = [[Attachment alloc] init];
            attachment.picType = [[dict objectForKey:@"type"] intValue];
            
            if ([NSString isNilOrEmpty:[dict objectForKey:@"imageUrl"]]) {
                attachment.imageUrl = [dict objectForKey:@"imgUrl"];
            }
            else
            {
                attachment.imageUrl = [dict objectForKey:@"imageUrl"];
            }
            NSString *suffixStr = nil;
            if ([attachment.imageUrl hasPrefix:@"http://img.newaircloud.com"]) {
                suffixStr = [attachment.imageUrl substringFromIndex:attachment.imageUrl.length-3];
                attachment.imageUrl = [suffixStr isEqualToString:@"gif"]?attachment.imageUrl:[NSString stringWithFormat:@"%@@!lg", attachment.imageUrl];
            }
    
            attachment.description = [dict objectForKey:@"summary"];
            attachment.title = [dict objectForKey:@"title"];
            [attachments addObject:attachment];
        }
        return attachments;
    } @catch (NSException *exception) {
        XYLog(@"数据错误--%@",exception);
    } @finally {
        
    }
}

@end
