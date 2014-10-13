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

enum VOIPCommand {
    VOIP_COMMAND_DIAL,
    VOIP_COMMAND_ACCEPT,
    VOIP_COMMAND_CONNECTED,
    VOIP_COMMAND_REFUSE,
    VOIP_COMMAND_HANG_UP,
    VOIP_COMMAND_RESET,
    
    //通话中
    VOIP_COMMAND_TALKING,
    
};

@interface VOIPControlCommand : NSObject

@property(nonatomic, readonly) NSString *raw;
@property(nonatomic, assign)enum VOIPCommand cmd;
@property(nonatomic, assign)int dialCount;

-(VOIPControlCommand*)initWithRaw:(NSString*)raw;

@end

@interface VOIP : NSObject
+(VOIP*)instance;

@property(nonatomic, assign)enum VOIPState state;
@end
