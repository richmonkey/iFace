//
//  AppDelegate.m
//  Face
//
//  Created by houxh on 14-10-13.
//  Copyright (c) 2014年 beetle. All rights reserved.
//

#import "AppDelegate.h"
#import <voipsession/VOIPService.h>
#import "Config.h"
#import "Token.h"
#import "MainTabBarController.h"
#import "AskPhoneNumberViewController.h"
#import "APIRequest.h"
#include <netdb.h>
#include <arpa/inet.h>
#include <netinet/in.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    //配置im server地址
    [VOIPService instance].host = [Config instance].sdkHost;
    [VOIPService instance].isSync = NO;
    
    [VOIPService instance].deviceID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    [[VOIPService instance] startRechabilityNotifier];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    application.statusBarHidden = NO;
    
    
    Token *token = [Token instance];
    if (token.accessToken) {
        UITabBarController *tabController = [[MainTabBarController alloc] init];
        self.tabBarController = tabController;
        self.window.rootViewController = tabController;
    }else{
        AskPhoneNumberViewController *ctl = [[AskPhoneNumberViewController alloc] init];
        UINavigationController * navCtr = [[UINavigationController alloc] initWithRootViewController: ctl];
        self.window.rootViewController = navCtr;
    }
    
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60)
                                                         forBarMetrics:UIBarMetricsDefault];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeAlert
                                                                                         | UIUserNotificationTypeBadge
                                                                                         | UIUserNotificationTypeSound) categories:nil];
    [application registerUserNotificationSettings:settings];
    
 
    
    [self refreshHost];
    return YES;
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    //register to receive notifications
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didRegisterForRemoteNotificationsWithDeviceToken"
                                                        object:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"register remote notification error:%@", error);
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [self refreshHost];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}





-(void)refreshHost {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSLog(@"refresh host ip...");
        
        for (int i = 0; i < 10; i++) {
            NSString *host = [Config instance].sdkHost;
            NSString *ip = [self resolveIP:host];
            
            NSString *apiHost = [Config instance].URL;
            NSString *apiIP = [self resolveIP:apiHost];
            
            NSString *sdkAPIHost = [Config instance].sdkAPIURL;
            NSString *sdkAPIIP = [self resolveIP:sdkAPIHost];
            
            NSString *voipHost = @"voipnode.gobelieve.io";
            NSString *voipHostIP = [self resolveIP:voipHost];
            
            NSLog(@"host:%@ ip:%@", host, ip);
            NSLog(@"api host:%@ ip:%@", apiHost, apiIP);
            NSLog(@"sdk api host:%@ ip:%@", sdkAPIHost, sdkAPIIP);
            
            if (ip.length == 0 || apiIP.length == 0 ||
                sdkAPIIP.length == 0 || voipHostIP.length == 0) {
                continue;
            } else {
                break;
            }
        }
    });
}

-(NSString*)IP2String:(struct in_addr)addr {
    char buf[64] = {0};
    const char *p = inet_ntop(AF_INET, &addr, buf, 64);
    if (p) {
        return [NSString stringWithUTF8String:p];
    }
    return nil;
    
}

-(NSString*)resolveIP:(NSString*)host {
    struct addrinfo hints;
    struct addrinfo *result, *rp;
    int s;
    
    char buf[32];
    snprintf(buf, 32, "%d", 0);
    
    memset(&hints, 0, sizeof(struct addrinfo));
    hints.ai_family = AF_INET;
    hints.ai_socktype = SOCK_STREAM;
    hints.ai_protocol = IPPROTO_TCP;
    hints.ai_flags = 0;
    
    s = getaddrinfo([host UTF8String], buf, &hints, &result);
    if (s != 0) {
        NSLog(@"get addr info error:%s", gai_strerror(s));
        return nil;
    }
    NSString *ip = nil;
    rp = result;
    if (rp != NULL) {
        struct sockaddr_in *addr = (struct sockaddr_in*)rp->ai_addr;
        ip = [self IP2String:addr->sin_addr];
    }
    freeaddrinfo(result);
    return ip;
}


@end
