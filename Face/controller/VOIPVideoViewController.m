//
//  VOIPVideoViewController.m
//  voip_demo
//
//  Created by houxh on 15/9/7.
//  Copyright (c) 2015年 beetle. All rights reserved.
//

#import "VOIPVideoViewController.h"

#include <arpa/inet.h>
#import <AVFoundation/AVAudioSession.h>
#import <UIKit/UIKit.h>
#import "VOIPEngine.h"
#import "VOIPRenderView.h"

#import <voipsession/VOIPSession.h>
#import "UserPresent.h"
#import "Token.h"

@interface VOIPVideoViewController ()

@property(nonatomic) UIButton *switchButton;
@property(nonatomic) VOIPRenderView *remoteRender;
@property(nonatomic) VOIPRenderView *localRender;
@property BOOL showCancel;

@end

@implementation VOIPVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.switchButton = [[UIButton alloc] initWithFrame:CGRectMake(240,60,42,24)];
    
    [self.switchButton setImage:[UIImage imageNamed:@"switch"] forState:UIControlStateNormal];
    [self.switchButton addTarget:self
                     action:@selector(switchCamera:)
           forControlEvents:UIControlEventTouchUpInside];
    [self.switchButton setAlpha:0.0f];
    [self.switchButton setHidden:YES];
    
    [self.view addSubview:self.switchButton];
    
    [self.hangUpButton setAlpha:0.6f];
    
    self.durationCenter = CGPointMake(self.view.frame.size.width/2, 45);
    
    self.remoteRender = [[VOIPRenderView alloc] initWithFrame:self.view.bounds];
    [self.view insertSubview:self.remoteRender atIndex:0];
    
    
    UITapGestureRecognizer*tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
    [self.remoteRender addGestureRecognizer:tapGesture];
    
    self.localRender = [[VOIPRenderView alloc] initWithFrame:CGRectMake(200, 380, 72, 96)];
    [self.view insertSubview:self.localRender aboveSubview:self.remoteRender];
    
    self.localRender.hidden = YES;
    self.remoteRender.hidden = YES;
    
    self.showCancel = YES;
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)switchCamera:(id)sender {
    NSLog(@"switch camera");
    [self.engine switchCamera];
}

-(void)tapAction:(id)sender{
    if (self.showCancel) {
        self.showCancel = NO;
        
        [self.headView setHidden:YES];
        
        [UIView animateWithDuration:1.0 animations:^{
            [self.hangUpButton setAlpha:0.0];
            [self.durationLabel setAlpha:0.0];
            [self.switchButton setAlpha:0.0];
            [self.switchButton setAlpha:0.0];
        } completion:^(BOOL finished){
            [self.hangUpButton setHidden:YES];
            [self.durationLabel setHidden:YES];
            [self.switchButton setHidden:YES];
            [self.switchButton setHidden:YES];
        }];
    }else {
        
        self.showCancel = YES;
        
        [self.hangUpButton setHidden:NO];
        [self.durationLabel setHidden:NO];
        [self.switchButton setHidden:NO];
        [self.switchButton setHidden:NO];
        
        [UIView animateWithDuration:1.0 animations:^{
            [self.hangUpButton setAlpha:0.6f];
            [self.durationLabel setAlpha:1.0];
            [self.switchButton setAlpha:1.0];
            [self.switchButton setAlpha:1.0];
        } completion:^(BOOL finished){

        }];
    }
    
}

- (void)dial {
    [self.voip dialVideo];
}

- (void)startStream {
    [super startStream];
    [self tapAction:nil];
    
    if (self.voip.localNatMap != nil) {
        struct in_addr addr;
        addr.s_addr = htonl(self.voip.localNatMap.ip);
        NSLog(@"local nat map:%s:%d", inet_ntoa(addr), self.voip.localNatMap.port);
    }
    if (self.voip.peerNatMap != nil) {
        struct in_addr addr;
        addr.s_addr = htonl(self.voip.peerNatMap.ip);
        NSLog(@"peer nat map:%s:%d", inet_ntoa(addr), self.voip.peerNatMap.port);
    }
    
    if (self.isP2P) {
        struct in_addr addr;
        addr.s_addr = htonl(self.voip.peerNatMap.ip);
        NSLog(@"peer address:%s:%d", inet_ntoa(addr), self.voip.peerNatMap.port);
        NSLog(@"start p2p stream");
    } else {
        NSLog(@"start stream");
    }
    
    if (self.engine != nil) {
        return;
    }
    
    self.engine = [[VOIPEngine alloc] init];
    NSLog(@"relay ip:%@", self.voip.relayIP);
    self.engine.relayIP = self.voip.relayIP;
    self.engine.voipPort = self.voip.voipPort;
    self.engine.caller = [UserPresent instance].uid;
    self.engine.callee = self.peerUser.uid;
    self.engine.token = [Token instance].accessToken;
    self.engine.isCaller = self.isCaller;
    self.engine.videoEnabled = YES;
    
    self.engine.remoteRender = self.remoteRender;
    self.engine.localRender = self.localRender;
    
    
    if (self.isP2P) {
        self.engine.calleeIP = self.voip.peerNatMap.ip;
        self.engine.calleePort = self.voip.peerNatMap.port;
    }
    
    [self.engine startStream];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    self.localRender.hidden = NO;
    self.remoteRender.hidden = NO;
    
    [self SetLoudspeakerStatus:YES];
}


-(void)stopStream {
    [super stopStream];
    if (self.engine == nil) {
        return;
    }
    NSLog(@"stop stream");
    [self.engine stopStream];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}


@end
