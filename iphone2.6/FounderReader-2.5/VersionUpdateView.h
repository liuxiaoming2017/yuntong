//
//  VersionUpdateView.h
//  FounderReader-2.5
//
//  Created by Julian on 2016/11/9.
//
//

#import <UIKit/UIKit.h>

typedef void(^VersionUpdateBlock)(BOOL isUpdate);

@interface VersionUpdateView : UIView

@property (nonatomic, copy)VersionUpdateBlock versionUpdateBlock;

+ (instancetype)versionUpdateViewWithContent:(NSString *)content;

@end
