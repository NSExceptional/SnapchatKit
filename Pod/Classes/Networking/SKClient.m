//
//  SKClient.m
//  SnapchatKit
//
//  Created by Tanner Bennett on 5/5/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "SKClient.h"
#import "SKSession.h"
#import "SKRequest.h"
#import "SKConversation.h"
#import "SKBlob.h"

#import "SnapchatKit-Constants.h"
#import "NSData+SnapchatKit.h"
#import "NSString+SnapchatKit.h"
#import "NSDictionary+SnapchatKit.h"
#import "NSArray+SnapchatKit.h"

#import "SSZipArchive.h"
#import <SystemConfiguration/SCNetworkReachability.h>
#import "Attestation.pb.h"

#define SKDispatchToMain(block) dispatch_async(dispatch_get_main_queue(), ^{ block; })

BOOL SKHasActiveConnection() {
    SCNetworkReachabilityFlags flags;
    SCNetworkReachabilityRef address;
    address = SCNetworkReachabilityCreateWithName(NULL, "appspot.com" );
    Boolean success = SCNetworkReachabilityGetFlags(address, &flags);
    CFRelease(address);
    
    bool canReach = success
    && !(flags & kSCNetworkReachabilityFlagsConnectionRequired)
    && (flags & kSCNetworkReachabilityFlagsReachable);
    
    return canReach;
}

NSDictionary *SKMakeSignInParams(NSString *gauth, NSString *attest, NSString *ptoken, NSString *clientAuthToken, NSDictionary *deviceTokens, NSString *timestamp) {
    return @{@"googleAuthToken": gauth, @"attestation": attest, @"pushToken": ptoken?:@"e", @"clientAuthToken": clientAuthToken, @"dt": deviceTokens, @"ts": timestamp};
}

NSString *SKMakeCapserSignature(NSDictionary *params, NSString *secret) {
    assert(params.allKeys.count); assert(secret);
    NSArray *sortedKeys = [params.allKeys sortedArrayUsingSelector:@selector(compare:options:)];
    NSMutableString *signature = [NSMutableString string];
    
    for (NSString *key in sortedKeys) {
        [signature appendString:key];
        [signature appendString:params[key]];
    }
    
    return [@"v1:" stringByAppendingString:[NSString hashHMac:signature key:secret].hexadecimalString];
}


@implementation SKClient

@synthesize authToken = _authToken;

#pragma mark Initializers

+ (instancetype)sharedClient {
    static SKClient *sharedSKClient;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        sharedSKClient = [SKClient new];
        [[NSFileManager defaultManager] createDirectoryAtPath:SKTempDirectory() withIntermediateDirectories:YES attributes:nil error:nil];
    });
    
    return sharedSKClient;
}

+ (instancetype)clientWithUsername:(NSString *)username authToken:(NSString *)authToken gauth:(NSString *)googleAuthToken {
    SKClient *client         = [self new];
    client.username          = username;
    client->_authToken       = authToken;
    client->_googleAuthToken = googleAuthToken;
    
    return client;
}

