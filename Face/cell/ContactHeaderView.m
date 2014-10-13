//
//  ContactHeaderView.m
//  Message
//
//  Created by daozhu on 14-7-27.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import "ContactHeaderView.h"

@implementation ContactHeaderView



-(void)awakeFromNib{
    
    CALayer *imageLayer = [self.headView layer];   //获取ImageView的层
    [imageLayer setMasksToBounds:YES];
    [imageLayer setCornerRadius:self.headView.frame.size.width/2];
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
