//
//  main.m
//  SnapchatKit
//
//  Created by Tanner on 5/5/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SKClient.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        __block BOOL waiting = YES;
        [[SKClient sharedClient] signInWithUsername:@"username" password:@"password" gmail:@"something@gmail.com" gpass:@"gmailPassword" completion:^(NSDictionary *dict, NSError *error) {
            if (!error) {
                SKSession *session = [SKClient sharedClient].currentSession;
                NSLog(@"%@", session);
            }
            waiting = NO;
        }];
        
        while (waiting) {
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:.1]];
        }
    }
    return 0;
}
