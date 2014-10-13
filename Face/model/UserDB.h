//
//  UserDB.h
//  Message
//
//  Created by houxh on 14-7-6.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "PhoneNumber.h"

@interface UserDB : NSObject
+(UserDB*)instance;

-(BOOL)addUser:(User*)user;
-(BOOL)setUserState:(int64_t)uid state:(NSString*)state;
-(IMUser*)loadUser:(int64_t)uid;
-(User*)loadUserWithNumber:(PhoneNumber*)number;
@end
