//
//  HelperScrollView.h
//  E-Publishing
//
//  Created by xiaobai on 11-6-6.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface HelperScrollView : UIView<UIScrollViewDelegate>
{
    UILabel *_pageNumLabel;
    int _index;
}


@end
