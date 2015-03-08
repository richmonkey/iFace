//
//  VOIPViewController.m
//  Face
//
//  Created by houxh on 14-10-13.
//  Copyright (c) 2014年 beetle. All rights reserved.
//

#include <arpa/inet.h>
#import <AVFoundation/AVAudioSession.h>
#import "VOIPEngine.h"
#import "VOIPViewController.h"

#import "User.h"
#import "UserDB.h"
#import "UserPresent.h"
#import "VOIP.h"
#import "HistoryDB.h"

#import "UIImageView+WebCache.h"
#import "ReflectionView.h"
#import "UIView+Toast.h"
#import "PublicFunc.h"
#import "VWWWaterView.h"
#import "stun.h"
#import "Config.h"



#define kBtnWidth  72
#define kBtnHeight 72

#define kBtnSqureWidth  200
#define kBtnSqureHeight 50

#define KheaderViewWH  100

#define kBtnYposition  (self.view.frame.size.height - 2.5*kBtnSqureHeight)

@interface VOIPViewController ()
@property(nonatomic) VOIPEngine *engine;
@property(nonatomic, assign) BOOL isCaller;
@property(nonatomic) User* peerUser;

@property(nonatomic, assign) int dialCount;
@property(nonatomic, assign) time_t dialBeginTimestamp;
@property(nonatomic) NSTimer *dialTimer;

@property(nonatomic, assign) time_t acceptTimestamp;
@property(nonatomic) NSTimer *acceptTimer;

@property(nonatomic, assign) time_t refuseTimestamp;
@property(nonatomic) NSTimer *refuseTimer;

@property(nonatomic) UIButton *hangUpButton;
@property(nonatomic) UIButton *acceptButton;
@property(nonatomic) UIButton *refuseButton;
@property (nonatomic) UIButton *changeStateButton;

@property (nonatomic) UIButton *reDialingButton;
@property (nonatomic) UIButton *cancelButton;

@property(nonatomic) UIView *bkview;
@property(nonatomic) UILabel *durationLabel;
@property   (nonatomic) ReflectionView *headView;
@property   (nonatomic) NSTimer *refreshTimer;

@property(nonatomic) UInt64  conversationDuration;

@property(nonatomic) BOOL isLoudspeaker;

@property(nonatomic) History *history;

@property(nonatomic) AVAudioPlayer *player;

@property(nonatomic) NatPortMap *peerNatMap;
@property(nonatomic) NatPortMap *localNatMap;

@property(atomic, assign) StunAddress4 mappedAddr;
@property(atomic, assign) NatType natType;
@property(nonatomic) BOOL hairpin;
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

