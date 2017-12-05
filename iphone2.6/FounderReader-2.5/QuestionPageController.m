//
//  QuestionPageController.m
//  FounderReader-2.5
//
//  Created by ld on 15-4-23.
//
//

#import "QuestionPageController.h"
#import "AppStartInfo.h"
#import "NSString+Helper.h"
#import "UserAccountDefine.h"
#import "FCReader_OpenUDID.h"
#import "HttpRequest.h"
#import "InformAttachment.h"
#import "YXLoginViewController.h"
#import "SearchTableViewController.h"
#import "Article.h"
#import <AVFoundation/AVFoundation.h>
#import <AVFoundation/AVAssetImageGenerator.h>
#import <AVFoundation/AVAsset.h>
#import "NSArray+Plist.h"
#import "ColorStyleConfig.h"
#import "NJWebPageController.h"
#import "FounderDetailPackage.h"
#import "ColumnBarConfig.h"

#define titleHoldPlaceText NSLocalizedString(@"提问标题 (20字以内)",nil)
#define phoneHoldPlaceText NSLocalizedString(@"联系电话",nil)
#define realNameHoldPlaceText NSLocalizedString(@"联系人",nil)
#define columnHoldSectionText NSLocalizedString(@"选择部门",nil)
#define columnHoldPlaceText   NSLocalizedString(@"选择类型",nil)
#define contentHoldPlaceText  NSLocalizedString(@"请输入报料内容",nil)
#define leftGap 10
#define topGap 12
#define labelHeight 30

#define kName_JUDGE            @"name_JUDGE "
#define kPhoneEmail_JUDGE       @"phoneEmail_JUDGE "
#define kTitle_JUDGE            @"title_JUDGE "
#define kContent_JUDGE          @"content_JUDGE "
#define kSaveDate_JUDGE         @"saveDate_JUDGE "

#define kBaoliaoPhone           @"baoliaoPhone"
#define kBaoliaoUser            @"baoliaoUser"

#define freeHeight 44

@interface QuestionPageController ()<UITableViewDelegate,UITableViewDataSource,SearchTableViewDelegate>
{
    UIImageView *duihaoImg1;
    UIImageView *duihaoImg2;
    UIImageView *duihaoImg3;
    UIImageView *duihaoImg4;
    UIButton *xiansuoBtn;
    UIButton *toushuBtn;
    UIButton *jianjuBtn;
    UIButton *hellpBtn;
}
@property(nonatomic,retain) UITableView *selectTV;
@property(nonatomic,retain) NSArray *columnValue;


@end

