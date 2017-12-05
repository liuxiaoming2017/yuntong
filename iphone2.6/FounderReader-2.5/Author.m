//
//  Author.m
//  FounderReader-2.5
//
//  Created by lihuiguo on 15/10/22.
//
//

#import "Author.h"

@implementation Author
@synthesize authorId,authorName,authorImageUrl,authorDuty,authorDescription,articleCount,fansCount;
@synthesize isAttention;

+ (Author *)authorFromDict:(NSDictionary *)dict
{
    if ([dict isKindOfClass:[NSNull class]]) {
        return nil;
    }
   
    Author *author = [[Author alloc] init];
    author.authorId = [[dict objectForKey:@"id"] integerValue];
    author.authorName = [dict objectForKey:@"name"];
    author.authorImageUrl = [dict objectForKey:@"url"];
    author.authorDuty = [dict objectForKey:@"duty"];
    author.authorDescription = [dict objectForKey:@"description"];
    author.articleCount = [[dict objectForKey:@"countArticle"] integerValue];
    author.fansCount = [[dict objectForKey:@"countFan"] integerValue];
     
    return author;

}

@end
