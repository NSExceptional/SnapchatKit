//
//  AppDelegate.m
//  SnapchatKit-iOS-Demo
//
//  Created by Tanner on 7/11/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "AppDelegate.h"
#import "SNTableViewController.h"

#import "SnapchatKit.h"

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    SNTableViewController *tableviewcontroller = [SNTableViewController new];
    tableviewcontroller.title = @"SnapchatKit";
    
    UINavigationController *nav = (UINavigationController *)self.window.rootViewController;
    [nav pushViewController:tableviewcontroller animated:YES];
    
    [self trySignIn];
    
    return YES;
}

- (SNTableViewController *)tableViewController {
    return (SNTableViewController *)([(UINavigationController *)self.window.rootViewController viewControllers].firstObject);
}

- (void)trySignIn {
    [[SKClient sharedClient] signInWithUsername:@"yourusername" password:@"yourpassword" gmail:@"you@gmail.com" gpass:@"123abc" completion:^(NSDictionary *dict, NSError *error) {
        if (!error) {
            [self tableViewController].dataSource = [SKClient sharedClient].currentSession.conversations.array;
            [[self tableViewController].tableView reloadData];
        } else {
            [self trySignIn];
            NSLog(@"Trying again...");
        }
    }];
}

@end
