//
//  InteractionConfig.h
//  FounderReader-2.5
//
//  Created by chenfei on 5/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InteractionConfig : NSObject {
    NSString *informNameLabelText;
    NSString *informNamePlaceholder;
    NSString *informPhoneNoLabelText;
    NSString *informPhoneNoPlaceholder;
    NSString *informSubjectLabelText;
    NSString *informSubjectPlaceholder;
    NSString *informContentLabelText;
    NSString *informContentPlaceholder;
    
    NSString *feedbackNameLabelText;
    NSString *feedbackNamePlaceholder;
    NSString *feedbackPhoneNoLabelText;
    NSString *feedbackPhoneNoPlaceholder;
    NSString *feedbackEmailLabelText;
    NSString *feedbackEmailPlaceholder;
    NSString *feedbackContentLabelText;
    NSString *feedbackContentPlaceholder;
}

@property(nonatomic, retain) NSString *informNameLabelText;
@property(nonatomic, retain) NSString *informNamePlaceholder;
@property(nonatomic, retain) NSString *informPhoneNoLabelText;
@property(nonatomic, retain) NSString *informPhoneNoPlaceholder;
@property(nonatomic, retain) NSString *informSubjectLabelText;
@property(nonatomic, retain) NSString *informSubjectPlaceholder;
@property(nonatomic, retain) NSString *informContentLabelText;
@property(nonatomic, retain) NSString *informContentPlaceholder;

@property(nonatomic, retain) NSString *feedbackNameLabelText;
@property(nonatomic, retain) NSString *feedbackNamePlaceholder;
@property(nonatomic, retain) NSString *feedbackPhoneNoLabelText;
@property(nonatomic, retain) NSString *feedbackPhoneNoPlaceholder;
@property(nonatomic, retain) NSString *feedbackEmailLabelText;
@property(nonatomic, retain) NSString *feedbackEmailPlaceholder;
@property(nonatomic, retain) NSString *feedbackContentLabelText;
@property(nonatomic, retain) NSString *feedbackContentPlaceholder;

+ (InteractionConfig *)sharedInteractionConfig;

@end
