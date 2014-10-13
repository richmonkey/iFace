//
//  APIRequest.h
//  Message
//
//  Created by houxh on 14-7-26.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TAHttpOperation.h"

@interface APIRequest : NSObject
+(TAHttpOperation*)updateState:(NSString*)state success:(void (^)())success fail:(void (^)())fail;

+(TAHttpOperation*)updateAvatar:(NSString*)avatar success:(void (^)())success fail:(void (^)())fail;

+(TAHttpOperation*)uploadImage:(UIImage*)image success:(void (^)(NSString *url))success fail:(void (^)())fail;

+(TAHttpOperation*)uploadAudio:(NSData*)data success:(void (^)(NSString *url))success fail:(void (^)())fail;

+(TAHttpOperation*)requestVerifyCode:(NSString*)zone number:(NSString*)number
                             success:(void (^)(NSString* code))success fail:(void (^)())fail;

+(TAHttpOperation*)requestAuthToken:(NSString*)code zone:(NSString*)zone number:(NSString*)number deviceToken:(NSString*)deviceToken
                            success:(void (^)(int64_t uid, NSString* accessToken, NSString *refreshToken, int expireTimestamp, NSString *state))success
                               fail:(void (^)())fail;

+(TAHttpOperation*)refreshAccessToken:(NSString*)refreshToken
                              success:(void (^)(NSString *accessToken, NSString *refreshToken, int expireTimestamp))success
                                 fail:(void (^)())fail;

+(TAHttpOperation*)requestUsers:(NSArray*)contacts
                        success:(void (^)(NSArray *resp))success
                           fail:(void (^)())fail;

@end
