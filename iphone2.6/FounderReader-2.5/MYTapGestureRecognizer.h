//
//  MYTapGestureRecognizer.h
//  FounderReader-2.5
//
//  Created by Julian on 2016/11/9.
//
//

#import <UIKit/UIKit.h>

typedef void(^RemoveBlock)(void);

@interface MYTapGestureRecognizer : UITapGestureRecognizer

@property (nonatomic, copy)RemoveBlock removeBlock;

@end