@implementation QuestionPageController
@synthesize selectButton,selectTV,columnValue,selectSectionButton;
@synthesize currentColumn;
@synthesize photoButton;


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    navTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
    navTitleLabel.text = NSLocalizedString(@"报料",nil);
    navTitleLabel.font = [UIFont systemFontOfSize:18];
    navTitleLabel.textAlignment = NSTextAlignmentCenter;
    navTitleLabel.textColor = [ColorStyleConfig sharedColorStyleConfig].navbar_titlecolor_selected;
    navTitleLabel.backgroundColor = [UIColor clearColor];
    self.navigationItem.titleView = navTitleLabel;
}
- (void)viewDidLoad
{
    self.view.backgroundColor = [UIColor whiteColor];
    checkArrow = YES;
    
    // 内容必填
    if (IS_IPHONE_4) {
        _contentBgView = [[UIImageView alloc] initWithFrame:CGRectMake(10+leftGap,topGap,kSWidth-30, 80)];
    }
    else if(IS_IPHONE_5)
    {
        _contentBgView = [[UIImageView alloc] initWithFrame:CGRectMake(10+leftGap,topGap,kSWidth-30, 100)];
    }
    else
    {
        _contentBgView = [[UIImageView alloc] initWithFrame:CGRectMake(10+leftGap,topGap,kSWidth-30, 130)];
    }

    [self.view addSubview:_contentBgView];
    _contentBgView.userInteractionEnabled = YES;

    //上传图片
    photoButton = [[UIButton alloc] init];
    [self.photoButton setBackgroundImage:[UIImage imageNamed:@"addPhoto2"] forState:UIControlStateNormal];
    [self.photoButton addTarget:self action:@selector(pickPhotos:) forControlEvents:UIControlEventTouchUpInside];
    
    // sub scrollview
    if (IS_IPHONE_4) {
        hScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(10+leftGap, _contentBgView.frame.origin.y+_contentBgView.bounds.size.height+topGap, kSWidth-30, 80)];
    }
    else if(IS_IPHONE_5)
    {
        hScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(10+leftGap, _contentBgView.frame.origin.y+_contentBgView.bounds.size.height+topGap, kSWidth-30, 150)];
    }
    else
    {
        hScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(10+leftGap, _contentBgView.frame.origin.y+_contentBgView.bounds.size.height+topGap, kSWidth-30, 200)];
    }
    
    hScrollView.showsHorizontalScrollIndicator = NO;
    hScrollView.showsVerticalScrollIndicator = NO;
    hScrollView.alwaysBounceHorizontal = NO;
    hScrollView.alwaysBounceVertical = YES;
    hScrollView.scrollsToTop = YES;
    hScrollView.delegate = self;
    hScrollView.layer.borderWidth = 1;
    hScrollView.layer.borderColor = UIColorFromString(@"234,234,234").CGColor;
    [self.view addSubview:hScrollView];
    
    
    // 姓名
    self.starlableName = [[UILabel alloc] init];
    self.starlableName.frame = CGRectMake(8, 5+hScrollView.frame.size.height + hScrollView.frame.origin.y+topGap, 12, 25);
    self.starlableName.textColor = [ColumnBarConfig sharedColumnBarConfig].column_all_color;
    self.starlableName.textAlignment = NSTextAlignmentCenter;
    self.starlableName.text = @"*";
    [self.view addSubview:self.starlableName];
    
    
    self.subjectBgView = [[UIImageView alloc] initWithFrame:CGRectMake(10+leftGap, hScrollView.frame.size.height + hScrollView.frame.origin.y+topGap, kSWidth-30, labelHeight)];
    self.subjectBgView.layer.borderWidth = 1;
    self.subjectBgView.layer.borderColor = UIColorFromString(@"234,234,234").CGColor;
    [self.view addSubview:self.subjectBgView];
    
    self.subjectBgView.userInteractionEnabled = YES;
    UILabel *realNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, 0, 0, labelHeight)];
    realNameLabel.font = [UIFont systemFontOfSize:13];
    [self.subjectBgView addSubview:realNameLabel];
    
    
    subjectField = [[UITextField alloc] initWithFrame:CGRectMake(5, 0, kSWidth-50, labelHeight)];
    subjectField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    subjectField.placeholder = realNameHoldPlaceText;
    subjectField.returnKeyType = UIReturnKeyDone;
    subjectField.delegate = self;
    subjectField.font = [UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleCellTitleFontSize-3];
    [self.subjectBgView addSubview:subjectField];
    
    
    
    // 手机
    self.starlablePhone = [[UILabel alloc] init];
    self.starlablePhone.frame = CGRectMake(8, 5+labelHeight + self.subjectBgView.frame.origin.y+topGap, 12, 25);
    self.starlablePhone.textColor = [ColumnBarConfig sharedColumnBarConfig].column_all_color;
    self.starlablePhone.textAlignment = NSTextAlignmentCenter;
    self.starlablePhone.text = @"*";
    [self.view addSubview:self.starlablePhone];
    
    
    self.phBgView = [[UIImageView alloc] initWithFrame:CGRectMake(10+leftGap, labelHeight + self.subjectBgView.frame.origin.y+topGap, kSWidth-30, labelHeight)];
    self.phBgView.layer.borderWidth = 1;
    self.phBgView.layer.borderColor = UIColorFromString(@"234,234,234").CGColor;
    [self.view addSubview:self.phBgView];
    
    self.phBgView.userInteractionEnabled = YES;
    
    UILabel *phLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, 0, 0, labelHeight)];
    phLabel.font = [UIFont systemFontOfSize:13];
    
    phoneNoField = [[UITextField alloc] initWithFrame:CGRectMake(5, 0, kSWidth-50, labelHeight)];
    phoneNoField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    phoneNoField.placeholder = phoneHoldPlaceText;
    phoneNoField.keyboardType = UIKeyboardTypePhonePad;
    phoneNoField.font = [UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleCellTitleFontSize-3];
    phoneNoField.delegate = self;
    [self.phBgView addSubview:phoneNoField];
    
    // 服务条款
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    //    CFShow(infoDictionary);
    NSString *appTermName = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    
    NSString *checkLable1 = NSLocalizedString(@"已阅读并同意",nil);
    NSString *checkLabel2 = [NSString stringWithFormat:@"“%@”%@",appTermName,  NSLocalizedString(@"服务协议",nil)];
    self.userView=[[UIView alloc]initWithFrame:CGRectMake(self.phBgView.frame.origin.x, self.phBgView.frame.origin.y+self.phBgView.frame.size.height, kSWidth-20, 30)];
    _smallButton=[UIButton buttonWithType:UIButtonTypeCustom];
    float buttonWidth = [FounderDetailPackage WidthWithText:checkLabel2 Font:[UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleCellDateFontSize] height:15*proportion];
    _smallButton.frame=CGRectMake(0, 8, 15*proportion, 15*proportion);
    [_smallButton setImage:[UIImage imageNamed:@"checkbox_normal"] forState:UIControlStateNormal];
    [_smallButton setImage:[UIImage imageNamed:@"checkbox_press"] forState:UIControlStateSelected];
    _smallButton.selected=YES;
    [_smallButton addTarget:self action:@selector(smallbtnClick) forControlEvents:UIControlEventTouchUpInside];
    UILabel *wordLabel=[[UILabel alloc]initWithFrame:CGRectMake(20*proportion, 10, 70 * proportion, 12*proportion)];
    wordLabel.text= checkLable1;
    wordLabel.font=[UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleCellDateFontSize];
    wordLabel.textColor = [UIColor grayColor];
    
    UIButton*userButton=[UIButton buttonWithType:UIButtonTypeCustom];
    userButton.frame=CGRectMake(wordLabel.frame.origin.x+wordLabel.frame.size.width, 10, buttonWidth, 12*proportion);
    userButton.titleLabel.font = [UIFont systemFontOfSize: [NewsListConfig sharedListConfig].middleCellDateFontSize];
    [userButton setTitle:checkLabel2 forState:UIControlStateNormal];
    [userButton setTitleColor:[ColumnBarConfig sharedColumnBarConfig].column_all_color forState:UIControlStateNormal];
    [userButton addTarget:self action:@selector(userbtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.userView addSubview:userButton];
    [self.userView addSubview:wordLabel];
    [self.userView addSubview:_smallButton];
    
    [self.view addSubview:self.userView];
    
    
    
    sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [sendButton setBackgroundColor:[ColumnBarConfig sharedColumnBarConfig].column_all_color];
    //    sendButton.frame = CGRectMake(leftGap, kSHeight - 100, 300, 40) ;
    sendButton.frame = CGRectMake(leftGap, CGRectGetMaxY(self.userView.frame) + 10, kSWidth-20, 40) ;
    
    [sendButton setTitle:NSLocalizedString(@"提交",nil) forState:UIControlStateNormal];
    [sendButton addTarget:self action:@selector(send:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sendButton];
    
    
    scrollView.contentSize = CGSizeMake(kSWidth, hScrollView.frame.size.height + hScrollView.frame.origin.y+170);
    scrollView.userInteractionEnabled = YES;
    
    [self clearForm];
    
    selectTV = [[UITableView alloc] init];
    self.selectTV.delegate = self;
    self.selectTV.dataSource = self;
    self.selectTV.layer.borderWidth = .5;
    self.selectTV.layer.borderColor = UIColorFromString(@"64,83,112").CGColor;
    self.selectTV.layer.cornerRadius = 1;//弧度
    self.selectTV.separatorStyle = NO;
    
    [self findColumns:self.currentColumn];
}
-(void)smallbtnClick{
    _smallButton.selected=!_smallButton.selected;
    
}
-(void)goRightPageBack{
    
    if ((contentTextView.text.length > 0 && [contentTextView.text isEqualToString:NSLocalizedString(@"请输入报料内容",nil)] == NO)
        || [informAttachments count] > 0) {
        UIAlertView *showalert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"是否放弃编辑?",nil) message:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"取消",nil) otherButtonTitles:NSLocalizedString(@"确定",nil), nil];
        [showalert show];
        showalert.tag = 11111;
        return;
    }
    
    //    [self.navigationController dismissModalViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES
                             completion:^{
                                 
                             }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 11111 && buttonIndex == 1){
        
        [self dismissViewControllerAnimated:YES
                                 completion:^{
                                     
                                 }];
    }
}

