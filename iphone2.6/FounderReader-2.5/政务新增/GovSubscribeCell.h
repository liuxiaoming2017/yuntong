//
//  GovSubscribeCell.h
//  FounderReader-2.5
//
//  Created by 黄柳姣 on 2017/12/4.
//

#import <UIKit/UIKit.h>
@class GovSubscribeCell;
@protocol GovSubscribeCellDelegate<NSObject>
-(void)buttonClickCell:(UITableViewCell *)tableViewCell withBool:(BOOL)selected;
@end
@interface GovSubscribeCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *iconImage;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subscribeCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *subscribeBtn;
@property (weak, nonatomic) id<GovSubscribeCellDelegate> delegate;
@end
