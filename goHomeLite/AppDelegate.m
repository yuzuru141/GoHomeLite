//
//  AppDelegate.m
//  goHomeLite
//
//  Created by 石井嗣 on 2014/12/17.
//  Copyright (c) 2014年 YuZ. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // UIApplicationLaunchOptionsLocalNotificationKeyをキーにして、情報を取り出す
    UILocalNotification *notification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    
    // nilでなければ、通知の情報が格納されている
    if(notification != nil) {
        // ここに処理を書く
        [self.regViewConview fire];
        // 通知領域から消す
        [[UIApplication sharedApplication] cancelLocalNotification:notification];
    }
    NSLog(@"呼ばれる");
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    //新しく通知をセットする
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeSound categories:nil];
        [application registerUserNotificationSettings:settings];
        
        self.regViewConview = [[RegViewController alloc]init];
        [self.regViewConview LocalNotificationStart];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    //新しく通知をセットする
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeSound categories:nil];
        [application registerUserNotificationSettings:settings];
        
        self.regViewConview = [[RegViewController alloc]init];
        [self.regViewConview LocalNotificationStart];
    }
    
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    if (application.applicationState == UIApplicationStateActive) {
        //パターン1：画面が既に表示されていて通知が飛んできた時に勝手に呼ばれる
        NSLog(@"呼ばれる");
        [self.regViewConview fire];
        return;
    }
    
    if (application.applicationState == UIApplicationStateInactive) {
        //パターン2：アプリがバックグラウンドではアクティブでない時に通知をタップ
        [self.regViewConview fire];
                NSLog(@"呼ばれる");
        return;
    }
    if (application.applicationState == UIApplicationStateBackground) {
        //パターン3：アプリがバックグラウンドの時に通知をタップ
        [self.regViewConview fire];
                NSLog(@"呼ばれる");
        return;
    }
    
    
//    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"UIApplicationDidReceiveLocalNotification" object:self]];
}

@end
