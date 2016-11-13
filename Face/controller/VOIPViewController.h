//
//  VOIPViewController.h
//  Face
//
//  Created by houxh on 14-10-13.
//  Copyright (c) 2014年 beetle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "ReflectionView.h"
#import "WebRTCViewController.h"

@class VOIPEngine;
@class VOIPSession;
@class User;

@interface VOIPViewController : WebRTCViewController<AVAudioPlayerDelegate>
    
@property(nonatomic) VOIPEngine *engine;
@property(nonatomic) VOIPSession *voip;

@property(nonatomic) User* peerUser;

@property(nonatomic) UIButton *switchButton;
@property(nonatomic) UIButton *hangUpButton;
@property(nonatomic) UILabel *durationLabel;

@property (nonatomic) ReflectionView *headView;
@property (nonatomic) CGPoint durationCenter;

-(id)initWithCalledUID:(int64_t)uid;
-(id)initWithCallerUID:(int64_t)uid;



-(int)setLoudspeakerStatus:(BOOL)enable;
-(void)dial;
-(void)waitAccept;
-(void)startStream;
-(void)stopStream;

@end
