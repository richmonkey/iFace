//
//  VOIPVoiceViewController.m
//  voip_demo
//
//  Created by houxh on 15/9/7.
//  Copyright (c) 2015年 beetle. All rights reserved.
//

#import "VOIPVoiceViewController.h"
#include <arpa/inet.h>
#import <UIKit/UIKit.h>
#import <voipsession/VOIPSession.h>
#import "UserPresent.h"
#import "Token.h"



@interface VOIPVoiceViewController ()



@end

@implementation VOIPVoiceViewController

- (void)viewDidLoad {
    self.isAudioOnly = NO;
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    AVAuthorizationStatus audioAuthStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if(audioAuthStatus == AVAuthorizationStatusAuthorized) {
        if (self.isCaller) {
            [self dial];
        } else {
            [self waitAccept];
        }
    } else if(audioAuthStatus == AVAuthorizationStatusDenied){
    } else if(audioAuthStatus == AVAuthorizationStatusRestricted){
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

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dial {
    [super dial];
    [self.voip dial];
}

- (void)startStream {
    [super startStream];
    [self setLoudspeakerStatus:NO];
}


-(void)stopStream {
    [super stopStream];
}


@end