-(void)userbtnClick
{
    NJWebPageController *controller = [[NJWebPageController alloc] init];
    Column *column = [[Column alloc] init];
    column.linkUrl = [NSString stringWithFormat:@"%@/protocol.html",[AppStartInfo sharedAppStartInfo].configUrl];
    column.columnName = NSLocalizedString(@"服务协议",nil);
    controller.parentColumn = column;
    controller.hiddenClose = YES;
    controller.isFromModal = YES;
    [self presentViewController:[Global controllerToNav:controller] animated:YES completion:nil];   
}

-(void)back:(UIButton *)button
{
    //    [self.navigationController popViewControllerAnimated:YES];
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - localSave


-(void)saveInformTextLocalWithUserId
{
    saveInformDic = [[NSMutableDictionary alloc]init];
    
    [self saveInfoToLocation];
    
    if (self.informAttachments.count) {
        
        //[self.informAttachments writeToPlistFile:[self attachmentLocalPath]];
    }
    else{
        NSFileManager* manager = [NSFileManager defaultManager];
        if ([manager fileExistsAtPath:[self attachmentLocalPath]]) {
            [manager removeItemAtPath:[self attachmentLocalPath] error:nil];
        }
    }
}

-(void)saveInfoToLocation
{
    if (![NSString isNilOrEmpty:nameField.text]) {
        [self.saveInformDic setObject:nameField.text forKey:kTitle_JUDGE];
    }
    if (![NSString isNilOrEmpty:phoneNoField.text]) {
        [self.saveInformDic setObject:phoneNoField.text forKey:kPhoneEmail_JUDGE];
    }
    if (![NSString isNilOrEmpty:subjectField.text]) {
        [self.saveInformDic setObject:subjectField.text forKey:kName_JUDGE];
    }
    
    if ([contentTextView hasText] && ![contentTextView.text isEqualToString:contentHoldPlaceText] ) {
        [self.saveInformDic setObject:contentTextView.text forKey:kContent_JUDGE];
    }
    
    if (self.saveInformDic.count) {
        [self.saveInformDic setObject:[NSDate date] forKey:kSaveDate_JUDGE];
        [self.saveInformDic writeToFile:[self textLocalPath]
                             atomically:YES];
    }
    else{
        NSFileManager* manager = [NSFileManager defaultManager];
        if ([manager fileExistsAtPath:[self textLocalPath]]) {
            [manager removeItemAtPath:[self textLocalPath] error:nil];
        }
    }
}

-(void)saveUserInfo{
    
    [[NSUserDefaults standardUserDefaults] setObject:phoneNoField.text forKey:kBaoliaoPhone];
    [[NSUserDefaults standardUserDefaults] setObject:subjectField.text forKey:kBaoliaoUser];
}

-(void)updateLocalSaveContent
{
    [self updateLocationContent];
    
    [self reloadPreviewImages];
}

-(void)updateLocationContent
{
    NSString *userName = [Global userInfoByKey:KuserAccountNickName];
    NSString *userPhone = [Global userInfoByKey:KuserAccountPhone];
    NSString *phone = [[NSUserDefaults standardUserDefaults] objectForKey:kBaoliaoPhone];
    if(phone){
        userPhone = phone;
    }
    NSString *user = [[NSUserDefaults standardUserDefaults] objectForKey:kBaoliaoUser];
    if(user){
        userName = user;
    }
    
    NSString *nameText = [self textForKeyInform:kTitle_JUDGE];
    if (![NSString isNilOrEmpty:nameText]) {
        nameField.text = nameText;
        
    }else{
        nameField.placeholder = titleHoldPlaceText;
    }
    
    NSString *phoneText = [self textForKeyInform:kPhoneEmail_JUDGE];
    if (![NSString isNilOrEmpty:phoneText]) {
        phoneNoField.text = phoneText;
        
    }else{
        phoneNoField.text = userPhone;
        phoneNoField.placeholder = phoneHoldPlaceText;
    }
    
    NSString *titeText = [self textForKeyInform:kName_JUDGE];
    if (![NSString isNilOrEmpty:titeText]) {
        subjectField.text = titeText;
        
    }else{
        subjectField.text = userName;
        subjectField.placeholder = realNameHoldPlaceText;
    }
    
    NSString *contentText = [self textForKeyInform:kContent_JUDGE];
    if ([NSString isNilOrEmpty: contentText] || [contentText isEqualToString:contentHoldPlaceText]) {
        if(contentTextView.text.length == 0){
            contentTextView.text = contentHoldPlaceText;
            contentTextView.textColor = [UIColor colorWithRed:160/255.0 green:160/255.0 blue:160/255.0 alpha:1.0];      // placehoder color
        }
    }else{
        contentTextView.text = contentText;
        contentTextView.textColor = [UIColor blackColor];
    }
}

- (void)clearForm
{
    [self.selectButton setTitle:columnHoldPlaceText forState:UIControlStateNormal];
    [self.selectButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    nameField.text = @"";
    //phoneNoField.text = @"";
    //subjectField.text = @"";
    contentTextView.text = contentHoldPlaceText;
    contentTextView.textColor = [UIColor colorWithRed:160/255.0 green:160/255.0 blue:160/255.0 alpha:1.0];      // placehoder color
}

-(NSString *)textLocalPath
{
    NSString *path = [self textLocalPathForQAorJUDGE:kSaveJUDGETextFileName];
    
    return path;
}

-(NSString *)textLocalPathForQAorJUDGE:(NSString *)pathName
{
    NSString *userId = [Global userId];
    if ([NSString isNilOrEmpty:userId]) {
        userId = @"";
    }
    NSString *lastComponent = [NSString stringWithFormat:@"%@%@",pathName,userId];
    NSString *attachmentFilePath = [cacheDirPath() stringByAppendingPathComponent:lastComponent];
    return attachmentFilePath;
}

-(NSString *)attachmentLocalPath
{
    NSString *path = [self attachmentLocalPathForQAorJUDGE:kSaveJUDGEAttachmentsFileName];
    
    return path;
}

-(NSString *)attachmentLocalPathForQAorJUDGE:(NSString *)pathName
{
    NSString *userId = [Global userId];
    if ([NSString isNilOrEmpty:userId]) {
        userId = @"";
    }
    NSString *lastComponent = [NSString stringWithFormat:@"%@%@.plist",pathName,userId];
    NSString *attachmentFilePath = [cacheDirPath() stringByAppendingPathComponent:lastComponent];
    return attachmentFilePath;
}

-(void)columnSectionValueSelected
{
    SearchTableViewController *searchView = [[SearchTableViewController alloc] init];
    searchView.columns = self.columns;
    searchView.delegate = self;
    searchView.isSearch = NO;
    [self.navigationController pushViewController:searchView animated:YES];
}
#pragma mark - SearchTableViewDelegate

- (void)backValue:(int)columnID withName:(NSString *)columuName
{
    self.columnId = columnID;
    self.columnName = columuName;
    [self.selectSectionButton setTitle:columuName forState:UIControlStateNormal];
    self.selectSectionButton.frame = CGRectMake(3,0,300, labelHeight);
    [self.selectSectionButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 255)];
    [self.selectSectionButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
}
-(void)columnValueSelected
{
    if (!self.selectTV.superview) {
        [self.view addSubview:self.selectTV];
        self.selectTV.frame = CGRectMake(80+140,
                                         2*labelHeight + 2*topGap+20+freeHeight,
                                         90,
                                         0);
    }
    [UIView animateWithDuration:.3 animations:^{
        self.selectTV.frame = CGRectMake(80+140,
                                         2*labelHeight + 2*topGap+20+freeHeight,
                                         90,
                                         30*self.columnValue.count);
        
    } completion:^(BOOL finished) {
        
    }];
}

-(void)findColumns:(Column *)column
{
    //    NSArray *columnsArry = [[AppInfo sharedAppInfo].columnsPlistDic objectForKey:@"otherColumns"];
    ////    NSArray *columnsArry = @[@"123",@"233",@"1213"];
    //    for (NSDictionary * dic in columnsArry)
    //    {
    //        NSInteger columnId = [[dic objectForKey:@"ColumnId"] integerValue];
    //        if (columnId == column.columnId) {
    //
    //            NSString *columnStr = [dic objectForKey:@"ColumnValue"];
    //            self.columnValue = [columnStr componentsSeparatedByString:@";"];
    //            return ;
    //        }
    //    }
    
    self.columnValue = @[NSLocalizedString(@"建议",nil),NSLocalizedString(@"投诉",nil),NSLocalizedString(@"举报",nil)];
}


#pragma mark - table view delegate
- (CGFloat)tableView:(UITableView *)sender heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 30;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *name = [self.columnValue objectAtIndex:indexPath.row];
    name = [name stringByAppendingString:@"          "];
    [self.selectButton setTitle:name forState:UIControlStateNormal];
    self.selectButton.frame = CGRectMake(3,0,300, labelHeight);
    [self.selectButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 265)];
    [self.selectButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.selectTV removeFromSuperview];
}
#pragma mark - table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.columnValue.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"writeCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"writeCell"];
    }
    
    NSString *name = [self.columnValue objectAtIndex:indexPath.row];
    cell.textLabel.text = name;
    cell.textLabel.textAlignment = 1;
    cell.textLabel.textColor = UIColorFromString(@"64,83,112");
    cell.textLabel.font = [UIFont systemFontOfSize:13];
    
    return cell;
}


