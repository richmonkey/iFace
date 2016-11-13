//
//  VOIPViewController.m
//  Face
//
//  Created by houxh on 14-10-13.
//  Copyright (c) 2014年 beetle. All rights reserved.
//

#import "VOIPViewController.h"
#import "User.h"
#import "UserDB.h"
#import "UserPresent.h"
#import <voipsession/VOIPSession.h>
#import "HistoryDB.h"

#import "UIImageView+WebCache.h"

#import "UIView+Toast.h"
#import "PublicFunc.h"

#import "Config.h"
#import "Token.h"

#define kBtnWidth  72
#define kBtnHeight 72

#define kBtnSqureWidth  200
#define kBtnSqureHeight 50

#define KheaderViewWH  100

#define kBtnYposition  (self.view.frame.size.height - 2.5*kBtnSqureHeight)

@interface VOIPViewController ()<VOIPSessionDelegate>


@property(nonatomic) UIButton *acceptButton;
@property(nonatomic) UIButton *refuseButton;

@property (nonatomic) UIButton *reDialingButton;
@property (nonatomic) UIButton *cancelButton;


@property   (nonatomic) NSTimer *refreshTimer;

@property(nonatomic) UInt64  conversationDuration;

@property(nonatomic) History *history;

@property(nonatomic) AVAudioPlayer *player;

@property(nonatomic) BOOL isConnected;

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


- (BOOL)prefersStatusBarHidden {
    return YES;
}

-(void)dealloc {
    NSLog(@"voip view controller dealloc");
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.currentUID = [Token instance].uid;
    self.token = [Token instance].accessToken;
    self.peerUID = self.peerUser.uid;
    
    self.conversationDuration = 0;
    
    // Do any additional setup after loading the view, typically from a nib.
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    
    
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
    [self.durationLabel setBackgroundColor:[UIColor clearColor]];

    self.durationCenter = CGPointMake((self.view.frame.size.width)/2, self.headView.frame.origin.y + self.headView.frame.size.height + 50);
    
    [self.durationLabel setCenter:self.durationCenter];
    
    self.acceptButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.acceptButton.frame = CGRectMake(0,0, kBtnWidth, kBtnHeight);
    [self.acceptButton setBackgroundImage: [UIImage imageNamed:@"Call_Ans"] forState:UIControlStateNormal];
    [self.acceptButton setBackgroundImage:[UIImage imageNamed:@"Call_Ans_p"] forState:UIControlStateHighlighted];
    [self.acceptButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.acceptButton addTarget:self
                          action:@selector(acceptCall:)
                forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.acceptButton];
    [self.acceptButton setCenter:CGPointMake(self.view.frame.size.width/4 + self.view.frame.size.width/2, kBtnYposition)];
   
    
    
    self.refuseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.refuseButton.frame = CGRectMake(30.0f, self.view.frame.size.height - kBtnHeight - kBtnHeight, kBtnWidth, kBtnHeight);
    [self.refuseButton setBackgroundImage:[UIImage imageNamed:@"Call_hangup"] forState:UIControlStateNormal];
    [self.refuseButton setBackgroundImage:[UIImage imageNamed:@"Call_hangup_p"] forState:UIControlStateHighlighted];
    [self.refuseButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.refuseButton addTarget:self
                          action:@selector(refuseCall:)
                forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.refuseButton];
    [self.refuseButton setCenter:CGPointMake(self.view.frame.size.width/4, kBtnYposition)];
    
    
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
    
    CGRect frame = CGRectMake(0, 0, kBtnSqureWidth, kBtnSqureHeight);
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
    

    
    self.voip = [[VOIPSession alloc] init];
    self.voip.currentUID = [UserPresent instance].uid;
    self.voip.peerUID = self.peerUser.uid;
    self.voip.delegate = self;
    [[VOIPService instance] pushVOIPObserver:self.voip];
    
    [[VOIPService instance] addRTMessageObserver:self];

}

-(void)dismiss {
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    
    [self dismissViewControllerAnimated:YES completion:^{
        
        [[VOIPService instance] popVOIPObserver:self.voip];
        [[VOIPService instance] removeRTMessageObserver:self];
        
        [[HistoryDB instance] addHistory:self.history];
        
        NSNotification* notification = [NSNotification notificationWithName:ON_NEW_CALL_HISTORY_NOTIFY object:self.history];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
        
    }];
}

-(void)refuseCall:(UIButton*)button {
    [self.voip refuse];
    [self.player stop];
    self.player = nil;
    self.history.flag = self.history.flag|FLAG_REFUSED;
    
    self.refuseButton.enabled = NO;
    self.acceptButton.enabled = NO;
}

-(void)acceptCall:(UIButton*)button {
    //关闭外方
    AVAudioSession *session = [AVAudioSession sharedInstance];
    
    [session setCategory:AVAudioSessionCategoryPlayAndRecord
                   error:nil];
    
    [session overrideOutputAudioPort:AVAudioSessionPortOverrideNone
                               error:nil];
    
    [self.player stop];
    self.player = nil;
    self.history.flag = self.history.flag|FLAG_ACCEPTED;
    
    [self.voip accept];
    
    self.refuseButton.enabled = NO;
    self.acceptButton.enabled = NO;
}

