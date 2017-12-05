//
//  SeeDirectTableViewCell.h
//  FounderReader-2.5
//
//  Created by lx on 15/8/15.
//
//

#import <UIKit/UIKit.h>
#import "ImageViewCf.h"
#import "TopDiscussmodel.h"
#import "SeeLivePhotosView.h"
#import "TopDiscussmodel.h"
#import "LiveFrame.h"
#import <MediaPlayer/MediaPlayer.h>
@interface SeeDirectTableViewCell : UITableViewCell<SDPhotoBrowserDelegate>
{
    UIButton *leftImageView;
    UIButton *rightImageView;
    UIButton *bigImageView;

}
@property(nonatomic,retain)UIView *messageBackView;
@property (nonatomic,assign)CGFloat cellHight;
@property(nonatomic ,retain)ImageViewCf *userImage;
//小三角形
@property(nonatomic, retain)UIImageView *taiangle;
@property(nonatomic ,retain)UILabel *authorLabel;
//九宫格图片
@property(nonatomic ,retain)SeeLivePhotosView *livephotosView;
//简易的文字
@property(nonatomic ,retain)UILabel *summaryLael;
//视频的图片
@property(nonatomic ,retain)ImageViewCf *videoImage;
@property(nonatomic ,retain)UILabel *pushtime;

//点赞
@property(nonatomic ,retain)UIImageView *topimage;
@property(nonatomic ,retain) UILabel *toppeople;
@property(nonatomic ,retain)UIButton *topButton;

//cell 的索引
@property(nonatomic ,assign)NSInteger indexrow;

//@property(nonatomic ,retain)NSMutableArray *livFrameArray;

@property (nonatomic ,retain)NSString *video_url;

@property (nonatomic,retain)NSMutableArray *Frames;

@property (nonatomic ,retain)UIImageView *videoIcon;

@property (nonatomic,copy) void(^playerButtonClickedBlock)(NSURL*urlStr);
-(void)directUIFrame:(LiveFrame *)topdissModel andReuseidentID:(NSString*)reuseID frames:(NSMutableArray *)frames andIndexpath:(NSIndexPath *)indexPath;

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier indexRow:(NSInteger)indexrow andliveFrame:(LiveFrame *)liveframe;
@end
