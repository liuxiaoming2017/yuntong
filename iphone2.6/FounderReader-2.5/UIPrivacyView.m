//
//  UIPrivacyView.m
//  FounderReader-2.5
//
//  Created by zhou.zy on 14-11-7.
//
//

#import "UIPrivacyView.h"
#import "ColorStyleConfig.h"
#import "NewsListConfig.h"

@implementation UIPrivacyView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        self.backgroundColor = [UIColor whiteColor];
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[Global getAppIcon]];
        imageView.frame = CGRectMake(30,50,50,50);
        [self addSubview:imageView];
        
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(100, 50, kSWidth-120, 25)];
        title.textColor = UIColorFromString([ColorStyleConfig sharedColorStyleConfig].tabbar_titlecolorstring_diselect);
        title.backgroundColor = [UIColor clearColor];
        title.font = [UIFont boldSystemFontOfSize:20];
        title.text = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
        [self addSubview:title];
 
        UILabel *title1 = [[UILabel alloc] initWithFrame:CGRectMake(100, 75, kSWidth-120, 25)];
        title1.textColor = UIColorFromString([ColorStyleConfig sharedColorStyleConfig].tabbar_titlecolorstring_diselect);
        title1.backgroundColor = [UIColor clearColor];
        title1.font = [UIFont boldSystemFontOfSize:16];
        title1.text = @"Macao Daily News";
        [self addSubview:title1];
        
        UILabel *title2 = [[UILabel alloc] initWithFrame:CGRectMake(20, 110, kSWidth-40, 100)];
        title2.numberOfLines = 3;
        title2.text = NSLocalizedString(@"在您使用本应用程式之前，须先阅读、明白并同意以下各条款及细则：",nil);
        title2.textColor = [UIColor colorWithRed:35/255.0 green:35/255.0 blue:35/255.0 alpha:1.0];
        title2.backgroundColor = [UIColor clearColor];
        title2.font = [UIFont boldSystemFontOfSize:18];
        [self addSubview:title2];
        
        UIButton *button3 = [UIButton buttonWithType:UIButtonTypeSystem];
        [button3 setTitle:NSLocalizedString(@"使用条款",nil) forState:UIControlStateNormal];
       
        button3.tintColor = [UIColor colorWithRed:19/255.0 green:183/255.0 blue:246/255.0 alpha:1.0];
        button3.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        button3.backgroundColor = [UIColor clearColor];
        button3.frame = CGRectMake(20, 220, 100, 40);
        [button3 addTarget:self action:@selector(showTiaokuan) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button3];

        UIButton *button4 = [UIButton buttonWithType:UIButtonTypeSystem];
        [button4 setTitle:NSLocalizedString(@"隐私政策",nil) forState:UIControlStateNormal];
        button4.tintColor = [UIColor colorWithRed:19/255.0 green:183/255.0 blue:246/255.0 alpha:1.0];
        button4.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        button4.backgroundColor = [UIColor clearColor];
        button4.frame = CGRectMake(20, 260, 100, 40);
        [button4 addTarget:self action:@selector(showZhengce) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button4];
        
        UIButton *_smallButton =[UIButton buttonWithType:UIButtonTypeCustom];
        _smallButton.frame = CGRectMake(20, 335, 20, 20);
        [_smallButton setImage:[UIImage imageNamed:@"checkbox_press"] forState:UIControlStateNormal];
        [_smallButton setImage:[UIImage imageNamed:@"checkbox_press"] forState:UIControlStateSelected];
        [self addSubview:_smallButton];
        UILabel *title5 = [[UILabel alloc] initWithFrame:CGRectMake(50, 320, kSWidth-70, 50)];
        title5.numberOfLines = 2;
        title5.text = NSLocalizedString(@"本人明白并同意以上条款及细则",nil);//✅
        title5.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
        title5.backgroundColor = [UIColor clearColor];
        title5.font = [UIFont boldSystemFontOfSize:16];
        [self addSubview:title5];

        UIButton *buttonAggree = [UIButton buttonWithType:UIButtonTypeCustom];
        buttonAggree.frame = CGRectMake(kSWidth/4-40, kSHeight-80, 80, 35);
        buttonAggree.layer.cornerRadius = 3;
        buttonAggree.layer.borderWidth = 1;
        [buttonAggree setTitle:NSLocalizedString(@"同意",nil) forState:UIControlStateNormal];
        buttonAggree.layer.borderColor = UIColorFromString([ColorStyleConfig sharedColorStyleConfig].tabbar_titlecolorstring_diselect).CGColor;
        [buttonAggree setTintColor:[UIColor colorWithRed:0xff/255.0 green:0xff/255.0 blue:0xff/255.0 alpha:1]];
        buttonAggree.titleLabel.font = [UIFont fontWithName:[Global fontName] size:[NewsListConfig sharedListConfig].middleActiveCellTitleFontSize];
        [buttonAggree setTitleColor:UIColorFromString([ColorStyleConfig sharedColorStyleConfig].tabbar_titlecolorstring_diselect) forState:UIControlStateNormal];
        [self addSubview:buttonAggree];
        [buttonAggree addTarget:self action:@selector(Aggree) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *buttoncancel = [UIButton buttonWithType:UIButtonTypeCustom];
        buttoncancel.frame = CGRectMake(kSWidth/4*3-40, kSHeight-80, 80, 35);
        buttoncancel.layer.cornerRadius = 3;
        buttoncancel.layer.borderWidth = 1;
        buttoncancel.layer.borderColor = UIColorFromString([ColorStyleConfig sharedColorStyleConfig].tabbar_titlecolorstring_diselect).CGColor;
        [buttoncancel setTitle:NSLocalizedString(@"离开",nil) forState:UIControlStateNormal];
        buttoncancel.titleLabel.font = [UIFont fontWithName:[Global fontName] size:[NewsListConfig sharedListConfig].middleActiveCellTitleFontSize];
        [buttoncancel setTitleColor:UIColorFromString([ColorStyleConfig sharedColorStyleConfig].tabbar_titlecolorstring_diselect) forState:UIControlStateNormal];
        [buttoncancel addTarget:self action:@selector(exitApplication) forControlEvents:UIControlEventTouchUpInside];
        buttoncancel.userInteractionEnabled=YES;
        [self addSubview:buttoncancel];
    }
    return self;
}

