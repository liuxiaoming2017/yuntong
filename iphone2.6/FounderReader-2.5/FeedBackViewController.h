//
//  FeedBackViewController.h
//  FounderReader-2.5
//
//  Created by lx on 15/9/15.
//
//

#import "InformPageController.h"
#import "Column.h"

@interface FeedBackViewController : ChannelPageController<UIAlertViewDelegate, UITextViewDelegate>
{
    UILabel *lengthLabel;
    UITextView *_contentTextView;
}
@property(nonatomic,retain) UIButton *sendButton;
@property(nonatomic, retain) UITextView *contentTextView;

@end
