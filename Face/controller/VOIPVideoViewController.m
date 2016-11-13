//
//  VOIPVideoViewController.m
//  voip_demo
//
//  Created by houxh on 15/9/7.
//  Copyright (c) 2015年 beetle. All rights reserved.
//

#import "VOIPVideoViewController.h"
#import <voipsession/VOIPSession.h>
#import "UserPresent.h"
#import "Token.h"

@interface VOIPVideoViewController ()<RTCEAGLVideoViewDelegate>


@property BOOL showCancel;

@end

@implementation VOIPVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.switchButton = [[UIButton alloc] initWithFrame:CGRectMake(240,27,42,24)];
    [self.switchButton setImage:[UIImage imageNamed:@"switch"] forState:UIControlStateNormal];
    [self.switchButton addTarget:self
                     action:@selector(switchCamera:)
           forControlEvents:UIControlEventTouchUpInside];
    [self.switchButton setHidden:YES];
    
    [self.view addSubview:self.switchButton];
    
    [self.hangUpButton setAlpha:0.6f];
    
    self.durationCenter = CGPointMake(self.view.frame.size.width/2, 40);
  

    
    RTCEAGLVideoView *remoteVideoView = [[RTCEAGLVideoView alloc] initWithFrame:self.view.bounds];
    remoteVideoView.delegate = self;
    
    self.remoteVideoView = remoteVideoView;
    [self.view insertSubview:self.remoteVideoView atIndex:0];
    
    RTCCameraPreviewView *localVideoView = [[RTCCameraPreviewView alloc] initWithFrame:CGRectMake(200, 380, 72, 96)];
    self.localVideoView = localVideoView;
    [self.view insertSubview:self.localVideoView aboveSubview:self.remoteVideoView];
    
    
    self.localVideoView.hidden = YES;
    self.remoteVideoView.hidden = YES;
    
    UITapGestureRecognizer*tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
    [self.remoteVideoView addGestureRecognizer:tapGesture];
    
    self.showCancel = YES;
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(authStatus == AVAuthorizationStatusAuthorized) {
        // do your logic
        AVAuthorizationStatus audioAuthStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
        if(audioAuthStatus == AVAuthorizationStatusAuthorized) {
            if (self.isCaller) {
                [self dial];
            } else {
                [self waitAccept];
            }
        } else if(audioAuthStatus == AVAuthorizationStatusDenied){
            // denied
        } else if(audioAuthStatus == AVAuthorizationStatusRestricted){
            // restricted, normally won't happen
        } else if(audioAuthStatus == AVAuthorizationStatusNotDetermined){
            [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
                if (granted) {
                    if (self.isCaller) {
                        [self dial];
                    } else {
                        [self waitAccept];
                    }
                } else {
                    NSLog(@"can't grant record permission");
                }
            }];
            
        }
        
    } else if(authStatus == AVAuthorizationStatusDenied){
        // denied
    } else if(authStatus == AVAuthorizationStatusRestricted){
        // restricted, normally won't happen
    } else if(authStatus == AVAuthorizationStatusNotDetermined){
        // not determined?!
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if(granted){
                NSLog(@"Granted access to %@", AVMediaTypeVideo);
                AVAuthorizationStatus audioAuthStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
                if(audioAuthStatus == AVAuthorizationStatusAuthorized) {
                    if (self.isCaller) {
                        [self dial];
                    } else {
                        [self waitAccept];
                    }
                } else if(audioAuthStatus == AVAuthorizationStatusDenied){
                    // denied
                } else if(audioAuthStatus == AVAuthorizationStatusRestricted){
                    // restricted, normally won't happen
                } else if(audioAuthStatus == AVAuthorizationStatusNotDetermined){
                    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
                        if (granted) {
                            
                            if (self.isCaller) {
                                [self dial];
                            } else {
                                [self waitAccept];
                            }
                        } else {
                            NSLog(@"can't grant record permission");
                        }
                    }];
                }
            } else {
                NSLog(@"Not granted access to %@", AVMediaTypeVideo);
            }
        }];
    }
}


- (void)videoView:(RTCEAGLVideoView *)videoView didChangeVideoSize:(CGSize)size {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)switchCamera:(id)sender {
    NSLog(@"switch camera");
    
    RTCVideoSource* source = self.localVideoTrack.source;
    if ([source isKindOfClass:[RTCAVFoundationVideoSource class]]) {
        RTCAVFoundationVideoSource* avSource = (RTCAVFoundationVideoSource*)source;
        avSource.useBackCamera = !avSource.useBackCamera;
    }
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
    [super dial];
    [self.voip dialVideo];
}

- (void)startStream {
    [super startStream];
    [self tapAction:nil];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    self.localVideoView.hidden = NO;
    self.remoteVideoView.hidden = NO;
    [self setLoudspeakerStatus:YES];
}


-(void)stopStream {
    [super stopStream];

    
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}


@end