-(BOOL)isP2P {
    if (self.localNatMap.ip != 0 && self.peerNatMap.ip != 0 ) {
        return YES;
    }

    return NO;
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
    
    self.bkview = [[VWWWaterView alloc]
                   initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,
                                            self.view.frame.size.height)];
    [self.view addSubview:self.bkview];
    
    UIImageView *imgView = [[UIImageView alloc]
                            initWithFrame:CGRectMake(0,0, KheaderViewWH,
                                                     KheaderViewWH)];
    
    NSURL *avatar = nil;
    if (self.peerUser.avatarURL) {
        avatar = [[NSURL alloc] initWithString:self.peerUser.avatarURL];
    }
    [imgView sd_setImageWithURL:avatar
               placeholderImage:[UIImage imageNamed:@"potrait"]];
    
    CALayer *imageLayer = [imgView layer];  //获取ImageView的层
    [imageLayer setMasksToBounds:YES];
    [imageLayer setCornerRadius:imgView.frame.size.width / 2];
    
    self.headView = [[ReflectionView alloc] initWithFrame:CGRectMake((self.view.frame.size.width-KheaderViewWH)/2,80, KheaderViewWH,KheaderViewWH)];
    self.headView.alpha = 0.9f;
    self.headView.reflectionScale = 0.3f;
    self.headView.reflectionGap = 1.0f;
    [self.headView addSubview:imgView];
    
    [self.view addSubview:self.headView];
    
    
    self.durationLabel = [[UILabel alloc] init];
    [self.durationLabel setFont:[UIFont systemFontOfSize:23.0f]];
    [self.durationLabel setTextAlignment:NSTextAlignmentCenter];
    [self.durationLabel sizeToFit];
    [self.durationLabel setTextColor: RGBCOLOR(11, 178, 39)];
    [self.durationLabel setHidden:YES];
    [self.view addSubview:self.durationLabel];
    [self.durationLabel setCenter:CGPointMake((self.view.frame.size.width)/2, self.headView.frame.origin.y + self.headView.frame.size.height + 50)];
    [self.durationLabel setBackgroundColor:[UIColor clearColor]];
    
    
    
    
    self.acceptButton = [UIButton buttonWithType:UIButtonTypeCustom];

    self.acceptButton.frame = CGRectMake(30.0f, self.view.frame.size.height - kBtnHeight - kBtnHeight, kBtnWidth, kBtnHeight);
    
    [self.acceptButton setBackgroundImage: [UIImage imageNamed:@"Call_Ans"] forState:UIControlStateNormal];
    
    [self.acceptButton setBackgroundImage:[UIImage imageNamed:@"Call_Ans_p"] forState:UIControlStateHighlighted];
    [self.acceptButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.acceptButton addTarget:self
                   action:@selector(acceptCall:)
         forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.acceptButton];
    [self.acceptButton setCenter:CGPointMake(self.view.frame.size.width/4, kBtnYposition)];
    
    
    self.refuseButton = [UIButton buttonWithType:UIButtonTypeCustom];

    self.refuseButton.frame = CGRectMake(0,0, kBtnWidth, kBtnHeight);
    
    [self.refuseButton setBackgroundImage:[UIImage imageNamed:@"Call_hangup"] forState:UIControlStateNormal];
    [self.refuseButton setBackgroundImage:[UIImage imageNamed:@"Call_hangup_p"] forState:UIControlStateHighlighted];
    [self.refuseButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.refuseButton addTarget:self
                   action:@selector(refuseCall:)
         forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.refuseButton];
    [self.refuseButton setCenter:CGPointMake(self.view.frame.size.width/4 + self.view.frame.size.width/2, kBtnYposition)];
    
    
    self.hangUpButton = [[UIButton alloc] initWithFrame:CGRectMake(0,0, kBtnSqureWidth, kBtnSqureHeight)];
    [self.hangUpButton setBackgroundImage:[UIImage imageNamed:@"refuse_nor"] forState:UIControlStateNormal];
    [self.hangUpButton setBackgroundImage:[UIImage imageNamed:@"refuse_pre"] forState:UIControlStateHighlighted];
    [self.hangUpButton setTitle:@"挂断" forState:UIControlStateNormal];
    [self.hangUpButton.titleLabel setFont:[UIFont systemFontOfSize:20.0f]];
    [self.hangUpButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.hangUpButton addTarget:self
                   action:@selector(hangUp:)
         forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.hangUpButton];
    [self.hangUpButton setCenter:CGPointMake(self.view.frame.size.width / 2, kBtnYposition)];
    
    self.reDialingButton = [UIButton buttonWithType:UIButtonTypeCustom];

    self.reDialingButton.frame =
    CGRectMake(0, 0, kBtnSqureWidth, kBtnSqureHeight);
    
    [self.reDialingButton setBackgroundImage:[UIImage imageNamed:@"accept_nor"] forState:UIControlStateNormal];
    [self.reDialingButton setBackgroundImage:[UIImage imageNamed:@"accpet_pre"] forState:UIControlStateHighlighted];
    [self.reDialingButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.reDialingButton addTarget:self
                          action:@selector(redialing:)
                forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.reDialingButton];
    [self.reDialingButton setTitle:@"重拨" forState:UIControlStateNormal];
    [self.reDialingButton.titleLabel setFont:[UIFont systemFontOfSize:20.0f]];
    [self.reDialingButton setCenter:CGPointMake(self.view.frame.size.width / 2, kBtnYposition)];
    [self.reDialingButton setHidden:YES];
    
    
    CGRect frame =
    CGRectMake(0, 0, kBtnSqureWidth, kBtnSqureHeight);
    self.cancelButton = [[UIButton alloc] initWithFrame:frame];
    [self.cancelButton addTarget:self
                               action:@selector(cancelFaceTalk:)
                     forControlEvents:UIControlEventTouchUpInside];
    [self.cancelButton setBackgroundImage:[UIImage imageNamed:@"refuse_nor"] forState:UIControlStateNormal];
    [self.cancelButton setBackgroundImage:[UIImage imageNamed:@"refuse_pre"] forState:UIControlStateHighlighted];
    [self.cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [self.cancelButton.titleLabel setFont:[UIFont systemFontOfSize:20.0f]];
    self.cancelButton.center = CGPointMake(self.view.frame.size.width/2, kBtnYposition +kBtnHeight);
    
    
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
            [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];

            if (self.isCaller) {
                
                [self makeDialing:voip];
                
            } else {
                voip.state = VOIP_ACCEPTING;
                [self playDialIn];
            }

        } else {
            NSLog(@"can't grant record permission");
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self dismissViewControllerAnimated:NO completion:^{
                    [[IMService instance] popVOIPObserver:self];
                }];
            });
        }
    }];

    self.natType = StunTypeUnknown;
    self.hairpin = NO;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        StunAddress4 addr;
        BOOL hairpin = NO;
        NatType stype = [self mapNatAddress:&addr hairpin:&hairpin];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.natType = stype;
            self.mappedAddr = addr;
            

            if (self.localNatMap == nil) {
                self.localNatMap = [[NatPortMap alloc] init];
                self.localNatMap.ip = self.mappedAddr.addr;
                self.localNatMap.port = self.mappedAddr.port;

                self.localNatMap.localIP = [self getPrimaryIP];
                self.localNatMap.localPort = [Config instance].voipPort;
            }

        });
    });
}

