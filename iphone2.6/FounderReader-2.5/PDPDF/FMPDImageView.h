//
//  FMPDImageView.h
//  FounderReader-2.5
//
//  Created by ld on 14-3-10.
//
//

#import <UIKit/UIKit.h>
#import "ImageViewCf.h"

@interface FMPDImageView : UIView
{
    id        _target;
    SEL       _actionB;
    SEL       _actionE;
    id        _actionObject;
}

@property(nonatomic,retain) ImageViewCf *imageView;

- (void)addTarget:(id)target actionB:(SEL)actionB actionE:(SEL)actionE;
- (void)addTarget:(id)target actionB:(SEL)actionB actionE:(SEL)actionE withObject:(id)object;
@end
