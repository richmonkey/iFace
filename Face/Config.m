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
        self.host = @"106.185.43.85";
        self.port = 23000;
        self.voipPort = 23001;
    }
    return self;
}
-(NSString*)URL {
    return @"http://106.186.122.158:5000";
}
@end
