//
//  NoNetWorkPageController.h
//  FounderReader-2.5
//
//  Created by chenfei on 4/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import "Global.h"

@interface NoNetWorkPageController:UIViewController{
    FinishDataBlock _finishedBlock;
}
-(void)setFinishBlock:(FinishDataBlock)finishedBlock;
@end
