//
//  VOIPViewController.m
//  Face
//
//  Created by houxh on 14-10-13.
//  Copyright (c) 2014年 beetle. All rights reserved.
//

#import "VOIPViewController.h"
#import "WebRTC.h"
#import "AVSendStream.h"
#import "AVReceiveStream.h"



#import "User.h"
#import "UserDB.h"
#import "UserPresent.h"
#import "VOIP.h"

@interface VOIPViewController ()

@property(strong, nonatomic) AVSendStream *sendStream;
@property(strong, nonatomic) AVReceiveStream *recvStream;
@property(nonatomic, assign) BOOL isCaller;
@property(nonatomic) User* peerUser;
@property(nonatomic, assign) int dialCount;
@property(nonatomic) NSTimer *dialTimer;
@property(nonatomic) NSTimer *acceptTimer;
@property(nonatomic) UIButton *hangUpButton;
@property(nonatomic) UIButton *acceptButton;
@property(nonatomic) UIButton *refuseButton;
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
    }
    return self;
}

-(id)initWithCallerUID:(int64_t)uid
{
    self = [super init];
    if (self) {
        self.peerUser = [[UserDB instance] loadUser:uid];
        self.isCaller = NO;
    }
    return self;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[IMService instance] pushVOIPObserver:self];
    
    VOIP *voip = [VOIP instance];
    if (voip.state != VOIP_LISTENING) {
        NSLog(@"invalid voip state:%d", voip.state);
        return;
    }
    

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
        voip.state = VOIP_DIALING;
        [self sendDial];
        
        self.dialTimer = [NSTimer scheduledTimerWithTimeInterval: 1
                                                          target:self
                                                        selector:@selector(sendDial)
                                                        userInfo:nil
                                                         repeats:YES];
        
        
        self.acceptButton.hidden = YES;
        self.refuseButton.hidden = YES;
    } else {
        voip.state = VOIP_ACCEPTING;
        self.hangUpButton.hidden = YES;
    }
}

-(void)refuseCall:(UIButton*)button {
    VOIP *voip = [VOIP instance];
    voip.state = VOIP_REFUSED;
    
    [self sendDialRefuse];
    
    [self dismissViewControllerAnimated:NO completion:^{
        voip.state = VOIP_LISTENING;
    }];
}

-(void)acceptCall:(UIButton*)button {
    VOIP *voip = [VOIP instance];
    voip.state = VOIP_ACCEPTED;
    self.acceptTimer = [NSTimer scheduledTimerWithTimeInterval: 1
                                                        target:self
                                                      selector:@selector(sendDialAccept)
                                                      userInfo:nil
                                                       repeats:YES];
    [self sendDialAccept];
}

-(void)hangUp:(UIButton*)button {
    VOIP *voip = [VOIP instance];
    if (voip.state == VOIP_DIALING || voip.state == VOIP_CONNECTED) {
        [self sendHangUp];
        voip.state = VOIP_HANGED_UP;
        [self.dialTimer invalidate];
        [self dismissViewControllerAnimated:YES completion:^{
            voip.state = VOIP_LISTENING;
            [[IMService instance] popVOIPObserver:self];
        }];
    } else {
        NSLog(@"invalid voip state:%d", voip.state);
    }
}

- (void)sendDial {
    NSLog(@"dial...");
    self.dialCount = self.dialCount + 1;
    VOIPControlCommand *command = [[VOIPControlCommand alloc] init];
    command.cmd = VOIP_COMMAND_DIAL;
    command.dialCount = self.dialCount;
    VOIPControl *ctl = [[VOIPControl alloc] init];
    ctl.sender = [UserPresent instance].uid;
    ctl.receiver = self.peerUser.uid;
    ctl.content = command.raw;
    [[IMService instance] sendVOIPControl:ctl];
}

-(void)sendControlCommand:(enum VOIPCommand)cmd {
    VOIPControlCommand *command = [[VOIPControlCommand alloc] init];
    command.cmd = cmd;
    VOIPControl *ctl = [[VOIPControl alloc] init];
    ctl.sender = [UserPresent instance].uid;
    ctl.receiver = self.peerUser.uid;
    ctl.content = command.raw;
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
}

-(void)sendDialRefuse {
    [self sendControlCommand:VOIP_COMMAND_REFUSE];
}

-(void)sendHangUp {
    [self sendControlCommand:VOIP_COMMAND_HANG_UP];
}

#pragma mark - VOIPObserver
-(void)onVOIPControl:(VOIPControl*)ctl {
    VOIP *voip = [VOIP instance];
    VOIPControlCommand *command = [[VOIPControlCommand alloc] initWithRaw:ctl.content];
    
    if (ctl.sender != self.peerUser.uid) {
        [self sendTalking];
        return;
    }
    NSLog(@"voip state:%d command:%d", voip.state, command.cmd);
    
    if (voip.state == VOIP_DIALING) {
        if (command.cmd == VOIP_COMMAND_ACCEPT) {
            [self sendConnected];
            voip.state = VOIP_CONNECTED;
            [self.dialTimer invalidate];
            NSLog(@"call voip connected");
            //todo 发送语音数据
            
        } else if (command.cmd == VOIP_COMMAND_REFUSE) {
            voip.state = VOIP_REFUSED;
            [self.dialTimer invalidate];
            [self dismissViewControllerAnimated:YES completion:^{
                voip.state = VOIP_LISTENING;
                [[IMService instance] popVOIPObserver:self];
            }];
        } else if (command.cmd == VOIP_COMMAND_DIAL) {
            //simultaneous open
            [self.dialTimer invalidate];
            voip.state = VOIP_ACCEPTED;
            self.acceptTimer = [NSTimer scheduledTimerWithTimeInterval: 1
                                                                target:self
                                                              selector:@selector(sendDialAccept)
                                                              userInfo:nil
                                                               repeats:YES];
            [self sendDialAccept];
        
        }
    } else if (voip.state == VOIP_ACCEPTING) {
        
    } else if (voip.state == VOIP_ACCEPTED) {
        if (command.cmd == VOIP_COMMAND_CONNECTED) {
            NSLog(@"called voip connected");
            [self.acceptTimer invalidate];
            voip.state = VOIP_CONNECTED;
            self.hangUpButton.hidden = NO;
            self.acceptButton.hidden = YES;
            self.refuseButton.hidden = YES;
            //todo 发送语音数据
        } else if (command.cmd == VOIP_COMMAND_ACCEPT) {
            //simultaneous open
            NSLog(@"simultaneous voip connected");
            [self.acceptTimer invalidate];
            voip.state = VOIP_CONNECTED;
            self.hangUpButton.hidden = NO;
            self.acceptButton.hidden = YES;
            self.refuseButton.hidden = YES;
            //todo 发送语音数据
        }
    } else if (voip.state == VOIP_CONNECTED) {
        if (command.cmd == VOIP_COMMAND_HANG_UP) {
            voip.state = VOIP_HANGED_UP;
            
            //todo 停止发送语音数据, dismiss self
        } else if (command.cmd == VOIP_COMMAND_RESET) {
            voip.state = VOIP_RESETED;
            //todo 停止发送语音数据, dismiss self
        } else if (command.cmd == VOIP_COMMAND_ACCEPT) {
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
        //todo 读取数据
    } else {
        NSLog(@"skip data...");
    }
}

@end
