//
//  VOIP.m
//  Face
//
//  Created by houxh on 14-10-13.
//  Copyright (c) 2014年 beetle. All rights reserved.
//

#import "VOIP.h"


@implementation VOIP
+(VOIP*)instance {
    static VOIP *voip;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!voip) {
            voip = [[VOIP alloc] init];
        }
    });
    return voip;
}

-(id)init {
    self = [super init];
    if (self) {
        self.state = VOIP_LISTENING;
    }
    return self;
}

@end
