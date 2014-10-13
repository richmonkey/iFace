//
//  UserDB.m
//  Message
//
//  Created by houxh on 14-7-6.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import "UserDB.h"
#import "LevelDB.h"
#import "ContactDB.h"

@implementation UserDB
+(UserDB*)instance {
    static UserDB *db;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!db) {
            db = [[UserDB alloc] init];
        }
    });
    return db;
}

-(NSString*)userKey:(int64_t)uid {
    return [NSString stringWithFormat:@"users_%lld", uid];
}

-(BOOL)addUser:(User*)user {
    LevelDB *db = [LevelDB defaultLevelDB];
    NSString *key = [self userKey:user.uid];

    if (user.avatarURL.length) {
        NSString *k = [key stringByAppendingString:@"_avatar"];
        [db setString:user.avatarURL forKey:k];
    }
    if (user.state.length) {
        NSString *k = [key stringByAppendingString:@"_state"];
        [db setString:user.state forKey:k];
    }
    if (user.phoneNumber.isValid) {
        NSString *k = [key stringByAppendingString:@"_number"];
        [db setString:user.phoneNumber.zoneNumber forKey:k];
        
        k = [NSString stringWithFormat:@"numbers_%@", user.phoneNumber.zoneNumber];
        [db setInt:user.uid forKey:k];
    }
    
    if (user.lastUpTimestamp) {
        NSString *k = [key stringByAppendingString:@"_up"];
        [db setInt:user.lastUpTimestamp forKey:k];
    }

    return YES;
}

-(BOOL)setUserState:(int64_t)uid state:(NSString*)state {
    LevelDB *db = [LevelDB defaultLevelDB];
    NSString *key = [self userKey:uid];
    NSString *k = [key stringByAppendingString:@"_state"];
    [db setString:state forKey:k];
    return YES;
}

-(IMUser*)loadUser:(int64_t)uid {
    LevelDB *db = [LevelDB defaultLevelDB];
    NSString *key = [self userKey:uid];
    NSString *k1 = [key stringByAppendingString:@"_avatar"];
    NSString *k2 = [key stringByAppendingString:@"_state"];
    NSString *k3 = [key stringByAppendingString:@"_number"];
    NSString *k4 = [key stringByAppendingString:@"_up"];
    IMUser *u = [[IMUser alloc] init];
    u.uid = uid;
    u.avatarURL = [db stringForKey:k1];
    u.state = [db stringForKey:k2];
    
    NSString *zoneNumber = [db stringForKey:k3];
    PhoneNumber *number = [[PhoneNumber alloc] initWithZoneNumber:zoneNumber];
    u.phoneNumber = number;
    
    u.lastUpTimestamp = [db intForKey:k4];
    
    if (!u.phoneNumber.isValid) {
        NSString *s = [NSString stringWithFormat:@"%lld", u.uid];
        NSRange range = [s rangeOfString:@"0"];
        if (range.length == 0) {
            return nil;
        }
        

        NSRange r1 = NSMakeRange(0, range.location);
        NSString *zone = [s substringWithRange:r1];
        NSString *n = [s substringFromIndex:range.location + range.length];
        number = [[PhoneNumber alloc] init];
        number.zone = zone;
        number.number = n;
        u.phoneNumber = number;
    }

    ContactDB *cdb = [ContactDB instance];
    if (u.phoneNumber.isValid) {
        u.contact = [cdb loadContactWithNumber:u.phoneNumber];
    }
    return u;
}


-(User*)loadUserWithNumber:(PhoneNumber*)number {
    LevelDB *db = [LevelDB defaultLevelDB];

    NSString *k = [NSString stringWithFormat:@"numbers_%@", number.zoneNumber];
    int64_t uid = [db intForKey:k];
    if (uid == 0) {
        return nil;
    }
    NSString *key = [self userKey:uid];
    NSString *k1 = [key stringByAppendingString:@"_avatar"];
    NSString *k2 = [key stringByAppendingString:@"_state"];
    NSString *k3 = [key stringByAppendingString:@"_number"];
    NSString *k4 = [key stringByAppendingString:@"_up"];
    User *u = [[User alloc] init];
    u.uid = uid;
    u.avatarURL = [db stringForKey:k1];
    u.state = [db stringForKey:k2];
    NSString *zoneNumber = [db stringForKey:k3];

    
    u.phoneNumber = [[PhoneNumber alloc] initWithZoneNumber:zoneNumber];
    if (u.avatarURL == nil &&
        u.state == nil &&
        !u.phoneNumber.isValid) {
        return nil;
    }
    
    u.lastUpTimestamp = [db intForKey:k4];
    return u;
}
@end
