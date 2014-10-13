//
//  CheckVerifyCodeController.h
//  Message
//
//  Created by 杨朋亮 on 14/9/14.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface CheckVerifyCodeController : UIViewController <UITextFieldDelegate,MFMailComposeViewControllerDelegate>

@property (nonatomic) NSString *phoneNumberStr;

@end
