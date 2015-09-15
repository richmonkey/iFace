//
//  DailCompView.h
//  Face
//
//  Created by 杨朋亮 on 12/9/15.
//  Copyright (c) 2015年 beetle. All rights reserved.
//

#import <UIKit/UIKit.h>


#define kDailVoiceBtnTag 100
#define kDailVideoBtnTag 101


@interface DailCompView : UIView

@property (weak, nonatomic) IBOutlet UIButton *voiceBtn;
@property (weak, nonatomic) IBOutlet UIButton *videoBtn;


+(id)fromXib;

@end
