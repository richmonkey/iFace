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

#import "ANBlurredImageView.h"
#import "UIImageView+WebCache.h"
#import "ReflectionView.h"
#import "UIView+Toast.h"

#define kBtnWidth  100
#define kBtnHeight 50
#define kBtnYposition  (self.view.frame.size.height - 3*kBtnHeight)

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
@property (nonatomic) UIButton *changeStateButton;

@property (nonatomic) UIButton *reDialingButton;
@property (nonatomic) UIButton *cancelButton;

@property(nonatomic) ANBlurredImageView *bkview;
@property(nonatomic) UILabel *durationLabel;
@property   (nonatomic) ReflectionView *headView;
@property   (nonatomic) NSTimer *refreshTimer;

@property(nonatomic) UInt64  conversationDuration;

@property(nonatomic) BOOL isLoudspeaker;

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
    
    self.conversationDuration = 0;
    
    // Do any additional setup after loading the view, typically from a nib.
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    self.bkview = [[ANBlurredImageView alloc]
                   initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,
                                            self.view.frame.size.height)];
    [self.bkview setImage:[UIImage imageNamed:@"bk"]];
    [self.bkview setBlurTintColor:[UIColor clearColor]];
    [self.bkview setFramesCount:20];
    [self.bkview setBlurAmount:1.0f];
    
    [self.view addSubview:self.bkview];
    
    UIImageView *imgView = [[UIImageView alloc]
                            initWithFrame:CGRectMake(0,0, 120,
                                                     120)];
    [imgView sd_setImageWithURL:[[NSURL alloc] initWithString:@""]
               placeholderImage:[UIImage imageNamed:@"potrait"]];
    
    CALayer *imageLayer = [imgView layer];  //获取ImageView的层
    [imageLayer setMasksToBounds:YES];
    [imageLayer setCornerRadius:imgView.frame.size.width / 2];
    
    self.headView = [[ReflectionView alloc] initWithFrame:CGRectMake((self.view.frame.size.width-120)/2,80, 120,120)];
    self.headView.alpha = 0.9f;
    self.headView.reflectionScale = 0.3f;
    self.headView.reflectionGap = 1.0f;
    [self.headView addSubview:imgView];
    
    [self.view addSubview:self.headView];
    
    
    self.durationLabel = [[UILabel alloc] init];
    [self.durationLabel setFont:[UIFont systemFontOfSize:23.0f]];
    [self.durationLabel setTextAlignment:NSTextAlignmentCenter];
    [self.durationLabel sizeToFit];
    [self.durationLabel setTextColor:[UIColor whiteColor]];
    [self.durationLabel setHidden:YES];
    [self.view addSubview:self.durationLabel];
    [self.durationLabel setCenter:CGPointMake((self.view.frame.size.width)/2, self.headView.frame.origin.y + self.headView.frame.size.height + 50)];
    [self.durationLabel setBackgroundColor:[UIColor clearColor]];
    
    
    
    
    self.acceptButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.acceptButton.backgroundColor =
    [UIColor colorWithRed:0.78f green:0.78f blue:0.8f alpha:1.0f];
    self.acceptButton.frame =
    CGRectMake(30.0f, self.view.frame.size.height - kBtnHeight - kBtnHeight, kBtnWidth, kBtnHeight);
    [self.acceptButton setTitle:@"接听" forState:UIControlStateNormal];
    [self.acceptButton setBackgroundImage:[UIImage imageNamed:@"accept_nor"] forState:UIControlStateNormal];
    [self.acceptButton setBackgroundImage:[UIImage imageNamed:@"accept_pre"] forState:UIControlStateHighlighted];
    [self.acceptButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.acceptButton addTarget:self
                   action:@selector(acceptCall:)
         forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.acceptButton];
    [self.acceptButton setCenter:CGPointMake(self.view.frame.size.width/4, kBtnYposition)];
    
    
    self.refuseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.refuseButton.backgroundColor =
    [UIColor colorWithRed:0.78f green:0.78f blue:0.8f alpha:1.0f];
    self.refuseButton.frame =
    CGRectMake(150.0f, self.view.frame.size.height - kBtnHeight - kBtnHeight, kBtnWidth, kBtnHeight);
    
    [self.refuseButton setTitle:@"拒绝" forState:UIControlStateNormal];
    [self.refuseButton setBackgroundImage:[UIImage imageNamed:@"refuse_nor"] forState:UIControlStateNormal];
    [self.refuseButton setBackgroundImage:[UIImage imageNamed:@"refuse_pre"] forState:UIControlStateHighlighted];
    [self.refuseButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.refuseButton addTarget:self
                   action:@selector(refuseCall:)
         forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.refuseButton];
    [self.refuseButton setCenter:CGPointMake(self.view.frame.size.width/4 + self.view.frame.size.width/2, kBtnYposition)];
    
    
    self.hangUpButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.hangUpButton.backgroundColor =
    [UIColor colorWithRed:0.78f green:0.78f blue:0.8f alpha:1.0f];
    self.hangUpButton.frame =
    CGRectMake(30.0f, self.view.frame.size.height - kBtnHeight - kBtnHeight, kBtnWidth*2, kBtnHeight);
    [self.hangUpButton setTitle:@"挂断" forState:UIControlStateNormal];
    
    [self.hangUpButton setBackgroundImage:[UIImage imageNamed:@"refuse_nor"] forState:UIControlStateNormal];
    [self.hangUpButton setBackgroundImage:[UIImage imageNamed:@"refuse_pre"] forState:UIControlStateHighlighted];
    [self.hangUpButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.hangUpButton addTarget:self
                   action:@selector(hangUp:)
         forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.hangUpButton];
    [self.hangUpButton setCenter:CGPointMake(self.view.frame.size.width / 2, kBtnYposition)];
    
    CGRect frame =
    CGRectMake(240, self.view.frame.size.height - kBtnHeight - kBtnHeight, kBtnWidth*2 , kBtnHeight);
    self.changeStateButton = [[UIButton alloc] initWithFrame:frame];
    [self.changeStateButton addTarget:self
                               action:@selector(changelistenState:)
                     forControlEvents:UIControlEventTouchUpInside];
    [self.changeStateButton setTitle:@"外放"  forState:UIControlStateNormal];
    [self.changeStateButton setBackgroundImage:[UIImage imageNamed:@"accept_nor"] forState:UIControlStateNormal];
    [self.changeStateButton setBackgroundImage:[UIImage imageNamed:@"accept_pre"] forState:UIControlStateHighlighted];
    self.changeStateButton.center = CGPointMake(self.view.frame.size.width/2, kBtnYposition +kBtnHeight/2*3);
    
    [self.changeStateButton setHidden:YES];
    [self.view addSubview:self.changeStateButton];
    
    
    self.reDialingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.reDialingButton.backgroundColor =
    [UIColor colorWithRed:0.78f green:0.78f blue:0.8f alpha:1.0f];
    self.reDialingButton.frame =
    CGRectMake(30.0f, self.view.frame.size.height - kBtnHeight - kBtnHeight, kBtnWidth*2, kBtnHeight);
    [self.reDialingButton setTitle:@"重拨" forState:UIControlStateNormal];
    
    [self.reDialingButton setBackgroundImage:[UIImage imageNamed:@"accept_nor"] forState:UIControlStateNormal];
    [self.reDialingButton setBackgroundImage:[UIImage imageNamed:@"accept_pre"] forState:UIControlStateHighlighted];
    [self.reDialingButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.reDialingButton addTarget:self
                          action:@selector(redialing:)
                forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.reDialingButton];
    [self.reDialingButton setCenter:CGPointMake(self.view.frame.size.width / 2, kBtnYposition)];
    [self.reDialingButton setHidden:YES];
    
     frame =
    CGRectMake(240, self.view.frame.size.height - kBtnHeight - kBtnHeight, kBtnWidth*2 , kBtnHeight);
    self.cancelButton = [[UIButton alloc] initWithFrame:frame];
    [self.cancelButton addTarget:self
                               action:@selector(cancelFaceTalk:)
                     forControlEvents:UIControlEventTouchUpInside];
    [self.cancelButton setTitle:@"取消"  forState:UIControlStateNormal];
    [self.cancelButton setBackgroundImage:[UIImage imageNamed:@"refuse_nor"] forState:UIControlStateNormal];
    [self.cancelButton setBackgroundImage:[UIImage imageNamed:@"refuse_pre"] forState:UIControlStateHighlighted];
    self.cancelButton.center = CGPointMake(self.view.frame.size.width/2, kBtnYposition +kBtnHeight/2*3);
    
    [self.cancelButton setHidden:YES];
    [self.view addSubview:self.cancelButton];
    [self.reDialingButton setHidden:YES];
    
    
    if (self.isCaller) {
        self.acceptButton.hidden = YES;
        self.refuseButton.hidden = YES;
    } else {
        self.hangUpButton.hidden = YES;
    }
    
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        if (granted) {
            if (self.isCaller) {
                
                [self makeDialing:voip];
                
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
        
        self.conversationDuration = 0;
        if (self.refreshTimer && [self.refreshTimer isValid]) {
            [self.refreshTimer invalidate];
            self.refreshTimer = nil;
            
        }
        
        [self sendHangUp];
        voip.state = VOIP_HANGED_UP;
        
        [self stopStream];
        
        [self dismiss];
    }else {
        NSLog(@"invalid voip state:%d", voip.state);
    }
}

