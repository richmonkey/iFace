//
//  PhoneNumber.m
//  Message
//
//  Created by houxh on 14-7-9.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import "PhoneNumber.h"

@implementation PhoneNumber
-(BOOL)isValid {
    return self.zone && self.number;
}

-(NSString*)zoneNumber {
    return [NSString stringWithFormat:@"%@_%@", self.zone, self.number];
}

-(PhoneNumber*)initWithZoneNumber:(NSString *)zoneNumber {
    self = [super init];
    if (self) {
        NSArray *array = [zoneNumber componentsSeparatedByString:@"_"];
        if ([array count] != 2) {
            return nil;
        }
        self.zone = [array objectAtIndex:0];
        self.number = [array objectAtIndex:1];
    }
    return self;
}
-(PhoneNumber*)initWithPhoneNumber:(NSString*)number {
    self = [super init];
    if (self) {
        if (![self parseNumber:number]) {
            return nil;
        }
    }
    return self;
}
-(BOOL)parseNumber:(NSString*)phone {
    char tmp[64] = {0};
    char *dst = tmp;
    const char *src = [phone UTF8String];
    
    while (*src) {
        if (isnumber(*src)){
            *dst++ = *src;
        }
        src++;
    }
    
    int len = dst - tmp;
    if (len > 11) {
        self.number = [NSString stringWithUTF8String:dst - 11];
        self.zone = [[NSString alloc] initWithBytes:tmp length:len - 11 encoding:NSUTF8StringEncoding];
        return YES;
    } else if (len == 11) {
        self.number = [NSString stringWithUTF8String:tmp];
        self.zone = @"86";
        return YES;
    } else {
        IMLog(@"invalid telephone number");
        return NO;
    }
}
@end