//
//  InformPageController.h
//  FounderReader-2.5
//
//  Created by chenfei on 4/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ChannelPageController.h"
#import "StyledPageControl.h"
#import "IQMediaPickerController.h"
#import "NewsListConfig.h"
#import "RegexKitLite.h"
#import "NSStringAdditions.h"

#define kInformX        9
#define kInformWidth    80

#define kName_inform            @"name_inform"
#define kPhoneEmail_inform      @"phoneEmail_inform"
#define kTitle_inform           @"title_inform"
#define kContent_inform         @"content_inform"
#define kImageUrl_inform        @"imageUrl_inform"
#define kSaveDate_inform        @"saveDate_inform"


//保存爆料
#define kSaveInformTextFileName             @"saveInformTextDicFile"
#define kSaveInformAttachmentsFileName      @"saveinformAttachmentsArry"
//保存问答
#define kSaveQATextFileName             @"saveQATextDicFile"
#define kSaveQAAttachmentsFileName      @"saveQAAttachmentsArry"
//保存鉴定
#define kSaveJUDGETextFileName             @"saveJUDGETextDicFile"
#define kSaveJUDGEAttachmentsFileName      @"saveJUDGEAttachmentsArry"

@interface InformPageController : ChannelPageController <
    UITextFieldDelegate,
    UITextViewDelegate,
    UIScrollViewDelegate,
    UINavigationControllerDelegate,
    UIImagePickerControllerDelegate,
    UIAlertViewDelegate,
    UIActionSheetDelegate,
    IQMediaPickerControllerDelegate
> {
    UIScrollView *scrollView;
    UITextField  *nameField;
    UITextField  *phoneNoField;
    UITextField  *subjectField;
    UITextView   *contentTextView;
    UIButton     *removeButton;
    
    UIScrollView *hScrollView;
    StyledPageControl *pageControl;
    
    NSMutableArray *informAttachments;

    BOOL isPickViewShow;
    UIImageView *photoBgImageView;
    UIButton *sendButton;
    NSMutableDictionary *saveInformDic;
}
@property(nonatomic,retain) UIButton *sendButton;
@property(nonatomic,retain) UIButton *selectSectionButton;
@property(nonatomic,retain) UIButton *selectButton;
@property(nonatomic,retain) UIImageView *photoBgImageView;
@property(nonatomic,retain) NSMutableDictionary *saveInformDic;
@property(nonatomic,retain) NSMutableArray *informAttachments;
- (NSData *)buildMultipartFormDataPostBody:(NSArray *)attachments;
-(void)clearLocalFile;
- (void)remove:(UIButton *)sender;
-(void)updateLocalSaveContent;
- (void)mediaPicker:(IQMediaPickerController*)controller didFinishMediaWithInfo:(NSDictionary *)info;

- (void)pickPhotos:(UIButton *)sender;
- (void)down:(id)sender;
@end
