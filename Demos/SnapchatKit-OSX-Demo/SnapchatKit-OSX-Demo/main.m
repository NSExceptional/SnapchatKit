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
#import "NSArray+SnapchatKit.h"
#import "NSString+SnapchatKit.h"
#import "TBTimer.h"
@import AppKit;
@import CoreLocation;

// Comment this out on your machine
#import "Login.h"

void registerAccount(NSString *email, NSString *password, NSString *birthday) {
    [[SKClient sharedClient] registerEmail:email password:password birthday:birthday completion:^(NSDictionary *jsonemail, NSError *error) {
        if (!error) {
            NSArray *suggestions = jsonemail[@"username_suggestions"];
            
            // And this works
            [[SKClient sharedClient] registerUsername:suggestions[0] withEmail:jsonemail[@"email"] gmail:kGmail gmailPassword:kGmailPassword completion:^(NSError *error2) {
                if (!error2) {
                    
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
                                        SKLog(@"%@", error4.localizedDescription);
                                    }
                                }];
                            } else {
                                SKLog(@"%@", error3.localizedDescription);
                            }
                        }];
                    else
                        [[SKClient sharedClient] sendPhoneVerification:kMobileNumber sendText:YES completion:^(NSDictionary *dict, NSError *error5) {
                            if (!error5) {
                                NSString *code = @"code";
                                [[SKClient sharedClient] verifyPhoneNumberWithCode:code completion:^(NSError *error6) {
                                    if (!error6)
                                        SKLog(@"Success!");
                                    else
                                        SKLog(@"Failure: %@", error.localizedDescription);
                                }];
                            } else {
                                SKLog(@"%@", error5.localizedDescription);
                            }
                        }];
                    
                } else {
                    SKLog(@"%@", error2.localizedDescription);
                }
            }];
        } else {
            SKLog(@"%@", error.localizedDescription);
        }
    }];
    
}

void markSnapsRead(NSArray *unread) {
    for (SKSnap *snap in unread)
        [[SKClient sharedClient] markSnapViewed:snap for:1 completion:^(NSError *error) {
            if (!error)
                SKLog(@"Success: %@", snap.identifier);
            else
                SKLog(@"Failure: %@", snap.identifier);
        }];
}

void markChatsRead(SKSession *session) {
    NSMutableArray *unreadChats = [NSMutableArray new];
    for (SKConversation *convo in session.conversations)
        if ([convo.usersWithPendingChats containsObject:session.username])
            [unreadChats addObject:convo];
    
    for (SKConversation *convo in unreadChats)
        [[SKClient sharedClient] markRead:convo completion:^(NSError *error) {
            if (!error)
                SKLog(@"Success: %@", convo.identifier);
            else
                SKLog(@"Failure: %@", convo.identifier);
        }];
}

void saveUnreadSnapsToDirectory(NSArray *unread, NSString *path) {
    for (SKSnap *snap in unread)
        [snap load:^(NSError *error) {
            if (!error) {
                // Turn it into an image if you want (if it's an image)
                // NSImage *image = [[NSImage alloc] initWithData:snap.blob.data];
                [snap.blob writeToPath:path filename:[NSString stringWithFormat:@"%@-%@", snap.sender, snap.identifier] atomically:YES];
                
                if (SKMediaKindIsImage(snap.mediaKind)) {
                    SKLog(@"Image snap from: %@", snap.sender);
                }
                else if (SKMediaKindIsVideo(snap.mediaKind)) {
                    SKLog(@"Video snap from: %@", snap.sender);
                }
            }
        }];
}

void testGetConversations() {
    [[SKClient sharedClient] conversationsWithUsers:@[@"luke_velten", @"baileybreen", @"avaallansnaps", @"abcdefgqwertyp"] completion:^(NSArray *conversations, NSArray *failed, NSError *error) {
        if (error)
            SKLog(@"%@", error.localizedFailureReason);
        SKLog(@"Conversations: %@", conversations);
        if (failed.count)
            SKLog(@"Failed to get convos with users: %@", failed);
    }];
}

void testGetStory(SKStory *story) {
    [story load:^(NSError *error) {
        if (!error) {
            SKLog(@"%@", story);
            if (SKMediaKindIsImage(story.mediaKind)) {
                NSImage *image = [[NSImage alloc] initWithData:story.blob.data];
            }
        }
    }];
}

void testGetAllStoriesInCollectionForUser(NSString *path, NSString *user) {
    SKStoryCollection *collection;
    for (SKStoryCollection *c in [SKClient sharedClient].currentSession.stories)
        if ([c.username isEqualToString:user]) {
            collection = c;
            break;
        }
    [[SKClient sharedClient] loadStories:collection.stories completion:^(NSArray *stories, NSArray *failed, NSArray *errors) {
        SKLog(@"%@", collection);
        for (SKStory *story in stories) {
            [story.blob writeToPath:path filename:story.suggestedFilename atomically:YES];
        }
    }];
}

void getFilterForCoordinates(CGFloat lat, CGFloat lon) {
    CLLocation *loc = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
    [[SKClient sharedClient] loadFiltersForLocation:loc completion:^(NSArray *collection, NSError *error) {
        if (!error) {
            SKLog(@"%@", collection);
        } else {
            SKLog(@"%@", error);
        }
    }];

}

