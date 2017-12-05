//
//  DirectFram.h
//  FounderReader-2.5
//
//  Created by 周志扬 on 15/8/19.
//
//

#import <Foundation/Foundation.h>
#import "SeeViewmodel.h"
@interface DirectFram : NSObject
//背景的
@property(nonatomic,assign)CGRect groundViewF;
//头像
@property(nonatomic,assign)CGRect userHeaderViewF;
//用户名
@property(nonatomic,assign)CGRect userNameF;
//发布时间的小图标
@property(nonatomic,assign)CGRect timerViewF;
//发布的时间
@property(nonatomic,assign)CGRect timeLabelF;
//参与人数
@property(nonatomic,assign)CGRect peopleNumberF;
//地址
@property(nonatomic,assign)CGRect addressLabelF;
//距离
@property(nonatomic,assign)CGRect distanceF;
//显示的描述标题
@property(nonatomic,assign)CGRect describelabelF;
//下面内容的描述
@property(nonatomic,assign)CGRect contentlabelF;
//button上的图片
@property(nonatomic,assign)CGRect buttonImage;

//button上的文字
@property(nonatomic,assign)CGRect buttonLabel;
//展开的按钮
@property(nonatomic,assign)CGRect buttonF;
//隐藏的九张图片
@property(nonatomic,assign)CGRect photosImageF;


//下面的描述的背景view
@property(nonatomic ,assign)CGRect originalViewF;

//数据模型
@property (nonatomic,retain)SeeViewmodel *directtop;
/** 点击展开的cell的高度*/
@property (nonatomic ,assign) CGFloat btnCellHeight;
/** 展开后cell 的高度*/
@property (nonatomic ,assign) CGFloat cellHeight;

@property (nonatomic ,assign) CGFloat originalH ;

@property (nonatomic ,assign) CGRect viedeoImageF;
@end