- (id)init {
    self = [super init];
    if (self) {
        if (NSClassFromString(@"UIScreen")) {
            id cls = NSClassFromString(@"UIScreen");
            id screen = [cls performSelector:@selector(mainScreen)];
            self.screenSize = [screen bounds].size;
            self.maxVideoSize = self.screenSize;
        } else {
            [self setScreenIdiom:0];
        }
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [self init];
    if (self) {
        _googleAuthToken   = [aDecoder decodeObjectForKey:@"googleAuthToken"];
        _googleAttestation = [aDecoder decodeObjectForKey:@"googleAttestation"];
        _deviceToken1i     = [aDecoder decodeObjectForKey:@"deviceToken1i"];
        _deviceToken1v     = [aDecoder decodeObjectForKey:@"deviceToken1v"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.googleAuthToken   forKey:@"googleAuthToken"];
    [aCoder encodeObject:self.googleAttestation forKey:@"googleAttestation"];
    [aCoder encodeObject:self.deviceToken1i     forKey:@"deviceToken1i"];
    [aCoder encodeObject:self.deviceToken1v     forKey:@"deviceToken1v"];
}

- (void)setCurrentSession:(SKSession *)currentSession {
    _currentSession = currentSession;
    _username = currentSession.username;
}

- (NSString *)authToken {
    return _authToken ?: SKConsts.staticToken;
}

- (void)setUsername:(NSString *)username {
    _username = [username lowercaseString];
}

- (void)setScreenIdiom:(SKScreenIdiom)idiom {
    switch (idiom) {
        case SKScreenIdiomiPhone4: {
            _screenSize = _maxVideoSize = CGSizeMake(640, 960);
            break;
        }
        case SKScreenIdiomiPhone5: {
            _screenSize = _maxVideoSize = CGSizeMake(640, 1136);
            break;
        }
        case SKScreenIdiomiPhone6: {
            _screenSize = _maxVideoSize = CGSizeMake(750, 1334);
            break;
        }
        case SKScreenIdiomiPhone6Plus: {
            _screenSize = _maxVideoSize = CGSizeMake(1080, 1920);
            break;
        }
    }
}

#pragma mark Convenience

- (void)handleError:(NSError *)error data:(NSData *)data response:(NSURLResponse *)response completion:(ResponseBlock)completion {
    NSParameterAssert(completion);
    
    // Pass data to the man-in-the-middle
    MiddleManBlock callback;
    if (self.middleMan) {
        callback = ^(id json, NSError *error, NSURLResponse *response) {
            [self.middleMan restructureJSON:json error:error response:response completion:completion];
        };
    } else {
        callback = ^(id json, NSError *error, NSURLResponse *response) {
            completion(json, error);
        };
    }
    
    NSInteger code = [(NSHTTPURLResponse *)response statusCode];
    
    if (error) {
        completion(nil, error);
    } else if (data.length) {
        NSError *jsonError;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
        
        // Could not parse JSON (it's probably HTML)
        if (jsonError) {
            NSString *html = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            if ([html containsString:@"<html><head>"]) {
                // Invalid request
                SKDispatchToMain(callback(nil, [SKRequest errorWithMessage:html.textFromHTML code:code], response));
            } else {
                // ???
                SKDispatchToMain(callback(nil, jsonError, response));
            }
        }
        
        else if (json) {
            if (code > 199 && code < 300) {
                // Suceeded with a response
                NSNumber *logged = json[@"logged"] ?: json[@"updates_response"][@"logged"];
                if (logged) {
                    if (logged.integerValue == 1)
                        SKDispatchToMain(callback(json, nil, response));
                    else
                        SKDispatchToMain(callback(nil, [SKRequest errorWithMessage:json[@"message"] code:[json[@"status"] integerValue]], response));
                } else {
                    SKDispatchToMain(callback(json, nil, response));
                }
            } else {
                // Failed with a message
                error = [SKRequest errorWithMessage:json[@"message"] code:code];
                SKDispatchToMain(callback(nil, error, response));
            }
        }
        else {
            SKDispatchToMain(callback(nil, [SKRequest unknownError], response));
        }
    } else if (code > 199 && code < 300) {
        // Succeeded with no response
        SKDispatchToMain(callback(nil, nil, response));
    } else {
        SKDispatchToMain(callback(nil, [SKRequest unknownError], response));
    }
}

- (void)postTo:(NSString *)endpoint query:(NSDictionary *)query callback:(ResponseBlock)callback {
    NSParameterAssert(endpoint); NSParameterAssert(query);
    [SKRequest postTo:endpoint query:query gauth:self.googleAuthToken token:self.authToken callback:^(NSData *data, NSURLResponse *response, NSError *error) {
        SKDispatchToMain([self handleError:error data:data response:response completion:callback]);
    }];
}

- (void)get:(NSString *)endpoint callback:(ResponseBlock)callback {
    NSParameterAssert(endpoint); NSParameterAssert(callback);
    [SKRequest get:endpoint callback:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!error) {
                NSInteger code = [(NSHTTPURLResponse *)response statusCode];
                if (code == 200)
                    callback(data, nil);
                else {
                    NSString *html = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    if ([html containsString:@"<html><head>"]) {
                        // Invalid request
                        callback(nil, [SKRequest errorWithMessage:html.textFromHTML code:code]);
                    } else {
                        callback(nil, [SKRequest errorWithMessage:@"Unknown error" code:[(NSHTTPURLResponse *)response statusCode]]);
                    }
                }
            } else {
                callback(nil, error);
            }
        });
    }];
}

