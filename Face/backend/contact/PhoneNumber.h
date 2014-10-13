//
//  PhoneNumber.h
//  Message
//
//  Created by houxh on 14-7-9.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PhoneNumber : NSObject
@property(nonatomic, copy)NSString *zone;
@property(nonatomic, copy)NSString *number;
@property(nonatomic, readonly)BOOL isValid;
@property(nonatomic, readonly)NSString *zoneNumber;

-(PhoneNumber*)initWithPhoneNumber:(NSString*)number;
-(PhoneNumber*)initWithZoneNumber:(NSString*)zoneNumber;
@end