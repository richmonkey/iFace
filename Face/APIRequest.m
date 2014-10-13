//
//  APIRequest.m
//  Message
//
//  Created by houxh on 14-7-26.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import "APIRequest.h"
#import "Token.h"
#import "Config.h"
#import "IMContact.h"
#import "PhoneNumber.h"

@implementation APIRequest
+(TAHttpOperation*)updateState:(NSString*)state success:(void (^)())success fail:(void (^)())fail {

    TAHttpOperation *request = [TAHttpOperation httpOperationWithTimeoutInterval:60];
    request.targetURL = [[Config instance].URL stringByAppendingString:@"/users/me"];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:state forKey:@"state"];
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    NSMutableDictionary *headers = [NSMutableDictionary dictionaryWithObject:@"application/json" forKey:@"Content-Type"];
    NSString *auth = [NSString stringWithFormat:@"Bearer %@", [Token instance].accessToken];
    [headers setObject:auth forKey:@"Authorization"];
    request.headers = headers;
    request.postBody = data;
    request.method = @"PATCH";
    request.successCB = ^(TAHttpOperation*commObj, NSURLResponse *response, NSData *data) {
        NSInteger statusCode = [(NSHTTPURLResponse*)response statusCode];
        if (statusCode != 200) {
            IMLog(@"update state fail");
            fail();
            return;
        }
        IMLog(@"update state success");
        success();
    };
    request.failCB = ^(TAHttpOperation*commObj, TAHttpOperationError error) {
        IMLog(@"update state fail");
        fail();
        
    };
    [[NSOperationQueue mainQueue] addOperation:request];
    return request;
}

+(TAHttpOperation*)updateAvatar:(NSString*)avatar success:(void (^)())success fail:(void (^)())fail {
    TAHttpOperation *request = [TAHttpOperation httpOperationWithTimeoutInterval:60];
    request.targetURL = [[Config instance].URL stringByAppendingString:@"/users/me"];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:avatar forKey:@"avatar"];
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    NSMutableDictionary *headers = [NSMutableDictionary dictionaryWithObject:@"application/json" forKey:@"Content-Type"];
    NSString *auth = [NSString stringWithFormat:@"Bearer %@", [Token instance].accessToken];
    [headers setObject:auth forKey:@"Authorization"];
    request.headers = headers;
    request.postBody = data;
    request.method = @"PATCH";
    request.successCB = ^(TAHttpOperation*commObj, NSURLResponse *response, NSData *data) {
        NSInteger statusCode = [(NSHTTPURLResponse*)response statusCode];
        if (statusCode != 200) {
            IMLog(@"update avatar fail");
            fail();
            return;
        }
        IMLog(@"update avatar success");
        success();
    };
    request.failCB = ^(TAHttpOperation*commObj, TAHttpOperationError error) {
        IMLog(@"update state fail");
        fail();
    };
    [[NSOperationQueue mainQueue] addOperation:request];
    return request;
}


+(TAHttpOperation*)uploadImage:(UIImage*)image success:(void (^)(NSString *url))success fail:(void (^)())fail {
    NSData *data = UIImagePNGRepresentation(image);
    TAHttpOperation *request = [TAHttpOperation httpOperationWithTimeoutInterval:60];
    request.targetURL = [[Config instance].URL stringByAppendingString:@"/images"];
    request.method = @"POST";
    request.postBody = data;
    
    NSMutableDictionary *headers = [NSMutableDictionary dictionaryWithObject:@"image/png" forKey:@"Content-Type"];
    NSString *auth = [NSString stringWithFormat:@"Bearer %@", [Token instance].accessToken];
    [headers setObject:auth forKey:@"Authorization"];
    request.headers = headers;
    
    request.successCB = ^(TAHttpOperation*commObj, NSURLResponse *response, NSData *data) {
        NSDictionary *resp = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        NSString *src_url = [resp objectForKey:@"src_url"];
        success(src_url);
    };
    request.failCB = ^(TAHttpOperation*commObj, TAHttpOperationError error) {
        fail();
    };
    [[NSOperationQueue mainQueue] addOperation:request];
    return request;

}


