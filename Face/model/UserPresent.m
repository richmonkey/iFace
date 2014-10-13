//
//  UserPresent.m
//  Message
//
//  Created by daozhu on 14-7-1.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import "UserPresent.h"
#import "Token.h"
#import "UserDB.h"

@implementation UserPresent


+(UserPresent*)instance {
  static UserPresent *im;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    if (!im) {
        im = [[UserPresent alloc] init];
        Token *tok = [Token instance];
        User *u = [[UserDB instance] loadUser:tok.uid];
        if (u) {
            im.phoneNumber = u.phoneNumber;
            im.uid= u.uid;
            im.avatarURL = u.avatarURL;
            im.state = u.state;
        }
    }
  });
  return im;
}

@end
