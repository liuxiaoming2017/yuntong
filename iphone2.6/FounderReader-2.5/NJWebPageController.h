//
//  NJWebPageController.h
//  FounderReader-2.5
//
//  Created by ld on 15-9-9.
//
//

#import "Column.h"
@interface NJWebPageController : UIViewController

@property (nonatomic, retain) Column *parentColumn;
@property (nonatomic, assign) BOOL isShowHtmlTitle; //是否显示网页中的文档title
@property (nonatomic, assign) BOOL hiddenClose;      //隐藏关闭按钮
@property (nonatomic, assign) BOOL isFromModal;      //是否来自于模态形式

@end
