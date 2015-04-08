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

@property(nonatomic, readonly)NSString *URL;
@property(nonatomic, readonly)NSString *sdkAPIURL;
@property(nonatomic, readonly)NSString *sdkHost;
@end
