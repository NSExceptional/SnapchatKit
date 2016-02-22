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
#import "NSMutableURLRequest+Util.h"

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

BOOL SKShouldUseStaticToken(NSString *endpiont) {
    static NSSet *staticTokenEndpoints = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        staticTokenEndpoints = [NSSet setWithArray:@[SKEPAccount.registration.start, SKEPAccount.registration.solveCaptcha,
                                                     SKEPAccount.registration.suggestUsername, SKEPAccount.registration.username,
                                                     SKEPAccount.registration.verifyPhone]];
    });
    
    return [staticTokenEndpoints containsObject:endpiont];
}


@implementation SKClient

@synthesize authToken = _authToken;

#pragma mark Initializers

static SKClient *sharedSKClient;
+ (instancetype)sharedClient {
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        sharedSKClient = [SKClient new];
        [[NSFileManager defaultManager] createDirectoryAtPath:SKTempDirectory() withIntermediateDirectories:YES attributes:nil error:nil];
    });
    
    return sharedSKClient;
}

- (id<SKCasperCache>)cache {
    if (!_cache) {
        _cache = [SKCasperCache new];
    }
    
    return _cache;
}

+ (void)setSharedClient:(SKClient *)client {
    NSParameterAssert(client);
    sharedSKClient = client;
}

+ (instancetype)clientWithUsername:(NSString *)username authToken:(NSString *)authToken {
    SKClient *client         = [self new];
    client.username          = username;
    client->_authToken       = authToken;
    
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

#pragma mark Casper

- (void)getClientLoginData:(NSString *)username password:(NSString *)password timestamp:(NSString *)ts callback:(DictionaryBlock)callback {
    NSParameterAssert(username); NSParameterAssert(password); NSParameterAssert(ts);
    NSAssert(self.casperAPIKey, @"You must have a valid API key from https://clients.casper.io to sign in.");
    //NSAssert(self.casperAPISecret, @"You must have a valid API secret from https://clients.casper.io to sign in.");
    
    // Build request
    NSDictionary *query   = @{@"username": username, @"password": password, @"iat": [NSString timestampInSeconds]};
    NSDictionary *headers = @{SKHeaders.casperAPIKey: self.casperAPIKey,
                              SKHeaders.casperSignature: SKMakeCapserSignature(query, self.casperAPISecret)};
    NSMutableURLRequest *request = [NSMutableURLRequest POST:@"https://casper-api.herokuapp.com/snapchat/ios/login"
                                                        body:@{@"jwt": [query JWTStringWithSecret:self.casperAPISecret]}
                                                     headers:headers];
    // Set optional headers
    if (self.casperUserAgent) {
        [request setValue:self.casperUserAgent forHTTPHeaderField:SKHeaders.userAgent];
    }
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        SKLog(@"Recieved casper response...");
        if (!error) {
            NSError *jsonError = nil;
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            
            if ([json[@"code"] integerValue] == 200) {
                callback(json, nil);
            }
            else {
                callback(nil, [SKRequest errorWithMessage:json[@"message"] code:[json[@"status"] integerValue]]);
            }
        } else {
            callback(nil, error);
        }
    }] resume];
}

- (void)getInformationForEndpoint:(NSString *)endpoint callback:(void (^)(NSDictionary *params, NSDictionary *headers, NSError *error))callback {
    NSParameterAssert(endpoint); NSParameterAssert(callback);
    NSAssert(self.username, @"Cannot make this request without a username.");
    NSAssert(self.casperAPIKey, @"You must have a valid API key from https://clients.casper.io to sign in.");
    //NSAssert(self.casperAPISecret, @"You must have a valid API secret from https://clients.casper.io to sign in.");
    
    NSDictionary *cached = self.cache[endpoint];
    if (cached) {
        callback(cached[@"params"], cached[@"headers"], nil);
    }
    
    // Do we need to use the static token?
    NSString *token = SKShouldUseStaticToken(endpoint) ? SKConsts.staticToken : _authToken;
    
    // Build request
    NSDictionary *query   = @{@"username": self.username, @"auth_token": token, @"endpoint": endpoint, @"iat": [NSString timestampInSeconds]};
    NSDictionary *headers = @{SKHeaders.casperAPIKey: self.casperAPIKey,
                              SKHeaders.casperSignature: SKMakeCapserSignature(query, self.casperAPISecret)};
    NSMutableURLRequest *request = [NSMutableURLRequest POST:@"https://casper-api.herokuapp.com/snapchat/ios/endpointauth"
                                                        body:@{@"jwt": [query JWTStringWithSecret:self.casperAPISecret]}
                                                     headers:headers];
    // Set optional headers
    if (self.casperUserAgent) {
        [request setValue:self.casperUserAgent forHTTPHeaderField:SKHeaders.userAgent];
    }
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSError *jsonError = nil;
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            
            if ([json[@"code"] integerValue] == 200) {
                [self.cache update:json];
                
                NSDictionary *data = self.cache[endpoint];
                callback(data[@"params"], data[@"headers"], nil);
            }
            else {
                callback(nil, nil, [SKRequest errorWithMessage:json[@"message"] code:[json[@"code"] integerValue]]);
            }
        } else {
            callback(nil, nil, error);
        }
    }] resume];
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
    
    [self getInformationForEndpoint:endpoint callback:^(NSDictionary *params, NSDictionary *headers, NSError *error) {
        if (!error) {
            [SKRequest postTo:endpoint query:SKMergeDictionaries(query, params) headers:headers callback:^(NSData *data, NSURLResponse *response, NSError *error2) {
                SKDispatchToMain([self handleError:error2 data:data response:response completion:callback]);
            }];
        } else {
            SKDispatchToMain(callback(nil, error));
        }
    }];
}

