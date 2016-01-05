//
//  AppDelegate.m
//  Room
//
//  Created by zjq on 15/12/2.
//  Copyright © 2015年 zjq. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"
#import "ServerVisit.h"
#import "ASNetwork.h"
#import "NtreatedDataManage.h"
#import "WXApi.h"
#import "WXApiManager.h"
#import "RoomApp.h"

@interface AppDelegate () <UISplitViewControllerDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    NSDictionary *navbarTitleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    [[UINavigationBar appearance] setTitleTextAttributes:navbarTitleTextAttributes];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setBarTintColor: [UIColor blackColor]];
    
    [ASNetwork sharedNetwork];
    [RoomApp shead].appDelgate = self;
    // Override point for customization after application launch.
    if (launchOptions) {
        NSString *string =  [NSString stringWithFormat:@"%@",launchOptions[UIApplicationLaunchOptionsURLKey]];
        if (![string isEqualToString:@"(null)"]) {
            NSLog(@"UIApplicationLaunchOptionsURLKey:%@",string);
            [self getUrlParamer:string withFirstIn:YES];
        }
    }
    
    /// 需要区分iOS SDK版本和iOS版本。
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)])
    {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge|UIUserNotificationTypeAlert|UIUserNotificationTypeSound) categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        
    } else
#endif
    {
        /// 去除warning
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
#pragma clang diagnostic pop
    }
    
    [WXApi registerApp:@"wx4d9fbaec0a4c368f" withDescription:@"demo 2.0"];
    UINavigationController *nai = [[UINavigationController alloc] initWithRootViewController:[MainViewController new]];
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    nai.navigationBarHidden = YES;
    [self.window setRootViewController:nai];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

/// iOS8下申请DeviceToken
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerForRemoteNotifications)]) {
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
}
#endif


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString *realDeviceToken = [NSString stringWithFormat:@"%@",deviceToken];
    realDeviceToken = [realDeviceToken stringByReplacingOccurrencesOfString:@"<" withString:@""];
    realDeviceToken = [realDeviceToken stringByReplacingOccurrencesOfString:@">" withString:@""];
    realDeviceToken = [realDeviceToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    [ServerVisit shead].deviceToken = realDeviceToken;
    // update deviceToken
    if (![[ServerVisit shead].authorization isEqualToString:@""]) {
        [ServerVisit updateDeviceTokenWithSign:[ServerVisit shead].authorization withToken:realDeviceToken completion:^(AFHTTPRequestOperation *operation, id responseData, NSError *error) {
            NSLog(@"update device token");
        }];
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"did Fail To Register For Remote Notifications With Error: %@", error);
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    // 解析url
    if ([[url scheme] isEqualToString:@"iosvideometting"]){
        NSString* encodedString = [NSString stringWithFormat:@"%@",url];
        [self getUrlParamer:encodedString withFirstIn:NO];
        
    }
    return [WXApi handleOpenURL:url delegate:[WXApiManager sharedManager]];
}

- (void)getUrlParamer:(NSString*)URL withFirstIn:(BOOL)isFirst
{
    NSRange rangeleft = [URL rangeOfString:@"?"];
    if (rangeleft.length <= 0 || rangeleft.location+1>URL.length) {
        return;
    }
    NSString *rightUrl = [URL substringFromIndex:rangeleft.location+1];
    NSArray *leftPar = [rightUrl componentsSeparatedByString:@"&"];
    if (leftPar.count==0) {
        return;
    }
    NSString *meetingStr = [leftPar objectAtIndex:0];
    NSArray *meetingArr = [meetingStr componentsSeparatedByString:@"="];
    if (meetingArr.count ==0) {
        return;
    }
    NSLog(@"meetingName:%@",[meetingArr objectAtIndex:1]);
    
    
    
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    if (isFirst) {
        // 用户还没有启动一种处理
//        [LoginUtil shead].dictShear = dict;
    }else{
        
//        [[NSNotificationCenter defaultCenter] postNotificationName:DreceivedDeviceCallNotification object:nil userInfo:dict];
    }
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return  [WXApi handleOpenURL:url delegate:[WXApiManager sharedManager]];
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