-(int32_t)getPrimaryIP {
    int sock = socket(AF_INET, SOCK_DGRAM, 0);
    assert(sock != -1);
    
    const char* kGoogleDnsIp = "8.8.8.8";
    uint16_t kDnsPort = 53;
    struct sockaddr_in serv;
    memset(&serv, 0, sizeof(serv));
    serv.sin_family = AF_INET;
    serv.sin_addr.s_addr = inet_addr(kGoogleDnsIp);
    serv.sin_port = htons(kDnsPort);
    
    int err = connect(sock, (const sockaddr*) &serv, sizeof(serv));
    if (err == -1) {
        return 0;
    }
    
    sockaddr_in name;
    socklen_t namelen = sizeof(name);
    bzero(&name, namelen);
    
    err = getsockname(sock, (sockaddr*) &name, &namelen);
    if (err == -1) {
        perror("get sock name");
        return 0;
    }
    
    close(sock);
    
    return ntohl(name.sin_addr.s_addr);
}

#define VERBOSE false
-(NatType)mapNatAddress:(StunAddress4*)eaddr hairpin:(BOOL*)ph{
    int fd = -1;
    StunAddress4 mappedAddr;
    StunAddress4 stunServerAddr;
    Config *config = [Config instance];
    NSString *stunServer = [Config instance].stunServer;
    stunParseServerName( (char*)[stunServer UTF8String], stunServerAddr);
    
    NSLog(@"nat mapping...");
    bool presPort = false, hairpin = false;
    NatType stype = stunNatType( stunServerAddr, VERBOSE, &presPort, &hairpin,
                                0, NULL);
    
    NSLog(@"nat type:%d", stype);
    *ph = hairpin;
    
    BOOL isOpen = NO;
    switch (stype)
    {
        case StunTypeFailure:
            break;
        case StunTypeUnknown:
            break;
        case StunTypeBlocked:
            break;
            
        case StunTypeOpen:
        case StunTypeFirewall:
            //todo get local address
        case StunTypeIndependentFilter:
        case StunTypeDependentFilter:
        case StunTypePortDependedFilter:
            isOpen = YES;
            break;
        case StunTypeDependentMapping:
            break;
        default:
            break;
    }
    
    
    if (!isOpen) {
        return stype;
    }
    for (int i = 0; i < 8; i++) {
        fd = stunOpenSocket(stunServerAddr, &mappedAddr, config.voipPort, NULL, VERBOSE);
        if (fd == -1) {
            continue;
        }
        break;
    }
    if (fd != -1) {
        close(fd);
        struct in_addr addr;
        addr.s_addr = htonl(mappedAddr.addr);
        NSLog(@"mapped address:%s:%d", inet_ntoa(addr), mappedAddr.port);
        *eaddr = mappedAddr;
    } else {
        NSLog(@"map nat address fail");
    }
    return stype;
}


