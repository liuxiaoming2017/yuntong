//
//  ShareViewDelegate.m
//  FounderReader-2.5
//
//  Created by guo.lh on 13-8-7.
//
//

#import "ShareViewDelegate.h"
#import <AGCommon/UIDevice+Common.h>
#import <AGCommon/UINavigationBar+Common.h>

@implementation ShareViewDelegate


#pragma mark - ISSShareViewDelegate

- (void)viewOnWillDisplay:(UIViewController *)viewController shareType:(int)shareType
{
    if (![UIDevice currentDevice].isPad)
    {
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")){
            [viewController.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_bar_background"]];
        }
        else{
            [viewController.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_bar_background"]];
        }
    }
    [viewController.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"tool_bar_background"]];
    viewController.navigationController.navigationBar.tintColor = [UIColor redColor];
}

- (void)view:(UIViewController *)viewController autorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation shareType:(int)shareType
{
    if ([UIDevice currentDevice].isPad)
    {
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")){
            [viewController.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_bar_background"]];
        }
        else{
            [viewController.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_bar_background"]];
        }
    }
}

/*- (id<ISSContent>)view:(UIViewController *)viewController
    willPublishContent:(id<ISSContent>)content
             shareList:(NSArray *)shareList
{
    return nil;
}*/

@end
