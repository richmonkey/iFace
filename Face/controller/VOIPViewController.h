//
//  VOIPViewController.h
//  Face
//
//  Created by houxh on 14-10-13.
//  Copyright (c) 2014年 beetle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class VOIPEngine;
@class VOIPSession;
@class User;

@interface VOIPViewController : UIViewController<AVAudioPlayerDelegate>
@property(nonatomic) VOIPEngine *engine;
@property(nonatomic) VOIPSession *voip;
@property(nonatomic, assign) BOOL isCaller;
@property(nonatomic) User* peerUser;

-(id)initWithCalledUID:(int64_t)uid;
-(id)initWithCallerUID:(int64_t)uid;


-(BOOL)isP2P;
-(int)SetLoudspeakerStatus:(BOOL)enable;
-(void)dial;
-(void)startStream;
-(void)stopStream;

@end