- (void)postTo:(NSString *)endpoint query:(NSDictionary *)query response:(void(^)(NSData *data, NSURLResponse *response, NSError *error))callback {
    NSParameterAssert(endpoint); NSParameterAssert(query);
    
    [self getInformationForEndpoint:endpoint callback:^(NSDictionary *params, NSDictionary *headers, NSError *error) {
        if (!error) {
            [SKRequest postTo:endpoint query:SKMergeDictionaries(query, params) headers:headers callback:callback];
        } else {
            SKDispatchToMain(callback(nil, nil, error));
        }
    }];
}

- (void)get:(NSString *)endpoint callback:(ResponseBlock)callback {
    NSParameterAssert(endpoint); NSParameterAssert(callback);
    
    [self getInformationForEndpoint:endpoint callback:^(NSDictionary *params, NSDictionary *headers, NSError *error) {
        if (!error) {
            
            [SKRequest get:endpoint headers:headers callback:^(NSData *data, NSURLResponse *response, NSError *error2) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (!error2) {
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
                        callback(nil, error2);
                    }
                });
            }];
        } else {
            callback(nil, error);
        }
    }];
}

#pragma mark Signing in

- (BOOL)isSignedIn {
    return self.authToken && self.username;
}

- (void)signInWithUsername:(NSString *)username password:(NSString *)password completion:(DictionaryBlock)completion {
    NSParameterAssert(username); NSParameterAssert(password); NSParameterAssert(completion);
    
    [self getClientLoginData:username password:password timestamp:[NSString timestamp] callback:^(NSDictionary *stuff, NSError *error) {
        if (!error) {
            SKRequest *request    = [[SKRequest alloc] initWithPOSTEndpoint:SKEPAccount.login query:stuff[@"params"] headers:stuff[@"headers"]];
            NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
            
            [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error2) {
                [self handleError:error2 data:data response:response completion:^(NSDictionary *json, NSError *jsonerror) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        SKLog(@"Recieved Snapchat login response...");
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
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil, error);
            });
        }
    }];
}

- (void)restoreSessionWithUsername:(NSString *)username snapchatAuthToken:(NSString *)authToken doGetUpdates:(ErrorBlock)completion {
    NSParameterAssert(username); NSParameterAssert(authToken);
    _username        = username;
    _authToken       = authToken;
    if (completion)
        [self updateSession:completion];
}

- (void)signOut:(ErrorBlock)completion {
    [self postTo:SKEPAccount.login query:@{@"username": self.currentSession.username} callback:^(NSDictionary *json, NSError *error) {
        if (!error) {
            [_cache clear];
            _currentSession    = nil;
            _username          = nil;
            _authToken         = nil;
            _deviceToken1i     = nil;
            _deviceToken1v     = nil;
            completion(nil);
        } else {
            completion(error);
        }
    }];
}

#pragma mark Misc

- (void)updateSession:(ErrorBlock)completion {
    SKAssertIsSignedIn(self);
    
    NSDictionary *query = @{@"username": self.username,
                            @"friends_request": @{@"friends_sync_token": self.currentSession.friendsSyncToken ?: @0}.JSONString,
                            @"height": @(self.screenSize.height),
                            @"width": @(self.screenSize.width),
                            @"screen_height_px": @(self.screenSize.height),
                            @"screen_width_px": @(self.screenSize.width),
                            @"screen_width_in": @0,
                            @"screen_height_in": @0,
                            @"checksums_dict": self.currentSession.checksums ?: @"{}"};
    [self postTo:SKEPUpdate.all query:query callback:^(NSDictionary *json, NSError *error) {
        if (!error) {
            BOOL partialFriends = [json[@"friends_response"][@"friends_sync_type"] isEqualToString:@"partial"];
            BOOL partialConvos  = [json[@"conversations_response_info"][@"is_delta"] boolValue];
            if (partialFriends || partialConvos) {
                _currentSession = [[[SKSession alloc] initWithDictionary:json] mergeWithOldSession:_currentSession];
            } else {
                _currentSession = [[SKSession alloc] initWithDictionary:json];
            }
            _authToken = self.currentSession.authToken;
            if (completion) completion(nil);
        } else {
            if (completion) completion(error);
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
}

- (void)getCaptcha:(ArrayBlock)completion {
    [self postTo:SKEPAccount.registration.getCaptcha query:@{@"username": self.username} response:^(NSData *data, NSURLResponse *response, NSError *error) {
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
    [self postTo:SKEPAccount.registration.verifyPhone query:query callback:^(NSDictionary *json, NSError *error) {
        SKLog(@"%@", json);
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
    
    [self postTo:SKEPUpdate.snaps query:query callback:^(NSDictionary *json, NSError *error) {
        if (completion) SKDispatchToMain(completion(error));
    }];
}

@end