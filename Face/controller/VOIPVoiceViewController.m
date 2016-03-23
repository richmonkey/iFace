//
//  VOIPVoiceViewController.m
//  voip_demo
//
//  Created by houxh on 15/9/7.
//  Copyright (c) 2015年 beetle. All rights reserved.
//

#import "VOIPVoiceViewController.h"
#include <arpa/inet.h>
#import <AVFoundation/AVAudioSession.h>
#import <UIKit/UIKit.h>
#import <voipsession/VOIPSession.h>
#import "UserPresent.h"
#import "Token.h"



@interface VOIPVoiceViewController ()



@end

@implementation VOIPVoiceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
 
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dial {
    [self.voip dial];
}

- (void)startStream {
    [super startStream];

}


-(void)stopStream {
    [super stopStream];


}


@end