+(TAHttpOperation*)uploadAudio:(NSData*)data success:(void (^)(NSString *url))success fail:(void (^)())fail {
    TAHttpOperation *request = [TAHttpOperation httpOperationWithTimeoutInterval:60];
    request.targetURL = [[Config instance].URL stringByAppendingString:@"/audios"];
    request.method = @"POST";
    request.postBody = data;
    
    NSMutableDictionary *headers = [NSMutableDictionary dictionaryWithObject:@"application/plain" forKey:@"Content-Type"];
    NSString *auth = [NSString stringWithFormat:@"Bearer %@", [Token instance].accessToken];
    [headers setObject:auth forKey:@"Authorization"];
    request.headers = headers;

    request.successCB = ^(TAHttpOperation*commObj, NSURLResponse *response, NSData *data) {
        NSDictionary *resp = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        NSString *src_url = [resp objectForKey:@"src_url"];
        success(src_url);
    };
    request.failCB = ^(TAHttpOperation*commObj, TAHttpOperationError error) {
        fail();
    };
    [[NSOperationQueue mainQueue] addOperation:request];
    return request;
}

+(TAHttpOperation*)requestVerifyCode:(NSString*)zone number:(NSString*)number
                              success:(void (^)(NSString* code))success fail:(void (^)())fail{
    TAHttpOperation *request = [TAHttpOperation httpOperationWithTimeoutInterval:60];
    request.targetURL = [[Config instance].URL stringByAppendingFormat:@"/verify_code?zone=%@&number=%@", zone, number];
    request.method = @"POST";
    request.successCB = ^(TAHttpOperation*commObj, NSURLResponse *response, NSData *data) {
        NSInteger statusCode = [(NSHTTPURLResponse*)response statusCode];
        if (statusCode != 200) {
            fail();
            return;
        }
        NSDictionary *resp = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        NSString *code = [resp objectForKey:@"code"];
        success(code);
    };
    request.failCB = ^(TAHttpOperation*commObj, TAHttpOperationError error) {
        fail();
    };
    [[NSOperationQueue mainQueue] addOperation:request];
    return request;
}


+(TAHttpOperation*)requestAuthToken:(NSString*)code zone:(NSString*)zone number:(NSString*)number deviceToken:(NSString*)deviceToken
                            success:(void (^)(int64_t uid, NSString* accessToken, NSString *refreshToken, int expireTimestamp, NSString *state))success
                               fail:(void (^)())fail {
    TAHttpOperation *request = [TAHttpOperation httpOperationWithTimeoutInterval:60];
    request.targetURL = [[Config instance].URL stringByAppendingString:@"/auth/token"];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:code forKey:@"code"];
    [dict setObject:zone forKey:@"zone"];
    [dict setObject:number forKey:@"number"];
    if (deviceToken) {
        [dict setObject:deviceToken forKey:@"apns_device_token"];
    }

    NSDictionary *headers = [NSDictionary dictionaryWithObject:@"application/json" forKey:@"Content-Type"];
    request.headers = headers;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    request.postBody = data;
    request.method = @"POST";
    request.successCB = ^(TAHttpOperation*commObj, NSURLResponse *response, NSData *data) {
        NSInteger statusCode = [(NSHTTPURLResponse*)response statusCode];
        if (statusCode != 200) {
            fail();
            return;
        }
        NSDictionary *resp = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
     
        NSString *accessToken = [resp objectForKey:@"access_token"];
        NSString *refreshToken = [resp objectForKey:@"refresh_token"];
        int expireTimestamp = time(NULL) + [[resp objectForKey:@"expires_in"] intValue];
        int64_t uid = [[resp objectForKey:@"uid"] longLongValue];
        NSString *state = [resp objectForKey:@"state"];
        success(uid, accessToken, refreshToken, expireTimestamp, state);
    };
    request.failCB = ^(TAHttpOperation*commObj, TAHttpOperationError error) {
        fail();
    };
    [[NSOperationQueue mainQueue] addOperation:request];
    return request;
}

