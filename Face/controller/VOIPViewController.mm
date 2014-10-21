//
//  VOIPViewController.m
//  Face
//
//  Created by houxh on 14-10-13.
//  Copyright (c) 2014年 beetle. All rights reserved.
//

#import <AVFoundation/AVAudioSession.h>

#import "VOIPViewController.h"
#import "WebRTC.h"
#import "AVSendStream.h"
#import "AVReceiveStream.h"

#import "WebRTC.h"

#include "webrtc/voice_engine/include/voe_base.h"
#include "webrtc/common_types.h"
#include "webrtc/system_wrappers/interface/constructor_magic.h"
#include "webrtc/video_engine/include/vie_base.h"
#include "webrtc/video_engine/include/vie_capture.h"
#include "webrtc/video_engine/include/vie_codec.h"
#include "webrtc/video_engine/include/vie_image_process.h"
#include "webrtc/video_engine/include/vie_network.h"
#include "webrtc/video_engine/include/vie_render.h"
#include "webrtc/video_engine/include/vie_rtp_rtcp.h"
#include "webrtc/video_engine/vie_defines.h"
#include "webrtc/video_engine/include/vie_errors.h"
#include "webrtc/video_engine/include/vie_render.h"

#include "webrtc/voice_engine/include/voe_network.h"
#include "webrtc/voice_engine/include/voe_base.h"
#include "webrtc/voice_engine/include/voe_audio_processing.h"
#include "webrtc/voice_engine/include/voe_dtmf.h"
#include "webrtc/voice_engine/include/voe_codec.h"
#include "webrtc/voice_engine/include/voe_errors.h"
#include "webrtc/voice_engine/include/voe_neteq_stats.h"
#include "webrtc/voice_engine/include/voe_file.h"
#include "webrtc/voice_engine/include/voe_rtp_rtcp.h"
#include "webrtc/voice_engine/include/voe_hardware.h"


#import "User.h"
#import "UserDB.h"
#import "UserPresent.h"
#import "VOIP.h"
#import "HistoryDB.h"

@interface VOIPViewController ()

@property(strong, nonatomic) AudioSendStream *sendStream;
@property(strong, nonatomic) AudioReceiveStream *recvStream;
@property(nonatomic, assign) BOOL isCaller;
@property(nonatomic) User* peerUser;

@property(nonatomic, assign) int dialCount;
@property(nonatomic, assign) time_t dialBeginTimestamp;
@property(nonatomic) NSTimer *dialTimer;

@property(nonatomic, assign) time_t acceptTimestamp;
@property(nonatomic) NSTimer *acceptTimer;

@property(nonatomic) UIButton *hangUpButton;
@property(nonatomic) UIButton *acceptButton;
@property(nonatomic) UIButton *refuseButton;

@property(nonatomic) History *history;
@end

@implementation VOIPViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithCalledUID:(int64_t)uid
{
    self = [super init];
    if (self) {
        self.peerUser = [[UserDB instance] loadUser:uid];
        self.isCaller = YES;
        self.history = [[History alloc] init];
        self.history.peerUID = uid;
        self.history.flag = FLAG_OUT;
        self.history.createTimestamp = time(NULL);
    }
    return self;
}

-(id)initWithCallerUID:(int64_t)uid
{
    self = [super init];
    if (self) {
        self.peerUser = [[UserDB instance] loadUser:uid];
        self.isCaller = NO;
        self.history = [[History alloc] init];
        self.history.peerUID = uid;
        self.history.createTimestamp = time(NULL);
    }
    return self;
}

