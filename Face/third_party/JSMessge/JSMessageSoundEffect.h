//
//  JSMessageSoundEffect.h
//
//  Created by Jesse Squires on 2/15/13.
//  Copyright (c) 2013 Hexed Bits. All rights reserved.
//
//  http://www.hexedbits.com
//


#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface JSMessageSoundEffect : NSObject

+ (void)playMessageReceivedSound;
+ (void)playMessageSentSound;

@end