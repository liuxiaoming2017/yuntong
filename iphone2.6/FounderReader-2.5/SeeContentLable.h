//
//  SeeContentLable.h
//  FounderReader-2.5
//
//  Created by yanbf on 16/10/17.
//
//

#import <UIKit/UIKit.h>
#import "SeeViewmodel.h"
#import "TopDiscussmodel.h"


@interface SeeContentLable : UIView 

@property (nonatomic, assign) int fileid;
@property (nonatomic, assign) int aid;
@property (nonatomic, strong) UILabel *contentLable;
//@property (nonatomic, assign) int articleType;
@property (nonatomic, retain) SeeViewmodel *mainModel;
@property (nonatomic, copy) NSString *msg; // 直播未发布的字段

@property (nonatomic, retain) TopDiscussmodel *discussmodel;

-(void)creatContentLableView;
@end
