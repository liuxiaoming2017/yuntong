//
//  PoliticalLocalPageController.h
//  FounderReader-2.5
//
//  Created by Julian on 16/7/27.
//
//

#import <UIKit/UIKit.h>
@class Column;

@interface PoliticalLocalController : UIViewController

@property (nonatomic, strong) Column *parentColumn;
@property (nonatomic, assign) BOOL isFromColumnBar;

@end
