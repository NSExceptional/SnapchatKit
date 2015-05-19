//
//  main.m
//  SnapchatKit
//
//  Created by Tanner on 5/5/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SKClient.h"

// Comment this out on your machine
#import "Login.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        __block BOOL waiting = YES;
        [[SKClient sharedClient] signInWithUsername:kUsername password:kPassword gmail:kGmail gpass:kGmailPassword completion:^(NSDictionary *dict, NSError *error) {
            if (!error) {
                SKSession *session = [SKClient sharedClient].currentSession;
                
                // For debugging purposes, to see the size of the response JSON in memory. Mine was about 300 KB.
                // Probably quadratically larger though, since each object also holds onto its JSON dictionary,
                // ie each SKStoryCollection has the JSON for each story, and each SKStory also has its JSON.
                NSData *data = [NSPropertyListSerialization dataWithPropertyList:[session valueForKey:@"_JSON"] format:NSPropertyListBinaryFormat_v1_0 options:0 error:nil];
                NSLog(@"Bytes: %lu Kilobytes: %f", (unsigned long)data.length, ((float)data.length/1024.f));
            }
            waiting = NO;
        }];
        
        while (waiting) {
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:.1]];
        }
    }
    return 0;
}