//
//  InformPageController.m
//  FounderReader-2.5
//
//  Created by chenfei on 4/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import "InformPageController.h"
#import "NSString+Helper.h"
#import "UIAlertView+Helper.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "HttpRequest.h"
#import "AppStartInfo.h"
#import "DataLib/DataLib.h"
#import "InformAttachment.h"
#import "InteractionConfig.h"
#import "UIImagePickerController+NonRotating.h"
#import "FCReader_OpenUDID.h"
#import "UserAccountDefine.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVCaptureDevice.h>
#import <AVFoundation/AVMediaFormat.h>
#import "NSArray+Plist.h"

#import "Global.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

#define height_dy 14


@interface InformPageController ()
{
    float height_textView;
    CGRect keyboardFrame;
    
    UIImageView *contentBgImageView;
    IQMediaPickerControllerMediaType mediaType;
    NSDictionary *mediaInfo;
}

@property(nonatomic,retain) UIImageView *contentBgImageView;

@end

@implementation InformPageController
@synthesize photoBgImageView,contentBgImageView;
@synthesize saveInformDic,informAttachments, sendButton;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

- (id)init
{
    self = [super init];
    if (self) {
        informAttachments = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)loadView
{
    scrollView = [[UIScrollView alloc] init];
    scrollView.alwaysBounceVertical = YES;
    scrollView.delegate = self;
    scrollView.userInteractionEnabled = YES;
    self.view = scrollView;
}

-(void)layOutSubViewsForBoardShow
{
    scrollView.contentSize = CGSizeMake(320, 600+contentBgImageView.frame.origin.y);
    
    contentBgImageView.frame = CGRectMake(contentBgImageView.frame.origin.x,
                                          contentBgImageView.frame.origin.y,
                                          contentBgImageView.frame.size.width,
                                          self.view.frame.size.height - keyboardFrame.size.height);
    
    contentTextView.frame = CGRectMake(contentTextView.frame.origin.x,
                                       contentTextView.frame.origin.y,
                                       contentTextView.frame.size.width,
                                       contentBgImageView.frame.size.height-90);
    
    
    photoBgImageView.frame = CGRectMake(photoBgImageView.frame.origin.x,
                                        contentBgImageView.frame.size.height+contentBgImageView.frame.origin.y+height_dy,
                                        photoBgImageView.frame.size.width,
                                        photoBgImageView.frame.size.height);
    
    sendButton.frame =  CGRectMake(sendButton.frame.origin.x,
                                   photoBgImageView.frame.origin.y+photoBgImageView.frame.size.height+height_dy,
                                   sendButton.frame.size.width,
                                   sendButton.frame.size.height);
    
    
}

-(void)layOutSubViewsForBoardHiden
{
    scrollView.contentSize = CGSizeMake(320, 680);
    contentBgImageView.frame = CGRectMake(contentBgImageView.frame.origin.x,
                                          contentBgImageView.frame.origin.y,
                                          contentBgImageView.frame.size.width,
                                          self.view.frame.size.height - keyboardFrame.size.height);
    
    contentTextView.frame = CGRectMake(contentTextView.frame.origin.x,
                                       contentTextView.frame.origin.y,
                                       contentTextView.frame.size.width,
                                       contentBgImageView.frame.size.height-50);
    
    
    photoBgImageView.frame = CGRectMake(photoBgImageView.frame.origin.x,
                                        contentBgImageView.frame.size.height+contentBgImageView.frame.origin.y+height_dy,
                                        photoBgImageView.frame.size.width,
                                        photoBgImageView.frame.size.height);
    
    sendButton.frame =  CGRectMake(sendButton.frame.origin.x,
                                   photoBgImageView.frame.origin.y+photoBgImageView.frame.size.height+height_dy,
                                   sendButton.frame.size.width,
                                   sendButton.frame.size.height);
    
    
}

- (void)keyboardWillShow:(NSNotification *)notification {
    
    NSDictionary *userInfo = [notification userInfo];
    NSValue *keyboardFrameVal = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    keyboardFrame = [keyboardFrameVal CGRectValue];
    
}

- (void)keyboardWillHide:(NSNotification *)notification {
    
    NSDictionary *userInfo = [notification userInfo];
    NSValue *keyboardFrameVal = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    keyboardFrame = [keyboardFrameVal CGRectValue];
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(void)saveLocal
{
    InteractionConfig *config = [InteractionConfig sharedInteractionConfig];
    
    saveInformDic = [[NSMutableDictionary alloc]init];
    if (![nameField.text isEqualToString:config.informNamePlaceholder]) {
        [saveInformDic setObject:nameField.text forKey:kName_inform];
    }
    if (![phoneNoField.text isEqualToString:config.informPhoneNoPlaceholder]) {
        [saveInformDic setObject:phoneNoField.text forKey:kPhoneEmail_inform];
    }
    if (![subjectField.text isEqualToString:config.informSubjectPlaceholder]) {
        [saveInformDic setObject:subjectField.text forKey:kTitle_inform];
    }
    if (![contentTextView.text isEqualToString:config.informContentPlaceholder]) {
        [saveInformDic setObject:contentTextView.text forKey:kContent_inform];
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [nameField resignFirstResponder];
    [phoneNoField resignFirstResponder];
    [subjectField resignFirstResponder];
    [contentTextView resignFirstResponder];
}

- (void)call
{

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{

}

- (void)down:(id)sender
{
    [nameField resignFirstResponder];
    [phoneNoField resignFirstResponder];
    [subjectField resignFirstResponder];
    [contentTextView resignFirstResponder];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self down:nil];
    [self saveInformTextLocalWithUserId];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

//访问相册
- (void)pickPhoto:(id)sender
{
    ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
    if (author == ALAuthorizationStatusRestricted || author == ALAuthorizationStatusDenied)
    {
        NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
        NSString *str = [NSString stringWithFormat:@"请在iPhone的\"设置->隐私->照片\"选项中，允许%@访问您的相册。", appName];
        [UIAlertView showAlert:str];
        return;
    }
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:picker.sourceType];
    [self.navigationController presentViewController:picker animated:YES completion:nil];
}

- (void)pickPhotos:(UIButton *)sender
{
    [contentTextView resignFirstResponder];
    [phoneNoField resignFirstResponder];
    [subjectField resignFirstResponder];
    
    NSInteger index = sender.tag;
    if (index != 1234) {
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"图片", @"视频", @"拍照", nil];
        actionSheet.tag = 1;
        [actionSheet showInView:self.view];
    }
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != actionSheet.cancelButtonIndex)
    {
        if (buttonIndex == 0){
            int i = 0;
            if (self.informAttachments.count) {
                for (InformAttachment *informAttachment in self.informAttachments) {
                    if ([informAttachment.movieStr isEqualToString:@"VIDEO"]) {
                        i = 1;
                    }
                }
                if (i == 1) {
                    [Global showTip:NSLocalizedString(@"图片和视频不能同时上传",nil)];
                    return;
                }
            }
            //相册 即图片或视频
            mediaType = buttonIndex;
            IQMediaPickerController *controller = [[IQMediaPickerController alloc] init];
            controller.delegate = self;
            [controller setMediaType:mediaType];
            if (buttonIndex < 2)
                controller.allowsPickingMultipleItems = YES;
            else
                controller.allowsPickingMultipleItems = NO;
            
            [self presentViewController:controller animated:YES completion:nil];
            return;
            
        }
        else if(buttonIndex == 1)
        {
            int i = 0;
            if (self.informAttachments.count) {
                for (InformAttachment *informAttachment in self.informAttachments) {
                    if ([informAttachment.movieStr isEqualToString:@"VIDEO"]) {
                        i = 1;
                    }
                    else
                    {
                        i = 2;
                    }
                }
                if (i == 1) {
                    [Global showTip:NSLocalizedString(@"视频不能超过1个",nil)];
                    return;
                }
                else if (i == 2)
                {
                    [Global showTip:NSLocalizedString(@"图片和视频不能同时上传",nil)];
                    return;
                }
            }
            mediaType = buttonIndex;
            IQMediaPickerController *controller = [[IQMediaPickerController alloc] init];
            controller.delegate = self;
            [controller setMediaType:mediaType];
            if (buttonIndex < 2)
                controller.allowsPickingMultipleItems = YES;
            else
                controller.allowsPickingMultipleItems = NO;
            
            [self presentViewController:controller animated:YES completion:nil];
            return;
        }
        
        if (buttonIndex == 2) {
            //拍摄照片
            
            int i = 0;
            if (self.informAttachments.count) {
                for (InformAttachment *informAttachment in self.informAttachments) {
                    if ([informAttachment.movieStr isEqualToString:@"VIDEO"]) {
                        i = 1;
                    }
                }
                if (i == 1) {
                    [Global showTip:NSLocalizedString(@"图片和视频不能同时上传",nil)];
                    return;
                }
            }
            
            UIImagePickerController *pick = [[UIImagePickerController alloc]init];
            pick.sourceType = UIImagePickerControllerSourceTypeCamera;
            pick.delegate = self;
            [self presentViewController:pick animated:YES completion:nil];
            return;
        }
        else if (buttonIndex == 3){
            //拍摄视频
            UIImagePickerController *pick1 = [[UIImagePickerController alloc]init];
            pick1.sourceType = UIImagePickerControllerSourceTypeCamera;
            [pick1 setVideoQuality:UIImagePickerControllerQualityTypeHigh];
            [pick1 setVideoMaximumDuration:180];
            
            pick1.mediaTypes = [NSArray arrayWithObjects:(NSString *)  kUTTypeMovie, nil];
            pick1.delegate = self;
            [self presentViewController:pick1 animated:YES completion:nil];
            return;
        }
    }
}
- (void)mediaPickerControllerDidCancel:(IQMediaPickerController *)controller{
    return;
}
- (void)mediaPickerController:(IQMediaPickerController*)controller didFinishMediaWithInfo:(NSDictionary *)info
{
    [self mediaPicker:controller didFinishMediaWithInfo:info];
}
- (void)mediaPicker:(IQMediaPickerController*)controller didFinishMediaWithInfo:(NSDictionary *)info
{
    XYLog(@"Info: %@",info);
    
    mediaInfo = [info copy];
    
    NSString *key = [[mediaInfo allKeys] objectAtIndex:0];
    for (id dict in [mediaInfo objectForKey:key])
    {
        if([dict objectForKey:IQMediaAssetURL])
        {
            InformAttachment *attachment = [[InformAttachment alloc] init];
            ALAssetRepresentation *rep = [dict objectForKey:IQMediaAssetURL];
            NSString *fileName =  [rep filename];
            Byte *buffer = (Byte*)malloc((int)rep.size);
            NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:(int)rep.size error:nil];
            
            // 限制视频大小10M
            float m = (float)buffered/1024/1024/2;
            if (m > 50) {
                [UIAlertView showAlert:NSLocalizedString(@"上传视频附件不能超过50M",nil)];
                return;
            }
            
            attachment.data = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
            NSString *newfileName = [NSString stringWithFormat:@"%@.mp4",[fileName stringByDeletingPathExtension]];
            
            
            [Global transMov2Mp4:rep.url destURL:newfileName finishedBlock:^(NSData *data){
                attachment.data = data;
                attachment.fileName = newfileName;
            }];

            attachment.fileName = fileName;
            attachment.movieStr = @"VIDEO";//[mediaURL absoluteString];
            attachment.type = mediaType;
            attachment.rep = rep;
            [informAttachments addObject:attachment];        }
        else if ([dict objectForKey:IQMediaImage])
        {
            UIImage *image = [dict objectForKey:IQMediaImage];
            
            CGSize imagesize = image.size;
            imagesize.width = 1024;
            imagesize.height = imagesize.width*image.size.height/image.size.width;
            image = [Global imageWithImage:image scaledToSize:imagesize];
            InformAttachment *attachment = [[InformAttachment alloc] init];
            attachment.data = UIImageJPEGRepresentation(image, 0.5);
            attachment.fileName = @"image.jpg";
            attachment.movieStr = @"";
            attachment.type = mediaType;
            [informAttachments addObject:attachment];
        }
    }
    
    [self updateLocalSaveContent];
}

