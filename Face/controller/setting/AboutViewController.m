//
//  AboutViewController.m
//  Message
//
//  Created by 杨朋亮 on 14-9-13.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import "AboutViewController.h"
#import "UIView+Toast.h"


@interface AboutViewController ()

@property (weak, nonatomic) IBOutlet UIButton *contactUsBtn;
@property (strong, nonatomic) NSArray *reciver;

-(IBAction) contactUs:(UIButton*)btn;

@end

@implementation AboutViewController

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
    [self setTitle:@"关于"];
    
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"联系我们"];
    NSRange strRange = {0,[str length]};
    
    [str addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:strRange];
    [str addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:strRange];
    
    [self.contactUsBtn setAttributedTitle:str forState:UIControlStateNormal];
    [self.contactUsBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction) contactUs:(UIButton*)btn{
    //检测设备是否支持邮件发送功能
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    if (mailClass != nil)
    {
        // We must always check whether the current device is configured for sending emails
        if ([mailClass canSendMail])
        {
            [self displayComposerSheet];//调用发送邮件的方法
        }
    }

}

-(void) displayComposerSheet{
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    self.reciver = @[@"daibou007@163.com"];
    [mc setSubject:@"Message,建议及意见!"];
    [mc setToRecipients:self.reciver];
    [mc setMessageBody:@"Message!!!\n\n!" isHTML:NO];
    [self presentViewController:mc animated:YES completion:nil];
    
}

#pragma - mark  MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail send canceled...");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved...");
            [self.view makeToast:@"邮件保存成功!"];
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent...");
            [self.view makeToast:@"发送成功!"];
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail send errored: %@...", [error localizedDescription]);
            [self.view makeToast:@"发送失败!"];
            break;
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

@end
