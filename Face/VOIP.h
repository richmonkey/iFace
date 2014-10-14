//
//  VOIP.h
//  Face
//
//  Created by houxh on 14-10-13.
//  Copyright (c) 2014年 beetle. All rights reserved.
//

#import <Foundation/Foundation.h>

//todo 状态变迁图
enum VOIPState {
    VOIP_LISTENING,
    VOIP_DIALING,//呼叫对方
    VOIP_CONNECTED,//通话连接成功
    VOIP_ACCEPTING,//询问用户是否接听来电
    VOIP_ACCEPTED,//用户接听来电
    VOIP_REFUSED,//(来/去)电被拒
    VOIP_HANGED_UP,//通话被挂断
    VOIP_RESETED,//通话连接被重置
};



#define VOIP_AUDIO 1
#define VOIP_VIDEO 2

#define VOIP_RTP 1
#define VOIP_RTCP 2

@interface VOIPAVData : NSObject

@property(nonatomic, readwrite) NSData *voipData;
@property(nonatomic, assign) int type;
@property(nonatomic) NSData *avData;
@property(nonatomic, getter = isRTP) BOOL rtp;

-(VOIPAVData*)initWithRTPAudio:(const void*)p length:(int)length;
-(VOIPAVData*)initWithRTCPAudio:(const void*)p length:(int)length;
-(VOIPAVData*)initWithRTPVideo:(const void*)p length:(int)length;
-(VOIPAVData*)initWithRTCPVideo:(const void*)p length:(int)length;

-(VOIPAVData*)initWithVOIPData:(NSData*)data;

@end

@interface VOIP : NSObject
+(VOIP*)instance;

@property(nonatomic, assign)enum VOIPState state;
@end
