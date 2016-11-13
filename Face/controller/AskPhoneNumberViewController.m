//
//  AskPhoneNumberViewController.m
//  Message
//
//  Created by 杨朋亮 on 14/9/14.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import "AskPhoneNumberViewController.h"
#import "APIRequest.h"
#import "MBProgressHUD.h"
#import "CheckVerifyCodeController.h"
#import "UIView+Toast.h"
#import "Constants.h"
#import "UIApplication+Util.h"

@interface AskPhoneNumberViewController ()

@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property  (nonatomic)               UIBarButtonItem *nextButton;


@end

@implementation AskPhoneNumberViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTitle:@"您的电话号码"];
    self.nextButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"获取验证码"
                                   style:UIBarButtonItemStylePlain
                                   target:self
                                   action:@selector(nextAction)];
    [self.navigationItem setRightBarButtonItem:self.nextButton];
    [self.nextButton setEnabled:NO];
    
    [self.phoneTextField becomeFirstResponder];
    [self.phoneTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    // Do any additional setup after loading the view from its nib.
}

-(void)viewDidAppear:(BOOL)animated{
    [self.phoneTextField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) nextAction {
   
    NSLog(@"验证码");
    NSString *number = self.phoneTextField.text;
    
    if (number.length != 11) return;
    
    if ([self checkTel:number]) {
        UIWindow *foreWindow  = [[UIApplication sharedApplication] foregroundWindow];
        UIView *backView =[[UIView alloc] initWithFrame:foreWindow.frame];
        [backView setBackgroundColor:RGBACOLOR(134, 136, 137, 0.95f)];
        [foreWindow addSubview:backView];
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:backView animated:YES];
        [APIRequest requestVerifyCode:@"86" number:number success:^(NSString *code){
            IMLog(@"code:%@", code);
            [hud hide:YES];
            [backView removeFromSuperview];
            CheckVerifyCodeController * ctrl = [[CheckVerifyCodeController alloc] init];
            ctrl.phoneNumberStr = number;
            [self.navigationController pushViewController:ctrl animated: YES];
        } fail:^{
            IMLog(@"获取验证码失败");
            [hud hide:NO];
            [backView removeFromSuperview];
            [self.view makeToast:@"获取验证码失败" duration:1.0f position:@"bottom"];
        }];
    }
    
}

- (void) textFieldDidChange:(id) sender {
    UITextField *_field = (UITextField *)sender;
    if ([_field text].length == 11) {
        [self.nextButton setEnabled:YES];
    }else if([_field text].length > 11){
        UIWindow *foreWindow  = [[UIApplication sharedApplication] foregroundWindow];
        [foreWindow makeToast:@"请确认手机号码是11位" duration:1.0f position:@"bottom"];
        [self.nextButton setEnabled:NO];
    }else{
        [self.nextButton setEnabled:NO];
    }
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField{

    
}

- (BOOL)checkTel:(NSString *)str
{
    //1[0-9]{10}
    //^((13[0-9])|(15[^4,\\D])|(18[0,5-9]))\\d{8}$
    //    NSString *regex = @"[0-9]{11}";
    NSString *regex = @"^((13[0-9])|(147)|(15[^4,\\D])|(18[0,5-9]))\\d{8}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isMatch = [pred evaluateWithObject:str];
    if (!isMatch) {
        [self.view makeToast:@"请输入正确的手机号码" duration:1.0f position:@"center"];
        return NO;
    }
    return YES;
}


@end