//访问摄像头
- (void)pickMovie:(id)sender
{
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied)
        {
            NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
            NSString *str = [NSString stringWithFormat:@"%@%@%@",NSLocalizedString(@"请在iPhone的\"设置->隐私->相机\"选项中，允许", nil),appName,NSLocalizedString(@"访问您的摄像头。", nil)];
            [UIAlertView showAlert:str];
            return;
        }
    }
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:picker.sourceType];
    [self presentViewController:picker animated:YES completion:nil];
    //	DELETE(picker);
}

- (int)currentPage
{
    CGFloat pageWidth = hScrollView.frame.size.width;
    int page = floor((hScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    return page;
}

- (void)remove:(UIButton *)sender
{
    
    [self.informAttachments removeObjectAtIndex:sender.tag-600];
    for(int i =0;i<[self.informAttachments count];i++)
    {
        InformAttachment *a = (InformAttachment*)[self.informAttachments objectAtIndex:i];
        if (!a.flagShow)
            [self.informAttachments removeObjectAtIndex:i];
    }
    [self reloadPreviewImages];
}

-(void)addDeleteButton:(UIView *)view index:(NSInteger)index
{
    view.userInteractionEnabled = YES;
    UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    deleteButton.frame = CGRectMake(view.bounds.size.width-70, 0, 18, 18);
    [deleteButton setBackgroundImage:[UIImage imageNamed:@"disclosure_remove_button"] forState:UIControlStateNormal];
    [deleteButton addTarget:self action:@selector(remove:) forControlEvents:UIControlEventTouchUpInside];
    deleteButton.tag = 600+index;
    
    [view addSubview:deleteButton];
}

- (void)reloadPreviewImages
{
    removeButton.hidden = !informAttachments.count;
    
    // remove hScrollView's subviews
    for (UIView *subview in hScrollView.subviews) {
        [subview removeFromSuperview];
    }
    
    hScrollView.contentSize = CGSizeMake(hScrollView.frame.size.width * informAttachments.count, hScrollView.frame.size.height);
    
    for (int i = 0; i < informAttachments.count; ++i) {
        InformAttachment *attachment = [informAttachments objectAtIndex:i];
        UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(hScrollView.frame.size.width*i, 0, hScrollView.frame.size.width, hScrollView.frame.size.height)];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(60, 10, bgView.frame.size.width-120, bgView.frame.size.height-10)];
        imageView.contentMode = UIViewContentModeScaleToFill;
        
        if (attachment.movieStr.length)
            imageView.image = [Global thumbnailImageForVideo:[NSURL URLWithString:attachment.movieStr] atTime:1];
        else
            imageView.image = [UIImage imageWithData:attachment.data];
        
        [bgView addSubview:imageView];
        [self addDeleteButton:bgView index:i];
        
        [hScrollView addSubview:bgView];
    }
    
    [hScrollView scrollRectToVisible:CGRectMake(hScrollView.frame.size.width*informAttachments.count-1, 0, hScrollView.frame.size.width, hScrollView.frame.size.height) animated:NO];
    
    // page control
    pageControl.numberOfPages = (int)informAttachments.count;
    pageControl.currentPage = (int)informAttachments.count-1;
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType1 = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType1 isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        if (image) {
            InformAttachment *attachment = [[InformAttachment alloc] init];
            attachment.data = UIImageJPEGRepresentation(image, 0.3);
            attachment.fileName = @"image.jpg";
            attachment.movieStr = @"";
            [informAttachments addObject:attachment];        }
    } else if ([mediaType1 isEqualToString:(NSString *)kUTTypeMovie]) {

        NSURL *mediaURL = [info objectForKey:UIImagePickerControllerMediaURL];
        NSString *fileName = [[mediaURL path] lastPathComponent];
        NSData *mediaData = [NSData dataWithContentsOfURL:mediaURL];
        InformAttachment *attachment = [[InformAttachment alloc] init];
        attachment.data = mediaData;
        attachment.fileName = fileName;
        attachment.movieStr = [mediaURL absoluteString];
        [informAttachments addObject:attachment];
    }
    
    [self saveInformTextLocalWithUserId];
    [self reloadPreviewImages];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    if (sender == hScrollView)
        pageControl.currentPage = [self currentPage];
    else if(sender == scrollView)
        [contentTextView resignFirstResponder];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == phoneNoField)
        if (![NSString isNilOrEmpty:phoneNoField.text])
            if (![phoneNoField.text isMatchedByRegex:[NSString stringWithFormat:@"%@|%@", kPhoneNumberRegExp, kEmailAddressRegExp]])
                [UIAlertView showAlert:NSLocalizedString(@"您输入的手机号码或邮箱不正确！",nil)];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:[InteractionConfig sharedInteractionConfig].informContentPlaceholder])
        textView.text = @"";
    
    textView.textColor = nameField.textColor;
    [self layOutSubViewsForBoardShow];
    [scrollView setContentOffset:CGPointMake(0, contentBgImageView.frame.origin.y) animated:YES];
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if (![textView hasText]) {
        textView.text = [InteractionConfig sharedInteractionConfig].informContentPlaceholder;
        textView.textColor = [UIColor colorWithRed:160/255.0 green:160/255.0 blue:160/255.0 alpha:1.0];      // placehoder color
    }
    [self layOutSubViewsForBoardHiden];
}

