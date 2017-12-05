//
//  PDFpassWordView.h
//  FounderReader-2.5
//
//  Created by ld on 16/1/19.
//
//

#import <UIKit/UIKit.h>

@protocol PDFpassWordViewDelegate <NSObject>

-(void)postPDFpasswordFinished;

@end

@interface PDFpassWordView : UIView

@property(nonatomic,assign) id<PDFpassWordViewDelegate> delegate;
@property(nonatomic,retain) UITextField *pwTextField;

@end
