// -*- Mode: ObjC; tab-width: 2; indent-tabs-mode: nil; c-basic-offset: 2 -*-

/**
 * Copyright 2009 Jeff Verkoeyen
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


#ifndef IS_IPHONE
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_5 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0f)
#define IS_IPHONE_4 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 480.0f)
#endif

#import "OverlayView.h"

static const CGFloat kPadding = 10;
static const CGFloat kLicenseButtonPadding = 10;

@interface OverlayView()
@property (nonatomic,assign) UIButton *cancelButton;
@property (nonatomic,assign) UIButton *licenseButton;
@property (nonatomic,retain) UILabel *instructionsLabel;
@end


@implementation OverlayView

@synthesize delegate, oneDMode;
@synthesize points = _points;
@synthesize cancelButton;
@synthesize licenseButton;
@synthesize cropRect;
@synthesize instructionsLabel;
@synthesize displayedMessage;
@synthesize cancelButtonTitle;
@synthesize cancelEnabled;

////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)theFrame cancelEnabled:(BOOL)isCancelEnabled oneDMode:(BOOL)isOneDModeEnabled {
    return [self initWithFrame:theFrame cancelEnabled:isCancelEnabled oneDMode:isOneDModeEnabled showLicense:YES];
}

- (id) initWithFrame:(CGRect)theFrame cancelEnabled:(BOOL)isCancelEnabled oneDMode:(BOOL)isOneDModeEnabled showLicense:(BOOL)showLicenseButton {
    BOOL disAlertMessage = showLicenseButton;
    self = [super initWithFrame:theFrame];
    if( self ) {
        
        CGFloat rectSize = self.frame.size.width - kPadding * 2;
        if (!oneDMode) {
            cropRect = CGRectMake(kPadding, (self.frame.size.height - rectSize) / 2, rectSize, rectSize);
        } else {
            CGFloat rectSize2 = self.frame.size.height - kPadding * 2;
            cropRect = CGRectMake(kPadding, kPadding, rectSize, rectSize2);		
        }
        
        self.backgroundColor = [UIColor clearColor];
        self.oneDMode = isOneDModeEnabled;
        
        self.cancelEnabled = isCancelEnabled;
        
        if (self.cancelEnabled) {
            UIImageView *bgImageView = nil;
            if (IS_IPHONE_5){
                bgImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"twobar_bg5"]];
            }
            else{
                bgImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"twobar_bg"]];
            }
           
            bgImageView.frame = self.bounds;
            [self addSubview:bgImageView];
            [bgImageView release];
            
            
//            UIButton *butt = [UIButton buttonWithType:UIButtonTypeCustom];
//            self.cancelButton = butt;
//            if ([self.cancelButtonTitle length] > 0 ) {
//                [cancelButton setTitle:self.cancelButtonTitle forState:UIControlStateNormal];
//            } else {
////                [cancelButton setTitle:NSLocalizedStringWithDefaultValue(@"OverlayView cancel button title", nil, [NSBundle mainBundle], @"取消", @"取消") forState:UIControlStateNormal];
//                [cancelButton setBackgroundImage:[UIImage imageNamed:@"twobar_cancel"] forState:UIControlStateNormal];
//                [cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//                [cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
//            }
//            [cancelButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
//            [self addSubview:cancelButton];
        }
    }
    return self;
}

- (void)cancel {
	// call delegate to cancel this scanner
	if (delegate != nil) {
		[delegate cancelled];
	}
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void) dealloc {
	[_points release];
    [instructionsLabel release];
    [displayedMessage release];
    [cancelButtonTitle release],
	[super dealloc];
}



#define kTextMargin 10


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void) setPoints:(NSMutableArray*)pnts {
    [pnts retain];
    [_points release];
    _points = pnts;
	
    if (pnts != nil) {
        self.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.25];
    }
    [self setNeedsDisplay];
}

- (void) setPoint:(CGPoint)point {
    if (!_points) {
        _points = [[NSMutableArray alloc] init];
    }
    if (_points.count > 3) {
        [_points removeObjectAtIndex:0];
    }
    [_points addObject:[NSValue valueWithCGPoint:point]];
    [self setNeedsDisplay];
}


- (void)layoutSubviews {
    [super layoutSubviews];
    if (cancelButton) {
        if (oneDMode) {
            [cancelButton setTransform:CGAffineTransformMakeRotation(M_PI/2)];
            [cancelButton setFrame:CGRectMake(20, 175, 45, 130)];
        }else {
            
            if (IS_IPHONE_4) {
                cancelButton.frame = CGRectMake(19, 408, 281, 38.5);
            }
            else if (IS_IPHONE_5){
                cancelButton.frame = CGRectMake(19, 498, 281, 38.5);
            }
            
        }
    }
}

@end
