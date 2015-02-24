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
        self.host = @"voip.yufeng.me";
        self.port = 20000;
        self.voipPort = 20001;
    }
    return self;
}
-(NSString*)URL {
    return @"http://voip.yufeng.me";
}
-(NSString*)stunServer {
    return @"stun.counterpath.net";
}

@end
