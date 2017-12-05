//
//  ChangeUserIconController.m
//  FounderReader-2.5
//
//  Created by ld on 14-12-30.
//
//

#import "ChangeUserIconController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVCaptureDevice.h>
#import <AVFoundation/AVMediaFormat.h>
#import "NSStringAdditions.h"
#import "UIImagePickerController+NonRotating.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "UserAccountDefine.h"

@interface ChangeUserIconController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    BOOL isMove;
}
@property (nonatomic, retain) UIButton *cameraButton;

@end

@implementation ChangeUserIconController
@synthesize cameraButton;

- (void)viewDidLoad
{
    [super viewDidLoad];
    isMove = NO;
    self.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.7];
    
    UIView *gestureView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-175)];
    gestureView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:gestureView];

    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goPrePage)];
    tapRecognizer.cancelsTouchesInView = NO;
    [gestureView addGestureRecognizer:tapRecognizer];

    
    UIView *blackView = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.bounds.size.height-175, self.view.bounds.size.width, 175)];
    blackView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:blackView];

    
    UILabel *Label = [[UILabel alloc] initWithFrame:CGRectMake(10, 12, self.view.bounds.size.width-15, 30)];
    Label.text = NSLocalizedString(@"设置您的头像",nil);
    Label.font = [UIFont systemFontOfSize:16];
    Label.textColor = [UIColor whiteColor];
    [blackView addSubview:Label];


    UILabel *line5 = [[UILabel alloc]initWithFrame:CGRectMake(0, 45, self.view.bounds.size.width, 1)];
    line5.backgroundColor = [UIColor colorWithRed:57/255.0 green:57/255.0  blue:57/255.0  alpha:1];
    [blackView addSubview:line5];

    

    
//    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
        cameraButton.frame = CGRectMake((self.view.bounds.size.width-150)/2, 85, 45, 40);
        [cameraButton addTarget:self action:@selector(cameraButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [cameraButton setBackgroundImage:[UIImage imageNamed:@"changeUserCamera"] forState:UIControlStateNormal];
        [blackView addSubview:cameraButton];
    }
    
    UIButton *pickButton = [UIButton buttonWithType:UIButtonTypeCustom];
    pickButton.frame = CGRectMake((self.view.bounds.size.width+50)/2, 85, 45, 40);
    [pickButton addTarget:self action:@selector(pictureButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [pickButton setBackgroundImage:[UIImage imageNamed:@"changeUserPicture"] forState:UIControlStateNormal];
    [blackView addSubview:pickButton];
    
    self.imageView = [[UIImageView alloc]initWithFrame:self.view.frame];
    [self.view addSubview:self.imageView];
    self.imageView.hidden = YES;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.editButton.enabled = !!self.imageView.image;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (isMove) {
        isMove = NO;
        [self goPrePage];
    }
}

- (void)viewDidUnload
{
    self.editButton = nil;
    self.imageView = nil;
    self.cameraButton = nil;
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

-(void)goPrePage
{
//    [self dismissModalViewControllerAnimated:YES];
    
    [UIView animateWithDuration:.5 animations:^{
        self.view.center = CGPointMake([UIApplication sharedApplication].keyWindow.frame.size.width*2, [UIApplication sharedApplication].keyWindow.frame.size.height/2);
        
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
    }];
    
}


- (void)pictureButtonClicked:(id)sender
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
	
	picker.delegate = self;
	picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	picker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:picker.sourceType];

    [self presentViewController:picker animated:YES completion:^{
    }];
}

- (void)cameraButtonClicked:(id)sender
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
//    [self presentModalViewController:picker animated:YES];
    [self presentViewController:picker animated:YES completion:^{
    }];
    
//	DELETE(picker);
}

#pragma mark -

- (void)cropViewController:(PECropViewController *)controller didFinishCroppingImage:(UIImage *)croppedImage
{
    [controller dismissViewControllerAnimated:YES completion:NULL];
    self.imageView.image = croppedImage;
    self.imageView.hidden = YES;
    CGSize imagesize = croppedImage.size;
    imagesize.width = 300;
    imagesize.height = imagesize.width*croppedImage.size.height/croppedImage.size.width;
    if (croppedImage) {
        croppedImage = [Global imageWithImage:croppedImage scaledToSize:imagesize];
        NSData *imageData = UIImageJPEGRepresentation(croppedImage, 0.3);
        
        [imageData writeToFile:[cacheDirPath() stringByAppendingPathComponent:cacheUserIconName] atomically:YES];
        isMove = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:KchangeUserIconNotification object:nil];
    }
}

- (void)cropViewControllerDidCancel:(PECropViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:NULL];
    self.imageView.hidden = YES;
}

#pragma mark -
- (void)openEditor:(id)sender
{
    PECropViewController *controller = [[PECropViewController alloc] init];
    controller.delegate = self;
    controller.image = self.imageView.image;

    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    
    controller.cropView.aspectRatio = 1.0f;
    
    [self presentViewController:navigationController animated:YES completion:NULL];

}
#pragma mark -

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    self.imageView.image = image;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if (self.popover.isPopoverVisible) {
            [self.popover dismissPopoverAnimated:NO];
        }
        
        [self openEditor:nil];
    } else {
        [picker dismissViewControllerAnimated:YES completion:^{
            [self openEditor:nil];
        }];
    }
    //self.imageView.hidden = NO;
    [picker dismissViewControllerAnimated:YES completion:nil];
    return;
}
@end