-(void)dealloc {
    NSLog(@"voip view controller dealloc");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    VOIP *voip = [VOIP instance];
    if (voip.state != VOIP_LISTENING) {
        NSLog(@"invalid voip state:%d", voip.state);
        return;
    }
    
    [[IMService instance] pushVOIPObserver:self];

    UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    moreButton.backgroundColor = [UIColor colorWithRed:0.78f green:0.78f blue:0.8f alpha:1.0f];
    moreButton.frame = CGRectMake(30.0f, 50.0f, 100, 50);
    [moreButton setTitle:@"挂断" forState:UIControlStateNormal];
    [moreButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [moreButton addTarget:self action:@selector(hangUp:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:moreButton];
    self.hangUpButton = moreButton;
    
    moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    moreButton.backgroundColor = [UIColor colorWithRed:0.78f green:0.78f blue:0.8f alpha:1.0f];
    moreButton.frame = CGRectMake(30.0f, 50.0f, 100, 50);
    [moreButton setTitle:@"接听" forState:UIControlStateNormal];
    [moreButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [moreButton addTarget:self action:@selector(acceptCall:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:moreButton];
    self.acceptButton = moreButton;
    
    moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    moreButton.backgroundColor = [UIColor colorWithRed:0.78f green:0.78f blue:0.8f alpha:1.0f];
    moreButton.frame = CGRectMake(150.0f, 50.0f, 100, 50);
    [moreButton setTitle:@"拒绝" forState:UIControlStateNormal];
    [moreButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [moreButton addTarget:self action:@selector(refuseCall:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:moreButton];
    self.refuseButton = moreButton;
    
    if (self.isCaller) {
        self.acceptButton.hidden = YES;
        self.refuseButton.hidden = YES;
    } else {
        self.hangUpButton.hidden = YES;
    }

    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        if (granted) {
            if (self.isCaller) {
                voip.state = VOIP_DIALING;
                
                self.dialBeginTimestamp = time(NULL);
                [self sendDial];

                self.dialTimer = [NSTimer scheduledTimerWithTimeInterval: 1
                                                                  target:self
                                                                selector:@selector(sendDial)
                                                                userInfo:nil
                                                                 repeats:YES];
                

            } else {
                voip.state = VOIP_ACCEPTING;
            }

        } else {
            NSLog(@"can't grant record permission");
            [self dismissViewControllerAnimated:NO completion:^{
                [[IMService instance] popVOIPObserver:self];
            }];
        }
    }];
}

-(void)dismiss {
    [self dismissViewControllerAnimated:YES completion:^{
        VOIP *voip = [VOIP instance];
        voip.state = VOIP_LISTENING;
        [[IMService instance] popVOIPObserver:self];
        [[HistoryDB instance] addHistory:self.history];
    }];
}

-(void)refuseCall:(UIButton*)button {
    VOIP *voip = [VOIP instance];
    voip.state = VOIP_REFUSED;
    self.history.flag = self.history.flag&FLAG_REFUSED;
    [self sendDialRefuse];
    
    [self dismiss];
}

-(void)acceptCall:(UIButton*)button {
    VOIP *voip = [VOIP instance];
    voip.state = VOIP_ACCEPTED;
    
    self.history.flag = self.history.flag&FLAG_ACCEPTED;

    
    self.acceptTimestamp = time(NULL);
    self.acceptTimer = [NSTimer scheduledTimerWithTimeInterval: 1
                                                        target:self
                                                      selector:@selector(sendDialAccept)
                                                      userInfo:nil
                                                       repeats:YES];
    [self sendDialAccept];
}

-(void)hangUp:(UIButton*)button {
    VOIP *voip = [VOIP instance];
    if (voip.state == VOIP_DIALING ) {
        [self.dialTimer invalidate];
        [self sendHangUp];
        voip.state = VOIP_HANGED_UP;
        
        self.history.flag = self.history.flag&FLAG_CANCELED;

        [self dismiss];
    } else if (voip.state == VOIP_CONNECTED) {
        [self sendHangUp];
        voip.state = VOIP_HANGED_UP;
        
        [self stopStream];
        
        [self dismiss];
    } else {
        NSLog(@"invalid voip state:%d", voip.state);
    }
}

- (void)sendDial {
    NSLog(@"dial...");
    VOIPControl *ctl = [[VOIPControl alloc] init];
    ctl.sender = [UserPresent instance].uid;
    ctl.receiver = self.peerUser.uid;
    ctl.cmd = VOIP_COMMAND_DIAL;
    ctl.dialCount = self.dialCount + 1;
    BOOL r = [[IMService instance] sendVOIPControl:ctl];
    if (r) {
        self.dialCount = self.dialCount + 1;
    } else {
        NSLog(@"dial fail");
    }
    
    time_t now = time(NULL);
    if (now - self.dialBeginTimestamp >= 60) {
        NSLog(@"dial timeout");
        [self.dialTimer invalidate];
        self.history.flag = self.history.flag&FLAG_UNRECEIVED;
        [self dismiss];
    }
}

-(void)sendControlCommand:(enum VOIPCommand)cmd {
    VOIPControl *ctl = [[VOIPControl alloc] init];
    ctl.sender = [UserPresent instance].uid;
    ctl.receiver = self.peerUser.uid;
    ctl.cmd = cmd;
    [[IMService instance] sendVOIPControl:ctl];
}

-(void)sendConnected {
    [self sendControlCommand:VOIP_COMMAND_CONNECTED];
}

-(void)sendTalking {
    [self sendControlCommand:VOIP_COMMAND_TALKING];
}

-(void)sendReset {
    [self sendControlCommand:VOIP_COMMAND_RESET];
}

-(void)sendDialAccept {
    [self sendControlCommand:VOIP_COMMAND_ACCEPT];
    
    time_t now = time(NULL);
    if (now - self.acceptTimestamp >= 10) {
        NSLog(@"accept timeout");
        [self.acceptTimer invalidate];
        [self dismiss];
    }
}

-(void)sendDialRefuse {
    [self sendControlCommand:VOIP_COMMAND_REFUSE];
}

-(void)sendHangUp {
    NSLog(@"send hang up");
    [self sendControlCommand:VOIP_COMMAND_HANG_UP];
}

- (BOOL)isHeadsetPluggedIn
{
    AVAudioSessionRouteDescription *route = [[AVAudioSession sharedInstance] currentRoute];
    
    BOOL headphonesLocated = NO;
    for( AVAudioSessionPortDescription *portDescription in route.outputs )
    {
        headphonesLocated |= ( [portDescription.portType isEqualToString:AVAudioSessionPortHeadphones] );
    }
    return headphonesLocated;
}


- (void)startStream {
    if (self.sendStream || self.recvStream) return;
    
    NSLog(@"start stream");
    BOOL isHeadphone = [self isHeadsetPluggedIn];
    
    self.sendStream = [[AudioSendStream alloc] init];
    self.sendStream.voiceTransport = self;
    [self.sendStream start];

    self.recvStream = [[AudioReceiveStream alloc] init];
    self.recvStream.voiceTransport = self;
    self.recvStream.isHeadphone = isHeadphone;
    self.recvStream.isLoudspeaker = NO;
    
    [self.recvStream start];
    
    self.history.beginTimestamp = time(NULL);
}


-(void)stopStream {
    if (!self.sendStream && !self.recvStream) return;
    NSLog(@"stop stream");
    [self.sendStream stop];
    [self.recvStream stop];
    
    self.history.endTimestamp = time(NULL);
}

#pragma mark - VOIPObserver
-(void)onVOIPControl:(VOIPControl*)ctl {
    VOIP *voip = [VOIP instance];
    
    if (ctl.sender != self.peerUser.uid) {
        [self sendTalking];
        return;
    }
    NSLog(@"voip state:%d command:%d", voip.state, ctl.cmd);
    
    if (voip.state == VOIP_DIALING) {
        if (ctl.cmd == VOIP_COMMAND_ACCEPT) {
            self.history.flag = self.history.flag&FLAG_ACCEPTED;

            
            [self sendConnected];
            voip.state = VOIP_CONNECTED;
            [self.dialTimer invalidate];
            NSLog(@"call voip connected");
            [self startStream];
        } else if (ctl.cmd == VOIP_COMMAND_REFUSE) {
            voip.state = VOIP_REFUSED;
            self.history.flag = self.history.flag&FLAG_REFUSED;
 
            
            [self.dialTimer invalidate];
            
            [self dismiss];
        } else if (ctl.cmd == VOIP_COMMAND_DIAL) {
            //simultaneous open
            [self.dialTimer invalidate];
            voip.state = VOIP_ACCEPTED;
            self.history.flag = self.history.flag&FLAG_ACCEPTED;


            self.acceptTimestamp = time(NULL);
            self.acceptTimer = [NSTimer scheduledTimerWithTimeInterval: 1
                                                                target:self
                                                              selector:@selector(sendDialAccept)
                                                              userInfo:nil
                                                               repeats:YES];
            [self sendDialAccept];
        }
    } else if (voip.state == VOIP_ACCEPTING) {
        
    } else if (voip.state == VOIP_ACCEPTED) {
        if (ctl.cmd == VOIP_COMMAND_CONNECTED) {
            NSLog(@"called voip connected");
            [self.acceptTimer invalidate];
            voip.state = VOIP_CONNECTED;
            [self startStream];
            
            self.hangUpButton.hidden = NO;
            self.acceptButton.hidden = YES;
            self.refuseButton.hidden = YES;
        } else if (ctl.cmd == VOIP_COMMAND_ACCEPT) {
            //simultaneous open
            NSLog(@"simultaneous voip connected");
            [self.acceptTimer invalidate];
            voip.state = VOIP_CONNECTED;
            [self startStream];
            
            self.hangUpButton.hidden = NO;
            self.acceptButton.hidden = YES;
            self.refuseButton.hidden = YES;
        }
    } else if (voip.state == VOIP_CONNECTED) {
        if (ctl.cmd == VOIP_COMMAND_HANG_UP) {
            voip.state = VOIP_HANGED_UP;
            [self stopStream];
            [self dismiss];
        } else if (ctl.cmd == VOIP_COMMAND_RESET) {
            voip.state = VOIP_RESETED;
            [self stopStream];
            
            [self dismiss];

        } else if (ctl.cmd == VOIP_COMMAND_ACCEPT) {
            [self sendConnected];
        }
    }
}

-(void)onVOIPData:(VOIPData*)data {
    if (data.sender != self.peerUser.uid) {
        [self sendReset];
        return;
    }
    VOIP *voip = [VOIP instance];
    if (voip.state == VOIP_CONNECTED) {
        int channel = self.recvStream.voiceChannel;
        
        const void *packet = [data.content bytes];
        int packet_length = [data.content length];
        
        WebRTC *rtc = [WebRTC sharedWebRTC];
        
        if (data.isRTP) {
            if (data.type == VOIP_AUDIO) {
                NSLog(@"audio data:%d content:%d", packet_length, data.content.length);
                rtc.voe_network->ReceivedRTPPacket(channel, packet, packet_length);
            }
        } else {
            if (data.type == VOIP_AUDIO) {
                NSLog(@"audio rtcp data:%d", packet_length);
                rtc.voe_network->ReceivedRTCPPacket(channel, packet, packet_length);
            }
        }

    } else {
        NSLog(@"skip data...");
    }
}


#pragma mark VoiceTransport
-(int)sendRTPPacketA:(const void*)data length:(int)length {
    VOIPData *vData = [[VOIPData alloc] init];
    
    vData.sender = [UserPresent instance].uid;
    vData.receiver = self.peerUser.uid;
    vData.type = VOIP_AUDIO;
    vData.rtp = YES;
    vData.content = [NSData dataWithBytes:data length:length];
    NSLog(@"send rtp package:%d", length);
    BOOL r = [[IMService instance] sendVOIPData:vData];
    if (!r) {
        NSLog(@"send rtp data fail");
    }
    
    return length;
}

-(int)sendRTCPPacketA:(const void*)data length:(int)length STOR:(BOOL)STOR {
    if (!STOR) {
        return 0;
    }

    NSLog(@"send rtcp package:%d", length);
    VOIPData *vData = [[VOIPData alloc] init];
    
    vData.sender = [UserPresent instance].uid;
    vData.receiver = self.peerUser.uid;
    vData.rtp = NO;
    vData.type = VOIP_AUDIO;
    vData.content = [NSData dataWithBytes:data length:length];
    BOOL r = [[IMService instance] sendVOIPData:vData];
    if (!r) {
        NSLog(@"send rtcp data fail");
    }
    return length;
}

@end