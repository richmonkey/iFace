//
//  UIApplication+Util.h
//  Message
//
//  Created by 杨朋亮 on 22/9/14.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIApplication (Util)

- (void)addSubViewOnFrontWindow:(UIView *)view;
- (id)foregroundWindow;
@end