-(void)hangUp:(UIButton*)button {
    [self.voip hangUp];
    if (self.isConnected) {
        self.conversationDuration = 0;
        if (self.refreshTimer && [self.refreshTimer isValid]) {
            [self.refreshTimer invalidate];
            self.refreshTimer = nil;
            
        }
        [self stopStream];
        
        [self dismiss];
    } else {
        [self.player stop];
        self.player = nil;
        
        self.history.flag = self.history.flag|FLAG_CANCELED;
        
        [self dismiss];
    }
}

-(void)redialing:(id)sender{
    [self dial];
    
    [self.hangUpButton setHidden:NO];
    [self.cancelButton setHidden:YES];
    [self.reDialingButton setHidden:YES];
}

-(void)cancelFaceTalk:(id)sender{
    [self dismiss];
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
    self.history.beginTimestamp = time(NULL);
    [super startStream];
}


-(void)stopStream {
    self.history.endTimestamp = time(NULL);
    [super stopStream];
}


-(int)setLoudspeakerStatus:(BOOL)enable {
    AVAudioSession* session = [AVAudioSession sharedInstance];
    NSString* category = session.category;
    AVAudioSessionCategoryOptions options = session.categoryOptions;
    // Respect old category options if category is
    // AVAudioSessionCategoryPlayAndRecord. Otherwise reset it since old options
    // might not be valid for this category.
    if ([category isEqualToString:AVAudioSessionCategoryPlayAndRecord]) {
        if (enable) {
            options |= AVAudioSessionCategoryOptionDefaultToSpeaker;
        } else {
            options &= ~AVAudioSessionCategoryOptionDefaultToSpeaker;
        }
    } else {
        options = AVAudioSessionCategoryOptionDefaultToSpeaker;
    }
    
    NSError* error = nil;
    [session setCategory:AVAudioSessionCategoryPlayAndRecord
             withOptions:options
                   error:&error];
    if (error != nil) {
        NSLog(@"set loudspeaker err:%@", error);
        return -1;
    }
    
    return 0;
}



#pragma mark - AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    NSLog(@"player finished");
    if (!self.isConnected) {
        [self.player play];
    }
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
    NSLog(@"player decode error");
}


-(void)playDialIn {
    NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"start.mp3"];
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
-(void) dial {
    self.acceptButton.hidden = YES;
    self.refuseButton.hidden = YES;
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    [self playDialOut];
}

-(void)waitAccept {
    self.hangUpButton.hidden = YES;
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    [self playDialOut];
}

/**
 *  显示通话中
 */
-(void) setOnTalkingUIShow{
    self.switchButton.hidden = NO;
    self.hangUpButton.hidden = NO;
    self.acceptButton.hidden = YES;
    self.refuseButton.hidden = YES;
    
    [self.durationLabel setHidden:NO];
    [self.durationLabel setText:[PublicFunc getTimeStrFromSeconds:self.conversationDuration]];
    [self.durationLabel sizeToFit];
    [self.durationLabel setCenter:self.durationCenter];
    
}

/**
 *  刷新时间显示
 */
-(void) refreshDuration{
    self.conversationDuration += 1;
    [self.durationLabel setText:[PublicFunc getTimeStrFromSeconds:self.conversationDuration]];
    [self.durationLabel sizeToFit];
    [self.durationLabel setCenter:self.durationCenter];
}

#pragma mark - VOIPStateDelegate
-(void)onRefuse {
    self.history.flag = self.history.flag|FLAG_REFUSED;
    [self.player stop];
    self.player = nil;
    
    [self.view makeToast:@"对方正忙!" duration:2.0 position:@"center"];
    [self.hangUpButton setHidden:YES];
    [self.reDialingButton setHidden:NO];
    [self.cancelButton setHidden:NO];
}

-(void)onHangUp {
    if (self.isConnected) {
        if (self.refreshTimer && [self.refreshTimer isValid]) {
            [self.refreshTimer invalidate];
            self.refreshTimer = nil;
        }
        [self stopStream];
        [self dismiss];
    } else {
        [self.player stop];
        self.player = nil;
        self.history.flag = self.history.flag|FLAG_UNRECEIVED;
        [self dismiss];
    }
}

-(void)onTalking {
    [self.player stop];
    self.player = nil;
    self.history.flag = self.history.flag|FLAG_UNRECEIVED;
    
    [self.view makeToast:@"对方正在通话中!" duration:2.0 position:@"center"];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self dismiss];
    });
}

-(void)onDialTimeout {
    [self.player stop];
    self.player = nil;
    
    self.history.flag = self.history.flag|FLAG_UNRECEIVED;
    
    [self.voip hangUp];
    [self dismiss];
}

-(void)onAcceptTimeout {
    [self dismiss];
}

-(void)onConnected {
    NSLog(@"call voip connected");
    self.isConnected = YES;
    self.history.flag = self.history.flag|FLAG_ACCEPTED;

    [self.player stop];
    self.player = nil;
    
    [self setOnTalkingUIShow];
    self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(refreshDuration) userInfo:nil repeats:YES];
    [self.refreshTimer fire];

    [self startStream];
}

-(void)onRefuseFinished {
    [self dismiss];
}

@end
