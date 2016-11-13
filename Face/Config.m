//
//  Config.m
//  Message
//
//  Created by houxh on 14-7-7.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import "Config.h"
@interface Config()

@end

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

    }
    return self;
}
#if 1
-(NSString*)URL {
    return @"http://face.gobelieve.io";
}

-(NSString*)sdkAPIURL {
    return @"http://api.gobelieve.io";
}

-(NSString*)sdkHost {
    return @"imnode2.gobelieve.io";
}
#else
-(NSString*)URL {
    return @"http://192.168.1.101:8000";
}

-(NSString*)sdkAPIURL {
    return @"http://192.168.1.101:8000";
}

-(NSString*)sdkHost {
    return @"192.168.1.101";
}
#endif

@end