#pragma mark Signing in

- (BOOL)isSignedIn {
    return self.googleAuthToken && self.authToken && self.username;
}

- (void)getClientLoginData:(NSString *)username password:(NSString *)password timestamp:(NSString *)ts callback:(DictionaryBlock)callback {
    NSParameterAssert(username); NSParameterAssert(password); NSParameterAssert(ts);
    NSAssert(self.casperAPIKey, @"You must have a valid API key from https://clients.casper.io to sign in.");
    //NSAssert(self.casperAPISecret, @"You must have a valid API secret from https://clients.casper.io to sign in.");
    
    // Params
    NSDictionary *query = @{@"username": username, @"password": password, @"timestamp": ts};
    
    // Build request
    NSURL *url = [NSURL URLWithString:@"http://api.casper.io/snapchat/auth"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"POST";
    request.HTTPBody   = [[NSString queryStringWithParams:query] dataUsingEncoding:NSUTF8StringEncoding];
    
    // Set headers
    [request setValue:self.casperAPIKey forHTTPHeaderField:SKHeaders.casperAPIKey];
    [request setValue:SKMakeCapserSignature(query, self.casperAPISecret) forHTTPHeaderField:SKHeaders.casperSignature];
    if (self.casperUserAgent) [request setValue:self.casperUserAgent forHTTPHeaderField:SKHeaders.userAgent];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSError *jsonError = nil;
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            
            if ([json[@"code"] integerValue] == 200)
                callback(json, nil);
            else
                callback(nil, [SKRequest errorWithMessage:json[@"message"] code:[json[@"status"] integerValue]]);
        } else {
            callback(nil, error);
        }
    }] resume];
}

- (void)signInWithUsername:(NSString *)username password:(NSString *)password completion:(DictionaryBlock)completion {
    NSParameterAssert(username); NSParameterAssert(password); NSParameterAssert(completion);
    
    [self getClientLoginData:username password:password timestamp:[NSString timestamp] callback:^(NSDictionary *stuff, NSError *error) {
        if (!error) {
            SKRequest *request    = [[SKRequest alloc] initWithPOSTEndpoint:SKEPAccount.login token:nil query:stuff[@"params"] headers:stuff[@"headers"] ts:stuff[@"params"][@"timestamp"]];
            NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
            
            [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error2) {
                [self handleError:error2 data:data response:response completion:^(NSDictionary *json, NSError *jsonerror) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (!jsonerror) {
                            self.currentSession = [SKSession sessionWithJSONResponse:json];
                            _authToken = self.currentSession.authToken;
                            completion(json, nil);
                        } else {
                            completion(nil, jsonerror);
                        }
                    });
                }];
            }] resume];
        } else {
            completion(nil, error);
        }
    }];
}

- (void)restoreSessionWithUsername:(NSString *)username snapchatAuthToken:(NSString *)authToken googleAuthToken:(NSString *)googleAuthToken doGetUpdates:(ErrorBlock)completion {
    NSParameterAssert(username); NSParameterAssert(authToken); NSParameterAssert(googleAuthToken);
    _username        = username;
    _authToken       = authToken;
    _googleAuthToken = googleAuthToken;
    if (completion)
        [self updateSession:completion];
}

- (void)signOut:(ErrorBlock)completion {
    [SKRequest postTo:SKEPAccount.login query:@{@"username": self.currentSession.username} gauth:self.googleAuthToken token:self.authToken callback:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (kVerboseLog) {
            NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            if (result.length == 0) {
                _currentSession    = nil;
                _username          = nil;
                _authToken         = nil;
                _googleAuthToken   = nil;
                _googleAttestation = nil;
                _deviceToken1i     = nil;
                _deviceToken1v     = nil;
                completion(nil);
            } else {
                completion([SKRequest errorWithMessage:result code:1]);
            }
        }
    }];
}

#pragma mark Misc

