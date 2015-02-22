//
//  IMService.h
//  im
//
//  Created by houxh on 14-6-26.
//  Copyright (c) 2014年 potato. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Message.h"

#define STATE_UNCONNECTED 0
#define STATE_CONNECTING 1
#define STATE_CONNECTED 2
#define STATE_CONNECTFAIL 3

@class IMessage;



@protocol VOIPObserver <NSObject>

-(void)onVOIPControl:(VOIPControl*)ctl;
-(void)onVOIPData:(VOIPData*)data;

@end

@protocol MessageObserver <NSObject>

//同IM服务器连接的状态变更通知
-(void)onConnectState:(int)state;

@end

@interface IMService : NSObject

@property(nonatomic)NSString *host;
@property(nonatomic)int port;
@property(nonatomic)int voipPort;
@property(nonatomic, assign)int connectState;

+(IMService*)instance;

-(void)start:(int64_t)uid;
-(void)stop;

-(void)listenVOIP;
-(void)closeUDP;

-(void)addMessageObserver:(id<MessageObserver>)ob;
-(void)removeMessageObserver:(id<MessageObserver>)ob;

-(void)pushVOIPObserver:(id<VOIPObserver>)ob;
-(void)popVOIPObserver:(id<VOIPObserver>)ob;

-(BOOL)sendVOIPControl:(VOIPControl*)ctl;
-(BOOL)sendVOIPData:(VOIPData*)data ip:(int)ip port:(short)port;
-(BOOL)sendVOIPData:(VOIPData*)data;
@end

