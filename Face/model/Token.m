//
//  Token.m
//  Message
//
//  Created by houxh on 14-7-8.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import "Token.h"
#import "LevelDB.h"
#import "TAHttpOperation.h"
#import "Config.h"
#import "APIRequest.h"

@interface Token()
@property(nonatomic)dispatch_source_t refreshTimer;
@property(nonatomic)int refreshFailCount;
@end

@implementation Token

+(Token*)instance {
    static Token *tok;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!tok) {
            tok = [[Token alloc] init];
            [tok load];
        }
    });
    return tok;
}

-(id)init {
    self = [super init];
    if (self) {

    }
    return self;
}

-(void)load {
    LevelDB *db = [LevelDB defaultLevelDB];
    self.accessToken = [db stringForKey:@"access_token"];
    self.refreshToken = [db stringForKey:@"refresh_token"];
    self.expireTimestamp = (int)[db intForKey:@"token_expire"];
    self.uid = [db intForKey:@"token_uid"];
}

-(void)save {
    LevelDB *db = [LevelDB defaultLevelDB];
    [db setString:self.accessToken forKey:@"access_token"];
    [db setString:self.refreshToken forKey:@"refresh_token"];
    [db setInt:self.expireTimestamp forKey:@"token_expire"];
    [db setInt:self.uid forKey:@"token_uid"];
}

@end