#pragma mark -

- (BOOL)validateForm
{

    InteractionConfig *config = [InteractionConfig sharedInteractionConfig];
    //爆料内容
    if (![contentTextView hasText] || [contentTextView.text isEqualToString:NSLocalizedString(@"请输入报料内容",nil)]) {
        [UIAlertView showAlert:config.informContentPlaceholder];
        return NO;
    }
    return YES;
}

- (void)clearForm
{
    nameField.text = @"";
    phoneNoField.text = @"";
    subjectField.text = @"";
    contentTextView.text = [InteractionConfig sharedInteractionConfig].informContentPlaceholder;
    contentTextView.textColor = [UIColor colorWithRed:160/255.0 green:160/255.0 blue:160/255.0 alpha:1.0];      // placehoder color
}

- (NSData *)buildMultipartFormDataPostBody:(NSArray *)attachments
{
    NSString *boundary = @"293iosfksdfkiowjksdf31jsiuwq003s02dsaffafass3qw";
    
    NSMutableData *body = [NSMutableData data];
    
    int i = 1;
    for (InformAttachment *attachment in attachments) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"upload%d\"; filename=\"%@\"\r\n", i, attachment.fileName] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:attachment.data];
        [body appendData:[@"\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
        ++i;
    }
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    return body;
}

