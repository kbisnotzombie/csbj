//
//  CBAppDelegate.m
//  HuXiu
//
//  Created by ly on 13-6-29.
//  Copyright (c) 2013年 Lei Yan. All rights reserved.
//

#import "CBAppDelegate.h"
#import <AVOSCloud/AVOSCloud.h>
#import "LocalInfo.h"
#import "CBViewController.h"

@implementation CBAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [AVOSCloud setApplicationId:@"n6k13cltwah76kysih14vx30nof7bkl3dkvcqlx2jt1rob6p"
                      clientKey:@"2qd00uj23v5b32ejhqxirwb87oz1kbufiddib63xz3f1z6t0"];
    
    // Register for push notifications
    [application registerForRemoteNotificationTypes:
     UIRemoteNotificationTypeBadge |
     UIRemoteNotificationTypeAlert |
     UIRemoteNotificationTypeSound];
    
    // 隐藏 status bar
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.viewController = [[CBViewController alloc] initWithNibName:@"CBViewController" bundle:nil];
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:self.viewController];
    [self.window makeKeyAndVisible];
    return YES;
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
    AVInstallation *currentInstallation = [AVInstallation currentInstallation];
    if (application.applicationIconBadgeNumber != 0 || [LocalInfo sharedSingleton].notificationInfo) {
        application.applicationIconBadgeNumber = 0;
        currentInstallation.badge = 0;
        [currentInstallation saveEventually];
        
        UIViewController* root = _window.rootViewController;
        UINavigationController *navController = (UINavigationController *)root;
        CBViewController *mycontroller = (CBViewController *)[[navController viewControllers] objectAtIndex:0];
        [LocalInfo sharedSingleton].notificationInfo = NO;
        [mycontroller viewDidLoad];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    AVInstallation *currentInstallation = [AVInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    if (application.applicationState == UIApplicationStateActive) {
        // 此处可以写上应用激活状态下接收到通知的处理代码，如无需处理可忽略
        [LocalInfo sharedSingleton].notificationInfo = YES;
    } else {
        // The application was just brought from the background to the foreground,
        // so we consider the app as having been "opened by a push notification."
        [LocalInfo sharedSingleton].notificationInfo = YES;
    }
}

@end
