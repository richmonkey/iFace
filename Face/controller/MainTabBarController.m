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
#import <voipsession/VOIPService.h>
#import "UserPresent.h"
#import "APIRequest.h"
#import "JSBadgeView.h"
#import "Constants.h"
#import "VOIPVoiceViewController.h"
#import "VOIPVideoViewController.h"
#import "UIView+Toast.h"
#import <voipsession/voipcommand.h>
#import "APIRequest.h"

@interface MainTabBarController ()
@property(nonatomic)dispatch_source_t refreshTimer;
@property(nonatomic)int refreshFailCount;

@property(nonatomic) int bindFailCount;
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

    [VOIPService instance].token = [Token instance].accessToken;
    [[VOIPService instance] start];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];

    [[self tabBar] setTintColor: RGBACOLOR(48,176,87, 1)];
    [[self tabBar] setBarTintColor: RGBACOLOR(245, 245, 246, 1)];
    
    [[VOIPService instance] pushVOIPObserver:self];
    
    
    UIApplication *application = [UIApplication sharedApplication];
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeAlert
                                                                                         | UIUserNotificationTypeBadge
                                                                                         | UIUserNotificationTypeSound) categories:nil];
    [application registerUserNotificationSettings:settings];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRegisterForRemoteNotificationsWithDeviceToken:) name:@"didRegisterForRemoteNotificationsWithDeviceToken" object:nil];
}

-(void)didRegisterForRemoteNotificationsWithDeviceToken:(NSNotification*)notification {
    NSData *deviceToken = (NSData*)notification.object;
    
    NSString* newToken = [deviceToken description];
    newToken = [newToken stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    newToken = [newToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSLog(@"device token is: %@:%@", deviceToken, newToken);

    self.bindFailCount = 0;
    [self bindDeviceToken:newToken];
}

- (void)bindDeviceToken:(NSString*)deviceToken {
    [APIRequest bindDeviceToken:deviceToken
                        success:^{
                            NSLog(@"bind device token success");
                        }
                           fail:^{
                               NSLog(@"bind device token fail");
                               self.bindFailCount = self.bindFailCount + 1;
                               if (self.bindFailCount >= 10) {
                                   return;
                               }
                               
                               dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                   [self bindDeviceToken:deviceToken];
                               });
                           }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)appDidEnterBackground {
    //todo check voip state
    [[VOIPService instance] enterBackground];
}

-(void)appWillEnterForeground {
    [[VOIPService instance] enterForeground];
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
                               [VOIPService instance].token = accessToken;
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
    VOIPCommand *command = [[VOIPCommand alloc] initWithContent:ctl.content];
    NSLog(@"voip command:%d", command.cmd);
    if (command.cmd == VOIP_COMMAND_DIAL) {
        VOIPVoiceViewController *controller = [[VOIPVoiceViewController alloc] initWithCallerUID:ctl.sender];
        [self presentViewController:controller animated:YES completion:nil];
    } else if (command.cmd == VOIP_COMMAND_DIAL_VIDEO) {
        VOIPVideoViewController *controller = [[VOIPVideoViewController alloc] initWithCallerUID:ctl.sender];
        [self presentViewController:controller animated:YES completion:nil];
    }
}

@end
