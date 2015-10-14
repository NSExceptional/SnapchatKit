//
//  SKAppDelegate.m
//  SnapchatKit
//
//  Created by ThePantsThief on 07/29/2015.
//  Copyright (c) 2015 ThePantsThief. All rights reserved.
//

#import "SKAppDelegate.h"
#import "SNTableViewController.h"

#import "SnapchatKit.h"
#import "Login.h"

@implementation SKAppDelegate

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
    static uint16_t authenticationCount = 0;
    authenticationCount++;

    if (authenticationCount > 3) {
        return;
    }
    
    [[SKClient sharedClient] signInWithUsername:kUsername password:kPassword gmail:kGmail gpass:kGmailPassword completion:^(NSDictionary *dict, NSError *error) {
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
