//
//  IM.m
//  im
//
//  Created by houxh on 14-6-21.
//  Copyright (c) 2014年 potato. All rights reserved.
//

#import "Message.h"
#import "util.h"

#define HEAD_SIZE 8

@implementation IMMessage

@end

@implementation NatPortMap

@end

@implementation VOIPControl

@end

@implementation VOIPData

@end

@implementation MessageInputing

@end
@implementation MessageOnlineState

@end
@implementation MessagePeerACK

@end

@implementation MessageSubsribe

@end

@implementation Message
-(NSData*)pack {
    char buf[64*1024] = {0};
    char *p = buf;

    writeInt32(self.seq, p);
    p += 4;
    *p = (uint8_t)self.cmd;
    p += 4;
    
    if (self.cmd == MSG_HEARTBEAT) {
        return [NSData dataWithBytes:buf length:HEAD_SIZE];
    } else if (self.cmd == MSG_AUTH) {
        int64_t uid = [(NSNumber*)self.body longLongValue];
        writeInt64(uid, p);
        return [NSData dataWithBytes:buf length:HEAD_SIZE+8];
    } else if (self.cmd == MSG_IM) {
        IMMessage *m = (IMMessage*)self.body;
        writeInt64(m.sender, p);
        p += 8;
        writeInt64(m.receiver, p);
        p += 8;
        writeInt32(m.msgLocalID, p);
        p += 4;
        const char *s = [m.content UTF8String];
        int l = strlen(s);
        if ((l + HEAD_SIZE + 20) > 64*1024) {
            return nil;
        }
        memcpy(p, s, l);
        return [NSData dataWithBytes:buf length:HEAD_SIZE + 20 +l];
    } else if (self.cmd == MSG_ACK) {
        writeInt32([(NSNumber*)self.body intValue], p);
        return [NSData dataWithBytes:buf length:HEAD_SIZE+4];
    } else if (self.cmd == MSG_SUBSCRIBE_ONLINE_STATE) {
        MessageSubsribe *sub = (MessageSubsribe*)self.body;
        writeInt32([sub.uids count], p);
        p += 4;
        for (NSNumber *n in sub.uids) {
            writeInt64([n longLongValue], p);
            p += 8;
        }
        return [NSData dataWithBytes:buf length:HEAD_SIZE + 4 + [sub.uids count]*8];
    } else if (self.cmd == MSG_INPUTING) {
        MessageInputing *inputing = (MessageInputing*)self.body;
        writeInt64(inputing.sender, p);
        p += 8;
        writeInt64(inputing.receiver, p);
        return [NSData dataWithBytes:buf length:HEAD_SIZE + 16];
    } else if (self.cmd == MSG_VOIP_CONTROL) {
        VOIPControl *ctl = (VOIPControl*)self.body;
        writeInt64(ctl.sender, p);
        p += 8;
        writeInt64(ctl.receiver, p);
        p += 8;

        writeInt32(ctl.cmd, p);
        p += 4;
        if (ctl.cmd == VOIP_COMMAND_DIAL) {
            writeInt32(ctl.dialCount, p);
            p += 4;
            return [NSData dataWithBytes:buf length:HEAD_SIZE+24];
        } else if (ctl.cmd == VOIP_COMMAND_ACCEPT || ctl.cmd == VOIP_COMMAND_CONNECTED) {
            writeInt32(ctl.natMap.ip, p);
            p += 4;
            writeInt16(ctl.natMap.port, p);
            p += 2;
            *p++ = ctl.natMap.hairpin;
            return [NSData dataWithBytes:buf length:HEAD_SIZE+27];
        } else {
            return [NSData dataWithBytes:buf length:HEAD_SIZE+20];
        }
    } 
    return nil;
}

-(BOOL)unpack:(NSData*)data {
    const char *p = [data bytes];
    self.seq = readInt32(p);
    p += 4;
    self.cmd = *p;
    p += 4;
    NSLog(@"seq:%d cmd:%d", self.seq, self.cmd);
    if (self.cmd == MSG_RST) {
        return YES;
    } else if (self.cmd == MSG_AUTH_STATUS) {
        int status = readInt32(p);
        self.body = [NSNumber numberWithInt:status];
        return YES;
    } else if (self.cmd == MSG_IM) {
        IMMessage *m = [[IMMessage alloc] init];
        m.sender = readInt64(p);
        p += 8;
        m.receiver = readInt64(p);
        p += 8;
        m.msgLocalID = readInt32(p);
        p += 4;
        m.content = [[NSString alloc] initWithBytes:p length:data.length-HEAD_SIZE-20 encoding:NSUTF8StringEncoding];
        self.body = m;
        return YES;
    } else if (self.cmd == MSG_ACK) {
        int seq = readInt32(p);
        self.body = [NSNumber numberWithInt:seq];
        return YES;
    } else if (self.cmd == MSG_PEER_ACK) {
        MessagePeerACK *ack = [[MessagePeerACK alloc] init];
        ack.sender = readInt64(p);
        p += 8;
        ack.receiver = readInt64(p);
        p += 8;
        ack.msgLocalID = readInt32(p);
        self.body = ack;
        return YES;
    } else if (self.cmd == MSG_INPUTING) {
        MessageInputing *inputing = [[MessageInputing alloc] init];
        inputing.sender = readInt64(p);
        p += 8;
        inputing.receiver = readInt64(p);
        p += 8;
        self.body = inputing;
        return YES;
    } else if (self.cmd == MSG_ONLINE_STATE) {
        MessageOnlineState *state = [[MessageOnlineState alloc] init];
        state.sender = readInt64(p);
        p += 8;
        state.online = readInt32(p);
        self.body = state;
        return YES;
    } else if (self.cmd == MSG_VOIP_CONTROL) {
        VOIPControl *ctl = [[VOIPControl alloc] init];
        ctl.sender = readInt64(p);
        p += 8;
        ctl.receiver = readInt64(p);
        p += 8;
        ctl.cmd = readInt32(p);
        p += 4;
        if (ctl.cmd == VOIP_COMMAND_DIAL) {
            ctl.dialCount = readInt32(p);
        } else if (ctl.cmd == VOIP_COMMAND_ACCEPT || ctl.cmd == VOIP_COMMAND_CONNECTED) {
            if (data.length >= HEAD_SIZE + 27) {
                ctl.natMap = [[NatPortMap alloc] init];
                ctl.natMap.ip = readInt32(p);
                p += 4;
                ctl.natMap.port = readInt16(p);
                p += 2;
                ctl.natMap.hairpin = *p++;
            }
        }
        self.body = ctl;
        return YES;
    }
    return NO;
}

@end
