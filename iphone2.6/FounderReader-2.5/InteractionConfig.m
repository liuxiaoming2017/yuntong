//
//  InteractionConfig.m
//  FounderReader-2.5
//
//  Created by chenfei on 5/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "InteractionConfig.h"

static InteractionConfig *__interactionConfig = nil;

@implementation InteractionConfig

@synthesize informNameLabelText, informNamePlaceholder;
@synthesize informPhoneNoLabelText, informPhoneNoPlaceholder;
@synthesize informSubjectLabelText, informSubjectPlaceholder;
@synthesize informContentLabelText, informContentPlaceholder;

@synthesize feedbackNameLabelText, feedbackNamePlaceholder;
@synthesize feedbackPhoneNoLabelText, feedbackPhoneNoPlaceholder;
@synthesize feedbackEmailLabelText, feedbackEmailPlaceholder;
@synthesize feedbackContentLabelText, feedbackContentPlaceholder;

- (id)init
{
    self = [super init];
    if (self) {
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:pathForMainBundleResource(@"interaction_config.plist")];
        self.informNameLabelText = [dict objectForKey:@"inform_name_label"];
        self.informNamePlaceholder = [dict objectForKey:@"inform_name_placeholder"];
        self.informPhoneNoLabelText = [dict objectForKey:@"inform_phone_no_label"];
        self.informPhoneNoPlaceholder = [dict objectForKey:@"inform_phone_no_placeholder"];
        self.informSubjectLabelText = [dict objectForKey:@"inform_subject_label"];
        self.informSubjectPlaceholder = [dict objectForKey:@"inform_subject_placeholder"];
        self.informContentLabelText = [dict objectForKey:@"inform_content_label"];
        self.informContentPlaceholder = [dict objectForKey:@"inform_content_placeholder"];
        
        self.feedbackNameLabelText = [dict objectForKey:@"feedback_name_label"];
        self.feedbackNamePlaceholder = [dict objectForKey:@"feedback_name_placeholder"];
        self.feedbackPhoneNoLabelText = [dict objectForKey:@"feedback_phone_no_label"];
        self.feedbackPhoneNoPlaceholder = [dict objectForKey:@"feedback_phone_no_placeholder"];
        self.feedbackEmailLabelText = [dict objectForKey:@"feedback_email_label"];
        self.feedbackEmailPlaceholder = [dict objectForKey:@"feedback_email_placeholder"];
        self.feedbackContentLabelText = [dict objectForKey:@"feedback_content_label"];
        self.feedbackContentPlaceholder = [dict objectForKey:@"feedback_content_placeholder"];
    }
    return self;
}

+ (InteractionConfig *)sharedInteractionConfig
{
    if (__interactionConfig == nil)
        __interactionConfig = [[self alloc] init];
    return __interactionConfig;
}

@end
