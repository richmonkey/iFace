//
//  UIApplication+Util.m
//  Message
//
//  Created by 杨朋亮 on 22/9/14.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import "UIApplication+Util.h"

@implementation UIApplication (Util)

- (void)addSubViewOnFrontWindow:(UIView *)view {
    UIWindow *w = [self.windows lastObject];
    [w addSubview:view];
}

- (id)foregroundWindow{
    UIWindow *w = [self.windows lastObject];
    return w;
}

/*
 UIApplication *app = [UIApplication sharedApplication];
 [app addSubViewOnFrontWindow:_loadingView];
 */

@end
