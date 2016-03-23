//
//  HistoryTableViewCell.m
//  Face
//
//  Created by 杨朋亮 on 2/11/14.
//  Copyright (c) 2014年 beetle. All rights reserved.
//

#import "HistoryTableViewCell.h"

@implementation HistoryTableViewCell

+(id)fromXib{
    NSArray *subviewArray = [[NSBundle mainBundle] loadNibNamed:@"HistoryTableViewCell" owner:self options:nil];
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