-(void)Aggree{
   
    [self removeFromSuperview];
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"IsAggreePrivacyPage"];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

-(void)showTiaokuan{
 
    UIView *bkview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    bkview.backgroundColor = [UIColor whiteColor];
    bkview.tag = 1000;
    [self addSubview:bkview];
    
    UITextView *showTiaokuan = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height-40)];
    showTiaokuan.textColor = [UIColor colorWithRed:35/255.0 green:35/255.0 blue:35/255.0 alpha:1.0];
    showTiaokuan.font = [UIFont systemFontOfSize:16];
    NSString *strText = [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"tiaokuan"ofType:@"txt"]] encoding:NSUTF8StringEncoding];
    showTiaokuan.text = strText;
    showTiaokuan.tag = 1001;
    showTiaokuan.editable = NO;
    [self addSubview:showTiaokuan];
    
    UIButton *buttoncancel = [UIButton buttonWithType:UIButtonTypeCustom];
    buttoncancel.frame = CGRectMake(kSWidth/2-40, kSHeight-35, 80, 30);
    buttoncancel.layer.cornerRadius = 3;
    buttoncancel.layer.borderWidth = 1;
    buttoncancel.layer.borderColor = UIColorFromString([ColorStyleConfig sharedColorStyleConfig].tabbar_titlecolorstring_diselect).CGColor;
    [buttoncancel setTitle:NSLocalizedString(@"关闭",nil) forState:UIControlStateNormal];
    buttoncancel.titleLabel.font = [UIFont fontWithName:[Global fontName] size:[NewsListConfig sharedListConfig].middleActiveCellTitleFontSize];
    [buttoncancel setTitleColor:UIColorFromString([ColorStyleConfig sharedColorStyleConfig].tabbar_titlecolorstring_diselect) forState:UIControlStateNormal];
    [buttoncancel addTarget:self action:@selector(close:) forControlEvents:UIControlEventTouchUpInside];
    buttoncancel.userInteractionEnabled=YES;
    [self addSubview:buttoncancel];
}


-(void)showZhengce{
  
    UIView *bkview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    bkview.backgroundColor = [UIColor whiteColor];
    bkview.tag = 1000;
    [self addSubview:bkview];
    
    UITextView *showTiaokuan = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height-40)];
    showTiaokuan.textColor = [UIColor colorWithRed:35/255.0 green:35/255.0 blue:35/255.0 alpha:1.0];
    showTiaokuan.font = [UIFont systemFontOfSize:16];
    NSString *strText = [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"zhengce"ofType:@"txt"]] encoding:NSUTF8StringEncoding];
    showTiaokuan.text = strText;
    showTiaokuan.tag = 1001;
    showTiaokuan.editable = NO;
    [self addSubview:showTiaokuan];
    
    UIButton *buttoncancel = [UIButton buttonWithType:UIButtonTypeCustom];
    buttoncancel.frame = CGRectMake(kSWidth/2-40, kSHeight-35, 80, 30);
    buttoncancel.layer.cornerRadius = 3;
    buttoncancel.layer.borderWidth = 1;
    buttoncancel.layer.borderColor = UIColorFromString([ColorStyleConfig sharedColorStyleConfig].tabbar_titlecolorstring_diselect).CGColor;
    [buttoncancel setTitle:NSLocalizedString(@"关闭",nil) forState:UIControlStateNormal];
    buttoncancel.titleLabel.font = [UIFont fontWithName:[Global fontName] size:[NewsListConfig sharedListConfig].middleActiveCellTitleFontSize];
    [buttoncancel setTitleColor:UIColorFromString([ColorStyleConfig sharedColorStyleConfig].tabbar_titlecolorstring_diselect) forState:UIControlStateNormal];
    [buttoncancel addTarget:self action:@selector(close:) forControlEvents:UIControlEventTouchUpInside];
    buttoncancel.userInteractionEnabled=YES;
    [self addSubview:buttoncancel];
}


-(void)close:(id) sender{
    
    UIView *view1 = [self viewWithTag:1000];
    [view1 removeFromSuperview];
    UIView *view2 = [self viewWithTag:1001];
    [view2 removeFromSuperview];
    UIButton *button = (UIButton *)sender;
    [button removeFromSuperview];
}

- (void)exitApplication {
    
    UIWindow *window = appDelegate().window;
    
    [UIView animateWithDuration:1.0f animations:^{
        window.alpha = 0;
        window.frame = CGRectMake(0, window.bounds.size.width, 0, 0);
    } completion:^(BOOL finished) {
        exit(0);
    }];
    
}
@end
