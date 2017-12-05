//
//  PDFpassWordView.m
//  FounderReader-2.5
//
//  Created by ld on 16/1/19.
//
//

#import "PDFpassWordView.h"
#import "HttpRequest.h"
#import "AppConfig.h"
#import "UIAlertView+Helper.h"


@interface PDFpassWordView ()
{
   
}

@end


@implementation PDFpassWordView
@synthesize pwTextField,delegate;

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
        
        UIImageView *bgIMG = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"bg_dialog_epaper"]];
        bgIMG.frame = CGRectMake(0, 0, kSWidth-120, 250);
        bgIMG.center = self.center;
        [self addSubview:bgIMG];
        
        float pointX = 30;
        pwTextField = [[UITextField alloc] initWithFrame:CGRectMake(pointX, 25, kSWidth-145-pointX, 50)];
        self.pwTextField.borderStyle = UITextBorderStyleRoundedRect;
        self.pwTextField.backgroundColor = [UIColor colorWithRed:0xF5/255.0 green:0xF5/255.0 blue:0xF5/255.0 alpha:1];
        self.pwTextField.font = [UIFont systemFontOfSize:17];
        self.pwTextField.placeholder = @"报卡号";
        self.pwTextField.tag = 101;
        self.pwTextField.enabled = YES;
        self.pwTextField.userInteractionEnabled = YES;
        [self.pwTextField becomeFirstResponder];
        [bgIMG addSubview:self.pwTextField];
        
        UILabel *phoneLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, 80, kSWidth-50, 30)];
        phoneLabel.font = [UIFont systemFontOfSize:15];
        phoneLabel.tag = 102;
        phoneLabel.text = @"联系电话：400-98789878";
        phoneLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        [bgIMG addSubview:phoneLabel];
        
        
        UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(kSWidth/2-20, bgIMG.frame.size.height + bgIMG.frame.origin.y +5, 50, 50)];
        [cancelButton setBackgroundImage:[UIImage imageNamed:@"bg_epaper_close"] forState:UIControlStateNormal];
        cancelButton.tag = 103;
        [cancelButton addTarget:self action:@selector(cancelPassWord) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:cancelButton];
        
        UIButton *okButton = [[UIButton alloc] initWithFrame:CGRectMake(kSWidth/2-45, bgIMG.frame.size.height + bgIMG.frame.origin.y-65, bgIMG.frame.size.width/3, 40)];
        [okButton setTitle:@"确认" forState:UIControlStateNormal];
        [okButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        okButton.tag = 104;
        [okButton addTarget:self action:@selector(okPassWord) forControlEvents:UIControlEventTouchUpInside];
        okButton.backgroundColor = [UIColor colorWithRed:245/255.0 green:67/255.0 blue:67/255.0 alpha:1];
        okButton.layer.cornerRadius = 20;
        okButton.layer.borderWidth = 0.5;
        okButton.layer.borderColor = [[UIColor colorWithRed:245/255.0 green:67/255.0 blue:67/255.0 alpha:1]CGColor];
        [self addSubview:okButton];
        
        
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeAway)];
        [self addGestureRecognizer:recognizer];
    }
    return self;
}

-(void)cancelPassWord
{
    [self removeAway];
}

-(void)okPassWord
{
    [self postPdfPassWord];
}

-(void)removeAway
{
    [self removeFromSuperview];
}

- (void)postPdfPassWord
{

}
@end
