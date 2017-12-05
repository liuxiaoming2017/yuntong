//
//  InformAttachment.h
//  FounderReader-2.5
//
//  Created by chenfei on 4/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IQMediaPickerController.h"
#import <AssetsLibrary/ALAssetRepresentation.h>

@interface InformAttachment : NSObject {
    NSData *data;
    NSString *fileName;
    
//    NSURL *movieURL;
    NSString *movieStr;
}

@property(nonatomic, retain) NSData *data;
@property(nonatomic, retain) NSString *fileName;
//@property(nonatomic, retain) NSURL *movieURL;
@property(nonatomic, retain) NSString *movieStr;
@property(nonatomic, assign) IQMediaPickerControllerMediaType type;
@property(nonatomic, retain) ALAssetRepresentation *rep;
@property(nonatomic, assign) BOOL flagShow;

@end