- (void)sendInformInfo:(NSArray *)urls
{
    
    NSString *urlString = @"";//[NSString stringWithFormat:@"%@informInfo", [AppStartInfo sharedAppStartInfo].disclosureServer];
    NSURL *url = [NSURL URLWithString:urlString];
    HttpRequest *request = [HttpRequest requestWithURL:url];
    
    [request setHTTPMethod:@"POST"];
    
    NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    NSString *userId = [Global userId];
    
    NSString *informString = [NSString stringWithFormat:@"userId=%@&userName=%@&phoneNumber=%@&email=%@&title=%@&content=%@&siteId=%d&sourceDevice=%@&informType=%d",userId,
                              nameField.text, phoneNoField.text, @"", subjectField.text, contentTextView.text,[AppStartInfo sharedAppStartInfo].siteId, appName, kInformTypeInform];
    
    if (urls == nil || [urls count] == 0) {
        informString = [informString stringByAppendingFormat:@"&attachmentURLS=%@", @""];
    } else {
        for (NSString *url in urls) {
            informString = [informString stringByAppendingFormat:@"&attachmentURLS=%@", url];
        }
        
    }
    
    NSData *informData = [informString dataUsingEncoding:NSUTF8StringEncoding];
    
    [request setHTTPBody:informData];
    
    [request setCompletionBlock:^(NSData *data) {
        
        NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers  error:nil];
        if ([[responseDict objectForKey:@"success"] boolValue]) {
            XYLog(@"send inform info success");
            [self clearForm];
            [self clearLocalFile];
            [informAttachments removeAllObjects];
            [self reloadPreviewImages];
            [Global showTip:NSLocalizedString(@"您的作品已成功提交审核，审核后即可显示",nil)];
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            NSString * strerror = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            XYLog(@"send inform info failed:%@", strerror);
            [Global showTipNoNetWork];
        }
    }];
    
    [request setFailedBlock:^(NSError *error) {
        XYLog(@"send inform info failed: %@", error);
        [Global showTipNoNetWork];
    }];
    
    [request startAsynchronous];
}