- (void)updateSession:(ErrorBlock)completion {
    SKAssertIsSignedIn(self);
    
    NSDictionary *query = @{@"username": self.username,
                            @"height": @(self.screenSize.height),
                            @"width": @(self.screenSize.width),
                            @"max_video_height": @(self.maxVideoSize.height),
                            @"max_video_width": @(self.maxVideoSize.width),
                            @"include_client_settings": @"true"};
    [self postTo:SKEPUpdate.all query:query callback:^(NSDictionary *json, NSError *error) {
        if (!error) {
            _currentSession = [[SKSession alloc] initWithDictionary:json];
            _authToken = self.currentSession.authToken;
            completion(nil);
        } else {
            completion(error);
        }
    }];
}

#pragma mark Registration

- (void)registerEmail:(NSString *)email password:(NSString *)password birthday:(NSString *)birthday completion:(DictionaryBlock)completion {
    NSParameterAssert(email); NSParameterAssert(password); NSParameterAssert(birthday); NSParameterAssert(completion);
    NSDictionary *query = @{@"email": email, @"password": password, @"birthday": birthday};
    
    /* If successful, json1 will be something like:
    {
        "auth_token" = ff8788437e471d21f60d83517581cae5;
        "default_username" = username;
        "default_username_status" = 1;
        email = "email@domain.com";
        logged = 1;
        "should_send_text_to_verify_number" = 0;
        "snapchat_phone_number" = "+19372034486";
        "username_suggestions" = (username5, username03, etc);
    } */
    [self postTo:SKEPAccount.registration.start query:query callback:^(NSDictionary *json, NSError *error) {
        if (!error) {
            // Continue registration
            if ([json[@"logged"] boolValue]) {
                _authToken = json[@"auth_token"];
                NSDictionary *result = @{@"email": json[@"email"],
                                         @"snapchat_phone_number": json[@"snapchat_phone_number"],
                                         @"username_suggestions": json[@"username_suggestions"]};
                completion(result, nil);
            }
            // Failed for some reason
            else {
                completion(nil, [SKRequest errorWithMessage:json[@"message"] code:[json[@"status"] integerValue]]);
            }
            
        }
    }];
}

- (void)registerUsername:(NSString *)username withEmail:(NSString *)registeredEmail gmail:(NSString *)gmail gmailPassword:(NSString *)gpass completion:(ErrorBlock)completion {
    NSParameterAssert(username); NSParameterAssert(registeredEmail); NSParameterAssert(gmail); NSParameterAssert(gpass); NSParameterAssert(completion);
    NSDictionary *query = @{@"username": registeredEmail,
                            @"selected_username": username};
    
    [self getAuthTokenForGmail:gmail password:gpass callback:^(NSString *gauth, NSError *error) {
        _googleAuthToken = gauth;
        [self postTo:SKEPAccount.registration.username query:query callback:^(NSDictionary *json, NSError *error) {
            if (!error) {
                
                // Continue registration
                self.currentSession = [[SKSession alloc] initWithDictionary:json];
                if (kDebugJSON && !self.currentSession) {
                    completion([SKRequest unknownError]);
                    SKLog(@"Unknown error: %@", json);
                } else {
                    _username = self.currentSession.username;
                    completion(nil);
                }
            }
            // Failed for some reason
            else {
                completion([SKRequest errorWithMessage:json[@"message"] code:[json[@"status"] integerValue]]);
            }
        }];
    }];
}