-(void)dismiss {
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];

    [self dismissViewControllerAnimated:YES completion:^{
        VOIP *voip = [VOIP instance];
        voip.state = VOIP_LISTENING;
        [[IMService instance] popVOIPObserver:self];
        [[HistoryDB instance] addHistory:self.history];
       
        NSNotification* notification = [NSNotification notificationWithName:ON_NEW_CALL_HISTORY_NOTIFY object:self.history];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
        
    }];
}

-(void)refuseCall:(UIButton*)button {
    VOIP *voip = [VOIP instance];
    voip.state = VOIP_REFUSING;
    [self.player stop];
    self.player = nil;
    self.history.flag = self.history.flag|FLAG_REFUSED;
    
    self.refuseTimestamp = time(NULL);
    self.refuseTimer = [NSTimer scheduledTimerWithTimeInterval: 1
                                                        target:self
                                                      selector:@selector(sendDialRefuse)
                                                      userInfo:nil
                                                       repeats:YES];

    [self sendDialRefuse];
    
    self.refuseButton.enabled = NO;
    self.acceptButton.enabled = NO;
}

-(void)acceptCall:(UIButton*)button {
    
    VOIP *voip = [VOIP instance];
    voip.state = VOIP_ACCEPTED;
    
    //关闭外方
    AVAudioSession *session = [AVAudioSession sharedInstance];
    
    [session setCategory:AVAudioSessionCategoryPlayAndRecord
                   error:nil];
    
    [session overrideOutputAudioPort:AVAudioSessionPortOverrideNone
                               error:nil];
    
    [self.player stop];
    self.player = nil;
    self.history.flag = self.history.flag|FLAG_ACCEPTED;

    if (self.localNatMap == nil) {
        self.localNatMap = [[NatPortMap alloc] init];
    }
    
    self.acceptTimestamp = time(NULL);
    self.acceptTimer = [NSTimer scheduledTimerWithTimeInterval: 1
                                                        target:self
                                                      selector:@selector(sendDialAccept)
                                                      userInfo:nil
                                                       repeats:YES];
    [self sendDialAccept];
    
    self.refuseButton.enabled = NO;
    self.acceptButton.enabled = NO;
}