#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:contentHoldPlaceText])
        textView.text = @"";
    
    textView.textColor = [UIColor blackColor];       // normal text color
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if (![textView hasText]) {
        textView.text = contentHoldPlaceText;
        textView.textColor = [UIColor colorWithRed:160/255.0 green:160/255.0 blue:160/255.0 alpha:1.0];      // placehoder color
    }
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    
    if (textField == subjectField) {
        
        scrollView.contentSize = CGSizeMake(kSWidth, sendButton.frame.size.height + sendButton.frame.origin.y+200);
        [UIView animateWithDuration:.1 animations:^{
            if (self.isMain) {
                float dishoffy = [[[NSUserDefaults standardUserDefaults] objectForKey:@"dishoffy"] floatValue];
                self.view.frame = CGRectMake(dishoffy, -180, self.view.frame.size.width, self.view.frame.size.height);
            }
            else
            {
                self.view.frame = CGRectMake(0, -180, self.view.frame.size.width, self.view.frame.size.height);
            }
        }];
        
    }else if (textField == phoneNoField)
    {
        scrollView.contentSize = CGSizeMake(kSWidth, sendButton.frame.size.height + sendButton.frame.origin.y+200);
        [UIView animateWithDuration:.1 animations:^{
            
            
            if (self.isMain) {
                float dishoffy = [[[NSUserDefaults standardUserDefaults] objectForKey:@"dishoffy"] floatValue];
                self.view.frame = CGRectMake(dishoffy, -155, self.view.frame.size.width, self.view.frame.size.height);
            }
            else
            {
                self.view.frame = CGRectMake(0, -155, self.view.frame.size.width, self.view.frame.size.height);
            }
        }];
    }
    
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == subjectField || textField == phoneNoField) {
        scrollView.contentSize = CGSizeMake(kSWidth, sendButton.frame.size.height + sendButton.frame.origin.y+20);
        [UIView animateWithDuration:.1 animations:^{
            
            if (self.isMain) {
                float dishoffy = [[[NSUserDefaults standardUserDefaults] objectForKey:@"dishoffy"] floatValue];
                self.view.frame = CGRectMake(dishoffy, 64, kSWidth, kSHeight-64-49);
            }
            else
            {
                self.view.frame = CGRectMake(0, 64, kSWidth, kSHeight-64);
            }
        }];
    }
}
#pragma mark - send methods


