//
//  VOIP.m
//  Face
//
//  Created by houxh on 14-10-13.
//  Copyright (c) 2014年 beetle. All rights reserved.
//

#import "VOIP.h"

/*raw format
 {
 "dial":{"count":"呼叫次数"}
 "accept":{}
 "refuse":{}
 "connected":{}
 "hang_up":{}
 "reset":{}
 "talking":{}
 }
 */
/*
@implementation VOIPControlCommand

-(NSString*)raw {
    NSDictionary *dic = nil;
    if (self.cmd == VOIP_COMMAND_DIAL) {
        NSDictionary *o = @{@"count":[NSNumber numberWithInt:self.dialCount]};
        dic = @{@"dial":o};
    } else if (self.cmd == VOIP_COMMAND_ACCEPT) {
        dic = @{@"accept":@{}};
    } else if (self.cmd == VOIP_COMMAND_CONNECTED) {
        dic = @{@"connected":@{}};
    } else if (self.cmd == VOIP_COMMAND_HANG_UP) {
        dic = @{@"hang_up":@{}};
    } else if (self.cmd == VOIP_COMMAND_REFUSE) {
        dic = @{@"refuse":@{}};
    } else if (self.cmd == VOIP_COMMAND_RESET) {
        dic = @{@"reset":@{}};
    } else if (self.cmd == VOIP_COMMAND_TALKING) {
        dic = @{@"talking":@{}};
    } else {
        NSLog(@"unknow cmd:%d", self.cmd);
        return @"";
    }
    
    NSString* newStr = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:dic options:0 error:nil] encoding:NSUTF8StringEncoding];
    return newStr;
}

-(VOIPControlCommand*)initWithRaw:(NSString*)raw {
    self = [super init];
    if (self) {
        const char *utf8 = [raw UTF8String];
        NSData *data = [NSData dataWithBytes:utf8 length:strlen(utf8)];
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        if ([dict objectForKey:@"dial"]) {
            self.cmd = VOIP_COMMAND_DIAL;
            self.dialCount = [[[dict objectForKey:@"dial"] objectForKey:@"count"] intValue];
        } else if ([dict objectForKey:@"accept"]) {
            self.cmd = VOIP_COMMAND_ACCEPT;
        } else if ([dict objectForKey:@"refuse"]) {
            self.cmd = VOIP_COMMAND_REFUSE;
        } else if ([dict objectForKey:@"connected"]) {
            self.cmd = VOIP_COMMAND_CONNECTED;
        } else if ([dict objectForKey:@"hang_up"]) {
            self.cmd = VOIP_COMMAND_HANG_UP;
        } else if ([dict objectForKey:@"talking"]) {
            self.cmd = VOIP_COMMAND_TALKING;
        } else if ([dict objectForKey:@"reset"]) {
            self.cmd = VOIP_COMMAND_RESET;
        } else {
            NSLog(@"unknow:%@", raw);
            self.cmd = -1;
        }
    }
    return self;
}

@end
*/

@implementation VOIPAVData


-(VOIPAVData*)initWithRTPAudio:(const void*)p length:(int)length {
    self = [super init];
    if (self) {
        NSMutableData *data = [NSMutableData dataWithLength:length+2];
        char *t = [data mutableBytes];
        t[0] = VOIP_AUDIO;
        t[1] = VOIP_RTP;
        memcpy(t+2, p, length);
        self.voipData = data;
    }
    return self;
}

-(VOIPAVData*)initWithRTCPAudio:(const void*)p length:(int)length {
    self = [super init];
    if (self) {
        NSMutableData *data = [NSMutableData dataWithLength:length+2];
        char *t = [data mutableBytes];
        t[0] = VOIP_AUDIO;
        t[1] = VOIP_RTCP;
        memcpy(t+2, p, length);
        self.voipData = data;
    }
    return self;
}

-(VOIPAVData*)initWithRTPVideo:(const void*)p length:(int)length {
    self = [super init];
    if (self) {
        NSMutableData *data = [NSMutableData dataWithLength:length+2];
        char *t = [data mutableBytes];
        t[0] = VOIP_VIDEO;
        t[1] = VOIP_RTP;
        memcpy(t+2, p, length);
        self.voipData = data;
    }
    return self;
}

-(VOIPAVData*)initWithRTCPVideo:(const void*)p length:(int)length {
    self = [super init];
    if (self) {
        NSMutableData *data = [NSMutableData dataWithLength:length+2];
        char *t = [data mutableBytes];
        t[0] = VOIP_VIDEO;
        t[1] = VOIP_RTCP;
        memcpy(t+2, p, length);
        self.voipData = data;
    }
    return self;
}


-(VOIPAVData*)initWithVOIPData:(NSData*)data {
    self = [super init];
    if (self) {
        if (data.length > 2) {
            const char *p = [data bytes];
            self.type = p[0];
            if (p[1] == VOIP_RTP) {
                self.rtp = YES;
            } else {
                self.rtp = NO;
            }
            NSRange r = NSMakeRange(2, data.length-2);
            self.avData = [data subdataWithRange:r];
        }
    }
    return self;
}

@end

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
