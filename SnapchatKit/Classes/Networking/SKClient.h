//
//  SKClient.h
//  SnapchatKit
//
//  Created by Tanner on 5/5/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SnapchatKit-Constants.h"

#import "SKSession.h"

@interface SKClient : NSObject

+ (instancetype)sharedClient;
@property (nonatomic) CGSize screenSize;
@property (nonatomic) CGSize maxVideoSize;

#pragma mark Signing in
- (void)signInWithUsername:(NSString *)username password:(NSString *)password gmail:(NSString *)gmailEmail gpass:(NSString *)gmailPassword completion:(DictionaryBlock)completion;
- (void)signOut;
- (BOOL)isSignedIn;

#pragma mark Misc
- (void)updateSession:(ErrorBlock)completion;

#pragma mark Registration
/**
 The first step in creating a new Snapchat account. Registers an email, password, and birthday in preparation for creating a new account.
 
 The dictionary passed to completion has the following keys:
 
    - email:                 the email you registered with.
 
    - snapchat_phone_number: a number you can use to verify your phone number later.
 
    - username_suggestions:  an array of available usernames for the next step.
 
 @param email The email address to be associated with the account.
 @param password The password of the account to be created.
 @param birthday Your birthday, in the format YYYY-MM-DD.
 */
- (void)registerEmail:(NSString *)email password:(NSString *)password birthday:(NSString *)birthday completion:(DictionaryBlock)completion;

/**
 The second step in creating a new Snapchat account. Registers a username with an email that was registered in the first step.
 You must call this method after successfully completing the first step in registration.
 
 @param username The username of the account to be created, trimmed to the first 15 characters.
 @param registeredEmail The email address to be associated with the account, used in the first step of registration.
 @param gmail A valid GMail address. Required to make Snapchat think this is an official client.
 @param gpass The password to the Google account associated with gmail.
 */
- (void)registerUsername:(NSString *)username withEmail:(NSString *)registeredEmail gmail:(NSString *)gmail gmailPassword:(NSString *)gpass completion:(BooleanBlock)completion;

/**
 The third and final step in registration. If you don't want to verify your humanity a phone number, you can verify it by with a "captcha" image of sorts.
 
 @param mobile A 10-digit (+ optional country code, defaults to 1) mobile phone number to be associated with the account, in any format. i.e. +11234567890, (123) 456-7890, 1-1234567890
 @param sms YES if you want a code sent via SMS, NO if you want to be called for verification.
 */
- (void)sendPhoneVerification:(NSString *)mobile sendText:(BOOL)sms completion:(DictionaryBlock)completion;
- (void)verifyPhoneNumberWithCode:(NSString *)code completion:(BooleanBlock)completion;

- (void)getCaptcha:(ArrayBlock)completion;
- (void)solveCaptchaWithSolution:(NSString *)solution completion:(DictionaryBlock)completion;

#pragma mark Internal
- (void)postTo:(NSString *)endpoint query:(NSDictionary *)query callback:(ResponseBlock)callback;
- (void)get:(NSString *)endpoint callback:(ResponseBlock)callback;
- (void)sendEvents:(NSArray *)events data:(NSDictionary *)snapInfo completion:(ErrorBlock)completion;
/** Completion is GUARANTEED to have one and only one non-nil parameter. */
- (void)handleError:(NSError *)error data:(NSData *)data response:(NSURLResponse *)response completion:(ResponseBlock)completion;

/** Always lowercase. */
@property (nonatomic, readonly) NSString *username;
@property (nonatomic) SKSession *currentSession;

// Data used to sign in
@property (nonatomic, readonly) NSString *authToken;
@property (nonatomic, readonly) NSString *googleAuthToken;
@property (nonatomic, readonly) NSString *deviceToken1i;
@property (nonatomic, readonly) NSString *deviceToken1v;
@property (nonatomic, readonly) NSString *googleAttestation;

@end

// Used in most method calls
NS_INLINE void SKAssertIsSignedIn() {
    if (![SKClient sharedClient].isSignedIn)
        [NSException raise:NSInternalInconsistencyException format:@"You must be signed in to call this method."];
}