//
//  MainTabBarController.m
//  Message
//
//  Created by houxh on 14-7-20.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import "MainTabBarController.h"
#import "ContactListTableViewController.h"
#import "ConversationHistoryViewController.h"
#import "SettingViewController.h"
#import "Token.h"
#import "IMService.h"
#import "UserPresent.h"
#import "Reachability.h"
#import "APIRequest.h"
#import "JSBadgeView.h"
#import "Constants.h"
#import "VOIP.h"
#import "VOIPViewController.h"
#import "UIView+Toast.h"

@interface MainTabBarController ()
@property(atomic) Reachability *reach;
@property(nonatomic)dispatch_source_t refreshTimer;
@property(nonatomic)int refreshFailCount;
@end

@implementation MainTabBarController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];

    
    ContactListTableViewController* contactViewController = [[ContactListTableViewController alloc] init];
    contactViewController.title = @"通讯录";
    
    contactViewController.tabBarItem.title = @"通讯录";
    contactViewController.tabBarItem.selectedImage = [UIImage imageNamed:@"ic_menu_contact_h"];
    contactViewController.tabBarItem.image = [UIImage imageNamed:@"ic_menu_contact_n"];

    UINavigationController *nav1 = [[UINavigationController alloc] initWithRootViewController:contactViewController];
    
    ConversationHistoryViewController *callHistoryViewController = [[ConversationHistoryViewController alloc] init];
    callHistoryViewController.title = @"通话记录";
    
    callHistoryViewController.tabBarItem.title = @"通话记录";
    callHistoryViewController.tabBarItem.selectedImage = [UIImage imageNamed:@"ic_menu_history_h"];
    callHistoryViewController.tabBarItem.image = [UIImage imageNamed:@"ic_menu_history_n"];
       UINavigationController *nav2 = [[UINavigationController alloc] initWithRootViewController:callHistoryViewController];
    
    
    
    SettingViewController *settingViewController = [[SettingViewController alloc] init];
    settingViewController.title = @"设置";
    
    settingViewController.tabBarItem.title = @"设置";
    settingViewController.tabBarItem.selectedImage = [UIImage imageNamed:@"ic_menu_setting_h"];
    settingViewController.tabBarItem.image = [UIImage imageNamed:@"ic_menu_setting_n"];
    UINavigationController *nav3 = [[UINavigationController alloc] initWithRootViewController:settingViewController];
    
    self.viewControllers = [NSArray arrayWithObjects:nav1,nav2, nav3,nil];
    self.selectedIndex = 0;
    
    dispatch_queue_t queue = dispatch_get_main_queue();
    self.refreshTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_event_handler(self.refreshTimer, ^{
        [self refreshAccessToken];
    });
    
    [self startRefreshTimer];
    self.reach = [Reachability reachabilityForInternetConnection];
    
    if ([self.reach isReachable]) {
        [[IMService instance] start:[UserPresent instance].uid];
    }
    
    self.reach.reachableBlock = ^(Reachability*reach) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"reachable");
            [[IMService instance] stop];
            [[IMService instance] start:[UserPresent instance].uid];
        });
    };
    __weak UIView *view = self.view;
    self.reach.unreachableBlock = ^(Reachability*reach) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"unreachable");
            [[IMService instance] stop];
            [view makeToast:@"手机网络错误,请检查" duration:3.0 position:@"center"];
        });
    };
    
    [self.reach startNotifier];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];

    [[self tabBar] setTintColor: RGBACOLOR(48,176,87, 1)];
    [[self tabBar] setBarTintColor: RGBACOLOR(245, 245, 246, 1)];
    
    [[IMService instance] pushVOIPObserver:self];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)appDidEnterBackground {
    //todo check voip state
    [[IMService instance] stop];
}

-(void)appWillEnterForeground {
    if ([self.reach isReachable]) {
        [[IMService instance] start:[UserPresent instance].uid];
    }
}


-(void)refreshAccessToken {
    Token *token = [Token instance];
    [APIRequest refreshAccessToken:token.refreshToken
                           success:^(NSString *accessToken, NSString *refreshToken, int expireTimestamp) {
                               token.accessToken = accessToken;
                               token.refreshToken = refreshToken;
                               token.expireTimestamp = expireTimestamp;
                               [token save];
                               [self prepareTimer];
                               
                           }
                              fail:^{
                                  self.refreshFailCount = self.refreshFailCount + 1;
                                  int64_t timeout;
                                  if (self.refreshFailCount > 60) {
                                      timeout = 60*NSEC_PER_SEC;
                                  } else {
                                      timeout = (int64_t)self.refreshFailCount*NSEC_PER_SEC;
                                  }
                                  
                                  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, timeout), dispatch_get_main_queue(), ^{
                                      [self prepareTimer];
                                  });
                                  
                              }];
}

-(void)prepareTimer {
    Token *token = [Token instance];
    int now = time(NULL);
    if (now >= token.expireTimestamp - 1) {
        dispatch_time_t w = dispatch_walltime(NULL, 0);
        dispatch_source_set_timer(self.refreshTimer, w, DISPATCH_TIME_FOREVER, 0);
    } else {
        dispatch_time_t w = dispatch_walltime(NULL, (token.expireTimestamp - now - 1)*NSEC_PER_SEC);
        dispatch_source_set_timer(self.refreshTimer, w, DISPATCH_TIME_FOREVER, 0);
    }
}

-(void) onNewMessage:(NSNotification*)ntf{
    UITabBar *tabBar = self.tabBar;
    UITabBarItem * cc =  [tabBar.items objectAtIndex: 2];
    [cc setBadgeValue:@""];
}

-(void) clearNewMessage:(NSNotification*)ntf{
    UITabBar *tabBar = self.tabBar;
    UITabBarItem * cc =  [tabBar.items objectAtIndex: 2];
    [cc setBadgeValue:nil];
}

-(void)startRefreshTimer {
    [self prepareTimer];
    dispatch_resume(self.refreshTimer);
}

-(void)stopRefreshTimer {
    dispatch_suspend(self.refreshTimer);
}


#pragma mark - VOIPObserver
-(void)onVOIPControl:(VOIPControl*)ctl {
    NSLog(@"voip command:%d", ctl.cmd);

    if (ctl.cmd == VOIP_COMMAND_DIAL) {
        VOIPViewController *controller = [[VOIPViewController alloc] initWithCallerUID:ctl.sender];
        [self presentViewController:controller animated:YES completion:nil];
    }
}


-(void)sendReset:(int64_t)uid {
    VOIPControl *ctl = [[VOIPControl alloc] init];
    ctl.sender = [UserPresent instance].uid;
    ctl.receiver = uid;
    ctl.cmd = VOIP_COMMAND_RESET;

    [[IMService instance] sendVOIPControl:ctl];
}

@end
