//
//  ContactPhoneTableViewCell.m
//  Message
//
//  Created by daozhu on 14-7-27.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import "ContactIMUserTableViewCell.h"

@implementation ContactIMUserTableViewCell



+(id)fromXib{
    NSArray *subviewArray = [[NSBundle mainBundle] loadNibNamed:@"ContactIMUserTableViewCell" owner:self options:nil];
    id mainView = [subviewArray objectAtIndex:0];
    return mainView;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