void testSendSnapFromFileAtPathToUser(NSString *path, NSString *recipient) {
    SKBlob *blob = [SKBlob blobWithContentsOfPath:path];
    if (!blob) {
        SKLog(@"Error loading blob data for file at: %@", path);
        return;
    }
    
    [[SKClient sharedClient] sendSnap:blob to:@[recipient] text:nil timer:5.5 completion:^(SKSnapResponse *response, NSError *error) {
        if (!error)
            NSLog(@"Sent snap: %@", response);
        else
            NSLog(@"Failed to send snap: %@", error);
    }];
}

void testFindFriendsNearby(CGFloat lat, CGFloat lon) {
    CLLocation *loc = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
    
    [TBTimer startTimer];
    for (NSUInteger i = 0; i < 5; i++) {
        [[SKClient sharedClient] findFriendsNear:loc accuracy:50 pollDurationSoFar:(NSUInteger)([TBTimer lap]*1000) completion:^(NSArray *collection, NSError *error) {
            NSLog(@"%@", collection ?: error.localizedDescription);
        }];
        sleep(2);
    }
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        __block BOOL waiting = YES;
        NSString *directory = [[NSHomeDirectory() stringByAppendingPathComponent:@"Desktop"] stringByAppendingPathComponent:@"SnapchatKit-Data"];
        [[NSFileManager defaultManager] createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:nil];
        
        // Testing account registration.
        // Cannot seem to "solve" a captcha.
//        registerAccount(@"Tatem1984@jourrapide.com", @"12345678h", @"1995-08-01");
        
        [[SKClient sharedClient] signInWithUsername:kUsername password:kPassword gmail:kGmail gpass:kGmailPassword completion:^(NSDictionary *dict, NSError *error) {
            if (!error) {
                SKSession *session = [SKClient sharedClient].currentSession;
                [dict writeToFile:[directory stringByAppendingPathComponent:@"current-session.plist"] atomically:YES];
                SKLog(@"Session written to file.");
                
                // For debugging purposes, to see the size of the response JSON in memory. Mine was about 300 KB.
                // Probably quadratically larger though, since each object also holds onto its JSON dictionary,
                // ie each SKStoryCollection has the JSON for each story, and each SKStory also has its JSON.
                // TODO: make the _JSON property of SKThing dependent on kDebugJSON.
                NSData *data = [NSPropertyListSerialization dataWithPropertyList:[session valueForKey:@"_JSON"] format:NSPropertyListBinaryFormat_v1_0 options:0 error:nil];
                SKLog(@"Bytes: %lu Kilobytes: %f", data.length, ((float)data.length/1024));

                ////////////////////////////
                // I'm testing stuff here //
                ////////////////////////////
                
                // Get unread snaps
                NSArray *unread = session.unread;
                SKLog(@"%lu unread snaps: %@", unread.count, unread);
                
//                [[SKClient sharedClient] get:[NSString stringWithFormat:@"%@US", kepDiscoverChannels] callback:^(id object, NSError *error) {
//                    NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:object options:0 error:NULL];
//                    NSLog(@"Discover: %@", JSON ?: error.localizedDescription);
//                }];
                
//                testFindFriendsNearby(40.713054, -74.007228);
                
//                SKLog(@"Sending snap...");
//                testSendSnapFromFileAtPathToUser(@"/Users/tantan/Desktop/snap.png", @"tannerbennett");
                
                // Some locations with cool filters.
                // Waco       31.534173, -97.123863
                // NY         40.713054, -74.007228
                // SF         37.780080, -122.420168
                // LA         34.052238, -118.243344
                // Manchester 53.480713, -2.234377
                // Cypress    29.973334, -95.687332
                // Houston    29.760803, -95.369506
                // Seattle    47.603229, -122.330280
                // Cape Crn.  28.350458, -80.607516
                
                // Disney parks. Not all of them have filters, and some are redundant
                // Disney Paris    48.869981, 2.780242
                // Disney HK       22.312553, 114.041862
                // Animal Kingdom  28.355066, -81.590046
                // Disney Tokyo    35.632913, 139.880405
                // Courtyard Cocoa 28.350458, -80.607516
                // Spaceship Earth 28.375281, -81.549365
                // Hollywood       28.358270, -81.558856
                // Magic Kingdom   28.418933, -81.581206
//                getFilterForCoordinates(28.355066, -81.590046);
                
//                testGetAllStoriesInCollectionForUser([directory stringByAppendingPathComponent:@"Test-Stories"], @"someusername");
                
//                testGetConversations();
                
                // Download and save unread snaps
//                saveUnreadSnapsToDirectory(unread, directory);
                
                // Mark snaps read
                markSnapsRead(unread);
                
                // Mark chats read (not working)
//                markChatsRead(session);
                
//                 // Get best friends (not working, api disabled?)
//                [[SKClient sharedClient] bestFriendsOfUsers:@[@"luke_velten"] completion:^(NSDictionary *dict, NSError *error) {
//                    if (!error)
//                        SKLog(@"%@", dict);
//                }];
            } else {
                SKLog(@"%@", error.localizedDescription);
            }
        }];
        
        while (waiting) { [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:.1]]; }
    }
    return 0;
}

#pragma clang diagnostic pop
