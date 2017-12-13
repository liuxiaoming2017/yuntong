//
//  UserBasicViewController.m
//  FounderReader-2.5
//
//  Created by ld on 15-2-3.
//
//

#import "UserBasicViewController.h"
#import "NSStringAdditions.h"
#import "RegexKitLite.h"

@interface UserBasicViewController ()

@end

@implementation UserBasicViewController


- (void)viewDidLoad
{
    [super viewDidLoad];

   
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

#pragma mark - Table view data source


- (BOOL)isPhoneNumberStyle:(NSString *)phoneMain
{
    if ([NSString isNilOrEmpty:phoneMain]) {
        //[UIAlertView showAlert:NSLocalizedString(@"您输入的手机号为空",nil)];
        [self showAlwetController:@"您输入的手机号为空"];
        return NO;
    }
    else
    {
        if ([phoneMain rangeOfString:@"@"].location != NSNotFound) {
            if (!([phoneMain rangeOfString:@".com"].location != NSNotFound || [phoneMain rangeOfString:@".cn"].location != NSNotFound)) {
                //[UIAlertView showAlert:NSLocalizedString(@"请输入有效的邮箱",nil)];
                [self showAlwetController:@"请输入有效的邮箱"];
                return NO;
            }
        }
        else if (phoneMain.length > 11){
            //[UIAlertView showAlert:NSLocalizedString(@"请输入有效的手机号",nil)];
            [self showAlwetController:@"请输入有效的手机号"];
            return NO;
        }else if(phoneMain.length == 11){
            NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",kPhoneNumberRegExp];
            if(![phoneTest evaluateWithObject:phoneMain]){
                [self showAlwetController:@"请输入有效的手机号"];
                return NO;
            }
//            if (![phoneMain isMatchedByRegex:kPhoneNumberRegExp]) {
//                //[UIAlertView showAlert:NSLocalizedString(@"请输入有效的手机号",nil)];
//                [self showAlwetController:@"请输入有效的手机号"];
//                return NO;
//            }
        }
        //长度低于11的也能获取验证码，因为澳门香港地区一般都少于11位
    }
    return YES;
}

- (BOOL)isPhoneNumber:(NSString *)phoneNum
{
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",kPhoneNumberRegExp];
    if ([NSString isNilOrEmpty:phoneNum]) {
        //[UIAlertView showAlert:NSLocalizedString(@"您输入的手机号为空",nil)];
        [self showAlwetController:@"您输入的手机号为空"];
        return NO;
    }else if (![phoneTest evaluateWithObject:phoneNum]){
        [self showAlwetController:@"请输入有效的手机号"];
        return NO;
    }
//    else if (![phoneNum isMatchedByRegex:kPhoneNumberRegExp]) {
//        //[UIAlertView showAlert:NSLocalizedString(@"请输入有效的手机号",nil)];
//        [self showAlwetController:@"请输入有效的手机号"];
//        return NO;
//    }
    return YES;
}

- (void)showAlwetController:(NSString *)str
{
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:str message:nil preferredStyle:UIAlertControllerStyleAlert];
   
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleCancel handler:nil];
    
    [alertVC addAction:cancleAction];
    [self presentViewController:alertVC animated:YES completion:nil];
}

@end
