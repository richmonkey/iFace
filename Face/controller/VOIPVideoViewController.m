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
#import <voipsession/VOIPSession.h>
#import "UserPresent.h"
#import "Token.h"

@interface VOIPVideoViewController ()

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
    

    
    self.showCancel = YES;
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)switchCamera:(id)sender {
    NSLog(@"switch camera");

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
    
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    

    
    [self SetLoudspeakerStatus:YES];
}


-(void)stopStream {
    [super stopStream];

    
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}


@end
