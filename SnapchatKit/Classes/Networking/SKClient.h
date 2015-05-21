//
//  SKClient.h
//  SnapchatKit
//
//  Created by Tanner on 5/5/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SnapchatKit-Constants.h"

#import "SKSession.h"

@interface SKClient : NSObject

+ (instancetype)sharedClient;

- (void)signInWithUsername:(NSString *)username password:(NSString *)password gmail:(NSString *)gmailEmail gpass:(NSString *)gmailPassword completion:(DictionaryBlock)completion;
- (void)signOut;

- (void)addFriend:(NSString *)username completion:(DictionaryBlock)completion;
- (void)unfriend:(NSString *)friend completion:(DictionaryBlock)completion;
- (void)bestFriendsOfUsers:(NSArray *)usernames completion:(DictionaryBlock)completion;

@property (nonatomic) SKSession *currentSession;

// Data used to sign in
@property (nonatomic, readonly) NSString *authToken;
@property (nonatomic, readonly) NSString *googleAuthToken;
@property (nonatomic, readonly) NSString *deviceToken1i;
@property (nonatomic, readonly) NSString *deviceToken1v;
@property (nonatomic, readonly) NSString *googleAttestation;

@end
