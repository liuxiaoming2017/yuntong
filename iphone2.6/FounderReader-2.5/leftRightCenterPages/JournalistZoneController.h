//
//  JournalistZoneController.h
//  FounderReader-2.5
//
//  Created by xhby on 15/10/21.
//
//

#import <UIKit/UIKit.h>
#import "ImageViewCf.h"
#import "Author.h"
@interface JournalistZoneController : UIViewController
@property (nonatomic,retain)UILabel *userName;
@property (nonatomic,retain)UILabel *articleNum;
@property (nonatomic,retain)UILabel *job;
@property (nonatomic,retain)UILabel *fansNum;
@property (nonatomic,retain)ImageViewCf *userPhoto;
@property (nonatomic,retain)Author *author;


@end
