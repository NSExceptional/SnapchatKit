//
//  SKClient.h
//  SnapchatKit
//
//  Created by Tanner on 5/5/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SnapchatKit-Constants.h"

@class SKSession;

@interface SKClient : NSObject

+ (instancetype)sharedClient;

- (void)signInWithUsername:(NSString *)username password:(NSString *)password gmail:(NSString *)gmailEmail gpass:(NSString *)gmailPassword completion:(DictionaryBlock)completion;
//- (void)sendSnap:(id)snapPNGData text:(NSString *)text duration:(NSUInteger)seconds;

@property (nonatomic) SKSession *currentSession;

// Data used to sign in
@property (nonatomic, readonly) NSString *googleAuthToken;
@property (nonatomic, readonly) NSString *deviceToken1i;
@property (nonatomic, readonly) NSString *deviceToken1v;
@property (nonatomic, readonly) NSString *googleAttestation;

@end
