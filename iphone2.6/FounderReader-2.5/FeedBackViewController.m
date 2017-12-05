//
//  FeedBackViewController.m
//  FounderReader-2.5
//
//  Created by lx on 15/9/15.
//
//

#import "FeedBackViewController.h"
#import "AppStartInfo.h"
#import "NSString+Helper.h"
#import "UserAccountDefine.h"
#import "FCReader_OpenUDID.h"
#import "HttpRequest.h"
#import "InformAttachment.h"
#import "YXLoginViewController.h"
#import "SearchTableViewController.h"
#import "shareCustomView.h"
#import "NewsListConfig.h"
#import "NSArray+Plist.h"
#import "ColumnBarConfig.h"
#import "ColorStyleConfig.h"

#define leftGap 10
#define topGap 12
#define labelHeight 30
#define freeHeight 44
#define placeString NSLocalizedString(@"说点什么吧...",nil)

@implementation FeedBackViewController

@synthesize contentTextView =  _contentTextView;

- (void)viewWillAppear:(BOOL)animated
{
    [self rightPageNavTopButtons];
    
    [super viewWillAppear:animated];
    navTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
    navTitleLabel.text = NSLocalizedString(@"意见反馈",nil);
    navTitleLabel.font = [UIFont systemFontOfSize:18];
    navTitleLabel.textAlignment = NSTextAlignmentCenter;
    navTitleLabel.backgroundColor = [UIColor clearColor];
    navTitleLabel.textColor = [ColorStyleConfig sharedColorStyleConfig].navbar_titlecolor_selected;
    self.navigationItem.titleView = navTitleLabel;
    
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftButton setImage:[UIImage imageNamed:@"nav_bar_back"] forState:UIControlStateNormal];
    [leftButton sizeToFit];
    leftButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    leftButton.contentEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
    [leftButton addTarget:self action:@selector(goBackIOS6) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    UIButton *send = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 31*proportion, 30*proportion)];
    [send setTitle:NSLocalizedString(@"发送",nil) forState:UIControlStateNormal];
    send.titleLabel.font = [UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleCellTitleFontSize ];
    [send setTitleColor:[ColorStyleConfig sharedColorStyleConfig].navbar_titlecolor_selected forState:UIControlStateNormal];
    send.backgroundColor = [UIColor clearColor];
    [send addTarget:self action:@selector(send:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc]initWithCustomView:send];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
}

-(void)goRightPageBack
{

    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    //内容
    UIImageView *contentBgView = [[UIImageView alloc] initWithFrame:CGRectMake(leftGap,topGap,kSWidth - 2 * leftGap, 240*proportion)];
    contentBgView.layer.borderWidth = 1;
    contentBgView.layer.borderColor = [UIColor clearColor].CGColor;
    [self.view addSubview:contentBgView];
    UIView * view = [[UIView alloc]initWithFrame:CGRectMake(0, 180*proportion, kSWidth, 1)];
    view.backgroundColor = UIColorFromString(@"237,237,237");    [self.view addSubview:view];
    UILabel *wordCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(kSWidth - 70, CGRectGetMaxY(view.frame)+10, 100, 15)];
    wordCountLabel.tag = 123;
    wordCountLabel.text = @" 0 / 1000";
    wordCountLabel.font=[UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleCellDateFontSize];
    wordCountLabel.textColor=[UIColor grayColor];
    [self.view addSubview:wordCountLabel];

    UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, 0, 0, labelHeight)];
    contentLabel.font = [UIFont systemFontOfSize:13];
    [contentBgView addSubview:contentLabel];
    
    contentBgView.userInteractionEnabled = YES;
    _contentTextView = [[UITextView alloc] initWithFrame:CGRectMake(2, 0, kSWidth-20, 150*proportion)];
    _contentTextView.backgroundColor = [UIColor clearColor];
    _contentTextView.text = placeString;
    _contentTextView.delegate = self;
    _contentTextView.font = [UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleCellDateFontSize+2];
    _contentTextView.textColor = [UIColor colorWithRed:160/255.0 green:160/255.0 blue:160/255.0 alpha:1.0];
    [contentBgView addSubview:_contentTextView];
    
    lengthLabel = [[UILabel alloc]initWithFrame:CGRectMake(160, 110, 80, 20)];
    lengthLabel.backgroundColor = [UIColor clearColor];
    lengthLabel.font = [UIFont systemFontOfSize:13];
    lengthLabel.textColor = [UIColor lightGrayColor];
    [contentBgView addSubview:lengthLabel];

}

-(void)back:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:placeString]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if (textView.text.length<1) {
        textView.text = placeString;
        textView.textColor = [UIColor colorWithRed:160/255.0 green:160/255.0 blue:160/255.0 alpha:1.0];
    }
}

- (void)textViewDidChange:(UITextView *)textView {
    NSInteger number = [textView.text length];
    UILabel *label = (UILabel *)[self.view viewWithTag:123];
    label.text = [NSString stringWithFormat:@" %lu / 1000",(unsigned long)textView.text.length];
    if (number > 1000) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"字符个数不能大于1000" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        textView.text = [textView.text substringToIndex:1000];
 
    }
}

#pragma mark - send methods

- (void)sendInformInfo
{
  
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *userName = [defaults stringForKey:KuserAccountNickName];
    if (userName == nil || [userName isEqualToString:@""]) {
        userName = NSLocalizedString(@"手机用户",nil);
    }
    NSString *userId = [Global userId];
    if (!userId.length) {
        userId = @"0";
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@/api/feedBack",[AppConfig sharedAppConfig].serverIf];
    NSString *content = _contentTextView.text;
    NSString *bodyString = nil;
    if (![content isEqualToString:placeString] && ![content isEqualToString:@""] && content != nil) {
        bodyString = [NSString stringWithFormat:@"sid=%@&content=%@&userID=%@&userName=%@",[AppConfig sharedAppConfig].sid,content,userId,userName];
    }
    else
    {
        return;
    }
    NSData *data = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    [Global showTipAlways:NSLocalizedString(@"正在发送...",nil)];
    NSURL *url = [NSURL URLWithString:urlString];
    HttpRequest *request = [HttpRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:data];
    [request setCompletionBlock:^(NSData *data)
    {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers  error:nil];
        if ([[dic objectForKey:@"success"] boolValue]) {
            [Global showTip:NSLocalizedString(@"您的意见已经收到，非常感谢。",nil)];
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [Global showTipNoNetWork];
        }
    }];
    
    [request setFailedBlock:^(NSError *error) {
        [Global showTipNoNetWork];
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    [request startAsynchronous];
    
}

- (void)send:(id)sender
{
    _contentTextView.text = [_contentTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *content = _contentTextView.text;
    if (content.length == 0 || [content compare:placeString] == NSOrderedSame) {
        [Global showTip:NSLocalizedString(@"内容不能为空",nil)];
        return;
    }
    
    [self sendInformInfo];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

@end
