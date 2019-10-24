//
//  AppDelegate.m
//  ZZWhiteBoard
//
//  Created by 泽泽 on 2019/9/4.
//  Copyright © 2019 泽泽. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
//    let username = "customerId"
//    let password = "customerCertificate"
//    let loginString = String(format: "%@:%@", username, password)
//    let loginData = loginString.data(using: String.Encoding.utf8)! /
    // base64LoginString 就是你要的 Authorization 值，是一个使用 Base64 算法编码的 LoginString
//    let base64LoginString = loginData.base64EncodedString()
    //NzRlYjM4NTBiNTU4NGQ1NWExNDBhNWIwZDNhMWZjZWQ6ODFlMGM3MjkyNTQ5NGZiZmFjMmEzZDUxMDU2NjVhY2Y=
    NSString *str = @"74eb3850b5584d55a140a5b0d3a1fced:81e0c72925494fbfac2a3d5105665acf";
    NSData  *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSString *baseStr =  [data base64EncodedStringWithOptions:0];
    XXLog(@"baseStr == %@",baseStr);
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
