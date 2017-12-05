//
//  MyInform.m
//  FounderReader-2.5
//
//  Created by ld on 14-8-22.
//
//


#import "MyInform.h"

@implementation MyInform
@synthesize informId;
@synthesize title;
@synthesize content;
@synthesize userName;
@synthesize userId;
@synthesize phone;
@synthesize email;
@synthesize createTime;
@synthesize sourceDevice;
@synthesize attachmentAmount;
@synthesize attachments;

-(void)dealloc
{
    self.informId = nil;
    self.title = nil;
    self.content = nil;
    self.userId = nil;
    self.userName = nil;
    self.phone = nil;
    self.email = nil;
    self.createTime = nil;
    self.sourceDevice = nil;
    self.attachmentAmount = nil;
//    self.attachments = nil;
    
//    [super dealloc];
}

+ (NSArray *)myInformsFromArray:(NSArray *)array
{
    NSMutableArray *informs = [[NSMutableArray alloc] initWithCapacity:[array count]];
    for (NSDictionary *dict in array) {
        MyInform *inform = [[MyInform alloc] init];
        inform.informId = [dict objectForKey:@"id"];
        inform.title = [dict objectForKey:@"title"];
        inform.content = [dict objectForKey:@"content"];
        inform.userId = [dict objectForKey:@"userId"];
        inform.userName = [dict objectForKey:@"userName"];
        inform.phone = [dict objectForKey:@"phone"];
        inform.email = [dict objectForKey:@"email"];
        inform.createTime = [dict objectForKey:@"createTime"];
        inform.sourceDevice = [dict objectForKey:@"sourceDevice"];
        inform.attachmentAmount = [dict objectForKey:@"attachmentAmount"];
        inform.attachments = [dict objectForKey:@"attachments"];
        //
        [informs addObject:inform];
//        DELETE(inform);
    } 
    return informs;

}

@end