-(void)hangUp:(UIButton*)button {
    VOIP *voip = [VOIP instance];
    if (voip.state == VOIP_DIALING ) {
        [self.dialTimer invalidate];
        self.dialTimer = nil;
        [self.player stop];
        self.player = nil;
        
        [self sendHangUp];
        voip.state = VOIP_HANGED_UP;
        
        self.history.flag = self.history.flag|FLAG_CANCELED;

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
        [self.player stop];
        self.player = nil;
        
        self.history.flag = self.history.flag|FLAG_UNRECEIVED;
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

-(void)sendRefused {
    [self sendControlCommand:VOIP_COMMAND_REFUSED];
}

-(void)sendTalking {
    [self sendControlCommand:VOIP_COMMAND_TALKING];
}

-(void)sendReset {
    [self sendControlCommand:VOIP_COMMAND_RESET];
}

-(void)sendConnected {
    VOIPControl *ctl = [[VOIPControl alloc] init];
    ctl.sender = [UserPresent instance].uid;
    ctl.receiver = self.peerUser.uid;
    ctl.cmd = VOIP_COMMAND_CONNECTED;
    ctl.natMap = self.localNatMap;
    
    [[IMService instance] sendVOIPControl:ctl];
}
-(void)sendDialAccept {
    VOIPControl *ctl = [[VOIPControl alloc] init];
    ctl.sender = [UserPresent instance].uid;
    ctl.receiver = self.peerUser.uid;
    ctl.cmd = VOIP_COMMAND_ACCEPT;
    ctl.natMap = self.localNatMap;
    
    [[IMService instance] sendVOIPControl:ctl];
    
    time_t now = time(NULL);
    if (now - self.acceptTimestamp >= 10) {
        NSLog(@"accept timeout");
        [self.acceptTimer invalidate];
        [self dismiss];
    }
}

-(void)sendDialRefuse {
    [self sendControlCommand:VOIP_COMMAND_REFUSE];
    
    time_t now = time(NULL);
    if (now - self.refuseTimestamp > 10) {
        NSLog(@"refuse timeout");
        [self.refuseTimer invalidate];
        
        VOIP *voip = [VOIP instance];
        voip.state = VOIP_REFUSED;
        [self dismiss];
    }
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
    if (self.localNatMap != nil) {
        struct in_addr addr;
        addr.s_addr = htonl(self.localNatMap.ip);
        NSLog(@"local nat map:%s:%d", inet_ntoa(addr), self.localNatMap.port);
        

        addr.s_addr = htonl(self.localNatMap.localIP);
        NSLog(@"local host:%s:%d", inet_ntoa(addr), self.localNatMap.localPort);
        
    }
    if (self.peerNatMap != nil) {
        struct in_addr addr;
        addr.s_addr = htonl(self.peerNatMap.ip);
        NSLog(@"peer nat map:%s:%d", inet_ntoa(addr), self.peerNatMap.port);
        
        addr.s_addr = htonl(self.peerNatMap.localIP);
        NSLog(@"peer local host:%s:%d", inet_ntoa(addr), self.peerNatMap.localPort);
    }
    
    if (self.isP2P) {
        struct in_addr addr;
        addr.s_addr = htonl(self.peerNatMap.ip);
        NSLog(@"peer address:%s:%d", inet_ntoa(addr), self.peerNatMap.port);
        NSLog(@"start p2p stream");
    } else {
        NSLog(@"start stream");
    }

    if (self.engine != nil) {
        return;
    }
    
    BOOL isHeadphone = [self isHeadsetPluggedIn];
    
    self.engine = [[VOIPEngine alloc] init];
    self.engine.serverIP = [IMService instance].hostIP;
    self.engine.voipPort = [Config instance].voipPort;
    self.engine.caller = [UserPresent instance].uid;
    self.engine.callee = self.peerUser.uid;
    if (self.isP2P) {
        self.engine.calleeIP = self.peerNatMap.ip;
        self.engine.calleePort = self.peerNatMap.port;
    }
    
    [self.engine startStream:isHeadphone];
    
    self.history.beginTimestamp = time(NULL);
}


-(void)stopStream {
    if (self.engine == nil) {
        return;
    }
    NSLog(@"stop stream");
    [self.engine stopStream];
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
            self.history.flag = self.history.flag|FLAG_ACCEPTED;
          
            [self setOnTalkingUIShow];
            
            self.peerNatMap = ctl.natMap;
            
            if (self.localNatMap == nil) {
                self.localNatMap = [[NatPortMap alloc] init];
            }
            
            [self sendConnected];
            voip.state = VOIP_CONNECTED;
            [self.dialTimer invalidate];
            self.dialTimer = nil;
            [self.player stop];
            self.player = nil;
            
            NSLog(@"call voip connected");
            [self startStream];
        } else if (ctl.cmd == VOIP_COMMAND_REFUSE) {
            voip.state = VOIP_REFUSED;
            self.history.flag = self.history.flag|FLAG_REFUSED;
 
            [self sendRefused];
            
            [self.dialTimer invalidate];
            self.dialTimer = nil;
            [self.player stop];
            self.player = nil;
            
            [self.view makeToast:@"对方正忙!" duration:2.0 position:@"center"];
            [self.hangUpButton setHidden:YES];
            [self.reDialingButton setHidden:NO];
            [self.cancelButton setHidden:NO];
            
        } else if (ctl.cmd == VOIP_COMMAND_DIAL) {
            //simultaneous open
            [self.dialTimer invalidate];
            self.dialTimer = nil;
            [self.player stop];
            self.player = nil;
            
            voip.state = VOIP_ACCEPTED;
            self.history.flag = self.history.flag|FLAG_ACCEPTED;

            if (self.localNatMap == nil) {
                self.localNatMap = [[NatPortMap alloc] init];
            }

            self.acceptTimestamp = time(NULL);
            self.acceptTimer = [NSTimer scheduledTimerWithTimeInterval: 1
                                                                target:self
                                                              selector:@selector(sendDialAccept)
                                                              userInfo:nil
                                                               repeats:YES];
            [self sendDialAccept];
        }
    } else if (voip.state == VOIP_ACCEPTING) {
        if (ctl.cmd == VOIP_COMMAND_HANG_UP) {
            [self.player stop];
            self.player = nil;
            self.history.flag = self.history.flag|FLAG_UNRECEIVED;
            voip.state = VOIP_HANGED_UP;
            [self dismiss];
        }
    } else if (voip.state == VOIP_ACCEPTED) {
        if (ctl.cmd == VOIP_COMMAND_CONNECTED) {
            NSLog(@"called voip connected");
            
            [self setOnTalkingUIShow];
            
            self.peerNatMap = ctl.natMap;
            
            [self.acceptTimer invalidate];
            voip.state = VOIP_CONNECTED;
            [self startStream];
            
            self.hangUpButton.hidden = NO;
            self.acceptButton.hidden = YES;
            self.refuseButton.hidden = YES;
        } else if (ctl.cmd == VOIP_COMMAND_ACCEPT) {
            //simultaneous open
            NSLog(@"simultaneous voip connected");
            [self setOnTalkingUIShow];
            
            self.peerNatMap = ctl.natMap;
            
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
            if (self.refreshTimer && [self.refreshTimer isValid]) {
                [self.refreshTimer invalidate];
                self.refreshTimer = nil;
            }
            [self stopStream];
            [self dismiss];
        } else if (ctl.cmd == VOIP_COMMAND_RESET) {
            voip.state = VOIP_RESETED;
            [self stopStream];
            if (self.refreshTimer && [self.refreshTimer isValid]) {
                [self.refreshTimer invalidate];
                self.refreshTimer = nil;
            }
            [self dismiss];

        } else if (ctl.cmd == VOIP_COMMAND_ACCEPT) {
            [self sendConnected];
        }
    } else if (voip.state == VOIP_REFUSING) {
        if (ctl.cmd == VOIP_COMMAND_REFUSED) {
            NSLog(@"refuse finished");
            voip.state = VOIP_REFUSED;
            [self.refuseTimer invalidate];
            
            [self dismiss];
        }
    }
}



