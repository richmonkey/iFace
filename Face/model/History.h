//
//  History.h
//  Face
//
//  Created by houxh on 14-10-14.
//  Copyright (c) 2014年 beetle. All rights reserved.
//

#import <Foundation/Foundation.h>

#define FLAG_OUT 1
#define FLAG_CANCELED 1<<1 //通话取消

#define FLAG_REFUSED 1<<2
#define FLAG_ACCEPTED 1<<3

#define FLAG_UNRECEIVED 1<<4 //无人接听

@interface History : NSObject
@property(nonatomic, assign) int64_t hid;
@property(nonatomic, assign) int64_t peerUID;
@property(nonatomic, assign) time_t createTimestamp;
@property(nonatomic, assign) time_t beginTimestamp;
@property(nonatomic, assign) time_t endTimestamp;
@property(nonatomic, assign) int32_t flag;
@end