-(void) changelistenState:(id)sender{
    self.isLoudspeaker = !self.isLoudspeaker;
    if (self.isLoudspeaker) {
        self.recvStream.isLoudspeaker = YES;
    }else{
        self.recvStream.isLoudspeaker = NO;
    }
}

-(void)redialing:(id)sender{
    VOIP *voip = [VOIP instance];
    [self makeDialing:voip];
    
    [self.hangUpButton setHidden:NO];
    [self.cancelButton setHidden:YES];
    [self.reDialingButton setHidden:YES];
}

-(void)cancelFaceTalk:(id)sender{
    
   [self dismiss];
    
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
        self.dialTimer = nil;
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
          
            [self setOnTalkingUIShow];

            
            [self sendConnected];
            voip.state = VOIP_CONNECTED;
            [self.dialTimer invalidate];
            self.dialTimer = nil;
            
            NSLog(@"call voip connected");
            [self startStream];
        } else if (ctl.cmd == VOIP_COMMAND_REFUSE) {
            voip.state = VOIP_REFUSED;
            self.history.flag = self.history.flag&FLAG_REFUSED;
 
            
            [self.dialTimer invalidate];
            self.dialTimer = nil;
            
            [self.view makeToast:@"对方正忙!" duration:2.0 position:@"center"];
            [self.hangUpButton setHidden:YES];
            [self.reDialingButton setHidden:NO];
            [self.cancelButton setHidden:NO];
            
        } else if (ctl.cmd == VOIP_COMMAND_DIAL) {
            //simultaneous open
            [self.dialTimer invalidate];
            self.dialTimer = nil;
            
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
            
            [self setOnTalkingUIShow];
            
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
/**
 *  创建拨号
 *
 *  @param voip  VOIP
 */
-(void) makeDialing:(VOIP*)voip{
    
    voip.state = VOIP_DIALING;
    
    self.dialBeginTimestamp = time(NULL);
    [self sendDial];
   
    self.dialTimer = [NSTimer scheduledTimerWithTimeInterval: 1
                                                      target:self
                                                    selector:@selector(sendDial)
                                                    userInfo:nil
                                                     repeats:YES];

}

/**
 *  显示通话中
 */
-(void) setOnTalkingUIShow{
    
    [self.changeStateButton setHidden:NO];
    [self.durationLabel setHidden:NO];
    [self.durationLabel setText:[self getTimeStrFromSeconds:self.conversationDuration]];
    [self.durationLabel sizeToFit];
    [self.durationLabel setTextAlignment:NSTextAlignmentCenter];
    [self.durationLabel setCenter:CGPointMake((self.view.frame.size.width)/2, self.headView.frame.origin.y + self.headView.frame.size.height + 50)];
    
    self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(refreshDuration) userInfo:nil repeats:YES];
    [self.refreshTimer fire];

}

/**
 *  刷新时间显示
 */
-(void) refreshDuration{
    self.conversationDuration += 1;
    [self.durationLabel setText:[self getTimeStrFromSeconds:self.conversationDuration]];
    [self.durationLabel sizeToFit];
    [self.durationLabel setTextAlignment:NSTextAlignmentCenter];
    [self.durationLabel setCenter:CGPointMake((self.view.frame.size.width)/2, self.headView.frame.origin.y + self.headView.frame.size.height + 50)];
}

/**
 *  获取时间字符串
 *
 *  @param seconds 秒
 *
 *  @return 字符串
 */
-(NSString*) getTimeStrFromSeconds:(UInt64)seconds{
    
    return [NSString stringWithFormat:@"%02lld:%02lld:%02lld",seconds/3600,(seconds%3600)/60,seconds%60];
    
}

@end
