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
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    SNTableViewController *root = [SNTableViewController new];
    root.title = @"SnapchatKit";

    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:root];
    [self.window makeKeyAndVisible];

    [self trySignIn];
    
    return YES;
}

- (SNTableViewController *)tableViewController {
    return (id)([(id)self.window.rootViewController viewControllers].firstObject);
}

- (void)trySignIn {
    static uint16_t authenticationCount = 0;
    authenticationCount++;

    if (authenticationCount > 3) {
        return;
    }
    
    [[SKClient sharedClient] signInWithUsername:kUsername password:kPassword completion:^(NSDictionary *dict, NSError *error) {
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