- (void)getCaptcha:(ArrayBlock)completion {
    [SKRequest postTo:SKEPAccount.registration.getCaptcha query:@{@"username": self.username} gauth:self.googleAuthToken token:self.authToken callback:^(NSData *data, NSURLResponse *response, NSError *error) {
        // Did get captcha ZIP
        if ([(NSHTTPURLResponse *)response statusCode] == 200) {
            NSString *dataPath   = [NSString stringWithFormat:@"%@sck-captcha.tmp", NSTemporaryDirectory()];
            NSString *imagesPath = [NSString stringWithFormat:@"%@sck-captcha-images/", NSTemporaryDirectory()];
            [data writeToFile:dataPath atomically:YES];
            // Unzip it
            [SSZipArchive unzipFileAtPath:dataPath toDestination:imagesPath completion:^(NSString *path, BOOL succeeded, NSError *error) {
                if (succeeded) {
                    NSArray *imagesNames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:imagesPath error:nil];
                    NSMutableArray *imageData = [NSMutableArray new];
                    for (NSString *path in imagesNames) {
                        NSData *data = [NSData dataWithContentsOfFile:[imagesPath stringByAppendingString:path]];
                        if (data)
                            [imageData addObject:data];
                    }
                    
                    completion(imageData, nil);
                    
                // Error unzipping
                } else if (error) {
                    completion(nil, error);
                } else {
                    completion(nil, [SKRequest errorWithMessage:@"Error unzipping captcha" code:1]);
                }
            }];
        // Failed to get captcha ZIP
        } else {
            completion(nil, [SKRequest errorWithMessage:@"Unknown error" code:[(NSHTTPURLResponse *)response statusCode]]);
        }
    }];
}

- (void)solveCaptchaWithSolution:(NSString *)solution completion:(DictionaryBlock)completion {
    NSParameterAssert(solution);
    NSDictionary *query = @{@"username": self.username,
                            @"captcha_id": [NSString SCIdentifierWith:self.username and:[[NSString timestamp] substringToIndex:13]],
                            @"captcha_solution": solution};
    [self postTo:SKEPAccount.registration.solveCaptcha query:query callback:^(NSDictionary *json, NSError *error) {
        SKLog(@"%@", json);
    }];
}

- (void)sendPhoneVerification:(NSString *)mobile sendText:(BOOL)sms completion:(DictionaryBlock)completion {
    NSParameterAssert(mobile); NSParameterAssert(completion);
    
    NSArray *digits = [mobile allMatchesForRegex:@"\\d"];
    if (digits.count != 10 && digits.count != 11) {
        completion(nil, [SKRequest errorWithMessage:@"Invalid phone number" code:400]);
    }
    
    NSString *countryCode;
    NSMutableString *number = [NSMutableString string];
    for (NSString *digit in digits)
        [number appendString:digit];
    
    if (digits.count == 11) {
        countryCode = digits[0];
        [number deleteCharactersInRange:NSMakeRange(0, 1)];
    }
    else {
        countryCode = @"1";
    }
    
    NSDictionary *query = @{@"username": self.username,
                            @"phoneNumber": number,
                            @"countryCode": countryCode,
                            @"action": @"updatePhoneNumber",
                            @"skipConfirmation": @YES};
    [self postTo:SKEPAccount.registration.verifyPhone query:query callback:^(NSDictionary *json, NSError *error) {
        SKLog(@"%@", json);
    }];
}

- (void)verifyPhoneNumberWithCode:(NSString *)code completion:(ErrorBlock)completion {
    NSParameterAssert(code); NSParameterAssert(completion);
    NSDictionary *query = @{@"action": @"verifyPhoneNumber",
                            @"username": self.username,
                            @"code": code};
    // Hash timestamp with static token before passing as token?
    [SKRequest postTo:SKEPAccount.registration.verifyPhone query:query gauth:self.googleAuthToken token:SKConsts.staticToken callback:^(NSData *data, NSURLResponse *response, NSError *error) {
        [self handleError:error data:data response:response completion:^(NSDictionary *json, NSError *error) {
            SKLog(@"%@", json);
        }];
    }];
}

#pragma mark For categories

- (void)sendEvents:(NSArray *)events data:(NSDictionary *)snapInfo completion:(ErrorBlock)completion {
    if (!completion) completion = ^(id e){};
    if (!events)   events = @[];
    if (!snapInfo) snapInfo = @{};
    NSDictionary *query = @{@"events": events.JSONString,
                            @"json": snapInfo.JSONString,
                            @"username": self.currentSession.username};
    
    [SKRequest postTo:SKEPUpdate.snaps query:query gauth:self.googleAuthToken token:self.authToken callback:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (completion)
            dispatch_async(dispatch_get_main_queue(), ^{
                if (data.length == 0 && [(NSHTTPURLResponse *)response statusCode] == 200)
                    completion(nil);
                else if (error) {
                    completion(error);
                } else {
                    completion([SKRequest unknownError]);
                }
            });
    }];
}

@end