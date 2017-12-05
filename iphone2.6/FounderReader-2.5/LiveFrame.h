//
//  LiveFrame.h
//  FounderReader-2.5
//
//  Created by 周志扬 on 15/9/7.
//
//

#import <Foundation/Foundation.h>
#import "TopDiscussmodel.h"

@interface LiveFrame : NSObject

@property(nonatomic ,retain)TopDiscussmodel *topModel;
/**评论用户的头像*/
@property(nonatomic ,assign)CGRect userImageF;
/**背景的小三角*/
@property(nonatomic ,assign)CGRect taiangleF;
/**评论作者的名字*/
@property(nonatomic ,assign)CGRect authorLabelF;
/**评论的时间*/
@property(nonatomic ,assign)CGRect pushtimeF;
/**赞的人数*/
@property(nonatomic ,assign)CGRect topPeople;
/**赞的图片*/
@property(nonatomic ,assign)CGRect topImageview;
/**赞的按钮*/
@property(nonatomic ,assign)CGRect topButton;
/**评论的内容*/
@property(nonatomic ,assign)CGRect summaryLaelF;
/**图片的view*/
@property(nonatomic ,assign)CGRect photosImgViewF;
/**视频的图片*/
@property(nonatomic ,assign)CGRect videoImageF;
/**视频的播放按钮图片*/
@property(nonatomic ,assign)CGRect videoIconF;
/**带视频的图片的整体背景*/
@property (nonatomic ,assign) CGRect backViewF;
/**评论的整体背景*/
@property(nonatomic ,assign)CGRect messageBackViewF;

@property(nonatomic ,assign)CGFloat cellHight;

@property (nonatomic ,assign)CGFloat videopicCellHight;

@property (nonatomic ,assign)CGFloat originalH;

@property (nonatomic ,retain)UILabel* summaryLabel;

@property (nonatomic, assign) CGRect longLineF;

@property (nonatomic, assign) CGRect topLineF;

@property (nonatomic, assign) CGRect bottomLineF;

@property (nonatomic, assign) CGRect middleImageF;
@end
