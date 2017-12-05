//
//  HTMLGenerator.h
//  FounderReader-2.5
//
//  Created by chenfei on 5/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MGTemplateEngine.h"

@interface HTMLGenerator : NSObject <MGTemplateEngineDelegate> {
    MGTemplateEngine *engine;
    
    NSString *templatePath;
    NSDictionary *variables;
}

@property(nonatomic, retain) NSString *templatePath;
@property(nonatomic, retain) NSDictionary *variables;

@end
