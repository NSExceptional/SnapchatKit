//
//  main.m
//  SnapchatKit
//
//  Created by Tanner on 5/5/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"


#import <Foundation/Foundation.h>
#import "SnapchatKit.h"

// debug
#import "NSData+SnapchatKit.h"
@import AppKit;

// Comment this out on your machine
#import "Login.h"

void registerAccount(NSString *email, NSString *password, NSString *birthday) {
    [[SKClient sharedClient] registerEmail:email password:password birthday:birthday completion:^(NSDictionary *jsonemail, NSError *error) {
        if (!error) {
            NSArray *suggestions = jsonemail[@"username_suggestions"];
            
            // And this works
            [[SKClient sharedClient] registerUsername:suggestions[0] withEmail:jsonemail[@"email"] gmail:kGmail gmailPassword:kGmailPassword completion:^(BOOL success, NSError *error2) {
                if (success) {
                    
                    BOOL phone = NO;
                    if (!phone)
                        // And this works
                        [[SKClient sharedClient] getCaptcha:^(NSArray *imageData, NSError *error3) {
                            if (!error3) {
                                
                                NSMutableArray *images = [NSMutableArray new];
                                for (NSData *data in imageData)
                                    [images addObject:[[NSImage alloc] initWithData:data]];
                                
                                // Breakpoint below so I can solve the captcha then modify
                                // the value of answer in the debugger with "call [answer setString:@"newanswer"]"
                                NSMutableString *answer = [NSMutableString stringWithString:@"000000000"];
                                
                                // But this does not work
                                [[SKClient sharedClient] solveCaptchaWithSolution:answer completion:^(NSDictionary *dict, NSError *error4) {
                                    if (!error4) {
                                        
                                    } else {
                                        NSLog(@"%@", error4.localizedFailureReason);
                                    }
                                }];
                            } else {
                                NSLog(@"%@", error3.localizedFailureReason);
                            }
                        }];
                    else
                        [[SKClient sharedClient] sendPhoneVerification:kMobileNumber sendText:YES completion:^(NSDictionary *dict, NSError *error5) {
                            if (!error5) {
                                NSString *code = @"code";
                                [[SKClient sharedClient] verifyPhoneNumberWithCode:code completion:^(BOOL success, NSError *error) {
                                    if (success)
                                        NSLog(@"Success!");
                                    else
                                        NSLog(@"Failure");
                                }];
                            } else {
                                NSLog(@"%@", error5.localizedFailureReason);
                            }
                        }];
                    
                } else {
                    NSLog(@"%@", error2.localizedFailureReason);
                }
            }];
        } else {
            NSLog(@"%@", error.localizedFailureReason);
        }
    }];
    
}

void markSnapsRead(NSArray *unread) {
    for (SKSnap *snap in unread)
        [[SKClient sharedClient] markSnapViewed:snap.identifier for:1 completion:^(BOOL success, NSError *error) {
            if (success)
                NSLog(@"Success: %@", snap.identifier);
            else
                NSLog(@"Failure: %@", snap.identifier);
        }];
}

void markChatsRead(SKSession *session) {
    NSMutableArray *unreadChats = [NSMutableArray new];
    for (SKConversation *convo in session.conversations)
        if ([convo.usersWithPendingChats containsObject:session.username])
            [unreadChats addObject:convo];
    
    for (SKConversation *convo in unreadChats)
        [[SKClient sharedClient] markRead:convo completion:^(BOOL success, NSError *error) {
            if (success)
                NSLog(@"Success: %@", convo.identifier);
            else
                NSLog(@"Failure: %@", convo.identifier);
        }];
}

void saveUnreadSnapsToDirectory(NSArray *unread, NSString *path) {
    for (SKSnap *snap in unread)
        [snap loadMediaWithCompletion:^(NSData *snapData, NSError *error) {
            if (SKMediaKindIsImage(snap.mediaKind)) {
                // Turn it into an image if you want
                // NSImage *image = [[NSImage alloc] initWithData:snapData];
                [snapData writeToFile:[path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%@.jpg", snap.sender, snap.identifier]] atomically:YES];
                NSLog(@"Image snap from: %@", snap.sender);
            }
            else if (SKMediaKindIsVideo(snap.mediaKind)) {
                [snapData writeToFile:[path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%@.m4a", snap.sender, snap.identifier]] atomically:YES];
                NSLog(@"Video snap from: %@", snap.sender);
            }
        }];
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        __block BOOL waiting = YES;
        
        // Testing account registration.
        // Cannot seem to "solve" a captcha.
//        registerAccount(@"Tatem1984@jourrapide.com", @"12345678h", @"1995-08-01");
        
        [[SKClient sharedClient] signInWithUsername:kUsername password:kPassword gmail:kGmail gpass:kGmailPassword completion:^(NSDictionary *dict, NSError *error) {
            if (!error) {
                SKSession *session = [SKClient sharedClient].currentSession;
                
                // For debugging purposes, to see the size of the response JSON in memory. Mine was about 300 KB.
                // Probably quadratically larger though, since each object also holds onto its JSON dictionary,
                // ie each SKStoryCollection has the JSON for each story, and each SKStory also has its JSON.
                // TODO: make the _JSON property of SKThing dependent on kDebugJSON.
                NSData *data = [NSPropertyListSerialization dataWithPropertyList:[session valueForKey:@"_JSON"] format:NSPropertyListBinaryFormat_v1_0 options:0 error:nil];
                NSLog(@"Bytes: %lu Kilobytes: %f", data.length, ((float)data.length/1024.f));
                
                ////////////////////////////
                // I'm testing stuff here //
                ////////////////////////////
                
                // Get unread snaps
                NSArray *unread = session.unread;
                NSLog(@"%lu unread snaps: %@", unread.count, unread);
                
                // Download and save unread snaps
                NSString *directory = [[NSHomeDirectory() stringByAppendingPathComponent:@"Desktop"] stringByAppendingPathComponent:@"Snaps"];
//                saveUnreadSnapsToDirectory(unread, directory);
                
                // Mark snaps read
//                markSnapsRead(unread);
                
                // Mark chats read
//                markChatsRead(session);
                
//                 // Get best friends (not working, api disabled?)
//                [[SKClient sharedClient] bestFriendsOfUsers:@[@"todd7"] completion:^(NSDictionary *dict, NSError *error) {
//                    if (!error)
//                        NSLog(@"%@", dict);
//                }];
            }
        }];
        
        while (waiting) {
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:.1]];
        }
    }
    return 0;
}

#pragma clang diagnostic pop