- (void)sendAttachment
{
    
    NSString *urlString = [NSString stringWithFormat:@"%@/upload?uniqid=%@&siteID=%d&fileType=picture",[AppConfig sharedAppConfig].serverIf, [FCReader_OpenUDID value],[AppStartInfo sharedAppStartInfo].siteId];
    HttpRequest *request = [HttpRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    [request setHTTPMethod:@"POST"];
    
    NSString *boundary = @"293iosfksdfkiowjksdf31jsiuwq003s02dsaffafass3qw";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    NSData *body = [self buildMultipartFormDataPostBody:informAttachments];
    [request setHTTPBody:body];
    
    [request setCompletionBlock:^(NSData *data) {
        //        NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers  error:nil];
        if ([[responseDict objectForKey:@"success"] boolValue]) {
            NSArray *fileList = [responseDict objectForKey:@"fileList"];
            NSMutableArray *urls = [NSMutableArray array];
            for (NSDictionary *item in fileList) {
                [urls addObject:[item objectForKey:@"url"]];
            }
            [self sendInformInfo:urls];
        } else {
            NSString *errorString = [responseDict objectForKey:@"errorInfo"];
            XYLog(@"send inform attachment error: %@", errorString);
        }
    }];
    
    [request setFailedBlock:^(NSError *error) {
        XYLog(@"send inform attachment error: %@", error);
    }];
    
    [request startAsynchronous];
    
}



- (void)sendInformInfo:(NSArray *)urls
{
    NSString *title = contentTextView.text;
    if(title.length > 50){
        title = [title substringToIndex:50];
    }
    NSString *urlString = [NSString stringWithFormat:@"%@/tipoff",[AppConfig sharedAppConfig].serverIf];
    NSString *informString = [NSString stringWithFormat:@"siteID=%d&rootID=0&topic=%@&content=%@&contactNo=%@&userID=0&userName=%@&userOtherID=%@",[AppStartInfo sharedAppStartInfo].siteId, title, contentTextView.text,phoneNoField.text, subjectField.text,[FCReader_OpenUDID value]];
    
    if (urls == nil || [urls count] == 0) {
        informString = [informString stringByAppendingFormat:@"&imgUrl=%@", @""];
    }
    else {
        for (NSString *url in urls) {
            informString = [informString stringByAppendingFormat:@"&imgUrl=%@",url];
        }
    }
    
    NSURL *url = [NSURL URLWithString:urlString];
    HttpRequest *request = [HttpRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    
    NSData *informData = [informString dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:informData];
    [request setCompletionBlock:^(NSData *data) {
        NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        if ([str isEqualToString:@"true"]) {
            [self clearForm];
            [self clearLocalFile];
            [informAttachments removeAllObjects];
            [self reloadPreviewImages];
            [Global showTip:NSLocalizedString(@"您的作品已成功提交审核，审核后即可显示",nil)];
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            
            [Global showTipNoNetWork];
        }
    }];
    
    [request setFailedBlock:^(NSError *error) {
        XYLog(@"send inform info failed: %@", error);
        [Global showTipNoNetWork];
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    [request startAsynchronous];
    
}
- (BOOL)validateForm
{
    if(!_smallButton.selected){
        [UIAlertView showAlert:NSLocalizedString(@"请阅读并同意本服务协议",nil)];
        return NO;
    }
    if(contentTextView.text.length > 2000){
        [UIAlertView showAlert:NSLocalizedString(@"内容不能超过2000字符",nil)];
        return NO;
    }
    
    subjectField.text = [subjectField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    phoneNoField.text = [phoneNoField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if ([NSString isNilOrEmpty:subjectField.text]) {
        [UIAlertView showAlert:NSLocalizedString(@"联系人为必填项",nil)];
        return NO;
    }

    
    if (subjectField.text.length > 12) {
        [UIAlertView showAlert:NSLocalizedString(@"联系人长度不能超过12个字符",nil)];
        return NO;
    }
    if (![NSString isNilOrEmpty:phoneNoField.text]) {
        if (phoneNoField.text.length > 11){
            [UIAlertView showAlert:NSLocalizedString(@"请输入有效的手机号",nil)];
            return NO;
        } else if(phoneNoField.text.length == 11){
            if (![phoneNoField.text isMatchedByRegex:kPhoneNumberRegExp]) {
                [UIAlertView showAlert:NSLocalizedString(@"请输入有效的手机号",nil)];
                return NO;
            }
        }
        //长度低于11的也能获取验证码，因为澳门香港地区一般都少于11位
    }
    else
    {
        [UIAlertView showAlert:NSLocalizedString(@"手机号为必填项",nil)];
        return NO;
    }
    
    return YES;
}

- (void)send:(id)sender{
}

- (void)reloadPreviewImages
{
    // page control
    if (pageControl.superview) {
        [pageControl removeFromSuperview];
    }
    
    // remove hScrollView's subviews
    for (UIView *subview in hScrollView.subviews) {
        [subview removeFromSuperview];
    }
    
    int k = 0;
    for (int i = 0; i < informAttachments.count; ++i) {
        InformAttachment *attachment = [informAttachments objectAtIndex:i];
        if (!attachment.flagShow)
        {
            k++;
            continue;
        }
        
        i = i - k;
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(60*(i%4)+10*(int)(i%4+1), 7*(int)(i/4+1)+60*(int)(i/4),60, 60)];
        imageView.contentMode = UIViewContentModeScaleToFill;

        
        if (attachment.movieStr.length)
        {
            if ([attachment.movieStr isEqualToString:@"VIDEO"]){
                NSURL *videoURL = [attachment.rep url];
                NSDate * oldDate=[NSDate date];
                NSDate * date=[NSDate date];
                NSTimeInterval time = [date timeIntervalSinceDate:oldDate];
                imageView.image = [self thumbnailImageForVideo:videoURL atTime:time];
            }
            else
                imageView.image = [Global thumbnailImageForVideo:[NSURL URLWithString:attachment.movieStr] atTime:1];
            
            UIImageView *vedioIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"vedioIcon"]];
            vedioIcon.frame = CGRectMake(0, 0, 20, 20);
            vedioIcon.center = CGPointMake(30, 30);
            [imageView addSubview:vedioIcon];
        }
        else
            imageView.image = [UIImage imageWithData:attachment.data];
        
        [self addDeleteButton:imageView index:i];
        
        [hScrollView addSubview:imageView];
    }
    [self configPhotoButtonFrame];
    
}

- (UIImage*) thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time {
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    if(asset == nil){
        return nil;
    }
    NSParameterAssert(asset);
    AVAssetImageGenerator *assetImageGenerator =[[AVAssetImageGenerator alloc] initWithAsset:asset];
    assetImageGenerator.appliesPreferredTrackTransform = YES;
    assetImageGenerator.apertureMode =AVAssetImageGeneratorApertureModeEncodedPixels;
    
    CGImageRef thumbnailImageRef = NULL;
    CFTimeInterval thumbnailImageTime = time;
    NSError *thumbnailImageGenerationError = nil;
    thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMake(thumbnailImageTime, 60)actualTime:NULL error:&thumbnailImageGenerationError];
    
    if(!thumbnailImageRef)
        XYLog(@"thumbnailImageGenerationError %@",thumbnailImageGenerationError);
    
    UIImage*thumbnailImage = thumbnailImageRef ? [[UIImage alloc]initWithCGImage:thumbnailImageRef] : nil;
    CGImageRelease(thumbnailImageRef);
    
    return thumbnailImage;
}

-(void)configPhotoButtonFrame
{
    [self diffPhotoButton:6];
}

-(void)diffPhotoButton:(NSInteger)picNUmber
{
    if ([informAttachments count] > 8)
        return;
    
    int i = (int)[informAttachments count];
    int j = 0;
    
    for (InformAttachment *p in informAttachments)
    {
        if (!p.flagShow)
            j++;
    }
    
    i -= j;
    
    self.photoButton.frame = CGRectMake(60*(i%4)+10*(int)(i%4+1)-3, 7*(int)(i/4+1)+60*(int)(i/4)-3,67, 67);
    [hScrollView addSubview:self.photoButton];

    return;
}

-(void)addDeleteButton:(UIView *)view index:(NSInteger)index
{
    view.userInteractionEnabled = YES;
    UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    deleteButton.frame = CGRectMake(view.bounds.size.width-15, -3, 18, 18);
    [deleteButton setBackgroundImage:[UIImage imageNamed:@"disclosure_remove_button"] forState:UIControlStateNormal];
    [deleteButton addTarget:self action:@selector(remove:) forControlEvents:UIControlEventTouchUpInside];
    deleteButton.tag = 600+index;
    [view addSubview:deleteButton];
}

-(void)showLoginPage
{
    YXLoginViewController *controller = [[YXLoginViewController alloc]init];
    [controller rightPageNavTopButtons];

    [self presentViewController:[Global controllerToNav:controller] animated:YES completion:^{
    }]; 
}

-(NSString *)textForKeyInform:(NSString *)key
{
    if (self.saveInformDic.count) {
        return [self.saveInformDic objectForKey:key];
    }
    return @"";
}
@end
