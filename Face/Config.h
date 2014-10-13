//
//  Config.h
//  Message
//
//  Created by houxh on 14-7-7.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Config : NSObject
+(Config*)instance;

@property(nonatomic)NSString *host;
@property(nonatomic)int port;
@property(nonatomic, readonly)NSString *URL;
@end
