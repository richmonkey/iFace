//
//  Config.m
//  Message
//
//  Created by houxh on 14-7-7.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import "Config.h"

@implementation Config
+(Config*)instance {
    static Config *cfg;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!cfg) {
            cfg = [[Config alloc] init];
        }
    });
    return cfg;
}

-(id)init {
    self = [super init];
    if (self) {
        self.host = @"im.yufeng.me";
//        self.host = @"127.0.0.1";
        self.port = 23000;
    }
    return self;
}
-(NSString*)URL {
    return @"http://im.yufeng.me:5000";
//    return @"http://192.168.33.10:5000";
}
@end
