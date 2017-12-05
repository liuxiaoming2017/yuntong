//
//  Thumbnail.h
//  FounderReader-2.5
//
//  Created by chenfei on 5/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ImageViewCf.h"

@interface Thumbnail : ImageViewCf {
    id        _target;
    SEL       _action;
}

- (void)addTarget:(id)target action:(SEL)action;

@end
