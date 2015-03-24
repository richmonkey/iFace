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

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    //配置im server地址
//    [VOIPService instance].host = [Config instance].host;
//    [VOIPService instance].port = [Config instance].port;
    
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
    
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeNewsstandContentAvailability)];
    
    return YES;
}

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString* newToken = [deviceToken description];
	newToken = [newToken stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
	newToken = [newToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    self.deviceToken = newToken;
    
    Token *token = [Token instance];
    if (token.uid > 0) {
        [APIRequest bindDeviceToken:self.deviceToken
                           success:^{
                               NSLog(@"bind device token success");
                           }
                              fail:^{
                                  NSLog(@"bind device token fail");
                              }];
    }

    
    NSLog(@"device token is: %@:%@", deviceToken, newToken);
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
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
