//
//  DailCompView.m
//  Face
//
//  Created by 杨朋亮 on 12/9/15.
//  Copyright (c) 2015年 beetle. All rights reserved.
//

#import "DailCompView.h"

@implementation DailCompView


+(id)fromXib{
    
    NSArray *subviewArray = [[NSBundle mainBundle] loadNibNamed:@"DailCompView" owner:self options:nil];
    id mainView = [subviewArray objectAtIndex:0];
    
    return mainView;
    
}


@end