- (void)send:(id)sender
{
    if (![self validateForm])
        return;
    
    [self down:nil];
    [Global showTipAlways:NSLocalizedString(@"正在发送...",nil)];
    
    [self sendInformInfo:nil];
}

-(void)saveInformTextLocalWithUserId
{
    InteractionConfig *config = [InteractionConfig sharedInteractionConfig];
    
    saveInformDic = [[NSMutableDictionary alloc]init];
    
    if (![NSString isNilOrEmpty:nameField.text]) {
        [self.saveInformDic setObject:nameField.text forKey:kName_inform];
    }
    if (![NSString isNilOrEmpty:phoneNoField.text]) {
        [self.saveInformDic setObject:phoneNoField.text forKey:kPhoneEmail_inform];
    }
    if (![NSString isNilOrEmpty:subjectField.text]) {
        [self.saveInformDic setObject:subjectField.text forKey:kTitle_inform];
    }
    
    if ([contentTextView hasText] && ![contentTextView.text isEqualToString:config.informContentPlaceholder] ) {
        [self.saveInformDic setObject:contentTextView.text forKey:kContent_inform];
    }
    
    if (self.saveInformDic.count) {
        [self.saveInformDic setObject:[NSDate date] forKey:kSaveDate_inform];
        [self.saveInformDic writeToFile:[self textLocalPath]
                             atomically:YES];
    }
    else{
        NSFileManager* manager = [NSFileManager defaultManager];
        if ([manager fileExistsAtPath:[self textLocalPath]]) {
            [manager removeItemAtPath:[self textLocalPath] error:nil];
        }
    }
    
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

-(NSString *)attachmentLocalPath
{
    NSString *userId = [Global userId];
    NSString *lastComponent = [NSString stringWithFormat:@"%@%@.plist",kSaveInformAttachmentsFileName,userId];
    NSString *attachmentFilePath = [cacheDirPath() stringByAppendingPathComponent:lastComponent];
    return attachmentFilePath;
}

-(NSString *)textLocalPath
{
    NSString *userId = [Global userId];
    NSString *lastComponent = [NSString stringWithFormat:@"%@%@",kSaveInformTextFileName,userId];
    NSString *attachmentFilePath = [cacheDirPath() stringByAppendingPathComponent:lastComponent];
    return attachmentFilePath;
}

-(void)clearLocalFile
{
    NSString *dicFilePath = [self textLocalPath];
    if (isFileExists(dicFilePath)) {
        [[NSFileManager defaultManager] removeItemAtPath:dicFilePath error:0];
    }
    NSString *arryFilePath = [self attachmentLocalPath];
    if (isFileExists(arryFilePath)) {
        [[NSFileManager defaultManager] removeItemAtPath:arryFilePath error:0];
    }
}

-(void)readFromLocalFile
{
    return;
}

-(void)updateLocalSaveContent
{
    [self readFromLocalFile];
    InteractionConfig *config = [InteractionConfig sharedInteractionConfig];
    NSString *userName = [Global userInfoByKey:KuserAccountNickName];
    NSString *userPhone = [Global userInfoByKey:KuserAccountPhone];
    
    NSString *nameText = [self textForKeyInform:kName_inform];
    if (![NSString isNilOrEmpty:nameText]) {
        nameField.text = nameText;
        nameField.placeholder = @"";
    }else{
        nameField.text = userName;
        nameField.placeholder = config.informNamePlaceholder;
    }
    
    NSString *phoneText = [self textForKeyInform:kPhoneEmail_inform];
    if (![NSString isNilOrEmpty:phoneText]) {
        phoneNoField.text = phoneText;
        phoneNoField.placeholder = @"";
    }else{
        phoneNoField.text = userPhone;
        phoneNoField.placeholder = config.informPhoneNoPlaceholder;
    }
    
    NSString *titeText = [self textForKeyInform:kTitle_inform];
    if (![NSString isNilOrEmpty:titeText]) {
        subjectField.text = titeText;
        subjectField.placeholder = @"";
    }else{
        subjectField.text = @"";
        subjectField.placeholder = config.informSubjectPlaceholder;
    }
    
    NSString *contentText = [self textForKeyInform:kContent_inform];
    if ([NSString isNilOrEmpty: contentText]) {
        contentTextView.text = config.informContentPlaceholder;
        contentTextView.textColor = [UIColor colorWithRed:160/255.0 green:160/255.0 blue:160/255.0 alpha:1.0];      // placehoder color
    }else{
        contentTextView.text = contentText;
        contentTextView.textColor = [UIColor blackColor];
    }
    
    
    [self reloadPreviewImages];
}
-(NSString *)textForKeyInform:(NSString *)key
{
    if (self.saveInformDic.count) {
        return [self.saveInformDic objectForKey:key];
    }
    return @"";
}

@end
