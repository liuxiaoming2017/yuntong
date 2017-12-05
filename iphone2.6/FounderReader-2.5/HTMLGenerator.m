//
//  HTMLGenerator.m
//  FounderReader-2.5
//
//  Created by chenfei on 5/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HTMLGenerator.h"
#import "ICUTemplateMatcher.h"

@implementation HTMLGenerator

@synthesize templatePath;
@synthesize variables;

- (id)init
{
    self = [super init];
    if (self) {
        engine = [MGTemplateEngine templateEngine];
        [engine setDelegate:self];
        [engine setMatcher:[ICUTemplateMatcher matcherWithTemplateEngine:engine]];
    }
    return self;
}

@end