#pragma mark - AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    NSLog(@"player finished");
    VOIP *voip = [VOIP instance];
    if (voip.state == VOIP_DIALING || voip.state == VOIP_ACCEPTING) {
        [self.player play];
    }
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
    NSLog(@"player decode error");
}


-(void)playDialIn {

    NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"start.mp3"];
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    //打开外放
    [session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker
                               error:nil];
    
    
    NSURL *u = [NSURL fileURLWithPath:path];
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:u error:nil];
    [self.player setDelegate:self];
    
    [self.player play];
}

-(void)playDialOut {
    
    NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"CallConnected.mp3"];
    BOOL r = [[NSFileManager defaultManager] fileExistsAtPath:path];
    NSLog(@"exist:%d", r);
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    NSURL *u = [NSURL fileURLWithPath:path];
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:u error:nil];
    [self.player setDelegate:self];
    
    [self.player play];
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
    [self playDialOut];
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
    [self.durationLabel setText:[PublicFunc getTimeStrFromSeconds:self.conversationDuration]];
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
    [self.durationLabel setText:[PublicFunc getTimeStrFromSeconds:self.conversationDuration]];
    [self.durationLabel sizeToFit];
    [self.durationLabel setTextAlignment:NSTextAlignmentCenter];
    [self.durationLabel setCenter:CGPointMake((self.view.frame.size.width)/2, self.headView.frame.origin.y + self.headView.frame.size.height + 50)];
}



@end