+(TAHttpOperation*)requestUsers:(NSArray*)contacts
                        success:(void (^)(NSArray *resp))success
                           fail:(void (^)())fail {
    
    TAHttpOperation *request = [TAHttpOperation httpOperationWithTimeoutInterval:60];
    request.targetURL = [[Config instance].URL stringByAppendingString:@"/users"];
    
    
    NSMutableArray *array = [NSMutableArray array];
    NSMutableSet *set = [NSMutableSet set];
    for (IMContact *contact in contacts) {
        for (NSDictionary *dict in contact.phoneDictionaries) {
            NSString *n = [dict objectForKey:@"value"];
            PhoneNumber *number = [[PhoneNumber alloc] initWithPhoneNumber:n];
            if (![number isValid]) {
                continue;
            }
            NSString *k = number.zoneNumber;
            if ([set containsObject:k]) {
                continue;
            }
            [set addObject:k];
            NSMutableDictionary *obj = [NSMutableDictionary dictionary];
            [obj setObject:number.zone forKey:@"zone"];
            [obj setObject:number.number forKey:@"number"];
            [array addObject:obj];
        }
    }
    if ([array count] == 0) return nil;
    
    NSMutableDictionary *headers = [NSMutableDictionary dictionaryWithObject:@"application/json" forKey:@"Content-Type"];
    NSString *auth = [NSString stringWithFormat:@"Bearer %@", [Token instance].accessToken];
    [headers setObject:auth forKey:@"Authorization"];
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:array options:0 error:nil];
    request.postBody = data;
    request.method = @"POST";
    request.headers = headers;
    request.successCB = ^(TAHttpOperation*commObj, NSURLResponse *response, NSData *data) {
        int statusCode = [(NSHTTPURLResponse*)response statusCode];
        if (statusCode != 200) {
            NSDictionary *d = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            IMLog(@"request users fail:%@", d);
            return;
        }
        NSArray *resp = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        success(resp);
    };
    
    request.failCB = ^(TAHttpOperation *commObj, TAHttpOperationError error) {
        fail();
    };
    [[NSOperationQueue mainQueue] addOperation:request];
    return request;
}

+(TAHttpOperation*)refreshAccessToken:(NSString*)refreshToken
                              success:(void (^)(NSString *accessToken, NSString *refreshToken, int expireTimestamp))success
                                 fail:(void (^)())fail{
    TAHttpOperation *request = [TAHttpOperation httpOperationWithTimeoutInterval:60];
    request.targetURL = [[Config instance].URL stringByAppendingString:@"/auth/refresh_token"];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:refreshToken forKey:@"refresh_token"];
    NSDictionary *headers = [NSDictionary dictionaryWithObject:@"application/json" forKey:@"Content-Type"];
    request.headers = headers;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    request.postBody = data;
    request.method = @"POST";
    request.successCB = ^(TAHttpOperation*commObj, NSURLResponse *response, NSData *data) {
        int statusCode = [(NSHTTPURLResponse*)response statusCode];
        if (statusCode != 200) {
            NSDictionary *e = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            IMLog(@"refresh token fail:%@", e);
            fail();
            return;
        }
        NSDictionary *resp = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        NSString *accessToken = [resp objectForKey:@"access_token"];
        NSString *refreshToken = [resp objectForKey:@"refresh_token"];
        int expireTimestamp = time(NULL) + [[resp objectForKey:@"expires_in"] intValue];
        success(accessToken, refreshToken, expireTimestamp);
    };
    request.failCB = ^(TAHttpOperation*commObj, TAHttpOperationError error) {
        fail();
    };
    [[NSOperationQueue mainQueue] addOperation:request];
    return request;
}
@end
