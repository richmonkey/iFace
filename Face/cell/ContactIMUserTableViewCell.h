//
//  ContactPhoneTableViewCell.h
//  Message
//
//  Created by daozhu on 14-7-27.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactIMUserTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *phoneTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastOnlineLabel;
@property (weak, nonatomic) IBOutlet UILabel *personnalStatusLabel;

@end
